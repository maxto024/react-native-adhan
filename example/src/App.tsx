import React, { useEffect, useState } from 'react';
import { Text, View, StyleSheet, ScrollView, NativeModules } from 'react-native';
import type { GetPrayerTimesOutput } from 'react-native-adhan';

export default function App() {
  const [prayerTimes, setPrayerTimes] = useState<GetPrayerTimesOutput | null>(
    null
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [moduleInfo, setModuleInfo] = useState<string>('');

  useEffect(() => {
    console.log('Available native modules:', Object.keys(NativeModules));
    setModuleInfo(`Available modules: ${Object.keys(NativeModules).length}`);

    const fetchPrayerTimes = async () => {
      try {
        console.log('Checking for NativeAdhanModule...');
        const AdhanModule = NativeModules.NativeAdhanModule;
        
        if (!AdhanModule) {
          throw new Error('NativeAdhanModule is not available in NativeModules');
        }
        
        console.log('Found AdhanModule:', AdhanModule);
        console.log('Module methods:', Object.keys(AdhanModule));
        
        const date = new Date();
        const times = await AdhanModule.getPrayerTimes({
          latitude: 44.96,
          longitude: -93.42,
          date: {
            year: date.getFullYear(),
            month: date.getMonth() + 1,
            day: date.getDate(),
          },
          method: 'MuslimWorldLeague',
          madhab: 'Shafi',
        });
        
        console.log('Received prayer times:', times);
        setPrayerTimes(times);
      } catch (error) {
        console.error('Error fetching prayer times:', error);
        setError(error instanceof Error ? error.message : String(error));
      } finally {
        setLoading(false);
      }
    };

    fetchPrayerTimes();
  }, []);

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>React Native Adhan</Text>

      <Text style={styles.subtitle}>Prayer Times (Hopkins)</Text>
      <Text style={styles.date}>Date: {new Date().toDateString()}</Text>

      <Text style={styles.subtitle}>{moduleInfo}</Text>
      
      {loading ? (
        <Text>Loading prayer times...</Text>
      ) : error ? (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Error: {error}</Text>
        </View>
      ) : prayerTimes ? (
        <View style={styles.timesContainer}>
          {Object.entries(prayerTimes).map(([prayer, time]) => (
            <View key={prayer} style={styles.timeRow}>
              <Text style={styles.prayerName}>
                {prayer.charAt(0).toUpperCase() + prayer.slice(1)}
              </Text>
              <Text style={styles.prayerTime}>
                {new Date(time as string).toLocaleTimeString()}
              </Text>
            </View>
          ))}
        </View>
      ) : (
        <Text>Failed to load prayer times</Text>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#333',
  },
  subtitle: {
    fontSize: 18,
    fontWeight: '600',
    marginVertical: 10,
    color: '#555',
  },
  date: {
    fontSize: 16,
    color: '#666',
    marginBottom: 20,
  },
  timesContainer: {
    width: '100%',
    maxWidth: 300,
  },
  timeRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    paddingHorizontal: 16,
    marginVertical: 2,
    backgroundColor: '#f5f5f5',
    borderRadius: 8,
  },
  prayerName: {
    fontSize: 16,
    fontWeight: '500',
    color: '#333',
  },
  prayerTime: {
    fontSize: 16,
    color: '#666',
  },
  errorContainer: {
    padding: 16,
    backgroundColor: '#ffebee',
    borderRadius: 8,
    marginVertical: 10,
  },
  errorText: {
    color: '#c62828',
    fontSize: 14,
  },
});
