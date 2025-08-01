#ifndef SUNNAH_TIMES_H
#define SUNNAH_TIMES_H

#include "PrayerTimes.h"
#include <ctime>

namespace adhan {

class SunnahTimes {
public:
    explicit SunnahTimes(const PrayerTimes& prayerTimes);

    time_t middleOfTheNight;
    time_t lastThirdOfTheNight;
};

} // namespace adhan

#endif // SUNNAH_TIMES_H
