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
        
        DateComponents tomorrowDate = date;
        tomorrowDate.day++;
        SolarTime tomorrowSolarTime(tomorrowDate, coordinates);

        double fajrTime = solarTime.timeForSolarAngle(Angle(-params.fajrAngle), false);
        double sunriseTime = solarTime.sunrise;
        double dhuhrTime = solarTime.transit;
        double asrTime = solarTime.afternoon(params.madhab == Madhab::Hanafi ? 2.0 : 1.0);
        double maghribTime = solarTime.sunset;
        double ishaTime = solarTime.timeForSolarAngle(Angle(-params.ishaAngle), true);

        // Adjustments
        fajrTime += params.adjustments.fajr / 60.0;
        sunriseTime += params.adjustments.sunrise / 60.0;
        dhuhrTime += params.adjustments.dhuhr / 60.0;
        asrTime += params.adjustments.asr / 60.0;
        maghribTime += params.adjustments.maghrib / 60.0;
        ishaTime += params.adjustments.isha / 60.0;

        if (params.method == CalculationMethod::MoonsightingCommittee && coordinates.latitude >= 55) {
            double night = tomorrowSolarTime.sunrise - solarTime.sunset;
            fajrTime = sunriseTime - night / 7.0;
            ishaTime = maghribTime + night / 7.0;
        }

        double safeFajr;
        if (params.method == CalculationMethod::MoonsightingCommittee) {
            safeFajr = Astronomical::seasonAdjustedMorningTwilight(coordinates.latitude, date.day, date.year, sunriseTime);
        } else {
            double portion = params.nightPortions(coordinates).fajr;
            double night = tomorrowSolarTime.sunrise - solarTime.sunset;
            safeFajr = sunriseTime - portion * night;
        }

        if (std::isnan(fajrTime) || fajrTime > safeFajr) {
            fajrTime = safeFajr;
        }

        if (params.ishaInterval > 0) {
            ishaTime = maghribTime + params.ishaInterval / 60.0;
        } else {
            double safeIsha;
            if (params.method == CalculationMethod::MoonsightingCommittee) {
                safeIsha = Astronomical::seasonAdjustedEveningTwilight(coordinates.latitude, date.day, date.year, maghribTime, params.shafaq);
            } else {
                double portion = params.nightPortions(coordinates).isha;
                double night = tomorrowSolarTime.sunrise - solarTime.sunset;
                safeIsha = maghribTime + portion * night;
            }

            if (std::isnan(ishaTime) || ishaTime < safeIsha) {
                ishaTime = safeIsha;
            }
        }

        if (params.maghribAngle != 0) {
            double maghribAngleTime = solarTime.timeForSolarAngle(Angle(-params.maghribAngle), true);
            if (maghribAngleTime > maghribTime && (std::isnan(ishaTime) || maghribAngleTime < ishaTime)) {
                maghribTime = maghribAngleTime;
            }
        }

        this->fajr = timeFromDecimal(fajrTime);
        this->sunrise = timeFromDecimal(sunriseTime);
        this->dhuhr = timeFromDecimal(dhuhrTime);
        this->asr = timeFromDecimal(asrTime);
        this->maghrib = timeFromDecimal(maghribTime);
        this->isha = timeFromDecimal(ishaTime);
    }
}