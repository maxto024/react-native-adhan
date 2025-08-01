# Expo Integration Guide

This guide shows how to use `react-native-adhan` with Expo development builds.

## Prerequisites

- Expo SDK 50+ 
- Expo CLI or Expo development build workflow
- Physical device or simulator (Expo Go doesn't support native modules)

## Installation

1. Install the package:
```bash
npx expo install react-native-adhan
```

2. Add the config plugin to your `app.json` or `app.config.js`:

```json
{
  "expo": {
    "plugins": [
      ["react-native-adhan/plugin"]
    ]
  }
}
```

With options:
```json
{
  "expo": {
    "plugins": [
      [
        "react-native-adhan/plugin",
        {
          "enableCppOptimizations": true,
          "customMethods": ["ISNA", "MWL", "Karachi"]
        }
      ]
    ]
  }
}
```

## Development Build

Create a development build with the native code:

```bash
# For iOS
npx expo run:ios

# For Android  
npx expo run:android

# Or create a build
npx eas build --platform ios --profile development
npx eas build --platform android --profile development
```

## Usage in Expo

```typescript
import React, { useEffect, useState } from 'react';
import { View, Text } from 'react-native';
import { getPrayerTimes, CalculationMethod, type PrayerTimesResult } from 'react-native-adhan';

export default function App() {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTimesResult | null>(null);

  useEffect(() => {
    const fetchPrayerTimes = async () => {
      try {
        const times = await getPrayerTimes({
          coordinates: {
            latitude: 40.7128,
            longitude: -74.0060
          },
          parameters: {
            method: CalculationMethod.ISNA
          }
        });
        setPrayerTimes(times);
      } catch (error) {
        console.error('Error fetching prayer times:', error);
      }
    };

    fetchPrayerTimes();
  }, []);

  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text style={{ fontSize: 24, marginBottom: 20 }}>Prayer Times</Text>
      {prayerTimes ? (
        <View>
          <Text>Fajr: {new Date(prayerTimes.fajr).toLocaleTimeString()}</Text>
          <Text>Dhuhr: {new Date(prayerTimes.dhuhr).toLocaleTimeString()}</Text>
          <Text>Asr: {new Date(prayerTimes.asr).toLocaleTimeString()}</Text>
          <Text>Maghrib: {new Date(prayerTimes.maghrib).toLocaleTimeString()}</Text>
          <Text>Isha: {new Date(prayerTimes.isha).toLocaleTimeString()}</Text>
        </View>
      ) : (
        <Text>Loading...</Text>
      )}
    </View>
  );
}
```

## Plugin Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enableCppOptimizations` | `boolean` | `false` | Enable C++ compiler optimizations |
| `customMethods` | `string[]` | `[]` | Specify which calculation methods to include |

## Troubleshooting

### "Module not found" Error
Make sure you've created a development build after adding the plugin. Expo Go doesn't support native modules.

### Build Errors
1. Clear caches: `npx expo r -c`
2. Rebuild: `npx expo run:ios --clear`
3. Check that your `app.json` includes the plugin correctly

### C++ Compilation Issues
The plugin automatically configures CMake for Android and CocoaPods for iOS. If you encounter issues:

1. Ensure you're using Expo SDK 50+
2. Check that your development build includes the plugin
3. Try cleaning and rebuilding

### Performance Issues
Enable C++ optimizations in the plugin configuration:
```json
{
  "expo": {
    "plugins": [
      [
        "react-native-adhan/plugin",
        {
          "enableCppOptimizations": true
        }
      ]
    ]
  }
}
```

## Migration from Bare React Native

If you're migrating from a bare React Native project:

1. Remove manual iOS and Android configuration
2. Add the plugin to your `app.json`
3. Create a new development build

## Next Steps

- [API Documentation](./README.md#api)
- [Performance Guide](./PERFORMANCE.md)
- [Troubleshooting](./TROUBLESHOOTING.md)