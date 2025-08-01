#ifndef QIBLA_H
#define QIBLA_H

#include "Coordinates.h"

namespace adhan {

class Qibla {
public:
    explicit Qibla(const Coordinates& coordinates);

    double getDirection() const;

private:
    double direction;
};

} // namespace adhan

#endif // QIBLA_H
