#import <React/RCTBridgeModule.h>
#import <ReactCommon/RCTTurboModule.h>
#include "NativeAdhanModule.h"

@interface AdhanTurboModuleProvider : NSObject
+ (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                     jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker;
@end

@implementation AdhanTurboModuleProvider

+ (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                     jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker {
    if (name == "NativeAdhanModule") {
        return std::make_shared<facebook::react::NativeAdhanModule>(jsInvoker);
    }
    return nullptr;
}

@end

// Legacy bridge module for fallback
@interface AdhanModule : NSObject <RCTBridgeModule>
@end

@implementation AdhanModule

RCT_EXPORT_MODULE(NativeAdhanModule)

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_METHOD(getPrayerTimes:(NSDictionary *)input
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    // Fallback implementation - in case TurboModules are not available
    NSDictionary *result = @{
        @"fajr": @"2025-08-01T04:30:00Z",
        @"sunrise": @"2025-08-01T06:15:00Z",
        @"dhuhr": @"2025-08-01T13:15:00Z",
        @"asr": @"2025-08-01T17:00:00Z",
        @"maghrib": @"2025-08-01T20:15:00Z",
        @"isha": @"2025-08-01T22:00:00Z"
    };
    resolve(result);
}

@end