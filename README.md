# react-native-adhan

**react-native-adhan** is a high-performance native module for React Native that calculates accurate Islamic prayer times using the official [adhan-cpp](https://github.com/batoulapps/adhan-cpp) library. Designed for speed, reliability, and mobile performance, this module works seamlessly on both iOS and Android and is ideal for prayer apps, masjid tools, or Islamic productivity tools.

✅ Powered by C++ for fast bulk calculations  
🚀 Lightweight & easy to integrate  
📱 Perfect for mobile prayer tracking and performance

## Installation

### React Native CLI

```sh
npm install react-native-adhan
```

For React Native 0.60 and above, the package will be auto-linked. For older versions, you'll need to manually link the library.

### Expo

```sh
npx expo install react-native-adhan
```

Add the config plugin to your `app.json`:
```json
{
  "expo": {
    "plugins": ["react-native-adhan/plugin"]
  }
}
```

Then create a development build:
```sh
npx expo run:ios
# or
npx expo run:android
```

📖 [Complete Expo integration guide](./EXPO.md)

## Usage

### Basic Prayer Time Calculation

```js
import { getPrayerTimes, CalculationMethod } from 'react-native-adhan';

// Get prayer times for New York using ISNA calculation method
const prayerTimes = await getPrayerTimes({
  coordinates: {
    latitude: 40.7128,
    longitude: -74.0060
  },
  parameters: {
    method: CalculationMethod.ISNA
  }
});

console.log(prayerTimes);
// Output:
// {
//   fajr: '2024-01-01T05:30:00-05:00',
//   sunrise: '2024-01-01T07:00:00-05:00',
//   dhuhr: '2024-01-01T12:30:00-05:00',
//   asr: '2024-01-01T15:45:00-05:00',
//   maghrib: '2024-01-01T18:15:00-05:00',
//   isha: '2024-01-01T19:45:00-05:00'
// }
```

### Available Calculation Methods

```js
import { CalculationMethod } from 'react-native-adhan';

// Available methods:
CalculationMethod.ISNA          // Islamic Society of North America
CalculationMethod.MWL           // Muslim World League
CalculationMethod.Karachi       // University of Islamic Sciences, Karachi
CalculationMethod.Egypt         // Egyptian General Authority of Survey
CalculationMethod.UmmAlQura     // Umm Al-Qura University, Makkah
CalculationMethod.Dubai         // Dubai
CalculationMethod.Moonsighting  // Moonsighting Committee Worldwide
CalculationMethod.Kuwait        // Kuwait
CalculationMethod.Qatar         // Qatar
CalculationMethod.Singapore     // Singapore
CalculationMethod.Tehran        // Tehran
CalculationMethod.Turkey        // Turkey
```

### Advanced Usage

```js
import { getPrayerTimes, CalculationMethod, Madhab } from 'react-native-adhan';

// Advanced calculation with custom parameters
const prayerTimes = await getPrayerTimes({
  coordinates: {
    latitude: 21.4225, // Makkah
    longitude: 39.8262,
    elevation: 277 // meters above sea level
  },
  date: {
    year: 2024,
    month: 1,
    day: 15
  },
  parameters: {
    method: CalculationMethod.UmmAlQura,
    madhab: Madhab.Hanafi, // Hanafi or Shafi (default)
    adjustments: {
      fajr: 2,    // +2 minutes
      dhuhr: -1,  // -1 minute
      asr: 0,
      maghrib: 1,
      isha: 3
    }
  },
  timezone: 'Asia/Riyadh'
});
```

### Qibla Direction

```js
import { getQiblaDirection } from 'react-native-adhan';

const qibla = await getQiblaDirection({
  latitude: 40.7128,
  longitude: -74.0060
});

console.log(`Qibla direction: ${qibla.direction.toFixed(1)}° ${qibla.compassBearing}`);
console.log(`Distance to Kaaba: ${qibla.distance.toFixed(0)} km`);
```

### Bulk Calculations

```js
import { getBulkPrayerTimes } from 'react-native-adhan';

// Get prayer times for a month
const bulkTimes = await getBulkPrayerTimes({
  coordinates: { latitude: 40.7128, longitude: -74.0060 },
  startDate: '2024-01-01',
  endDate: '2024-01-31',
  parameters: { method: CalculationMethod.ISNA }
});

console.log(`Calculated ${bulkTimes.totalDays} days of prayer times`);
bulkTimes.prayerTimes.forEach(day => {
  console.log(`${day.date}: Fajr ${day.fajr}, Isha ${day.isha}`);
});
```

### Error Handling & Validation

```js
import { getPrayerTimes, CalculationMethod, validateCoordinates } from 'react-native-adhan';

// Validate coordinates before calculation
const coords = { latitude: 21.4225, longitude: 39.8262 };
const validation = validateCoordinates(coords);

if (!validation.isValid) {
  console.error('Invalid coordinates:', validation.errors);
  return;
}

try {
  const prayerTimes = await getPrayerTimes({
    coordinates: coords,
    parameters: { method: CalculationMethod.UmmAlQura }
  });
  
  console.log(`Fajr: ${new Date(prayerTimes.fajr).toLocaleTimeString()}`);
  console.log(`Dhuhr: ${new Date(prayerTimes.dhuhr).toLocaleTimeString()}`);
} catch (error) {
  if (error.code === 'INVALID_COORDINATES') {
    console.error('Coordinate validation failed:', error.context);
  } else if (error.code === 'MODULE_NOT_AVAILABLE') {
    console.error('Native module unavailable:', error.message);
  } else {
    console.error('Unexpected error:', error);
  }
}
```

### Performance Monitoring

```js
import { configure, getPerformanceMetrics } from 'react-native-adhan';

// Enable performance monitoring
configure({
  enablePerformanceMonitoring: true,
  enableCaching: true,
  maxCacheSize: 100
});

const prayerTimes = await getPrayerTimes({...});

// Check performance metrics
const metrics = getPerformanceMetrics();
if (metrics) {
  console.log(`Calculation took ${metrics.calculationTime}ms`);
  console.log(`Used native module: ${metrics.usedNativeModule}`);
}
```

## API Reference

### Core Functions

#### `getPrayerTimes(request: PrayerTimesRequest): Promise<PrayerTimesResult>`

Calculates prayer times for a specific location and date with comprehensive error handling.

**Parameters:**
- `coordinates` (Coordinates): Geographic location
  - `latitude` (number): Latitude (-90 to 90)
  - `longitude` (number): Longitude (-180 to 180)  
  - `elevation?` (number): Elevation in meters
- `date?` (DateInput | string): Date for calculation (defaults to current date)
- `parameters?` (CalculationParameters): Calculation settings
  - `method` (CalculationMethod): Calculation method
  - `madhab?` (Madhab): School of jurisprudence
  - `adjustments?` (PrayerAdjustments): Prayer time adjustments in minutes
- `timezone?` (string): Timezone for result formatting

**Returns:** `Promise<PrayerTimesResult>`
- `fajr`, `sunrise`, `dhuhr`, `asr`, `maghrib`, `isha` (string): Prayer times in ISO 8601 format
- `metadata?` (PrayerTimesMetadata): Calculation metadata

#### `getQiblaDirection(coordinates: Coordinates): Promise<QiblaResult>`

Calculates the direction to Kaaba from given coordinates.

**Returns:** `Promise<QiblaResult>`
- `direction` (number): Direction in degrees from North (0-360)
- `distance` (number): Distance to Kaaba in kilometers
- `compassBearing` (string): Compass bearing (e.g., "NE", "SW")

#### `getBulkPrayerTimes(request: BulkPrayerTimesRequest): Promise<BulkPrayerTimesResult>`

Calculates prayer times for multiple consecutive days.

#### `getAvailableMethods(): MethodInfo[]`

Returns information about all available calculation methods.

#### `configure(config: Partial<ModuleConfig>): void`

Configures module behavior including performance monitoring and caching.

### Validation Functions

#### `validateCoordinates(coordinates: Coordinates): ValidationResult`
#### `validateDate(date: DateInput | string): ValidationResult`

### Performance Functions

#### `getPerformanceMetrics(): PerformanceMetrics | null`

Returns performance metrics for the last calculation.

### Types

```typescript
interface PrayerTimesRequest {
  coordinates: Coordinates;
  date?: DateInput | string;
  parameters?: CalculationParameters;
  timezone?: string;
}

interface Coordinates {
  latitude: number;
  longitude: number;
  elevation?: number;
}

enum CalculationMethod {
  ISNA = 'ISNA',
  MWL = 'MWL',
  Karachi = 'Karachi',
  Egypt = 'Egypt',
  UmmAlQura = 'UmmAlQura',
  Dubai = 'Dubai',
  Moonsighting = 'Moonsighting',
  Kuwait = 'Kuwait',
  Qatar = 'Qatar',
  Singapore = 'Singapore',
  Tehran = 'Tehran',
  Turkey = 'Turkey'
}

enum Madhab {
  Shafi = 'Shafi',  // Default
  Hanafi = 'Hanafi'
}
```

## Features

- ⚡ **High Performance**: TurboModule architecture with C++ calculations
- 🛡️ **Type Safe**: Comprehensive TypeScript definitions
- 📱 **Expo Compatible**: Works with Expo development builds
- 🌍 **13 Calculation Methods**: Support for major Islamic authorities
- 🎯 **Qibla Direction**: Calculate direction and distance to Kaaba
- 📊 **Performance Monitoring**: Built-in performance metrics
- 🔄 **Bulk Calculations**: Efficient multi-day calculations
- ✅ **Runtime Validation**: Input validation with detailed error reporting
- 🔧 **Configurable**: Extensive customization options
- 🚀 **Fallback Support**: Graceful degradation to legacy bridge

## Performance

This library is optimized for mobile performance:

- **TurboModule**: Direct JavaScript ↔ Native communication via JSI
- **C++ Core**: Prayer time calculations in optimized C++ 
- **Caching**: Intelligent result caching to avoid redundant calculations
- **Bulk Operations**: Efficient multi-day calculations
- **Memory Efficient**: Minimal memory footprint
- **Battery Friendly**: Optimized algorithms reduce CPU usage

Typical performance on modern devices:
- Single calculation: **<1ms**
- Monthly bulk calculation (30 days): **<10ms**
- Qibla direction: **<0.5ms**

## Platform Support

| Platform | Status | Architecture |
|----------|--------|--------------|
| iOS | ✅ | TurboModule + Legacy Bridge |
| Android | ✅ | TurboModule + Legacy Bridge |
| Expo | ✅ | Development Builds Only |
| React Native | ✅ | 0.60+ (New Architecture Ready) |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
