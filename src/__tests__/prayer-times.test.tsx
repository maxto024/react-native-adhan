import { getPrayerTimes, CalculationMethod, type PrayerTimesResult } from '../index';

// Mock the native module for testing
jest.mock('../NativeAdhan', () => ({
  getPrayerTimes: jest.fn((): string => JSON.stringify({
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
      coordinates: {
        latitude: 21.4225,
        longitude: 39.8262,
      },
      parameters: {
        method: CalculationMethod.ISNA,
      },
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
      CalculationMethod.ISNA,
      CalculationMethod.MWL,
      CalculationMethod.Karachi,
      CalculationMethod.Egypt,
    ];

    for (const method of methods) {
      const result = await getPrayerTimes({
        coordinates: {
          latitude: 40.7128,
          longitude: -74.0060,
        },
        parameters: {
          method,
        },
      });

      expect(result).toBeDefined();
      expect(result.fajr).toBeDefined();
      expect(result.dhuhr).toBeDefined();
      expect(result.maghrib).toBeDefined();
    }
  });
});