#include "AdhanCalculations.h"
#include <iomanip>
#include <sstream>
#include <ctime>

namespace Adhan {

// Utility function to normalize values
double normalizeToScale(double value, double scale) {
    double normalized = fmod(value, scale);
    return normalized < 0 ? normalized + scale : normalized;
}

// DateComponents implementation
DateComponents DateComponents::settingHour(double hours) const {
    int h = static_cast<int>(hours);
    int m = static_cast<int>((hours - h) * 60);
    int s = static_cast<int>(((hours - h) * 60 - m) * 60);
    
    return DateComponents(year, month, day, h, m, s);
}

double DateComponents::julianDay() const {
    return Astronomical::julianDay(*this);
}

// SolarCoordinates implementation
SolarCoordinates::SolarCoordinates(double julianDay) {
    double T = Astronomical::julianCentury(julianDay);
    Angle L0 = Astronomical::meanSolarLongitude(T);
    Angle Lp = Astronomical::meanLunarLongitude(T);
    Angle Ω = Astronomical::ascendingLunarNodeLongitude(T);
    double λ = Astronomical::apparentSolarLongitude(T, L0).radians();
    
    Angle θ0 = Astronomical::meanSiderealTime(T);
    double ΔΨ = Astronomical::nutationInLongitude(L0, Lp, Ω);
    double Δε = Astronomical::nutationInObliquity(L0, Lp, Ω);
    
    Angle ε0 = Astronomical::meanObliquityOfTheEcliptic(T);
    double εapp = Astronomical::apparentObliquityOfTheEcliptic(T, ε0).radians();
    
    // Equation from Astronomical Algorithms page 165
    declination = Angle(asin(sin(εapp) * sin(λ)) * 180.0 / M_PI);
    
    // Equation from Astronomical Algorithms page 165  
    rightAscension = Angle(atan2(cos(εapp) * sin(λ), cos(λ)) * 180.0 / M_PI).unwound();
    
    // Equation from Astronomical Algorithms page 88
    apparentSiderealTime = Angle(θ0.degrees() + (((ΔΨ * 3600) * cos(Angle(ε0.degrees() + Δε).radians())) / 3600));
}

// Astronomical calculations following Jean Meeus algorithms
Angle Astronomical::meanSolarLongitude(double T) {
    // Equation from Astronomical Algorithms page 163
    double term1 = 280.4664567;
    double term2 = 36000.76983 * T;
    double term3 = 0.0003032 * T * T;
    double L0 = term1 + term2 + term3;
    return Angle(L0).unwound();
}

Angle Astronomical::meanLunarLongitude(double T) {
    // Equation from Astronomical Algorithms page 144
    double term1 = 218.3165;
    double term2 = 481267.8813 * T;
    double Lp = term1 + term2;
    return Angle(Lp).unwound();
}

Angle Astronomical::ascendingLunarNodeLongitude(double T) {
    // Equation from Astronomical Algorithms page 144
    double term1 = 125.04452;
    double term2 = 1934.136261 * T;
    double term3 = 0.0020708 * T * T;
    double term4 = (T * T * T) / 450000;
    double Ω = term1 - term2 + term3 + term4;
    return Angle(Ω).unwound();
}

Angle Astronomical::meanSolarAnomaly(double T) {
    // Equation from Astronomical Algorithms page 163
    double term1 = 357.52911;
    double term2 = 35999.05029 * T;
    double term3 = 0.0001537 * T * T;
    double M = term1 + term2 - term3;
    return Angle(M).unwound();
}

Angle Astronomical::solarEquationOfTheCenter(double T, const Angle& M) {
    // Equation from Astronomical Algorithms page 164
    double Mrad = M.radians();
    double term1 = (1.914602 - (0.004817 * T) - (0.000014 * T * T)) * sin(Mrad);
    double term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad);
    double term3 = 0.000289 * sin(3 * Mrad);
    return Angle(term1 + term2 + term3);
}

Angle Astronomical::apparentSolarLongitude(double T, const Angle& L0) {
    // Equation from Astronomical Algorithms page 164
    Angle longitude = L0 + solarEquationOfTheCenter(T, meanSolarAnomaly(T));
    Angle Ω = Angle(125.04 - (1934.136 * T));
    double λ = longitude.degrees() - 0.00569 - (0.00478 * sin(Ω.radians()));
    return Angle(λ).unwound();
}

Angle Astronomical::meanObliquityOfTheEcliptic(double T) {
    // Equation from Astronomical Algorithms page 147
    double term1 = 23.439291;
    double term2 = 0.013004167 * T;
    double term3 = 0.0000001639 * T * T;
    double term4 = 0.0000005036 * T * T * T;
    return Angle(term1 - term2 - term3 + term4);
}

Angle Astronomical::apparentObliquityOfTheEcliptic(double T, const Angle& ε0) {
    // Equation from Astronomical Algorithms page 165
    double O = 125.04 - (1934.136 * T);
    return Angle(ε0.degrees() + (0.00256 * cos(Angle(O).radians())));
}

Angle Astronomical::meanSiderealTime(double T) {
    // Equation from Astronomical Algorithms page 165
    double JD = (T * 36525) + 2451545.0;
    double term1 = 280.46061837;
    double term2 = 360.98564736629 * (JD - 2451545);
    double term3 = 0.000387933 * T * T;
    double term4 = (T * T * T) / 38710000;
    double θ = term1 + term2 + term3 - term4;
    return Angle(θ).unwound();
}

double Astronomical::nutationInLongitude(const Angle& L0, const Angle& Lp, const Angle& Ω) {
    // Equation from Astronomical Algorithms page 144
    double term1 = (-17.2/3600) * sin(Ω.radians());
    double term2 = (1.32/3600) * sin(2 * L0.radians());
    double term3 = (0.23/3600) * sin(2 * Lp.radians());
    double term4 = (0.21/3600) * sin(2 * Ω.radians());
    return term1 - term2 - term3 + term4;
}

double Astronomical::nutationInObliquity(const Angle& L0, const Angle& Lp, const Angle& Ω) {
    // Equation from Astronomical Algorithms page 144
    double term1 = (9.2/3600) * cos(Ω.radians());
    double term2 = (0.57/3600) * cos(2 * L0.radians());
    double term3 = (0.10/3600) * cos(2 * Lp.radians());
    double term4 = (0.09/3600) * cos(2 * Ω.radians());
    return term1 + term2 + term3 - term4;
}

Angle Astronomical::altitudeOfCelestialBody(const Angle& φ, const Angle& δ, const Angle& H) {
    // Equation from Astronomical Algorithms page 93
    double term1 = sin(φ.radians()) * sin(δ.radians());
    double term2 = cos(φ.radians()) * cos(δ.radians()) * cos(H.radians());
    return Angle(asin(term1 + term2) * 180.0 / M_PI);
}

double Astronomical::approximateTransit(const Angle& L, const Angle& Θ0, const Angle& α2) {
    // Equation from Astronomical Algorithms page 102
    Angle Lw = L * -1;
    double result = ((α2 + Lw - Θ0) / Angle(360)).degrees();
    return normalizeToScale(result, 1.0);
}

double Astronomical::correctedTransit(double m0, const Angle& L, const Angle& Θ0,
                                    const Angle& α2, const Angle& α1, const Angle& α3) {
    // Equation from Astronomical Algorithms page 102
    Angle Lw = L * -1;
    Angle θ = Angle(Θ0.degrees() + (360.985647 * m0)).unwound();
    Angle α = interpolateAngles(α2, α1, α3, m0).unwound();
    Angle H = (θ - Lw - α).quadrantShifted();
    Angle Δm = H / Angle(-360);
    return (m0 + Δm.degrees()) * 24;
}

double Astronomical::correctedHourAngle(double m0, const Angle& h0, const Coordinates& coordinates, bool afterTransit,
                                      const Angle& Θ0, const Angle& α2, const Angle& α1, const Angle& α3,
                                      const Angle& δ2, const Angle& δ1, const Angle& δ3) {
    // Equation from Astronomical Algorithms page 102
    Angle Lw = coordinates.longitudeAngle() * Angle(-1);
    double term1 = sin(h0.radians()) - (sin(coordinates.latitudeAngle().radians()) * sin(δ2.radians()));
    double term2 = cos(coordinates.latitudeAngle().radians()) * cos(δ2.radians());
    Angle H0 = Angle(acos(term1 / term2) * 180.0 / M_PI);
    double m = afterTransit ? m0 + (H0.degrees() / 360) : m0 - (H0.degrees() / 360);
    Angle θ = Angle(Θ0.degrees() + (360.985647 * m)).unwound();
    Angle α = interpolateAngles(α2, α1, α3, m).unwound();
    Angle δ = Angle(interpolate(δ2.degrees(), δ1.degrees(), δ3.degrees(), m));
    Angle H = θ - Lw - α;
    Angle h = altitudeOfCelestialBody(coordinates.latitudeAngle(), δ, H);
    double term3 = (h - h0).degrees();
    double term4 = 360 * cos(δ.radians()) * cos(coordinates.latitudeAngle().radians()) * sin(H.radians());
    double Δm = term3 / term4;
    return (m + Δm) * 24;
}

double Astronomical::interpolate(double y2, double y1, double y3, double n) {
    // Equation from Astronomical Algorithms page 24
    double a = y2 - y1;
    double b = y3 - y2;
    double c = b - a;
    return y2 + ((n/2) * (a + b + (n * c)));
}

Angle Astronomical::interpolateAngles(const Angle& y2, const Angle& y1, const Angle& y3, double n) {
    // Equation from Astronomical Algorithms page 24
    Angle a = (y2 - y1).unwound();
    Angle b = (y3 - y2).unwound();
    Angle c = b - a;
    return Angle(y2.degrees() + ((n/2) * (a.degrees() + b.degrees() + (n * c.degrees()))));
}

double Astronomical::julianDay(int year, int month, int day, double hours) {
    // Equation from Astronomical Algorithms page 60
    int Y = month > 2 ? year : year - 1;
    int M = month > 2 ? month : month + 12;
    double D = static_cast<double>(day) + (hours / 24);
    
    int A = Y/100;
    int B = 2 - A + (A/4);
    
    int i0 = static_cast<int>(365.25 * (static_cast<double>(Y) + 4716));
    int i1 = static_cast<int>(30.6001 * (static_cast<double>(M) + 1));
    return static_cast<double>(i0) + static_cast<double>(i1) + D + static_cast<double>(B) - 1524.5;
}

double Astronomical::julianDay(const DateComponents& date) {
    double hour = static_cast<double>(date.hour);
    double minute = static_cast<double>(date.minute);
    return julianDay(date.year, date.month, date.day, hour + (minute / 60));
}

double Astronomical::julianCentury(double JD) {
    // Equation from Astronomical Algorithms page 163
    return (JD - 2451545.0) / 36525;
}

bool Astronomical::isLeapYear(int year) {
    if (year % 4 != 0) {
        return false;
    }
    if (year % 100 == 0 && year % 400 != 0) {
        return false;
    }
    return true;
}

// SolarTime implementation
SolarTime::SolarTime(const DateComponents& date, const Coordinates& coordinates)
    : date(date), observer(coordinates), 
      solar(Astronomical::julianDay(date)),
      prevSolar(Astronomical::julianDay(date) - 1),
      nextSolar(Astronomical::julianDay(date) + 1) {
    
    approxTransit = Astronomical::approximateTransit(coordinates.longitudeAngle(), 
                                                   solar.apparentSiderealTime, 
                                                   solar.rightAscension);
    
    Angle solarAltitude = Angle(-50.0 / 60.0); // Atmospheric refraction
    
    double transitTime = Astronomical::correctedTransit(approxTransit, coordinates.longitudeAngle(), 
                                                      solar.apparentSiderealTime, solar.rightAscension, 
                                                      prevSolar.rightAscension, nextSolar.rightAscension);
    
    double sunriseTime = Astronomical::correctedHourAngle(approxTransit, solarAltitude, coordinates, false,
                                                        solar.apparentSiderealTime, solar.rightAscension,
                                                        prevSolar.rightAscension, nextSolar.rightAscension,
                                                        solar.declination, prevSolar.declination, nextSolar.declination);
    
    double sunsetTime = Astronomical::correctedHourAngle(approxTransit, solarAltitude, coordinates, true,
                                                       solar.apparentSiderealTime, solar.rightAscension,
                                                       prevSolar.rightAscension, nextSolar.rightAscension,
                                                       solar.declination, prevSolar.declination, nextSolar.declination);
    
    transit = date.settingHour(transitTime);
    sunrise = date.settingHour(sunriseTime);
    sunset = date.settingHour(sunsetTime);
}

DateComponents SolarTime::timeForSolarAngle(const Angle& angle, bool afterTransit) const {
    double hours = Astronomical::correctedHourAngle(approxTransit, angle, observer, afterTransit,
                                                  solar.apparentSiderealTime, solar.rightAscension,
                                                  prevSolar.rightAscension, nextSolar.rightAscension,
                                                  solar.declination, prevSolar.declination, nextSolar.declination);
    return date.settingHour(hours);
}

DateComponents SolarTime::afternoon(double shadowLength) const {
    // Calculate Asr time based on shadow length
    Angle tangent = Angle(fabs(observer.latitude - solar.declination.degrees()));
    double inverse = shadowLength + tan(tangent.radians());
    Angle angle = Angle(atan(1.0 / inverse) * 180.0 / M_PI);
    
    return timeForSolarAngle(angle, true);
}

// CalculationParameters implementation with exact adhan-swift defaults
CalculationParameters CalculationParameters::forMethod(CalculationMethod method) {
    CalculationParameters params;
    params.method = method;
    params.madhab = Madhab::SHAFI; // Default: Shafi (shadow length = 1.0)
    params.ishaInterval = 0;
    params.maghribAngle = 0;
    
    // Initialize all adjustments to 0
    params.adjustments["fajr"] = 0;
    params.adjustments["sunrise"] = 0;
    params.adjustments["dhuhr"] = 0;
    params.adjustments["asr"] = 0;
    params.adjustments["maghrib"] = 0;
    params.adjustments["isha"] = 0;
    
    // Initialize method adjustments to 0
    params.methodAdjustments["fajr"] = 0;
    params.methodAdjustments["sunrise"] = 0;
    params.methodAdjustments["dhuhr"] = 0;
    params.methodAdjustments["asr"] = 0;
    params.methodAdjustments["maghrib"] = 0;
    params.methodAdjustments["isha"] = 0;
    
    switch (method) {
        case CalculationMethod::MUSLIM_WORLD_LEAGUE:
            params.fajrAngle = 18.0;
            params.ishaAngle = 17.0;
            // Method adjustment: dhuhr +1 minute
            params.methodAdjustments["dhuhr"] = 1;
            break;
            
        case CalculationMethod::EGYPTIAN:
            params.fajrAngle = 19.5;
            params.ishaAngle = 17.5;
            // Method adjustment: dhuhr +1 minute
            params.methodAdjustments["dhuhr"] = 1;
            break;
            
        case CalculationMethod::KARACHI:
            params.fajrAngle = 18.0;
            params.ishaAngle = 18.0;
            // Method adjustment: dhuhr +1 minute
            params.methodAdjustments["dhuhr"] = 1;
            break;
            
        case CalculationMethod::UMM_AL_QURA:
            params.fajrAngle = 18.5;
            params.ishaInterval = 90.0; // 90 minutes after maghrib
            // No method adjustments for UmmAlQura
            break;
            
        case CalculationMethod::DUBAI:
            params.fajrAngle = 18.2;
            params.ishaAngle = 18.2;
            // Method adjustments: sunrise -3, dhuhr +3, asr +3, maghrib +3
            params.methodAdjustments["sunrise"] = -3;
            params.methodAdjustments["dhuhr"] = 3;
            params.methodAdjustments["asr"] = 3;
            params.methodAdjustments["maghrib"] = 3;
            break;
            
        case CalculationMethod::MOON_SIGHTING_COMMITTEE:
            params.fajrAngle = 18.0;
            params.ishaAngle = 18.0;
            // Method adjustments: dhuhr +5, maghrib +3
            params.methodAdjustments["dhuhr"] = 5;
            params.methodAdjustments["maghrib"] = 3;
            break;
            
        case CalculationMethod::NORTH_AMERICA: // ISNA
            params.fajrAngle = 15.0;
            params.ishaAngle = 15.0;
            // Method adjustment: dhuhr +1 minute
            params.methodAdjustments["dhuhr"] = 1;
            break;
            
        case CalculationMethod::KUWAIT:
            params.fajrAngle = 18.0;
            params.ishaAngle = 17.5;
            // No method adjustments for Kuwait
            break;
            
        case CalculationMethod::QATAR:
            params.fajrAngle = 18.0;
            params.ishaInterval = 90.0; // 90 minutes after maghrib
            // No method adjustments for Qatar
            break;
            
        case CalculationMethod::SINGAPORE:
            params.fajrAngle = 20.0;
            params.ishaAngle = 18.0;
            // Method adjustment: dhuhr +1 minute
            // Note: Singapore also uses rounding = up, but we'll handle that separately
            params.methodAdjustments["dhuhr"] = 1;
            break;
            
        case CalculationMethod::TEHRAN:
            params.fajrAngle = 17.7;
            params.ishaAngle = 14.0;
            params.maghribAngle = 4.5; // Tehran uses maghrib angle of 4.5°
            // No method adjustments for Tehran
            break;
            
        case CalculationMethod::TURKEY:
            params.fajrAngle = 18.0;
            params.ishaAngle = 17.0;
            // Method adjustments: fajr +0, sunrise -7, dhuhr +5, asr +4, maghrib +7, isha +0
            params.methodAdjustments["fajr"] = 0;
            params.methodAdjustments["sunrise"] = -7;
            params.methodAdjustments["dhuhr"] = 5;
            params.methodAdjustments["asr"] = 4;
            params.methodAdjustments["maghrib"] = 7;
            params.methodAdjustments["isha"] = 0;
            break;
    }
    
    return params;
}

// PrayerTimes implementation
PrayerTimes PrayerTimes::calculate(const Coordinates& coordinates, const DateComponents& date, const CalculationParameters& params) {
    SolarTime solarTime(date, coordinates);
    
    PrayerTimes times;
    times.sunrise = solarTime.sunrise;
    times.dhuhr = solarTime.transit;
    times.maghrib = solarTime.sunset;
    
    // Calculate Fajr
    times.fajr = solarTime.timeForSolarAngle(Angle(-params.fajrAngle), false);
    
    // Calculate Asr based on Madhab
    times.asr = solarTime.afternoon(params.shadowLength());
    
    // Calculate Isha
    if (params.ishaInterval > 0) {
        // Use interval method (minutes after maghrib)
        double ishaHours = times.maghrib.hour + times.maghrib.minute / 60.0 + params.ishaInterval / 60.0;
        times.isha = date.settingHour(ishaHours);
    } else {
        // Use angle method
        times.isha = solarTime.timeForSolarAngle(Angle(-params.ishaAngle), true);
    }
    
    return times;
}

// Utility functions
std::string formatDateComponents(const DateComponents& date, const std::string& timezone) {
    std::ostringstream oss;
    oss << std::setfill('0');
    oss << std::setw(4) << date.year << "-"
        << std::setw(2) << date.month << "-"
        << std::setw(2) << date.day << "T"
        << std::setw(2) << date.hour << ":"
        << std::setw(2) << date.minute << ":"
        << std::setw(2) << date.second;
    
    if (!timezone.empty() && timezone != "UTC") {
        oss << timezone;
    } else {
        oss << "Z";
    }
    
    return oss.str();
}

DateComponents parseDate(const std::string& dateIso) {
    // Parse ISO date string "YYYY-MM-DD"
    int year, month, day;
    if (sscanf(dateIso.c_str(), "%d-%d-%d", &year, &month, &day) == 3) {
        return DateComponents(year, month, day);
    }
    
    // Default to current date if parsing fails
    time_t now = time(0);
    tm* ltm = localtime(&now);
    return DateComponents(1900 + ltm->tm_year, 1 + ltm->tm_mon, ltm->tm_mday);
}

CalculationParameters parseMethod(const std::string& methodName) {
    if (methodName == "MWL") return CalculationParameters::forMethod(CalculationMethod::MUSLIM_WORLD_LEAGUE);
    if (methodName == "Egyptian") return CalculationParameters::forMethod(CalculationMethod::EGYPTIAN);
    if (methodName == "Karachi") return CalculationParameters::forMethod(CalculationMethod::KARACHI);
    if (methodName == "UmmAlQura") return CalculationParameters::forMethod(CalculationMethod::UMM_AL_QURA);
    if (methodName == "Dubai") return CalculationParameters::forMethod(CalculationMethod::DUBAI);
    if (methodName == "MoonsightingCommittee") return CalculationParameters::forMethod(CalculationMethod::MOON_SIGHTING_COMMITTEE);
    if (methodName == "ISNA") return CalculationParameters::forMethod(CalculationMethod::NORTH_AMERICA);
    if (methodName == "Kuwait") return CalculationParameters::forMethod(CalculationMethod::KUWAIT);
    if (methodName == "Qatar") return CalculationParameters::forMethod(CalculationMethod::QATAR);
    if (methodName == "Singapore") return CalculationParameters::forMethod(CalculationMethod::SINGAPORE);
    if (methodName == "Tehran") return CalculationParameters::forMethod(CalculationMethod::TEHRAN);
    if (methodName == "Turkey") return CalculationParameters::forMethod(CalculationMethod::TURKEY);
    
    // Default to Muslim World League
    return CalculationParameters::forMethod(CalculationMethod::MUSLIM_WORLD_LEAGUE);
}

Madhab parseMadhab(const std::string& madhabName) {
    if (madhabName == "Hanafi") return Madhab::HANAFI;
    return Madhab::SHAFI; // Default
}

} // namespace Adhan