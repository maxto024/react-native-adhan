#!/usr/bin/env node

/**
 * Integration Test for react-native-adhan
 * Tests all features and type safety
 */

const {
  getPrayerTimes,
  getQiblaDirection,
  getBulkPrayerTimes,
  getAvailableMethods,
  validateCoordinates,
  validateDate,
  multiply,
  CalculationMethod,
  Madhab,
  AdhanErrorCode,
} = require('./lib/commonjs/index.js');

console.log('🕌 React Native Adhan - Integration Test\n');

// Test coordinates (Hopkins, MN)
const coordinates = {
  latitude: 44.924054,
  longitude: -93.41964,
};

async function runTests() {
  let passedTests = 0;
  let totalTests = 0;

  function test(name, testFn) {
    totalTests++;
    try {
      const result = testFn();
      if (result instanceof Promise) {
        return result.then(() => {
          console.log(`✅ ${name}`);
          passedTests++;
        }).catch(error => {
          console.log(`❌ ${name}: ${error.message}`);
        });
      } else {
        console.log(`✅ ${name}`);
        passedTests++;
      }
    } catch (error) {
      console.log(`❌ ${name}: ${error.message}`);
    }
  }

  // 1. Basic Module Test
  test('Module connectivity (multiply function)', () => {
    const result = multiply(3, 7);
    if (result !== 21) throw new Error(`Expected 21, got ${result}`);
  });

  // 2. Coordinate Validation
  test('Coordinate validation - valid coordinates', () => {
    const validation = validateCoordinates(coordinates);
    if (!validation.isValid) throw new Error(`Should be valid: ${validation.errors}`);
  });

  test('Coordinate validation - invalid coordinates', () => {
    const validation = validateCoordinates({ latitude: 100, longitude: 200 });
    if (validation.isValid) throw new Error('Should be invalid');
  });

  // 3. Date Validation
  test('Date validation - valid ISO string', () => {
    const validation = validateDate('2024-12-25');
    if (!validation.isValid) throw new Error(`Should be valid: ${validation.errors}`);
  });

  test('Date validation - valid date object', () => {
    const validation = validateDate({ year: 2024, month: 12, day: 25 });
    if (!validation.isValid) throw new Error(`Should be valid: ${validation.errors}`);
  });

  // 4. Prayer Times Tests
  await test('Prayer times - Default parameters (should use MWL)', async () => {
    const result = await getPrayerTimes({
      coordinates,
      // No parameters provided - should default to MWL method, Shafi madhab
    });
    
    if (!result.fajr || !result.isha) {
      throw new Error('Missing prayer times');
    }
    
    // Validate ISO format
    const fajrDate = new Date(result.fajr);
    if (isNaN(fajrDate.getTime())) {
      throw new Error('Invalid date format in result');
    }
  });

  await test('Prayer times - ISNA method', async () => {
    const result = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.ISNA,
        madhab: Madhab.Shafi,
        timezone: 'America/Chicago',
      },
    });
    
    if (!result.fajr || !result.isha) {
      throw new Error('Missing prayer times');
    }
    
    // Validate ISO format  
    const fajrDate = new Date(result.fajr);
    if (isNaN(fajrDate.getTime())) {
      throw new Error('Invalid date format in result');
    }
  });

  await test('Prayer times - Egyptian method with adjustments', async () => {
    const result = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.Egypt,
        madhab: Madhab.Hanafi,
        adjustments: {
          fajr: 2,
          isha: -1,
        },
      },
    });
    
    if (!result.fajr || !result.isha) {
      throw new Error('Missing prayer times');
    }
  });

  await test('Prayer times - Custom angles', async () => {
    const result = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.ISNA,
        fajrAngle: 15.5,
        ishaAngle: 15.5,
      },
    });
    
    if (!result.fajr || !result.isha) {
      throw new Error('Missing prayer times');
    }
  });

  await test('Prayer times - UmmAlQura method (interval)', async () => {
    const result = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.UmmAlQura,
      },
    });
    
    if (!result.fajr || !result.isha) {
      throw new Error('Missing prayer times');
    }
  });

  await test('Prayer times - Method adjustments (Dubai method)', async () => {
    const dubaiResult = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.Dubai, // Has built-in adjustments
      },
    });
    
    const mwlResult = await getPrayerTimes({
      coordinates,
      parameters: {
        method: CalculationMethod.MWL, // Different built-in adjustments
      },
    });
    
    // Dubai and MWL should have different times due to method adjustments
    if (dubaiResult.dhuhr === mwlResult.dhuhr) {
      throw new Error('Method adjustments not being applied - times should differ');
    }
    
    console.log(`   📊 Dubai dhuhr vs MWL dhuhr time difference verified`);
  });

  // 5. Qibla Direction Test
  await test('Qibla direction calculation', async () => {
    const result = await getQiblaDirection(coordinates);
    
    if (typeof result.direction !== 'number' || 
        typeof result.distance !== 'number' ||
        typeof result.compassBearing !== 'string') {
      throw new Error('Invalid qibla result structure');
    }
    
    if (result.direction < 0 || result.direction >= 360) {
      throw new Error('Direction should be 0-360 degrees');
    }
  });

  // 6. Bulk Prayer Times Test
  await test('Bulk prayer times calculation', async () => {
    const result = await getBulkPrayerTimes({
      coordinates,
      startDate: '2024-12-25',
      endDate: '2024-12-27',
      parameters: {
        method: CalculationMethod.MWL,
      },
    });
    
    if (!result.prayerTimes || result.prayerTimes.length !== 3) {
      throw new Error('Should return 3 days of prayer times');
    }
    
    if (result.totalDays !== 3) {
      throw new Error('Total days should be 3');
    }
    
    // Check each day has all prayer times
    result.prayerTimes.forEach((day, index) => {
      if (!day.fajr || !day.isha || !day.date) {
        throw new Error(`Day ${index + 1} missing required fields`);
      }
    });
  });

  // 7. Available Methods Test
  test('Get available methods', () => {
    const methods = getAvailableMethods();
    
    if (!Array.isArray(methods) || methods.length === 0) {
      throw new Error('Should return array of methods');
    }
    
    const method = methods[0];
    if (!method.method || !method.name || typeof method.fajrAngle !== 'number') {
      throw new Error('Invalid method structure');
    }
  });

  // 8. Error Handling Tests
  await test('Error handling - invalid coordinates', async () => {
    try {
      await getPrayerTimes({
        coordinates: { latitude: 100, longitude: 200 },
      });
      throw new Error('Should have thrown an error');
    } catch (error) {
      if (!error.code || error.code !== AdhanErrorCode.INVALID_COORDINATES) {
        throw new Error('Should throw INVALID_COORDINATES error');
      }
    }
  });

  await test('Error handling - invalid date', async () => {
    try {
      await getPrayerTimes({
        coordinates,
        date: 'invalid-date',
      });
      throw new Error('Should have thrown an error');
    } catch (error) {
      if (!error.code || error.code !== AdhanErrorCode.INVALID_DATE) {
        throw new Error('Should throw INVALID_DATE error');
      }
    }
  });

  // 9. Type Safety Tests
  test('Enum values are correct', () => {
    if (CalculationMethod.ISNA !== 'ISNA') {
      throw new Error('CalculationMethod.ISNA should equal "ISNA"');
    }
    
    if (Madhab.Shafi !== 'Shafi') {
      throw new Error('Madhab.Shafi should equal "Shafi"');
    }
    
    if (AdhanErrorCode.INVALID_COORDINATES !== 'INVALID_COORDINATES') {
      throw new Error('AdhanErrorCode values incorrect');
    }
  });

  // 10. Performance Test
  await test('Performance test - multiple calculations', async () => {
    const startTime = Date.now();
    
    const promises = [];
    for (let i = 0; i < 5; i++) {
      promises.push(getPrayerTimes({
        coordinates,
        parameters: { method: CalculationMethod.ISNA },
      }));
    }
    
    await Promise.all(promises);
    
    const endTime = Date.now();
    const duration = endTime - startTime;
    
    if (duration > 5000) { // 5 seconds should be plenty
      throw new Error(`Too slow: ${duration}ms for 5 calculations`);
    }
    
    console.log(`   ⏱️  5 calculations took ${duration}ms`);
  });

  // Summary
  console.log(`\n📊 Test Results: ${passedTests}/${totalTests} passed`);
  
  if (passedTests === totalTests) {
    console.log('🎉 All tests passed! The library is fully functional and type-safe.');
  } else {
    console.log('❌ Some tests failed. Please check the implementation.');
    process.exit(1);
  }
}

// Run all tests
runTests().catch(error => {
  console.error('💥 Test runner error:', error);
  process.exit(1);
});