/**
 * Test script to verify the react-native-adhan TurboModule functionality
 */

import { getPrayerTimes } from 'react-native-adhan';

async function testPrayerTimes() {
  console.log('Testing react-native-adhan TurboModule...\n');

  try {
    // Test 1: Basic functionality with MuslimWorldLeague method
    console.log('=== Test 1: Minneapolis - MuslimWorldLeague method ===');
    const basicResult = await getPrayerTimes({
      latitude: 44.9778,
      longitude: -93.2650,
      date: { year: 2025, month: 8, day: 1 },
      method: 'MuslimWorldLeague'
    });
    console.log('Minneapolis, MN:', JSON.stringify(basicResult, null, 2));

    // Test 2: Different calculation method with Hanafi madhab  
    console.log('\n=== Test 2: Islamabad - MuslimWorldLeague with Hanafi madhab ===');
    const hanafiResult = await getPrayerTimes({
      latitude: 33.6844,
      longitude: 73.0479,
      date: { year: 2025, month: 8, day: 1 },
      method: 'MuslimWorldLeague',
      madhab: 'Hanafi'
    });
    console.log('Islamabad, Pakistan:', JSON.stringify(hanafiResult, null, 2));

    // Test 3: UmmAlQura method for Makkah
    console.log('\n=== Test 3: Makkah - UmmAlQura method ===');
    const makkahResult = await getPrayerTimes({
      latitude: 21.4225,
      longitude: 39.8262,
      date: { year: 2025, month: 8, day: 1 },
      method: 'UmmAlQura'
    });
    console.log('Makkah, Saudi Arabia:', JSON.stringify(makkahResult, null, 2));

    // Test 4: New York with North America method
    console.log('\n=== Test 4: New York - NorthAmerica method ===');
    const nyResult = await getPrayerTimes({
      latitude: 40.7128,
      longitude: -74.0060,
      date: { year: 2025, month: 8, day: 1 },
      method: 'NorthAmerica'
    });
    console.log('New York, NY:', JSON.stringify(nyResult, null, 2));

    console.log('\n✅ All tests completed successfully!');
    return true;
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    return false;
  }
}

export default testPrayerTimes;

// Run tests if this is the main module
if (require.main === module) {
  testPrayerTimes();
}