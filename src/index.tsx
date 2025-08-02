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

// Calculation methods enum for convenience
export enum CalculationMethod {
  MUSLIM_WORLD_LEAGUE = 'muslimWorldLeague',
  EGYPTIAN = 'egyptian',
  KARACHI = 'karachi',
  UMM_AL_QURA = 'ummAlQura',
  DUBAI = 'dubai',
  MOON_SIGHTING_COMMITTEE = 'moonsightingCommittee',
  NORTH_AMERICA = 'northAmerica',
  KUWAIT = 'kuwait',
  QATAR = 'qatar',
  SINGAPORE = 'singapore',
  TEHRAN = 'tehran',
  TURKEY = 'turkey',
  OTHER = 'other',
}

// Madhab enum for convenience
export enum Madhab {
  SHAFI = 'shafi',
  HANAFI = 'hanafi',
}

// High latitude rule enum for convenience
export enum HighLatitudeRule {
  MIDDLE_OF_THE_NIGHT = 'middleOfTheNight',
  SEVENTH_OF_THE_NIGHT = 'seventhOfTheNight',
  TWILIGHT_ANGLE = 'twilightAngle',
}

// Rounding enum for convenience
export enum Rounding {
  NEAREST = 'nearest',
  UP = 'up',
  DOWN = 'down',
}

// Shafaq enum for convenience
export enum Shafaq {
  GENERAL = 'general',
  AHMER = 'ahmer',
  ABYAD = 'abyad',
}

// Prayer enum for convenience
export enum Prayer {
  FAJR = 'fajr',
  SUNRISE = 'sunrise',
  DHUHR = 'dhuhr',
  ASR = 'asr',
  MAGHRIB = 'maghrib',
  ISHA = 'isha',
}

/**
 * Calculate prayer times for a location and date
 */
export function calculatePrayerTimes(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<AdhanPrayerTimes> {
  return NativeAdhan.calculatePrayerTimes(coordinates, dateComponents, calculationParameters);
}

/**
 * Calculate Qibla direction for a location
 */
export function calculateQibla(coordinates: AdhanCoordinates): Promise<AdhanQibla> {
  return NativeAdhan.calculateQibla(coordinates);
}

/**
 * Calculate Sunnah times (middle of night, last third of night)
 */
export function calculateSunnahTimes(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<AdhanSunnahTimes> {
  return NativeAdhan.calculateSunnahTimes(coordinates, dateComponents, calculationParameters);
}

/**
 * Get current and next prayer for a given time
 */
export function getCurrentPrayer(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters,
  currentTime?: number
): Promise<AdhanCurrentPrayerInfo> {
  const time = currentTime ?? Date.now();
  return NativeAdhan.getCurrentPrayer(coordinates, dateComponents, calculationParameters, time);
}

/**
 * Get time for a specific prayer
 */
export function getTimeForPrayer(
  coordinates: AdhanCoordinates,
  dateComponents: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters,
  prayer: Prayer | string
): Promise<number | null> {
  const prayerName = prayer;
  return NativeAdhan.getTimeForPrayer(coordinates, dateComponents, calculationParameters, prayerName);
}

/**
 * Validate coordinates
 */
export function validateCoordinates(coordinates: AdhanCoordinates): Promise<boolean> {
  return NativeAdhan.validateCoordinates(coordinates);
}

/**
 * Get all available calculation methods
 */
export function getCalculationMethods(): AdhanCalculationMethodInfo[] {
  return NativeAdhan.getCalculationMethods();
}

/**
 * Get default calculation parameters for a method
 */
export function getMethodParameters(method: CalculationMethod | string): AdhanCalculationParameters {
  const methodName = method;
  return NativeAdhan.getMethodParameters(methodName);
}

/**
 * Calculate prayer times for a date range (bulk calculation)
 */
export function calculatePrayerTimesRange(
  coordinates: AdhanCoordinates,
  startDate: AdhanDateComponents,
  endDate: AdhanDateComponents,
  calculationParameters: AdhanCalculationParameters
): Promise<Array<{ date: AdhanDateComponents; prayerTimes: AdhanPrayerTimes }>> {
  return NativeAdhan.calculatePrayerTimesRange(coordinates, startDate, endDate, calculationParameters);
}

/**
 * Get library version and metadata
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
 * Utility function to create date components from JavaScript Date
 */
export function dateComponentsFromDate(date: Date): AdhanDateComponents {
  return {
    year: date.getFullYear(),
    month: date.getMonth() + 1, // JavaScript months are 0-indexed
    day: date.getDate(),
  };
}

/**
 * Utility function to convert Unix timestamp to JavaScript Date
 */
export function timestampToDate(timestamp: number): Date {
  return new Date(timestamp);
}

/**
 * Utility function to convert prayer times to JavaScript Dates
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
