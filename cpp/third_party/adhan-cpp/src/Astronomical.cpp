#include "../include/adhan/Adhan.hpp"
#include <cmath>

namespace adhan {

double Astronomical::meanSolarLongitude(double julianDay) {
    double T = (julianDay - 2451545.0) / 36525.0;
    double L0 = fmod(280.46646 + T * (36000.76983 + T * 0.0003032), 360.0);
    return L0;
}

double Astronomical::apparentSolarLongitude(double julianDay) {
    double L = meanSolarLongitude(julianDay);
    double omega = 125.04 - 1934.136 * (julianDay - 2451545.0) / 36525.0;
    double lambda = L - 0.00569 - 0.00478 * sin(omega * M_PI / 180.0);
    return lambda;
}

double Astronomical::meanLunarLongitude(double julianDay) {
    double T = (julianDay - 2451545.0) / 36525.0;
    double Lp = fmod(218.3165 + T * (481267.8813 + T * (-0.0015 + T * (1.0/538841.0 + T * (-1.0/65194000.0)))), 360.0);
    return Lp;
}

double Astronomical::solarDeclination(double julianDay) {
    double lambda = apparentSolarLongitude(julianDay);
    double epsilon0 = 23.0 + (26.0 + (21.448 - 46.815 * (julianDay - 2451545.0) / 36525.0) / 60.0) / 60.0;
    double epsilon = epsilon0 + 0.00256 * cos((125.04 - 1934.136 * (julianDay - 2451545.0) / 36525.0) * M_PI / 180.0);
    double delta = asin(sin(epsilon * M_PI / 180.0) * sin(lambda * M_PI / 180.0)) * 180.0 / M_PI;
    return delta;
}

double Astronomical::correctedHourAngle(double latitude, double declination, double angle) {
    double H = acos((sin(angle * M_PI / 180.0) - sin(latitude * M_PI / 180.0) * sin(declination * M_PI / 180.0)) / 
                   (cos(latitude * M_PI / 180.0) * cos(declination * M_PI / 180.0))) * 180.0 / M_PI;
    return H;
}

}