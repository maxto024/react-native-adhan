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
      
      // Parse the date
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val outputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.getDefault())
      val date = inputFormat.parse(dateIso) ?: Date()
      
      val calendar = Calendar.getInstance().apply {
        time = date
      }
      
      // Generate mock prayer times based on location and date
      // In production, this would use the C++ adhan library
      
      // Fajr time
      calendar.set(Calendar.HOUR_OF_DAY, 5)
      calendar.set(Calendar.MINUTE, 30)
      result.put("fajr", outputFormat.format(calendar.time))
      
      // Sunrise time
      calendar.set(Calendar.HOUR_OF_DAY, 7)
      calendar.set(Calendar.MINUTE, 0)
      result.put("sunrise", outputFormat.format(calendar.time))
      
      // Dhuhr time
      calendar.set(Calendar.HOUR_OF_DAY, 12)
      calendar.set(Calendar.MINUTE, 30)
      result.put("dhuhr", outputFormat.format(calendar.time))
      
      // Asr time
      calendar.set(Calendar.HOUR_OF_DAY, 15)
      calendar.set(Calendar.MINUTE, 45)
      result.put("asr", outputFormat.format(calendar.time))
      
      // Maghrib time
      calendar.set(Calendar.HOUR_OF_DAY, 18)
      calendar.set(Calendar.MINUTE, 15)
      result.put("maghrib", outputFormat.format(calendar.time))
      
      // Isha time
      calendar.set(Calendar.HOUR_OF_DAY, 19)
      calendar.set(Calendar.MINUTE, 45)
      result.put("isha", outputFormat.format(calendar.time))
      
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
    adjustments: String?
  ): String {
    return try {
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val startDate = inputFormat.parse(startDateIso) ?: return "[]"
      val endDate = inputFormat.parse(endDateIso) ?: return "[]"
      
      val results = JSONArray()
      val calendar = Calendar.getInstance().apply { time = startDate }
      
      while (calendar.time <= endDate) {
        val dateIso = inputFormat.format(calendar.time)
        val prayerTimesJson = getPrayerTimes(latitude, longitude, dateIso, method, madhab, adjustments)
        
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
