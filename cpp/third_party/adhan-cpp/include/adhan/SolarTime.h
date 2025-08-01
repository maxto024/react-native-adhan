#pragma once

namespace adhan {
    struct DateComponents;
    struct Coordinates;

    class SolarTime {
    public:
        SolarTime(const DateComponents& date, const Coordinates& coordinates);

        double timeForSolarAngle(double angle, bool afterTransit);
        double afternoon(double shadowLength);

        double transit;
        double sunrise;
        double sunset;

    private:
        double julianDay;
        const Coordinates& observer;
        double solarDeclination;
        double equationOfTime;
    };
}