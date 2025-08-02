#import "Adhan.h"
#import <React/RCTLog.h>

// Correctly import the auto-generated header based on the podspec's module_name
#import "react_native_adhan-Swift.h"

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
    // Use UTC for all calculations, as the core library expects
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
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
    if (!dict || ![dict isKindOfClass:[NSDictionary class]] || !dict[@"method"]) {
        // Default to MWL if no params are provided
        return [[BACalculationParameters alloc] initWithMethod:BACalculationMethodMuslimWorldLeague];
    }
    
    NSString *methodName = dict[@"method"];
    BACalculationMethod method = calculationMethodFromString(methodName);
    
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


// --- Asynchronous Methods ---

RCT_REMAP_METHOD(calculatePrayerTimes,
                 calculatePrayerTimesWithCoordinates:(NSDictionary *)coordinates
                 dateComponents:(NSDictionary *)dateComponents
                 calculationParameters:(NSDictionary *)calculationParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    NSDateComponents *date = dateComponentsFromDictionary(dateComponents);
    BACalculationParameters *params = paramsFromDictionary(calculationParameters);

    if (!coords || !date) {
        reject(@"INVALID_PARAMS", @"Invalid coordinates or date components.", nil);
        return;
    }

    BAPrayerTimes *prayerTimes = [[BAPrayerTimes alloc] initWithCoordinates:coords date:date calculationParameters:params];
    if (!prayerTimes.fajr) { // Check for a valid prayer time to ensure calculation succeeded
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
                 calculateQiblaWithCoordinates:(NSDictionary *)coordinates
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

// --- Synchronous Methods ---

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSArray<NSDictionary *> *, getCalculationMethods)
{
    // This is a simplified representation. The official library doesn't expose this directly.
    return @[
        @{@"name": @"muslimWorldLeague"}, @{@"name": @"egyptian"}, @{@"name": @"karachi"},
        @{@"name": @"ummAlQura"}, @{@"name": @"dubai"}, @{@"name": @"moonsightingCommittee"},
        @{@"name": @"northAmerica"}, @{@"name": @"kuwait"}, @{@"name": @"qatar"},
        @{@"name": @"singapore"}, @{@"name": @"tehran"}, @{@"name": @"turkey"}, @{@"name": @"other"}
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
    return @{ @"version": @"2.0.0", @"platform": @"iOS (adhan-swift)" };
}

// Stubs for other methods not yet implemented with the official wrapper
RCT_REMAP_METHOD(validateCoordinates, validateCoordinates:(NSDictionary *)c resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej) { res(@(YES)); }
RCT_REMAP_METHOD(calculateSunnahTimes, calcSunnah:(NSDictionary *)p resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej) { res(@{}); }
RCT_REMAP_METHOD(getCurrentPrayer, getCurrent:(NSDictionary *)p resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej) { res(@{}); }
RCT_REMAP_METHOD(getTimeForPrayer, getTime:(NSDictionary *)p resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej) { res(nil); }
RCT_REMAP_METHOD(calculatePrayerTimesRange, calcRange:(NSDictionary *)p resolver:(RCTPromiseResolveBlock)res rejecter:(RCTPromiseRejectBlock)rej) { res(@[]); }

@end