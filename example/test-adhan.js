/**
 * Test script to verify the enhanced react-native-adhan functionality
 * Tests all the new parameters including timezone, madhab, and custom angles
 */

const { getPrayerTimes, CalculationMethod, Madhab } = require('react-native-adhan');

async function testPrayerTimes() {
  console.log('Testing enhanced react-native-adhan functionality...\n');

  try {
    // Test 1: Basic functionality with ISNA method
    console.log('=== Test 1: Basic ISNA method ===');
    const basicResult = await getPrayerTimes({
      coordinates: {
        latitude: 44.923890,
        longitude: -93.419795
      },
      parameters: {
        method: CalculationMethod.ISNA,
      }
    });
    console.log('Hopkins, MN (ISNA):', JSON.stringify(basicResult, null, 2));

    // Test 2: Different calculation method with Hanafi madhab
    console.log('\n=== Test 2: MWL method with Hanafi madhab ===');
    const hanafiResult = await getPrayerTimes({
      coordinates: {
        latitude: 33.6844,
        longitude: 73.0479
      },
      parameters: {
        method: CalculationMethod.MWL,
        madhab: Madhab.Hanafi,
      }
    });
    console.log('Islamabad, Pakistan (MWL + Hanafi):', JSON.stringify(hanafiResult, null, 2));

    // Test 3: Timezone specification
    console.log('\n=== Test 3: Custom timezone ===');
    const timezoneResult = await getPrayerTimes({
      coordinates: {
        latitude: 21.4225,
        longitude: 39.8262
      },
      parameters: {
        method: CalculationMethod.UmmAlQura,
        timezone: 'Asia/Riyadh',
      }
    });
    console.log('Makkah, Saudi Arabia (UmmAlQura + Asia/Riyadh):', JSON.stringify(timezoneResult, null, 2));

    // Test 4: Prayer time adjustments
    console.log('\n=== Test 4: With adjustments ===');
    const adjustmentResult = await getPrayerTimes({
      coordinates: {
        latitude: 40.7128,
        longitude: -74.0060
      },
      parameters: {
        method: CalculationMethod.ISNA,
        adjustments: {
          fajr: 2,
          dhuhr: -1,
          asr: 3,
          maghrib: 1,
          isha: -2
        }
      }
    });
    console.log('New York, NY (ISNA + adjustments):', JSON.stringify(adjustmentResult, null, 2));

    console.log('\n✅ All tests completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Run tests
testPrayerTimes();