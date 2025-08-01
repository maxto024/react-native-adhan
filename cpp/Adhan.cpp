#include "Adhan.h"
#include "PrayerTimes.h"
#include "Coordinates.h"
#include "CalculationMethod.h"
#include "DateComponents.h"
#include <jsi/jsi.h>
#include <ReactCommon/TurboModuleUtils.h>
#include <sstream>
#include <iomanip>

namespace adhan {

// Helper to format time_t to ISO 8601 string
static std::string formatTime(time_t t) {
    std::tm* gmt = std::gmtime(&t);
    if (!gmt) return "";
    std::stringstream ss;
    ss << std::put_time(gmt, "%Y-%m-%dT%H:%M:%SZ");
    return ss.str();
}

Adhan::Adhan(std::shared_ptr<facebook::react::CallInvoker> jsInvoker)
    : AdhanSpec(jsInvoker) {}

facebook::jsi::Value Adhan::getPrayerTimes(
    facebook::jsi::Runtime& rt,
    const facebook::jsi::Object& input
) {
    return facebook::react::createPromiseAsJSIValue(rt, [&](
        facebook::jsi::Runtime& rt,
        std::shared_ptr<facebook::react::Promise> promise) {
        try {
            double latitude = input.getProperty(rt, "latitude").asNumber();
            double longitude = input.getProperty(rt, "longitude").asNumber();
            facebook::jsi::Object dateObj = input.getProperty(rt, "date").asObject(rt);
            int year = dateObj.getProperty(rt, "year").asNumber();
            int month = dateObj.getProperty(rt, "month").asNumber();
            int day = dateObj.getProperty(rt, "day").asNumber();
            std::string method = input.getProperty(rt, "method").asString(rt).utf8(rt);

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

            if (input.hasProperty(rt, "madhab")) {
                std::string madhab = input.getProperty(rt, "madhab").asString(rt).utf8(rt);
                if (madhab == "Hanafi") {
                    params.madhab = Madhab::Hanafi;
                } else {
                    params.madhab = Madhab::Shafi;
                }
            }

            Coordinates coordinates(latitude, longitude);
            DateComponents date(year, month, day);
            PrayerTimes prayerTimes(coordinates, date, params);

            facebook::jsi::Object result(rt);
            result.setProperty(rt, "fajr", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.fajr)));
            result.setProperty(rt, "sunrise", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.sunrise)));
            result.setProperty(rt, "dhuhr", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.dhuhr)));
            result.setProperty(rt, "asr", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.asr)));
            result.setProperty(rt, "maghrib", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.maghrib)));
            result.setProperty(rt, "isha", facebook::jsi::String::createFromUtf8(rt, formatTime(prayerTimes.isha)));

            promise->resolve(std::move(result));
        } catch (const std::exception& e) {
            promise->reject(e.what());
        }
    });
}

} // namespace adhan
