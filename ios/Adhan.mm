#import "Adhan.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import "Adhan-Swift.h"

// Helper function to convert NSDictionary to BACoordinates
static BACoordinates *coordinatesFromDictionary(NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return nil;
    NSNumber *latitude = dict[@"latitude"];
    NSNumber *longitude = dict[@"longitude"];
    if (!latitude || !longitude) return nil;
    return [[BACoordinates alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
}

// Helper function to convert NSDictionary to NSDateComponents
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
    return components;
}

// Helper function to convert string to BACalculationMethod enum
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

// Helper function to convert NSDictionary to BACalculationParameters
static BACalculationParameters *paramsFromDictionary(NSDictionary *dict) {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMuslimWorldLeague];
    }
    
    NSString *methodName = dict[@"method"];
    BACalculationMethod method = methodName ? calculationMethodFromString(methodName) : BACalculationMethodOther;
    
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:method];
    
    // Allow overriding angles for "other" method
    if (method == BACalculationMethodOther) {
        if (dict[@"fajrAngle"]) params.fajrAngle = [dict[@"fajrAngle"] doubleValue];
        if (dict[@"ishaAngle"]) params.ishaAngle = [dict[@"ishaAngle"] doubleValue];
    }
    
    return params;
}

@implementation Adhan

RCT_EXPORT_MODULE()

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

RCT_REMAP_METHOD(calculatePrayerTimes,
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    BACoordinates *coordinates = coordinatesFromDictionary(params[@"coordinates"]);
    NSDateComponents *date = dateComponentsFromDictionary(params[@"dateComponents"]);
    BACalculationParameters *calcParams = paramsFromDictionary(params[@"calculationParameters"]);

    if (!coordinates || !date) {
        reject(@"INVALID_PARAMS", @"Invalid coordinates or date components.", nil);
        return;
    }

    BAPrayerTimes *prayerTimes = [[BAPrayerTimes alloc] initWithCoordinates:coordinates date:date calculationParameters:calcParams];
    if (!prayerTimes) {
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

RCT_REMAP_METHOD(calculateQibla,
                 coordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    if (!coords) {
        reject(@"INVALID_COORDINATES", @"Invalid coordinates.", nil);
        return;
    }
    
    BAQibla *qibla = [[BAQibla alloc] initWithCoordinates:coords];
    resolve(@{@"direction": @(qibla.direction)});
}

// Note: The adhan-swift library does not have a direct equivalent for SunnahTimes in its ObjC wrapper.
// This would need to be implemented in Swift and exposed, or calculated manually.
// For now, returning an empty object to avoid crashes.
RCT_REMAP_METHOD(calculateSunnahTimes,
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@{});
}

// Note: The adhan-swift library's currentPrayer/nextPrayer requires a Date object.
// This simplified implementation does not yet handle this.
RCT_REMAP_METHOD(getCurrentPrayer,
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@{@"current": @"none", @"next": @"none"});
}

RCT_REMAP_METHOD(getTimeForPrayer,
                 params:(NSDictionary *)params
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    // This is a simplified stub. A full implementation would map the string prayer name to the BAPrayer enum.
    resolve(nil);
}

RCT_REMAP_METHOD(validateCoordinates,
                 coordinates:(NSDictionary *)coordinates
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    BOOL isValid = (coords != nil);
    resolve(@(isValid));
}


// --- Synchronous Methods ---
// These are not part of the official adhan-swift ObjC API and would require a Swift wrapper.
// Returning placeholder data.

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSArray *, getCalculationMethods)
{
    return @[
        @{@"name": @"muslimWorldLeague", @"displayName": @"Muslim World League"},
        @{@"name": @"egyptian", @"displayName": @"Egyptian General Authority of Survey"},
        @{@"name": @"karachi", @"displayName": @"University of Islamic Sciences, Karachi"},
        @{@"name": @"ummAlQura", @"displayName": @"Umm al-Qura University, Makkah"},
        @{@"name": @"dubai", @"displayName": @"Dubai"},
        @{@"name": @"moonsightingCommittee", @"displayName": @"Moonsighting Committee"},
        @{@"name": @"northAmerica", @"displayName": @"North America (ISNA)"},
        @{@"name": @"kuwait", @"displayName": @"Kuwait"},
        @{@"name": @"qatar", @"displayName": @"Qatar"},
        @{@"name": @"singapore", @"displayName": @"Singapore"},
        @{@"name": @"tehran", @"displayName": @"Tehran"},
        @{@"name": @"turkey", @"displayName": @"Turkey"},
        @{@"name": @"other", @"displayName": @"Other"}
    ];
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getMethodParameters:(NSString *)method)
{
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:calculationMethodFromString(method)];
    return @{
        @"method": method,
        @"fajrAngle": @(params.fajrAngle),
        @"ishaAngle": @(params.ishaAngle),
        @"ishaInterval": @(params.ishaInterval)
    };
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getLibraryInfo)
{
    return @{ @"version": @"1.0.0", @"platform": @"iOS (Official Wrapper)" };
}

@end
