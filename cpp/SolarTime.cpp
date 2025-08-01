#include "SolarTime.h"
#include "Astronomical.h"
#include <cmath>

namespace adhan {

    SolarTime::SolarTime(DateComponents date, Coordinates coordinates)
    : transit(0, 0, 0), sunrise(0, 0, 0), sunset(0, 0, 0),
      date(date), observer(coordinates),
      solar(Astronomical::julianDay(date)),
      prevSolar(Astronomical::julianDay(date) - 1),
      nextSolar(Astronomical::julianDay(date) + 1),
      approxTransit(Astronomical::approximateTransit(coordinates.longitude, solar.apparentSiderealTime.degrees, solar.rightAscension.degrees))
    {
        double transitTime = Astronomical::correctedTransit(approxTransit, coordinates.longitude, solar.apparentSiderealTime.degrees,
                                                          solar.rightAscension.degrees, prevSolar.rightAscension.degrees, nextSolar.rightAscension.degrees);
        double sunriseTime = Astronomical::correctedHourAngle(approxTransit, -0.8333, coordinates, false, solar.apparentSiderealTime.degrees,
                                                          solar.rightAscension.degrees, prevSolar.rightAscension.degrees, nextSolar.rightAscension.degrees,
                                                          solar.declination.degrees, prevSolar.declination.degrees, nextSolar.declination.degrees);
        double sunsetTime = Astronomical::correctedHourAngle(approxTransit, -0.8333, coordinates, true, solar.apparentSiderealTime.degrees,
                                                         solar.rightAscension.degrees, prevSolar.rightAscension.degrees, nextSolar.rightAscension.degrees,
                                                         solar.declination.degrees, prevSolar.declination.degrees, nextSolar.declination.degrees);

        int hour, minute, second;

        hour = static_cast<int>(floor(transitTime));
        minute = static_cast<int>(floor((transitTime - hour) * 60.0));
        second = static_cast<int>(floor((transitTime - (hour + minute / 60.0)) * 3600.0));
        transit = DateComponents(date.year, date.month, date.day);

        hour = static_cast<int>(floor(sunriseTime));
        minute = static_cast<int>(floor((sunriseTime - hour) * 60.0));
        second = static_cast<int>(floor((sunriseTime - (hour + minute / 60.0)) * 3600.0));
        sunrise = DateComponents(date.year, date.month, date.day);

        hour = static_cast<int>(floor(sunsetTime));
        minute = static_cast<int>(floor((sunsetTime - hour) * 60.0));
        second = static_cast<int>(floor((sunsetTime - (hour + minute / 60.0)) * 3600.0));
        sunset = DateComponents(date.year, date.month, date.day);
    }

    DateComponents SolarTime::timeForSolarAngle(Angle angle, bool afterTransit) {
        double hours = Astronomical::correctedHourAngle(approxTransit, angle.degrees, observer, afterTransit, solar.apparentSiderealTime.degrees,
                                                      solar.rightAscension.degrees, prevSolar.rightAscension.degrees, nextSolar.rightAscension.degrees,
                                                      solar.declination.degrees, prevSolar.declination.degrees, nextSolar.declination.degrees);
        int hour, minute, second;
        hour = static_cast<int>(floor(hours));
        minute = static_cast<int>(floor((hours - hour) * 60.0));
        second = static_cast<int>(floor((hours - (hour + minute / 60.0)) * 3600.0));
        return DateComponents(date.year, date.month, date.day);
    }

    DateComponents SolarTime::afternoon(double shadowLength) {
        double tangent = std::abs(observer.latitude - solar.declination.degrees);
        double inverse = shadowLength + tan(Angle(tangent).getRadians());
        Angle angle = Angle::fromRadians(atan(1.0 / inverse));
        return timeForSolarAngle(angle, true);
    }

}
