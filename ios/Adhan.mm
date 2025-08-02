#import "Adhan.h"
#import "react_native_adhan-Swift.h"

// Helper functions (as before)
static BACoordinates *coordinatesFromDictionary(NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    NSNumber *latitude = dict[@"latitude"];
    NSNumber *longitude = dict[@"longitude"];
    if (!latitude || !longitude) return nil;
    return [[BACoordinates alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
}

static NSDateComponents *dateComponentsFromDictionary(NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    NSNumber *year = dict[@"year"];
    NSNumber *month = dict[@"month"];
    NSNumber *day = dict[@"day"];
    if (!year || !month || !day) return nil;
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = [year integerValue];
    components.month = [month integerValue];
    components.day = [day integerValue];
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return components;
}

static BACalculationMethod calculationMethodFromString(NSString *methodName) {
    if ([methodName isEqualToString:@"muslimWorldLeague"]) return BACalculationMethodMuslimWorldLeague;
    if ([methodName isEqualToString:@"egyptian"]) return BACalculationMethodEgyptian;
    if ([methodName isEqualToString:@"karachi"]) return BACalculationMethodKarachi;
    if ([methodName isEqualToString:@"ummAlQura"]) return BACalculationMethodUmmAlQura;
    if ([methodName isEqualToString:@"dubai"]) return BACalculationMethodDubai;
    if ([methodName isEqualToString:@"moonsightingCommittee"]) return BACalculationMethodMoonsightingCommittee;
    if ([methodName isEqualToString:@"northAmerica"]) return BACalculationMethodNorthAmerica;
    if ([methodName isEqualToString:@"kuwait"]) return BACalculationMethodKuwait;
    if ([methodName isEqualToString:@"qatar"]) return BACalculationMethodQatar;
    if ([methodName isEqualToString:@"singapore"]) return BACalculationMethodSingapore;
    if ([methodName isEqualToString:@"tehran"]) return BACalculationMethodTehran;
    if ([methodName isEqualToString:@"turkey"]) return BACalculationMethodTurkey;
    return BACalculationMethodOther;
}

static BACalculationParameters *paramsFromDictionary(NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]] || !dict[@"method"]) {
        return [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMuslimWorldLeague];
    }
    NSString *methodName = dict[@"method"];
    BACalculationMethod method = calculationMethodFromString(methodName);
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:method];
    if (method == BACalculationMethodOther) {
        if (dict[@"fajrAngle"]) params.fajrAngle = [dict[@"fajrAngle"] doubleValue];
        if (dict[@"ishaAngle"]) params.ishaAngle = [dict[@"ishaAngle"] doubleValue];
    }
    return params;
}

@implementation Adhan

- (void)calculatePrayerTimes:(NSDictionary *)coordinates
              dateComponents:(NSDictionary *)dateComponents
       calculationParameters:(NSDictionary *)calculationParameters
                    resolver:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    NSDateComponents *date = dateComponentsFromDictionary(dateComponents);
    BACalculationParameters *params = paramsFromDictionary(calculationParameters);

    if (!coords || !date) {
        reject(@"INVALID_PARAMS", @"Invalid coordinates or date components.", nil);
        return;
    }

    BAPrayerTimes *prayerTimes = [[BAPrayerTimes alloc] initWithCoordinates:coords date:date calculationParameters:params];
    if (!prayerTimes.fajr) {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
        return;
    }

    NSDictionary *result = @{
        @"fajr": @([prayerTimes.fajr timeIntervalSince1970] * 1000),
        @"sunrise": @([prayerTimes.sunrise timeIntervalSince1970] * 1000),
        @"dhuhr": @([prayerTimes.dhuhr timeIntervalSince1970] * 1000),
        @"asr": @([prayerTimes.asr timeIntervalSince1970] * 1000),
        @"maghrib": @([prayerTimes.maghrib timeIntervalSince1970] * 1000),
        @"isha": @([prayerTimes.isha timeIntervalSince1970] * 1000)
    };
    resolve(result);
}

- (void)calculateQibla:(NSDictionary *)coordinates
              resolver:(RCTPromiseResolveBlock)resolve
              rejecter:(RCTPromiseRejectBlock)reject
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    if (!coords) {
        reject(@"INVALID_COORDINATES", @"Invalid coordinates.", nil);
        return;
    }
    
    BAQibla *qibla = [[BAQibla alloc] initWithCoordinates:coords];
    resolve(@{@"direction": @(qibla.direction)});
}

- (NSArray<NSDictionary *> *)getCalculationMethods
{
    return @[
        @{@"name": @"muslimWorldLeague"}, @{@"name": @"egyptian"}, @{@"name": @"karachi"},
        @{@"name": @"ummAlQura"}, @{@"name": @"dubai"}, @{@"name": @"moonsightingCommittee"},
        @{@"name": @"northAmerica"}, @{@"name": @"kuwait"}, @{@"name": @"qatar"},
        @{@"name": @"singapore"}, @{@"name": @"tehran"}, @{@"name": @"turkey"}, @{@"name": @"other"}
    ];
}

- (NSDictionary *)getMethodParameters:(NSString *)method
{
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:calculationMethodFromString(method)];
    return @{
        @"method": method,
        @"fajrAngle": @(params.fajrAngle),
        @"ishaAngle": @(params.ishaAngle),
        @"ishaInterval": @(params.ishaInterval)
    };
}

- (NSDictionary *)getLibraryInfo
{
    return @{ @"version": @"2.0.0", @"platform": @"iOS (adhan-swift)" };
}

// Stubs for other methods
- (void)validateCoordinates:(NSDictionary *)p resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej { res(@(YES)); }
- (void)calculateSunnahTimes:(NSDictionary *)p dateComponents:(NSDictionary *)dc calculationParameters:(NSDictionary *)cp resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej { res(@{}); }
- (void)getCurrentPrayer:(NSDictionary *)p dateComponents:(NSDictionary *)dc calculationParameters:(NSDictionary *)cp currentTime:(nonnull NSNumber *)ct resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej { res(@{}); }
- (void)getTimeForPrayer:(NSDictionary *)p dateComponents:(NSDictionary *)dc calculationParameters:(NSDictionary *)cp prayer:(NSString *)prayer resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej { res(nil); }
- (void)calculatePrayerTimesRange:(NSDictionary *)p startDate:(NSDictionary *)sd endDate:(NSDictionary *)ed calculationParameters:(NSDictionary *)cp resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej { res(@[]); }

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}

@end
