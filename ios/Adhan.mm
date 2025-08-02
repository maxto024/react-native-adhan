#import "Adhan.h"
#import <React/RCTLog.h>

#import "Adhan-Swift.h"

@implementation Adhan {
    AdhanImpl *impl;
}

RCT_EXPORT_MODULE()

- (instancetype)init {
    if (self = [super init]) {
        impl = [[AdhanImpl alloc] init];
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

#if RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}
#endif

// --- Now update all your method mappings:

RCT_REMAP_METHOD(validateCoordinates,
  validateCoordinatesWithCoordinates:(NSDictionary *)coordinates
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl validateCoordinatesWithCoordinates:coordinates
                              resolver:resolve
                              rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimes,
  calculatePrayerTimesWithCoordinates:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculatePrayerTimesWithCoordinates:coordinates
                             dateComponents:dateComponents
                      calculationParameters:calculationParameters
                                  resolver:resolve
                                  rejecter:reject];
}

RCT_REMAP_METHOD(calculateQibla,
  calculateQiblaWithCoordinates:(NSDictionary *)coordinates
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculateQiblaWithCoordinates:coordinates
                             resolver:resolve
                             rejecter:reject];
}

RCT_REMAP_METHOD(calculateSunnahTimes,
  calculateSunnahTimesWithCoordinates:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculateSunnahTimesWithCoordinates:coordinates
                              dateComponents:dateComponents
                       calculationParameters:calculationParameters
                                   resolver:resolve
                                   rejecter:reject];
}

RCT_REMAP_METHOD(getCurrentPrayer,
  getCurrentPrayerWithCoordinates:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  currentTime:(nonnull NSNumber *)currentTime
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl getCurrentPrayerWithCoordinates:coordinates
                         dateComponents:dateComponents
                  calculationParameters:calculationParameters
                            currentTime:currentTime
                              resolver:resolve
                              rejecter:reject];
}

RCT_REMAP_METHOD(getTimeForPrayer,
  getTimeForPrayerWithCoordinates:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  prayer:(NSString *)prayer
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl getTimeForPrayerWithCoordinates:coordinates
                         dateComponents:dateComponents
                  calculationParameters:calculationParameters
                                prayer:prayer
                              resolver:resolve
                              rejecter:reject];
}

// Sync exports:
RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSArray *, getCalculationMethods) {
  return [impl getCalculationMethods];
}
RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getMethodParameters:(NSString *)method) {
  return [impl getMethodParameters:method];
}
RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getLibraryInfo) {
  return [impl getLibraryInfo];
}

@end
