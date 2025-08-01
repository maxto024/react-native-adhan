#include "CalculationMethod.h"

namespace adhan {

    CalculationParameters getParams(CalculationMethod method) {
        switch(method) {
            case CalculationMethod::MuslimWorldLeague: {
                CalculationParameters params(18.0, 17.0, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 1, 0, 0, 0);
                return params;
            }
            case CalculationMethod::Egyptian: {
                CalculationParameters params(19.5, 17.5, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 1, 0, 0, 0);
                return params;
            }
            case CalculationMethod::Karachi: {
                CalculationParameters params(18.0, 18.0, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 1, 0, 0, 0);
                return params;
            }
            case CalculationMethod::UmmAlQura:
                return CalculationParameters(18.5, 90, method);
            case CalculationMethod::Dubai: {
                CalculationParameters params(18.2, 18.2, method);
                params.methodAdjustments = PrayerAdjustments(0, -3, 3, 3, 3, 0);
                return params;
            }
            case CalculationMethod::MoonsightingCommittee: {
                CalculationParameters params(18.0, 18.0, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 5, 0, 3, 0);
                return params;
            }
            case CalculationMethod::NorthAmerica: {
                CalculationParameters params(15.0, 15.0, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 1, 0, 0, 0);
                return params;
            }
            case CalculationMethod::Kuwait:
                return CalculationParameters(18.0, 17.5, method);
            case CalculationMethod::Qatar:
                return CalculationParameters(18.0, 90, method);
            case CalculationMethod::Singapore: {
                CalculationParameters params(20.0, 18.0, method);
                params.methodAdjustments = PrayerAdjustments(0, 0, 1, 0, 0, 0);
                params.rounding = Rounding::Up;
                return params;
            }
            case CalculationMethod::Tehran:
                return CalculationParameters(17.7, 4.5, 14.0, method);
            case CalculationMethod::Turkey: {
                CalculationParameters params(18.0, 17.0, method);
                params.methodAdjustments = PrayerAdjustments(0, -7, 5, 4, 7, 0);
                return params;
            }
            case CalculationMethod::Other:
                return CalculationParameters(0.0, 0.0, method);
        }
    }

}
