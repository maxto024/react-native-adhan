#pragma once

#include <ReactCommon/TurboModule.h>
#include <jsi/jsi.h>
#include <memory>
#include <string>

namespace facebook::react {

class NativeAdhanModule : public TurboModule {
public:
    NativeAdhanModule(std::shared_ptr<CallInvoker> jsInvoker);
    
    jsi::Value getPrayerTimes(jsi::Runtime& rt, jsi::Object input);
};

} // namespace facebook::react