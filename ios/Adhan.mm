#import "Adhan.h"
#import <React/RCTBridge.h>
#import <React/RCTUtils.h>
#include <ReactCommon/RCTTurboModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <AdhanSpec/AdhanSpec.h>
#endif

// Forward declare Swift class - will be resolved at runtime
@class AdhanModule;

@interface Adhan ()

@property (nonatomic, strong) AdhanModule *module;

@end

@implementation Adhan

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Use runtime class lookup to find the Swift class
        Class AdhanModuleClass = NSClassFromString(@"AdhanModule");
        if (AdhanModuleClass) {
            self.module = [[AdhanModuleClass alloc] init];
        } else {
            NSLog(@"Error: AdhanModule Swift class not found");
        }
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_REMAP_METHOD(calculatePrayerTimes,
                 coordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module calculatePrayerTimes:coordinates
                       dateComponents:dateComponents
                calculationParameters:calculationParameters
                             resolver:resolve
                             rejecter:reject];
}

RCT_REMAP_METHOD(calculateQibla,
                 qiblaCoordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module calculateQibla:coordinates
                       resolver:resolve
                       rejecter:reject];
}

RCT_REMAP_METHOD(calculateSunnahTimes,
                 sunnahCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module calculateSunnahTimes:coordinates
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
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module getCurrentPrayer:coordinates
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
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module getTimeForPrayer:coordinates
                   dateComponents:dateComponents
            calculationParameters:calculationParameters
                           prayer:prayer
                         resolver:resolve
                         rejecter:reject];
}

RCT_REMAP_METHOD(validateCoordinates,
                 validateCoordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module validateCoordinates:coordinates
                            resolver:resolve
                            rejecter:reject];
}

RCT_REMAP_METHOD(getCalculationMethods,
                 calculationMethodsResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module getCalculationMethods:resolve
                              rejecter:reject];
}

RCT_REMAP_METHOD(getMethodParameters,
                 method:(NSString *)method
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module getMethodParameters:method
                            resolver:resolve
                            rejecter:reject];
}

RCT_REMAP_METHOD(calculatePrayerTimesRange,
                 rangeCoordinates:(NSDictionary *)coordinates
                 startDate:(NSDictionary *)startDate
                 endDate:(NSDictionary *)endDate
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module calculatePrayerTimesRange:coordinates
                                 startDate:startDate
                                   endDate:endDate
                     calculationParameters:calculationParameters
                                  resolver:resolve
                                  rejecter:reject];
}

RCT_REMAP_METHOD(getLibraryInfo,
                 libraryInfoResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.module getLibraryInfo:resolve
                       rejecter:reject];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}

@end