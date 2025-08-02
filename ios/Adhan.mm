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

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(calculatePrayerTimes:(NSDictionary *)coordinates
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

RCT_EXPORT_METHOD(calculateQibla:(NSDictionary *)coordinates
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

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSArray *, getCalculationMethods)
{
    return @[
        @{@"name": @"muslimWorldLeague"}, @{@"name": @"egyptian"}, @{@"name": @"karachi"},
        @{@"name": @"ummAlQura"}, @{@"name": @"dubai"}, @{@"name": @"moonsightingCommittee"},
        @{@"name": @"northAmerica"}, @{@"name": @"kuwait"}, @{@"name": @"qatar"},
        @{@"name": @"singapore"}, @{@"name": @"tehran"}, @{@"name": @"turkey"}, @{@"name": @"other"}
    ];
}

RCT_EXPORT_METHOD(getMethodParameters:(NSString *)method
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject)
{
    BACalculationParameters *params = [[BACalculationParameters alloc] initWithMethod:calculationMethodFromString(method)];
    NSDictionary *result = @{
        @"method": method,
        @"fajrAngle": @(params.fajrAngle),
        @"ishaAngle": @(params.ishaAngle),
        @"ishaInterval": @(params.ishaInterval)
    };
    resolve(result);
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSDictionary *, getLibraryInfo)
{
    return @{ @"version": @"2.0.0", @"platform": @"iOS (adhan-swift)" };
}

RCT_EXPORT_METHOD(calculateSunnahTimes:(NSDictionary *)coordinates
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
    if (!prayerTimes.fajr) {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
        return;
    }

    // Calculate middle and last third of night
    NSDate *maghrib = prayerTimes.maghrib;
    NSDate *fajr = prayerTimes.fajr;
    
    // Add 24 hours if fajr is before maghrib (next day)
    if ([fajr compare:maghrib] == NSOrderedAscending) {
        fajr = [fajr dateByAddingTimeInterval:24 * 60 * 60];
    }
    
    NSTimeInterval nightDuration = [fajr timeIntervalSinceDate:maghrib];
    NSDate *middleOfNight = [maghrib dateByAddingTimeInterval:nightDuration / 2.0];
    NSDate *lastThirdOfNight = [maghrib dateByAddingTimeInterval:nightDuration * 2.0 / 3.0];

    NSDictionary *result = @{
        @"middleOfTheNight": @([middleOfNight timeIntervalSince1970] * 1000),
        @"lastThirdOfTheNight": @([lastThirdOfNight timeIntervalSince1970] * 1000)
    };
    resolve(result);
}

RCT_EXPORT_METHOD(getCurrentPrayer:(NSDictionary *)coordinates
              dateComponents:(NSDictionary *)dateComponents
       calculationParameters:(NSDictionary *)calculationParameters
                 currentTime:(nonnull NSNumber *)currentTime
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
    if (!prayerTimes.fajr) {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
        return;
    }

    NSDate *time = [NSDate dateWithTimeIntervalSince1970:[currentTime doubleValue] / 1000.0];
    BAPrayer current = [prayerTimes currentPrayer:time];
    BAPrayer next = [prayerTimes nextPrayer:time];

    NSString *currentString = @"none";
    NSString *nextString = @"none";

    switch (current) {
        case BAPrayerFajr: currentString = @"fajr"; break;
        case BAPrayerSunrise: currentString = @"sunrise"; break;
        case BAPrayerDhuhr: currentString = @"dhuhr"; break;
        case BAPrayerAsr: currentString = @"asr"; break;
        case BAPrayerMaghrib: currentString = @"maghrib"; break;
        case BAPrayerIsha: currentString = @"isha"; break;
        case BAPrayerNone: currentString = @"none"; break;
    }

    switch (next) {
        case BAPrayerFajr: nextString = @"fajr"; break;
        case BAPrayerSunrise: nextString = @"sunrise"; break;
        case BAPrayerDhuhr: nextString = @"dhuhr"; break;
        case BAPrayerAsr: nextString = @"asr"; break;
        case BAPrayerMaghrib: nextString = @"maghrib"; break;
        case BAPrayerIsha: nextString = @"isha"; break;
        case BAPrayerNone: nextString = @"none"; break;
    }

    NSDictionary *result = @{
        @"current": currentString,
        @"next": nextString
    };
    resolve(result);
}

RCT_EXPORT_METHOD(getTimeForPrayer:(NSDictionary *)coordinates
               dateComponents:(NSDictionary *)dateComponents
        calculationParameters:(NSDictionary *)calculationParameters
                       prayer:(NSString *)prayer
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
    if (!prayerTimes.fajr) {
        reject(@"CALCULATION_ERROR", @"Failed to calculate prayer times.", nil);
        return;
    }

    BAPrayer prayerEnum = BAPrayerNone;
    if ([prayer isEqualToString:@"fajr"]) prayerEnum = BAPrayerFajr;
    else if ([prayer isEqualToString:@"sunrise"]) prayerEnum = BAPrayerSunrise;
    else if ([prayer isEqualToString:@"dhuhr"]) prayerEnum = BAPrayerDhuhr;
    else if ([prayer isEqualToString:@"asr"]) prayerEnum = BAPrayerAsr;
    else if ([prayer isEqualToString:@"maghrib"]) prayerEnum = BAPrayerMaghrib;
    else if ([prayer isEqualToString:@"isha"]) prayerEnum = BAPrayerIsha;

    NSDate *prayerTime = [prayerTimes timeForPrayer:prayerEnum];
    if (prayerTime) {
        resolve(@([prayerTime timeIntervalSince1970] * 1000));
    } else {
        resolve([NSNull null]);
    }
}

RCT_EXPORT_METHOD(calculatePrayerTimesRange:(NSDictionary *)coordinates
                              startDate:(NSDictionary *)startDate
                                endDate:(NSDictionary *)endDate
                  calculationParameters:(NSDictionary *)calculationParameters
                               resolver:(RCTPromiseResolveBlock)resolve
                               rejecter:(RCTPromiseRejectBlock)reject)
{
    BACoordinates *coords = coordinatesFromDictionary(coordinates);
    NSDateComponents *start = dateComponentsFromDictionary(startDate);
    NSDateComponents *end = dateComponentsFromDictionary(endDate);
    BACalculationParameters *params = paramsFromDictionary(calculationParameters);

    if (!coords || !start || !end) {
        reject(@"INVALID_PARAMS", @"Invalid parameters provided", nil);
        return;
    }

    NSMutableArray *results = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

    NSDate *startDateTime = [calendar dateFromComponents:start];
    NSDate *endDateTime = [calendar dateFromComponents:end];

    NSDate *currentDate = startDateTime;
    while ([currentDate compare:endDateTime] != NSOrderedDescending) {
        NSDateComponents *currentComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
        
        BAPrayerTimes *prayerTimes = [[BAPrayerTimes alloc] initWithCoordinates:coords date:currentComponents calculationParameters:params];
        
        if (prayerTimes.fajr) {
            NSDictionary *prayerTimesDict = @{
                @"fajr": @([prayerTimes.fajr timeIntervalSince1970] * 1000),
                @"sunrise": @([prayerTimes.sunrise timeIntervalSince1970] * 1000),
                @"dhuhr": @([prayerTimes.dhuhr timeIntervalSince1970] * 1000),
                @"asr": @([prayerTimes.asr timeIntervalSince1970] * 1000),
                @"maghrib": @([prayerTimes.maghrib timeIntervalSince1970] * 1000),
                @"isha": @([prayerTimes.isha timeIntervalSince1970] * 1000)
            };

            NSDictionary *dateDict = @{
                @"year": @(currentComponents.year),
                @"month": @(currentComponents.month),
                @"day": @(currentComponents.day)
            };

            NSDictionary *resultItem = @{
                @"date": dateDict,
                @"prayerTimes": prayerTimesDict
            };

            [results addObject:resultItem];
        }

        currentDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:currentDate options:0];
    }

    resolve(results);
}


@end
