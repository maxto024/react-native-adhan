/**
 * react-native-adhan - High-performance Islamic prayer times library
 *
 * Features:
 * - ⚡ TurboModule performance with New Architecture
 * - 🛡️ Full TypeScript type safety
 * - 📱 Expo compatibility via development builds
 * - 🌍 Comprehensive calculation methods
 * - 🎯 Qibla direction calculation
 * - 📊 Performance monitoring
 * - 🔄 Bulk calculations
 * - ✅ Runtime validation
 */

import AdhanTurboModule from './NativeAdhan';
import {
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
  AdhanErrorCode,
  TypeGuards,
  type PrayerTimesResult,
  type PrayerTimesRequest,
  type QiblaResult,
  type BulkPrayerTimesRequest,
  type BulkPrayerTimesResult,
  type MethodInfo,
  type Coordinates,
  type DateInput,
  type CalculationParameters,
  type AdhanError,
  type PerformanceMetrics,
  type ModuleConfig,
  type ValidationResult,
} from './types';

// ============ MODULE CONFIGURATION ============

let moduleConfig: ModuleConfig = {
  enablePerformanceMonitoring: false,
  enableDebugLogging: false,
  enableCaching: true,
  maxCacheSize: 100,
};

/**
 * Configure the module behavior
 */
export function configure(config: Partial<ModuleConfig>): void {
  moduleConfig = { ...moduleConfig, ...config };

  try {
    AdhanTurboModule.setDebugLogging(moduleConfig.enableDebugLogging || false);
  } catch (error) {
    console.warn('[Adhan] Failed to configure debug logging:', error);
  }
}

// ============ ERROR HANDLING ============

class AdhanErrorImpl extends Error implements AdhanError {
  code: AdhanErrorCode;
  context?: Record<string, any>;

  constructor(
    code: AdhanErrorCode,
    message: string,
    context?: Record<string, any>
  ) {
    super(message);
    this.name = 'AdhanError';
    this.code = code;
    this.context = context;
  }
}

function createError(
  code: AdhanErrorCode,
  message: string,
  context?: Record<string, any>
): AdhanError {
  return new AdhanErrorImpl(code, message, context);
}

// ============ VALIDATION ============

/**
 * Validate coordinates with detailed error reporting
 */
export function validateCoordinates(
  coordinates: Coordinates
): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (!TypeGuards.isValidCoordinates(coordinates)) {
    errors.push('Invalid coordinates object structure');
    return { isValid: false, errors, warnings };
  }

  if (coordinates.latitude < -90 || coordinates.latitude > 90) {
    errors.push(
      `Latitude must be between -90 and 90, got ${coordinates.latitude}`
    );
  }

  if (coordinates.longitude < -180 || coordinates.longitude > 180) {
    errors.push(
      `Longitude must be between -180 and 180, got ${coordinates.longitude}`
    );
  }

  if (coordinates.elevation !== undefined) {
    if (coordinates.elevation < -1000 || coordinates.elevation > 10000) {
      warnings.push(
        `Elevation ${coordinates.elevation}m is outside typical range (-1000 to 10000m)`
      );
    }
  }

  return { isValid: errors.length === 0, errors, warnings };
}

/**
 * Validate date input
 */
export function validateDate(date: DateInput | string): ValidationResult {
  const errors: string[] = [];
  const warnings: string[] = [];

  if (typeof date === 'string') {
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(date)) {
      errors.push('Date string must be in YYYY-MM-DD format');
      return { isValid: false, errors, warnings };
    }

    const parsedDate = new Date(date);
    if (isNaN(parsedDate.getTime())) {
      errors.push('Invalid date string');
      return { isValid: false, errors, warnings };
    }
  } else {
    if (!TypeGuards.isValidDateInput(date)) {
      errors.push('Invalid date object structure');
      return { isValid: false, errors, warnings };
    }

    // Validate month and day ranges
    if (date.month < 1 || date.month > 12) {
      errors.push(`Month must be between 1 and 12, got ${date.month}`);
    }

    if (date.day < 1 || date.day > 31) {
      errors.push(`Day must be between 1 and 31, got ${date.day}`);
    }

    // Check for reasonable year range
    const currentYear = new Date().getFullYear();
    if (date.year < 1900 || date.year > currentYear + 100) {
      warnings.push(`Year ${date.year} is outside typical range`);
    }
  }

  return { isValid: errors.length === 0, errors, warnings };
}

// ============ CORE API FUNCTIONS ============

/**
 * Calculate prayer times for a specific location and date
 * High-performance TurboModule implementation
 */
export async function getPrayerTimes(
  request: PrayerTimesRequest
): Promise<PrayerTimesResult> {
  const startTime = Date.now();

  try {
    // Validate input
    const coordValidation = validateCoordinates(request.coordinates);
    if (!coordValidation.isValid) {
      throw createError(
        AdhanErrorCode.INVALID_COORDINATES,
        `Invalid coordinates: ${coordValidation.errors.join(', ')}`,
        { coordinates: request.coordinates, errors: coordValidation.errors }
      );
    }

    // Prepare date
    let dateIso: string;
    if (request.date) {
      if (typeof request.date === 'string') {
        const dateValidation = validateDate(request.date);
        if (!dateValidation.isValid) {
          throw createError(
            AdhanErrorCode.INVALID_DATE,
            `Invalid date: ${dateValidation.errors.join(', ')}`
          );
        }
        dateIso = request.date;
      } else {
        const dateValidation = validateDate(request.date);
        if (!dateValidation.isValid) {
          throw createError(
            AdhanErrorCode.INVALID_DATE,
            `Invalid date: ${dateValidation.errors.join(', ')}`
          );
        }
        dateIso = `${request.date.year}-${String(request.date.month).padStart(2, '0')}-${String(request.date.day).padStart(2, '0')}`;
      }
    } else {
      // Use current date
      const now = new Date();
      dateIso = now.toISOString().split('T')[0] as string;
    }

    // Prepare parameters
    const method = request.parameters?.method || CalculationMethod.ISNA;
    const madhab = request.parameters?.madhab || Madhab.Shafi;
    const adjustments = request.parameters?.adjustments
      ? JSON.stringify(request.parameters.adjustments)
      : undefined;

    // Call TurboModule
    const resultJson = AdhanTurboModule.getPrayerTimes(
      request.coordinates.latitude,
      request.coordinates.longitude,
      dateIso,
      method,
      madhab,
      adjustments
    );

    const result: PrayerTimesResult = JSON.parse(resultJson);

    if (moduleConfig.enablePerformanceMonitoring) {
      const calculationTime = Date.now() - startTime;
      console.log(`[Adhan] TurboModule calculation took ${calculationTime}ms`);
    }

    return result;
  } catch (error) {
    if (error instanceof AdhanErrorImpl) {
      throw error;
    }
    throw createError(
      AdhanErrorCode.UNKNOWN_ERROR,
      `Unexpected error: ${error}`,
      { originalError: error }
    );
  }
}

/**
 * Calculate Qibla direction from given coordinates
 */
export async function getQiblaDirection(
  coordinates: Coordinates
): Promise<QiblaResult> {
  const coordValidation = validateCoordinates(coordinates);
  if (!coordValidation.isValid) {
    throw createError(
      AdhanErrorCode.INVALID_COORDINATES,
      `Invalid coordinates: ${coordValidation.errors.join(', ')}`
    );
  }

  try {
    const resultJson = AdhanTurboModule.getQiblaDirection(
      coordinates.latitude,
      coordinates.longitude
    );
    return JSON.parse(resultJson);
  } catch (error) {
    throw createError(
      AdhanErrorCode.UNKNOWN_ERROR,
      `Failed to calculate Qibla direction: ${error}`
    );
  }
}

/**
 * Calculate prayer times for multiple consecutive days
 */
export async function getBulkPrayerTimes(
  request: BulkPrayerTimesRequest
): Promise<BulkPrayerTimesResult> {
  const coordValidation = validateCoordinates(request.coordinates);
  if (!coordValidation.isValid) {
    throw createError(
      AdhanErrorCode.INVALID_COORDINATES,
      `Invalid coordinates: ${coordValidation.errors.join(', ')}`
    );
  }

  const startDateStr =
    typeof request.startDate === 'string'
      ? request.startDate
      : `${request.startDate.year}-${String(request.startDate.month).padStart(2, '0')}-${String(request.startDate.day).padStart(2, '0')}`;
  const endDateStr =
    typeof request.endDate === 'string'
      ? request.endDate
      : `${request.endDate.year}-${String(request.endDate.month).padStart(2, '0')}-${String(request.endDate.day).padStart(2, '0')}`;

  const startDate = new Date(startDateStr);
  const endDate = new Date(endDateStr);

  if (startDate > endDate) {
    throw createError(
      AdhanErrorCode.INVALID_DATE,
      'Start date must be before or equal to end date'
    );
  }

  const method = request.parameters?.method || CalculationMethod.ISNA;
  const madhab = request.parameters?.madhab || Madhab.Shafi;
  const adjustments = request.parameters?.adjustments
    ? JSON.stringify(request.parameters.adjustments)
    : undefined;

  try {
    const resultJson = AdhanTurboModule.getBulkPrayerTimes(
      request.coordinates.latitude,
      request.coordinates.longitude,
      startDateStr,
      endDateStr,
      method,
      madhab,
      adjustments
    );

    const prayerTimes: Array<PrayerTimesResult & { date: string }> =
      JSON.parse(resultJson);

    return {
      prayerTimes,
      totalDays: prayerTimes.length,
      metadata: {
        method,
        madhab,
        coordinates: request.coordinates,
        date: {
          year: startDate.getFullYear(),
          month: startDate.getMonth() + 1,
          day: startDate.getDate(),
        },
        hasAdjustments: !!request.parameters?.adjustments,
      },
    };
  } catch (error) {
    throw createError(
      AdhanErrorCode.UNKNOWN_ERROR,
      `Failed to calculate bulk prayer times: ${error}`
    );
  }
}

/**
 * Get information about all available calculation methods
 */
export function getAvailableMethods(): MethodInfo[] {
  try {
    const resultJson = AdhanTurboModule.getAvailableMethods();
    return JSON.parse(resultJson);
  } catch (error) {
    // Fallback static method information
    return [
      {
        method: CalculationMethod.ISNA,
        name: 'Islamic Society of North America',
        description: 'Used in North America',
        fajrAngle: 15,
        ishaAngle: 15,
        ishaInterval: false,
        regions: ['North America'],
      },
      {
        method: CalculationMethod.MWL,
        name: 'Muslim World League',
        description: 'Used globally',
        fajrAngle: 18,
        ishaAngle: 17,
        ishaInterval: false,
        regions: ['Global'],
      },
    ];
  }
}

/**
 * Get performance metrics
 */
export function getPerformanceMetrics(): PerformanceMetrics | null {
  try {
    const metricsJson = AdhanTurboModule.getPerformanceMetrics();
    const metrics = JSON.parse(metricsJson);
    return {
      calculationTime: metrics.lastCalculationTime,
      usedNativeModule: true,
      memoryUsage: metrics.memoryUsage,
    };
  } catch (error) {
    console.warn('[Adhan] Failed to get performance metrics:', error);
    return null;
  }
}

/**
 * Simple multiply function for testing TurboModule connectivity
 */
export function multiply(a: number, b: number): number {
  try {
    return AdhanTurboModule.multiply(a, b);
  } catch (error) {
    throw createError(
      AdhanErrorCode.MODULE_NOT_AVAILABLE,
      `TurboModule not available: ${error}`
    );
  }
}

// ============ EXPORTS ============

// Export all types
export type {
  PrayerTimesResult,
  PrayerTimesRequest,
  QiblaResult,
  BulkPrayerTimesRequest,
  BulkPrayerTimesResult,
  MethodInfo,
  Coordinates,
  DateInput,
  CalculationParameters,
  AdhanError,
  PerformanceMetrics,
  ModuleConfig,
  ValidationResult,
};

// Export enums and constants
export {
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
  AdhanErrorCode,
  TypeGuards,
};

// Legacy exports for backward compatibility
export const CalculationMethods = CalculationMethod;
export type CalculationMethodType = CalculationMethod;

// Default export
export default {
  getPrayerTimes,
  getQiblaDirection,
  getBulkPrayerTimes,
  getAvailableMethods,
  getPerformanceMetrics,
  validateCoordinates,
  validateDate,
  multiply,
  configure,
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
  AdhanErrorCode,
  TypeGuards,
};
