#include "PrayerTimes.h"
#include "third_party/adhan-cpp/include/adhan/Adhan.hpp"
#include <ctime>
#include <sstream>
#include <iomanip>

using namespace adhan;

namespace {

DateComponents parseDate(const std::string& dateIso) {
  int year, month, day;
  sscanf(dateIso.c_str(), "%d-%d-%d", &year, &month, &day);
  return DateComponents(year, month, day);
}

std::string formatTime(const DateComponents& date, const TimeComponents& time) {
  std::ostringstream oss;
  std::tm t = {};
  t.tm_year = date.year - 1900;
  t.tm_mon = date.month - 1;
  t.tm_mday = date.day;
  t.tm_hour = time.hours;
  t.tm_min = time.minutes;
  t.tm_sec = time.seconds;
  oss << std::put_time(&t, "%Y-%m-%dT%H:%M:%S");
  return oss.str();
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

} // namespace

std::map<std::string, std::string> getPrayerTimesCpp(
  double latitude,
  double longitude,
  const std::string& dateIso,
  const std::string& methodStr
) {
  DateComponents date = parseDate(dateIso);
  Coordinates coordinates(latitude, longitude);
  CalculationParameters params = getParameters(getMethod(methodStr));
  params.madhab = Madhab::Shafi;

  PrayerTimes prayerTimes(coordinates, date, params);

  std::map<std::string, std::string> result;
  result["fajr"] = formatTime(date, prayerTimes.fajr);
  result["sunrise"] = formatTime(date, prayerTimes.sunrise);
  result["dhuhr"] = formatTime(date, prayerTimes.dhuhr);
  result["asr"] = formatTime(date, prayerTimes.asr);
  result["maghrib"] = formatTime(date, prayerTimes.maghrib);
  result["isha"] = formatTime(date, prayerTimes.isha);

  return result;
}