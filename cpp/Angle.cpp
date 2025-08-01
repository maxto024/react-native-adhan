#include "Angle.h"
#include <cmath>

namespace adhan {

    Angle::Angle(double degrees) : degrees(degrees) {}

    Angle Angle::fromRadians(double radians) {
        return Angle((radians * 180.0) / M_PI);
    }

    double Angle::getRadians() {
        return (degrees * M_PI) / 180.0;
    }

    Angle Angle::unwound() {
        return Angle(fmod(degrees, 360.0));
    }

    Angle Angle::quadrantShifted() {
        if (degrees >= -180 && degrees <= 180) {
            return *this;
        }
        return Angle(degrees - (360 * round(degrees / 360)));
    }

    Angle operator+(const Angle& left, const Angle& right) {
        return Angle(left.degrees + right.degrees);
    }

    Angle operator-(const Angle& left, const Angle& right) {
        return Angle(left.degrees - right.degrees);
    }

    Angle operator*(const Angle& left, const Angle& right) {
        return Angle(left.degrees * right.degrees);
    }

    Angle operator/(const Angle& left, const Angle& right) {
        return Angle(left.degrees / right.degrees);
    }

}
