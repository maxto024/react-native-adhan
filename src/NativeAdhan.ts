import { NativeModules } from 'react-native';

export interface GetPrayerTimesInput {
  latitude: number;
  longitude: number;
  date: { year: number; month: number; day: number };
  method: string; // e.g., "MuslimWorldLeague"
  madhab?: string; // e.g., "Shafi"
}

export interface GetPrayerTimesOutput {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
}

export interface AdhanModuleInterface {
  getPrayerTimes(input: GetPrayerTimesInput): Promise<GetPrayerTimesOutput>;
}

// Try to use TurboModule first, fallback to legacy bridge
let AdhanModule: AdhanModuleInterface;

try {
  // Try to get the TurboModule
  const TurboModuleRegistry = require('react-native').TurboModuleRegistry;
  AdhanModule = TurboModuleRegistry.get('NativeAdhanModule');
} catch (e) {
  // Fallback to legacy bridge
  AdhanModule = NativeModules.NativeAdhanModule;
}

if (!AdhanModule) {
  throw new Error(
    'NativeAdhanModule could not be found. Make sure the native module is properly linked and registered.'
  );
}

export default AdhanModule;
