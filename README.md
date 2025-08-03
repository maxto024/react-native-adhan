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

### ⚠️ Expo Go Incompatibility

This library uses native C++/Swift/Kotlin code via TurboModules for maximum performance and accuracy. As a result, **it will not work in the standard Expo Go app**, which is a sandboxed environment that cannot be extended with custom native code.

### ✅ Using with Expo (Custom Dev Client)

To use `react-native-adhan` in your Expo project, you need to build a **custom development client**. This is a version of your app that includes the native modules you've installed.

Here’s how to set it up:

1.  **Install the library and its dependencies:**

    ```sh
    npx expo install react-native-adhan
    ```

2.  **Add the config plugin to your `app.json`:**

    This step automatically links the native code when you build your app.

    ```json
    {
      "expo": {
        "plugins": [
          "react-native-adhan"
        ]
      }
    }
    ```

3.  **Build and run your custom dev client:**

    This command compiles the native code and installs the client on your simulator or device.

    ```sh
    # For iOS
    npx expo run:ios

    # For Android
    npx expo run:android
    ```

Once the custom client is built, you can develop your app just like you would with Expo Go, but with full access to all the native features of `react-native-adhan`.

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

Calculates all six prayer times for a specific location and date.

**Parameters:**
- `coordinates: AdhanCoordinates` - Location coordinates
- `dateComponents: AdhanDateComponents` - Date for calculation  
- `calculationParameters: AdhanCalculationParameters` - Calculation method and settings

**Returns:** `Promise<AdhanPrayerTimes>`
```typescript
{
  fajr: 1640995800000,     // Unix timestamp in milliseconds (UTC)
  sunrise: 1641002400000,
  dhuhr: 1641024000000,
  asr: 1641034800000,
  maghrib: 1641045600000,
  isha: 1641052800000
}
```

**Example:**
```typescript
const prayerTimes = await calculatePrayerTimes(
  { latitude: 21.4225, longitude: 39.8262 },
  { year: 2024, month: 1, day: 15 },
  { method: 'muslimWorldLeague', madhab: 'shafi' }
);
```

#### `calculateQibla(coordinates)`

Calculates the Qibla direction (direction to Kaaba in Makkah) from any location.

**Parameters:**
- `coordinates: AdhanCoordinates` - Your current location

**Returns:** `Promise<AdhanQibla>`
```typescript
{
  direction: 58.48  // Degrees from True North (0-360°)
}
```

**Example:**
```typescript
const qibla = await calculateQibla({ latitude: 40.7128, longitude: -74.0060 });
console.log(`Face ${qibla.direction.toFixed(1)}° from North`);
```

#### `calculateSunnahTimes(coordinates, dateComponents, calculationParameters)`

Calculates recommended Islamic night times for additional prayers and worship.

**Parameters:**
- `coordinates: AdhanCoordinates` - Location coordinates
- `dateComponents: AdhanDateComponents` - Date for calculation
- `calculationParameters: AdhanCalculationParameters` - Calculation settings

**Returns:** `Promise<AdhanSunnahTimes>`
```typescript
{
  middleOfTheNight: 1641000000000,     // Unix timestamp in milliseconds (UTC)
  lastThirdOfTheNight: 1641008000000   // Unix timestamp in milliseconds (UTC)
}
```

**Example:**
```typescript
const sunnahTimes = await calculateSunnahTimes(coordinates, today, params);
const middleOfNight = new Date(sunnahTimes.middleOfTheNight);
```

#### `getCurrentPrayer(coordinates, dateComponents, calculationParameters, currentTime?)`

Determines which prayer is currently active and which prayer comes next.

**Parameters:**
- `coordinates: AdhanCoordinates` - Location coordinates
- `dateComponents: AdhanDateComponents` - Date for calculation
- `calculationParameters: AdhanCalculationParameters` - Calculation settings
- `currentTime?: number` - Unix timestamp in milliseconds (defaults to current time)

**Returns:** `Promise<AdhanCurrentPrayerInfo>`
```typescript
{
  current: "dhuhr",  // Current prayer: "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha" | "none"
  next: "asr"        // Next prayer: "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha" | "none"
}
```

**Example:**
```typescript
const now = Date.now();
const currentPrayer = await getCurrentPrayer(coordinates, today, params, now);
console.log(`Current: ${currentPrayer.current}, Next: ${currentPrayer.next}`);
```

#### `getTimeForPrayer(coordinates, dateComponents, calculationParameters, prayer)`

Gets the exact time for a specific prayer.

**Parameters:**
- `coordinates: AdhanCoordinates` - Location coordinates
- `dateComponents: AdhanDateComponents` - Date for calculation
- `calculationParameters: AdhanCalculationParameters` - Calculation settings
- `prayer: string` - Prayer name: "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha"

**Returns:** `Promise<number | null>`
```typescript
1641024000000  // Unix timestamp in milliseconds (UTC), or null if invalid prayer name
```

**Example:**
```typescript
const dhuhrTime = await getTimeForPrayer(coordinates, today, params, "dhuhr");
if (dhuhrTime) {
  console.log("Dhuhr time:", new Date(dhuhrTime).toLocaleTimeString());
}
```

#### `calculatePrayerTimesRange(coordinates, startDate, endDate, calculationParameters)`

Calculates prayer times for multiple consecutive days (bulk calculation).

**Parameters:**
- `coordinates: AdhanCoordinates` - Location coordinates
- `startDate: AdhanDateComponents` - Start date
- `endDate: AdhanDateComponents` - End date (inclusive)
- `calculationParameters: AdhanCalculationParameters` - Calculation settings

**Returns:** `Promise<Array<{ date: AdhanDateComponents; prayerTimes: AdhanPrayerTimes }>>`
```typescript
[
  {
    date: { year: 2024, month: 1, day: 15 },
    prayerTimes: { fajr: 1640995800000, sunrise: 1641002400000, ... }
  },
  {
    date: { year: 2024, month: 1, day: 16 },
    prayerTimes: { fajr: 1641082200000, sunrise: 1641088800000, ... }
  }
  // ... more days
]
```

**Example:**
```typescript
const startDate = dateComponentsFromDate(new Date());
const endDate = dateComponentsFromDate(new Date(Date.now() + 7*24*60*60*1000));
const weeklyTimes = await calculatePrayerTimesRange(coordinates, startDate, endDate, params);
```

### Utility Functions

#### `getCalculationMethods()`

Returns detailed information about all available calculation methods.

**Returns:** `AdhanCalculationMethodInfo[]`
```typescript
[
  {
    name: "muslimWorldLeague",
    displayName: "Muslim World League", 
    fajrAngle: 18.0,
    ishaAngle: 17.0,
    ishaInterval: 0,
    description: "Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°."
  },
  // ... more methods
]
```

**Example:**
```typescript
const methods = getCalculationMethods();
methods.forEach(method => {
  console.log(`${method.displayName}: ${method.description}`);
});
```

#### `getMethodParameters(method)`

Gets default parameters for a specific calculation method.

**Parameters:**
- `method: string` - Method name (e.g., "muslimWorldLeague")

**Returns:** `Promise<AdhanCalculationParameters>`
```typescript
{
  method: "muslimWorldLeague",
  fajrAngle: 18.0,
  ishaAngle: 17.0,
  ishaInterval: 0,
  madhab: "shafi",
  rounding: "nearest",
  shafaq: "general"
}
```

**Example:**
```typescript
const params = await getMethodParameters("egyptianGeneralAuthority");
console.log(`Fajr angle: ${params.fajrAngle}°`);
```

#### `getLibraryInfo()`

Returns information about the native library versions and platform.

**Returns:** `Object`
```typescript
{
  version: "2.0.0",
  swiftLibraryVersion: "2.0.0",    // iOS only
  kotlinLibraryVersion: "2.0.0",  // Android only
  platform: "iOS" | "Android"
}
```

### Helper Functions

#### `dateComponentsFromDate(date)`

Converts a JavaScript Date object to the date components format required by the library.

**Parameters:**
- `date: Date` - JavaScript Date object

**Returns:** `AdhanDateComponents`
```typescript
{
  year: 2024,
  month: 1,    // 1-indexed (January = 1)
  day: 15
}
```

**Example:**
```typescript
const today = dateComponentsFromDate(new Date());
const tomorrow = dateComponentsFromDate(new Date(Date.now() + 24*60*60*1000));
```

#### `timestampToDate(timestamp)`

Converts a Unix timestamp (milliseconds) to a JavaScript Date object.

**Parameters:**
- `timestamp: number` - Unix timestamp in milliseconds

**Returns:** `Date`

**Example:**
```typescript
const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
const fajrDate = timestampToDate(prayerTimes.fajr);
console.log("Fajr time:", fajrDate.toLocaleTimeString());
```

#### `prayerTimesToDates(prayerTimes)`

Converts an entire prayer times object to JavaScript Date objects for easy handling.

**Parameters:**
- `prayerTimes: AdhanPrayerTimes` - Prayer times with timestamps

**Returns:** `Object with Date values`
```typescript
{
  fajr: Date,
  sunrise: Date,
  dhuhr: Date,
  asr: Date,
  maghrib: Date,
  isha: Date
}
```

**Example:**
```typescript
const prayerTimes = await calculatePrayerTimes(coordinates, today, params);
const prayerDates = prayerTimesToDates(prayerTimes);

console.log("Today's Prayer Times:");
console.log("Fajr:", prayerDates.fajr.toLocaleTimeString());
console.log("Dhuhr:", prayerDates.dhuhr.toLocaleTimeString());
console.log("Asr:", prayerDates.asr.toLocaleTimeString());
console.log("Maghrib:", prayerDates.maghrib.toLocaleTimeString());
console.log("Isha:", prayerDates.isha.toLocaleTimeString());
```

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

## Issues and Support

- **Bug Reports**: [GitHub Issues](https://github.com/maxto024/react-native-adhan/issues)
- **Feature Requests**: [GitHub Issues](https://github.com/maxto024/react-native-adhan/issues)
- **Documentation**: [GitHub Repository](https://github.com/maxto024/react-native-adhan)

## Author

**Mohamed Elmi Hassan**
- GitHub: [@maxto024](https://github.com/maxto024)
- Email: maxto024@gmail.com

## Acknowledgments

This library is built on top of the excellent work from:
- [Batoul Apps](https://github.com/batoulapps) for the original [adhan-swift](https://github.com/batoulapps/adhan-swift) and [adhan-kotlin](https://github.com/batoulapps/adhan-kotlin) libraries
- The Islamic Society of North America (ISNA) and other Islamic organizations for calculation method standards
- The open-source community for React Native and Islamic software development

## License

MIT License - see the [LICENSE](LICENSE) file for details.

## Repository

- **GitHub**: [maxto024/react-native-adhan](https://github.com/maxto024/react-native-adhan)
- **NPM**: [react-native-adhan](https://www.npmjs.com/package/react-native-adhan)
- **Homepage**: [https://github.com/maxto024/react-native-adhan](https://github.com/maxto024/react-native-adhan)

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

Built on top of the official [Adhan](https://github.com/batoulapps/adhan) calculation libraries by [Batoul Apps](https://github.com/batoulapps).
