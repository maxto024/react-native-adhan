#include "Enums.h"
#include "Coordinates.h"

namespace adhan {

    HighLatitudeRule recommendedForCoordinates(const Coordinates& coordinates) {
        if (coordinates.latitude > 48.0) {
            return HighLatitudeRule::SeventhOfTheNight;
        } else {
            return HighLatitudeRule::MiddleOfTheNight;
        }
    }

} // namespace adhan
