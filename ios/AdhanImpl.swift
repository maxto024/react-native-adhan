// AdhanImpl.swift

import Foundation
import React

@objcMembers
public class AdhanImpl: NSObject {

    func calculatePrayerTimes(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            rejecter("INVALID_DATE", "Year, month, and day are required.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
            rejecter("CALCULATION_ERROR", "Failed to calculate prayer times.", nil)
            return
        }

        let result: [String: Any] = [
            "fajr": prayerTimes.fajr.timeIntervalSince1970 * 1000,
            "sunrise": prayerTimes.sunrise.timeIntervalSince1970 * 1000,
            "dhuhr": prayerTimes.dhuhr.timeIntervalSince1970 * 1000,
            "asr": prayerTimes.asr.timeIntervalSince1970 * 1000,
            "maghrib": prayerTimes.maghrib.timeIntervalSince1970 * 1000,
            "isha": prayerTimes.isha.timeIntervalSince1970 * 1000
        ]
        
        resolver(result)
    }

    func calculateQibla(
        coordinates: [String: Double],
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let qibla = Qibla(coordinates: adhanCoordinates)
        
        resolver(["direction": qibla.direction])
    }

    func calculateSunnahTimes(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            rejecter("INVALID_DATE", "Year, month, and day are required.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams),
              let sunnahTimes = SunnahTimes(from: prayerTimes) else {
            rejecter("CALCULATION_ERROR", "Failed to calculate sunnah times.", nil)
            return
        }

        let result: [String: Any] = [
            "middleOfTheNight": sunnahTimes.middleOfTheNight.timeIntervalSince1970 * 1000,
            "lastThirdOfTheNight": sunnahTimes.lastThirdOfTheNight.timeIntervalSince1970 * 1000
        ]
        
        resolver(result)
    }

    func getCurrentPrayer(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        currentTime: Double,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            rejecter("INVALID_DATE", "Year, month, and day are required.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
            rejecter("CALCULATION_ERROR", "Failed to calculate prayer times for current prayer.", nil)
            return
        }
        
        let currentDate = Date(timeIntervalSince1970: currentTime / 1000)
        let currentPrayer = prayerTimes.currentPrayer(at: currentDate)
        let nextPrayer = prayerTimes.nextPrayer(at: currentDate)

        let result: [String: String] = [
            "current": currentPrayer?.rawValue ?? "none",
            "next": nextPrayer?.rawValue ?? "none"
        ]
        
        resolver(result)
    }

    func getTimeForPrayer(
        coordinates: [String: Double],
        dateComponents: [String: Int],
        calculationParameters: [String: Any],
        prayer: String,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        guard let year = dateComponents["year"], let month = dateComponents["month"], let day = dateComponents["day"] else {
            rejecter("INVALID_DATE", "Year, month, and day are required.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)
        
        var adhanDateComponents = DateComponents()
        adhanDateComponents.year = year
        adhanDateComponents.month = month
        adhanDateComponents.day = day

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: adhanDateComponents, calculationParameters: adhanParams) else {
            rejecter("CALCULATION_ERROR", "Failed to calculate prayer times for getting a specific prayer time.", nil)
            return
        }
        
        guard let prayerEnum = Prayer(rawValue: prayer) else {
            rejecter("INVALID_PRAYER", "Invalid prayer name specified.", nil)
            return
        }
        
        let time = prayerTimes.time(for: prayerEnum)
        resolver(time.timeIntervalSince1970 * 1000)
    }

    func validateCoordinates(
        coordinates: [String: Double],
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            resolver(false)
            return
        }
        
        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        resolver(adhanCoordinates.latitude >= -90 && adhanCoordinates.latitude <= 90 && adhanCoordinates.longitude >= -180 && adhanCoordinates.longitude <= 180)
    }

    func getCalculationMethods(
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        let methods: [[String: Any]] = [
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
                "name": "ummAlQura",
                "displayName": "Umm al-Qura University, Makkah",
                "fajrAngle": 18.5,
                "ishaAngle": 0,
                "ishaInterval": 90,
                "description": "Umm al-Qura University, Makkah. Fajr: 18.5°, Isha: 90 minutes after Maghrib"
            ],
            [
                "name": "dubai",
                "displayName": "Dubai",
                "fajrAngle": 18.2,
                "ishaAngle": 18.2,
                "ishaInterval": 0,
                "description": "Dubai. Fajr: 18.2°, Isha: 18.2°"
            ],
            [
                "name": "moonsightingCommittee",
                "displayName": "Moonsighting Committee",
                "fajrAngle": 18.0,
                "ishaAngle": 18.0,
                "ishaInterval": 0,
                "description": "Moonsighting Committee. Fajr: 18°, Isha: 18°"
            ],
            [
                "name": "northAmerica",
                "displayName": "Islamic Society of North America (ISNA)",
                "fajrAngle": 15.0,
                "ishaAngle": 15.0,
                "ishaInterval": 0,
                "description": "Islamic Society of North America (ISNA). Fajr: 15°, Isha: 15°"
            ],
            [
                "name": "kuwait",
                "displayName": "Kuwait",
                "fajrAngle": 18.0,
                "ishaAngle": 17.5,
                "ishaInterval": 0,
                "description": "Kuwait. Fajr: 18°, Isha: 17.5°"
            ],
            [
                "name": "qatar",
                "displayName": "Qatar",
                "fajrAngle": 18.0,
                "ishaAngle": 0,
                "ishaInterval": 90,
                "description": "Qatar. Fajr: 18°, Isha: 90 minutes after Maghrib"
            ],
            [
                "name": "singapore",
                "displayName": "Majlis Ugama Islam Singapura (MUIS)",
                "fajrAngle": 20.0,
                "ishaAngle": 18.0,
                "ishaInterval": 0,
                "description": "Majlis Ugama Islam Singapura (MUIS). Fajr: 20°, Isha: 18°"
            ],
            [
                "name": "tehran",
                "displayName": "Institute of Geophysics, University of Tehran",
                "fajrAngle": 17.7,
                "ishaAngle": 14.0,
                "ishaInterval": 0,
                "description": "Institute of Geophysics, University of Tehran. Fajr: 17.7°, Isha: 14°"
            ],
            [
                "name": "turkey",
                "displayName": "Diyanet İşleri Başkanlığı",
                "fajrAngle": 18.0,
                "ishaAngle": 17.0,
                "ishaInterval": 0,
                "description": "Diyanet İşleri Başkanlığı. Fajr: 18°, Isha: 17°"
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
        resolver(methods)
    }

    func getMethodParameters(
        method: String,
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let calculationMethod = CalculationMethod.fromString(method) else {
            rejecter("INVALID_METHOD", "Invalid calculation method name.", nil)
            return
        }
        
        let params = CalculationParameters(method: calculationMethod)
        let result: [String: Any] = [
            "method": method,
            "fajrAngle": params.fajrAngle,
            "ishaAngle": params.ishaAngle,
            "ishaInterval": params.ishaInterval,
            "madhab": params.madhab.rawValue,
            "highLatitudeRule": params.highLatitudeRule.rawValue,
            "rounding": params.rounding.rawValue,
            "shafaq": params.shafaq.rawValue,
            "prayerAdjustments": [
                "fajr": params.adjustments.fajr,
                "sunrise": params.adjustments.sunrise,
                "dhuhr": params.adjustments.dhuhr,
                "asr": params.adjustments.asr,
                "maghrib": params.adjustments.maghrib,
                "isha": params.adjustments.isha
            ],
            "methodAdjustments": [
                "fajr": params.methodAdjustments.fajr,
                "sunrise": params.methodAdjustments.sunrise,
                "dhuhr": params.methodAdjustments.dhuhr,
                "asr": params.methodAdjustments.asr,
                "maghrib": params.methodAdjustments.maghrib,
                "isha": params.methodAdjustments.isha
            ]
        ]
        resolver(result)
    }

    func calculatePrayerTimesRange(
        coordinates: [String: Double],
        startDate: [String: Int],
        endDate: [String: Int],
        calculationParameters: [String: Any],
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        guard let lat = coordinates["latitude"], let lon = coordinates["longitude"] else {
            rejecter("INVALID_COORDINATES", "Latitude and longitude are required.", nil)
            return
        }

        guard let startYear = startDate["year"], let startMonth = startDate["month"], let startDay = startDate["day"] else {
            rejecter("INVALID_START_DATE", "Start date requires year, month, and day.", nil)
            return
        }
        
        guard let endYear = endDate["year"], let endMonth = endDate["month"], let endDay = endDate["day"] else {
            rejecter("INVALID_END_DATE", "End date requires year, month, and day.", nil)
            return
        }

        let adhanCoordinates = Coordinates(latitude: lat, longitude: lon)
        let adhanParams = getCalculationParameters(from: calculationParameters)

        var startComponents = DateComponents()
        startComponents.year = startYear
        startComponents.month = startMonth
        startComponents.day = startDay
        
        var endComponents = DateComponents()
        endComponents.year = endYear
        endComponents.month = endMonth
        endComponents.day = endDay

        guard let startDateObj = Calendar.current.date(from: startComponents), let endDateObj = Calendar.current.date(from: endComponents) else {
            rejecter("INVALID_DATE_OBJECT", "Could not create date objects from components.", nil)
            return
        }

        var results: [[String: Any]] = []
        var currentDate = startDateObj
        
        while currentDate <= endDateObj {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
            
            if let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: components, calculationParameters: adhanParams) {
                let prayerTimesDict: [String: Any] = [
                    "fajr": prayerTimes.fajr.timeIntervalSince1970 * 1000,
                    "sunrise": prayerTimes.sunrise.timeIntervalSince1970 * 1000,
                    "dhuhr": prayerTimes.dhuhr.timeIntervalSince1970 * 1000,
                    "asr": prayerTimes.asr.timeIntervalSince1970 * 1000,
                    "maghrib": prayerTimes.maghrib.timeIntervalSince1970 * 1000,
                    "isha": prayerTimes.isha.timeIntervalSince1970 * 1000
                ]
                
                let dateDict: [String: Int] = [
                    "year": components.year!,
                    "month": components.month!,
                    "day": components.day!
                ]
                
                results.append([
                    "date": dateDict,
                    "prayerTimes": prayerTimesDict
                ])
            }
            
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        resolver(results)
    }

    func getLibraryInfo(
        resolver: @escaping RCTPromiseResolveBlock,
        rejecter: @escaping RCTPromiseRejectBlock
    ) -> Void {
        let result: [String: String] = [
            "version": "0.1.0", // Replace with your library's version
            "swiftLibraryVersion": "2.0.0", // Replace with Adhan.swift version if known
            "platform": "iOS"
        ]
        resolver(result)
    }

    // MARK: - Private Helpers

    private func getCalculationParameters(from params: [String: Any]) -> CalculationParameters {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            let decoder = JSONDecoder()
            return try decoder.decode(CalculationParameters.self, from: data)
        } catch {
            return CalculationParameters(method: .other)
        }
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

extension Madhab {
    static func fromString(_ string: String) -> Madhab? {
        return string.lowercased() == "hanafi" ? .hanafi : .shafi
    }
}

extension HighLatitudeRule {
    static func fromString(_ string: String) -> HighLatitudeRule? {
        switch string.lowercased() {
            case "middleofthenight": return .middleOfTheNight
            case "seventhofthenight": return .seventhOfTheNight
            case "twilightangle": return .twilightAngle
            default: return nil
        }
    }
}

extension Rounding {
    static func fromString(_ string: String) -> Rounding? {
        switch string.lowercased() {
            case "up": return .up
            case "nearest": return .nearest
            default: return .nearest
        }
    }
}

extension Shafaq {
    static func fromString(_ string: String) -> Shafaq? {
        switch string.lowercased() {
            case "ahmer": return .ahmer
            case "abyad": return .abyad
            case "general": return .general
            default: return .general
        }
    }
}