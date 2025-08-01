#ifndef ADHAN_PRAYERADJUSTMENTS_H
#define ADHAN_PRAYERADJUSTMENTS_H

namespace adhan {

    struct PrayerAdjustments {
        int fajr;
        int sunrise;
        int dhuhr;
        int asr;
        int maghrib;
        int isha;

        PrayerAdjustments(int fajr = 0, int sunrise = 0, int dhuhr = 0, int asr = 0, int maghrib = 0, int isha = 0);
    };

}

#endif //ADHAN_PRAYERADJUSTMENTS_H
