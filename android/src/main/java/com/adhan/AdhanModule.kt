package com.adhan

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import kotlin.math.*

@ReactModule(name = AdhanModule.NAME)
class AdhanModule(reactContext: ReactApplicationContext) :
  NativeAdhanSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }

  // Native method declarations
  external fun calculatePrayerTimesNative(
    latitude: Double,
    longitude: Double,
    dateIso: String,
    method: String,
    madhab: String?,
    timezone: String?,
    adjustments: String?
  ): String

  external fun calculateQiblaDirectionNative(
    latitude: Double,
    longitude: Double
  ): String

  override fun getPrayerTimes(
    latitude: Double,
    longitude: Double,
    dateIso: String,
    method: String,
    madhab: String?,
    adjustments: String?,
    customAngles: String?
  ): String {
    return try {
      // Debug logging to trace parameters
      Log.i(NAME, "Android getPrayerTimes called with method: $method, madhab: $madhab, lat: $latitude, lon: $longitude, date: $dateIso")
      Log.i(NAME, "Using fallback calculation for testing. Method: $method, Madhab: $madhab")
      return fallbackCalculation(latitude, longitude, dateIso, method, madhab, null, adjustments, customAngles)
    } catch (e: Exception) {
      Log.e(NAME, "Error in fallback calculation", e)
      return "{}"
    }
  }

  private fun fallbackCalculation(
    latitude: Double,
    longitude: Double,
    dateIso: String,
    method: String,
    madhab: String?,
    timezone: String?,
    adjustments: String?,
    customAngles: String?
  ): String {
    return try {
      val result = JSONObject()
      
      // Parse input date
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val date = inputFormat.parse(dateIso) ?: Date()
      
      // Set up timezone
      val calculationTimeZone: TimeZone = when {
        timezone.isNullOrEmpty() -> TimeZone.getDefault()
        timezone.startsWith("+") || timezone.startsWith("-") -> {
          TimeZone.getTimeZone("GMT${timezone}")
        }
        else -> TimeZone.getTimeZone(timezone)
      }
      
      val outputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.US).apply {
        timeZone = calculationTimeZone
      }
      
      val calendar = Calendar.getInstance(calculationTimeZone).apply {
        time = date
      }
      
      // Parse calculation method angles with exact adhan-swift defaults
      var fajrAngle = 18.0 // Default to MWL
      var ishaAngle = 17.0
      var ishaIsInterval = false
      var ishaInterval = 0.0
      var maghribAngle = 0.0
      
      // Method-specific built-in adjustments (exactly matching adhan-swift)
      val methodAdjustments = mutableMapOf(
        "fajr" to 0, "sunrise" to 0, "dhuhr" to 0, 
        "asr" to 0, "maghrib" to 0, "isha" to 0
      )
      
      when (method) {
        "ISNA" -> { 
          fajrAngle = 15.0; ishaAngle = 15.0
          methodAdjustments["dhuhr"] = 1 // +1 minute
          Log.i(NAME, "Android using ISNA method: fajr=${fajrAngle}°, isha=${ishaAngle}°")
        }
        "MWL" -> { 
          fajrAngle = 18.0; ishaAngle = 17.0
          methodAdjustments["dhuhr"] = 1 // +1 minute
          Log.i(NAME, "Android using MWL method: fajr=${fajrAngle}°, isha=${ishaAngle}°")
        }
        "Karachi" -> { 
          fajrAngle = 18.0; ishaAngle = 18.0
          methodAdjustments["dhuhr"] = 1 // +1 minute
        }
        "Egyptian" -> { 
          fajrAngle = 19.5; ishaAngle = 17.5
          methodAdjustments["dhuhr"] = 1 // +1 minute
        }
        "UmmAlQura" -> { 
          fajrAngle = 18.5; ishaInterval = 90.0; ishaIsInterval = true
          // No method adjustments
        }
        "Dubai" -> { 
          fajrAngle = 18.2; ishaAngle = 18.2
          methodAdjustments["sunrise"] = -3
          methodAdjustments["dhuhr"] = 3
          methodAdjustments["asr"] = 3
          methodAdjustments["maghrib"] = 3
        }
        "Kuwait" -> { 
          fajrAngle = 18.0; ishaAngle = 17.5
          // No method adjustments
        }
        "Qatar" -> { 
          fajrAngle = 18.0; ishaInterval = 90.0; ishaIsInterval = true
          // No method adjustments
        }
        "Singapore" -> { 
          fajrAngle = 20.0; ishaAngle = 18.0
          methodAdjustments["dhuhr"] = 1 // +1 minute
          // Note: Singapore also uses rounding = up in adhan-swift
        }
        "Tehran" -> { 
          fajrAngle = 17.7; ishaAngle = 14.0; maghribAngle = 4.5
          // No method adjustments
        }
        "Turkey" -> { 
          fajrAngle = 18.0; ishaAngle = 17.0
          methodAdjustments["fajr"] = 0
          methodAdjustments["sunrise"] = -7
          methodAdjustments["dhuhr"] = 5
          methodAdjustments["asr"] = 4
          methodAdjustments["maghrib"] = 7
          methodAdjustments["isha"] = 0
        }
        "Moonsighting" -> {
          fajrAngle = 18.0; ishaAngle = 18.0
          methodAdjustments["dhuhr"] = 5
          methodAdjustments["maghrib"] = 3
        }
      }
      
      // Override with custom angles if provided
      customAngles?.let { angles ->
        try {
          val customDict = JSONObject(angles)
          customDict.optDouble("fajrAngle").let { if (it != 0.0) fajrAngle = it }
          customDict.optDouble("ishaAngle").let { if (it != 0.0) { ishaAngle = it; ishaIsInterval = false } }
          customDict.optDouble("ishaInterval").let { if (it != 0.0) { ishaInterval = it; ishaIsInterval = true } }
        } catch (e: Exception) {
          Log.w(NAME, "Failed to parse custom angles: $angles", e)
        }
      }
      
      // Improved calculations with better astronomical accuracy
      val dayOfYear = calendar.get(Calendar.DAY_OF_YEAR)
      val year = calendar.get(Calendar.YEAR)
      
      // Calculate Julian Day for more accurate calculations
      val julianDay = (1461 * (year + 4800 + (calendar.get(Calendar.MONTH) + 1 - 14) / 12)) / 4 +
                      (367 * (calendar.get(Calendar.MONTH) + 1 - 2 - 12 * ((calendar.get(Calendar.MONTH) + 1 - 14) / 12))) / 12 -
                      (3 * ((year + 4900 + (calendar.get(Calendar.MONTH) + 1 - 14) / 12) / 100)) / 4 +
                      calendar.get(Calendar.DAY_OF_MONTH) - 32075.5
      
      val T = (julianDay - 2451545.0) / 36525.0
      
      // More accurate solar declination calculation
      val L0 = (280.4664567 + 36000.76983 * T + 0.0003032 * T * T).let { 
        it - 360.0 * floor(it / 360.0) 
      }
      val M = (357.52911 + 35999.05029 * T - 0.0001537 * T * T) * PI / 180.0
      val C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sin(M) +
              (0.019993 - 0.000101 * T) * sin(2 * M) +
              0.000289 * sin(3 * M)
      val lambda = (L0 + C - 0.00569) * PI / 180.0
      val epsilon = (23.439291 - 0.013004167 * T) * PI / 180.0
      val declination = asin(sin(epsilon) * sin(lambda))
      
      // More accurate equation of time
      val y = tan(epsilon / 2).pow(2)
      val E = 4 * (y * sin(2 * L0 * PI / 180.0) - 2 * sin(M) + 4 * sin(M) * y * cos(2 * L0 * PI / 180.0) -
                   0.5 * y * y * sin(4 * L0 * PI / 180.0) - 1.25 * sin(2 * M)) * 180.0 / PI
      
      // Solar noon calculation with longitude correction
      val solarNoon = 12.0 - (longitude / 15.0) + (E / 60.0)
      
      // Sunrise and sunset with atmospheric refraction
      val latRad = latitude * PI / 180.0
      val h0 = -50.0 / 60.0 * PI / 180.0 // -50 arcminutes for atmospheric refraction
      val cosH = (sin(h0) - sin(latRad) * sin(declination)) / (cos(latRad) * cos(declination))
      
      if (abs(cosH) <= 1) {
        val H = acos(cosH) * 180.0 / PI / 15.0
        val sunrise = solarNoon - H
        val sunset = solarNoon + H
        
        // Fajr calculation
        val fajrCos = (sin(-fajrAngle * PI / 180.0) - sin(latRad) * sin(declination)) / (cos(latRad) * cos(declination))
        val fajr = if (abs(fajrCos) <= 1) {
          val fajrH = acos(fajrCos) * 180.0 / PI / 15.0
          solarNoon - fajrH
        } else {
          // Fallback for extreme latitudes
          sunrise - 1.5 // 1.5 hours before sunrise
        }
        
        // Asr calculation with madhab consideration (following adhan-swift logic)
        val shadowLength = if (madhab == "Hanafi") 2.0 else 1.0
        val tangent = abs(latRad - declination)
        val inverse = shadowLength + tan(tangent)
        val asrAngle = atan(1.0 / inverse)
        val asrCos = (sin(asrAngle) - sin(latRad) * sin(declination)) / (cos(latRad) * cos(declination))
        val asr = if (abs(asrCos) <= 1) {
          val asrH = acos(asrCos) * 180.0 / PI / 15.0
          solarNoon + asrH
        } else {
          // Fallback for extreme latitudes
          solarNoon + 3.0 // 3 hours after noon
        }
        
        // Isha calculation
        val isha = if (ishaIsInterval) {
          sunset + ishaInterval / 60.0
        } else {
          val ishaCos = (sin(-ishaAngle * PI / 180.0) - sin(latRad) * sin(declination)) / (cos(latRad) * cos(declination))
          if (abs(ishaCos) <= 1) {
            val ishaH = acos(ishaCos) * 180.0 / PI / 15.0
            solarNoon + ishaH
          } else {
            // Fallback for extreme latitudes
            sunset + 1.5 // 1.5 hours after sunset
          }
        }
        
        Log.i(NAME, "Android calculated times: fajr=$fajr, sunrise=$sunrise, dhuhr=$solarNoon, asr=$asr, maghrib=$sunset, isha=$isha")
        
        // Parse user adjustments
        val userAdj = adjustments?.let {
          try { JSONObject(it) } catch (e: Exception) { null }
        }
        
        // Create final dates with both method adjustments and user adjustments
        fun createPrayerTime(hour: Double, prayerName: String): String {
          val finalHour = hour.toInt()
          val baseMinute = ((hour - finalHour) * 60).toInt()
          
          // Apply method adjustments (built-in to calculation method)
          val methodAdjustment = methodAdjustments[prayerName] ?: 0
          
          // Apply user adjustments (custom overrides)
          val userAdjustment = userAdj?.optInt(prayerName) ?: 0
          
          // Total adjustment = method adjustment + user adjustment
          val finalMinute = baseMinute + methodAdjustment + userAdjustment
          
          // Handle minute overflow/underflow
          var adjustedHour = finalHour
          var adjustedMinute = finalMinute
          
          if (adjustedMinute >= 60) {
            adjustedHour += adjustedMinute / 60
            adjustedMinute %= 60
          } else if (adjustedMinute < 0) {
            adjustedHour -= ((-adjustedMinute - 1) / 60 + 1)
            adjustedMinute = 60 - ((-adjustedMinute) % 60)
            if (adjustedMinute == 60) adjustedMinute = 0
          }
          
          // Handle hour overflow/underflow for day boundaries
          if (adjustedHour >= 24) {
            adjustedHour %= 24
            calendar.add(Calendar.DAY_OF_YEAR, 1)
          } else if (adjustedHour < 0) {
            adjustedHour = 24 + (adjustedHour % 24)
            calendar.add(Calendar.DAY_OF_YEAR, -1)
          }
          
          calendar.set(Calendar.HOUR_OF_DAY, adjustedHour)
          calendar.set(Calendar.MINUTE, adjustedMinute)
          calendar.set(Calendar.SECOND, 0)
          calendar.set(Calendar.MILLISECOND, 0)
          
          val result = outputFormat.format(calendar.time)
          
          // Reset calendar to original date to avoid cumulative day changes
          calendar.time = date
          
          return result
        }
        
        result.put("fajr", createPrayerTime(fajr, "fajr"))
        result.put("sunrise", createPrayerTime(sunrise, "sunrise"))
        result.put("dhuhr", createPrayerTime(solarNoon, "dhuhr"))
        result.put("asr", createPrayerTime(asr, "asr"))
        result.put("maghrib", createPrayerTime(sunset, "maghrib"))
        result.put("isha", createPrayerTime(isha, "isha"))
      }
      
      result.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error in fallback calculation", e)
      "{}"
    }
  }

  override fun getQiblaDirection(latitude: Double, longitude: Double): String {
    return try {
      // Use fallback calculation (native disabled for testing)
      val makkahLat = 21.4225
      val makkahLon = 39.8262
      
      val lat1 = Math.toRadians(latitude)
      val lat2 = Math.toRadians(makkahLat)
      val deltaLon = Math.toRadians(makkahLon - longitude)
      
      val y = sin(deltaLon) * cos(lat2)
      val x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
      var direction = Math.toDegrees(atan2(y, x))
      direction = (direction + 360) % 360
      
      val R = 6371.0
      val dLat = Math.toRadians(makkahLat - latitude)
      val dLon = deltaLon
      val a = sin(dLat / 2).pow(2) + cos(lat1) * cos(lat2) * sin(dLon / 2).pow(2)
      val c = 2 * atan2(sqrt(a), sqrt(1 - a))
      val distance = R * c
      
      val bearings = arrayOf("N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                           "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW")
      val index = ((direction / 22.5).roundToInt()) % 16
      val compassBearing = bearings[index]
      
      val result = JSONObject()
      result.put("direction", direction)
      result.put("distance", distance)
      result.put("compassBearing", compassBearing)
      
      result.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating Qibla direction", e)
      "{}"
    }
  }

  override fun getBulkPrayerTimes(
    latitude: Double,
    longitude: Double,
    startDateIso: String,
    endDateIso: String,
    method: String,
    madhab: String?,
    timezone: String?,
    adjustments: String?,
    customAngles: String?
  ): String {
    return try {
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val startDate = inputFormat.parse(startDateIso) ?: return "[]"
      val endDate = inputFormat.parse(endDateIso) ?: return "[]"
      
      val results = JSONArray()
      val calendar = Calendar.getInstance().apply { time = startDate }
      
      while (calendar.time <= endDate) {
        val dateIso = inputFormat.format(calendar.time)
        val prayerTimesJson = getPrayerTimes(latitude, longitude, dateIso, method, madhab, adjustments, customAngles)
        
        // Parse and add date field
        val prayerTimes = JSONObject(prayerTimesJson)
        prayerTimes.put("date", dateIso)
        results.put(prayerTimes)
        
        calendar.add(Calendar.DAY_OF_YEAR, 1)
      }
      
      results.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating bulk prayer times", e)
      "[]"
    }
  }

  override fun getAvailableMethods(): String {
    return try {
      val methods = JSONArray()
      
      val isna = JSONObject().apply {
        put("method", "ISNA")
        put("name", "Islamic Society of North America")
        put("description", "Used in North America")
        put("fajrAngle", 15)
        put("ishaAngle", 15)
        put("ishaInterval", false)
        put("regions", JSONArray(arrayOf("North America")))
      }
      methods.put(isna)
      
      val mwl = JSONObject().apply {
        put("method", "MWL")
        put("name", "Muslim World League")
        put("description", "Used globally")
        put("fajrAngle", 18)
        put("ishaAngle", 17)
        put("ishaInterval", false)
        put("regions", JSONArray(arrayOf("Global")))
      }
      methods.put(mwl)
      
      methods.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error getting available methods", e)
      "[]"
    }
  }

  override fun validateCoordinates(latitude: Double, longitude: Double): Boolean {
    return latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0
  }

  override fun getModuleInfo(): String {
    return try {
      val info = JSONObject().apply {
        put("version", "1.0.0")
        put("buildDate", "2025-01-01")
        put("nativeVersion", "1.0.0")
        put("supportsNewArchitecture", true)
      }
      info.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error getting module info", e)
      "{}"
    }
  }

  override fun getPerformanceMetrics(): String {
    return try {
      val metrics = JSONObject().apply {
        put("lastCalculationTime", 1)
        put("totalCalculations", 1)
        put("averageCalculationTime", 1)
        put("memoryUsage", 1024)
      }
      metrics.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error getting performance metrics", e)
      "{}"
    }
  }

  override fun clearCache() {
    // Implementation would clear any internal caches
  }

  override fun setDebugLogging(enabled: Boolean) {
    // Implementation would enable/disable debug logging
  }

  companion object {
    const val NAME = "Adhan"
    
    init {
      // Temporarily disable native library loading for testing
      Log.i(NAME, "Native library loading disabled for testing, using fallback calculations")
    }
  }
}
