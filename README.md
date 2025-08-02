# react-native-adhan

A React Native TurboModule for accurate Islamic prayer times and Qibla direction calculations. This library provides a complete wrapper around the official [adhan-swift](https://github.com/batoulapps/adhan-swift) and [adhan-kotlin](https://github.com/batoulapps/adhan-kotlin) libraries, ensuring identical and precise calculations on both iOS and Android platforms.

## Features

- 🕌 **Complete Prayer Times**: Calculate Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha prayer times
- 🧭 **Qibla Direction**: Accurate Qibla direction calculation from any location
- 🌙 **Sunnah Times**: Calculate middle of the night and last third of the night times
- 🌍 **Multiple Calculation Methods**: Support for 12+ calculation methods (Muslim World League, Egyptian, Karachi, etc.)
- 📱 **React Native New Architecture**: Built with TurboModules for optimal performance
- 🎯 **Type Safe**: Complete TypeScript definitions included
- 📊 **Bulk Calculations**: Calculate prayer times for date ranges
- 🏔️ **High Latitude Support**: Handles extreme latitude locations with appropriate rules
- ⚡ **Native Performance**: Direct use of official adhan libraries without approximations

## Installation

```sh
npm install react-native-adhan
```

### iOS Setup

If using CocoaPods, add this to your `Podfile`:

```ruby
pod 'Adhan', :path => '../node_modules/react-native-adhan'
```

### Android Setup

The Android dependencies are automatically included via Gradle.

## Usage

### Basic Prayer Times Calculation

```typescript
import {
  calculatePrayerTimes,
  calculateQibla,
  CalculationMethod,
  Madhab,
  dateComponentsFromDate,
  prayerTimesToDates,
} from 'react-native-adhan';

// Define location coordinates
const coordinates = {
  latitude: 21.4225241,  // Makkah
  longitude: 39.8261818,
};

// Get today's date components
const today = dateComponentsFromDate(new Date());

// Set calculation parameters
const calculationParams = {
  method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
  madhab: Madhab.SHAFI,
};

// Calculate prayer times
const prayerTimes = await calculatePrayerTimes(coordinates, today, calculationParams);

// Convert timestamps to JavaScript Date objects
const prayerDates = prayerTimesToDates(prayerTimes);

console.log('Fajr:', prayerDates.fajr.toLocaleTimeString());
console.log('Dhuhr:', prayerDates.dhuhr.toLocaleTimeString());
console.log('Asr:', prayerDates.asr.toLocaleTimeString());
console.log('Maghrib:', prayerDates.maghrib.toLocaleTimeString());
console.log('Isha:', prayerDates.isha.toLocaleTimeString());
```

### Qibla Direction

```typescript
import { calculateQibla } from 'react-native-adhan';

const coordinates = {
  latitude: 40.7128,  // New York
  longitude: -74.0060,
};

const qibla = await calculateQibla(coordinates);
console.log(`Qibla direction: ${qibla.direction.toFixed(1)}° from North`);
```

### Current Prayer Detection

```typescript
import { getCurrentPrayer } from 'react-native-adhan';

const currentPrayerInfo = await getCurrentPrayer(coordinates, today, calculationParams);
console.log('Current prayer:', currentPrayerInfo.current);
console.log('Next prayer:', currentPrayerInfo.next);
```

### Sunnah Times

```typescript
import { calculateSunnahTimes } from 'react-native-adhan';

const sunnahTimes = await calculateSunnahTimes(coordinates, today, calculationParams);
const middleOfNight = new Date(sunnahTimes.middleOfTheNight);
const lastThird = new Date(sunnahTimes.lastThirdOfTheNight);

console.log('Middle of the night:', middleOfNight.toLocaleTimeString());
console.log('Last third of the night:', lastThird.toLocaleTimeString());
```

### Advanced Configuration

```typescript
import { 
  calculatePrayerTimes,
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  Rounding,
} from 'react-native-adhan';

const advancedParams = {
  method: CalculationMethod.MOON_SIGHTING_COMMITTEE,
  madhab: Madhab.HANAFI,
  highLatitudeRule: HighLatitudeRule.SEVENTH_OF_THE_NIGHT,
  rounding: Rounding.NEAREST,
  prayerAdjustments: {
    fajr: 2,      // Add 2 minutes
    dhuhr: -1,    // Subtract 1 minute
    asr: 0,
    maghrib: 1,
    isha: 3,
  },
  methodAdjustments: {
    // Custom method-specific adjustments
    fajr: 0,
    sunrise: 0,
    dhuhr: 5,     // Moonsighting Committee uses +5 minutes for Dhuhr
    asr: 0,
    maghrib: 3,   // Moonsighting Committee uses +3 minutes for Maghrib
    isha: 0,
  },
};

const prayerTimes = await calculatePrayerTimes(coordinates, today, advancedParams);
```

### Bulk Date Range Calculations

```typescript
import { calculatePrayerTimesRange, dateComponentsFromDate } from 'react-native-adhan';

const startDate = dateComponentsFromDate(new Date());
const endDate = dateComponentsFromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)); // 7 days later

const prayerTimesRange = await calculatePrayerTimesRange(
  coordinates,
  startDate,
  endDate,
  calculationParams
);

prayerTimesRange.forEach(({ date, prayerTimes }) => {
  console.log(`${date.year}-${date.month}-${date.day}:`, prayerTimes);
});
```

## Calculation Methods

The library supports all major calculation methods:

- `MUSLIM_WORLD_LEAGUE` - Muslim World League (18°/17°)
- `EGYPTIAN` - Egyptian General Authority of Survey (19.5°/17.5°)
- `KARACHI` - University of Islamic Sciences, Karachi (18°/18°)
- `UMM_AL_QURA` - Umm al-Qura University, Makkah (18.5°, 90 min interval)
- `DUBAI` - UAE (18.2°/18.2°)
- `MOON_SIGHTING_COMMITTEE` - Moonsighting Committee (18°/18° with seasonal adjustments)
- `NORTH_AMERICA` - ISNA (15°/15°)
- `KUWAIT` - Kuwait (18°/17.5°)
- `QATAR` - Qatar (18°, 90 min interval)
- `SINGAPORE` - Singapore (20°/18°)
- `TEHRAN` - Tehran (17.7°/14°, 4.5° Maghrib)
- `TURKEY` - Turkey (18°/17°)

## API Reference

### Core Functions

#### `calculatePrayerTimes(coordinates, dateComponents, calculationParameters)`
Calculates prayer times for a specific location and date.

#### `calculateQibla(coordinates)`
Calculates Qibla direction from given coordinates.

#### `calculateSunnahTimes(coordinates, dateComponents, calculationParameters)`
Calculates recommended Islamic times (middle and last third of night).

#### `getCurrentPrayer(coordinates, dateComponents, calculationParameters, currentTime?)`
Determines current and next prayer based on current time.

#### `getTimeForPrayer(coordinates, dateComponents, calculationParameters, prayer)`
Gets the time for a specific prayer.

### Utility Functions

#### `validateCoordinates(coordinates)`
Validates if coordinates are within valid ranges.

#### `getCalculationMethods()`
Returns array of all available calculation methods with descriptions.

#### `getMethodParameters(method)`
Gets default parameters for a specific calculation method.

#### `dateComponentsFromDate(date)`
Converts JavaScript Date to date components format.

#### `timestampToDate(timestamp)`
Converts Unix timestamp to JavaScript Date.

#### `prayerTimesToDates(prayerTimes)`
Converts prayer times object to JavaScript Date objects.

## Type Definitions

```typescript
interface AdhanCoordinates {
  latitude: number;
  longitude: number;
}

interface AdhanDateComponents {
  year: number;
  month: number;  // 1-indexed
  day: number;
}

interface AdhanPrayerTimes {
  fajr: number;     // Unix timestamp in milliseconds
  sunrise: number;
  dhuhr: number;
  asr: number;
  maghrib: number;
  isha: number;
}

interface AdhanCalculationParameters {
  method?: string;
  fajrAngle?: number;
  ishaAngle?: number;
  ishaInterval?: number;
  madhab?: string;
  highLatitudeRule?: string;
  prayerAdjustments?: AdhanPrayerAdjustments;
  methodAdjustments?: AdhanPrayerAdjustments;
  rounding?: string;
  shafaq?: string;
  maghribAngle?: number;
}
```

## Error Handling

The library includes comprehensive error handling:

```typescript
try {
  const prayerTimes = await calculatePrayerTimes(coordinates, today, calculationParams);
  // Handle successful calculation
} catch (error) {
  if (error.code === 'INVALID_PARAMS') {
    // Handle invalid input parameters
  } else if (error.code === 'CALCULATION_ERROR') {
    // Handle calculation errors (e.g., extreme coordinates)
  }
  console.error('Prayer time calculation failed:', error.message);
}
```

## Performance

This library leverages React Native's New Architecture (TurboModules) for optimal performance:

- Direct native method calls without bridge serialization
- Lazy loading of native modules
- Type-safe interface with automatic codegen
- Minimal JavaScript overhead

## Accuracy

The calculations are identical to the official adhan libraries:
- iOS: Uses [adhan-swift v2.0.0](https://github.com/batoulapps/adhan-swift)
- Android: Uses [adhan-kotlin v2.0.0](https://github.com/batoulapps/adhan-kotlin)

Both libraries implement the same high-precision astronomical algorithms from "Astronomical Algorithms" by Jean Meeus.

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

Built on top of the official [Adhan](https://github.com/batoulapps/adhan) calculation libraries.
