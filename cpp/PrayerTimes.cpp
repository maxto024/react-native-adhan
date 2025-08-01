#include "PrayerTimes.h"
#include "SolarTime.h"
#include "Astronomical.h"
#include <cmath>

namespace adhan {
    
    time_t date_components_to_time_t(const DateComponents& components) {
        tm temp_tm = {0};
        temp_tm.tm_year = components.year - 1900;
        temp_tm.tm_mon = components.month - 1;
        temp_tm.tm_mday = components.day;
        temp_tm.tm_hour = components.hour;
        temp_tm.tm_min = components.minute;
        temp_tm.tm_sec = components.second;
        temp_tm.tm_isdst = -1;
        return mktime(&temp_tm);
    }

    PrayerTimes::PrayerTimes(Coordinates coordinates, DateComponents date, CalculationParameters params)
    : coordinates(coordinates), date(date), params(params)
    {
        tm prayer_date = {0};
        prayer_date.tm_year = date.year - 1900;
        prayer_date.tm_mon = date.month - 1;
        prayer_date.tm_mday = date.day;
        prayer_date.tm_isdst = -1;
        
        SolarTime solarTime(date, coordinates);
        
        time_t sunrise_time = date_components_to_time_t(solarTime.sunrise);
        time_t sunset_time = date_components_to_time_t(solarTime.sunset);
        
        DateComponents tomorrow_date(date.year, date.month, date.day + 1);
        SolarTime tomorrowSolar(tomorrow_date, coordinates);
        time_t tomorrow_sunrise = date_components_to_time_t(tomorrowSolar.sunrise);

        double night = difftime(tomorrow_sunrise, sunset_time);

        fajr = date_components_to_time_t(solarTime.timeForSolarAngle(Angle(-params.fajrAngle), false));

        if (params.method == CalculationMethod::MoonsightingCommittee && coordinates.latitude >= 55) {
            fajr = sunrise_time - (night / 7.0);
        }

        time_t safeFajr;
        if (params.method == CalculationMethod::MoonsightingCommittee) {
            safeFajr = Astronomical::seasonAdjustedMorningTwilight(coordinates.latitude, prayer_date.tm_yday + 1, date.year, sunrise_time);
        } else {
            NightPortions portions = params.nightPortions(coordinates);
            safeFajr = sunrise_time - (portions.fajr * night);
        }

        if (fajr < safeFajr) {
            fajr = safeFajr;
        }

        if (params.ishaInterval > 0) {
            isha = sunset_time + (params.ishaInterval * 60);
        } else {
            isha = date_components_to_time_t(solarTime.timeForSolarAngle(Angle(-params.ishaAngle), true));

            if (params.method == CalculationMethod::MoonsightingCommittee && coordinates.latitude >= 55) {
                isha = sunset_time + (night / 7.0);
            }

            time_t safeIsha;
            if (params.method == CalculationMethod::MoonsightingCommittee) {
                safeIsha = Astronomical::seasonAdjustedEveningTwilight(coordinates.latitude, prayer_date.tm_yday + 1, date.year, sunset_time, params.shafaq);
            } else {
                NightPortions portions = params.nightPortions(coordinates);
                safeIsha = sunset_time + (portions.isha * night);
            }

            if (isha > safeIsha) {
                isha = safeIsha;
            }
        }
        
        dhuhr = date_components_to_time_t(solarTime.transit);
        asr = date_components_to_time_t(solarTime.afternoon(static_cast<double>(params.madhab)));
        sunrise = sunrise_time;
        maghrib = sunset_time;
        
        if (params.maghribAngle != 0) {
            time_t maghrib_time = date_components_to_time_t(solarTime.timeForSolarAngle(Angle(-params.maghribAngle), true));
            if (maghrib_time > sunset_time && maghrib_time < isha) {
                maghrib = maghrib_time;
            }
        }
        
        fajr += params.adjustments.fajr * 60;
        sunrise += params.adjustments.sunrise * 60;
        dhuhr += params.adjustments.dhuhr * 60;
        asr += params.adjustments.asr * 60;
        maghrib += params.adjustments.maghrib * 60;
        isha += params.adjustments.isha * 60;
    }

    Prayer PrayerTimes::currentPrayer(time_t time) {
        if (time == 0) {
            time = std::time(0);
        }

        if (isha <= time) {
            return Prayer::Isha;
        } else if (maghrib <= time) {
            return Prayer::Maghrib;
        } else if (asr <= time) {
            return Prayer::Asr;
        } else if (dhuhr <= time) {
            return Prayer::Dhuhr;
        } else if (sunrise <= time) {
            return Prayer::Sunrise;
        } else if (fajr <= time) {
            return Prayer::Fajr;
        } else {
            return Prayer::Fajr;
        }
    }

    Prayer PrayerTimes::nextPrayer(time_t time) {
        if (time == 0) {
            time = std::time(0);
        }

        if (isha <= time) {
            return Prayer::Fajr;
        } else if (maghrib <= time) {
            return Prayer::Isha;
        } else if (asr <= time) {
            return Prayer::Maghrib;
        } else if (dhuhr <= time) {
            return Prayer::Asr;
        } else if (sunrise <= time) {
            return Prayer::Dhuhr;
        } else if (fajr <= time) {
            return Prayer::Sunrise;
        } else {
            return Prayer::Fajr;
        }
    }

    time_t PrayerTimes::timeForPrayer(Prayer prayer) {
        switch (prayer) {
            case Prayer::Fajr:
                return fajr;
            case Prayer::Sunrise:
                return sunrise;
            case Prayer::Dhuhr:
                return dhuhr;
            case Prayer::Asr:
                return asr;
            case Prayer::Maghrib:
                return maghrib;
            case Prayer::Isha:
                return isha;
        }
    }

}
