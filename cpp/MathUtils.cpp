#include "MathUtils.h"
#include <cmath>

namespace adhan {
namespace math_utils {

double normalizeToScale(double value, double max) {
    return value - (max * std::floor(value / max));
}

} // namespace math_utils
} // namespace adhan
