#ifndef ADHAN_CALCULATIONPARAMETERS_H
#define ADHAN_CALCULATIONPARAMETERS_H

#include "Enums.h"
#include "PrayerAdjustments.h"
#include "Coordinates.h"

namespace adhan {

    struct NightPortions {
        double fajr;
        double isha;
    };

    class CalculationParameters {
    public:
        CalculationMethod method;
        double fajrAngle;
        double maghribAngle;
        double ishaAngle;
        int ishaInterval;
        Madhab madhab;
        HighLatitudeRule highLatitudeRule;
        PrayerAdjustments adjustments;
        Rounding rounding;
        Shafaq shafaq;
        PrayerAdjustments methodAdjustments;

        CalculationParameters(double fajrAngle, double ishaAngle);
        CalculationParameters(double fajrAngle, int ishaInterval);
        CalculationParameters(double fajrAngle, double ishaAngle, CalculationMethod method);
        CalculationParameters(double fajrAngle, int ishaInterval, CalculationMethod method);
        CalculationParameters(double fajrAngle, double maghribAngle, double ishaAngle, CalculationMethod method);

        NightPortions nightPortions(Coordinates coordinates);
    };

}

#endif //ADHAN_CALCULATIONPARAMETERS_H
