#ifndef ADHAN_ASTRONOMICAL_H
#define ADHAN_ASTRONOMICAL_H

#include "Angle.h"
#include "Coordinates.h"
#include "DateComponents.h"
#include "Enums.h"
#include <ctime>

namespace adhan {

    class Astronomical {
    public:
        static double meanSolarLongitude(double T);
        static double meanLunarLongitude(double T);
        static double ascendingLunarNodeLongitude(double T);
        static double meanSolarAnomaly(double T);
        static double solarEquationOfTheCenter(double T, double M);
        static double apparentSolarLongitude(double T, double L0);
        static double meanObliquityOfTheEcliptic(double T);
        static double apparentObliquityOfTheEcliptic(double T, double epsilon0);
        static double meanSiderealTime(double T);
        static double nutationInLongitude(double L0, double Lp, double Omega);
        static double nutationInObliquity(double L0, double Lp, double Omega);
        static double altitudeOfCelestialBody(double phi, double delta, double H);
        static double approximateTransit(double L, double Theta0, double alpha2);
        static double correctedTransit(double m0, double L, double Theta0, double alpha2, double alpha1, double alpha3);
        static double correctedHourAngle(double m0, double h0, Coordinates coordinates, bool afterTransit, double Theta0,
                                         double alpha2, double alpha1, double alpha3,
                                         double delta2, double delta1, double delta3);
        static double interpolate(double y2, double y1, double y3, double n);
        static Angle interpolateAngles(Angle y2, Angle y1, Angle y3, double n);
        static double julianDay(int year, int month, int day, double hours = 0);
        static double julianDay(const DateComponents& dateComponents);
        static double julianCentury(double JD);
        static bool isLeapYear(int year);
        static time_t seasonAdjustedMorningTwilight(double latitude, int day, int year, time_t sunrise);
        static time_t seasonAdjustedEveningTwilight(double latitude, int day, int year, time_t sunset, Shafaq shafaq);
        static int daysSinceSolstice(int dayOfYear, int year, double latitude);
    };

}

#endif //ADHAN_ASTRONOMICAL_H
