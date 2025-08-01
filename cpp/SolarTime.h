#ifndef ADHAN_SOLARTIME_H
#define ADHAN_SOLARTIME_H

#include "DateComponents.h"
#include "Coordinates.h"
#include "SolarCoordinates.h"

namespace adhan {

    class SolarTime {
    public:
        DateComponents transit;
        DateComponents sunrise;
        DateComponents sunset;

        SolarTime(DateComponents date, Coordinates coordinates);

        DateComponents timeForSolarAngle(Angle angle, bool afterTransit);
        DateComponents afternoon(double shadowLength);

    private:
        DateComponents date;
        Coordinates observer;
        SolarCoordinates solar;
        SolarCoordinates prevSolar;
        SolarCoordinates nextSolar;
        double approxTransit;
    };

}

#endif //ADHAN_SOLARTIME_H
