#import "Adhan.h"
#import <React/RCTLog.h>
#import <Adhan/Adhan-Swift.h> // Import the auto-generated Swift header

@interface Adhan()
@property (nonatomic, strong) AdhanBridge *bridge;
@end

@implementation Adhan

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bridge = [[AdhanBridge alloc] init];
    }
    return self;
}

// MARK: - Helper Methods

- (AdhanCoordinates *)coordinatesFromDict:(NSDictionary *)dict {
    double latitude = [dict[@"latitude"] doubleValue];
    double longitude = [dict[@"longitude"] doubleValue];
    return [[AdhanCoordinates alloc] initWithLatitude:latitude longitude:longitude];
}

- (AdhanCalculationParameters *)paramsFromDict:(NSDictionary *)dict {
    AdhanCalculationParameters *params = [[AdhanCalculationParameters alloc] init];
    if (dict[@"method"]) {
        params.method = dict[@"method"];
    }
    if (dict[@"fajrAngle"]) {
        params.fajrAngle = [dict[@"fajrAngle"] doubleValue];
    }
    if (dict[@"ishaAngle"]) {
        params.ishaAngle = [dict[@"ishaAngle"] doubleValue];
    }
    if (dict[@"ishaInterval"]) {
        params.ishaInterval = [dict[@"ishaInterval"] intValue];
    }
    if (dict[@"madhab"]) {
        params.madhab = dict[@"madhab"];
    }
    if (dict[@"highLatitudeRule"]) {
        params.highLatitudeRule = dict[@"highLatitudeRule"];
    }
    if (dict[@"rounding"]) {
        params.rounding = dict[@"rounding"];
    }
    if (dict[@"shafaq"]) {
        params.shafaq = dict[@"shafaq"];
    }
    
    // Adjustments
    if (dict[@"prayerAdjustments"]) {
        NSDictionary *adjustments = dict[@"prayerAdjustments"];
        AdhanPrayerAdjustments *prayerAdjustments = [[AdhanPrayerAdjustments alloc] init];
        if (adjustments[@"fajr"]) prayerAdjustments.fajr = [adjustments[@"fajr"] intValue];
        if (adjustments[@"sunrise"]) prayerAdjustments.sunrise = [adjustments[@"sunrise"] intValue];
        if (adjustments[@"dhuhr"]) prayerAdjustments.dhuhr = [adjustments[@"dhuhr"] intValue];
        if (adjustments[@"asr"]) prayerAdjustments.asr = [adjustments[@"asr"] intValue];
        if (adjustments[@"maghrib"]) prayerAdjustments.maghrib = [adjustments[@"maghrib"] intValue];
        if (adjustments[@"isha"]) prayerAdjustments.isha = [adjustments[@"isha"] intValue];
        params.adjustments = prayerAdjustments;
    }
    
    return params;
}

- (NSNumber *)timestampFromDate:(NSDate *)date {
    return @([date timeIntervalSince1970] * 1000);
}

// MARK: - TurboModule Methods (Bridged to Swift)

- (void)calculatePrayerTimes:(NSDictionary *)coordinates
                dateComponents:(NSDictionary *)dateComponents
         calculationParameters:(NSDictionary *)calculationParameters
                       resolve:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject {
    
    AdhanCoordinates *coords = [self coordinatesFromDict:coordinates];
    AdhanCalculationParameters *params = [self paramsFromDict:calculationParameters];
    NSInteger year = [dateComponents[@"year"] integerValue];
    NSInteger month = [dateComponents[@"month"] integerValue];
    NSInteger day = [dateComponents[@"day"] integerValue];

    AdhanPrayerTimes *prayerTimes = [self.bridge calculatePrayerTimesWithCoordinates:coords year:year month:month day:day params:params];

    if (prayerTimes) {
        NSDictionary *result = @{
            @"fajr": [self timestampFromDate:prayerTimes.fajr],
            @"sunrise": [self timestampFromDate:prayerTimes.sunrise],
            @"dhuhr": [self timestampFromDate:prayerTimes.dhuhr],
            @"asr": [self timestampFromDate:prayerTimes.asr],
            @"maghrib": [self timestampFromDate:prayerTimes.maghrib],
            @"isha": [self timestampFromDate:prayerTimes.isha]
        };
        resolve(result);
    } else {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
    }
}

- (void)calculateQibla:(NSDictionary *)coordinates
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
    AdhanCoordinates *coords = [self coordinatesFromDict:coordinates];
    AdhanQibla *qibla = [self.bridge calculateQiblaWithCoordinates:coords];
    resolve(@{@"direction": @(qibla.direction)});
}

- (void)calculateSunnahTimes:(NSDictionary *)coordinates
              dateComponents:(NSDictionary *)dateComponents
       calculationParameters:(NSDictionary *)calculationParameters
                     resolve:(RCTPromiseResolveBlock)resolve
                      reject:(RCTPromiseRejectBlock)reject {

    AdhanCoordinates *coords = [self coordinatesFromDict:coordinates];
    AdhanCalculationParameters *params = [self paramsFromDict:calculationParameters];
    NSInteger year = [dateComponents[@"year"] integerValue];
    NSInteger month = [dateComponents[@"month"] integerValue];
    NSInteger day = [dateComponents[@"day"] integerValue];

    AdhanSunnahTimes *sunnahTimes = [self.bridge calculateSunnahTimesWithCoordinates:coords year:year month:month day:day params:params];

    if (sunnahTimes) {
        NSDictionary *result = @{
            @"middleOfTheNight": [self timestampFromDate:sunnahTimes.middleOfTheNight],
            @"lastThirdOfTheNight": [self timestampFromDate:sunnahTimes.lastThirdOfTheNight]
        };
        resolve(result);
    } else {
        reject(@"CALCULATION_ERROR", @"Failed to calculate sunnah times.", nil);
    }
}


- (NSDictionary *)getLibraryInfo {
    return [self.bridge getLibraryInfo];
}


// MARK: - Required TurboModule Method

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}

@end