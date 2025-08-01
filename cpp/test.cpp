#include "PrayerTimes.h"
#include <iostream>
#include <string>
#include <map>
#include "third_party/adhan-cpp/include/adhan/Adhan.hpp"

void runTest(
    const std::string& location,
    double latitude,
    double longitude,
    const std::string& date,
    const std::string& method,
    const std::string& timezone,
    const std::string& madhab) {

    std::cout << "========================================" << std::endl;
    std::cout << "Calculating prayer times for " << location << std::endl;
    std::cout << "Date: " << date << ", Timezone: " << timezone << ", Madhab: " << madhab << std::endl;
    std::cout << "----------------------------------------" << std::endl;

    std::map<std::string, std::string> prayerTimes = getPrayerTimesCpp(
        latitude,
        longitude,
        date,
        method,
        timezone,
        madhab
    );

    std::cout << "Fajr:    " << prayerTimes["fajr"] << std::endl;
    std::cout << "Sunrise: " << prayerTimes["sunrise"] << std::endl;
    std::cout << "Dhuhr:   " << prayerTimes["dhuhr"] << std::endl;
    std::cout << "Asr:     " << prayerTimes["asr"] << std::endl;
    std::cout << "Maghrib: " << prayerTimes["maghrib"] << std::endl;
    std::cout << "Isha:    " << prayerTimes["isha"] << std::endl;
    std::cout << "========================================" << std::endl << std::endl;
}

int main() {
    // Test Case 1: Hopkins, MN (Shafi)
    runTest(
        "Hopkins, MN (Shafi)",
        44.9242,
        -93.4615,
        "2025-08-01",
        "ISNA",
        "America/Chicago",
        "Shafi"
    );

    // Test Case 2: Hopkins, MN (Hanafi)
    runTest(
        "Hopkins, MN (Hanafi)",
        44.9242,
        -93.4615,
        "2025-08-01",
        "ISNA",
        "America/Chicago",
        "Hanafi"
    );

    return 0;
}