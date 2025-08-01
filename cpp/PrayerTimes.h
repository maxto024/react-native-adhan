#ifndef ADHAN_PRAYERTIMES_H
#define ADHAN_PRAYERTIMES_H

#include "Coordinates.h"
#include "DateComponents.h"
#include "CalculationParameters.h"
#include "Enums.h"
#include <ctime>

namespace adhan {

    class PrayerTimes {
    public:
        time_t fajr;
        time_t sunrise;
        time_t dhuhr;
        time_t asr;
        time_t maghrib;
        time_t isha;

        PrayerTimes(Coordinates coordinates, DateComponents date, CalculationParameters params);

        Prayer currentPrayer(time_t time = 0);
        Prayer nextPrayer(time_t time = 0);
        time_t timeForPrayer(Prayer prayer);
    
    private:
        Coordinates coordinates;
        DateComponents date;
        CalculationParameters params;
    };

}

#endif //ADHAN_PRAYERTIMES_H
