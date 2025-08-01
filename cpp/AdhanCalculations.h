#pragma once

#include <cmath>
#include <string>
#include <map>
#include <vector>

namespace Adhan {

class Angle {
public:
    explicit Angle(double degrees) : degrees_(degrees) {}
    
    double degrees() const { return degrees_; }
    double radians() const { return degrees_ * M_PI / 180.0; }
    
    Angle unwound() const {
        double d = fmod(degrees_, 360.0);
        return Angle(d < 0 ? d + 360.0 : d);
    }
    
    Angle quadrantShifted() const {
        if (degrees_ >= -180 && degrees_ <= 180) {
            return *this;
        }
        return Angle(degrees_ - 360.0 * round(degrees_ / 360.0));
    }
    
    Angle operator+(const Angle& other) const {
        return Angle(degrees_ + other.degrees_);
    }
    
    Angle operator-(const Angle& other) const {
        return Angle(degrees_ - other.degrees_);
    }
    
    Angle operator*(double factor) const {
        return Angle(degrees_ * factor);
    }
    
    Angle operator/(const Angle& other) const {
        return Angle(degrees_ / other.degrees_);
    }

private:
    double degrees_;
};

struct Coordinates {
    double latitude;
    double longitude;
    
    Coordinates(double lat, double lon) : latitude(lat), longitude(lon) {}
    
    Angle latitudeAngle() const { return Angle(latitude); }
    Angle longitudeAngle() const { return Angle(longitude); }
};

struct SolarCoordinates {
    Angle declination;
    Angle rightAscension;
    Angle apparentSiderealTime;
    
    SolarCoordinates(double julianDay);
};

struct DateComponents {
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
    
    DateComponents(int y, int m, int d, int h = 0, int min = 0, int s = 0)
        : year(y), month(m), day(d), hour(h), minute(min), second(s) {}
    
    DateComponents settingHour(double hours) const;
    double julianDay() const;
};

class Astronomical {
public:
    // Core astronomical calculations following Jean Meeus algorithms
    static Angle meanSolarLongitude(double julianCentury);
    static Angle meanLunarLongitude(double julianCentury);
    static Angle ascendingLunarNodeLongitude(double julianCentury);
    static Angle meanSolarAnomaly(double julianCentury);
    static Angle solarEquationOfTheCenter(double julianCentury, const Angle& meanAnomaly);
    static Angle apparentSolarLongitude(double julianCentury, const Angle& meanLongitude);
    static Angle meanObliquityOfTheEcliptic(double julianCentury);
    static Angle apparentObliquityOfTheEcliptic(double julianCentury, const Angle& meanObliquity);
    static Angle meanSiderealTime(double julianCentury);
    
    // Nutation calculations
    static double nutationInLongitude(const Angle& solarLongitude, const Angle& lunarLongitude, const Angle& ascendingNode);
    static double nutationInObliquity(const Angle& solarLongitude, const Angle& lunarLongitude, const Angle& ascendingNode);
    
    // Time calculations
    static double approximateTransit(const Angle& longitude, const Angle& siderealTime, const Angle& rightAscension);
    static double correctedTransit(double approximateTransit, const Angle& longitude, const Angle& siderealTime,
                                 const Angle& rightAscension, const Angle& previousRightAscension, const Angle& nextRightAscension);
    static double correctedHourAngle(double approximateTransit, const Angle& angle, const Coordinates& coordinates, bool afterTransit,
                                   const Angle& siderealTime, const Angle& rightAscension, const Angle& previousRightAscension, const Angle& nextRightAscension,
                                   const Angle& declination, const Angle& previousDeclination, const Angle& nextDeclination);
    
    // Utility functions
    static double julianDay(int year, int month, int day, double hours = 0);
    static double julianDay(const DateComponents& date);
    static double julianCentury(double julianDay);
    static bool isLeapYear(int year);
    static double interpolate(double value, double previousValue, double nextValue, double factor);
    static Angle interpolateAngles(const Angle& value, const Angle& previousValue, const Angle& nextValue, double factor);
    
    // Altitude calculations
    static Angle altitudeOfCelestialBody(const Angle& observerLatitude, const Angle& declination, const Angle& localHourAngle);
    
    // Season adjustment for high latitudes (Moonsighting Committee method)
    static double seasonAdjustedMorningTwilight(double latitude, int dayOfYear, int year, double sunrise);
    static double seasonAdjustedEveningTwilight(double latitude, int dayOfYear, int year, double sunset);
    static int daysSinceSolstice(int dayOfYear, int year, double latitude);

private:
    static double normalizedToScale(double value, double scale);
};

struct SolarTime {
    DateComponents date;
    Coordinates observer;
    SolarCoordinates solar;
    DateComponents transit;
    DateComponents sunrise;
    DateComponents sunset;
    
    SolarCoordinates prevSolar;
    SolarCoordinates nextSolar;
    double approxTransit;
    
    SolarTime(const DateComponents& date, const Coordinates& coordinates);
    
    DateComponents timeForSolarAngle(const Angle& angle, bool afterTransit) const;
    DateComponents afternoon(double shadowLength) const;
};

enum class CalculationMethod {
    MUSLIM_WORLD_LEAGUE,
    EGYPTIAN,
    KARACHI,
    UMM_AL_QURA,
    DUBAI,
    MOON_SIGHTING_COMMITTEE,
    NORTH_AMERICA,
    KUWAIT,
    QATAR,
    SINGAPORE,
    TEHRAN,
    TURKEY
};

enum class Madhab {
    SHAFI,
    HANAFI
};

struct CalculationParameters {
    CalculationMethod method;
    double fajrAngle;
    double ishaAngle;
    double ishaInterval; // minutes after maghrib
    double maghribAngle; // optional, for methods that specify maghrib angle
    Madhab madhab;
    
    // Adjustments in minutes
    std::map<std::string, int> adjustments;
    std::map<std::string, int> methodAdjustments;
    
    static CalculationParameters forMethod(CalculationMethod method);
    
    double shadowLength() const {
        return madhab == Madhab::HANAFI ? 2.0 : 1.0;
    }
};

struct PrayerTimes {
    DateComponents fajr;
    DateComponents sunrise;
    DateComponents dhuhr;
    DateComponents asr;
    DateComponents maghrib;
    DateComponents isha;
    
    static PrayerTimes calculate(const Coordinates& coordinates, const DateComponents& date, const CalculationParameters& params);
};

// Utility functions
double normalizeToScale(double value, double scale);
std::string formatDateComponents(const DateComponents& date, const std::string& timezone);
DateComponents parseDate(const std::string& dateIso);
CalculationParameters parseMethod(const std::string& methodName);
Madhab parseMadhab(const std::string& madhabName);

} // namespace Adhan