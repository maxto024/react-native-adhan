#ifndef ADHAN_COORDINATES_H
#define ADHAN_COORDINATES_H

#include "Angle.h"

namespace adhan {

    class Coordinates {
    public:
        double latitude;
        double longitude;

        Coordinates(double latitude, double longitude);

        Angle getLatitudeAngle();
        Angle getLongitudeAngle();
    };

}

#endif //ADHAN_COORDINATES_H
