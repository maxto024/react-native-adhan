#ifndef ADHAN_ENUMS_H
#define ADHAN_ENUMS_H

namespace adhan {

    enum class Prayer {
        Fajr,
        Sunrise,
        Dhuhr,
        Asr,
        Maghrib,
        Isha
    };

    enum class Madhab {
        Shafi = 1,
        Hanafi = 2
    };

    enum class Rounding {
        Nearest,
        Up,
        None
    };

    enum class CalculationMethod {
        MuslimWorldLeague,
        Egyptian,
        Karachi,
        UmmAlQura,
        Dubai,
        MoonsightingCommittee,
        NorthAmerica,
        Kuwait,
        Qatar,
        Singapore,
        Tehran,
        Turkey,
        Other
    };

    enum class HighLatitudeRule {
        MiddleOfTheNight,
        SeventhOfTheNight,
        TwilightAngle
    };

    enum class Shafaq {
        General,
        Ahmer,
        Abyad
    };

}

#endif //ADHAN_ENUMS_H