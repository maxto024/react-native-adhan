import NativeAdhan from './NativeAdhan';
import type {
  AdhanCoordinates,
  AdhanDateComponents,
  AdhanCalculationParameters,
  AdhanPrayerTimes,
  AdhanSunnahTimes,
  AdhanQibla,
  AdhanCurrentPrayerInfo,
  AdhanCalculationMethodInfo,
  AdhanPrayerAdjustments,
} from './NativeAdhan';

// Re-export types for consumers
export type {
  AdhanCoordinates,
  AdhanDateComponents,
  AdhanCalculationParameters,
  AdhanPrayerTimes,
  AdhanSunnahTimes,
  AdhanQibla,
  AdhanCurrentPrayerInfo,
  AdhanCalculationMethodInfo,
  AdhanPrayerAdjustments,
};

/**
 * Enumeration of supported calculation methods for prayer times.
 *
 * Each method represents different calculation standards used by Islamic
 * organizations worldwide. Methods differ in the angles used for Fajr
 * and Isha calculations, and some use fixed intervals instead of angles.
 */
export enum CalculationMethod {
  /** Muslim World League - Standard method using 18°/17° */
  MUSLIM_WORLD_LEAGUE = 'muslimWorldLeague',
  /** Egyptian General Authority of Survey - Early Fajr with 19.5°/17.5° */
  EGYPTIAN = 'egyptian',
  /** University of Islamic Sciences, Karachi - General purpose 18°/18° */
  KARACHI = 'karachi',
  /** Umm al-Qura University, Makkah - 18.5° Fajr, 90min interval for Isha */
  UMM_AL_QURA = 'ummAlQura',
  /** UAE calculation method - 18.2°/18.2° */
  DUBAI = 'dubai',
  /** Moonsighting Committee - 18°/18° with seasonal adjustments */
  MOON_SIGHTING_COMMITTEE = 'moonsightingCommittee',
  /** ISNA (North America) - Later Fajr/earlier Isha with 15°/15° */
  NORTH_AMERICA = 'northAmerica',
  /** Kuwait calculation method - 18°/17.5° */
  KUWAIT = 'kuwait',
  /** Qatar calculation method - 18° Fajr, 90min interval for Isha */
  QATAR = 'qatar',
  /** Singapore method - Early Fajr 20°, standard Isha 18° */
  SINGAPORE = 'singapore',
  /** Tehran calculation method - 17.7°/14° with 4.5° Maghrib */
  TEHRAN = 'tehran',
  /** Turkey (Diyanet) method - 18°/17° */
  TURKEY = 'turkey',
  /** Custom method - for manual parameter specification */
  OTHER = 'other',
}

/**
 * Enumeration of Islamic jurisprudence schools (madhabs) for Asr calculation.
 *
 * Different madhabs use different methods to determine when Asr prayer begins:
 * - Shafi: When shadow length equals object height plus noon shadow
 * - Hanafi: When shadow length equals twice the object height plus noon shadow
 */
export enum Madhab {
  /** Shafi madhab - Earlier Asr time (standard method) */
  SHAFI = 'shafi',
  /** Hanafi madhab - Later Asr time */
  HANAFI = 'hanafi',
}

/**
 * Enumeration of high latitude rules for extreme northern/southern locations.
 *
 * In areas where twilight persists all night (e.g., Nordic countries in summer),
 * special rules are needed to determine Fajr and Isha times.
 */
export enum HighLatitudeRule {
  /** Use the middle of the night between sunset and sunrise */
  MIDDLE_OF_THE_NIGHT = 'middleOfTheNight',
  /** Use 1/7th of the night for twilight periods */
  SEVENTH_OF_THE_NIGHT = 'seventhOfTheNight',
  /** Use a fixed twilight angle regardless of season */
  TWILIGHT_ANGLE = 'twilightAngle',
}

/**
 * Enumeration of time rounding methods for prayer times.
 *
 * Determines how calculated prayer times are rounded to the nearest minute.
 */
export enum Rounding {
  /** Round to the nearest minute */
  NEAREST = 'nearest',
  /** Always round up to the next minute */
  UP = 'up',
  /** Always round down to the previous minute */
  DOWN = 'down',
}

/**
 * Enumeration of twilight types (shafaq) for Isha calculation.
 *
 * Different interpretations of twilight in Islamic jurisprudence:
 * - General: Combination of red and white twilight (most common)
 * - Ahmer: Red twilight only (earlier Isha)
 * - Abyad: White twilight only (later Isha)
 */
export enum Shafaq {
  /** General twilight (red and white) - most commonly used */
  GENERAL = 'general',
  /** Red twilight only - earlier Isha time */
  AHMER = 'ahmer',
  /** White twilight only - later Isha time */
  ABYAD = 'abyad',
}

/**
 * Enumeration of prayer names and solar events.
 *
 * Represents the five daily prayers plus sunrise (which marks the end of Fajr time).
 */
export enum Prayer {
  /** Dawn prayer - first prayer of the day */
  FAJR = 'fajr',
  /** Sunrise - end of Fajr time (not a prayer) */
  SUNRISE = 'sunrise',
  /** Noon prayer - when sun passes meridian */
  DHUHR = 'dhuhr',
  /** Afternoon prayer - based on shadow length */
  ASR = 'asr',
  /** Sunset prayer - at sunset */
  MAGHRIB = 'maghrib',
  /** Night prayer - after twilight disappears */
  ISHA = 'isha',
}

/**
 * Calculate prayer times for a specific location and date.
 *
 * This function calculates all six prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
 * using authentic Islamic calculation methods. All times are returned as Unix timestamps
 * in milliseconds (UTC).
 *
 * @param coordinates - Geographic coordinates (latitude/longitude)
 * @param dateComponents - Date for calculation (year, month, day)
 * @param calculationParameters - Calculation method and settings
 * @returns Promise resolving to prayer times as Unix timestamps in milliseconds
 *
 * @example
 * ```typescript
 * import { calculatePrayerTimes, CalculationMethod, Madhab, dateComponentsFromDate } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 21.4225, longitude: 39.8262 }; // Makkah
 * const today = dateComponentsFromDate(new Date());
 * const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE, madhab: Madhab.SHAFI };
 *
 * const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
 * console.log('Fajr:', new Date(prayerTimes.fajr).toLocaleTimeString());
 * ```
 */
export function calculatePrayerTimes(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<AdhanPrayerTimes> {
  return NativeAdhan.calculatePrayerTimes(
    coordinates,
    dateComponents,
    calculationParameters
  );
}

/**
 * Calculate the Qibla direction (direction to Kaaba in Makkah) from any location.
 *
 * The Qibla is the direction Muslims face during prayer. This function calculates
 * the accurate bearing from your location to the Kaaba in Makkah, Saudi Arabia.
 *
 * @param coordinates - Geographic coordinates of your current location
 * @returns Promise resolving to Qibla direction in degrees from True North (0-360°)
 *
 * @example
 * ```typescript
 * import { calculateQibla } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 40.7128, longitude: -74.0060 }; // New York
 * const qibla = await calculateQibla(coordinates);
 * console.log(`Face ${qibla.direction.toFixed(1)}° from North for prayer`);
 * ```
 */
export function calculateQibla(
  coordinates: AdhanCoordinates
): Promise<AdhanQibla> {
  return NativeAdhan.calculateQibla(coordinates);
}

/**
 * Calculate Sunnah times for additional Islamic observances.
 *
 * Calculates special times recommended in Islamic tradition:
 * - Middle of the Night: Halfway between Maghrib and Fajr, ideal for Tahajjud prayer
 * - Last Third of the Night: Beginning of the last third period, highly recommended for prayer
 *
 * @param coordinates - Geographic coordinates
 * @param dateComponents - Date for calculation
 * @param calculationParameters - Calculation settings
 * @returns Promise resolving to Sunnah times as Unix timestamps in milliseconds
 *
 * @example
 * ```typescript
 * import { calculateSunnahTimes, CalculationMethod, dateComponentsFromDate } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 21.4225, longitude: 39.8262 };
 * const today = dateComponentsFromDate(new Date());
 * const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE };
 *
 * const sunnahTimes = await calculateSunnahTimes(coordinates, today, params);
 * const middleOfNight = new Date(sunnahTimes.middleOfTheNight);
 * console.log('Best time for Tahajjud:', middleOfNight.toLocaleTimeString());
 * ```
 */
export function calculateSunnahTimes(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<AdhanSunnahTimes> {
  return NativeAdhan.calculateSunnahTimes(
    coordinates,
    dateComponents,
    calculationParameters
  );
}

/**
 * Determine which prayer is currently active and which prayer comes next.
 *
 * This function analyzes the current time against the day's prayer schedule
 * to identify the current prayer period and the upcoming prayer.
 *
 * @param coordinates - Geographic coordinates
 * @param dateComponents - Date for calculation
 * @param calculationParameters - Calculation settings
 * @param currentTime - Unix timestamp in milliseconds (defaults to current time)
 * @returns Promise resolving to current and next prayer information
 *
 * @example
 * ```typescript
 * import { getCurrentPrayer, CalculationMethod, dateComponentsFromDate } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 40.7128, longitude: -74.0060 };
 * const today = dateComponentsFromDate(new Date());
 * const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE };
 *
 * const currentPrayer = await getCurrentPrayer(coordinates, today, params);
 * console.log(`Current: ${currentPrayer.current}, Next: ${currentPrayer.next}`);
 * ```
 */
export function getCurrentPrayer(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters,
  currentTime?: number
): Promise<AdhanCurrentPrayerInfo> {
  const time = currentTime ?? Date.now();
  return NativeAdhan.getCurrentPrayer(
    coordinates,
    dateComponents,
    calculationParameters,
    time
  );
}

/**
 * Get the exact time for a specific prayer.
 *
 * Retrieves the calculated time for an individual prayer rather than
 * calculating all prayer times. Returns null for invalid prayer names.
 *
 * @param coordinates - Geographic coordinates
 * @param dateComponents - Date for calculation
 * @param calculationParameters - Calculation settings
 * @param prayer - Prayer name: 'fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'
 * @returns Promise resolving to prayer time as Unix timestamp in milliseconds, or null
 *
 * @example
 * ```typescript
 * import { getTimeForPrayer, Prayer, CalculationMethod, dateComponentsFromDate } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 21.4225, longitude: 39.8262 };
 * const today = dateComponentsFromDate(new Date());
 * const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE };
 *
 * const dhuhrTime = await getTimeForPrayer(coordinates, today, params, Prayer.DHUHR);
 * if (dhuhrTime) {
 *   console.log('Dhuhr time:', new Date(dhuhrTime).toLocaleTimeString());
 * }
 * ```
 */
export function getTimeForPrayer(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters,
  prayer: Prayer | string
): Promise<number | null> {
  const prayerName = prayer;
  return NativeAdhan.getTimeForPrayer(
    coordinates,
    dateComponents,
    calculationParameters,
    prayerName
  );
}

/**
 * Validate geographic coordinates for prayer time calculations.
 *
 * Ensures coordinates are within valid ranges:
 * - Latitude: -90° to +90° (South to North)
 * - Longitude: -180° to +180° (West to East)
 *
 * @param coordinates - Geographic coordinates to validate
 * @returns true if coordinates are valid, false otherwise
 *
 * @example
 * ```typescript
 * import { validateCoordinates } from 'react-native-adhan';
 *
 * const validCoords = { latitude: 21.4225, longitude: 39.8262 };
 * const invalidCoords = { latitude: 100, longitude: 200 };
 *
 * console.log(validateCoordinates(validCoords));   // true
 * console.log(validateCoordinates(invalidCoords)); // false
 * ```
 */
export function validateCoordinates(coordinates: AdhanCoordinates): boolean {
  return (
    coordinates.latitude >= -90 &&
    coordinates.latitude <= 90 &&
    coordinates.longitude >= -180 &&
    coordinates.longitude <= 180
  );
}

/**
 * Get detailed information about all available calculation methods.
 *
 * Returns comprehensive information about each supported calculation method,
 * including the organization name, angles used, and descriptions. Useful for
 * building UI selection components or understanding method differences.
 *
 * @returns Array of calculation method information objects
 *
 * @example
 * ```typescript
 * import { getCalculationMethods } from 'react-native-adhan';
 *
 * const methods = getCalculationMethods();
 * methods.forEach(method => {
 *   console.log(`${method.displayName}: ${method.description}`);
 *   console.log(`Fajr: ${method.fajrAngle}°, Isha: ${method.ishaAngle}°`);
 * });
 * ```
 */
export function getCalculationMethods(): AdhanCalculationMethodInfo[] {
  return NativeAdhan.getCalculationMethods();
}

/**
 * Get default calculation parameters for a specific method.
 *
 * Retrieves the standard parameters (angles, madhab, etc.) used by
 * a calculation method. Useful for understanding method configurations
 * or as a starting point for custom adjustments.
 *
 * @param method - Calculation method name
 * @returns Promise resolving to default parameters for the method
 *
 * @example
 * ```typescript
 * import { getMethodParameters, CalculationMethod } from 'react-native-adhan';
 *
 * const params = await getMethodParameters(CalculationMethod.EGYPTIAN);
 * console.log(`Egyptian method uses ${params.fajrAngle}° for Fajr`);
 * console.log(`Default madhab: ${params.madhab}`);
 * ```
 */
export function getMethodParameters(
  method: CalculationMethod | string
): Promise<AdhanCalculationParameters> {
  const methodName = typeof method === 'string' ? method : method;
  return NativeAdhan.getMethodParameters(methodName);
}

/**
 * Calculate prayer times for multiple consecutive days (bulk calculation).
 *
 * Efficiently calculates prayer times for a date range, useful for generating
 * monthly prayer timetables or calendar applications. More efficient than
 * calling calculatePrayerTimes multiple times.
 *
 * @param coordinates - Geographic coordinates
 * @param startDate - Start date (inclusive)
 * @param endDate - End date (inclusive)
 * @param calculationParameters - Calculation settings
 * @returns Promise resolving to array of date/prayer-time pairs
 *
 * @example
 * ```typescript
 * import { calculatePrayerTimesRange, CalculationMethod, dateComponentsFromDate } from 'react-native-adhan';
 *
 * const coordinates = { latitude: 21.4225, longitude: 39.8262 };
 * const startDate = dateComponentsFromDate(new Date());
 * const endDate = dateComponentsFromDate(new Date(Date.now() + 7*24*60*60*1000)); // 7 days later
 * const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE };
 *
 * const weeklyTimes = await calculatePrayerTimesRange(coordinates, startDate, endDate, params);
 * weeklyTimes.forEach(({ date, prayerTimes }) => {
 *   console.log(`${date.year}-${date.month}-${date.day}:`, new Date(prayerTimes.fajr));
 * });
 * ```
 */
export function calculatePrayerTimesRange(
  coordinates: AdhanCoordinates,
  startDate: AdhanDateComponents,
  endDate: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<
  Array<{ date: AdhanDateComponents; prayerTimes: AdhanPrayerTimes }>
> {
  return NativeAdhan.calculatePrayerTimesRange(
    coordinates,
    startDate,
    endDate,
    calculationParameters
  );
}

/**
 * Get library version and platform metadata.
 *
 * Returns information about the current library version and the underlying
 * native calculation libraries being used on each platform.
 *
 * @returns Object containing version and platform information
 *
 * @example
 * ```typescript
 * import { getLibraryInfo } from 'react-native-adhan';
 *
 * const info = getLibraryInfo();
 * console.log(`react-native-adhan v${info.version} on ${info.platform}`);
 * if (info.swiftLibraryVersion) {
 *   console.log(`Using adhan-swift v${info.swiftLibraryVersion}`);
 * }
 * ```
 */
export function getLibraryInfo(): {
  version: string;
  swiftLibraryVersion?: string;
  kotlinLibraryVersion?: string;
  platform: string;
} {
  return NativeAdhan.getLibraryInfo();
}

/**
 * Convert a JavaScript Date object to date components format.
 *
 * Converts a standard JavaScript Date to the AdhanDateComponents format
 * required by prayer time calculation functions. Handles timezone conversion
 * and month indexing automatically.
 *
 * @param date - JavaScript Date object to convert
 * @returns Date components in {year, month, day} format (month is 1-indexed)
 *
 * @example
 * ```typescript
 * import { dateComponentsFromDate } from 'react-native-adhan';
 *
 * const today = dateComponentsFromDate(new Date());
 * const tomorrow = dateComponentsFromDate(new Date(Date.now() + 24*60*60*1000));
 *
 * console.log(today);    // { year: 2024, month: 1, day: 15 }
 * console.log(tomorrow); // { year: 2024, month: 1, day: 16 }
 * ```
 */
export function dateComponentsFromDate(date: Date): AdhanDateComponents {
  return {
    year: date.getFullYear(),
    month: date.getMonth() + 1, // JavaScript months are 0-indexed
    day: date.getDate(),
  };
}

/**
 * Convert a Unix timestamp (milliseconds) to a JavaScript Date object.
 *
 * Converts prayer time timestamps returned by calculation functions
 * into standard JavaScript Date objects for easier handling and formatting.
 *
 * @param timestamp - Unix timestamp in milliseconds
 * @returns JavaScript Date object
 *
 * @example
 * ```typescript
 * import { timestampToDate, calculatePrayerTimes } from 'react-native-adhan';
 *
 * const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
 * const fajrDate = timestampToDate(prayerTimes.fajr);
 *
 * console.log('Fajr time:', fajrDate.toLocaleTimeString());
 * console.log('Fajr date:', fajrDate.toLocaleDateString());
 * ```
 */
export function timestampToDate(timestamp: number): Date {
  return new Date(timestamp);
}

/**
 * Convert all prayer times to JavaScript Date objects for easy handling.
 *
 * Transforms an entire AdhanPrayerTimes object (with Unix timestamps)
 * into an object with JavaScript Date objects. This is the most convenient
 * way to work with prayer times in applications.
 *
 * @param prayerTimes - Prayer times object with Unix timestamps
 * @returns Object with the same structure but Date objects instead of timestamps
 *
 * @example
 * ```typescript
 * import { prayerTimesToDates, calculatePrayerTimes } from 'react-native-adhan';
 *
 * const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
 * const prayerDates = prayerTimesToDates(prayerTimes);
 *
 * console.log("Today's Prayer Times:");
 * console.log('Fajr:', prayerDates.fajr.toLocaleTimeString());
 * console.log('Dhuhr:', prayerDates.dhuhr.toLocaleTimeString());
 * console.log('Maghrib:', prayerDates.maghrib.toLocaleTimeString());
 * ```
 */
export function prayerTimesToDates(prayerTimes: AdhanPrayerTimes): {
  fajr: Date;
  sunrise: Date;
  dhuhr: Date;
  asr: Date;
  maghrib: Date;
  isha: Date;
} {
  return {
    fajr: new Date(prayerTimes.fajr),
    sunrise: new Date(prayerTimes.sunrise),
    dhuhr: new Date(prayerTimes.dhuhr),
    asr: new Date(prayerTimes.asr),
    maghrib: new Date(prayerTimes.maghrib),
    isha: new Date(prayerTimes.isha),
  };
}

// Default export for convenience
export default {
  calculatePrayerTimes,
  calculateQibla,
  calculateSunnahTimes,
  getCurrentPrayer,
  getTimeForPrayer,
  validateCoordinates,
  getCalculationMethods,
  getMethodParameters,
  calculatePrayerTimesRange,
  getLibraryInfo,
  dateComponentsFromDate,
  timestampToDate,
  prayerTimesToDates,
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
  Shafaq,
  Prayer,
};
