#include "Astronomical.h"
#include <cmath>

namespace adhan {

    double Astronomical::meanSolarLongitude(double T) {
        double term1 = 280.4664567;
        double term2 = 36000.76983 * T;
        double term3 = 0.0003032 * pow(T, 2);
        double L0 = term1 + term2 + term3;
        return fmod(L0, 360.0);
    }

    double Astronomical::meanLunarLongitude(double T) {
        double term1 = 218.3165;
        double term2 = 481267.8813 * T;
        double Lp = term1 + term2;
        return fmod(Lp, 360.0);
    }

    double Astronomical::ascendingLunarNodeLongitude(double T) {
        double term1 = 125.04452;
        double term2 = 1934.136261 * T;
        double term3 = 0.0020708 * pow(T, 2);
        double term4 = pow(T, 3) / 450000.0;
        double Omega = term1 - term2 + term3 + term4;
        return fmod(Omega, 360.0);
    }

    double Astronomical::meanSolarAnomaly(double T) {
        double term1 = 357.52911;
        double term2 = 35999.05029 * T;
        double term3 = 0.0001537 * pow(T, 2);
        double M = term1 + term2 - term3;
        return fmod(M, 360.0);
    }

    double Astronomical::solarEquationOfTheCenter(double T, double M) {
        double Mrad = Angle(M).getRadians();
        double term1 = (1.914602 - (0.004817 * T) - (0.000014 * pow(T, 2))) * sin(Mrad);
        double term2 = (0.019993 - (0.000101 * T)) * sin(2 * Mrad);
        double term3 = 0.000289 * sin(3 * Mrad);
        return term1 + term2 + term3;
    }

    double Astronomical::apparentSolarLongitude(double T, double L0) {
        double longitude = L0 + solarEquationOfTheCenter(T, meanSolarAnomaly(T));
        double Omega = 125.04 - (1934.136 * T);
        double lambda = longitude - 0.00569 - (0.00478 * sin(Angle(Omega).getRadians()));
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
        double O = 125.04 - (1934.136 * T);
        return epsilon0 + (0.00256 * cos(Angle(O).getRadians()));
    }

    double Astronomical::meanSiderealTime(double T) {
        double JD = (T * 36525.0) + 2451545.0;
        double term1 = 280.46061837;
        double term2 = 360.98564736629 * (JD - 2451545.0);
        double term3 = 0.000387933 * pow(T, 2);
        double term4 = pow(T, 3) / 38710000.0;
        double theta = term1 + term2 + term3 - term4;
        return fmod(theta, 360.0);
    }

    double Astronomical::nutationInLongitude(double L0, double Lp, double Omega) {
        double term1 = (-17.2/3600.0) * sin(Angle(Omega).getRadians());
        double term2 =  (1.32/3600.0) * sin(2 * Angle(L0).getRadians());
        double term3 =  (0.23/3600.0) * sin(2 * Angle(Lp).getRadians());
        double term4 =  (0.21/3600.0) * sin(2 * Angle(Omega).getRadians());
        return term1 - term2 - term3 + term4;
    }

    double Astronomical::nutationInObliquity(double L0, double Lp, double Omega) {
        double term1 =  (9.2/3600.0) * cos(Angle(Omega).getRadians());
        double term2 = (0.57/3600.0) * cos(2 * Angle(L0).getRadians());
        double term3 = (0.10/3600.0) * cos(2 * Angle(Lp).getRadians());
        double term4 = (0.09/3600.0) * cos(2 * Angle(Omega).getRadians());
        return term1 + term2 + term3 - term4;
    }

    double Astronomical::altitudeOfCelestialBody(double phi, double delta, double H) {
        double term1 = sin(Angle(phi).getRadians()) * sin(Angle(delta).getRadians());
        double term2 = cos(Angle(phi).getRadians()) * cos(Angle(delta).getRadians()) * cos(Angle(H).getRadians());
        return Angle::fromRadians(asin(term1 + term2)).degrees;
    }

    double Astronomical::approximateTransit(double L, double Theta0, double alpha2) {
        double Lw = L * -1.0;
        double result = (alpha2 + Lw - Theta0) / 360.0;
        if (result < 0) {
            result += 1;
        }
        return result;
    }

    double Astronomical::correctedTransit(double m0, double L, double Theta0, double alpha2, double alpha1, double alpha3) {
        double Lw = L * -1.0;
        double theta = fmod(Theta0 + (360.985647 * m0), 360.0);
        double alpha = fmod(interpolate(alpha2, alpha1, alpha3, m0), 360.0);
        double H = Angle(theta - Lw - alpha).quadrantShifted().degrees;
        double deltaM = H / -360.0;
        return (m0 + deltaM) * 24.0;
    }

    double Astronomical::correctedHourAngle(double m0, double h0, Coordinates coordinates, bool afterTransit, double Theta0,
                                          double alpha2, double alpha1, double alpha3,
                                          double delta2, double delta1, double delta3) {
        double Lw = coordinates.longitude * -1.0;
        double term1 = sin(Angle(h0).getRadians()) - (sin(Angle(coordinates.latitude).getRadians()) * sin(Angle(delta2).getRadians()));
        double term2 = cos(Angle(coordinates.latitude).getRadians()) * cos(Angle(delta2).getRadians());
        double H0 = Angle::fromRadians(acos(term1 / term2)).degrees;
        double m = afterTransit ? m0 + (H0 / 360.0) : m0 - (H0 / 360.0);
        double theta = fmod(Theta0 + (360.985647 * m), 360.0);
        double alpha = fmod(interpolate(alpha2, alpha1, alpha3, m), 360.0);
        double delta = interpolate(delta2, delta1, delta3, m);
        double H = (theta - Lw - alpha);
        double h = altitudeOfCelestialBody(coordinates.latitude, delta, H);
        double term3 = (h - h0);
        double term4 = 360.0 * cos(Angle(delta).getRadians()) * cos(Angle(coordinates.latitude).getRadians()) * sin(Angle(H).getRadians());
        double deltaM = term3 / term4;
        return (m + deltaM) * 24.0;
    }

    double Astronomical::interpolate(double y2, double y1, double y3, double n) {
        double a = y2 - y1;
        double b = y3 - y2;
        double c = b - a;
        return y2 + ((n/2.0) * (a + b + (n * c)));
    }

    Angle Astronomical::interpolateAngles(Angle y2, Angle y1, Angle y3, double n) {
        Angle a = (y2 - y1).unwound();
        Angle b = (y3 - y2).unwound();
        Angle c = b - a;
        return Angle(y2.degrees + ((n/2.0) * (a.degrees + b.degrees + (n * c.degrees))));
    }

    double Astronomical::julianDay(int year, int month, int day, double hours) {
        int Y = month > 2 ? year : year - 1;
        int M = month > 2 ? month : month + 12;
        double D = static_cast<double>(day) + (hours / 24.0);

        int A = Y/100;
        int B = 2 - A + (A/4);

        int i0 = static_cast<int>(365.25 * (static_cast<double>(Y) + 4716.0));
        int i1 = static_cast<int>(30.6001 * (static_cast<double>(M) + 1.0));
        return static_cast<double>(i0) + static_cast<double>(i1) + D + static_cast<double>(B) - 1524.5;
    }

    double Astronomical::julianDay(const DateComponents& dateComponents) {
        return julianDay(dateComponents.year, dateComponents.month, dateComponents.day);
    }

    double Astronomical::julianCentury(double JD) {
        return (JD - 2451545.0) / 36525.0;
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

    time_t Astronomical::seasonAdjustedMorningTwilight(double latitude, int day, int year, time_t sunrise) {
        double a = 75.0 + ((28.65 / 55.0) * std::abs(latitude));
        double b = 75.0 + ((19.44 / 55.0) * std::abs(latitude));
        double c = 75.0 + ((32.74 / 55.0) * std::abs(latitude));
        double d = 75.0 + ((48.10 / 55.0) * std::abs(latitude));

        double dyy = static_cast<double>(daysSinceSolstice(day, year, latitude));
        double adjustment;
        if ( dyy < 91) {
            adjustment = a + ( b - a ) / 91.0 * dyy;
        } else if ( dyy < 137) {
            adjustment = b + ( c - b ) / 46.0 * ( dyy - 91.0 );
        } else if ( dyy < 183 ) {
            adjustment = c + ( d - c ) / 46.0 * ( dyy - 137.0 );
        } else if ( dyy < 229 ) {
            adjustment = d + ( c - d ) / 46.0 * ( dyy - 183.0 );
        } else if ( dyy < 275 ) {
            adjustment = c + ( b - c ) / 46.0 * ( dyy - 229.0 );
        } else {
            adjustment = b + ( a - b ) / 91.0 * ( dyy - 275.0 );
        }

        return sunrise - static_cast<time_t>(round(adjustment * 60.0));
    }

    time_t Astronomical::seasonAdjustedEveningTwilight(double latitude, int day, int year, time_t sunset, Shafaq shafaq) {
        double a, b, c, d;

        switch (shafaq) {
            case Shafaq::General:
                a = 75.0 + ((25.60 / 55.0) * std::abs(latitude));
                b = 75.0 + ((2.050 / 55.0) * std::abs(latitude));
                c = 75.0 - ((9.210 / 55.0) * std::abs(latitude));
                d = 75.0 + ((6.140 / 55.0) * std::abs(latitude));
                break;
            case Shafaq::Ahmer:
                a = 62.0 + ((17.40 / 55.0) * std::abs(latitude));
                b = 62.0 - ((7.160 / 55.0) * std::abs(latitude));
                c = 62.0 + ((5.120 / 55.0) * std::abs(latitude));
                d = 62.0 + ((19.44 / 55.0) * std::abs(latitude));
                break;
            case Shafaq::Abyad:
                a = 75.0 + ((25.60 / 55.0) * std::abs(latitude));
                b = 75.0 + ((7.160 / 55.0) * std::abs(latitude));
                c = 75.0 + ((36.84 / 55.0) * std::abs(latitude));
                d = 75.0 + ((81.84 / 55.0) * std::abs(latitude));
                break;
        }

        double dyy = static_cast<double>(daysSinceSolstice(day, year, latitude));
        double adjustment;
        if ( dyy < 91) {
            adjustment = a + ( b - a ) / 91.0 * dyy;
        } else if ( dyy < 137) {
            adjustment = b + ( c - b ) / 46.0 * ( dyy - 91.0 );
        } else if ( dyy < 183 ) {
            adjustment = c + ( d - c ) / 46.0 * ( dyy - 137.0 );
        } else if ( dyy < 229 ) {
            adjustment = d + ( c - d ) / 46.0 * ( dyy - 183.0 );
        } else if ( dyy < 275 ) {
            adjustment = c + ( b - c ) / 46.0 * ( dyy - 229.0 );
        } else {
            adjustment = b + ( a - b ) / 91.0 * ( dyy - 275.0 );
        }

        return sunset + static_cast<time_t>(round(adjustment * 60.0));
    }

    int Astronomical::daysSinceSolstice(int dayOfYear, int year, double latitude) {
        int daysSinceSolstice = 0;
        int northernOffset = 10;
        int southernOffset = isLeapYear(year) ? 173 : 172;
        int daysInYear = isLeapYear(year) ? 366 : 365;

        if (latitude >= 0) {
            daysSinceSolstice = dayOfYear + northernOffset;
            if (daysSinceSolstice >= daysInYear) {
                daysSinceSolstice = daysSinceSolstice - daysInYear;
            }
        } else {
            daysSinceSolstice = dayOfYear - southernOffset;
            if (daysSinceSolstice < 0) {
                daysSinceSolstice = daysSinceSolstice + daysInYear;
            }
        }

        return daysSinceSolstice;
    }

}
