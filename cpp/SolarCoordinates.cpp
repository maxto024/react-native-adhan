#include "SolarCoordinates.h"
#include "Astronomical.h"
#include <cmath>

namespace adhan {

    SolarCoordinates::SolarCoordinates(double julianDay)
    : declination(0.0), rightAscension(0.0), apparentSiderealTime(0.0)
    {
        double T = Astronomical::julianCentury(julianDay);
        double L0 = Astronomical::meanSolarLongitude(T);
        double Lp = Astronomical::meanLunarLongitude(T);
        double Omega = Astronomical::ascendingLunarNodeLongitude(T);
        double lambda = Angle::fromRadians(Astronomical::apparentSolarLongitude(T, L0)).getRadians();

        double theta0 = Astronomical::meanSiderealTime(T);
        double deltaPsi = Astronomical::nutationInLongitude(L0, Lp, Omega);
        double deltaEpsilon = Astronomical::nutationInObliquity(L0, Lp, Omega);

        double epsilon0 = Astronomical::meanObliquityOfTheEcliptic(T);
        double epsilonApp = Angle::fromRadians(Astronomical::apparentObliquityOfTheEcliptic(T, epsilon0)).getRadians();

        declination = Angle::fromRadians(asin(sin(epsilonApp) * sin(lambda)));
        rightAscension = Angle::fromRadians(atan2(cos(epsilonApp) * sin(lambda), cos(lambda))).unwound();
        apparentSiderealTime = Angle(theta0 + (((deltaPsi * 3600) * cos(Angle(epsilon0 + deltaEpsilon).getRadians())) / 3600));
    }

}
