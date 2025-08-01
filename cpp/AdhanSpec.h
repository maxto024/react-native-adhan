#pragma once

#include <ReactCommon/TurboModule.h>
#include <jsi/jsi.h>
#include <string>

namespace adhan {

class JSI_EXPORT AdhanSpec : public facebook::react::TurboModule {
public:
  AdhanSpec(std::shared_ptr<facebook::react::CallInvoker> jsInvoker)
      : facebook::react::TurboModule("Adhan", jsInvoker) {}

  virtual facebook::jsi::Value getPrayerTimes(
      facebook::jsi::Runtime& rt,
      const facebook::jsi::Object& input) = 0;
};

// Factory function to be implemented by the module
std::shared_ptr<facebook::react::TurboModule> AdhanSpec_ModuleProvider(
    const std::string& name,
    const std::shared_ptr<facebook::react::CallInvoker>& jsInvoker);

} // namespace adhan