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

long long int timeToTimestamp(const DateComponents& date, const TimeComponents& time) {
    std::tm timeinfo = {};
    timeinfo.tm_year = date.year - 1900;
    timeinfo.tm_mon = date.month - 1;
    timeinfo.tm_mday = date.day;
    timeinfo.tm_hour = time.hours;
    timeinfo.tm_min = time.minutes;
    timeinfo.tm_sec = time.seconds;
    return static_cast<long long int>(timegm(&timeinfo));
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

std::map<std::string, long long int> getPrayerTimesCpp(
  double latitude,
  double longitude,
  const std::string& dateIso,
  const std::string& methodStr,
  const std::string& madhabStr
) {
  DateComponents date = parseDate(dateIso);
  Coordinates coordinates(latitude, longitude);
  CalculationParameters params = getParameters(getMethod(methodStr));
  params.madhab = getMadhab(madhabStr);

  PrayerTimes prayerTimes(coordinates, date, params);

  std::map<std::string, long long int> result;
  result["fajr"] = timeToTimestamp(date, prayerTimes.fajr);
  result["sunrise"] = timeToTimestamp(date, prayerTimes.sunrise);
  result["dhuhr"] = timeToTimestamp(date, prayerTimes.dhuhr);
  result["asr"] = timeToTimestamp(date, prayerTimes.asr);
  result["maghrib"] = timeToTimestamp(date, prayerTimes.maghrib);
  result["isha"] = timeToTimestamp(date, prayerTimes.isha);

  return result;
}