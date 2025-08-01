#include "Qibla.h"
#include "Angle.h"
#include <cmath>

namespace adhan {

Qibla::Qibla(const Coordinates& coordinates) {
    const Coordinates makkah(21.4225241, 39.8261818);

    double term1 = std::sin(Angle(makkah.longitude).getRadians() - Angle(coordinates.longitude).getRadians());
    double term2 = std::cos(Angle(coordinates.latitude).getRadians()) * std::tan(Angle(makkah.latitude).getRadians());
    double term3 = std::sin(Angle(coordinates.latitude).getRadians()) * std::cos(Angle(makkah.longitude).getRadians() - Angle(coordinates.longitude).getRadians());

    direction = Angle::fromRadians(std::atan2(term1, term2 - term3)).unwound().degrees;
}

double Qibla::getDirection() const {
    return direction;
}

} // namespace adhan
