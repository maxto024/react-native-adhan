import Foundation
import React

@objc(AdhanImpl)
public class AdhanImpl: NSObject {

  // MARK: - Asynchronous Bridged Methods (Public Wrappers)

  @objc(validateCoordinates:resolver:rejecter:)
  public func validateCoordinates(
    _ coordinates: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    resolver(validateCoordinatesSync(coordinates))
  }

  @objc(calculatePrayerTimes:dateComponents:calculationParameters:resolver:rejecter:)
  public func calculatePrayerTimes(
    _ coordinates: NSDictionary,
    dateComponents: NSDictionary,
    calculationParameters: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    if let result = calculatePrayerTimesSync(coordinates, dateComponents: dateComponents, calculationParameters: calculationParameters) {
      resolver(result)
    } else {
      rejecter("CALCULATION_ERROR", "Failed to calculate prayer times.", nil)
    }
  }

  @objc(calculateQibla:resolver:rejecter:)
  public func calculateQibla(
    _ coordinates: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    if let result = calculateQiblaSync(coordinates) {
      resolver(result)
    } else {
      rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
    }
  }

  @objc(calculateSunnahTimes:dateComponents:calculationParameters:resolver:rejecter:)
  public func calculateSunnahTimes(
    _ coordinates: NSDictionary,
    dateComponents: NSDictionary,
    calculationParameters: NSDictionary,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    if let result = calculateSunnahTimesSync(coordinates, dateComponents: dateComponents, calculationParameters: calculationParameters) {
      resolver(result)
    } else {
      rejecter("CALCULATION_ERROR", "Failed to calculate sunnah times.", nil)
    }
  }

  @objc(getCurrentPrayer:dateComponents:calculationParameters:currentTime:resolver:rejecter:)
  public func getCurrentPrayer(
    _ coordinates: NSDictionary,
    dateComponents: NSDictionary,
    calculationParameters: NSDictionary,
    currentTime: NSNumber,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    if let result = getCurrentPrayerSync(
      coordinates,
      dateComponents: dateComponents,
      calculationParameters: calculationParameters,
      currentTimeMs: currentTime.doubleValue
    ) {
      resolver(result)
    } else {
      rejecter("CALCULATION_ERROR", "Failed to calculate current prayer.", nil)
    }
  }

  @objc(getTimeForPrayer:dateComponents:calculationParameters:prayer:resolver:rejecter:)
  public func getTimeForPrayer(
    _ coordinates: NSDictionary,
    dateComponents: NSDictionary,
    calculationParameters: NSDictionary,
    prayer: NSString,
    resolver: @escaping RCTPromiseResolveBlock,
    rejecter: @escaping RCTPromiseRejectBlock
  ) {
    if let ts = getTimeForPrayerSync(
      coordinates,
      dateComponents: dateComponents,
      calculationParameters: calculationParameters,
      prayer: prayer as String
    ) {
      resolver(ts)
    } else {
      rejecter("INVALID_PRAYER", "Invalid prayer name or calculation failed.", nil)
    }
  }

  // MARK: - Synchronous Bridged Methods

  @objc(getCalculationMethods)
  public func getCalculationMethods() -> [[String: Any]] {
    return [
        ["name": "muslimWorldLeague", "displayName": "Muslim World League", "fajrAngle": 18.0, "ishaAngle": 17.0, "ishaInterval": 0, "description": "Muslim World League. Fajr: 18°, Isha: 17°"],
        ["name": "egyptian", "displayName": "Egyptian General Authority of Survey", "fajrAngle": 19.5, "ishaAngle": 17.5, "ishaInterval": 0, "description": "Egyptian General Authority of Survey. Fajr: 19.5°, Isha: 17.5°"],
        ["name": "karachi", "displayName": "University of Islamic Sciences, Karachi", "fajrAngle": 18.0, "ishaAngle": 18.0, "ishaInterval": 0, "description": "University of Islamic Sciences, Karachi. Fajr: 18°, Isha: 18°"],
        ["name": "other", "displayName": "Other", "fajrAngle": 0, "ishaAngle": 0, "ishaInterval": 0, "description": "Custom calculation method"]
    ]
  }

  @objc(getMethodParameters:)
  public func getMethodParameters(_ method: NSString) -> [String: Any]? {
    guard let calculationMethod = CalculationMethod.fromString(method as String) else { return nil }
    let params = CalculationParameters(method: calculationMethod)
    return ["method": method, "fajrAngle": params.fajrAngle, "ishaAngle": params.ishaAngle, "ishaInterval": params.ishaInterval, "madhab": params.madhab.rawValue, "highLatitudeRule": params.highLatitudeRule.rawValue, "rounding": params.rounding.rawValue, "shafaq": params.shafaq.rawValue]
  }

  @objc(getLibraryInfo)
  public func getLibraryInfo() -> [String: String] {
    return ["version": "0.1.0", "swiftLibraryVersion": "2.0.0", "platform": "iOS"]
  }

  // MARK: - Internal Synchronous Logic (Private)

  private func validateCoordinatesSync(_ coordinates: NSDictionary) -> Bool {
    guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double else { return false }
    return (-90...90).contains(lat) && (-180...180).contains(lon)
  }

  private func calculatePrayerTimesSync(_ coordinates: NSDictionary, dateComponents: NSDictionary, calculationParameters: NSDictionary) -> [String: Any]? {
      guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double,
            let year = dateComponents["year"] as? Int, let month = dateComponents["month"] as? Int, let day = dateComponents["day"] as? Int else { return nil }
      let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
      var adhanDateComponents = DateComponents()
      adhanDateComponents.year = year
      adhanDateComponents.month = month
      adhanDateComponents.day = day
      let adhanParams = getCalculationParameters(from: calculationParameters as! [String : Any])
      guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else { return nil }
      return ["fajr": prayerTimes.fajr.timeIntervalSince1970 * 1000, "sunrise": prayerTimes.sunrise.timeIntervalSince1970 * 1000, "dhuhr": prayerTimes.dhuhr.timeIntervalSince1970 * 1000, "asr": prayerTimes.asr.timeIntervalSince1970 * 1000, "maghrib": prayerTimes.maghrib.timeIntervalSince1970 * 1000, "isha": prayerTimes.isha.timeIntervalSince1970 * 1000]
  }

  private func calculateQiblaSync(_ coordinates: NSDictionary) -> [String: Any]? {
      guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double else { return nil }
      let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
      let qibla = Qibla(coordinates: adhanCoordinates)
      return ["direction": qibla.direction]
  }

  private func calculateSunnahTimesSync(_ coordinates: NSDictionary, dateComponents: NSDictionary, calculationParameters: NSDictionary) -> [String: Any]? {
      guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double,
            let year = dateComponents["year"] as? Int, let month = dateComponents["month"] as? Int, let day = dateComponents["day"] as? Int else { return nil }
      let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
      var adhanDateComponents = DateComponents()
      adhanDateComponents.year = year
      adhanDateComponents.month = month
      adhanDateComponents.day = day
      let adhanParams = getCalculationParameters(from: calculationParameters as! [String : Any])
      guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams),
            let sunnahTimes = SunnahTimes(from: prayerTimes) else { return nil }
      return ["middleOfTheNight": sunnahTimes.middleOfTheNight.timeIntervalSince1970 * 1000, "lastThirdOfTheNight": sunnahTimes.lastThirdOfTheNight.timeIntervalSince1970 * 1000]
  }

  private func getCurrentPrayerSync(_ coordinates: NSDictionary, dateComponents: NSDictionary, calculationParameters: NSDictionary, currentTimeMs: Double) -> [String: String]? {
      guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double,
            let year = dateComponents["year"] as? Int, let month = dateComponents["month"] as? Int, let day = dateComponents["day"] as? Int else { return nil }
      let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
      var adhanDateComponents = DateComponents()
      adhanDateComponents.year = year
      adhanDateComponents.month = month
      adhanDateComponents.day = day
      let adhanParams = getCalculationParameters(from: calculationParameters as! [String : Any])
      guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else { return nil }
      let currentDate = Date(timeIntervalSince1970: currentTimeMs / 1000)
      let currentPrayer = prayerTimes.currentPrayer(at: currentDate)
      let nextPrayer = prayerTimes.nextPrayer(at: currentDate)
      return ["current": currentPrayer?.rawValue ?? "none", "next": nextPrayer?.rawValue ?? "none"]
  }

  private func getTimeForPrayerSync(_ coordinates: NSDictionary, dateComponents: NSDictionary, calculationParameters: NSDictionary, prayer: String) -> NSNumber? {
      guard let lat = coordinates["latitude"] as? Double, let lon = coordinates["longitude"] as? Double,
            let year = dateComponents["year"] as? Int, let month = dateComponents["month"] as? Int, let day = dateComponents["day"] as? Int else { return nil }
      let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
      var adhanDateComponents = DateComponents()
      adhanDateComponents.year = year
      adhanDateComponents.month = month
      adhanDateComponents.day = day
      let adhanParams = getCalculationParameters(from: calculationParameters as! [String : Any])
      guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams),
            let prayerEnum = Prayer(rawValue: prayer) else { return nil }
      let time = prayerTimes.time(for: prayerEnum)
      return NSNumber(value: time.timeIntervalSince1970 * 1000)
  }
  
  private func getCalculationParameters(from params: [String: Any]) -> CalculationParameters {
      return CalculationParameters(method: .muslimWorldLeague)
  }
}

// MARK: - String to Enum Helpers

extension CalculationMethod {
    static func fromString(_ string: String) -> CalculationMethod? {
        switch string.lowercased() {
        case "muslimworldleague": return .muslimWorldLeague
        case "egyptian": return .egyptian
        case "karachi": return .karachi
        case "ummalqura": return .ummAlQura
        case "dubai": return .dubai
        case "moonsightingcommittee": return .moonsightingCommittee
        case "northamerica": return .northAmerica
        case "kuwait": return .kuwait
        case "qatar": return .qatar
        case "singapore": return .singapore
        case "tehran": return .tehran
        case "turkey": return .turkey
        default: return .other
        }
    }
}