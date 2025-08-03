# react-native-adhan

**React Native TurboModule** for accurate Islamic prayer times and Qibla direction calculations on iOS and Android. This library leverages the official [adhan-swift](https://github.com/batoulapps/adhan-swift) and [adhan-kotlin](https://github.com/batoulapps/adhan-kotlin) SDKs to deliver consistent, high-precision results across platforms.

---

## 📦 Features

- **Prayer Times:** Compute Fajr, Sunrise, Dhuhr, Asr, Maghrib, and Isha times.  
- **Qibla Direction:** Determine the bearing to the Kaaba from any location.  
- **Sunnah Times:** Calculate the middle and last third of the night for additional worship.  
- **Calculation Methods:** Support for 12+ global methods (e.g., Muslim World League, ISNA, Karachi).  
- **High Latitude Rules:** Handles polar and extreme latitude scenarios.  
- **Bulk Range Calculations:** Retrieve prayer times across date ranges.  
- **New Architecture:** Built as a TurboModule for minimal bridge overhead.  
- **TypeScript Support:** Fully typed interfaces and utility functions.  
- **Expo Plugin:** Out-of-the-box support for custom dev clients.

---

## 🚀 Installation

### React Native

```bash
npm install react-native-adhan
```

**iOS:**  
```ruby
# In your Podfile
pod 'react_native_adhan', :path => '../node_modules/react-native-adhan'
```

**Android:**  
The Gradle plugin automatically includes the native modules.

### Expo (Custom Dev Client)

> **Note:** Expo Go does not support custom native modules. You must build a custom client.

1. Install the package:
   ```bash
   npx expo install react-native-adhan
   ```
2. Add the plugin to `app.json`:
   ```json
   {
     "expo": {
       "plugins": ["react-native-adhan"]
     }
   }
   ```
3. Rebuild:
   ```bash
   npx expo run:ios
   npx expo run:android
   ```

---

## 💡 Usage

Import and call the methods directly:

```typescript
import Adhan, {
  CalculationMethod,
  Madhab,
  HighLatitudeRule,
  dateComponentsFromDate,
  prayerTimesToDates,
} from 'react-native-adhan';

const coords = { latitude: 21.4225, longitude: 39.8262 };
const today = dateComponentsFromDate(new Date());

const params = {
  method: CalculationMethod.MUSLIM_WORLD_LEAGUE,
  madhab: Madhab.SHAFI,
  highLatitudeRule: HighLatitudeRule.MIDDLE_OF_THE_NIGHT,
};

// Async/await
const prayerTimes = await Adhan.calculatePrayerTimes(coords, today, params);
const prayerDates = prayerTimesToDates(prayerTimes);

console.log('Fajr:', prayerDates.fajr.toLocaleTimeString());
```

---

### Example API

| Method                         | Description                                                  |
| ------------------------------ | ------------------------------------------------------------ |
| `calculatePrayerTimes(...)`    | Returns six prayer timestamps for a given date and location. |
| `calculateQibla(coords)`       | Returns Qibla bearing in degrees from True North.            |
| `calculateSunnahTimes(...)`    | Returns middle and last third of the night timestamps.       |
| `getCurrentPrayer(...)`        | Identifies current and next prayer.                         |
| `getTimeForPrayer(...)`        | Returns timestamp for a specific prayer.                    |
| `calculatePrayerTimesRange...` | Bulk computation over a date range.                          |
| `getCalculationMethods()`      | Lists available calculation methods.                        |
| `getMethodParameters(name)`    | Retrieves default parameters for a method.                   |
| `getLibraryInfo()`             | Returns native SDK versions and platform details.           |

---

## 🛠️ API Reference

See [API Reference](./docs/API.md) for detailed parameter and return types.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Please review our [Contributing Guide](CONTRIBUTING.md).

---

## ⚖️ License

MIT © 2025 Mohamed Elmi Hassan  
