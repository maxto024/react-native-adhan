#pragma once

#include <string>
#include <map>

#include <string>
#include <map>

std::map<std::string, long long int> getPrayerTimesCpp(
  double latitude,
  double longitude,
  const std::string& dateIso,
  const std::string& methodStr,
  const std::string& madhabStr
);