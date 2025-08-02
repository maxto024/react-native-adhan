import {
  calculatePrayerTimes,
  calculateQibla,
  calculateSunnahTimes,
  getCurrentPrayer,
  getCalculationMethods,
  getMethodParameters,
  validateCoordinates,
  dateComponentsFromDate,
  prayerTimesToDates,
  CalculationMethod,
  Madhab,
  timestampToDate,
  getLibraryInfo,
} from '../index';

// Mock the native module
jest.mock('../NativeAdhan', () => ({
  calculatePrayerTimes: jest.fn(),
  calculateQibla: jest.fn(),
  calculateSunnahTimes: jest.fn(),
  getCurrentPrayer: jest.fn(),
  getTimeForPrayer: jest.fn(),
  validateCoordinates: jest.fn(),
  getCalculationMethods: jest.fn(),
  getMethodParameters: jest.fn(),
  calculatePrayerTimesRange: jest.fn(),
  getLibraryInfo: jest.fn(),
}));

const mockNativeAdhan = require('../NativeAdhan');

describe('react-native-adhan', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('validateCoordinates', () => {
    it('should validate correct coordinates', () => {
      const result = validateCoordinates({
        latitude: 21.4225,
        longitude: 39.8262,
      });
      expect(result).toBe(true);
    });

    it('should invalidate incorrect coordinates', () => {
      const result = validateCoordinates({ latitude: 100, longitude: 200 });
      expect(result).toBe(false);
    });
  });

  describe('calculatePrayerTimes', () => {
    it('should calculate prayer times successfully', async () => {
      const mockPrayerTimes = {
        fajr: 1640995200000, // Example timestamp
        sunrise: 1641000600000,
        dhuhr: 1641020400000,
        asr: 1641027600000,
        maghrib: 1641034800000,
        isha: 1641042000000,
      };

      mockNativeAdhan.calculatePrayerTimes.mockResolvedValue(mockPrayerTimes);

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };

      const result = await calculatePrayerTimes(
        coordinates,
        dateComponents,
        calculationParameters
      );

      expect(result).toEqual(mockPrayerTimes);
      expect(mockNativeAdhan.calculatePrayerTimes).toHaveBeenCalledWith(
        coordinates,
        dateComponents,
        calculationParameters
      );
    });

    it('should handle calculation errors', async () => {
      mockNativeAdhan.calculatePrayerTimes.mockRejectedValue(
        new Error('Calculation failed')
      );

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };

      await expect(
        calculatePrayerTimes(coordinates, dateComponents, calculationParameters)
      ).rejects.toThrow('Calculation failed');
    });
  });

  describe('calculateQibla', () => {
    it('should calculate Qibla direction', async () => {
      const mockQibla = { direction: 158.58 };
      mockNativeAdhan.calculateQibla.mockResolvedValue(mockQibla);

      const coordinates = { latitude: 40.7128, longitude: -74.006 }; // New York

      const result = await calculateQibla(coordinates);

      expect(result).toEqual(mockQibla);
      expect(mockNativeAdhan.calculateQibla).toHaveBeenCalledWith(coordinates);
    });
  });

  describe('calculateSunnahTimes', () => {
    it('should calculate Sunnah times', async () => {
      const mockSunnahTimes = {
        middleOfTheNight: 1641006000000,
        lastThirdOfTheNight: 1641012000000,
      };

      mockNativeAdhan.calculateSunnahTimes.mockResolvedValue(mockSunnahTimes);

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };

      const result = await calculateSunnahTimes(
        coordinates,
        dateComponents,
        calculationParameters
      );

      expect(result).toEqual(mockSunnahTimes);
      expect(mockNativeAdhan.calculateSunnahTimes).toHaveBeenCalledWith(
        coordinates,
        dateComponents,
        calculationParameters
      );
    });
  });

  describe('getCurrentPrayer', () => {
    it('should get current prayer with default timestamp', async () => {
      const mockCurrentPrayer = { current: 'dhuhr', next: 'asr' };
      mockNativeAdhan.getCurrentPrayer.mockResolvedValue(mockCurrentPrayer);

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };

      const result = await getCurrentPrayer(
        coordinates,
        dateComponents,
        calculationParameters
      );

      expect(result).toEqual(mockCurrentPrayer);
      expect(mockNativeAdhan.getCurrentPrayer).toHaveBeenCalledWith(
        coordinates,
        dateComponents,
        calculationParameters,
        expect.any(Number)
      );
    });

    it('should get current prayer with custom timestamp', async () => {
      const mockCurrentPrayer = { current: 'fajr', next: 'sunrise' };
      mockNativeAdhan.getCurrentPrayer.mockResolvedValue(mockCurrentPrayer);

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };
      const customTime = 1641000000000;

      const result = await getCurrentPrayer(
        coordinates,
        dateComponents,
        calculationParameters,
        customTime
      );

      expect(result).toEqual(mockCurrentPrayer);
      expect(mockNativeAdhan.getCurrentPrayer).toHaveBeenCalledWith(
        coordinates,
        dateComponents,
        calculationParameters,
        customTime
      );
    });
  });

  describe('getCalculationMethods', () => {
    it('should return available calculation methods', () => {
      const mockMethods = [
        {
          name: 'muslimWorldLeague',
          displayName: 'Muslim World League',
          fajrAngle: 18.0,
          ishaAngle: 17.0,
          ishaInterval: 0,
          description: 'Standard method',
        },
      ];

      mockNativeAdhan.getCalculationMethods.mockReturnValue(mockMethods);

      const result = getCalculationMethods();

      expect(result).toEqual(mockMethods);
      expect(mockNativeAdhan.getCalculationMethods).toHaveBeenCalled();
    });
  });

  describe('getMethodParameters', () => {
    it('should return method parameters for string input', async () => {
      const mockParams = {
        method: 'muslimWorldLeague',
        fajrAngle: 18.0,
        ishaAngle: 17.0,
        madhab: 'shafi',
        rounding: 'nearest',
        shafaq: 'general',
      };

      mockNativeAdhan.getMethodParameters.mockResolvedValue(mockParams);

      const result = await getMethodParameters('muslimWorldLeague');

      expect(result).toEqual(mockParams);
      expect(mockNativeAdhan.getMethodParameters).toHaveBeenCalledWith(
        'muslimWorldLeague'
      );
    });

    it('should return method parameters for enum input', async () => {
      const mockParams = {
        method: 'egyptian',
        fajrAngle: 19.5,
        ishaAngle: 17.5,
        madhab: 'shafi',
        rounding: 'nearest',
        shafaq: 'general',
      };

      mockNativeAdhan.getMethodParameters.mockResolvedValue(mockParams);

      const result = await getMethodParameters(CalculationMethod.EGYPTIAN);

      expect(result).toEqual(mockParams);
      expect(mockNativeAdhan.getMethodParameters).toHaveBeenCalledWith(
        'egyptian'
      );
    });
  });

  describe('getLibraryInfo', () => {
    it('should return library information', () => {
      const mockInfo = {
        version: '0.1.0',
        swiftLibraryVersion: '2.0.0',
        platform: 'iOS',
      };

      mockNativeAdhan.getLibraryInfo.mockReturnValue(mockInfo);

      const result = getLibraryInfo();

      expect(result).toEqual(mockInfo);
      expect(mockNativeAdhan.getLibraryInfo).toHaveBeenCalled();
    });
  });

  describe('utility functions', () => {
    describe('dateComponentsFromDate', () => {
      it('should convert JavaScript Date to date components', () => {
        const date = new Date(2022, 0, 15); // January 15, 2022 (month is 0-indexed)

        const result = dateComponentsFromDate(date);

        expect(result).toEqual({
          year: 2022,
          month: 1, // Should be 1-indexed
          day: 15,
        });
      });
    });

    describe('timestampToDate', () => {
      it('should convert timestamp to JavaScript Date', () => {
        const timestamp = 1641995400000; // January 12, 2022

        const result = timestampToDate(timestamp);

        expect(result).toBeInstanceOf(Date);
        expect(result.getTime()).toBe(timestamp);
      });
    });

    describe('prayerTimesToDates', () => {
      it('should convert prayer times to JavaScript Dates', () => {
        const prayerTimes = {
          fajr: 1640995200000,
          sunrise: 1641000600000,
          dhuhr: 1641020400000,
          asr: 1641027600000,
          maghrib: 1641034800000,
          isha: 1641042000000,
        };

        const result = prayerTimesToDates(prayerTimes);

        expect(result.fajr).toBeInstanceOf(Date);
        expect(result.sunrise).toBeInstanceOf(Date);
        expect(result.dhuhr).toBeInstanceOf(Date);
        expect(result.asr).toBeInstanceOf(Date);
        expect(result.maghrib).toBeInstanceOf(Date);
        expect(result.isha).toBeInstanceOf(Date);

        expect(result.fajr.getTime()).toBe(prayerTimes.fajr);
        expect(result.sunrise.getTime()).toBe(prayerTimes.sunrise);
        expect(result.dhuhr.getTime()).toBe(prayerTimes.dhuhr);
        expect(result.asr.getTime()).toBe(prayerTimes.asr);
        expect(result.maghrib.getTime()).toBe(prayerTimes.maghrib);
        expect(result.isha.getTime()).toBe(prayerTimes.isha);
      });
    });
  });

  describe('enums', () => {
    it('should have correct CalculationMethod values', () => {
      expect(CalculationMethod.MUSLIM_WORLD_LEAGUE).toBe('muslimWorldLeague');
      expect(CalculationMethod.EGYPTIAN).toBe('egyptian');
      expect(CalculationMethod.KARACHI).toBe('karachi');
      expect(CalculationMethod.UMM_AL_QURA).toBe('ummAlQura');
      expect(CalculationMethod.DUBAI).toBe('dubai');
      expect(CalculationMethod.MOON_SIGHTING_COMMITTEE).toBe(
        'moonsightingCommittee'
      );
      expect(CalculationMethod.NORTH_AMERICA).toBe('northAmerica');
      expect(CalculationMethod.KUWAIT).toBe('kuwait');
      expect(CalculationMethod.QATAR).toBe('qatar');
      expect(CalculationMethod.SINGAPORE).toBe('singapore');
      expect(CalculationMethod.TEHRAN).toBe('tehran');
      expect(CalculationMethod.TURKEY).toBe('turkey');
      expect(CalculationMethod.OTHER).toBe('other');
    });

    it('should have correct Madhab values', () => {
      expect(Madhab.SHAFI).toBe('shafi');
      expect(Madhab.HANAFI).toBe('hanafi');
    });
  });

  describe('error handling', () => {
    it('should handle native module errors gracefully', async () => {
      mockNativeAdhan.calculatePrayerTimes.mockRejectedValue(
        new Error('Native module error')
      );

      const coordinates = { latitude: 21.4225, longitude: 39.8262 };
      const dateComponents = { year: 2022, month: 1, day: 1 };
      const calculationParameters = {
        method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
      };

      await expect(
        calculatePrayerTimes(coordinates, dateComponents, calculationParameters)
      ).rejects.toThrow('Native module error');
    });
  });

  describe('integration scenarios', () => {
    it('should handle Makkah coordinates correctly', async () => {
      const mockPrayerTimes = {
        fajr: 1640995200000,
        sunrise: 1641000600000,
        dhuhr: 1641020400000,
        asr: 1641027600000,
        maghrib: 1641034800000,
        isha: 1641042000000,
      };

      mockNativeAdhan.calculatePrayerTimes.mockResolvedValue(mockPrayerTimes);
      mockNativeAdhan.validateCoordinates.mockReturnValue(true);

      const makkahCoordinates = { latitude: 21.4225241, longitude: 39.8261818 };
      const isValid = validateCoordinates(makkahCoordinates);

      expect(isValid).toBe(true);

      const result = await calculatePrayerTimes(
        makkahCoordinates,
        { year: 2022, month: 1, day: 1 },
        { method: CalculationMethod.UMM_AL_QURA, madhab: Madhab.SHAFI }
      );

      expect(result).toEqual(mockPrayerTimes);
    });

    it('should handle high latitude locations', async () => {
      const mockPrayerTimes = {
        fajr: 1640995200000,
        sunrise: 1641000600000,
        dhuhr: 1641020400000,
        asr: 1641027600000,
        maghrib: 1641034800000,
        isha: 1641042000000,
      };

      mockNativeAdhan.calculatePrayerTimes.mockResolvedValue(mockPrayerTimes);

      const londonCoordinates = { latitude: 51.5074, longitude: -0.1278 };

      const result = await calculatePrayerTimes(
        londonCoordinates,
        { year: 2022, month: 6, day: 15 }, // Summer solstice
        {
          method: CalculationMethod.MOON_SIGHTING_COMMITTEE,
          highLatitudeRule: 'seventhOfTheNight',
        }
      );

      expect(result).toEqual(mockPrayerTimes);
      expect(mockNativeAdhan.calculatePrayerTimes).toHaveBeenCalledWith(
        londonCoordinates,
        { year: 2022, month: 6, day: 15 },
        {
          method: CalculationMethod.MOON_SIGHTING_COMMITTEE,
          highLatitudeRule: 'seventhOfTheNight',
        }
      );
    });
  });
});
