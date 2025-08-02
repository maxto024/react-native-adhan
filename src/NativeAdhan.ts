import { NativeModules } from 'react-native';

/**
 * Native module interface for react-native-adhan
 * Promise-based methods for cross-platform compatibility
 */
export interface AdhanNativeModule {
  /**
   * Calculate prayer times for a specific location and date
   * @param latitude Geographic latitude (-90 to 90)
   * @param longitude Geographic longitude (-180 to 180)
   * @param dateIso Date in ISO format (YYYY-MM-DD)
   * @param method Calculation method identifier
   * @param madhab School of jurisprudence ('Shafi' | 'Hanafi')
   * @param adjustments JSON string of prayer adjustments in minutes
   * @param customAngles JSON string of custom fajr/isha angles
   * @returns Promise that resolves to prayer times as JSON string
   */
  getPrayerTimes(
    latitude: number,
    longitude: number,
    dateIso: string,
    method: string,
    madhab?: string,
    adjustments?: string,
    customAngles?: string
  ): Promise<string>;

  /**
   * Calculate Qibla direction from given coordinates
   * @param latitude Geographic latitude
   * @param longitude Geographic longitude
   * @returns Promise that resolves to Qibla direction info as JSON string
   */
  getQiblaDirection(latitude: number, longitude: number): Promise<string>;

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
   * @returns Promise that resolves to array of prayer times as JSON string
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
  ): Promise<string>;

  /**
   * Get information about all available calculation methods
   * @returns Promise that resolves to array of method information as JSON string
   */
  getAvailableMethods(): Promise<string>;

  /**
   * Validate coordinates
   * @param latitude Geographic latitude
   * @param longitude Geographic longitude
   * @returns Promise that resolves to whether coordinates are valid
   */
  validateCoordinates(latitude: number, longitude: number): Promise<boolean>;

  /**
   * Get module version and build information
   * @returns Promise that resolves to version and build info as JSON string
   */
  getModuleInfo(): Promise<string>;

  /**
   * Get performance metrics for the last calculation
   * @returns Promise that resolves to performance metrics as JSON string
   */
  getPerformanceMetrics(): Promise<string>;

  /**
   * Clear internal caches and reset counters
   */
  clearCache(): Promise<void>;

  /**
   * Enable or disable debug logging
   * @param enabled Whether to enable debug logging
   */
  setDebugLogging(enabled: boolean): Promise<void>;

  /**
   * Simple multiplication for testing TurboModule connectivity
   * @param a First number
   * @param b Second number
   * @returns Promise that resolves to product of a and b
   */
  multiply(a: number, b: number): Promise<number>;
}

// Access the native module through React Native bridge
export default NativeModules.Adhan as AdhanNativeModule;
