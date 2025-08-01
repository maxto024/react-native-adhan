#ifdef __ANDROID__
#include <jni.h>
#include <string>
#include "PrayerTimes.h"
#include "Coordinates.h"
#include "CalculationMethod.h"
#include "DateComponents.h"
#include <sstream>
#include <iomanip>

// Helper to format time_t to ISO 8601 string
static std::string formatTime(time_t t) {
    std::tm* gmt = std::gmtime(&t);
    if (!gmt) return "";
    std::stringstream ss;
    ss << std::put_time(gmt, "%Y-%m-%dT%H:%M:%SZ");
    return ss.str();
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_adhan_AdhanModule_nativeGetPrayerTimes(
    JNIEnv *env,
    jobject /* this */,
    jdouble latitude,
    jdouble longitude,
    jint year,
    jint month,
    jint day,
    jstring method,
    jstring madhab) {
    
    try {
        // Convert Java strings to C++ strings
        const char* methodStr = env->GetStringUTFChars(method, nullptr);
        std::string methodCpp(methodStr);
        env->ReleaseStringUTFChars(method, methodStr);
        
        std::string madhabCpp;
        if (madhab != nullptr) {
            const char* madhabStr = env->GetStringUTFChars(madhab, nullptr);
            madhabCpp = std::string(madhabStr);
            env->ReleaseStringUTFChars(madhab, madhabStr);
        }
        
        // Parse calculation method
        CalculationMethod calculationMethod = CalculationMethod::Other;
        if (methodCpp == "MuslimWorldLeague") calculationMethod = CalculationMethod::MuslimWorldLeague;
        else if (methodCpp == "Egyptian") calculationMethod = CalculationMethod::Egyptian;
        else if (methodCpp == "Karachi") calculationMethod = CalculationMethod::Karachi;
        else if (methodCpp == "UmmAlQura") calculationMethod = CalculationMethod::UmmAlQura;
        else if (methodCpp == "Dubai") calculationMethod = CalculationMethod::Dubai;
        else if (methodCpp == "MoonsightingCommittee") calculationMethod = CalculationMethod::MoonsightingCommittee;
        else if (methodCpp == "NorthAmerica") calculationMethod = CalculationMethod::NorthAmerica;
        else if (methodCpp == "Kuwait") calculationMethod = CalculationMethod::Kuwait;
        else if (methodCpp == "Qatar") calculationMethod = CalculationMethod::Qatar;
        else if (methodCpp == "Singapore") calculationMethod = CalculationMethod::Singapore;
        else if (methodCpp == "Tehran") calculationMethod = CalculationMethod::Tehran;
        else if (methodCpp == "Turkey") calculationMethod = CalculationMethod::Turkey;
        
        CalculationParameters params = getParams(calculationMethod);
        
        if (!madhabCpp.empty()) {
            if (madhabCpp == "Hanafi") {
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
        
        // Create JSON result
        std::stringstream json;
        json << "{";
        json << "\"fajr\":\"" << formatTime(prayerTimes.fajr) << "\",";
        json << "\"sunrise\":\"" << formatTime(prayerTimes.sunrise) << "\",";
        json << "\"dhuhr\":\"" << formatTime(prayerTimes.dhuhr) << "\",";
        json << "\"asr\":\"" << formatTime(prayerTimes.asr) << "\",";
        json << "\"maghrib\":\"" << formatTime(prayerTimes.maghrib) << "\",";
        json << "\"isha\":\"" << formatTime(prayerTimes.isha) << "\"";
        json << "}";
        
        return env->NewStringUTF(json.str().c_str());
    } catch (const std::exception& e) {
        return env->NewStringUTF("{}");
    }
}
#endif