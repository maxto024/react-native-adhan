import Foundation
import Adhan

@objc(PrayerTimesWrapper)
public class PrayerTimesWrapper: NSObject {

    @objc
    public func getPrayerTimes(latitude: Double, longitude: Double, dateIso: String, method: String, madhab: String?, adjustments: String?, customAngles: String?) -> String {
        do {
            let coordinates = Coordinates(latitude: latitude, longitude: longitude)
            guard let date = parseISO(date: dateIso) else {
                throw AdhanWrapperError.invalidDate
            }
            var params = getParams(method: method)

            if let madhab = madhab, madhab.lowercased() == "hanafi" {
                params.madhab = .hanafi
            }

            if let adjustmentsJson = adjustments?.data(using: .utf8) {
                let decoder = JSONDecoder()
                if let adjustments = try? decoder.decode([String: Int].self, from: adjustmentsJson) {
                    params.adjustments.fajr = adjustments["fajr"] ?? 0
                    params.adjustments.sunrise = adjustments["sunrise"] ?? 0
                    params.adjustments.dhuhr = adjustments["dhuhr"] ?? 0
                    params.adjustments.asr = adjustments["asr"] ?? 0
                    params.adjustments.maghrib = adjustments["maghrib"] ?? 0
                    params.adjustments.isha = adjustments["isha"] ?? 0
                }
            }

            if let prayerTimes = PrayerTimes(coordinates: coordinates, date: Calendar.current.dateComponents([.year, .month, .day], from: date), calculationParameters: params) {
                return formatPrayerTimes(prayerTimes: prayerTimes)
            } else {
                throw AdhanWrapperError.invalidParams
            }
        } catch {
            return "{\"error\": \"\(error.localizedDescription)\"}"
        }
    }

    @objc
    public func getQiblaDirection(latitude: Double, longitude: Double) -> String {
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        let qibla = Qibla(coordinates: coordinates)
        return "{\"direction\": \(qibla.direction)}"
    }

    @objc
    public func getBulkPrayerTimes(latitude: Double, longitude: Double, startDateIso: String, endDateIso: String, method: String, madhab: String?, timezone: String?, adjustments: String?, customAngles: String?) -> String {
        do {
            let coordinates = Coordinates(latitude: latitude, longitude: longitude)
            guard let startDate = parseISO(date: startDateIso), let endDate = parseISO(date: endDateIso) else {
                throw AdhanWrapperError.invalidDate
            }
            var params = getParams(method: method)

            if let madhab = madhab, madhab.lowercased() == "hanafi" {
                params.madhab = .hanafi
            }

            var prayerTimesArray: [[String: Any]] = []
            var currentDate = startDate
            let calendar = Calendar.current

            while currentDate <= endDate {
                if let prayerTimes = PrayerTimes(coordinates: coordinates, date: calendar.dateComponents([.year, .month, .day], from: currentDate), calculationParameters: params) {
                    prayerTimesArray.append(formatPrayerTimesAsDict(prayerTimes: prayerTimes))
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: prayerTimesArray, options: [])
            return String(data: jsonData, encoding: .utf8) ?? "[]"
        } catch {
            return "{\"error\": \"\(error.localizedDescription)\"}"
        }
    }

    @objc
    public func getAvailableMethods() -> String {
        let methods = CalculationMethod.allCases.map { method -> [String: Any] in
            return [
                "name": method.name,
                "params": [
                    "fajrAngle": method.params.fajrAngle,
                    "ishaAngle": method.params.ishaAngle,
                    "ishaInterval": method.params.ishaInterval,
                    "maghribAngle": method.params.maghribAngle ?? 0
                ]
            ]
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: methods, options: []) {
            return String(data: jsonData, encoding: .utf8) ?? "[]"
        }
        return "[]"
    }

    @objc
    public func validateCoordinates(latitude: Double, longitude: Double) -> Bool {
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }

    @objc
    public func getModuleInfo() -> String {
        return "{\"version\": \"1.0.0\", \"build\": 1}"
    }

    private func parseISO(date: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: date)
    }

    private func getParams(method: String) -> CalculationParameters {
        switch method.lowercased() {
        case "mwl", "muslimworldleague": return CalculationMethod.muslimWorldLeague.params
        case "isna", "northamerica": return CalculationMethod.northAmerica.params
        case "egypt", "egyptian": return CalculationMethod.egyptian.params
        case "karachi": return CalculationMethod.karachi.params
        case "ummalqura": return CalculationMethod.ummAlQura.params
        case "dubai": return CalculationMethod.dubai.params
        case "moonsighting", "moonsightingcommittee": return CalculationMethod.moonsightingCommittee.params
        case "kuwait": return CalculationMethod.kuwait.params
        case "qatar": return CalculationMethod.qatar.params
        case "singapore": return CalculationMethod.singapore.params
        case "tehran": return CalculationMethod.tehran.params
        case "turkey": return CalculationMethod.turkey.params
        default: return CalculationMethod.muslimWorldLeague.params // Default to MWL
        }
    }

    private func formatPrayerTimes(prayerTimes: PrayerTimes) -> String {
        let dict = formatPrayerTimesAsDict(prayerTimes: prayerTimes)
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
    
    private func formatPrayerTimesAsDict(prayerTimes: PrayerTimes) -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime]

        return [
            "fajr": formatter.string(from: prayerTimes.fajr),
            "sunrise": formatter.string(from: prayerTimes.sunrise),
            "dhuhr": formatter.string(from: prayerTimes.dhuhr),
            "asr": formatter.string(from: prayerTimes.asr),
            "maghrib": formatter.string(from: prayerTimes.maghrib),
            "isha": formatter.string(from: prayerTimes.isha)
        ]
    }
}

enum AdhanWrapperError: Error {
    case invalidDate
    case invalidParams
}

extension CalculationMethod {
    var name: String {
        switch self {
        case .muslimWorldLeague: return "Muslim World League"
        case .northAmerica: return "North America"
        case .egyptian: return "Egyptian"
        case .karachi: return "Karachi"
        case .ummAlQura: return "Umm Al-Qura"
        case .dubai: return "Dubai"
        case .moonsightingCommittee: return "Moonsighting Committee"
        case .kuwait: return "Kuwait"
        case .qatar: return "Qatar"
        case .singapore: return "Singapore"
        case .tehran: return "Tehran"
        case .turkey: return "Turkey"
        case .other: return "Other"
        }
    }
}