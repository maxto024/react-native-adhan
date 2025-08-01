import Adhan from '../index';
import type { GetPrayerTimesInput, GetPrayerTimesOutput } from '../index';

// Mock the native module for testing
jest.mock('../NativeAdhan', () => ({
  getPrayerTimes: jest.fn((_input: GetPrayerTimesInput): Promise<GetPrayerTimesOutput> => Promise.resolve({
    fajr: '2024-01-01T05:30:00',
    sunrise: '2024-01-01T07:00:00',
    dhuhr: '2024-01-01T12:30:00',
    asr: '2024-01-01T15:45:00',
    maghrib: '2024-01-01T18:15:00',
    isha: '2024-01-01T19:45:00',
  })),
}));

describe('getPrayerTimes', () => {
  it('should return prayer times for valid coordinates and date', async () => {
    const date = new Date();
    const result = await Adhan.getPrayerTimes({
      latitude: 21.4225,
      longitude: 39.8262,
      date: {
        year: date.getFullYear(),
        month: date.getMonth() + 1,
        day: date.getDate(),
      },
      method: 'MuslimWorldLeague',
    });

    expect(result).toEqual({
      fajr: '2024-01-01T05:30:00',
      sunrise: '2024-01-01T07:00:00',
      dhuhr: '2024-01-01T12:30:00',
      asr: '2024-01-01T15:45:00',
      maghrib: '2024-01-01T18:15:00',
      isha: '2024-01-01T19:45:00',
    });
  });

  it('should work with different calculation methods', async () => {
    const methods = [
      'MuslimWorldLeague',
      'Egyptian',
      'Karachi',
      'UmmAlQura',
      'Dubai',
      'MoonsightingCommittee',
      'NorthAmerica',
      'Kuwait',
      'Qatar',
      'Singapore',
      'Tehran',
      'Turkey',
    ];

    for (const method of methods) {
      const date = new Date();
      const result = await Adhan.getPrayerTimes({
        latitude: 40.7128,
        longitude: -74.0060,
        date: {
          year: date.getFullYear(),
          month: date.getMonth() + 1,
          day: date.getDate(),
        },
        method,
      });

      expect(result).toBeDefined();
      expect(result.fajr).toBeDefined();
      expect(result.dhuhr).toBeDefined();
      expect(result.maghrib).toBeDefined();
    }
  });
});
