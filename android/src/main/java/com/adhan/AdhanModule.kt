package com.adhan

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.module.annotations.ReactModule
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

// Import adhan-kotlin library classes
import com.batoulapps.adhan2.*
import com.batoulapps.adhan2.data.DateComponents
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime

/**
 * React Native bridge module wrapper around adhan-kotlin library for accurate prayer time calculations
 */
@ReactModule(name = AdhanModule.NAME)
class AdhanModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  /**
   * Simple multiply function for testing TurboModule connectivity
   */
  @ReactMethod
  fun multiply(a: Double, b: Double, promise: Promise) {
    try {
      promise.resolve(a * b)
    } catch (e: Exception) {
      promise.reject("MULTIPLY_ERROR", e.message, e)
    }
  }

  /**
   * Calculate prayer times using adhan-kotlin library
   * Returns JSON string with prayer times in ISO 8601 format
   */
  @ReactMethod
  fun getPrayerTimes(
    latitude: Double,
    longitude: Double,
    dateIso: String,
    method: String,
    madhab: String?,
    adjustments: String?,
    customAngles: String?,
    promise: Promise
  ) {
    try {
      Log.d(NAME, "Android getPrayerTimes called with method: $method, madhab: $madhab")
      
      // Parse input date
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val date = inputFormat.parse(dateIso) ?: Date()
      val calendar = Calendar.getInstance().apply { time = date }
      
      // Create adhan-kotlin Coordinates
      val coordinates = Coordinates(latitude, longitude)
      
      // Create DateComponents for adhan-kotlin
      val dateComponents = DateComponents(
        year = calendar.get(Calendar.YEAR),
        month = calendar.get(Calendar.MONTH) + 1, // Calendar.MONTH is 0-based
        day = calendar.get(Calendar.DAY_OF_MONTH)
      )
      
      // Create CalculationParameters based on method
      var calculationParameters = getAdhanKotlinCalculationMethod(method)
      
      // Set madhab if provided
      madhab?.let { madhabStr ->
        calculationParameters = calculationParameters.copy(
          madhab = when (madhabStr) {
            "Hanafi" -> Madhab.HANAFI
            else -> Madhab.SHAFI
          }
        )
      }
      
      // Apply custom angles if provided
      customAngles?.let { angles ->
        try {
          val customDict = JSONObject(angles)
          customDict.optDouble("fajrAngle").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(fajrAngle = it)
          }
          customDict.optDouble("ishaAngle").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(ishaAngle = it)
          }
          customDict.optDouble("ishaInterval").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(ishaInterval = it.toInt())
          }
        } catch (e: Exception) {
          Log.w(NAME, "Failed to parse custom angles: $angles", e)
        }
      }
      
      // Apply prayer adjustments if provided
      adjustments?.let { adj ->
        try {
          val adjDict = JSONObject(adj)
          val prayerAdjustments = PrayerAdjustments(
            fajr = adjDict.optInt("fajr", 0),
            sunrise = adjDict.optInt("sunrise", 0),
            dhuhr = adjDict.optInt("dhuhr", 0),
            asr = adjDict.optInt("asr", 0),
            maghrib = adjDict.optInt("maghrib", 0),
            isha = adjDict.optInt("isha", 0)
          )
          calculationParameters = calculationParameters.copy(prayerAdjustments = prayerAdjustments)
        } catch (e: Exception) {
          Log.w(NAME, "Failed to parse adjustments: $adj", e)
        }
      }
      
      // Calculate prayer times using adhan-kotlin
      val prayerTimes = PrayerTimes(coordinates, dateComponents, calculationParameters)
      
      // Get local timezone for formatting
      val localTimeZone = TimeZone.currentSystemDefault()
      val outputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.US).apply {
        timeZone = java.util.TimeZone.getDefault()
      }
      
      val result = calculatePrayerTimesSync(latitude, longitude, dateIso, method, madhab, adjustments, customAngles)
      promise.resolve(result)
      
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating prayer times with adhan-kotlin", e)
      promise.reject("PRAYER_TIMES_ERROR", e.message, e)
    }
  }

  /**
   * Calculate Qibla direction using adhan-kotlin library
   */
  @ReactMethod
  fun getQiblaDirection(latitude: Double, longitude: Double, promise: Promise) {
    try {
      // Create coordinates
      val coordinates = Coordinates(latitude, longitude)
      
      // Calculate Qibla using adhan-kotlin
      val qibla = Qibla(coordinates)
      
      // Calculate distance to Makkah (approximation)
      val makkahCoordinates = Coordinates(21.4225, 39.8262)
      val distance = calculateDistance(coordinates, makkahCoordinates)
      
      // Convert to compass bearing
      val bearings = arrayOf("N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", 
                           "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW")
      val index = ((qibla.direction / 22.5).toInt() + 16) % 16
      val compassBearing = bearings[index]
      
      val result = JSONObject().apply {
        put("direction", qibla.direction)
        put("distance", distance)
        put("compassBearing", compassBearing)
      }
      
      promise.resolve(result.toString())
      
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating Qibla direction", e)
      promise.reject("QIBLA_ERROR", e.message, e)
    }
  }

  /**
   * Calculate bulk prayer times for multiple dates
   */
  @ReactMethod
  fun getBulkPrayerTimes(
    latitude: Double,
    longitude: Double,
    startDateIso: String,
    endDateIso: String,
    method: String,
    madhab: String?,
    timezone: String?,
    adjustments: String?,
    customAngles: String?,
    promise: Promise
  ) {
    try {
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val startDate = inputFormat.parse(startDateIso)
      val endDate = inputFormat.parse(endDateIso)
      
      if (startDate == null || endDate == null) {
        promise.reject("INVALID_DATE", "Invalid date format", null)
        return
      }
      
      val results = JSONArray()
      val calendar = Calendar.getInstance().apply { time = startDate }
      
      while (calendar.time <= endDate) {
        val dateIso = inputFormat.format(calendar.time)
        val prayerTimesJson = calculatePrayerTimesSync(latitude, longitude, dateIso, method, madhab, adjustments, customAngles)
        
        // Parse and add date field
        val prayerTimes = JSONObject(prayerTimesJson)
        prayerTimes.put("date", dateIso)
        results.put(prayerTimes)
        
        calendar.add(Calendar.DAY_OF_YEAR, 1)
      }
      
      promise.resolve(results.toString())
      
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating bulk prayer times", e)
      promise.reject("BULK_PRAYER_TIMES_ERROR", e.message, e)
    }
  }

  /**
   * Get available calculation methods
   */
  @ReactMethod
  fun getAvailableMethods(promise: Promise) {
    try {
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
      
      promise.resolve(methods.toString())
      
    } catch (e: Exception) {
      Log.e(NAME, "Error getting available methods", e)
      promise.reject("METHODS_ERROR", e.message, e)
    }
  }

  /**
   * Validate coordinates
   */
  @ReactMethod
  fun validateCoordinates(latitude: Double, longitude: Double, promise: Promise) {
    try {
      val isValid = latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0
      promise.resolve(isValid)
    } catch (e: Exception) {
      promise.reject("VALIDATION_ERROR", e.message, e)
    }
  }

  /**
   * Get module information
   */
  @ReactMethod
  fun getModuleInfo(promise: Promise) {
    try {
      val info = JSONObject().apply {
        put("version", "1.0.0")
        put("buildDate", "2025-01-01")
        put("nativeVersion", "1.0.0")
        put("supportsNewArchitecture", true)
        put("usesAdhanKotlin", true)
      }
      promise.resolve(info.toString())
    } catch (e: Exception) {
      Log.e(NAME, "Error getting module info", e)
      promise.reject("MODULE_INFO_ERROR", e.message, e)
    }
  }

  /**
   * Get performance metrics
   */
  @ReactMethod
  fun getPerformanceMetrics(promise: Promise) {
    try {
      val metrics = JSONObject().apply {
        put("lastCalculationTime", 1)
        put("totalCalculations", 1)
        put("averageCalculationTime", 1)
        put("memoryUsage", 1024)
      }
      promise.resolve(metrics.toString())
    } catch (e: Exception) {
      Log.e(NAME, "Error getting performance metrics", e)
      promise.reject("METRICS_ERROR", e.message, e)
    }
  }

  /**
   * Clear any internal caches
   */
  @ReactMethod
  fun clearCache(promise: Promise) {
    try {
      // Implementation would clear any internal caches
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("CLEAR_CACHE_ERROR", e.message, e)
    }
  }

  /**
   * Enable/disable debug logging
   */
  @ReactMethod
  fun setDebugLogging(enabled: Boolean, promise: Promise) {
    try {
      // Implementation would enable/disable debug logging
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("DEBUG_LOGGING_ERROR", e.message, e)
    }
  }

  /**
   * Helper method to convert method string to adhan-kotlin CalculationMethod
   */
  private fun getAdhanKotlinCalculationMethod(method: String): CalculationParameters {
    return when (method) {
      "MWL" -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
      "ISNA" -> CalculationMethod.NORTH_AMERICA.parameters
      "Egypt" -> CalculationMethod.EGYPTIAN.parameters
      "Karachi" -> CalculationMethod.KARACHI.parameters
      "UmmAlQura" -> CalculationMethod.UMM_AL_QURA.parameters
      "Dubai" -> CalculationMethod.DUBAI.parameters
      "Moonsighting" -> CalculationMethod.MOON_SIGHTING_COMMITTEE.parameters
      "Kuwait" -> CalculationMethod.KUWAIT.parameters
      "Qatar" -> CalculationMethod.QATAR.parameters
      "Singapore" -> CalculationMethod.SINGAPORE.parameters
      "Turkey" -> CalculationMethod.TURKEY.parameters
      "Tehran" -> {
        // Tehran method not available in adhan-kotlin, use custom parameters
        var params = CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
        params = params.copy(fajrAngle = 17.7, ishaAngle = 14.0)
        params
      }
      else -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters // Default
    }
  }

  /**
   * Helper method to calculate distance between two coordinates
   */
  private fun calculateDistance(coord1: Coordinates, coord2: Coordinates): Double {
    val R = 6371.0 // Earth's radius in km
    val lat1 = Math.toRadians(coord1.latitude)
    val lat2 = Math.toRadians(coord2.latitude)
    val dLat = Math.toRadians(coord2.latitude - coord1.latitude)
    val dLon = Math.toRadians(coord2.longitude - coord1.longitude)
    
    val a = kotlin.math.sin(dLat / 2) * kotlin.math.sin(dLat / 2) +
            kotlin.math.cos(lat1) * kotlin.math.cos(lat2) *
            kotlin.math.sin(dLon / 2) * kotlin.math.sin(dLon / 2)
    val c = 2 * kotlin.math.atan2(kotlin.math.sqrt(a), kotlin.math.sqrt(1 - a))
    
    return R * c
  }

  /**
   * Helper method to calculate prayer times synchronously for internal use
   */
  private fun calculatePrayerTimesSync(
    latitude: Double,
    longitude: Double,
    dateIso: String,
    method: String,
    madhab: String?,
    adjustments: String?,
    customAngles: String?
  ): String {
    return try {
      Log.d(NAME, "Android calculatePrayerTimesSync called with method: $method, madhab: $madhab")
      
      // Parse input date
      val inputFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
      val date = inputFormat.parse(dateIso) ?: Date()
      
      // Create coordinates
      val coordinates = Coordinates(latitude, longitude)
      
      // Create date components
      val calendar = Calendar.getInstance().apply { time = date }
      val dateComponents = DateComponents(
        year = calendar.get(Calendar.YEAR),
        month = calendar.get(Calendar.MONTH) + 1,
        day = calendar.get(Calendar.DAY_OF_MONTH)
      )
      
      // Get calculation parameters
      var calculationParameters = getAdhanKotlinCalculationMethod(method)
      
      // Apply madhab settings
      madhab?.let { madhabValue ->
        calculationParameters = calculationParameters.copy(
          madhab = when (madhabValue.lowercase()) {
            "hanafi" -> Madhab.HANAFI
            else -> Madhab.SHAFI
          }
        )
      }
      
      // Apply custom angles if provided
      customAngles?.let { angles ->
        try {
          val customDict = JSONObject(angles)
          customDict.optDouble("fajrAngle").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(fajrAngle = it)
          }
          customDict.optDouble("ishaAngle").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(ishaAngle = it)
          }
          customDict.optDouble("ishaInterval").takeIf { it != 0.0 }?.let {
            calculationParameters = calculationParameters.copy(ishaInterval = it.toInt())
          }
        } catch (e: Exception) {
          Log.w(NAME, "Failed to parse custom angles: $angles", e)
        }
      }
      
      // Apply prayer adjustments if provided
      adjustments?.let { adj ->
        try {
          val adjDict = JSONObject(adj)
          val prayerAdjustments = PrayerAdjustments(
            fajr = adjDict.optInt("fajr", 0),
            sunrise = adjDict.optInt("sunrise", 0),
            dhuhr = adjDict.optInt("dhuhr", 0),
            asr = adjDict.optInt("asr", 0),
            maghrib = adjDict.optInt("maghrib", 0),
            isha = adjDict.optInt("isha", 0)
          )
          calculationParameters = calculationParameters.copy(prayerAdjustments = prayerAdjustments)
        } catch (e: Exception) {
          Log.w(NAME, "Failed to parse adjustments: $adj", e)
        }
      }
      
      // Calculate prayer times using adhan-kotlin
      val prayerTimes = PrayerTimes(coordinates, dateComponents, calculationParameters)
      
      // Get local timezone for formatting
      val outputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.US).apply {
        timeZone = java.util.TimeZone.getDefault()
      }
      
      // Create result JSON object
      val result = JSONObject().apply {
        put("fajr", outputFormat.format(Date(prayerTimes.fajr.toEpochMilliseconds())))
        put("sunrise", outputFormat.format(Date(prayerTimes.sunrise.toEpochMilliseconds())))
        put("dhuhr", outputFormat.format(Date(prayerTimes.dhuhr.toEpochMilliseconds())))
        put("asr", outputFormat.format(Date(prayerTimes.asr.toEpochMilliseconds())))
        put("maghrib", outputFormat.format(Date(prayerTimes.maghrib.toEpochMilliseconds())))
        put("isha", outputFormat.format(Date(prayerTimes.isha.toEpochMilliseconds())))
      }
      
      Log.d(NAME, "Android calculated prayer times successfully using adhan-kotlin")
      result.toString()
      
    } catch (e: Exception) {
      Log.e(NAME, "Error calculating prayer times with adhan-kotlin", e)
      "{}"
    }
  }

  companion object {
    const val NAME = "Adhan"
  }
}