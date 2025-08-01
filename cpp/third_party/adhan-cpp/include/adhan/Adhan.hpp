#pragma once

#include <cmath>
#include <string>
#include "SolarTime.h"

namespace adhan {

struct DateComponents {
    int year;
    int month;
    int day;
    
    DateComponents(int y, int m, int d) : year(y), month(m), day(d) {}
};

struct TimeComponents {
    int hours;
    int minutes;
    int seconds;
    
    TimeComponents(int h, int m, int s) : hours(h), minutes(m), seconds(s) {}
};

struct Coordinates {
    double latitude;
    double longitude;
    
    Coordinates(double lat, double lon) : latitude(lat), longitude(lon) {}
};

enum class CalculationMethod {
    MuslimWorldLeague,
    Egyptian,
    Karachi,
    UmmAlQura,
    Dubai,
    MoonsightingCommittee,
    NorthAmerica,
    Kuwait,
    Qatar
};

enum class Madhab {
    Shafi,
    Hanafi
};

struct CalculationParameters {
    double fajrAngle;
    double ishaAngle;
    double ishaInterval;
    int maghribAngle;
    Madhab madhab;
    
    CalculationParameters() : fajrAngle(18.0), ishaAngle(17.0), ishaInterval(0), maghribAngle(0), madhab(Madhab::Shafi) {}
};

CalculationParameters getParameters(CalculationMethod method);

class PrayerTimes {
public:
    TimeComponents fajr;
    TimeComponents sunrise;
    TimeComponents dhuhr;
    TimeComponents asr;
    TimeComponents maghrib;
    TimeComponents isha;
    
    PrayerTimes(const Coordinates& coordinates, const DateComponents& date, const CalculationParameters& params);
};

class Astronomical {
public:
    static double julianDay(int year, int month, int day, double hours = 0);
    static double julianCentury(double jd);
    static double meanSolarLongitude(double T);
    static double meanSolarAnomaly(double T);
    static double solarEquationOfTheCenter(double T, double M);
    static double apparentSolarLongitude(double T, double L0);
    static double meanObliquityOfTheEcliptic(double T);
    static double apparentObliquityOfTheEcliptic(double T, double epsilon0);
    static double solarDeclination(double jd);
    static double equationOfTime(double jd);
};

}