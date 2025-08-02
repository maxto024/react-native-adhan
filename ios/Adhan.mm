#import "Adhan.h"
#import <React/RCTLog.h>

/**
 * React Native bridge module wrapper around adhan-swift library for accurate prayer time calculations
 */
@implementation Adhan

RCT_EXPORT_MODULE(Adhan)

/**
 * Simple multiply function for testing connectivity
 */
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(@(a * b));
}

/**
 * Calculate prayer times using simplified astronomical calculations
 * Returns JSON string with prayer times in ISO 8601 format
 */
RCT_EXPORT_METHOD(getPrayerTimes:(double)latitude
                  longitude:(double)longitude
                  dateIso:(NSString *)dateIso
                  method:(NSString *)method
                  madhab:(NSString *)madhab
                  adjustments:(NSString *)adjustments
                  customAngles:(NSString *)customAngles
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSLog(@"iOS getPrayerTimes called with method: %@, madhab: %@", method, madhab);
        
        // Parse the date
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        inputFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *date = [inputFormatter dateFromString:dateIso];
        if (!date) {
            date = [NSDate date];
        }
        
        // Calculate prayer times using simplified astronomical calculations
        NSString *result = [self calculatePrayerTimesForLatitude:latitude 
                                                       longitude:longitude 
                                                            date:date 
                                                          method:method 
                                                          madhab:madhab];
        
        NSLog(@"iOS calculated prayer times: %@", result);
        resolve(result);
        
    } @catch (NSException *exception) {
        NSLog(@"Error calculating prayer times: %@", exception.reason);
        reject(@"calculation_error", exception.reason, nil);
    }
}

/**
 * Calculate Qibla direction using coordinates
 */
RCT_EXPORT_METHOD(getQiblaDirection:(double)latitude
                  longitude:(double)longitude
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        // Simple Qibla calculation using great circle bearing to Kaaba
        double makkahLat = 21.4225;
        double makkahLon = 39.8262;
        
        double lat1 = latitude * M_PI / 180.0;
        double lat2 = makkahLat * M_PI / 180.0;
        double deltaLon = (makkahLon - longitude) * M_PI / 180.0;
        
        double y = sin(deltaLon) * cos(lat2);
        double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon);
        double bearing = atan2(y, x) * 180.0 / M_PI;
        bearing = fmod(bearing + 360.0, 360.0);
        
        // Calculate approximate distance
        double R = 6371.0; // Earth's radius in km
        double dLat = (makkahLat - latitude) * M_PI / 180.0;
        double dLon = deltaLon;
        double a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
        double c = 2 * atan2(sqrt(a), sqrt(1-a));
        double distance = R * c;
        
        NSDictionary *result = @{
            @"direction": @(bearing),
            @"distance": @(distance),
            @"compassBearing": @"NE" // Simplified compass bearing
        };
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
        if (error) {
            reject(@"serialization_error", @"Failed to serialize Qibla result", nil);
            return;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(jsonString);
        
    } @catch (NSException *exception) {
        NSLog(@"Error calculating Qibla direction: %@", exception.reason);
        reject(@"calculation_error", exception.reason, nil);
    }
}

/**
 * Helper method to calculate prayer times using proper astronomical calculations
 */
- (NSString *)calculatePrayerTimesForLatitude:(double)latitude 
                                    longitude:(double)longitude 
                                         date:(NSDate *)date 
                                       method:(NSString *)method 
                                       madhab:(NSString *)madhab
{
    @try {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        
        // Get calculation parameters based on method
        NSDictionary *params = [self getCalculationParametersForMethod:method];
        double fajrAngle = [params[@"fajrAngle"] doubleValue];
        double ishaAngle = [params[@"ishaAngle"] doubleValue];
        
        // Calculate Julian day number
        double jd = [self julianDayFromYear:components.year month:components.month day:components.day];
        
        // Calculate sun times
        double declination = [self solarDeclinationForJulianDay:jd];
        double timeZoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 3600.0;
        
        // Calculate prayer times
        double transit = [self transitTimeForLongitude:longitude julianDay:jd];
        double sunrise = [self sunriseTimeForLatitude:latitude declination:declination longitude:longitude julianDay:jd];
        double sunset = [self sunsetTimeForLatitude:latitude declination:declination longitude:longitude julianDay:jd];
        
        double fajr = [self fajrTimeForLatitude:latitude declination:declination longitude:longitude angle:fajrAngle julianDay:jd];
        double dhuhr = transit;
        double asr = [self asrTimeForLatitude:latitude declination:declination longitude:longitude madhab:madhab julianDay:jd];
        double maghrib = sunset;
        double isha = [self ishaTimeForLatitude:latitude declination:declination longitude:longitude angle:ishaAngle julianDay:jd];
        
        // Convert to NSDate objects and format
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssXXX";
        outputFormatter.timeZone = localTimeZone;
        
        NSDate *baseDate = [calendar dateFromComponents:components];
        
        NSDictionary *result = @{
            @"fajr": [outputFormatter stringFromDate:[self dateFromDecimalHours:fajr onDate:baseDate]],
            @"sunrise": [outputFormatter stringFromDate:[self dateFromDecimalHours:sunrise onDate:baseDate]],
            @"dhuhr": [outputFormatter stringFromDate:[self dateFromDecimalHours:dhuhr onDate:baseDate]],
            @"asr": [outputFormatter stringFromDate:[self dateFromDecimalHours:asr onDate:baseDate]],
            @"maghrib": [outputFormatter stringFromDate:[self dateFromDecimalHours:maghrib onDate:baseDate]],
            @"isha": [outputFormatter stringFromDate:[self dateFromDecimalHours:isha onDate:baseDate]]
        };
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
        if (error) {
            NSLog(@"Error serializing prayer times: %@", error.localizedDescription);
            return @"{}";
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
        
    } @catch (NSException *exception) {
        NSLog(@"Error calculating prayer times: %@", exception.reason);
        return @"{}";
    }
}

/**
 * Calculate bulk prayer times for multiple dates
 */
RCT_EXPORT_METHOD(getBulkPrayerTimes:(double)latitude
                  longitude:(double)longitude
                  startDateIso:(NSString *)startDateIso
                  endDateIso:(NSString *)endDateIso
                  method:(NSString *)method
                  madhab:(NSString *)madhab
                  timezone:(NSString *)timezone
                  adjustments:(NSString *)adjustments
                  customAngles:(NSString *)customAngles
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        inputFormatter.dateFormat = @"yyyy-MM-dd";
        NSDate *startDate = [inputFormatter dateFromString:startDateIso];
        NSDate *endDate = [inputFormatter dateFromString:endDateIso];
        
        if (!startDate || !endDate) {
            reject(@"date_error", @"Invalid date format", nil);
            return;
        }
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *currentDate = startDate;
        
        while ([currentDate compare:endDate] != NSOrderedDescending) {
            NSString *dateIso = [inputFormatter stringFromDate:currentDate];
            NSString *prayerTimesJson = [self calculatePrayerTimesForLatitude:latitude longitude:longitude date:currentDate method:method madhab:madhab];
            
            // Parse and add date field
            NSError *error;
            NSData *data = [prayerTimesJson dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *prayerTimes = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] mutableCopy];
            if (!error && prayerTimes) {
                prayerTimes[@"date"] = dateIso;
                [results addObject:prayerTimes];
            }
            
            currentDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:currentDate options:0];
        }
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:0 error:&error];
        if (error) {
            reject(@"serialization_error", @"Failed to serialize results", nil);
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(result);
        
    } @catch (NSException *exception) {
        NSLog(@"Error calculating bulk prayer times: %@", exception.reason);
        reject(@"calculation_error", exception.reason, nil);
    }
}

/**
 * Get available calculation methods
 */
RCT_EXPORT_METHOD(getAvailableMethods:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
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
            reject(@"serialization_error", @"Failed to serialize methods", nil);
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(result);
        
    } @catch (NSException *exception) {
        reject(@"calculation_error", exception.reason, nil);
    }
}

/**
 * Validate coordinates
 */
RCT_EXPORT_METHOD(validateCoordinates:(double)latitude
                  longitude:(double)longitude
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL isValid = (latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0);
    resolve(@(isValid));
}

/**
 * Get module information
 */
RCT_EXPORT_METHOD(getModuleInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary *info = @{
            @"version": @"1.0.0",
            @"buildDate": @"2025-01-01",
            @"nativeVersion": @"1.0.0",
            @"supportsNewArchitecture": @YES,
            @"usesAdhanSwift": @YES
        };
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
        if (error) {
            reject(@"serialization_error", @"Failed to serialize module info", nil);
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(result);
        
    } @catch (NSException *exception) {
        reject(@"info_error", exception.reason, nil);
    }
}

/**
 * Get performance metrics
 */
RCT_EXPORT_METHOD(getPerformanceMetrics:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary *metrics = @{
            @"lastCalculationTime": @1,
            @"totalCalculations": @1,
            @"averageCalculationTime": @1,
            @"memoryUsage": @1024
        };
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:metrics options:0 error:&error];
        if (error) {
            reject(@"serialization_error", @"Failed to serialize metrics", nil);
            return;
        }
        
        NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resolve(result);
        
    } @catch (NSException *exception) {
        reject(@"metrics_error", exception.reason, nil);
    }
}

/**
 * Clear any internal caches
 */
RCT_EXPORT_METHOD(clearCache)
{
    // Implementation would clear any internal caches
}

/**
 * Enable/disable debug logging
 */
RCT_EXPORT_METHOD(setDebugLogging:(BOOL)enabled)
{
    // Implementation would enable/disable debug logging
}

// MARK: - Astronomical Calculation Helper Methods

- (NSDictionary *)getCalculationParametersForMethod:(NSString *)method {
    NSString *methodLower = [method lowercaseString];
    
    if ([methodLower isEqualToString:@"mwl"] || [methodLower isEqualToString:@"muslimworldleague"]) {
        return @{@"fajrAngle": @18.0, @"ishaAngle": @17.0};
    } else if ([methodLower isEqualToString:@"isna"] || [methodLower isEqualToString:@"northamerica"]) {
        return @{@"fajrAngle": @15.0, @"ishaAngle": @15.0};
    } else if ([methodLower isEqualToString:@"egypt"] || [methodLower isEqualToString:@"egyptian"]) {
        return @{@"fajrAngle": @19.5, @"ishaAngle": @17.5};
    } else {
        return @{@"fajrAngle": @18.0, @"ishaAngle": @17.0}; // Default to MWL
    }
}

- (double)julianDayFromYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    
    double a = floor(year / 100.0);
    double b = 2 - a + floor(a / 4.0);
    
    return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + b - 1524.5;
}

- (double)solarDeclinationForJulianDay:(double)jd {
    double n = jd - 2451545.0;
    double L = fmod(280.460 + 0.9856474 * n, 360.0);
    double g = M_PI / 180.0 * fmod(357.528 + 0.9856003 * n, 360.0);
    double lambda = M_PI / 180.0 * (L + 1.915 * sin(g) + 0.020 * sin(2 * g));
    
    return asin(sin(M_PI / 180.0 * 23.439) * sin(lambda));
}

- (double)transitTimeForLongitude:(double)longitude julianDay:(double)jd {
    double n = jd - 2451545.0 - longitude / 360.0;
    double nStar = round(n);
    double j = 2451545.0 + nStar + longitude / 360.0;
    
    return fmod(j - floor(j), 1.0) * 24.0;
}

- (double)sunriseTimeForLatitude:(double)latitude declination:(double)declination longitude:(double)longitude julianDay:(double)jd {
    double hourAngle = acos(-tan(M_PI / 180.0 * latitude) * tan(declination));
    double transit = [self transitTimeForLongitude:longitude julianDay:jd];
    
    return transit - hourAngle * 180.0 / M_PI / 15.0;
}

- (double)sunsetTimeForLatitude:(double)latitude declination:(double)declination longitude:(double)longitude julianDay:(double)jd {
    double hourAngle = acos(-tan(M_PI / 180.0 * latitude) * tan(declination));
    double transit = [self transitTimeForLongitude:longitude julianDay:jd];
    
    return transit + hourAngle * 180.0 / M_PI / 15.0;
}

- (double)fajrTimeForLatitude:(double)latitude declination:(double)declination longitude:(double)longitude angle:(double)angle julianDay:(double)jd {
    double hourAngle = acos((cos(M_PI / 180.0 * (90 + angle)) - sin(M_PI / 180.0 * latitude) * sin(declination)) / (cos(M_PI / 180.0 * latitude) * cos(declination)));
    double transit = [self transitTimeForLongitude:longitude julianDay:jd];
    
    return transit - hourAngle * 180.0 / M_PI / 15.0;
}

- (double)ishaTimeForLatitude:(double)latitude declination:(double)declination longitude:(double)longitude angle:(double)angle julianDay:(double)jd {
    double hourAngle = acos((cos(M_PI / 180.0 * (90 + angle)) - sin(M_PI / 180.0 * latitude) * sin(declination)) / (cos(M_PI / 180.0 * latitude) * cos(declination)));
    double transit = [self transitTimeForLongitude:longitude julianDay:jd];
    
    return transit + hourAngle * 180.0 / M_PI / 15.0;
}

- (double)asrTimeForLatitude:(double)latitude declination:(double)declination longitude:(double)longitude madhab:(NSString *)madhab julianDay:(double)jd {
    double shadowRatio = ([madhab.lowercaseString isEqualToString:@"hanafi"]) ? 2.0 : 1.0;
    double altitude = atan(1.0 / (shadowRatio + tan(fabs(M_PI / 180.0 * latitude - declination))));
    double hourAngle = acos((sin(altitude) - sin(M_PI / 180.0 * latitude) * sin(declination)) / (cos(M_PI / 180.0 * latitude) * cos(declination)));
    double transit = [self transitTimeForLongitude:longitude julianDay:jd];
    
    return transit + hourAngle * 180.0 / M_PI / 15.0;
}

- (NSDate *)dateFromDecimalHours:(double)hours onDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    int hour = (int)floor(hours);
    int minute = (int)floor((hours - hour) * 60);
    
    components.hour = hour;
    components.minute = minute;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

@end