#ifndef ADHAN_MODULE_H
#define ADHAN_MODULE_H

#include "AdhanSpec.h"

namespace adhan {

class Adhan : public AdhanSpec {
public:
    Adhan(std::shared_ptr<facebook::react::CallInvoker> jsInvoker);

    facebook::jsi::Value getPrayerTimes(
        facebook::jsi::Runtime& rt,
        const facebook::jsi::Object& input
    ) override;
};

} // namespace adhan

#endif // ADHAN_MODULE_H
