import React, { useState, useEffect } from 'react';
import {
  Text,
  View,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
  SafeAreaView,
  ActivityIndicator,
} from 'react-native';
import {
  calculatePrayerTimes,
  calculateQibla,
  calculateSunnahTimes,
  getCurrentPrayer,
  getCalculationMethods,
  getMethodParameters,
  validateCoordinates,
  dateComponentsFromDate,
  prayerTimesToDates,
  CalculationMethod,
  Madhab,
  type AdhanCoordinates,
  type AdhanPrayerTimes,
  type AdhanQibla,
  type AdhanSunnahTimes,
  type AdhanCurrentPrayerInfo,
  type AdhanCalculationMethodInfo,
} from 'react-native-adhan';

const DEFAULT_COORDINATES: AdhanCoordinates = {
  latitude: 21.4225241, // Makkah
  longitude: 39.8261818,
};

export default function App() {
  const [coordinates, setCoordinates] =
    useState<AdhanCoordinates>(DEFAULT_COORDINATES);
  const [method, setMethod] = useState<string>(
    CalculationMethod.MUSLIM_WORLD_LEAGUE
  );
  const [madhab, setMadhab] = useState<string>(Madhab.SHAFI);
  const [prayerTimes, setPrayerTimes] = useState<AdhanPrayerTimes | null>(null);
  const [qibla, setQibla] = useState<AdhanQibla | null>(null);
  const [sunnahTimes, setSunnahTimes] = useState<AdhanSunnahTimes | null>(null);
  const [currentPrayer, setCurrentPrayer] =
    useState<AdhanCurrentPrayerInfo | null>(null);
  const [availableMethods, setAvailableMethods] = useState<
    AdhanCalculationMethodInfo[]
  >([]);
  const [loading, setLoading] = useState(false);

  // Load available calculation methods on mount
  useEffect(() => {
    const methods = getCalculationMethods();
    setAvailableMethods(methods);
  }, []);

  // Calculate all prayer data when coordinates or method changes
  useEffect(() => {
    if (validateCoordinates(coordinates)) {
      calculateAllData();
    }
  }, [coordinates, method, madhab]);

  const calculateAllData = async () => {
    setLoading(true);
    try {
      const today = dateComponentsFromDate(new Date());
      const calculationParams = {
        method,
        madhab,
      };

      // Calculate prayer times
      const times = await calculatePrayerTimes(
        coordinates,
        today,
        calculationParams
      );
      setPrayerTimes(times);

      // Calculate Qibla direction
      const qiblaDirection = await calculateQibla(coordinates);
      setQibla(qiblaDirection);

      // Calculate Sunnah times
      const sunnah = await calculateSunnahTimes(
        coordinates,
        today,
        calculationParams
      );
      setSunnahTimes(sunnah);

      // Get current prayer
      const current = await getCurrentPrayer(
        coordinates,
        today,
        calculationParams
      );
      setCurrentPrayer(current);
    } catch (error) {
      Alert.alert('Error', `Failed to calculate prayer times: ${error}`);
    } finally {
      setLoading(false);
    }
  };

  const formatTime = (timestamp: number): string => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const handleCoordinateChange = (
    field: 'latitude' | 'longitude',
    value: string
  ) => {
    const numValue = parseFloat(value) || 0;
    setCoordinates((prev) => ({ ...prev, [field]: numValue }));
  };

  const useCurrentLocation = () => {
    // In a real app, you would use geolocation here
    // For demo purposes, we'll use New York coordinates
    setCoordinates({ latitude: 40.7128, longitude: -74.006 });
  };

  const cycleCalculationMethod = () => {
    const currentIndex = availableMethods.findIndex(m => m.name === method);
    const nextIndex = (currentIndex + 1) % availableMethods.length;
    setMethod(availableMethods[nextIndex].name);
  };

  const cycleMadhab = () => {
    setMadhab(madhab === Madhab.SHAFI ? Madhab.HANAFI : Madhab.SHAFI);
  };

  const getCurrentMethodDisplayName = () => {
    return availableMethods.find(m => m.name === method)?.displayName || 'Unknown';
  };

  const getMadhabDisplayName = () => {
    return madhab === Madhab.HANAFI ? 'Hanafi' : 'Shafi/Maliki/Hanbali';
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}
      >
        <Text style={styles.title}>Adhan Prayer Times</Text>

        {/* Location Input */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Location</Text>
          <View style={styles.row}>
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Latitude:</Text>
              <TextInput
                style={styles.input}
                value={coordinates.latitude.toString()}
                onChangeText={(value) =>
                  handleCoordinateChange('latitude', value)
                }
                keyboardType="numeric"
                placeholder="Latitude"
              />
            </View>
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Longitude:</Text>
              <TextInput
                style={styles.input}
                value={coordinates.longitude.toString()}
                onChangeText={(value) =>
                  handleCoordinateChange('longitude', value)
                }
                keyboardType="numeric"
                placeholder="Longitude"
              />
            </View>
          </View>
          <TouchableOpacity style={styles.button} onPress={useCurrentLocation}>
            <Text style={styles.buttonText}>Use New York</Text>
          </TouchableOpacity>
        </View>

        {/* Calculation Method */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Calculation Method</Text>
          <TouchableOpacity style={styles.selectionButton} onPress={cycleCalculationMethod}>
            <View style={styles.selectionContent}>
              <Text style={styles.selectionLabel}>Current Method:</Text>
              <Text style={styles.selectionValue}>{getCurrentMethodDisplayName()}</Text>
              <Text style={styles.tapToChange}>Tap to change</Text>
            </View>
            <Text style={styles.selectionArrow}>→</Text>
          </TouchableOpacity>
        </View>

        {/* Madhab */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Madhab (Asr Calculation)</Text>
          <TouchableOpacity style={styles.selectionButton} onPress={cycleMadhab}>
            <View style={styles.selectionContent}>
              <Text style={styles.selectionLabel}>Current Madhab:</Text>
              <Text style={styles.selectionValue}>{getMadhabDisplayName()}</Text>
              <Text style={styles.tapToChange}>Tap to change</Text>
            </View>
            <Text style={styles.selectionArrow}>→</Text>
          </TouchableOpacity>
        </View>

        {loading && (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#007AFF" />
            <Text style={styles.loadingText}>Calculating...</Text>
          </View>
        )}

        {/* Current Prayer */}
        {currentPrayer && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Current Prayer</Text>
            <Text style={styles.currentPrayer}>
              Current:{' '}
              {currentPrayer.current.charAt(0).toUpperCase() +
                currentPrayer.current.slice(1)}
            </Text>
            <Text style={styles.nextPrayer}>
              Next:{' '}
              {currentPrayer.next.charAt(0).toUpperCase() +
                currentPrayer.next.slice(1)}
            </Text>
          </View>
        )}

        {/* Prayer Times */}
        {prayerTimes && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Prayer Times</Text>
            <View style={styles.prayerGrid}>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Fajr</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.fajr)}
                </Text>
              </View>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Sunrise</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.sunrise)}
                </Text>
              </View>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Dhuhr</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.dhuhr)}
                </Text>
              </View>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Asr</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.asr)}
                </Text>
              </View>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Maghrib</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.maghrib)}
                </Text>
              </View>
              <View style={styles.prayerItem}>
                <Text style={styles.prayerName}>Isha</Text>
                <Text style={styles.prayerTime}>
                  {formatTime(prayerTimes.isha)}
                </Text>
              </View>
            </View>
          </View>
        )}

        {/* Qibla Direction */}
        {qibla && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Qibla Direction</Text>
            <Text style={styles.qiblaDirection}>
              {qibla.direction.toFixed(1)}° from North
            </Text>
          </View>
        )}

        {/* Sunnah Times */}
        {sunnahTimes && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Sunnah Times</Text>
            <View style={styles.sunnahGrid}>
              <View style={styles.sunnahItem}>
                <Text style={styles.sunnahName}>Middle of Night</Text>
                <Text style={styles.sunnahTime}>
                  {formatTime(sunnahTimes.middleOfTheNight)}
                </Text>
              </View>
              <View style={styles.sunnahItem}>
                <Text style={styles.sunnahName}>Last Third of Night</Text>
                <Text style={styles.sunnahTime}>
                  {formatTime(sunnahTimes.lastThirdOfTheNight)}
                </Text>
              </View>
            </View>
          </View>
        )}

        {/* Method Description */}
        {availableMethods.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Method Description</Text>
            <Text style={styles.methodDescription}>
              {availableMethods.find((m) => m.name === method)?.description}
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    padding: 16,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 24,
    color: '#333',
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
    fontWeight: 'bold',
    marginBottom: 12,
    color: '#333',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  inputContainer: {
    flex: 1,
    marginHorizontal: 4,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 4,
    color: '#666',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
    marginTop: 12,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  selectionButton: {
    backgroundColor: '#f8f9fa',
    borderRadius: 12,
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    borderWidth: 1,
    borderColor: '#e9ecef',
  },
  selectionContent: {
    flex: 1,
  },
  selectionLabel: {
    fontSize: 12,
    color: '#666',
    marginBottom: 4,
    fontWeight: '500',
  },
  selectionValue: {
    fontSize: 16,
    color: '#333',
    fontWeight: '600',
    marginBottom: 2,
  },
  tapToChange: {
    fontSize: 11,
    color: '#007AFF',
    fontStyle: 'italic',
  },
  selectionArrow: {
    fontSize: 18,
    color: '#007AFF',
    fontWeight: 'bold',
    marginLeft: 12,
  },
  loadingContainer: {
    alignItems: 'center',
    padding: 20,
  },
  loadingText: {
    marginTop: 8,
    fontSize: 16,
    color: '#666',
  },
  currentPrayer: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#007AFF',
    marginBottom: 4,
  },
  nextPrayer: {
    fontSize: 16,
    color: '#666',
  },
  prayerGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  prayerItem: {
    width: '48%',
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    alignItems: 'center',
  },
  prayerName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
    marginBottom: 4,
  },
  prayerTime: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  qiblaDirection: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#007AFF',
  },
  sunnahGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  sunnahItem: {
    flex: 1,
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    padding: 12,
    marginHorizontal: 4,
    alignItems: 'center',
  },
  sunnahName: {
    fontSize: 12,
    fontWeight: '600',
    color: '#666',
    marginBottom: 4,
    textAlign: 'center',
  },
  sunnahTime: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  methodDescription: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
});
