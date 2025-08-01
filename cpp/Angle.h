#ifndef ADHAN_ANGLE_H
#define ADHAN_ANGLE_H

namespace adhan {

    class Angle {
    public:
        double degrees;

        Angle(double degrees);
        static Angle fromRadians(double radians);

        double getRadians();
        Angle unwound();
        Angle quadrantShifted();
    };

    Angle operator+(const Angle& left, const Angle& right);
    Angle operator-(const Angle& left, const Angle& right);
    Angle operator*(const Angle& left, const Angle& right);
    Angle operator/(const Angle& left, const Angle& right);

}

#endif //ADHAN_ANGLE_H
