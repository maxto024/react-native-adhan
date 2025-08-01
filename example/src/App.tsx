import React, { useEffect, useState } from 'react';
import { Text, View, StyleSheet, ScrollView } from 'react-native';
import { multiply, getPrayerTimes, CalculationMethod, type PrayerTimesResult } from 'react-native-adhan';

const multiplyResult = multiply(3, 7);

export default function App() {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTimesResult | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchPrayerTimes = async () => {
      try {
        // Example: Hopkins, MN coordinates
        const times = await getPrayerTimes({
          coordinates: {
            latitude: 44.923890,
            longitude: -93.419795
          },
          parameters: {
            method: CalculationMethod.ISNA
            
          }
        });
        setPrayerTimes(times);
      } catch (error) {
        console.error('Error fetching prayer times:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchPrayerTimes();
  }, []);

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>React Native Adhan</Text>
      
      <Text style={styles.subtitle}>Multiply Test: {multiplyResult}</Text>
      
      <Text style={styles.subtitle}>Prayer Times (Hopkins)</Text>
      <Text style={styles.date}>Date: {new Date().toDateString()}</Text>
      
      {loading ? (
        <Text>Loading prayer times...</Text>
      ) : prayerTimes ? (
        <View style={styles.timesContainer}>
          {Object.entries(prayerTimes).map(([prayer, time]) => (
            <View key={prayer} style={styles.timeRow}>
              <Text style={styles.prayerName}>{prayer.charAt(0).toUpperCase() + prayer.slice(1)}</Text>
              <Text style={styles.prayerTime}>{new Date(time).toLocaleTimeString()}</Text>
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
});
