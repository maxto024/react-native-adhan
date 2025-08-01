#import "Adhan.h"
#import <AdhanSpec/AdhanSpec.h>

@implementation Adhan

RCT_EXPORT_MODULE()

- (NSNumber *)multiply:(double)a b:(double)b {
    NSNumber *result = @(a * b);
    return result;
}

- (NSString *)getPrayerTimes:(double)latitude
                   longitude:(double)longitude
                     dateIso:(NSString *)dateIso
                      method:(NSString *)method
                      madhab:(NSString *)madhab
                    timezone:(NSString *)timezone
                 adjustments:(NSString *)adjustments
                customAngles:(NSString *)customAngles {
    
    // Create prayer times dictionary
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    // Parse input date
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [inputFormatter dateFromString:dateIso];
    
    if (!date) {
        date = [NSDate date]; // Fallback to current date
    }
    
    // Set up timezone
    NSTimeZone *calculationTimeZone;
    if (timezone && ![timezone isEqualToString:@""]) {
        // Try parsing as timezone identifier first
        calculationTimeZone = [NSTimeZone timeZoneWithName:timezone];
        if (!calculationTimeZone) {
            // Try parsing as offset (e.g., "+05:00")
            NSInteger secondsFromGMT = 0;
            if ([timezone hasPrefix:@"+"]) {
                NSString *offsetStr = [timezone substringFromIndex:1];
                NSArray *parts = [offsetStr componentsSeparatedByString:@":"];
                if (parts.count >= 2) {
                    NSInteger hours = [parts[0] integerValue];
                    NSInteger minutes = [parts[1] integerValue];
                    secondsFromGMT = (hours * 3600) + (minutes * 60);
                }
            } else if ([timezone hasPrefix:@"-"]) {
                NSString *offsetStr = [timezone substringFromIndex:1];
                NSArray *parts = [offsetStr componentsSeparatedByString:@":"];
                if (parts.count >= 2) {
                    NSInteger hours = [parts[0] integerValue];
                    NSInteger minutes = [parts[1] integerValue];
                    secondsFromGMT = -((hours * 3600) + (minutes * 60));
                }
            }
            calculationTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
        }
    } else {
        calculationTimeZone = [NSTimeZone localTimeZone];
    }
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssXXXXX"];
    [outputFormatter setTimeZone:calculationTimeZone];
    
    // Parse calculation method angles
    double fajrAngle = 15.0; // Default ISNA
    double ishaAngle = 15.0;
    BOOL ishaIsInterval = NO;
    double ishaInterval = 0.0;
    
    // Set method-specific angles
    if ([method isEqualToString:@"ISNA"]) {
        fajrAngle = 15.0; ishaAngle = 15.0;
    } else if ([method isEqualToString:@"MWL"]) {
        fajrAngle = 18.0; ishaAngle = 17.0;
    } else if ([method isEqualToString:@"Karachi"]) {
        fajrAngle = 18.0; ishaAngle = 18.0;
    } else if ([method isEqualToString:@"Egypt"]) {
        fajrAngle = 19.5; ishaAngle = 17.5;
    } else if ([method isEqualToString:@"UmmAlQura"]) {
        fajrAngle = 18.5; ishaInterval = 90.0; ishaIsInterval = YES;
    } else if ([method isEqualToString:@"Dubai"]) {
        fajrAngle = 18.2; ishaAngle = 18.2;
    } else if ([method isEqualToString:@"Kuwait"]) {
        fajrAngle = 18.0; ishaAngle = 17.5;
    } else if ([method isEqualToString:@"Qatar"]) {
        fajrAngle = 18.0; ishaInterval = 90.0; ishaIsInterval = YES;
    } else if ([method isEqualToString:@"Singapore"]) {
        fajrAngle = 20.0; ishaAngle = 18.0;
    } else if ([method isEqualToString:@"Tehran"]) {
        fajrAngle = 17.7; ishaAngle = 14.0;
    } else if ([method isEqualToString:@"Turkey"]) {
        fajrAngle = 18.0; ishaAngle = 17.0;
    }
    
    // Override with custom angles if provided
    if (customAngles && ![customAngles isEqualToString:@""]) {
        NSError *error;
        NSDictionary *customDict = [NSJSONSerialization JSONObjectWithData:[customAngles dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (!error && customDict) {
            if (customDict[@"fajrAngle"]) {
                fajrAngle = [customDict[@"fajrAngle"] doubleValue];
            }
            if (customDict[@"ishaAngle"]) {
                ishaAngle = [customDict[@"ishaAngle"] doubleValue];
                ishaIsInterval = NO;
            }
            if (customDict[@"ishaInterval"]) {
                ishaInterval = [customDict[@"ishaInterval"] doubleValue];
                ishaIsInterval = YES;
            }
        }
    }
    
    // Calculate prayer times using more accurate astronomical calculations
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:calculationTimeZone];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    
    // Calculate day of year and equation of time for more accuracy
    NSInteger dayOfYear = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:date];
    double P = asin(0.39795 * cos(0.98563 * (dayOfYear - 173) * M_PI / 180.0));
    double argument = (0.0145 * sin(4 * M_PI * (dayOfYear - 81) / 365.0) - 0.1679 * sin(2 * M_PI * (dayOfYear - 81) / 365.0));
    double equationOfTime = 4 * (longitude - 15 * ([calculationTimeZone secondsFromGMT] / 3600.0)) + 4 * argument;
    
    // Calculate solar noon
    double solarNoon = 12.0 - equationOfTime / 60.0;
    
    // Calculate sunrise and sunset
    double hourAngleSunrise = acos(-tan(latitude * M_PI / 180.0) * tan(P)) * 180.0 / M_PI / 15.0;
    double sunrise = solarNoon - hourAngleSunrise;
    double sunset = solarNoon + hourAngleSunrise;
    
    // Calculate Fajr
    double fajrHourAngle = acos((-sin(fajrAngle * M_PI / 180.0) - sin(latitude * M_PI / 180.0) * sin(P)) / (cos(latitude * M_PI / 180.0) * cos(P))) * 180.0 / M_PI / 15.0;
    double fajr = solarNoon - fajrHourAngle;
    
    // Calculate Asr (consider Madhab)
    double asrAltitude = atan(1.0 / (1.0 + tan((90.0 - latitude) * M_PI / 180.0) * tan(P) + ([madhab isEqualToString:@"Hanafi"] ? 2.0 : 1.0))) * 180.0 / M_PI;
    double asrHourAngle = acos((sin(asrAltitude * M_PI / 180.0) - sin(latitude * M_PI / 180.0) * sin(P)) / (cos(latitude * M_PI / 180.0) * cos(P))) * 180.0 / M_PI / 15.0;
    double asr = solarNoon + asrHourAngle;
    
    // Calculate Isha
    double isha;
    if (ishaIsInterval) {
        isha = sunset + ishaInterval / 60.0;
    } else {
        double ishaHourAngle = acos((-sin(ishaAngle * M_PI / 180.0) - sin(latitude * M_PI / 180.0) * sin(P)) / (cos(latitude * M_PI / 180.0) * cos(P))) * 180.0 / M_PI / 15.0;
        isha = solarNoon + ishaHourAngle;
    }
    
    // Apply adjustments if provided
    NSDictionary *adj = nil;
    if (adjustments && ![adjustments isEqualToString:@""]) {
        NSError *error;
        adj = [NSJSONSerialization JSONObjectWithData:[adjustments dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    }
    
    // Create final dates with adjustments
    [components setHour:(int)fajr];
    [components setMinute:(int)((fajr - (int)fajr) * 60) + (adj && adj[@"fajr"] ? [adj[@"fajr"] intValue] : 0)];
    NSDate *fajrTime = [calendar dateFromComponents:components];
    
    [components setHour:(int)sunrise];
    [components setMinute:(int)((sunrise - (int)sunrise) * 60) + (adj && adj[@"sunrise"] ? [adj[@"sunrise"] intValue] : 0)];
    NSDate *sunriseTime = [calendar dateFromComponents:components];
    
    [components setHour:(int)solarNoon];
    [components setMinute:(int)((solarNoon - (int)solarNoon) * 60) + (adj && adj[@"dhuhr"] ? [adj[@"dhuhr"] intValue] : 0)];
    NSDate *dhuhrTime = [calendar dateFromComponents:components];
    
    [components setHour:(int)asr];
    [components setMinute:(int)((asr - (int)asr) * 60) + (adj && adj[@"asr"] ? [adj[@"asr"] intValue] : 0)];
    NSDate *asrTime = [calendar dateFromComponents:components];
    
    [components setHour:(int)sunset];
    [components setMinute:(int)((sunset - (int)sunset) * 60) + (adj && adj[@"maghrib"] ? [adj[@"maghrib"] intValue] : 0)];
    NSDate *maghribTime = [calendar dateFromComponents:components];
    
    [components setHour:(int)isha];
    [components setMinute:(int)((isha - (int)isha) * 60) + (adj && adj[@"isha"] ? [adj[@"isha"] intValue] : 0)];
    NSDate *ishaTime = [calendar dateFromComponents:components];
    
    result[@"fajr"] = [outputFormatter stringFromDate:fajrTime];
    result[@"sunrise"] = [outputFormatter stringFromDate:sunriseTime];
    result[@"dhuhr"] = [outputFormatter stringFromDate:dhuhrTime];
    result[@"asr"] = [outputFormatter stringFromDate:asrTime];
    result[@"maghrib"] = [outputFormatter stringFromDate:maghribTime];
    result[@"isha"] = [outputFormatter stringFromDate:ishaTime];
    
    // Convert to JSON string
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
    if (error) {
        return @"{}"; // Return empty JSON on error
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)getQiblaDirection:(double)latitude longitude:(double)longitude {
    // Makkah coordinates
    double makkahLat = 21.4225;
    double makkahLon = 39.8262;
    
    // Simple bearing calculation (Haversine formula)
    double lat1 = latitude * M_PI / 180.0;
    double lat2 = makkahLat * M_PI / 180.0;
    double deltaLon = (makkahLon - longitude) * M_PI / 180.0;
    
    double y = sin(deltaLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
    
    double direction = atan2(y, x) * 180.0 / M_PI;
    direction = fmod(direction + 360.0, 360.0);
    
    // Calculate distance using Haversine formula
    double R = 6371.0; // Earth's radius in km
    double dLat = (makkahLat - latitude) * M_PI / 180.0;
    double dLon = deltaLon;
    double a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = R * c;
    
    // Convert to compass bearing
    NSArray *bearings = @[@"N", @"NNE", @"NE", @"ENE", @"E", @"ESE", @"SE", @"SSE", 
                         @"S", @"SSW", @"SW", @"WSW", @"W", @"WNW", @"NW", @"NNW"];
    int index = (int)round(direction / 22.5) % 16;
    NSString *compassBearing = bearings[index];
    
    NSDictionary *result = @{
        @"direction": @(direction),
        @"distance": @(distance),
        @"compassBearing": compassBearing
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
    if (error) {
        return @"{}";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)getBulkPrayerTimes:(double)latitude
                       longitude:(double)longitude
                   startDateIso:(NSString *)startDateIso
                     endDateIso:(NSString *)endDateIso
                          method:(NSString *)method
                          madhab:(NSString *)madhab
                     adjustments:(NSString *)adjustments {
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *startDate = [inputFormatter dateFromString:startDateIso];
    NSDate *endDate = [inputFormatter dateFromString:endDateIso];
    
    if (!startDate || !endDate) {
        return @"[]"; // Return empty array on invalid dates
    }
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = startDate;
    
    while ([currentDate compare:endDate] != NSOrderedDescending) {
        NSString *dateIso = [inputFormatter stringFromDate:currentDate];
        NSString *prayerTimesJson = [self getPrayerTimes:latitude longitude:longitude dateIso:dateIso method:method madhab:madhab adjustments:adjustments];
        
        // Parse the JSON and add date field
        NSError *error;
        NSData *jsonData = [prayerTimesJson dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *prayerTimes = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error] mutableCopy];
        
        if (!error && prayerTimes) {
            prayerTimes[@"date"] = dateIso;
            [results addObject:prayerTimes];
        }
        
        currentDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:currentDate options:0];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:0 error:&error];
    if (error) {
        return @"[]";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)getAvailableMethods {
    NSArray *methods = @[
        @{
            @"method": @"ISNA",
            @"name": @"Islamic Society of North America",
            @"description": @"Used in North America",
            @"fajrAngle": @15,
            @"ishaAngle": @15,
            @"ishaInterval": @NO,
            @"regions": @[@"North America"]
        },
        @{
            @"method": @"MWL",
            @"name": @"Muslim World League",
            @"description": @"Used globally",
            @"fajrAngle": @18,
            @"ishaAngle": @17,
            @"ishaInterval": @NO,
            @"regions": @[@"Global"]
        }
    ];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:methods options:0 error:&error];
    if (error) {
        return @"[]";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (BOOL)validateCoordinates:(double)latitude longitude:(double)longitude {
    return (latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0);
}

- (NSString *)getModuleInfo {
    NSDictionary *info = @{
        @"version": @"1.0.0",
        @"buildDate": @"2025-01-01",
        @"nativeVersion": @"1.0.0",
        @"supportsNewArchitecture": @YES
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    if (error) {
        return @"{}";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)getPerformanceMetrics {
    NSDictionary *metrics = @{
        @"lastCalculationTime": @1,
        @"totalCalculations": @1,
        @"averageCalculationTime": @1,
        @"memoryUsage": @1024
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metrics options:0 error:&error];
    if (error) {
        return @"{}";
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)clearCache {
    // Implementation would clear any internal caches
}

- (void)setDebugLogging:(BOOL)enabled {
    // Implementation would enable/disable debug logging
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeAdhanSpecJSI>(params);
}

@end
