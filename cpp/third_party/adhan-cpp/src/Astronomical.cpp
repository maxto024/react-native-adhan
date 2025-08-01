#include "../include/adhan/Adhan.hpp"
#include <cmath>

namespace adhan {

    double Astronomical::julianDay(int year, int month, int day, double hours) {
        if (month <= 2) {
            year -= 1;
            month += 12;
        }
        double A = floor(year / 100.0);
        double B = 2 - A + floor(A / 4.0);
        return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + (hours / 24.0) + B - 1524.5;
    }

    double Astronomical::julianCentury(double jd) {
        return (jd - 2451545.0) / 36525.0;
    }

    double Astronomical::meanSolarLongitude(double T) {
        double term1 = 280.4664567;
        double term2 = 36000.76983 * T;
        double term3 = 0.0003032 * pow(T, 2);
        double L0 = term1 + term2 + term3;
        return fmod(L0, 360.0);
    }

    double Astronomical::meanSolarAnomaly(double T) {
        double term1 = 357.52911;
        double term2 = 35999.05029 * T;
        double term3 = 0.0001537 * pow(T, 2);
        double M = term1 + term2 - term3;
        return fmod(M, 360.0);
    }

    double Astronomical::solarEquationOfTheCenter(double T, double M) {
        double Mrad = M * M_PI / 180.0;
        double term1 = (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(Mrad);
        double term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad);
        double term3 = 0.000289 * sin(3 * Mrad);
        return term1 + term2 + term3;
    }

    double Astronomical::apparentSolarLongitude(double T, double L0) {
        double longitude = L0 + solarEquationOfTheCenter(T, meanSolarAnomaly(T));
        double omega = 125.04 - 1934.136 * T;
        double lambda = longitude - 0.00569 - 0.00478 * sin(omega * M_PI / 180.0);
        return fmod(lambda, 360.0);
    }

    double Astronomical::meanObliquityOfTheEcliptic(double T) {
        double term1 = 23.439291;
        double term2 = 0.013004167 * T;
        double term3 = 0.0000001639 * pow(T, 2);
        double term4 = 0.0000005036 * pow(T, 3);
        return term1 - term2 - term3 + term4;
    }

    double Astronomical::apparentObliquityOfTheEcliptic(double T, double epsilon0) {
        double O = 125.04 - 1934.136 * T;
        return epsilon0 + 0.00256 * cos(O * M_PI / 180.0);
    }

    double Astronomical::solarDeclination(double jd) {
        double T = julianCentury(jd);
        double L0 = meanSolarLongitude(T);
        double lambda = apparentSolarLongitude(T, L0);
        double epsilon0 = meanObliquityOfTheEcliptic(T);
        double epsilon = apparentObliquityOfTheEcliptic(T, epsilon0);
        double delta = asin(sin(epsilon * M_PI / 180.0) * sin(lambda * M_PI / 180.0)) * 180.0 / M_PI;
        return delta;
    }

    double Astronomical::equationOfTime(double jd) {
        double T = julianCentury(jd);
        double L0 = meanSolarLongitude(T);
        double M = meanSolarAnomaly(T);
        double e = 0.016708634 - T * (0.000042037 + 0.0000001267 * T);
        double epsilon = meanObliquityOfTheEcliptic(T);
        double y = tan(epsilon * M_PI / 360.0);
        y *= y;

        double Etime = y * sin(2 * L0 * M_PI / 180.0) - 2 * e * sin(M * M_PI / 180.0) + 4 * e * y * sin(M * M_PI / 180.0) * cos(2 * L0 * M_PI / 180.0) - 0.5 * y * y * sin(4 * L0 * M_PI / 180.0) - 1.25 * e * e * sin(2 * M * M_PI / 180.0);
        return Etime * 180.0 / M_PI / 15.0;
    }
}