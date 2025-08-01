#include "PrayerTimes.h"
#include "third_party/adhan-cpp/include/adhan/Adhan.hpp"
#include <ctime>
#include <sstream>
#include <iomanip>
#include <cstdlib> // For setenv

using namespace adhan;

namespace {

DateComponents parseDate(const std::string& dateIso) {
  int year, month, day;
  sscanf(dateIso.c_str(), "%d-%d-%d", &year, &month, &day);
  return DateComponents(year, month, day);
}

std::string formatTime(const DateComponents& date, const TimeComponents& time, const std::string& timezone) {
    // 1. Create a UTC time structure
    std::tm utc_tm = {};
    utc_tm.tm_year = date.year - 1900;
    utc_tm.tm_mon = date.month - 1;
    utc_tm.tm_mday = date.day;
    utc_tm.tm_hour = time.hours;
    utc_tm.tm_min = time.minutes;
    utc_tm.tm_sec = time.seconds;
    utc_tm.tm_isdst = 0;

    // 2. Convert UTC std::tm to time_t
    #ifdef _WIN32
        _putenv_s("TZ", "UTC");
        _tzset();
    #else
        setenv("TZ", "UTC", 1);
        tzset();
    #endif
    time_t utc_time = mktime(&utc_tm);

    // 3. Set the local timezone and convert
    #ifdef _WIN32
        _putenv_s("TZ", timezone.c_str());
        _tzset();
    #else
        setenv("TZ", timezone.c_str(), 1);
        tzset();
    #endif
    
    std::tm local_tm;
    #ifdef _WIN32
        localtime_s(&local_tm, &utc_time);
    #else
        localtime_r(&utc_time, &local_tm);
    #endif

    // 4. Format the local time to an ISO 8601 string with timezone offset
    std::ostringstream oss;
    oss << std::put_time(&local_tm, "%Y-%m-%dT%H:%M:%S%z");
    std::string result = oss.str();
    
    // std::put_time format for %z is +hhmm, but ISO 8601 prefers +hh:mm
    if (result.length() > 5) {
        result.insert(result.length() - 2, ":");
    }

    // Reset TZ to default
    #ifdef _WIN32
        _putenv_s("TZ", "");
        _tzset();
    #else
        unsetenv("TZ");
        tzset();
    #endif

    return result;
}

CalculationMethod getMethod(const std::string& methodStr) {
  if (methodStr == "ISNA") return CalculationMethod::NorthAmerica;
  if (methodStr == "MWL") return CalculationMethod::MuslimWorldLeague;
  if (methodStr == "Karachi") return CalculationMethod::Karachi;
  if (methodStr == "Egypt") return CalculationMethod::Egyptian;
  if (methodStr == "UmmAlQura") return CalculationMethod::UmmAlQura;
  if (methodStr == "Dubai") return CalculationMethod::Dubai;
  if (methodStr == "Moonsighting") return CalculationMethod::MoonsightingCommittee;
  return CalculationMethod::NorthAmerica;
}

Madhab getMadhab(const std::string& madhabStr) {
    if (madhabStr == "Hanafi") return Madhab::Hanafi;
    return Madhab::Shafi;
}

} // namespace

std::map<std::string, std::string> getPrayerTimesCpp(
  double latitude,
  double longitude,
  const std::string& dateIso,
  const std::string& methodStr,
  const std::string& timezone,
  const std::string& madhabStr
) {
  DateComponents date = parseDate(dateIso);
  Coordinates coordinates(latitude, longitude);
  CalculationParameters params = getParameters(getMethod(methodStr));
  params.madhab = getMadhab(madhabStr);

  PrayerTimes prayerTimes(coordinates, date, params);

  std::map<std::string, std::string> result;
  result["fajr"] = formatTime(date, prayerTimes.fajr, timezone);
  result["sunrise"] = formatTime(date, prayerTimes.sunrise, timezone);
  result["dhuhr"] = formatTime(date, prayerTimes.dhuhr, timezone);
  result["asr"] = formatTime(date, prayerTimes.asr, timezone);
  result["maghrib"] = formatTime(date, prayerTimes.maghrib, timezone);
  result["isha"] = formatTime(date, prayerTimes.isha, timezone);

  return result;
}