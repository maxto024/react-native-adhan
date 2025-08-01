#include "../include/adhan/Adhan.hpp"
#include <cmath>

namespace adhan {

CalculationParameters getParameters(CalculationMethod method) {
    CalculationParameters params;
    
    switch (method) {
        case CalculationMethod::MuslimWorldLeague:
            params.fajrAngle = 18.0;
            params.ishaAngle = 17.0;
            break;
        case CalculationMethod::Egyptian:
            params.fajrAngle = 19.5;
            params.ishaAngle = 17.5;
            break;
        case CalculationMethod::Karachi:
            params.fajrAngle = 18.0;
            params.ishaAngle = 18.0;
            break;
        case CalculationMethod::UmmAlQura:
            params.fajrAngle = 18.5;
            params.ishaInterval = 90;
            break;
        case CalculationMethod::Dubai:
            params.fajrAngle = 18.2;
            params.ishaAngle = 18.2;
            break;
        case CalculationMethod::MoonsightingCommittee:
            params.fajrAngle = 18.0;
            params.ishaAngle = 18.0;
            break;
        case CalculationMethod::NorthAmerica:
            params.fajrAngle = 15.0;
            params.ishaAngle = 15.0;
            break;
        default:
            params.fajrAngle = 18.0;
            params.ishaAngle = 17.0;
            break;
    }
    
    return params;
}

double julianDay(int year, int month, int day) {
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    
    double a = floor(year / 100.0);
    double b = 2 - a + floor(a / 4.0);
    
    return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + b - 1524.5;
}

double timeForAngle(double latitude, double declination, double angle) {
    double numerator = sin(angle * M_PI / 180.0) - sin(latitude * M_PI / 180.0) * sin(declination);
    double denominator = cos(latitude * M_PI / 180.0) * cos(declination);
    
    if (abs(numerator / denominator) > 1.0) {
        return NAN;
    }
    
    return acos(numerator / denominator) * 180.0 / M_PI / 15.0;
}

TimeComponents timeFromDecimal(double decimal) {
    int hours = (int)floor(decimal);
    int minutes = (int)floor((decimal - hours) * 60);
    int seconds = (int)round(((decimal - hours) * 60 - minutes) * 60);
    
    if (seconds >= 60) {
        seconds = 0;
        minutes++;
    }
    if (minutes >= 60) {
        minutes = 0;
        hours++;
    }
    
    return TimeComponents(hours, minutes, seconds);
}

PrayerTimes::PrayerTimes(const Coordinates& coordinates, const DateComponents& date, const CalculationParameters& params)
    : fajr(0, 0, 0), sunrise(0, 0, 0), dhuhr(0, 0, 0), asr(0, 0, 0), maghrib(0, 0, 0), isha(0, 0, 0) {
    
    double jd = julianDay(date.year, date.month, date.day);
    double longitude = coordinates.longitude;
    double latitude = coordinates.latitude;
    
    // Solar declination
    double solarDeclination = 23.45 * sin((360.0 * (284 + date.day) / 365.0) * M_PI / 180.0);
    
    // Prayer time calculations
    double fajrTime = 12.0 - timeForAngle(latitude, solarDeclination, -params.fajrAngle) - longitude / 15.0;
    double sunriseTime = 12.0 - timeForAngle(latitude, solarDeclination, -0.833) - longitude / 15.0;
    double dhuhrTime = 12.0 - longitude / 15.0;
    
    // Asr calculation
    double shadowLength = (params.madhab == Madhab::Hanafi) ? 2.0 : 1.0;
    double asrAngle = atan(1.0 / (shadowLength + tan((90.0 - abs(latitude - solarDeclination)) * M_PI / 180.0))) * 180.0 / M_PI;
    double asrTime = 12.0 + timeForAngle(latitude, solarDeclination, 90.0 - asrAngle) - longitude / 15.0;
    
    double maghribTime = 12.0 + timeForAngle(latitude, solarDeclination, -0.833) - longitude / 15.0;
    double ishaTime = 12.0 + timeForAngle(latitude, solarDeclination, -params.ishaAngle) - longitude / 15.0;
    
    // Convert to time components
    fajr = timeFromDecimal(fajrTime);
    sunrise = timeFromDecimal(sunriseTime);
    dhuhr = timeFromDecimal(dhuhrTime);
    asr = timeFromDecimal(asrTime);
    maghrib = timeFromDecimal(maghribTime);
    isha = timeFromDecimal(ishaTime);
}

}