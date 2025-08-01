#include "NativeAdhanModule.h"
#include "PrayerTimes.h"
#include "Coordinates.h"
#include "CalculationMethod.h"
#include "DateComponents.h"
#include <jsi/jsi.h>
#include <sstream>
#include <iomanip>

namespace facebook::react {

// Helper to format time_t to ISO 8601 string
static std::string formatTime(time_t t) {
    std::tm* gmt = std::gmtime(&t);
    if (!gmt) return "";
    std::stringstream ss;
    ss << std::put_time(gmt, "%Y-%m-%dT%H:%M:%SZ");
    return ss.str();
}

NativeAdhanModule::NativeAdhanModule(std::shared_ptr<CallInvoker> jsInvoker)
    : TurboModule("NativeAdhanModule", std::move(jsInvoker)) {}

jsi::Value NativeAdhanModule::getPrayerTimes(jsi::Runtime& rt, jsi::Object input) {
    try {
        // Extract parameters from input
        double latitude = input.getProperty(rt, "latitude").asNumber();
        double longitude = input.getProperty(rt, "longitude").asNumber();
        
        jsi::Object dateObj = input.getProperty(rt, "date").asObject(rt);
        int year = (int)dateObj.getProperty(rt, "year").asNumber();
        int month = (int)dateObj.getProperty(rt, "month").asNumber();
        int day = (int)dateObj.getProperty(rt, "day").asNumber();
        
        std::string method = input.getProperty(rt, "method").asString(rt).utf8(rt);
        
        // Parse calculation method
        CalculationMethod calculationMethod = CalculationMethod::Other;
        if (method == "MuslimWorldLeague") calculationMethod = CalculationMethod::MuslimWorldLeague;
        else if (method == "Egyptian") calculationMethod = CalculationMethod::Egyptian;
        else if (method == "Karachi") calculationMethod = CalculationMethod::Karachi;
        else if (method == "UmmAlQura") calculationMethod = CalculationMethod::UmmAlQura;
        else if (method == "Dubai") calculationMethod = CalculationMethod::Dubai;
        else if (method == "MoonsightingCommittee") calculationMethod = CalculationMethod::MoonsightingCommittee;
        else if (method == "NorthAmerica") calculationMethod = CalculationMethod::NorthAmerica;
        else if (method == "Kuwait") calculationMethod = CalculationMethod::Kuwait;
        else if (method == "Qatar") calculationMethod = CalculationMethod::Qatar;
        else if (method == "Singapore") calculationMethod = CalculationMethod::Singapore;
        else if (method == "Tehran") calculationMethod = CalculationMethod::Tehran;
        else if (method == "Turkey") calculationMethod = CalculationMethod::Turkey;
        
        CalculationParameters params = getParams(calculationMethod);
        
        // Handle optional madhab
        if (input.hasProperty(rt, "madhab")) {
            std::string madhab = input.getProperty(rt, "madhab").asString(rt).utf8(rt);
            if (madhab == "Hanafi") {
                params.madhab = Madhab::Hanafi;
            } else {
                params.madhab = Madhab::Shafi;
            }
        }
        
        // Create coordinates and date
        Coordinates coordinates(latitude, longitude);
        DateComponents date(year, month, day);
        
        // Calculate prayer times
        PrayerTimes prayerTimes(coordinates, date, params);
        
        // Create result object
        jsi::Object result(rt);
        result.setProperty(rt, "fajr", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.fajr)));
        result.setProperty(rt, "sunrise", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.sunrise)));
        result.setProperty(rt, "dhuhr", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.dhuhr)));
        result.setProperty(rt, "asr", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.asr)));
        result.setProperty(rt, "maghrib", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.maghrib)));
        result.setProperty(rt, "isha", jsi::String::createFromUtf8(rt, formatTime(prayerTimes.isha)));
        
        // Return as resolved promise
        return jsi::Value(std::move(result));
        
    } catch (const std::exception& e) {
        // Return rejected promise with error
        throw jsi::JSError(rt, e.what());
    }
}

} // namespace facebook::react