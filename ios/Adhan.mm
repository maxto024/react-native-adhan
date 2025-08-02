#import "Adhan.h"
#import <React/RCTBridgeModule.h>
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

// --- Promise-based (Async) Methods ---

RCT_EXPORT_METHOD(validateCoordinates:(NSDictionary *)coordinates
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  [impl validateCoordinates:coordinates
                   resolver:resolve
                   rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimes,
  calculatePrayerTimes:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculatePrayerTimes:coordinates
            dateComponents:dateComponents
     calculationParameters:calculationParameters
                  resolver:resolve
                  rejecter:reject];
}

RCT_REMAP_METHOD(calculateQibla,
  calculateQibla:(NSDictionary *)coordinates
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculateQibla:coordinates
              resolver:resolve
              rejecter:reject];
}

RCT_REMAP_METHOD(calculateSunnahTimes,
  calculateSunnahTimes:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl calculateSunnahTimes:coordinates
            dateComponents:dateComponents
     calculationParameters:calculationParameters
                  resolver:resolve
                  rejecter:reject];
}

RCT_REMAP_METHOD(getCurrentPrayer,
  getCurrentPrayer:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  currentTime:(nonnull NSNumber *)currentTime
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl getCurrentPrayer:coordinates
        dateComponents:dateComponents
 calculationParameters:calculationParameters
           currentTime:currentTime
              resolver:resolve
              rejecter:reject];
}

RCT_REMAP_METHOD(getTimeForPrayer,
  getTimeForPrayer:(NSDictionary *)coordinates
  dateComponents:(NSDictionary *)dateComponents
  calculationParameters:(NSDictionary *)calculationParameters
  prayer:(NSString *)prayer
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
) {
  [impl getTimeForPrayer:coordinates
        dateComponents:dateComponents
 calculationParameters:calculationParameters
                prayer:prayer
              resolver:resolve
              rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimesRange,
                 calculatePrayerTimesRange:(NSDictionary *)coordinates
                 startDate:(NSDictionary *)startDate
                 endDate:(NSDictionary *)endDate
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    // Simplified stub for now
    resolve(@[]);
}

// --- Synchronous Methods ---

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