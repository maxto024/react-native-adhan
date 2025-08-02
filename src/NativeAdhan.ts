import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

// Core data structures

export interface AdhanCoordinates {
  latitude: number;
  longitude: number;
}

export interface AdhanDateComponents {
  year: number;
  month: number;
  day: number;
}

export interface AdhanPrayerAdjustments {
  fajr?: number;
  sunrise?: number;
  dhuhr?: number;
  asr?: number;
  maghrib?: number;
  isha?: number;
}

export interface AdhanCalculationParameters {
  method?: string; // Calculation method name
  fajrAngle?: number;
  ishaAngle?: number;
  ishaInterval?: number; // Minutes after Maghrib
  madhab?: string; // 'shafi' or 'hanafi'
  highLatitudeRule?: string; // 'middleOfTheNight', 'seventhOfTheNight', 'twilightAngle'
  prayerAdjustments?: AdhanPrayerAdjustments;
  methodAdjustments?: AdhanPrayerAdjustments;
  rounding?: string; // 'nearest', 'up', 'down'
  shafaq?: string; // 'general', 'ahmer', 'abyad'
  maghribAngle?: number;
}

export interface AdhanPrayerTimes {
  fajr: number; // Unix timestamp in milliseconds
  sunrise: number;
  dhuhr: number;
  asr: number;
  maghrib: number;
  isha: number;
}

export interface AdhanSunnahTimes {
  middleOfTheNight: number; // Unix timestamp in milliseconds
  lastThirdOfTheNight: number;
}

export interface AdhanQibla {
  direction: number; // Degrees from North
}

export interface AdhanCurrentPrayerInfo {
  current: string; // Prayer name or 'none'
  next: string; // Next prayer name or 'none'
}

// Pre-defined calculation methods
export interface AdhanCalculationMethodInfo {
  name: string;
  displayName: string;
  fajrAngle: number;
  ishaAngle: number;
  ishaInterval: number;
  description: string;
}

export interface Spec extends TurboModule {
  /**
   * Calculate prayer times for a location and date
   * @param coordinates Location coordinates
   * @param dateComponents Date components (year, month, day)
   * @param calculationParameters Calculation parameters
   * @returns Prayer times in UTC as Unix timestamps (milliseconds)
   */
  calculatePrayerTimes(
    coordinates: AdhanCoordinates,
    dateComponents: AdhanDateComponents,
    calculationParameters: AdhanCalculationParameters
  ): Promise<AdhanPrayerTimes>;

  /**
   * Calculate Qibla direction for a location
   * @param coordinates Location coordinates
   * @returns Qibla direction in degrees from North
   */
  calculateQibla(coordinates: AdhanCoordinates): Promise<AdhanQibla>;

  /**
   * Calculate Sunnah times (middle of night, last third of night)
   * @param coordinates Location coordinates
   * @param dateComponents Date components
   * @param calculationParameters Calculation parameters
   * @returns Sunnah times in UTC as Unix timestamps (milliseconds)
   */
  calculateSunnahTimes(
    coordinates: AdhanCoordinates,
    dateComponents: AdhanDateComponents,
    calculationParameters: AdhanCalculationParameters
  ): Promise<AdhanSunnahTimes>;

  /**
   * Get current and next prayer for a given time
   * @param coordinates Location coordinates
   * @param dateComponents Date components
   * @param calculationParameters Calculation parameters
   * @param currentTime Current time as Unix timestamp (milliseconds)
   * @returns Current and next prayer information
   */
  getCurrentPrayer(
    coordinates: AdhanCoordinates,
    dateComponents: AdhanDateComponents,
    calculationParameters: AdhanCalculationParameters,
    currentTime: number
  ): Promise<AdhanCurrentPrayerInfo>;

  /**
   * Get time for a specific prayer
   * @param coordinates Location coordinates
   * @param dateComponents Date components
   * @param calculationParameters Calculation parameters
   * @param prayer Prayer name ('fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha')
   * @returns Prayer time in UTC as Unix timestamp (milliseconds), or null if invalid
   */
  getTimeForPrayer(
    coordinates: AdhanCoordinates,
    dateComponents: AdhanDateComponents,
    calculationParameters: AdhanCalculationParameters,
    prayer: string
  ): Promise<number | null>;

  /**
   * Validate coordinates
   * @param coordinates Location coordinates to validate
   * @returns true if coordinates are valid, false otherwise
   */
  validateCoordinates(coordinates: AdhanCoordinates): Promise<boolean>;

  /**
   * Get all available calculation methods
   * @returns Array of calculation method information
   */
  getCalculationMethods(): AdhanCalculationMethodInfo[];

  /**
   * Get default calculation parameters for a method
   * @param method Method name
   * @returns Default calculation parameters for the method
   */
  getMethodParameters(method: string): AdhanCalculationParameters;

  /**
   * Calculate prayer times for a date range (bulk calculation)
   * @param coordinates Location coordinates
   * @param startDate Start date components
   * @param endDate End date components
   * @param calculationParameters Calculation parameters
   * @returns Array of prayer times for each date
   */
  calculatePrayerTimesRange(
    coordinates: AdhanCoordinates,
    startDate: AdhanDateComponents,
    endDate: AdhanDateComponents,
    calculationParameters: AdhanCalculationParameters
  ): Promise<Array<{ date: AdhanDateComponents; prayerTimes: AdhanPrayerTimes }>>;

  /**
   * Get library version and metadata
   * @returns Version and metadata information
   */
  getLibraryInfo(): {
    version: string;
    swiftLibraryVersion?: string;
    kotlinLibraryVersion?: string;
    platform: string;
  };
}

export default TurboModuleRegistry.getEnforcing<Spec>('Adhan');
