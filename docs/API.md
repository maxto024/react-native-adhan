# API Reference

This document provides a detailed reference for the `react-native-adhan` API. It includes full TypeScript definitions, parameter descriptions, return values, and examples for each function.

## Table of Contents

1.  [TypeScript Interfaces](#typescript-interfaces)
2.  [Enumerations](#enumerations)
3.  [API Methods](#api-methods)
    -   [`calculatePrayerTimes`](#calculateprayertimes)
    -   [`calculateQibla`](#calculateqibla)
    -   [`calculateSunnahTimes`](#calculatesunnahtimes)
    -   [`getCurrentPrayer`](#getcurrentprayer)
    -   [`getTimeForPrayer`](#gettimeforprayer)
    -   [`getCalculationMethods`](#getcalculationmethods)
    -   [`getMethodParameters`](#getmethodparameters)
    -   [`getLibraryInfo`](#getlibraryinfo)
    -   [`validateCoordinates`](#validatecoordinates)
4.  [Helper Functions](#helper-functions)

---

## TypeScript Interfaces

These are the core data structures used throughout the library.

### `AdhanCoordinates`

Represents geographic coordinates.

```typescript
export interface AdhanCoordinates {
  /** Latitude, in degrees. Must be between -90 and 90. */
  latitude: number;
  /** Longitude, in degrees. Must be between -180 and 180. */
  longitude: number;
}
```

### `AdhanDateComponents`

Represents a calendar date.

```typescript
export interface AdhanDateComponents {
  /** The full year (e.g., 2024). */
  year: number;
  /** The month of the year, 1-indexed (1 for January, 12 for December). */
  month: number;
  /** The day of the month. */
  day: number;
}
```

### `AdhanCalculationParameters`

Specifies the settings for prayer time calculations. All properties are optional.

```typescript
export interface AdhanCalculationParameters {
  /** The calculation method name. See `CalculationMethod` enum. Defaults to `MUSLIM_WORLD_LEAGUE`. */
  method?: string;
  /** The school of thought for Asr prayer. See `Madhab` enum. Defaults to `shafi`. */
  madhab?: 'shafi' | 'hanafi';
  /** The rule for handling high-latitude locations. See `HighLatitudeRule` enum. */
  highLatitudeRule?: 'middleOfTheNight' | 'seventhOfTheNight' | 'twilightAngle';
  /** Manual adjustments for each prayer time, in minutes. */
  prayerAdjustments?: {
    fajr?: number;
    sunrise?: number;
    dhuhr?: number;
    asr?: number;
    maghrib?: number;
    isha?: number;
  };
  /** Fajr angle in degrees. */
  fajrAngle?: number;
  /** Isha angle in degrees. */
  ishaAngle?: number;
  /** Minutes to add to Maghrib for Isha. Used by some methods. */
  ishaInterval?: number;
  /** How to round prayer times to the nearest minute. See `Rounding` enum. */
  rounding?: 'nearest' | 'up' | 'down';
  /** The type of twilight to use for Isha. See `Shafaq` enum. */
  shafaq?: 'general' | 'ahmer' | 'abyad';
}
```

### `AdhanPrayerTimes`

The calculated prayer times for a single day.

```typescript
export interface AdhanPrayerTimes {
  /** Fajr prayer time as a Unix timestamp in milliseconds (UTC). */
  fajr: number;
  /** Sunrise time as a Unix timestamp in milliseconds (UTC). */
  sunrise: number;
  /** Dhuhr prayer time as a Unix timestamp in milliseconds (UTC). */
  dhuhr: number;
  /** Asr prayer time as a Unix timestamp in milliseconds (UTC). */
  asr: number;
  /** Maghrib prayer time as a Unix timestamp in milliseconds (UTC). */
  maghrib: number;
  /** Isha prayer time as a Unix timestamp in milliseconds (UTC). */
  isha: number;
}
```

### `AdhanQibla`

The calculated Qibla direction.

```typescript
export interface AdhanQibla {
  /** The direction to the Kaaba in Makkah, in degrees from True North (0-360). */
  direction: number;
}
```

### `AdhanSunnahTimes`

Calculated times for voluntary (Sunnah) prayers.

```typescript
export interface AdhanSunnahTimes {
  /** The midpoint between Maghrib and Fajr, as a Unix timestamp in milliseconds (UTC). */
  middleOfTheNight: number;
  /** The beginning of the last third of the night, as a Unix timestamp in milliseconds (UTC). */
  lastThirdOfTheNight: number;
}
```

### `AdhanCurrentPrayerInfo`

Information about the current and next prayer.

```typescript
export interface AdhanCurrentPrayerInfo {
  /** The name of the current prayer period ('fajr', 'dhuhr', etc.), or 'none'. */
  current: string;
  /** The name of the next prayer period, or 'none'. */
  next: string;
}
```

### `AdhanCalculationMethodInfo`

Detailed information about a calculation method.

```typescript
export interface AdhanCalculationMethodInfo {
  /** The unique identifier for the method (e.g., 'muslimWorldLeague'). */
  name: string;
  /** The display-friendly name (e.g., 'Muslim World League'). */
  displayName: string;
  /** The Fajr angle used by this method. */
  fajrAngle: number;
  /** The Isha angle used by this method. */
  ishaAngle: number;
  /** The Isha interval (in minutes) used by this method, if applicable. */
  ishaInterval: number;
  /** A brief description of the method. */
  description: string;
}
```

---

## Enumerations

For convenience, the library provides enums for common parameter values.

-   `CalculationMethod`: `MUSLIM_WORLD_LEAGUE`, `EGYPTIAN`, `KARACHI`, `UMM_AL_QURA`, `DUBAI`, `MOON_SIGHTING_COMMITTEE`, `NORTH_AMERICA`, `KUWAIT`, `QATAR`, `SINGAPORE`, `TEHRAN`, `TURKEY`, `OTHER`.
-   `Madhab`: `SHAFI`, `HANAFI`.
-   `HighLatitudeRule`: `MIDDLE_OF_THE_NIGHT`, `SEVENTH_OF_THE_NIGHT`, `TWILIGHT_ANGLE`.
-   `Rounding`: `NEAREST`, `UP`, `DOWN`.
-   `Shafaq`: `GENERAL`, `AHMER`, `ABYAD`.
-   `Prayer`: `FAJR`, `SUNRISE`, `DHUHR`, `ASR`, `MAGHRIB`, `ISHA`.

---

## API Methods

### `calculatePrayerTimes`

Calculates the five daily prayer times plus sunrise.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates` - The geographic location.
    -   `dateComponents`: `AdhanDateComponents` - The date for the calculation.
    -   `calculationParameters`: `AdhanCalculationParameters` - The calculation settings.
-   **Returns:** `Promise<AdhanPrayerTimes>` - An object containing prayer times as Unix timestamps in milliseconds.
-   **Errors:** Throws an error if the native module fails (e.g., invalid parameters).

**Example:**

```typescript
import { calculatePrayerTimes, dateComponentsFromDate, CalculationMethod } from 'react-native-adhan';

const makkah = { latitude: 21.4225, longitude: 39.8262 };
const today = dateComponentsFromDate(new Date());
const params = { method: CalculationMethod.UMM_AL_QURA };

const prayerTimes = await calculatePrayerTimes(makkah, today, params);
console.log('Fajr in Makkah:', new Date(prayerTimes.fajr).toLocaleTimeString());
```

### `calculateQibla`

Calculates the direction to the Kaaba in Makkah.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates` - The geographic location.
-   **Returns:** `Promise<AdhanQibla>` - An object containing the direction in degrees from North.
-   **Errors:** Throws an error if the native module fails.

**Example:**

```typescript
import { calculateQibla } from 'react-native-adhan';

const newYork = { latitude: 40.7128, longitude: -74.0060 };
const qibla = await calculateQibla(newYork);
console.log(`Qibla direction from NYC: ${qibla.direction.toFixed(2)}°`);
```

### `calculateSunnahTimes`

Calculates the middle of the night and the last third of the night.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates` - The geographic location.
    -   `dateComponents`: `AdhanDateComponents` - The date for the calculation.
    -   `calculationParameters`: `AdhanCalculationParameters` - The calculation settings.
-   **Returns:** `Promise<AdhanSunnahTimes>` - An object containing Sunnah times as Unix timestamps.
-   **Errors:** Throws an error if the native module fails.

**Example:**

```typescript
import { calculateSunnahTimes, dateComponentsFromDate, CalculationMethod } from 'react-native-adhan';

const location = { latitude: 34.0522, longitude: -118.2437 }; // Los Angeles
const today = dateComponentsFromDate(new Date());
const params = { method: CalculationMethod.NORTH_AMERICA };

const sunnahTimes = await calculateSunnahTimes(location, today, params);
console.log('Middle of the night:', new Date(sunnahTimes.middleOfTheNight).toLocaleTimeString());
```

### `getCurrentPrayer`

Determines the current and next prayer based on a given time.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates`
    -   `dateComponents`: `AdhanDateComponents`
    -   `calculationParameters`: `AdhanCalculationParameters`
    -   `currentTime`: `number` - The time to check, as a Unix timestamp in milliseconds.
-   **Returns:** `Promise<AdhanCurrentPrayerInfo>`
-   **Errors:** Throws an error if the native module fails.

**Example:**

```typescript
import { getCurrentPrayer, dateComponentsFromDate, CalculationMethod } from 'react-native-adhan';

const location = { latitude: 51.5074, longitude: -0.1278 }; // London
const today = dateComponentsFromDate(new Date());
const params = { method: CalculationMethod.MUSLIM_WORLD_LEAGUE };

const prayerInfo = await getCurrentPrayer(location, today, params, Date.now());
console.log(`Current prayer is ${prayerInfo.current}, next is ${prayerInfo.next}.`);
```

### `getTimeForPrayer`

Retrieves the time for a single, specific prayer.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates`
    -   `dateComponents`: `AdhanDateComponents`
    -   `calculationParameters`: `AdhanCalculationParameters`
    -   `prayer`: `string` - The name of the prayer (e.g., 'fajr', 'dhuhr'). Use the `Prayer` enum.
-   **Returns:** `Promise<number | null>` - The prayer time as a Unix timestamp, or `null` if the prayer name is invalid.
-   **Errors:** Throws an error if the native module fails.

**Example:**

```typescript
import { getTimeForPrayer, dateComponentsFromDate, Prayer, CalculationMethod } from 'react-native-adhan';

const location = { latitude: 35.6895, longitude: 139.6917 }; // Tokyo
const today = dateComponentsFromDate(new Date());
const params = { method: CalculationMethod.KARACHI };

const asrTime = await getTimeForPrayer(location, today, params, Prayer.ASR);
if (asrTime) {
  console.log('Asr time in Tokyo:', new Date(asrTime).toLocaleTimeString());
}
```

### `getCalculationMethods`

Returns a list of all supported calculation methods and their details. This is a synchronous function.

-   **Parameters:** None.
-   **Returns:** `AdhanCalculationMethodInfo[]` - An array of method information objects.

**Example:**

```typescript
import { getCalculationMethods } from 'react-native-adhan';

const methods = getCalculationMethods();
console.log('Available Calculation Methods:');
methods.forEach(method => console.log(`- ${method.displayName}`));
```

### `getMethodParameters`

Gets the default parameters for a given calculation method.

-   **Parameters:**
    -   `method`: `string` - The name of the method. Use the `CalculationMethod` enum.
-   **Returns:** `Promise<AdhanCalculationParameters>` - The default parameters for that method.
-   **Errors:** Throws an error if the method name is invalid.

**Example:**

```typescript
import { getMethodParameters, CalculationMethod } from 'react-native-adhan';

const egyptianParams = await getMethodParameters(CalculationMethod.EGYPTIAN);
console.log(`Egyptian method Fajr angle: ${egyptianParams.fajrAngle}°`);
```

### `getLibraryInfo`

Returns version information for the library and its native dependencies. This is a synchronous function.

-   **Parameters:** None.
-   **Returns:** `{ version: string, swiftLibraryVersion?: string, kotlinLibraryVersion?: string, platform: string }`

**Example:**

```typescript
import { getLibraryInfo } from 'react-native-adhan';

const info = getLibraryInfo();
console.log(`Running react-native-adhan v${info.version} on ${info.platform}`);
```

### `validateCoordinates`

A synchronous helper to check if coordinates are valid.

-   **Parameters:**
    -   `coordinates`: `AdhanCoordinates`
-   **Returns:** `boolean` - `true` if valid, `false` otherwise.

**Example:**

```typescript
import { validateCoordinates } from 'react-native-adhan';

console.log(validateCoordinates({ latitude: 90, longitude: 180 })); // true
console.log(validateCoordinates({ latitude: 91, longitude: 180 })); // false
```

---

## Helper Functions

The library exports a few JavaScript helpers for convenience.

### `dateComponentsFromDate`

Converts a JavaScript `Date` object to the `AdhanDateComponents` format.

```typescript
import { dateComponentsFromDate } from 'react-native-adhan';

const components = dateComponentsFromDate(new Date());
// { year: 2024, month: 8, day: 2 }
```

### `timestampToDate`

Converts a Unix timestamp (in milliseconds) to a JavaScript `Date` object.

```typescript
import { timestampToDate } from 'react-native-adhan';

const date = timestampToDate(1722556800000);
// Date object for 2025-08-02
```

### `prayerTimesToDates`

Converts an entire `AdhanPrayerTimes` object from timestamps to `Date` objects.

```typescript
import { prayerTimesToDates, calculatePrayerTimes } from 'react-native-adhan';

const prayerTimestamps = await calculatePrayerTimes(...);
const prayerDates = prayerTimesToDates(prayerTimestamps);

console.log(prayerDates.fajr.toLocaleTimeString());
```
