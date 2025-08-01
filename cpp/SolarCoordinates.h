#ifndef ADHAN_SOLARCOORDINATES_H
#define ADHAN_SOLARCOORDINATES_H

#include "Angle.h"

namespace adhan {

    class SolarCoordinates {
    public:
        Angle declination;
        Angle rightAscension;
        Angle apparentSiderealTime;

        SolarCoordinates(double julianDay);
    };

}

#endif //ADHAN_SOLARCOORDINATES_H
