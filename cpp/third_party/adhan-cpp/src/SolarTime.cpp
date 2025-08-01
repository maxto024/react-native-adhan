#include "../include/adhan/SolarTime.h"
#include "../include/adhan/Adhan.hpp"
#include <cmath>

namespace adhan {

    SolarTime::SolarTime(const DateComponents& date, const Coordinates& coordinates) : observer(coordinates) {
        julianDay = Astronomical::julianDay(date.year, date.month, date.day, 0);
        solarDeclination = Astronomical::solarDeclination(julianDay);
        equationOfTime = Astronomical::equationOfTime(julianDay);

        transit = 12.0 - coordinates.longitude / 15.0 - equationOfTime;
        sunrise = transit + timeForSolarAngle(-0.833, false);
        sunset = transit + timeForSolarAngle(-0.833, true);
    }

    double SolarTime::timeForSolarAngle(double angle, bool afterTransit) {
        double phi = observer.latitude;
        double delta = solarDeclination;
        double term = (sin(angle * M_PI / 180.0) - sin(phi * M_PI / 180.0) * sin(delta * M_PI / 180.0)) / (cos(phi * M_PI / 180.0) * cos(delta * M_PI / 180.0));

        if (std::abs(term) > 1.0) {
            return NAN;
        }

        double H = acos(term) * 180.0 / M_PI;
        return afterTransit ? H / 15.0 : -H / 15.0;
    }

    double SolarTime::afternoon(double shadowLength) {
        double tangent = std::abs(observer.latitude - solarDeclination);
        double inverse = shadowLength + tan(tangent * M_PI / 180.0);
        double angle = atan(1.0 / inverse) * 180.0 / M_PI;
        return timeForSolarAngle(angle, true);
    }
}