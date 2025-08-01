import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface GetPrayerTimesInput {
  latitude: number;
  longitude: number;
  date: { year: number; month: number; day: number };
  method: string;
  madhab?: string;
}

export interface GetPrayerTimesOutput {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
}

export interface Spec extends TurboModule {
  readonly getPrayerTimes: (input: GetPrayerTimesInput) => Promise<GetPrayerTimesOutput>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('NativeAdhanModule');