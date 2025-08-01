import { getPrayerTimes, CalculationMethods, type PrayerTimesResult } from '../index';

// Mock the native module for testing
jest.mock('../NativeAdhan', () => ({
  getPrayerTimes: jest.fn((lat: number, lng: number, date: string, method: string): PrayerTimesResult => ({
    fajr: '2024-01-01T05:30:00',
    sunrise: '2024-01-01T07:00:00',
    dhuhr: '2024-01-01T12:30:00',
    asr: '2024-01-01T15:45:00',
    maghrib: '2024-01-01T18:15:00',
    isha: '2024-01-01T19:45:00',
  })),
  multiply: jest.fn((a: number, b: number) => a * b),
}));

describe('getPrayerTimes', () => {
  it('should return prayer times for valid coordinates and date', async () => {
    const result = await getPrayerTimes({
      latitude: 21.4225,
      longitude: 39.8262,
      dateIso: '2024-01-01',
      method: CalculationMethods.ISNA,
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
      CalculationMethods.ISNA,
      CalculationMethods.MWL,
      CalculationMethods.Karachi,
      CalculationMethods.Egypt,
    ];

    for (const method of methods) {
      const result = await getPrayerTimes({
        latitude: 40.7128,
        longitude: -74.0060,
        dateIso: '2024-06-15',
        method,
      });

      expect(result).toBeDefined();
      expect(result.fajr).toBeDefined();
      expect(result.dhuhr).toBeDefined();
      expect(result.maghrib).toBeDefined();
    }
  });
});