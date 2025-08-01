# Expo Integration Guide

Complete guide for integrating `react-native-adhan` with Expo projects using development builds. This library provides accurate Islamic prayer time calculations with full TurboModule support.

## ⚠️ Important Requirements

- **Development Build Required**: This library uses TurboModules and won't work with Expo Go
- **Expo SDK 48+**: Recommended for best New Architecture support
- **EAS Build or Local Builds**: You need either an EAS subscription or local development environment

## 🚀 Quick Start

### 1. Install the Package

```bash
npx expo install react-native-adhan
```

### 2. Add Config Plugin

Add the config plugin to your `app.json`:

```json
{
  "expo": {
    "name": "My Prayer App",
    "plugins": [
      "react-native-adhan"
    ]
  }
}
```

**Advanced Configuration** (app.config.js):
```js
export default {
  expo: {
    name: "Prayer Times App",
    plugins: [
      [
        "react-native-adhan",
        {
          // Enable New Architecture optimizations
          enableNewArchitecture: true,
          // Custom iOS deployment target
          iosDeploymentTarget: "11.0"
        }
      ]
    ]
  }
};
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

## 📱 Complete Expo Example

```tsx
import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { 
  getPrayerTimes, 
  getQiblaDirection,
  CalculationMethod, 
  Madhab,
  type PrayerTimesResult,
  type QiblaResult 
} from 'react-native-adhan';

export default function ExpoAdhanApp() {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTimesResult | null>(null);
  const [qibla, setQibla] = useState<QiblaResult | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPrayerData = async () => {
      try {
        const coordinates = { latitude: 40.7128, longitude: -74.0060 }; // NYC
        
        // Fetch prayer times with enhanced parameters
        const times = await getPrayerTimes({
          coordinates,
          parameters: {
            method: CalculationMethod.ISNA,
            madhab: Madhab.Shafi,  // Asr jurisprudence
            adjustments: {
              fajr: 2,   // +2 minutes
              isha: -1   // -1 minute
            }
          },
          timezone: 'America/New_York'  // Timezone support
        });
        
        // Fetch Qibla direction
        const qiblaDirection = await getQiblaDirection(coordinates);
        
        setPrayerTimes(times);
        setQibla(qiblaDirection);
      } catch (error) {
        console.error('Error fetching prayer data:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchPrayerData();
  }, []);

  if (loading) {
    return (
      <View style={styles.center}>
        <Text>Loading prayer times...</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <Text style={styles.title}>Prayer Times NYC</Text>
      <Text style={styles.subtitle}>Using ISNA method (Shafi madhab)</Text>
      
      {prayerTimes && (
        <View style={styles.timesContainer}>
          {Object.entries(prayerTimes).map(([prayer, time]) => (
            <View key={prayer} style={styles.timeRow}>
              <Text style={styles.prayerName}>
                {prayer.charAt(0).toUpperCase() + prayer.slice(1)}
              </Text>
              <Text style={styles.prayerTime}>
                {new Date(time).toLocaleTimeString()}
              </Text>
            </View>
          ))}
        </View>
      )}
      
      {qibla && (
        <View style={styles.qiblaContainer}>
          <Text style={styles.qiblaTitle}>Qibla Direction</Text>
          <Text style={styles.qiblaText}>
            {qibla.direction.toFixed(1)}° ({qibla.compassBearing})
          </Text>
          <Text style={styles.distance}>
            Distance: {qibla.distance.toFixed(0)} km
          </Text>
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#f5f5f5' },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  title: { fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 5 },
  subtitle: { fontSize: 14, textAlign: 'center', color: '#666', marginBottom: 20 },
  timesContainer: { backgroundColor: 'white', borderRadius: 10, padding: 15, marginBottom: 15 },
  timeRow: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#eee'
  },
  prayerName: { fontSize: 16, fontWeight: '500' },
  prayerTime: { fontSize: 16, color: '#007AFF' },
  qiblaContainer: { 
    backgroundColor: 'white', 
    borderRadius: 10, 
    padding: 15,
    alignItems: 'center'
  },
  qiblaTitle: { fontSize: 18, fontWeight: 'bold', marginBottom: 10 },
  qiblaText: { fontSize: 16, color: '#007AFF' },
  distance: { fontSize: 14, color: '#666', marginTop: 5 }
});
```

## 🌍 Advanced Features Examples

### Timezone Support
```tsx
// Using timezone identifiers
const makkahTimes = await getPrayerTimes({
  coordinates: { latitude: 21.4225, longitude: 39.8262 },
  parameters: { method: CalculationMethod.UmmAlQura },
  timezone: 'Asia/Riyadh'
});

// Using timezone offsets
const pakistanTimes = await getPrayerTimes({
  coordinates: { latitude: 33.6844, longitude: 73.0479 },
  parameters: { method: CalculationMethod.Karachi },
  timezone: '+05:00'
});
```

### Madhab Differences
```tsx
// Shafi madhab (earlier Asr)
const shafiTimes = await getPrayerTimes({
  coordinates: { latitude: 33.6844, longitude: 73.0479 },
  parameters: {
    method: CalculationMethod.Karachi,
    madhab: Madhab.Shafi
  }
});

// Hanafi madhab (later Asr)
const hanafiTimes = await getPrayerTimes({
  coordinates: { latitude: 33.6844, longitude: 73.0479 },
  parameters: {
    method: CalculationMethod.Karachi,
    madhab: Madhab.Hanafi
  }
});
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