#include "../include/adhan/Adhan.hpp"
#include "../include/adhan/SolarTime.h"
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

    TimeComponents timeFromDecimal(double decimal) {
        if (std::isnan(decimal)) {
            return TimeComponents(0, 0, 0);
        }
        int hours = static_cast<int>(floor(decimal));
        int minutes = static_cast<int>(floor((decimal - hours) * 60));
        int seconds = static_cast<int>(round(((decimal - hours) * 60 - minutes) * 60));

        if (seconds >= 60) {
            seconds -= 60;
            minutes++;
        }
        if (minutes >= 60) {
            minutes -= 60;
            hours++;
        }
        return TimeComponents(hours, minutes, seconds);
    }

    PrayerTimes::PrayerTimes(const Coordinates& coordinates, const DateComponents& date, const CalculationParameters& params)
        : fajr(0, 0, 0), sunrise(0, 0, 0), dhuhr(0, 0, 0), asr(0, 0, 0), maghrib(0, 0, 0), isha(0, 0, 0) {

        SolarTime solarTime(date, coordinates);
        
        double asrTime = solarTime.transit + solarTime.afternoon(params.madhab == Madhab::Hanafi ? 2.0 : 1.0);
        double maghribTime = solarTime.sunset;
        
        double fajrTime = solarTime.transit + solarTime.timeForSolarAngle(-params.fajrAngle, false);
        double ishaTime = solarTime.transit + solarTime.timeForSolarAngle(-params.ishaAngle, true);

        // Safe Fajr
        double safeFajr = solarTime.sunrise - (20.0 / 60.0);
        if (fajrTime > safeFajr) {
            fajrTime = safeFajr;
        }

        // Safe Isha
        if (params.ishaInterval > 0) {
            ishaTime = maghribTime + params.ishaInterval / 60.0;
        } else {
            double safeIsha = solarTime.sunset + (20.0 / 60.0);
            if (ishaTime < safeIsha) {
                ishaTime = safeIsha;
            }
        }

        this->fajr = timeFromDecimal(fajrTime);
        this->sunrise = timeFromDecimal(solarTime.sunrise);
        this->dhuhr = timeFromDecimal(solarTime.transit);
        this->asr = timeFromDecimal(asrTime);
        this->maghrib = timeFromDecimal(maghribTime);
        this->isha = timeFromDecimal(ishaTime);
    }
}