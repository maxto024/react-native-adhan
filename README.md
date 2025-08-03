# React Native Adhan

[![NPM Version](https://img.shields.io/npm/v/react-native-adhan.svg)](https://www.npmjs.com/package/react-native-adhan)
[![NPM Downloads](https://img.shields.io/npm/dm/react-native-adhan.svg)](https://www.npmjs.com/package/react-native-adhan)
[![License](https://img.shields.io/npm/l/react-native-adhan.svg)](https://github.com/maxto024/react-native-adhan/blob/main/LICENSE)
[![CI](https://github.com/maxto024/react-native-adhan/actions/workflows/ci.yml/badge.svg)](https://github.com/maxto024/react-native-adhan/actions/workflows/ci-library.yml)

**Accurate Islamic prayer times and Qibla direction for React Native.**

`react-native-adhan` is a high-performance TurboModule for React Native that provides precise Islamic prayer time and Qibla direction calculations. It directly wraps the official, battle-tested [Adhan-Swift](https://github.com/batoulapps/Adhan-Swift) and [Adhan-Kotlin](https://github.com/batoulapps/Adhan-Kotlin) libraries, ensuring accuracy and reliability.

Built for the new architecture, it offers optimal performance and seamless integration with both modern and legacy React Native projects.

## Key Features

- **High Accuracy:** Leverages the official Adhan libraries used by millions.
- **TurboModule Powered:** Optimized for the React Native New Architecture for maximum performance.
- **Full TypeScript Support:** Strongly typed for a better developer experience.
- **Comprehensive API:** Includes prayer times, Qibla, Sunnah times, and more.
- **Customizable Calculations:** Supports various calculation methods, madhabs, and high-latitude rules.
- **Expo Compatible:** Includes a config plugin for easy integration with Expo projects.
- **Autolinking:** Simple installation with automatic native module linking.

## Installation

Install the package using your preferred package manager:

```bash
npm install react-native-adhan
# or
yarn add react-native-adhan
```

The library supports autolinking, so no further manual setup is required for standard React Native projects. For iOS, run `pod install`:

```bash
cd ios && pod install
```

### Expo Integration

If you are using Expo, add the config plugin to your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": ["react-native-adhan"]
  }
}
```

The plugin will automatically configure the necessary permissions (`ACCESS_FINE_LOCATION` on Android) and background modes (location, fetch on iOS).

## Usage

Here's a quick example of how to calculate prayer times for a specific location.

```typescript
import {
  calculatePrayerTimes,
  dateComponentsFromDate,
  CalculationMethod,
  Madhab,
} from 'react-native-adhan';

async function getPrayerTimes() {
  const coordinates = {
    latitude: 21.4225, // Makkah
    longitude: 39.8262,
  };
  const today = dateComponentsFromDate(new Date());
  const params = {
    method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
    madhab: Madhab.SHAFI,
  };

  try {
    const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
    console.log('Fajr:', new Date(prayerTimes.fajr).toLocaleTimeString());
    console.log('Dhuhr:', new Date(prayerTimes.dhuhr).toLocaleTimeString());
    console.log('Asr:', new Date(prayerTimes.asr).toLocaleTimeString());
    console.log('Maghrib:', new Date(prayerTimes.maghrib).toLocaleTimeString());
    console.log('Isha:', new Date(prayerTimes.isha).toLocaleTimeString());
  } catch (error) {
    console.error('Error calculating prayer times:', error);
  }
}

getPrayerTimes();
```

## API Reference

### Main Functions

| Function                    | Description                                                              |
| --------------------------- | ------------------------------------------------------------------------ |
| `calculatePrayerTimes(...)` | Calculates the five daily prayer times.                                  |
| `calculateQibla(...)`       | Calculates the Qibla direction in degrees from North.                    |
| `calculateSunnahTimes(...)` | Calculates Sunnah times (middle and last third of the night).            |
| `getCurrentPrayer(...)`     | Determines the current and next prayer times.                            |
| `getTimeForPrayer(...)`     | Retrieves the time for a single specified prayer.                        |
| `getCalculationMethods()`   | Returns a list of all available calculation methods.                     |
| `getMethodParameters(...)`  | Gets the default parameters for a specific calculation method.           |
| `getLibraryInfo()`          | Returns version info for the library and its native dependencies.        |
| `validateCoordinates(...)`  | Checks if latitude/longitude values are within the valid range.          |

### Method Signatures

- **`calculatePrayerTimes(coords: AdhanCoordinates, date: AdhanDateComponents, params: AdhanCalculationParameters): Promise<AdhanPrayerTimes>`**
- **`calculateQibla(coords: AdhanCoordinates): Promise<AdhanQibla>`**
- **`calculateSunnahTimes(coords: AdhanCoordinates, date: AdhanDateComponents, params: AdhanCalculationParameters): Promise<AdhanSunnahTimes>`**
- **`getCurrentPrayer(coords: AdhanCoordinates, date: AdhanDateComponents, params: AdhanCalculationParameters, currentTime: number): Promise<AdhanCurrentPrayerInfo>`**
- **`getTimeForPrayer(coords: AdhanCoordinates, date: AdhanDateComponents, params: AdhanCalculationParameters, prayer: string): Promise<number | null>`**
- **`getCalculationMethods(): AdhanCalculationMethodInfo[]`**
- **`getMethodParameters(method: string): Promise<AdhanCalculationParameters>`**
- **`getLibraryInfo(): { version: string, swiftLibraryVersion?: string, kotlinLibraryVersion?: string, platform: string }`**
- **`validateCoordinates(coords: AdhanCoordinates): boolean`**

For a complete API reference, including all TypeScript types and detailed examples, please see the [API Documentation](./docs/API.md).

### TypeScript Types

The library exposes several types for easier integration. Here are some of the core ones:

```typescript
// Input Types
export interface AdhanCoordinates {
  latitude: number;
  longitude: number;
}

export interface AdhanDateComponents {
  year: number;
  month: number; // 1-indexed
  day: number;
}

export interface AdhanCalculationParameters {
  method?: string;
  madhab?: 'shafi' | 'hanafi';
  highLatitudeRule?: 'middleOfTheNight' | 'seventhOfTheNight' | 'twilightAngle';
  // ... and more
}

// Output Types
export interface AdhanPrayerTimes {
  fajr: number; // Unix timestamp in ms
  sunrise: number;
  dhuhr: number;
  asr: number;
  maghrib: number;
  isha: number;
}

export interface AdhanQibla {
  direction: number; // Degrees from North
}
```

## Contributing

Contributions are welcome! Please see the [Contributing Guide](./CONTRIBUTING.md) for more details on how to get started.

## License

MIT © 2025 Mohamed Elmi Hassan

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.