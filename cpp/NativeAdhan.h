#ifndef NATIVE_ADHAN_H
#define NATIVE_ADHAN_H

// This file is kept for backward compatibility
// The actual implementation has been moved to AdhanSpec.h

#include "AdhanSpec.h"

namespace adhan {
// For backward compatibility, alias AdhanSpec as NativeAdhan
using NativeAdhan = AdhanSpec;
} // namespace adhan

#endif // NATIVE_ADHAN_H