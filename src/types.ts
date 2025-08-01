/**
 * Comprehensive TypeScript types for react-native-adhan
 * Provides full type safety for Islamic prayer time calculations
 */

/**
 * Supported calculation methods for prayer times
 * Each method has different angle calculations based on religious authorities
 */
export enum CalculationMethod {
  /** Islamic Society of North America (15° fajr, 15° isha) */
  ISNA = 'ISNA',
  /** Muslim World League (18° fajr, 17° isha) */
  MWL = 'MWL',
  /** University of Islamic Sciences, Karachi (18° fajr, 18° isha) */
  Karachi = 'Karachi',
  /** Egyptian General Authority of Survey (19.5° fajr, 17.5° isha) */
  Egypt = 'Egypt',
  /** Umm Al-Qura University, Makkah (18.5° fajr, 90 min after maghrib) */
  UmmAlQura = 'UmmAlQura',
  /** Dubai (18.2° fajr, 18.2° isha) */
  Dubai = 'Dubai',
  /** Moonsighting Committee Worldwide (18° fajr, 18° isha) */
  Moonsighting = 'Moonsighting',
  /** Kuwait (18° fajr, 17.5° isha) */
  Kuwait = 'Kuwait',
  /** Qatar (18° fajr, 90 min after maghrib) */
  Qatar = 'Qatar',
  /** Singapore (20° fajr, 18° isha) */
  Singapore = 'Singapore',
  /** Tehran (17.7° fajr, 14° isha) */
  Tehran = 'Tehran',
  /** Turkey (18° fajr, 17° isha) */
  Turkey = 'Turkey',
}

/**
 * Islamic schools of jurisprudence for Asr calculation
 */
export enum Madhab {
  /** Shafi, Maliki, Hanbali schools - Asr when shadow = object length */
  Shafi = 'Shafi',
  /** Hanafi school - Asr when shadow = 2x object length */
  Hanafi = 'Hanafi',
}

/**
 * High noon adjustment methods for locations with extreme latitudes
 */
export enum HighLatitudeRule {
  /** Default - no adjustment */
  None = 'None',
  /** Middle of the night method */
  MiddleOfTheNight = 'MiddleOfTheNight',
  /** One-seventh of the night method */
  SeventhOfTheNight = 'SeventhOfTheNight',
  /** Twilight angle-based method */
  TwilightAngle = 'TwilightAngle',
}

/**
 * Rounding methods for prayer times
 */
export enum Rounding {
  /** No rounding */
  None = 'None',
  /** Round to nearest minute */
  Nearest = 'Nearest',
  /** Always round up */
  Up = 'Up',
  /** Always round down */
  Down = 'Down',
}

/**
 * Geographic coordinates with validation
 */
export interface Coordinates {
  /** Latitude in decimal degrees (-90 to 90) */
  latitude: number;
  /** Longitude in decimal degrees (-180 to 180) */
  longitude: number;
  /** Optional elevation in meters above sea level */
  elevation?: number;
}

/**
 * Date specification for prayer time calculations
 */
export interface DateInput {
  /** Year (e.g., 2024) */
  year: number;
  /** Month (1-12) */
  month: number;
  /** Day of month (1-31) */
  day: number;
}

/**
 * Advanced calculation parameters for prayer times
 * 
 * @default method: CalculationMethod.MWL (Muslim World League)
 * @default madhab: Madhab.Shafi (shadow length = 1.0)
 * @default rounding: Rounding.Nearest
 * @default adjustments: All prayers = 0 minutes
 * @default highLatitudeRule: None (no special rule)
 */
export interface CalculationParameters {
  /** Calculation method @default CalculationMethod.MWL */
  method: CalculationMethod;
  /** School of jurisprudence for Asr calculation @default Madhab.Shafi */
  madhab?: Madhab;
  /** High latitude adjustment rule @default none */
  highLatitudeRule?: HighLatitudeRule;
  /** Custom fajr angle in degrees (overrides method default) */
  fajrAngle?: number;
  /** Custom isha angle in degrees (overrides method default) */
  ishaAngle?: number;
  /** Custom isha interval in minutes after maghrib */
  ishaInterval?: number;
  /** Custom maghrib angle in degrees */
  maghribAngle?: number;
  /** Minutes to add/subtract from each prayer time (applied after method adjustments) */
  adjustments?: PrayerAdjustments;
  /** Rounding method for prayer times @default Rounding.Nearest */
  rounding?: Rounding;
  /** Timezone identifier (e.g., 'America/New_York') or offset (e.g., '+05:00') */
  timezone?: string;
}

/**
 * Individual prayer time adjustments in minutes
 * 
 * Note: These are applied IN ADDITION to built-in method adjustments.
 * Built-in method adjustments (matching adhan-swift):
 * - MWL, Egyptian, Karachi, ISNA: dhuhr +1min
 * - Dubai: sunrise -3min, dhuhr +3min, asr +3min, maghrib +3min  
 * - Moonsighting: dhuhr +5min, maghrib +3min
 * - Singapore: dhuhr +1min
 * - Turkey: sunrise -7min, dhuhr +5min, asr +4min, maghrib +7min
 * 
 * @default All adjustments: 0 minutes
 */
export interface PrayerAdjustments {
  /** Fajr adjustment in minutes @default 0 */
  fajr?: number;
  /** Sunrise adjustment in minutes @default 0 */
  sunrise?: number;
  /** Dhuhr adjustment in minutes @default 0 */
  dhuhr?: number;
  /** Asr adjustment in minutes @default 0 */
  asr?: number;
  /** Maghrib adjustment in minutes @default 0 */
  maghrib?: number;
  /** Isha adjustment in minutes @default 0 */
  isha?: number;
}

/**
 * Complete prayer times result with metadata
 */
export interface PrayerTimesResult {
  /** Fajr (dawn) prayer time in ISO 8601 format */
  fajr: string;
  /** Sunrise time in ISO 8601 format */
  sunrise: string;
  /** Dhuhr (midday) prayer time in ISO 8601 format */
  dhuhr: string;
  /** Asr (afternoon) prayer time in ISO 8601 format */
  asr: string;
  /** Maghrib (sunset) prayer time in ISO 8601 format */
  maghrib: string;
  /** Isha (night) prayer time in ISO 8601 format */
  isha: string;
  /** Metadata about the calculation */
  metadata?: PrayerTimesMetadata;
}

/**
 * Metadata about prayer time calculations
 */
export interface PrayerTimesMetadata {
  /** Calculation method used */
  method: CalculationMethod;
  /** School of jurisprudence used */
  madhab: Madhab;
  /** Coordinates used for calculation */
  coordinates: Coordinates;
  /** Date used for calculation */
  date: DateInput;
  /** High latitude rule applied (if any) */
  highLatitudeRule?: HighLatitudeRule;
  /** Whether any adjustments were applied */
  hasAdjustments: boolean;
  /** Timezone offset in minutes from UTC */
  timezoneOffset?: number;
}

/**
 * Prayer time calculation request parameters
 */
export interface PrayerTimesRequest {
  /** Geographic coordinates */
  coordinates: Coordinates;
  /** Date for calculation (defaults to current date) */
  date?: DateInput | string; // ISO date string (YYYY-MM-DD) or DateInput object
  /** Calculation parameters */
  parameters?: CalculationParameters;
  /** Timezone for result formatting (defaults to system timezone) */
  timezone?: string;
}

/**
 * Qibla direction calculation result
 */
export interface QiblaResult {
  /** Direction to Kaaba in degrees from North (0-360) */
  direction: number;
  /** Distance to Kaaba in kilometers */
  distance: number;
  /** Compass bearing as string (e.g., "NE", "SW") */
  compassBearing: string;
}

/**
 * Bulk prayer times calculation for multiple dates
 */
export interface BulkPrayerTimesRequest {
  /** Geographic coordinates */
  coordinates: Coordinates;
  /** Start date */
  startDate: DateInput | string;
  /** End date */
  endDate: DateInput | string;
  /** Calculation parameters */
  parameters?: CalculationParameters;
  /** Timezone for result formatting */
  timezone?: string;
}

/**
 * Result for bulk prayer times calculation
 */
export interface BulkPrayerTimesResult {
  /** Array of prayer times for each date */
  prayerTimes: Array<PrayerTimesResult & { date: string }>;
  /** Total number of days calculated */
  totalDays: number;
  /** Calculation metadata */
  metadata: PrayerTimesMetadata;
}

/**
 * Calculation method information
 */
export interface MethodInfo {
  /** Method identifier */
  method: CalculationMethod;
  /** Human-readable name */
  name: string;
  /** Description */
  description: string;
  /** Fajr angle in degrees */
  fajrAngle: number;
  /** Isha angle in degrees (or interval in minutes) */
  ishaAngle: number;
  /** Whether isha uses interval instead of angle */
  ishaInterval: boolean;
  /** Geographic regions where commonly used */
  regions: string[];
}

/**
 * Error types for better error handling
 */
export enum AdhanErrorCode {
  /** Invalid coordinates provided */
  INVALID_COORDINATES = 'INVALID_COORDINATES',
  /** Invalid date provided */
  INVALID_DATE = 'INVALID_DATE',
  /** Invalid calculation parameters */
  INVALID_PARAMETERS = 'INVALID_PARAMETERS',
  /** Calculation failed due to extreme latitude */
  EXTREME_LATITUDE = 'EXTREME_LATITUDE',
  /** Native module not available */
  MODULE_NOT_AVAILABLE = 'MODULE_NOT_AVAILABLE',
  /** Unknown error occurred */
  UNKNOWN_ERROR = 'UNKNOWN_ERROR',
}

/**
 * Custom error class for Adhan-specific errors
 */
export interface AdhanError extends Error {
  /** Error code for programmatic handling */
  code: AdhanErrorCode;
  /** Additional context about the error */
  context?: Record<string, any>;
}

/**
 * Performance metrics for calculations
 */
export interface PerformanceMetrics {
  /** Calculation time in milliseconds */
  calculationTime: number;
  /** Whether native module was used */
  usedNativeModule: boolean;
  /** Memory usage in bytes (if available) */
  memoryUsage?: number;
}

/**
 * Module configuration options
 */
export interface ModuleConfig {
  /** Enable performance monitoring */
  enablePerformanceMonitoring?: boolean;
  /** Enable debug logging */
  enableDebugLogging?: boolean;
  /** Cache calculation results */
  enableCaching?: boolean;
  /** Maximum cache size */
  maxCacheSize?: number;
}

/**
 * Type guards for runtime validation
 */
export namespace TypeGuards {
  export function isValidCoordinates(obj: any): obj is Coordinates {
    return (
      typeof obj === 'object' &&
      typeof obj.latitude === 'number' &&
      obj.latitude >= -90 &&
      obj.latitude <= 90 &&
      typeof obj.longitude === 'number' &&
      obj.longitude >= -180 &&
      obj.longitude <= 180
    );
  }

  export function isValidDateInput(obj: any): obj is DateInput {
    return (
      typeof obj === 'object' &&
      typeof obj.year === 'number' &&
      typeof obj.month === 'number' &&
      obj.month >= 1 &&
      obj.month <= 12 &&
      typeof obj.day === 'number' &&
      obj.day >= 1 &&
      obj.day <= 31
    );
  }

  export function isPrayerTimesResult(obj: any): obj is PrayerTimesResult {
    return (
      typeof obj === 'object' &&
      typeof obj.fajr === 'string' &&
      typeof obj.sunrise === 'string' &&
      typeof obj.dhuhr === 'string' &&
      typeof obj.asr === 'string' &&
      typeof obj.maghrib === 'string' &&
      typeof obj.isha === 'string'
    );
  }
}

/**
 * Utility type for partial prayer times (useful for intermediate calculations)
 */
export type PartialPrayerTimes = Partial<PrayerTimesResult>;

/**
 * Union type for all supported calculation methods
 */
export type CalculationMethodType = keyof typeof CalculationMethod;

/**
 * Helper type for method-specific parameters
 */
export type MethodSpecificParameters<T extends CalculationMethod> = T extends
  | CalculationMethod.UmmAlQura
  | CalculationMethod.Qatar
  ? CalculationParameters &
      Required<Pick<CalculationParameters, 'ishaInterval'>>
  : CalculationParameters;

/**
 * Type for configuration validation result
 */
export interface ValidationResult {
  /** Whether the configuration is valid */
  isValid: boolean;
  /** Validation errors (if any) */
  errors: string[];
  /** Validation warnings (if any) */
  warnings: string[];
}

export default {
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
  AdhanErrorCode,
  TypeGuards,
};
