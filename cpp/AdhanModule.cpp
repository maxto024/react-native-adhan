#include "Adhan.h"
#include "AdhanSpec.h"
#include <memory>
#include <ReactCommon/TurboModuleUtils.h>

#ifdef __ANDROID__
#include <fbjni/fbjni.h>
#include <ReactCommon/JavaTurboModule.h>
#include <jni.h>

extern "C" JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *) {
    return facebook::jni::initialize(vm, [] {
        facebook::react::TurboModuleManager::sharedModuleProvider() = [](const std::string &name, const facebook::react::TurboModule::InitParams &params) {
            return adhan::AdhanSpec_ModuleProvider(name, params.jsInvoker);
        };
    });
}
#endif

namespace adhan {

std::shared_ptr<facebook::react::TurboModule> AdhanSpec_ModuleProvider(const std::string &name, const std::shared_ptr<facebook::react::CallInvoker>& jsInvoker) {
    if (name == "Adhan") {
        return std::make_shared<Adhan>(jsInvoker);
    }
    return nullptr;
}

} // namespace adhan
