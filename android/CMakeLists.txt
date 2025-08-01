cmake_minimum_required(VERSION 3.18)
project(Adhan)

add_library(adhan SHARED
  ../cpp/NativeAdhanModule.cpp
  ../cpp/Adhan.cpp
  ../cpp/AdhanJNI.cpp
  ../cpp/Angle.cpp
  ../cpp/Astronomical.cpp
  ../cpp/CalculationMethod.cpp
  ../cpp/CalculationParameters.cpp
  ../cpp/Coordinates.cpp
  ../cpp/DateComponents.cpp
  ../cpp/HighLatitudeRule.cpp
  ../cpp/MathUtils.cpp
  ../cpp/PrayerAdjustments.cpp
  ../cpp/PrayerTimes.cpp
  ../cpp/Qibla.cpp
  ../cpp/SolarCoordinates.cpp
  ../cpp/SolarTime.cpp
)

target_include_directories(adhan PUBLIC
  ../cpp
)

target_link_libraries(adhan
  android
  log
)
