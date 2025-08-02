import Foundation

// MARK: - Data Models

// Note: All models are converted from struct to class and inherit from NSObject
// to be accessible from Objective-C. Properties are marked with @objc dynamic.

@objc(AdhanCoordinates)
public class AdhanCoordinates: NSObject {
    @objc public dynamic var latitude: Double
    @objc public dynamic var longitude: Double

    @objc public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

@objc(AdhanPrayerAdjustments)
public class AdhanPrayerAdjustments: NSObject {
    @objc public dynamic var fajr: Int = 0
    @objc public dynamic var sunrise: Int = 0
    @objc public dynamic var dhuhr: Int = 0
    @objc public dynamic var asr: Int = 0
    @objc public dynamic var maghrib: Int = 0
    @objc public dynamic var isha: Int = 0
}

@objc(AdhanCalculationParameters)
public class AdhanCalculationParameters: NSObject {
    @objc public dynamic var method: String = "other"
    @objc public dynamic var fajrAngle: Double = 0
    @objc public dynamic var ishaAngle: Double = 0
    @objc public dynamic var ishaInterval: Int = 0
    @objc public dynamic var madhab: String = "shafi"
    @objc public dynamic var highLatitudeRule: String = "middleOfTheNight"
    @objc public dynamic var rounding: String = "nearest"
    @objc public dynamic var shafaq: String = "general"
    @objc public dynamic var adjustments = AdhanPrayerAdjustments()
    @objc public dynamic var methodAdjustments = AdhanPrayerAdjustments()
}

@objc(AdhanPrayerTimes)
public class AdhanPrayerTimes: NSObject {
    @objc public dynamic var fajr: Date
    @objc public dynamic var sunrise: Date
    @objc public dynamic var dhuhr: Date
    @objc public dynamic var asr: Date
    @objc public dynamic var maghrib: Date
    @objc public dynamic var isha: Date

    @objc public init(fajr: Date, sunrise: Date, dhuhr: Date, asr: Date, maghrib: Date, isha: Date) {
        self.fajr = fajr
        self.sunrise = sunrise
        self.dhuhr = dhuhr
        self.asr = asr
        self.maghrib = maghrib
        self.isha = isha
    }
}

@objc(AdhanSunnahTimes)
public class AdhanSunnahTimes: NSObject {
    @objc public dynamic var middleOfTheNight: Date
    @objc public dynamic var lastThirdOfTheNight: Date

    @objc public init(middleOfTheNight: Date, lastThirdOfTheNight: Date) {
        self.middleOfTheNight = middleOfTheNight
        self.lastThirdOfTheNight = lastThirdOfTheNight
    }
}

@objc(AdhanQibla)
public class AdhanQibla: NSObject {
    @objc public dynamic var direction: Double

    @objc public init(direction: Double) {
        self.direction = direction
    }
}

// MARK: - AdhanBridge Facade

@objc(AdhanBridge)
public class AdhanBridge: NSObject {

    // MARK: - Private Helpers

    private func getCalculationParameters(from params: AdhanCalculationParameters) -> CalculationParameters {
        var adhanParams: CalculationParameters

        if let method = CalculationMethod.fromString(params.method) {
            adhanParams = method.params
        } else {
            adhanParams = CalculationMethod.other.params
        }

        // Apply custom values if they are not default
        if params.fajrAngle != 0 { adhanParams.fajrAngle = params.fajrAngle }
        if params.ishaAngle != 0 { adhanParams.ishaAngle = params.ishaAngle }
        if params.ishaInterval != 0 { adhanParams.ishaInterval = Minute(params.ishaInterval) }
        
        adhanParams.madhab = Madhab.fromString(params.madhab) ?? .shafi
        adhanParams.highLatitudeRule = HighLatitudeRule.fromString(params.highLatitudeRule) ?? .middleOfTheNight
        adhanParams.rounding = Rounding.fromString(params.rounding) ?? .nearest
        adhanParams.shafaq = Shafaq.fromString(params.shafaq) ?? .general

        // Adjustments
        adhanParams.adjustments.fajr = Minute(params.adjustments.fajr)
        adhanParams.adjustments.sunrise = Minute(params.adjustments.sunrise)
        adhanParams.adjustments.dhuhr = Minute(params.adjustments.dhuhr)
        adhanParams.adjustments.asr = Minute(params.adjustments.asr)
        adhanParams.adjustments.maghrib = Minute(params.adjustments.maghrib)
        adhanParams.adjustments.isha = Minute(params.adjustments.isha)
        
        // Method Adjustments
        adhanParams.methodAdjustments.fajr = Minute(params.methodAdjustments.fajr)
        adhanParams.methodAdjustments.sunrise = Minute(params.methodAdjustments.sunrise)
        adhanParams.methodAdjustments.dhuhr = Minute(params.methodAdjustments.dhuhr)
        adhanParams.methodAdjustments.asr = Minute(params.methodAdjustments.asr)
        adhanParams.methodAdjustments.maghrib = Minute(params.methodAdjustments.maghrib)
        adhanParams.methodAdjustments.isha = Minute(params.methodAdjustments.isha)

        return adhanParams
    }

    private func getDateComponents(year: Int, month: Int, day: Int) -> DateComponents {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return components
    }

    // MARK: - Public API

    @objc
    public func calculatePrayerTimes(
        coordinates: AdhanCoordinates,
        year: Int,
        month: Int,
        day: Int,
        params: AdhanCalculationParameters
    ) -> AdhanPrayerTimes? {
        let adhanCoordinates = Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let adhanParams = getCalculationParameters(from: params)
        let dateComponents = getDateComponents(year: year, month: month, day: day)

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: dateComponents, calculationParameters: adhanParams) else {
            return nil
        }

        return AdhanPrayerTimes(
            fajr: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dhuhr: prayerTimes.dhuhr,
            asr: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isha: prayerTimes.isha
        )
    }

    @objc
    public func calculateQibla(coordinates: AdhanCoordinates) -> AdhanQibla {
        let adhanCoordinates = Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let qibla = Qibla(coordinates: adhanCoordinates)
        return AdhanQibla(direction: qibla.direction)
    }
    
    @objc
    public func calculateSunnahTimes(
        coordinates: AdhanCoordinates,
        year: Int,
        month: Int,
        day: Int,
        params: AdhanCalculationParameters
    ) -> AdhanSunnahTimes? {
        let adhanCoordinates = Coordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let adhanParams = getCalculationParameters(from: params)
        let dateComponents = getDateComponents(year: year, month: month, day: day)

        guard let prayerTimes = PrayerTimes(coordinates: adhanCoordinates, date: dateComponents, calculationParameters: adhanParams),
              let sunnahTimes = SunnahTimes(from: prayerTimes) else {
            return nil
        }

        return AdhanSunnahTimes(
            middleOfTheNight: sunnahTimes.middleOfTheNight,
            lastThirdOfTheNight: sunnahTimes.lastThirdOfTheNight
        )
    }
    
    @objc
    public func getLibraryInfo() -> [String: String] {
        return [
            "version": "1.0.0", // Your library version
            "swiftLibraryVersion": "2.0.0", // Adhan.swift version
            "platform": "iOS"
        ];
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
            case "down": return .down
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
