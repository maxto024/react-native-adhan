#include "CalculationParameters.h"

namespace adhan {

    CalculationParameters::CalculationParameters(double fajrAngle, double ishaAngle)
    : method(CalculationMethod::Other), fajrAngle(fajrAngle), maghribAngle(0.0), ishaAngle(ishaAngle), ishaInterval(0), madhab(Madhab::Shafi), highLatitudeRule(HighLatitudeRule::MiddleOfTheNight), rounding(Rounding::Nearest), shafaq(Shafaq::General) {}

    CalculationParameters::CalculationParameters(double fajrAngle, int ishaInterval)
    : method(CalculationMethod::Other), fajrAngle(fajrAngle), maghribAngle(0.0), ishaAngle(0.0), ishaInterval(ishaInterval), madhab(Madhab::Shafi), highLatitudeRule(HighLatitudeRule::MiddleOfTheNight), rounding(Rounding::Nearest), shafaq(Shafaq::General) {}

    CalculationParameters::CalculationParameters(double fajrAngle, double ishaAngle, CalculationMethod method)
    : method(method), fajrAngle(fajrAngle), maghribAngle(0.0), ishaAngle(ishaAngle), ishaInterval(0), madhab(Madhab::Shafi), highLatitudeRule(HighLatitudeRule::MiddleOfTheNight), rounding(Rounding::Nearest), shafaq(Shafaq::General) {}

    CalculationParameters::CalculationParameters(double fajrAngle, int ishaInterval, CalculationMethod method)
    : method(method), fajrAngle(fajrAngle), maghribAngle(0.0), ishaAngle(0.0), ishaInterval(ishaInterval), madhab(Madhab::Shafi), highLatitudeRule(HighLatitudeRule::MiddleOfTheNight), rounding(Rounding::Nearest), shafaq(Shafaq::General) {}

    CalculationParameters::CalculationParameters(double fajrAngle, double maghribAngle, double ishaAngle, CalculationMethod method)
    : method(method), fajrAngle(fajrAngle), maghribAngle(maghribAngle), ishaAngle(ishaAngle), ishaInterval(0), madhab(Madhab::Shafi), highLatitudeRule(HighLatitudeRule::MiddleOfTheNight), rounding(Rounding::Nearest), shafaq(Shafaq::General) {}

    NightPortions CalculationParameters::nightPortions(Coordinates coordinates) {
        HighLatitudeRule currentHighLatitudeRule = highLatitudeRule;

        switch (currentHighLatitudeRule) {
            case HighLatitudeRule::MiddleOfTheNight:
                return {1.0/2.0, 1.0/2.0};
            case HighLatitudeRule::SeventhOfTheNight:
                return {1.0/7.0, 1.0/7.0};
            case HighLatitudeRule::TwilightAngle:
                return {fajrAngle / 60.0, ishaAngle / 60.0};
        }
    }

}
