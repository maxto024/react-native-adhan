package com.adhan

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.bridge.WritableArray
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.Promise
import com.facebook.react.module.annotations.ReactModule
import com.batoulapps.adhan2.Coordinates
import com.batoulapps.adhan2.PrayerTimes
import com.batoulapps.adhan2.Qibla
import com.batoulapps.adhan2.SunnahTimes
import com.batoulapps.adhan2.CalculationMethod
import com.batoulapps.adhan2.CalculationParameters
import com.batoulapps.adhan2.PrayerAdjustments
import com.batoulapps.adhan2.Prayer
import com.batoulapps.adhan2.Madhab
import com.batoulapps.adhan2.HighLatitudeRule
import com.batoulapps.adhan2.data.DateComponents
import com.batoulapps.adhan2.model.Rounding
import com.batoulapps.adhan2.model.Shafaq
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime
import kotlinx.datetime.DateTimeUnit
import kotlinx.datetime.plus

@ReactModule(name = AdhanModule.NAME)
class AdhanModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  // Helper methods
  private fun coordinatesFromMap(map: ReadableMap): Coordinates? {
    return try {
      val latitude = map.getDouble("latitude")
      val longitude = map.getDouble("longitude")
      Coordinates(latitude, longitude)
    } catch (e: Exception) {
      null
    }
  }

  private fun dateComponentsFromMap(map: ReadableMap): DateComponents? {
    return try {
      val year = map.getInt("year")
      val month = map.getInt("month")
      val day = map.getInt("day")
      DateComponents(year, month, day)
    } catch (e: Exception) {
      null
    }
  }

  private fun calculationParametersFromMap(map: ReadableMap): CalculationParameters {
    var params = CalculationMethod.OTHER.parameters

    // Get base method parameters
    if (map.hasKey("method")) {
      val method = map.getString("method")
      params = when (method) {
        "muslimWorldLeague" -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
        "egyptian" -> CalculationMethod.EGYPTIAN.parameters
        "karachi" -> CalculationMethod.KARACHI.parameters
        "ummAlQura" -> CalculationMethod.UMM_AL_QURA.parameters
        "dubai" -> CalculationMethod.DUBAI.parameters
        "moonsightingCommittee" -> CalculationMethod.MOON_SIGHTING_COMMITTEE.parameters
        "northAmerica" -> CalculationMethod.NORTH_AMERICA.parameters
        "kuwait" -> CalculationMethod.KUWAIT.parameters
        "qatar" -> CalculationMethod.QATAR.parameters
        "singapore" -> CalculationMethod.SINGAPORE.parameters
        "turkey" -> CalculationMethod.TURKEY.parameters
        else -> CalculationMethod.OTHER.parameters
      }
    }

    // Apply custom parameters if provided
    var customParams = params.copy()

    if (map.hasKey("fajrAngle")) {
      customParams = customParams.copy(fajrAngle = map.getDouble("fajrAngle"))
    }

    if (map.hasKey("ishaAngle")) {
      customParams = customParams.copy(ishaAngle = map.getDouble("ishaAngle"))
    }

    if (map.hasKey("ishaInterval")) {
      customParams = customParams.copy(ishaInterval = map.getInt("ishaInterval"))
    }

    if (map.hasKey("madhab")) {
      val madhab = map.getString("madhab")
      customParams = customParams.copy(madhab = if (madhab == "hanafi") Madhab.HANAFI else Madhab.SHAFI)
    }

    if (map.hasKey("rounding")) {
      val rounding = map.getString("rounding")
      val roundingEnum = when (rounding) {
        "up" -> Rounding.UP
        else -> Rounding.NEAREST
      }
      customParams = customParams.copy(rounding = roundingEnum)
    }

    if (map.hasKey("shafaq")) {
      val shafaq = map.getString("shafaq")
      val shafaqEnum = when (shafaq) {
        "ahmer" -> Shafaq.AHMER
        "abyad" -> Shafaq.ABYAD
        else -> Shafaq.GENERAL
      }
      customParams = customParams.copy(shafaq = shafaqEnum)
    }

    if (map.hasKey("highLatitudeRule")) {
      val rule = map.getString("highLatitudeRule")
      val ruleEnum = when (rule) {
        "middleOfTheNight" -> HighLatitudeRule.MIDDLE_OF_THE_NIGHT
        "seventhOfTheNight" -> HighLatitudeRule.SEVENTH_OF_THE_NIGHT
        "twilightAngle" -> HighLatitudeRule.TWILIGHT_ANGLE
        else -> HighLatitudeRule.MIDDLE_OF_THE_NIGHT
      }
      customParams = customParams.copy(highLatitudeRule = ruleEnum)
    }

    // Apply prayer adjustments
    if (map.hasKey("prayerAdjustments")) {
      val adjustments = map.getMap("prayerAdjustments")
      adjustments?.let { adj ->
        val prayerAdj = PrayerAdjustments(
          fajr = if (adj.hasKey("fajr")) adj.getInt("fajr") else 0,
          sunrise = if (adj.hasKey("sunrise")) adj.getInt("sunrise") else 0,
          dhuhr = if (adj.hasKey("dhuhr")) adj.getInt("dhuhr") else 0,
          asr = if (adj.hasKey("asr")) adj.getInt("asr") else 0,
          maghrib = if (adj.hasKey("maghrib")) adj.getInt("maghrib") else 0,
          isha = if (adj.hasKey("isha")) adj.getInt("isha") else 0
        )
        customParams = customParams.copy(prayerAdjustments = prayerAdj)
      }
    }

    if (map.hasKey("methodAdjustments")) {
      val adjustments = map.getMap("methodAdjustments")
      adjustments?.let { adj ->
        val methodAdj = PrayerAdjustments(
          fajr = if (adj.hasKey("fajr")) adj.getInt("fajr") else 0,
          sunrise = if (adj.hasKey("sunrise")) adj.getInt("sunrise") else 0,
          dhuhr = if (adj.hasKey("dhuhr")) adj.getInt("dhuhr") else 0,
          asr = if (adj.hasKey("asr")) adj.getInt("asr") else 0,
          maghrib = if (adj.hasKey("maghrib")) adj.getInt("maghrib") else 0,
          isha = if (adj.hasKey("isha")) adj.getInt("isha") else 0
        )
        customParams = customParams.copy(methodAdjustments = methodAdj)
      }
    }

    return customParams
  }

  private fun timestampFromInstant(instant: Instant): Double {
    return instant.toEpochMilliseconds().toDouble()
  }

  private fun instantFromTimestamp(timestamp: Double): Instant {
    return Instant.fromEpochMilliseconds(timestamp.toLong())
  }

  private fun prayerToString(prayer: Prayer): String {
    return when (prayer) {
      Prayer.FAJR -> "fajr"
      Prayer.SUNRISE -> "sunrise"
      Prayer.DHUHR -> "dhuhr"
      Prayer.ASR -> "asr"
      Prayer.MAGHRIB -> "maghrib"
      Prayer.ISHA -> "isha"
      Prayer.NONE -> "none"
    }
  }

  private fun stringToPrayer(prayer: String): Prayer {
    return when (prayer) {
      "fajr" -> Prayer.FAJR
      "sunrise" -> Prayer.SUNRISE
      "dhuhr" -> Prayer.DHUHR
      "asr" -> Prayer.ASR
      "maghrib" -> Prayer.MAGHRIB
      "isha" -> Prayer.ISHA
      else -> Prayer.NONE
    }
  }

  // TurboModule implementations
  override fun calculatePrayerTimes(
    coordinates: ReadableMap,
    dateComponents: ReadableMap,
    calculationParameters: ReadableMap,
    promise: Promise
  ) {
    try {
      val coord = coordinatesFromMap(coordinates)
      val dateComp = dateComponentsFromMap(dateComponents)
      val calcParams = calculationParametersFromMap(calculationParameters)

      if (coord == null || dateComp == null) {
        promise.reject("INVALID_PARAMS", "Invalid parameters provided")
        return
      }

      val prayerTimes = PrayerTimes(coord, dateComp, calcParams)

      val result = WritableNativeMap().apply {
        putDouble("fajr", timestampFromInstant(prayerTimes.fajr))
        putDouble("sunrise", timestampFromInstant(prayerTimes.sunrise))
        putDouble("dhuhr", timestampFromInstant(prayerTimes.dhuhr))
        putDouble("asr", timestampFromInstant(prayerTimes.asr))
        putDouble("maghrib", timestampFromInstant(prayerTimes.maghrib))
        putDouble("isha", timestampFromInstant(prayerTimes.isha))
      }

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }

  override fun calculateQibla(coordinates: ReadableMap, promise: Promise) {
    try {
      val coord = coordinatesFromMap(coordinates)

      if (coord == null) {
        promise.reject("INVALID_PARAMS", "Invalid coordinates provided")
        return
      }

      val qibla = Qibla(coord)

      val result = WritableNativeMap().apply {
        putDouble("direction", qibla.direction)
      }

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }

  override fun calculateSunnahTimes(
    coordinates: ReadableMap,
    dateComponents: ReadableMap,
    calculationParameters: ReadableMap,
    promise: Promise
  ) {
    try {
      val coord = coordinatesFromMap(coordinates)
      val dateComp = dateComponentsFromMap(dateComponents)
      val calcParams = calculationParametersFromMap(calculationParameters)

      if (coord == null || dateComp == null) {
        promise.reject("INVALID_PARAMS", "Invalid parameters provided")
        return
      }

      val prayerTimes = PrayerTimes(coord, dateComp, calcParams)
      val sunnahTimes = SunnahTimes(prayerTimes)

      val result = WritableNativeMap().apply {
        putDouble("middleOfTheNight", timestampFromInstant(sunnahTimes.middleOfTheNight))
        putDouble("lastThirdOfTheNight", timestampFromInstant(sunnahTimes.lastThirdOfTheNight))
      }

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }

  override fun getCurrentPrayer(
    coordinates: ReadableMap,
    dateComponents: ReadableMap,
    calculationParameters: ReadableMap,
    currentTime: Double,
    promise: Promise
  ) {
    try {
      val coord = coordinatesFromMap(coordinates)
      val dateComp = dateComponentsFromMap(dateComponents)
      val calcParams = calculationParametersFromMap(calculationParameters)

      if (coord == null || dateComp == null) {
        promise.reject("INVALID_PARAMS", "Invalid parameters provided")
        return
      }

      val prayerTimes = PrayerTimes(coord, dateComp, calcParams)
      val time = instantFromTimestamp(currentTime)

      // Manual implementation matching iOS logic exactly
      val currentPrayer = when {
        time >= prayerTimes.isha -> Prayer.ISHA
        time >= prayerTimes.maghrib -> Prayer.MAGHRIB  
        time >= prayerTimes.asr -> Prayer.ASR
        time >= prayerTimes.dhuhr -> Prayer.DHUHR
        time >= prayerTimes.sunrise -> Prayer.SUNRISE
        time >= prayerTimes.fajr -> Prayer.FAJR
        else -> Prayer.NONE
      }
      
      val nextPrayer = when {
        time < prayerTimes.fajr -> Prayer.FAJR
        time < prayerTimes.sunrise -> Prayer.SUNRISE
        time < prayerTimes.dhuhr -> Prayer.DHUHR
        time < prayerTimes.asr -> Prayer.ASR
        time < prayerTimes.maghrib -> Prayer.MAGHRIB
        time < prayerTimes.isha -> Prayer.ISHA
        else -> Prayer.NONE // After Isha, next is Fajr of next day
      }

      val result = WritableNativeMap().apply {
        putString("current", prayerToString(currentPrayer))
        putString("next", prayerToString(nextPrayer))
      }

      promise.resolve(result)
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }

  override fun getTimeForPrayer(
    coordinates: ReadableMap,
    dateComponents: ReadableMap,
    calculationParameters: ReadableMap,
    prayer: String,
    promise: Promise
  ) {
    try {
      val coord = coordinatesFromMap(coordinates)
      val dateComp = dateComponentsFromMap(dateComponents)
      val calcParams = calculationParametersFromMap(calculationParameters)

      if (coord == null || dateComp == null) {
        promise.reject("INVALID_PARAMS", "Invalid parameters provided")
        return
      }

      val prayerTimes = PrayerTimes(coord, dateComp, calcParams)
      val prayerEnum = stringToPrayer(prayer)

      val prayerTime = prayerTimes.timeForPrayer(prayerEnum)

      if (prayerTime != null) {
        promise.resolve(timestampFromInstant(prayerTime))
      } else {
        promise.resolve(null)
      }
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }


  override fun getCalculationMethods(): WritableArray {
    val methods = WritableNativeArray()

    val methodsData = listOf(
      mapOf(
        "name" to "muslimWorldLeague",
        "displayName" to "Muslim World League",
        "fajrAngle" to 18.0,
        "ishaAngle" to 17.0,
        "ishaInterval" to 0,
        "description" to "Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°."
      ),
      mapOf(
        "name" to "egyptian",
        "displayName" to "Egyptian General Authority of Survey",
        "fajrAngle" to 19.5,
        "ishaAngle" to 17.5,
        "ishaInterval" to 0,
        "description" to "Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°."
      ),
      mapOf(
        "name" to "karachi",
        "displayName" to "University of Islamic Sciences, Karachi",
        "fajrAngle" to 18.0,
        "ishaAngle" to 18.0,
        "ishaInterval" to 0,
        "description" to "A generally applicable method that uses standard Fajr and Isha angles of 18°."
      ),
      mapOf(
        "name" to "ummAlQura",
        "displayName" to "Umm al-Qura University, Makkah",
        "fajrAngle" to 18.5,
        "ishaAngle" to 0.0,
        "ishaInterval" to 90,
        "description" to "Uses a fixed interval of 90 minutes from maghrib to calculate Isha. Note: you should add a +30 minute custom adjustment for Isha during Ramadan."
      ),
      mapOf(
        "name" to "dubai",
        "displayName" to "UAE",
        "fajrAngle" to 18.2,
        "ishaAngle" to 18.2,
        "ishaInterval" to 0,
        "description" to "Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2°."
      ),
      mapOf(
        "name" to "moonsightingCommittee",
        "displayName" to "Moonsighting Committee",
        "fajrAngle" to 18.0,
        "ishaAngle" to 18.0,
        "ishaInterval" to 0,
        "description" to "Method developed by Khalid Shaukat. Uses standard 18° angles for Fajr and Isha in addition to seasonal adjustment values."
      ),
      mapOf(
        "name" to "northAmerica",
        "displayName" to "ISNA",
        "fajrAngle" to 15.0,
        "ishaAngle" to 15.0,
        "ishaInterval" to 0,
        "description" to "Also known as the ISNA method. Gives later Fajr times and early Isha times with angles of 15°."
      ),
      mapOf(
        "name" to "kuwait",
        "displayName" to "Kuwait",
        "fajrAngle" to 18.0,
        "ishaAngle" to 17.5,
        "ishaInterval" to 0,
        "description" to "Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°."
      ),
      mapOf(
        "name" to "qatar",
        "displayName" to "Qatar",
        "fajrAngle" to 18.0,
        "ishaAngle" to 0.0,
        "ishaInterval" to 90,
        "description" to "Same Isha interval as Umm al-Qura but with the standard Fajr time using an angle of 18°."
      ),
      mapOf(
        "name" to "singapore",
        "displayName" to "Singapore",
        "fajrAngle" to 20.0,
        "ishaAngle" to 18.0,
        "ishaInterval" to 0,
        "description" to "Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°."
      ),
      mapOf(
        "name" to "turkey",
        "displayName" to "Diyanet İşleri Başkanlığı, Turkey",
        "fajrAngle" to 18.0,
        "ishaAngle" to 17.0,
        "ishaInterval" to 0,
        "description" to "An approximation of the Diyanet method used in Turkey."
      )
    )

    methodsData.forEach { methodData ->
      val method = WritableNativeMap().apply {
        putString("name", methodData["name"] as String)
        putString("displayName", methodData["displayName"] as String)
        putDouble("fajrAngle", methodData["fajrAngle"] as Double)
        putDouble("ishaAngle", methodData["ishaAngle"] as Double)
        putInt("ishaInterval", methodData["ishaInterval"] as Int)
        putString("description", methodData["description"] as String)
      }
      methods.pushMap(method)
    }

    return methods
  }

  override fun getMethodParameters(method: String, promise: Promise) {
    val params = when (method) {
      "muslimWorldLeague" -> CalculationMethod.MUSLIM_WORLD_LEAGUE.parameters
      "egyptian" -> CalculationMethod.EGYPTIAN.parameters
      "karachi" -> CalculationMethod.KARACHI.parameters
      "ummAlQura" -> CalculationMethod.UMM_AL_QURA.parameters
      "dubai" -> CalculationMethod.DUBAI.parameters
      "moonsightingCommittee" -> CalculationMethod.MOON_SIGHTING_COMMITTEE.parameters
      "northAmerica" -> CalculationMethod.NORTH_AMERICA.parameters
      "kuwait" -> CalculationMethod.KUWAIT.parameters
      "qatar" -> CalculationMethod.QATAR.parameters
      "singapore" -> CalculationMethod.SINGAPORE.parameters
      "turkey" -> CalculationMethod.TURKEY.parameters
      else -> CalculationMethod.OTHER.parameters
    }

    val result = WritableNativeMap().apply {
      putString("method", method)
      putDouble("fajrAngle", params.fajrAngle)
      putDouble("ishaAngle", params.ishaAngle)
      putInt("ishaInterval", params.ishaInterval)
      putString("madhab", if (params.madhab == Madhab.HANAFI) "hanafi" else "shafi")
      putString("rounding", when (params.rounding) {
        Rounding.UP -> "up"
        else -> "nearest"
      })
      putString("shafaq", when (params.shafaq) {
        Shafaq.AHMER -> "ahmer"
        Shafaq.ABYAD -> "abyad"
        else -> "general"
      })
    }
    promise.resolve(result)
  }

  override fun calculatePrayerTimesRange(
    coordinates: ReadableMap,
    startDate: ReadableMap,
    endDate: ReadableMap,
    calculationParameters: ReadableMap,
    promise: Promise
  ) {
    try {
      val coord = coordinatesFromMap(coordinates)
      val startComp = dateComponentsFromMap(startDate)
      val endComp = dateComponentsFromMap(endDate)
      val calcParams = calculationParametersFromMap(calculationParameters)

      if (coord == null || startComp == null || endComp == null) {
        promise.reject("INVALID_PARAMS", "Invalid parameters provided")
        return
      }

      val results = WritableNativeArray()

      // Create date range
      var currentDate = startComp
      val endDateTime = endComp?.let { LocalDateTime(it.year, it.month, it.day, 0, 0) }

      while (true) {
        val currentDateTime = currentDate?.let { LocalDateTime(it.year, it.month, it.day, 0, 0) }
        
        if (currentDateTime == null || (endDateTime != null && currentDateTime > endDateTime)) break

        try {
          val prayerTimes = PrayerTimes(coord, currentDate!!, calcParams)

          val prayerTimesMap = WritableNativeMap().apply {
            putDouble("fajr", timestampFromInstant(prayerTimes.fajr))
            putDouble("sunrise", timestampFromInstant(prayerTimes.sunrise))
            putDouble("dhuhr", timestampFromInstant(prayerTimes.dhuhr))
            putDouble("asr", timestampFromInstant(prayerTimes.asr))
            putDouble("maghrib", timestampFromInstant(prayerTimes.maghrib))
            putDouble("isha", timestampFromInstant(prayerTimes.isha))
          }

          val dateMap = WritableNativeMap().apply {
            putInt("year", currentDate.year)
            putInt("month", currentDate.month)
            putInt("day", currentDate.day)
          }

          val resultItem = WritableNativeMap().apply {
            putMap("date", dateMap)
            putMap("prayerTimes", prayerTimesMap)
          }

          results.pushMap(resultItem)
        } catch (e: Exception) {
          // Skip invalid dates but continue processing
        }

        // Move to next day
        val nextDay = currentDateTime?.toInstant(TimeZone.UTC)
          ?.plus(1, DateTimeUnit.DAY, TimeZone.UTC)
          ?.toLocalDateTime(TimeZone.UTC)
        
        currentDate = nextDay?.let { DateComponents(it.year, it.monthNumber, it.dayOfMonth) }
      }

      promise.resolve(results)
    } catch (e: Exception) {
      promise.reject("CALCULATION_ERROR", e.message ?: "Unknown error")
    }
  }

  override fun getLibraryInfo(): WritableMap {
    return WritableNativeMap().apply {
      putString("version", "1.0.0")
      putString("kotlinLibraryVersion", "2.0.0")
      putString("platform", "Android")
    }
  }

  companion object {
    const val NAME = "Adhan"
  }
}
