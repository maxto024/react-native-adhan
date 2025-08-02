#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Adhan, NSObject)

RCT_EXTERN_METHOD(calculatePrayerTimes:(NSDictionary *)coordinates
                  dateComponents:(NSDictionary *)dateComponents
                  calculationParameters:(NSDictionary *)calculationParameters
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(calculateQibla:(NSDictionary *)coordinates
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(calculateSunnahTimes:(NSDictionary *)coordinates
                  dateComponents:(NSDictionary *)dateComponents
                  calculationParameters:(NSDictionary *)calculationParameters
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getCurrentPrayer:(NSDictionary *)coordinates
                  dateComponents:(NSDictionary *)dateComponents
                  calculationParameters:(NSDictionary *)calculationParameters
                  currentTime:(nonnull NSNumber *)currentTime
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getTimeForPrayer:(NSDictionary *)coordinates
                  dateComponents:(NSDictionary *)dateComponents
                  calculationParameters:(NSDictionary *)calculationParameters
                  prayer:(NSString *)prayer
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(validateCoordinates:(NSDictionary *)coordinates
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(calculatePrayerTimesRange:(NSDictionary *)coordinates
                  startDate:(NSDictionary *)startDate
                  endDate:(NSDictionary *)endDate
                  calculationParameters:(NSDictionary *)calculationParameters
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_BLOCKING_SYNCHRONOUS_METHOD(getCalculationMethods)

RCT_EXTERN_BLOCKING_SYNCHRONOUS_METHOD(getMethodParameters:(NSString *)method)

RCT_EXTERN_BLOCKING_SYNCHRONOUS_METHOD(getLibraryInfo)

@end
