import React, { useEffect, useState, useCallback } from 'react';
import {
  Text,
  View,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import {
  multiply,
  getPrayerTimes,
  getQiblaDirection,
  getAvailableMethods,
  validateCoordinates,
  CalculationMethod,
  Madhab,
  type PrayerTimesResult,
  type QiblaResult,
  type MethodInfo,
  type Coordinates,
} from 'react-native-adhan';

const multiplyResult = multiply(3, 7);

// Test coordinates: Hopkins, MN
const coordinates: Coordinates = {
  latitude: 44.924054,
  longitude: -93.41964,
};

export default function App() {
  const [prayerTimes, setPrayerTimes] = useState<PrayerTimesResult | null>(
    null
  );
  const [qiblaDirection, setQiblaDirection] = useState<QiblaResult | null>(
    null
  );
  const [methods, setMethods] = useState<MethodInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentMethod, setCurrentMethod] = useState<CalculationMethod>(
    CalculationMethod.ISNA
  );
  const [currentMadhab, setCurrentMadhab] = useState<Madhab>(Madhab.Shafi);
  const [error, setError] = useState<string | null>(null);

  const fetchAllData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      // Validate coordinates first
      const validation = validateCoordinates(coordinates);
      if (!validation.isValid) {
        throw new Error(`Invalid coordinates: ${validation.errors.join(', ')}`);
      }

      // Test prayer times with different parameters
      const times = await getPrayerTimes({
        coordinates,
        parameters: {
          method: currentMethod,
          madhab: currentMadhab,
          fajrAngle: 18,
          ishaAngle: 18,
          timezone: 'America/Chicago',
          adjustments: {
            fajr: 0,
            sunrise: 0,
            dhuhr: 0,
            asr: 0,
            maghrib: 0,
            isha: 0,
          },
        },
      });
      setPrayerTimes(times);

      // Test Qibla direction
      const qibla = await getQiblaDirection(coordinates);
      setQiblaDirection(qibla);

      // Get available methods
      const availableMethods = await getAvailableMethods();
      setMethods(availableMethods);
    } catch (err: any) {
      console.error('Error fetching data:', err);
      setError(err.message || 'Unknown error occurred');
    } finally {
      setLoading(false);
    }
  }, [currentMethod, currentMadhab]);

  useEffect(() => {
    fetchAllData();
  }, [fetchAllData]);

  const switchMethod = () => {
    const methodKeys = Object.values(CalculationMethod);
    const currentIndex = methodKeys.indexOf(currentMethod);
    const nextIndex = (currentIndex + 1) % methodKeys.length;
    const nextMethod = methodKeys[nextIndex];
    if (nextMethod) {
      setCurrentMethod(nextMethod);
    }
  };

  const switchMadhab = () => {
    setCurrentMadhab(currentMadhab === Madhab.Shafi ? Madhab.Hanafi : Madhab.Shafi);
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text style={styles.title}>React Native Adhan</Text>
      <Text style={styles.subtitle}>Full Type-Safe Integration Test</Text>

      {/* Module connectivity test */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Module Test</Text>
        <Text style={styles.testResult}>Multiply 3 × 7 = {multiplyResult}</Text>
      </View>

      {/* Method switcher */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Calculation Method</Text>
        <TouchableOpacity style={styles.button} onPress={switchMethod}>
          <Text style={styles.buttonText}>
            Current: {currentMethod} (Tap to change)
          </Text>
        </TouchableOpacity>
      </View>

      {/* Madhab switcher */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Madhab (Asr Calculation)</Text>
        <TouchableOpacity style={styles.button} onPress={switchMadhab}>
          <Text style={styles.buttonText}>
            Current: {currentMadhab} (Tap to change)
          </Text>
        </TouchableOpacity>
      </View>

      {/* Error display */}
      {error && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Error: {error}</Text>
        </View>
      )}

      {/* Loading state */}
      {loading ? (
        <Text style={styles.loading}>Loading data...</Text>
      ) : (
        <>
          {/* Prayer Times */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Prayer Times (Hopkins, MN)</Text>
            <Text style={styles.date}>Date: {new Date().toDateString()}</Text>

            {prayerTimes ? (
              <View style={styles.timesContainer}>
                {Object.entries(prayerTimes)
                  .filter(([key]) => !key.includes('metadata'))
                  .map(([prayer, time]) => (
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
              <Text style={styles.errorText}>Failed to load prayer times</Text>
            )}
          </View>

          {/* Qibla Direction */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Qibla Direction</Text>
            {qiblaDirection ? (
              <View style={styles.qiblaContainer}>
                <Text style={styles.qiblaText}>
                  Direction: {qiblaDirection.direction.toFixed(1)}°
                </Text>
                <Text style={styles.qiblaText}>
                  Bearing: {qiblaDirection.compassBearing}
                </Text>
                <Text style={styles.qiblaText}>
                  Distance: {qiblaDirection.distance.toFixed(0)} km
                </Text>
              </View>
            ) : (
              <Text style={styles.errorText}>
                Failed to load Qibla direction
              </Text>
            )}
          </View>

          {/* Available Methods */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>
              Available Methods ({methods.length})
            </Text>
            {methods.length > 0 ? (
              <View style={styles.methodsContainer}>
                {methods.slice(0, 3).map((method, index) => (
                  <View key={index} style={styles.methodRow}>
                    <Text style={styles.methodName}>{method.method}</Text>
                    <Text style={styles.methodAngles}>
                      Fajr: {method.fajrAngle}°, Isha: {method.ishaAngle}°
                    </Text>
                  </View>
                ))}
              </View>
            ) : (
              <Text style={styles.testResult}>Using fallback method data</Text>
            )}
          </View>

          {/* Validation Test */}
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Coordinate Validation</Text>
            <Text style={styles.testResult}>
              Hopkins coordinates: {coordinates.latitude.toFixed(6)},{' '}
              {coordinates.longitude.toFixed(6)} ✅
            </Text>
          </View>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 20,
    backgroundColor: '#f8f9fa',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#2c3e50',
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 20,
    color: '#7f8c8d',
    textAlign: 'center',
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
    color: '#2c3e50',
  },
  testResult: {
    fontSize: 14,
    color: '#27ae60',
    fontWeight: '500',
  },
  button: {
    backgroundColor: '#3498db',
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  errorContainer: {
    backgroundColor: '#ffe6e6',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
  },
  errorText: {
    color: '#e74c3c',
    fontSize: 14,
  },
  loading: {
    fontSize: 16,
    color: '#7f8c8d',
    textAlign: 'center',
    marginVertical: 20,
  },
  date: {
    fontSize: 14,
    color: '#7f8c8d',
    marginBottom: 12,
  },
  timesContainer: {
    gap: 8,
  },
  timeRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 14,
    backgroundColor: '#ecf0f1',
    borderRadius: 8,
  },
  prayerName: {
    fontSize: 15,
    fontWeight: '600',
    color: '#2c3e50',
  },
  prayerTime: {
    fontSize: 14,
    color: '#34495e',
    fontWeight: '500',
  },
  qiblaContainer: {
    gap: 6,
  },
  qiblaText: {
    fontSize: 14,
    color: '#2c3e50',
  },
  methodsContainer: {
    gap: 8,
  },
  methodRow: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    backgroundColor: '#f8f9fa',
    borderRadius: 6,
  },
  methodName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2c3e50',
  },
  methodAngles: {
    fontSize: 12,
    color: '#7f8c8d',
    marginTop: 2,
  },
});
