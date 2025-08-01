#ifndef ADHAN_DATECOMPONENTS_H
#define ADHAN_DATECOMPONENTS_H

namespace adhan {

    struct DateComponents {
        int year;
        int month;
        int day;
        int hour;
        int minute;
        int second;

        DateComponents(int year, int month, int day, int hour = 0, int minute = 0, int second = 0);
    };

}

#endif //ADHAN_DATECOMPONENTS_H
