import Adhan from './NativeAdhan';
import type { GetPrayerTimesInput, GetPrayerTimesOutput } from './NativeAdhan';

export const getPrayerTimes = (input: GetPrayerTimesInput): Promise<GetPrayerTimesOutput> => {
  return Adhan.getPrayerTimes(input);
};

export type { GetPrayerTimesInput, GetPrayerTimesOutput };
export default Adhan;
