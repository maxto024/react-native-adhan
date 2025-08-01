package com.adhan

import com.facebook.react.bridge.*
import com.facebook.react.module.annotations.ReactModule
import org.json.JSONObject

@ReactModule(name = AdhanModule.NAME)
class AdhanModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Load the native C++ library
  companion object {
    const val NAME = "Adhan"
    
    init {
      try {
        System.loadLibrary("adhan")
      } catch (e: Exception) {
        // Handle library loading error
      }
    }
  }

  // Native method declarations
  private external fun nativeGetPrayerTimes(
    latitude: Double,
    longitude: Double,
    year: Int,
    month: Int,
    day: Int,
    method: String,
    madhab: String?
  ): String

  @ReactMethod
  fun getPrayerTimes(input: ReadableMap, promise: Promise) {
    try {
      val latitude = input.getDouble("latitude")
      val longitude = input.getDouble("longitude")
      val dateMap = input.getMap("date")!!
      val year = dateMap.getInt("year")
      val month = dateMap.getInt("month")
      val day = dateMap.getInt("day")
      val method = input.getString("method") ?: "MuslimWorldLeague"
      val madhab = if (input.hasKey("madhab")) input.getString("madhab") else null
      
      val resultJson = nativeGetPrayerTimes(latitude, longitude, year, month, day, method, madhab)
      val result = JSONObject(resultJson)
      
      val writableMap = WritableNativeMap()
      writableMap.putString("fajr", result.getString("fajr"))
      writableMap.putString("sunrise", result.getString("sunrise"))
      writableMap.putString("dhuhr", result.getString("dhuhr"))
      writableMap.putString("asr", result.getString("asr"))
      writableMap.putString("maghrib", result.getString("maghrib"))
      writableMap.putString("isha", result.getString("isha"))
      
      promise.resolve(writableMap)
    } catch (e: Exception) {
      promise.reject("ERROR", e.message, e)
    }
  }

}
