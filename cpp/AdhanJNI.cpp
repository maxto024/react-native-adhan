#include <jni.h>
#include <string>
#include <sstream>
#include "AdhanCalculations.h"

extern "C" {

JNIEXPORT jstring JNICALL
Java_com_adhan_AdhanModule_calculatePrayerTimesNative(
    JNIEnv *env,
    jobject /* this */,
    jdouble latitude,
    jdouble longitude,
    jstring dateIso,
    jstring method,
    jstring madhab,
    jstring timezone,
    jstring adjustments) {
    
    try {
        // Convert Java strings to C++ strings
        const char* dateStr = env->GetStringUTFChars(dateIso, 0);
        const char* methodStr = env->GetStringUTFChars(method, 0);
        const char* madhabStr = madhab ? env->GetStringUTFChars(madhab, 0) : "Shafi";
        const char* timezoneStr = timezone ? env->GetStringUTFChars(timezone, 0) : "UTC";
        const char* adjustmentsStr = adjustments ? env->GetStringUTFChars(adjustments, 0) : "";
        
        // Create coordinates
        Adhan::Coordinates coordinates(latitude, longitude);
        
        // Parse date
        Adhan::DateComponents date = Adhan::parseDate(std::string(dateStr));
        
        // Parse calculation parameters
        Adhan::CalculationParameters params = Adhan::parseMethod(std::string(methodStr));
        params.madhab = Adhan::parseMadhab(std::string(madhabStr));
        
        // Calculate prayer times
        Adhan::PrayerTimes times = Adhan::PrayerTimes::calculate(coordinates, date, params);
        
        // Format as JSON
        std::ostringstream json;
        json << "{";
        json << "\"fajr\":\"" << Adhan::formatDateComponents(times.fajr, std::string(timezoneStr)) << "\",";
        json << "\"sunrise\":\"" << Adhan::formatDateComponents(times.sunrise, std::string(timezoneStr)) << "\",";
        json << "\"dhuhr\":\"" << Adhan::formatDateComponents(times.dhuhr, std::string(timezoneStr)) << "\",";
        json << "\"asr\":\"" << Adhan::formatDateComponents(times.asr, std::string(timezoneStr)) << "\",";
        json << "\"maghrib\":\"" << Adhan::formatDateComponents(times.maghrib, std::string(timezoneStr)) << "\",";
        json << "\"isha\":\"" << Adhan::formatDateComponents(times.isha, std::string(timezoneStr)) << "\"";
        json << "}";
        
        // Clean up
        env->ReleaseStringUTFChars(dateIso, dateStr);
        env->ReleaseStringUTFChars(method, methodStr);
        if (madhab) env->ReleaseStringUTFChars(madhab, madhabStr);
        if (timezone) env->ReleaseStringUTFChars(timezone, timezoneStr);
        if (adjustments) env->ReleaseStringUTFChars(adjustments, adjustmentsStr);
        
        return env->NewStringUTF(json.str().c_str());
        
    } catch (const std::exception& e) {
        // Return empty JSON on error
        return env->NewStringUTF("{}");
    }
}

JNIEXPORT jstring JNICALL
Java_com_adhan_AdhanModule_calculateQiblaDirectionNative(
    JNIEnv *env,
    jobject /* this */,
    jdouble latitude,
    jdouble longitude) {
    
    try {
        // Makkah coordinates
        const double makkahLat = 21.4225;
        const double makkahLon = 39.8262;
        
        // Convert to radians
        double lat1 = latitude * M_PI / 180.0;
        double lat2 = makkahLat * M_PI / 180.0;
        double deltaLon = (makkahLon - longitude) * M_PI / 180.0;
        
        // Calculate bearing
        double y = sin(deltaLon) * cos(lat2);
        double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
        double direction = atan2(y, x) * 180.0 / M_PI;
        direction = fmod(direction + 360.0, 360.0);
        
        // Calculate distance using Haversine formula
        const double R = 6371.0; // Earth's radius in km
        double dLat = (makkahLat - latitude) * M_PI / 180.0;
        double dLon = deltaLon;
        double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
        double c = 2 * atan2(sqrt(a), sqrt(1 - a));
        double distance = R * c;
        
        // Format as JSON
        std::ostringstream json;
        json << "{";
        json << "\"direction\":" << direction << ",";
        json << "\"distance\":" << distance;
        json << "}";
        
        return env->NewStringUTF(json.str().c_str());
        
    } catch (const std::exception& e) {
        return env->NewStringUTF("{}");
    }
}

} // extern "C"