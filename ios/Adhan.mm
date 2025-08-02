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

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}
#endif

// MARK: - TurboModule Method Implementations

RCT_REMAP_METHOD(calculatePrayerTimes,
                 calculatePrayerTimesWithCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSDictionary *result = [impl calculatePrayerTimesWithCoordinates:coordinates
                                                      dateComponents:dateComponents
                                               calculationParameters:calculationParameters];
    
    if (result) {
        resolve(result);
    } else {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
    }
}

RCT_REMAP_METHOD(calculateQibla,
                 calculateQiblaWithCoordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSDictionary *result = [impl calculateQiblaWithCoordinates:coordinates];
    
    if (result) {
        resolve(result);
    } else {
        reject(@"INVALID_COORDINATES", @"Latitude and longitude are required.", nil);
    }
}

RCT_REMAP_METHOD(calculateSunnahTimes,
                 calculateSunnahTimesWithCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSDictionary *result = [impl calculateSunnahTimesWithCoordinates:coordinates
                                                        dateComponents:dateComponents
                                                 calculationParameters:calculationParameters];
    
    if (result) {
        resolve(result);
    } else {
        reject(@"CALCULATION_ERROR", @"Failed to calculate sunnah times.", nil);
    }
}

RCT_REMAP_METHOD(getCurrentPrayer,
                 getCurrentPrayerWithCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 currentTime:(double)currentTime
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSDictionary *result = [impl getCurrentPrayerWithCoordinates:coordinates
                                                 dateComponents:dateComponents
                                          calculationParameters:calculationParameters
                                                    currentTime:currentTime];
    
    if (result) {
        resolve(result);
    } else {
        reject(@"CALCULATION_ERROR", @"Failed to calculate current prayer.", nil);
    }
}

RCT_REMAP_METHOD(getTimeForPrayer,
                 getTimeForPrayerWithCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 prayer:(NSString *)prayer
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSNumber *result = [impl getTimeForPrayerWithCoordinates:coordinates
                                                dateComponents:dateComponents
                                         calculationParameters:calculationParameters
                                                        prayer:prayer];
    
    if (result) {
        resolve(result);
    } else {
        reject(@"INVALID_PRAYER", @"Invalid prayer name or calculation failed.", nil);
    }
}

RCT_EXPORT_METHOD(validateCoordinates:(NSDictionary *)coordinates
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [impl validateCoordinates:coordinates resolver:resolve rejecter:reject];
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSArray *, getCalculationMethods) {
    return [impl getCalculationMethods];
}

RCT_REMAP_METHOD(getMethodParameters,
                 getMethodParametersWithMethod:(NSString *)method
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    [impl getMethodParameters:method resolver:resolve rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimesRange,
                 calculatePrayerTimesRangeWithCoordinates:(NSDictionary *)coordinates
                 startDate:(NSDictionary *)startDate
                 endDate:(NSDictionary *)endDate
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    
    // Simplified implementation - just return empty array for now
    resolve(@[]);
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getLibraryInfo) {
    return [impl getLibraryInfo];
}

@end