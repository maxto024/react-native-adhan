import Foundation
import React

@objc(AdhanImpl)
public class AdhanImpl: NSObject {
    
    @objc public func calculatePrayerTimes(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any]
    ) -> [String: Any]? {
        
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            return nil
        }
        
        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            return nil
        }
        
        do {
            let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
            let adhanParams = getCalculationParameters(from: calculationParameters)
            
            var adhanDateComponents = DateComponents()
            adhanDateComponents.year = year
            adhanDateComponents.month = month
            adhanDateComponents.day = day
            
            guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
                return nil
            }
            
            return [
                "fajr": prayerTimes.fajr.timeIntervalSince1970 * 1000,
                "sunrise": prayerTimes.sunrise.timeIntervalSince1970 * 1000,
                "dhuhr": prayerTimes.dhuhr.timeIntervalSince1970 * 1000,
                "asr": prayerTimes.asr.timeIntervalSince1970 * 1000,
                "maghrib": prayerTimes.maghrib.timeIntervalSince1970 * 1000,
                "isha": prayerTimes.isha.timeIntervalSince1970 * 1000
            ]
        } catch {
            return nil
        }
    }
    
    @objc public func calculateQibla(coordinates: [String: Double]) -> [String: Any]? {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            return nil
        }
        
        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let qibla = Qibla(coordinates: adhanCoordinates)
        
        return ["direction": qibla.direction]
    }
    
    @objc public func calculateSunnahTimes(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any]
    ) -> [String: Any]? {
        
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            return nil
        }
        
        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            return nil
        }
        
        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day
        
        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams),
              let sunnahTimes = SunnahTimes(from: prayerTimes) else {
            return nil
        }
        
        return [
            "middleOfTheNight": sunnahTimes.middleOfTheNight.timeIntervalSince1970 * 1000,
            "lastThirdOfTheNight": sunnahTimes.lastThirdOfTheNight.timeIntervalSince1970 * 1000
        ]
    }
    
    @objc public func getCurrentPrayer(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        currentTime: Double
    ) -> [String: String]? {
        
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            return nil
        }
        
        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            return nil
        }
        
        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day
        
        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
            return nil
        }
        
        let currentDate = Date(timeIntervalSince1970: currentTime / 1000)
        let currentPrayer = prayerTimes.currentPrayer(at: currentDate)
        let nextPrayer = prayerTimes.nextPrayer(at: currentDate)
        
        return [
            "current": currentPrayer?.rawValue ?? "none",
            "next": nextPrayer?.rawValue ?? "none"
        ]
    }
    
    @objc public func getTimeForPrayer(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        prayer: String
    ) -> NSNumber? {
        
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            return nil
        }
        
        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            return nil
        }
        
        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day
        
        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
            return nil
        }
        
        guard let prayerEnum = Prayer(rawValue: prayer) else {
            return nil
        }
        
        let time = prayerTimes.time(for: prayerEnum)
        return NSNumber(value: time.timeIntervalSince1970 * 1000)
    }
    
    @objc public func validateCoordinates(coordinates: NSDictionary) -> Bool {
        guard
            let lat = coordinates["latitude"] as? Double,
            let lon = coordinates["longitude"] as? Double
        else {
            return false
        }
        return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180
    }
    
    @objc public func getCalculationMethods() -> [[String: Any]] {
        return [
            [
                "name": "muslimWorldLeague",
                "displayName": "Muslim World League",
                "fajrAngle": 18.0,
                "ishaAngle": 17.0,
                "ishaInterval": 0,
                "description": "Muslim World League. Fajr: 18°, Isha: 17°"
            ],
            [
                "name": "egyptian",
                "displayName": "Egyptian General Authority of Survey",
                "fajrAngle": 19.5,
                "ishaAngle": 17.5,
                "ishaInterval": 0,
                "description": "Egyptian General Authority of Survey. Fajr: 19.5°, Isha: 17.5°"
            ],
            [
                "name": "karachi",
                "displayName": "University of Islamic Sciences, Karachi",
                "fajrAngle": 18.0,
                "ishaAngle": 18.0,
                "ishaInterval": 0,
                "description": "University of Islamic Sciences, Karachi. Fajr: 18°, Isha: 18°"
            ],
            [
                "name": "other",
                "displayName": "Other",
                "fajrAngle": 0,
                "ishaAngle": 0,
                "ishaInterval": 0,
                "description": "Custom calculation method"
            ]
        ]
    }
    
    @objc public func getMethodParameters(method: String) -> [String: Any]? {
        guard let calculationMethod = CalculationMethod.fromString(method) else {
            return nil
        }
        
        let params = CalculationParameters(method: calculationMethod)
        return [
            "method": method,
            "fajrAngle": params.fajrAngle,
            "ishaAngle": params.ishaAngle,
            "ishaInterval": params.ishaInterval,
            "madhab": params.madhab.rawValue,
            "highLatitudeRule": params.highLatitudeRule.rawValue,
            "rounding": params.rounding.rawValue,
            "shafaq": params.shafaq.rawValue
        ]
    }
    
    @objc public func getLibraryInfo() -> [String: String] {
        return [
            "version": "0.1.0",
            "swiftLibraryVersion": "2.0.0",
            "platform": "iOS"
        ]
    }
    
    // MARK: - Private Helpers
    
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