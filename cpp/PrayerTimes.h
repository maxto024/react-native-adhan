#pragma once

#include <string>
#include <map>

std::map<std::string, std::string> getPrayerTimesCpp(
  double latitude,
  double longitude,
  const std::string& dateIso,
  const std::string& method
);