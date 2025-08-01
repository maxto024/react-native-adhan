#include "Coordinates.h"

namespace adhan {

    Coordinates::Coordinates(double latitude, double longitude) : latitude(latitude), longitude(longitude) {}

    Angle Coordinates::getLatitudeAngle() {
        return Angle(latitude);
    }

    Angle Coordinates::getLongitudeAngle() {
        return Angle(longitude);
    }

}
