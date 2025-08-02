#import "Adhan.h"
#import <React/RCTLog.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <react_native_adhan/react_native_adhan-Swift.h>
#else
#import "react_native_adhan-Swift.h"
#endif

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

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}
#endif

// Bridge all methods to Swift implementation
RCT_REMAP_METHOD(calculatePrayerTimes,
                 coordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl calculatePrayerTimesWithCoordinates:coordinates
                               dateComponents:dateComponents
                        calculationParameters:calculationParameters
                                     resolver:resolve
                                     rejecter:reject];
}

RCT_REMAP_METHOD(calculateQibla,
                 qiblaCoordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl calculateQiblaWithCoordinates:coordinates
                               resolver:resolve
                               rejecter:reject];
}

RCT_REMAP_METHOD(calculateSunnahTimes,
                 sunnahCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl calculateSunnahTimesWithCoordinates:coordinates
                               dateComponents:dateComponents
                        calculationParameters:calculationParameters
                                     resolver:resolve
                                     rejecter:reject];
}

RCT_REMAP_METHOD(getCurrentPrayer,
                 currentPrayerCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 currentTime:(double)currentTime
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getCurrentPrayerWithCoordinates:coordinates
                           dateComponents:dateComponents
                    calculationParameters:calculationParameters
                              currentTime:currentTime
                                 resolver:resolve
                                 rejecter:reject];
}

RCT_REMAP_METHOD(getTimeForPrayer,
                 timeForPrayerCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 prayer:(NSString *)prayer
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getTimeForPrayerWithCoordinates:coordinates
                           dateComponents:dateComponents
                    calculationParameters:calculationParameters
                                   prayer:prayer
                                 resolver:resolve
                                 rejecter:reject];
}

RCT_REMAP_METHOD(validateCoordinates,
                 validateCoordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl validateCoordinatesWithCoordinates:coordinates
                                    resolver:resolve
                                    rejecter:reject];
}

RCT_REMAP_METHOD(getCalculationMethods,
                 calculationMethodsResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getCalculationMethodsWithResolver:resolve
                                   rejecter:reject];
}

RCT_REMAP_METHOD(getMethodParameters,
                 method:(NSString *)method
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getMethodParametersWithMethod:method
                               resolver:resolve
                               rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimesRange,
                 rangeCoordinates:(NSDictionary *)coordinates
                 startDate:(NSDictionary *)startDate
                 endDate:(NSDictionary *)endDate
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl calculatePrayerTimesRangeWithCoordinates:coordinates
                                         startDate:startDate
                                           endDate:endDate
                             calculationParameters:calculationParameters
                                          resolver:resolve
                                          rejecter:reject];
}

RCT_REMAP_METHOD(getLibraryInfo,
                 libraryInfoResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getLibraryInfoWithResolver:resolve
                            rejecter:reject];
}

@end