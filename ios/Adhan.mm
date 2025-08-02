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
    
    // Apply custom parameters if provided
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
        NSString *madhab = dict[@"madhab"];
        if ([madhab isEqualToString:@"hanafi"]) {
            params.madhab = BAMadhabHanafi;
        } else {
            params.madhab = BAMadhabShafi;
        }
    }
    if (dict[@"rounding"]) {
        NSString *rounding = dict[@"rounding"];
        if ([rounding isEqualToString:@"up"]) {
            params.rounding = BARoundingUp;
        } else if ([rounding isEqualToString:@"none"]) {
            params.rounding = BARoundingNone;
        } else {
            params.rounding = BARoundingNearest;
        }
    }
    if (dict[@"shafaq"]) {
        NSString *shafaq = dict[@"shafaq"];
        if ([shafaq isEqualToString:@"ahmer"]) {
            params.shafaq = BAShafaqAhmer;
        } else if ([shafaq isEqualToString:@"abyad"]) {
            params.shafaq = BAShafaqAbyad;
        } else {
            params.shafaq = BAShafaqGeneral;
        }
    }
    if (dict[@"highLatitudeRule"]) {
        NSString *rule = dict[@"highLatitudeRule"];
        if ([rule isEqualToString:@"middleOfTheNight"]) {
            params.highLatitudeRule = BAHighLatitudeRuleMiddleOfTheNight;
        } else if ([rule isEqualToString:@"seventhOfTheNight"]) {
            params.highLatitudeRule = BAHighLatitudeRuleSeventhOfTheNight;
        } else if ([rule isEqualToString:@"twilightAngle"]) {
            params.highLatitudeRule = BAHighLatitudeRuleTwilightAngle;
        }
    }
    if (dict[@"maghribAngle"]) {
        params.maghribAngle = [dict[@"maghribAngle"] doubleValue];
    }
    
    // Apply prayer adjustments
    if (dict[@"prayerAdjustments"]) {
        NSDictionary *adjustments = dict[@"prayerAdjustments"];
        int fajr = adjustments[@"fajr"] ? [adjustments[@"fajr"] intValue] : 0;
        int sunrise = adjustments[@"sunrise"] ? [adjustments[@"sunrise"] intValue] : 0;
        int dhuhr = adjustments[@"dhuhr"] ? [adjustments[@"dhuhr"] intValue] : 0;
        int asr = adjustments[@"asr"] ? [adjustments[@"asr"] intValue] : 0;
        int maghrib = adjustments[@"maghrib"] ? [adjustments[@"maghrib"] intValue] : 0;
        int isha = adjustments[@"isha"] ? [adjustments[@"isha"] intValue] : 0;
        BAPrayerAdjustments *prayerAdj = [[BAPrayerAdjustments alloc] initWithFajr:fajr sunrise:sunrise dhuhr:dhuhr asr:asr maghrib:maghrib isha:isha];
        params.adjustments = prayerAdj;
    }
    
    // Apply method adjustments
    if (dict[@"methodAdjustments"]) {
        NSDictionary *adjustments = dict[@"methodAdjustments"];
        int fajr = adjustments[@"fajr"] ? [adjustments[@"fajr"] intValue] : 0;
        int sunrise = adjustments[@"sunrise"] ? [adjustments[@"sunrise"] intValue] : 0;
        int dhuhr = adjustments[@"dhuhr"] ? [adjustments[@"dhuhr"] intValue] : 0;
        int asr = adjustments[@"asr"] ? [adjustments[@"asr"] intValue] : 0;
        int maghrib = adjustments[@"maghrib"] ? [adjustments[@"maghrib"] intValue] : 0;
        int isha = adjustments[@"isha"] ? [adjustments[@"isha"] intValue] : 0;
        // Note: methodAdjustments is private in BACalculationParameters, 
        // so they're automatically applied when using initWithMethod:
        // BAPrayerAdjustments *methodAdj = [[BAPrayerAdjustments alloc] initWithFajr:fajr sunrise:sunrise dhuhr:dhuhr asr:asr maghrib:maghrib isha:isha];
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
        @{
            @"name": @"muslimWorldLeague",
            @"displayName": @"Muslim World League",
            @"fajrAngle": @18.0,
            @"ishaAngle": @17.0,
            @"ishaInterval": @0,
            @"description": @"Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°."
        },
        @{
            @"name": @"egyptian",
            @"displayName": @"Egyptian General Authority of Survey",
            @"fajrAngle": @19.5,
            @"ishaAngle": @17.5,
            @"ishaInterval": @0,
            @"description": @"Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°."
        },
        @{
            @"name": @"karachi",
            @"displayName": @"University of Islamic Sciences, Karachi",
            @"fajrAngle": @18.0,
            @"ishaAngle": @18.0,
            @"ishaInterval": @0,
            @"description": @"A generally applicable method that uses standard Fajr and Isha angles of 18°."
        },
        @{
            @"name": @"ummAlQura",
            @"displayName": @"Umm al-Qura University, Makkah",
            @"fajrAngle": @18.5,
            @"ishaAngle": @0.0,
            @"ishaInterval": @90,
            @"description": @"Uses a fixed interval of 90 minutes from maghrib to calculate Isha. Note: you should add a +30 minute custom adjustment for Isha during Ramadan."
        },
        @{
            @"name": @"dubai",
            @"displayName": @"UAE",
            @"fajrAngle": @18.2,
            @"ishaAngle": @18.2,
            @"ishaInterval": @0,
            @"description": @"Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2°."
        },
        @{
            @"name": @"moonsightingCommittee",
            @"displayName": @"Moonsighting Committee",
            @"fajrAngle": @18.0,
            @"ishaAngle": @18.0,
            @"ishaInterval": @0,
            @"description": @"Method developed by Khalid Shaukat. Uses standard 18° angles for Fajr and Isha in addition to seasonal adjustment values."
        },
        @{
            @"name": @"northAmerica",
            @"displayName": @"ISNA",
            @"fajrAngle": @15.0,
            @"ishaAngle": @15.0,
            @"ishaInterval": @0,
            @"description": @"Also known as the ISNA method. Gives later Fajr times and early Isha times with angles of 15°."
        },
        @{
            @"name": @"kuwait",
            @"displayName": @"Kuwait",
            @"fajrAngle": @18.0,
            @"ishaAngle": @17.5,
            @"ishaInterval": @0,
            @"description": @"Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°."
        },
        @{
            @"name": @"qatar",
            @"displayName": @"Qatar",
            @"fajrAngle": @18.0,
            @"ishaAngle": @0.0,
            @"ishaInterval": @90,
            @"description": @"Same Isha interval as Umm al-Qura but with the standard Fajr time using an angle of 18°."
        },
        @{
            @"name": @"singapore",
            @"displayName": @"Singapore",
            @"fajrAngle": @20.0,
            @"ishaAngle": @18.0,
            @"ishaInterval": @0,
            @"description": @"Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°."
        },
        @{
            @"name": @"turkey",
            @"displayName": @"Diyanet İşleri Başkanlığı, Turkey",
            @"fajrAngle": @18.0,
            @"ishaAngle": @17.0,
            @"ishaInterval": @0,
            @"description": @"An approximation of the Diyanet method used in Turkey."
        }
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
        @"ishaInterval": @(params.ishaInterval),
        @"madhab": (params.madhab == BAMadhabHanafi) ? @"hanafi" : @"shafi",
        @"rounding": (params.rounding == BARoundingUp) ? @"up" : @"nearest",
        @"shafaq": (params.shafaq == BAShafaqAhmer) ? @"ahmer" : 
                   (params.shafaq == BAShafaqAbyad) ? @"abyad" : @"general"
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
