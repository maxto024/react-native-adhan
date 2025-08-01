#include "NativeAdhan.h"
#include "PrayerTimes.h"
#include "Adhan.h"

using namespace facebook;

namespace adhan {

NativeAdhan::NativeAdhan(jsi::Runtime &rt) : runtime_(rt) {}

jsi::Value NativeAdhan::get(jsi::Runtime &rt, const jsi::PropNameID &name) {
    auto methodName = name.utf8(rt);

    if (methodName == "getPrayerTimes") {
        return jsi::Function::createFromHostFunction(rt, name, 5,
            [this](jsi::Runtime &runtime, const jsi::Value &thisValue, const jsi::Value *arguments, size_t count) -> jsi::Value {
                if (count < 5) {
                    throw jsi::JSError(runtime, "getPrayerTimes expects at least 5 arguments");
                }

                double latitude = arguments[0].asNumber();
                double longitude = arguments[1].asNumber();
                std::string dateIso = arguments[2].asString(runtime).utf8(runtime);
                std::string method = arguments[3].asString(runtime).utf8(runtime);
                std::string madhab = arguments[4].asString(runtime).utf8(runtime);

                auto prayerTimes = getPrayerTimesCpp(latitude, longitude, dateIso, method, madhab);

                auto result = jsi::Object(runtime);
                for (auto const& [key, val] : prayerTimes) {
                    result.setProperty(runtime, jsi::String::createFromUtf8(runtime, key), jsi::Value((double)val));
                }

                return result;
            });
    }
    // Add other methods here...

    return jsi::Value::undefined();
}

std::vector<jsi::PropNameID> NativeAdhan::getPropertyNames(jsi::Runtime& rt) {
    std::vector<jsi::PropNameID> result;
    result.push_back(jsi::PropNameID::forUtf8(rt, std::string("getPrayerTimes")));
    // Add other method names here...
    return result;
}

} // namespace adhan