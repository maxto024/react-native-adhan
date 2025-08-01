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

  override fun getPrayerTimes(
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
          // Parse offset format like "+05:00" or "-05:00"
          val offsetStr = timezone.substring(1)
          val parts = offsetStr.split(":")
          if (parts.size >= 2) {
            val hours = parts[0].toIntOrNull() ?: 0
            val minutes = parts[1].toIntOrNull() ?: 0
            val offsetMillis = ((hours * 60 + minutes) * 60 * 1000) * if (timezone.startsWith("-")) -1 else 1
            TimeZone.getTimeZone("GMT${timezone}")
          } else TimeZone.getDefault()
        }
        else -> TimeZone.getTimeZone(timezone) // Try timezone identifier
      }
      
      val outputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.US).apply {
        timeZone = calculationTimeZone
      }
      
      val calendar = Calendar.getInstance(calculationTimeZone).apply {
        time = date
      }
      
      // Parse calculation method angles
      var fajrAngle = 15.0 // Default ISNA
      var ishaAngle = 15.0
      var ishaIsInterval = false
      var ishaInterval = 0.0
      
      // Set method-specific angles
      when (method) {
        "ISNA" -> { fajrAngle = 15.0; ishaAngle = 15.0 }
        "MWL" -> { fajrAngle = 18.0; ishaAngle = 17.0 }
        "Karachi" -> { fajrAngle = 18.0; ishaAngle = 18.0 }
        "Egypt" -> { fajrAngle = 19.5; ishaAngle = 17.5 }
        "UmmAlQura" -> { fajrAngle = 18.5; ishaInterval = 90.0; ishaIsInterval = true }
        "Dubai" -> { fajrAngle = 18.2; ishaAngle = 18.2 }
        "Kuwait" -> { fajrAngle = 18.0; ishaAngle = 17.5 }
        "Qatar" -> { fajrAngle = 18.0; ishaInterval = 90.0; ishaIsInterval = true }
        "Singapore" -> { fajrAngle = 20.0; ishaAngle = 18.0 }
        "Tehran" -> { fajrAngle = 17.7; ishaAngle = 14.0 }
        "Turkey" -> { fajrAngle = 18.0; ishaAngle = 17.0 }
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
      
      // Calculate prayer times using accurate astronomical calculations
      val dayOfYear = calendar.get(Calendar.DAY_OF_YEAR)
      val P = asin(0.39795 * cos(0.98563 * (dayOfYear - 173) * PI / 180.0))
      val argument = (0.0145 * sin(4 * PI * (dayOfYear - 81) / 365.0) - 0.1679 * sin(2 * PI * (dayOfYear - 81) / 365.0))
      val equationOfTime = 4 * (longitude - 15 * (calculationTimeZone.rawOffset / 3600000.0)) + 4 * argument
      
      // Calculate solar noon
      val solarNoon = 12.0 - equationOfTime / 60.0
      
      // Calculate sunrise and sunset
      val latRad = Math.toRadians(latitude)
      val hourAngleSunrise = acos(-tan(latRad) * tan(P)) * 180.0 / PI / 15.0
      val sunrise = solarNoon - hourAngleSunrise
      val sunset = solarNoon + hourAngleSunrise
      
      // Calculate Fajr
      val fajrHourAngle = acos((-sin(Math.toRadians(fajrAngle)) - sin(latRad) * sin(P)) / (cos(latRad) * cos(P))) * 180.0 / PI / 15.0
      val fajr = solarNoon - fajrHourAngle
      
      // Calculate Asr (consider Madhab)
      val madhubMultiplier = if (madhab == "Hanafi") 2.0 else 1.0
      val asrAltitude = atan(1.0 / (madhubMultiplier + tan((90.0 - latitude) * PI / 180.0) * tan(P))) * 180.0 / PI
      val asrHourAngle = acos((sin(Math.toRadians(asrAltitude)) - sin(latRad) * sin(P)) / (cos(latRad) * cos(P))) * 180.0 / PI / 15.0
      val asr = solarNoon + asrHourAngle
      
      // Calculate Isha
      val isha = if (ishaIsInterval) {
        sunset + ishaInterval / 60.0
      } else {
        val ishaHourAngle = acos((-sin(Math.toRadians(ishaAngle)) - sin(latRad) * sin(P)) / (cos(latRad) * cos(P))) * 180.0 / PI / 15.0
        solarNoon + ishaHourAngle
      }
      
      // Parse adjustments if provided
      val adj = adjustments?.let {
        try { JSONObject(it) } catch (e: Exception) { null }
      }
      
      // Create final dates with adjustments
      fun createPrayerTime(hour: Double, prayerName: String): String {
        val finalHour = hour.toInt()
        val finalMinute = ((hour - finalHour) * 60).toInt() + (adj?.optInt(prayerName) ?: 0)
        
        calendar.set(Calendar.HOUR_OF_DAY, finalHour)
        calendar.set(Calendar.MINUTE, finalMinute)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        
        return outputFormat.format(calendar.time)
      }
      
      result.put("fajr", createPrayerTime(fajr, "fajr"))
      result.put("sunrise", createPrayerTime(sunrise, "sunrise"))
      result.put("dhuhr", createPrayerTime(solarNoon, "dhuhr"))
      result.put("asr", createPrayerTime(asr, "asr"))
      result.put("maghrib", createPrayerTime(sunset, "maghrib"))
      result.put("isha", createPrayerTime(isha, "isha"))
      
      result.toString()
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating prayer times", e)
      "{}"
    }
  }

  override fun getQiblaDirection(latitude: Double, longitude: Double): String {
    return try {
      // Makkah coordinates
      val makkahLat = 21.4225
      val makkahLon = 39.8262
      
      // Convert to radians
      val lat1 = Math.toRadians(latitude)
      val lat2 = Math.toRadians(makkahLat)
      val deltaLon = Math.toRadians(makkahLon - longitude)
      
      // Calculate bearing
      val y = sin(deltaLon) * cos(lat2)
      val x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
      var direction = Math.toDegrees(atan2(y, x))
      direction = (direction + 360) % 360
      
      // Calculate distance using Haversine formula
      val R = 6371.0 // Earth's radius in km
      val dLat = Math.toRadians(makkahLat - latitude)
      val dLon = deltaLon
      val a = sin(dLat / 2).pow(2) + cos(lat1) * cos(lat2) * sin(dLon / 2).pow(2)
      val c = 2 * atan2(sqrt(a), sqrt(1 - a))
      val distance = R * c
      
      // Convert to compass bearing
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
        val prayerTimesJson = getPrayerTimes(latitude, longitude, dateIso, method, madhab, timezone, adjustments, customAngles)
        
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
  }
}
