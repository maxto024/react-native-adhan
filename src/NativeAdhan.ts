import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

/**
 * TurboModule specification for react-native-adhan
 * Following 2025 best practices for New Architecture compatibility
 */
export interface Spec extends TurboModule {
  /**
   * Calculate prayer times for a specific location and date
   * @param latitude Geographic latitude (-90 to 90)
   * @param longitude Geographic longitude (-180 to 180)
   * @param dateIso Date in ISO format (YYYY-MM-DD)
   * @param method Calculation method identifier
   * @param madhab School of jurisprudence ('Shafi' | 'Hanafi')
   * @param timezone Timezone identifier (e.g., 'America/New_York') or offset (+05:00)
   * @param adjustments JSON string of prayer adjustments in minutes
   * @param customAngles JSON string of custom fajr/isha angles
   * @returns Prayer times as JSON string
   */
  getPrayerTimes(
    latitude: number,
    longitude: number,
    dateIso: string,
    method: string,
    madhab?: string,
    adjustments?: string,
    customAngles?: string
  ): string;

  /**
   * Calculate Qibla direction from given coordinates
   * @param latitude Geographic latitude
   * @param longitude Geographic longitude
   * @returns Qibla direction info as JSON string
   */
  getQiblaDirection(latitude: number, longitude: number): string;

  /**
   * Calculate prayer times for multiple consecutive days
   * @param latitude Geographic latitude
   * @param longitude Geographic longitude
   * @param startDateIso Start date in ISO format
   * @param endDateIso End date in ISO format
   * @param method Calculation method
   * @param madhab School of jurisprudence
   * @param timezone Timezone identifier or offset
   * @param adjustments JSON string of adjustments
   * @param customAngles JSON string of custom fajr/isha angles
   * @returns Array of prayer times as JSON string
   */
  getBulkPrayerTimes(
    latitude: number,
    longitude: number,
    startDateIso: string,
    endDateIso: string,
    method: string,
    madhab?: string,
    timezone?: string,
    adjustments?: string,
    customAngles?: string
  ): string;

  /**
   * Get information about all available calculation methods
   * @returns Array of method information as JSON string
   */
  getAvailableMethods(): string;

  /**
   * Validate coordinates
   * @param latitude Geographic latitude
   * @param longitude Geographic longitude
   * @returns Whether coordinates are valid
   */
  validateCoordinates(latitude: number, longitude: number): boolean;

  /**
   * Get module version and build information
   * @returns Version and build info as JSON string
   */
  getModuleInfo(): string;

  /**
   * Get performance metrics for the last calculation
   * @returns Performance metrics as JSON string
   */
  getPerformanceMetrics(): string;

  /**
   * Clear internal caches and reset counters
   */
  clearCache(): void;

  /**
   * Enable or disable debug logging
   * @param enabled Whether to enable debug logging
   */
  setDebugLogging(enabled: boolean): void;

  /**
   * Simple multiplication for testing TurboModule connectivity
   * @param a First number
   * @param b Second number
   * @returns Product of a and b
   */
  multiply(a: number, b: number): number;
}

// Single TurboModule registry call following 2025 best practices
export default TurboModuleRegistry.getEnforcing<Spec>('Adhan');
