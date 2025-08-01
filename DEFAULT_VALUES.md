# 📋 Default Values & Built-in Adjustments

This document explains the exact default values used when parameters are not provided, matching the behavior of the official `adhan-swift` library.

## 🎯 **Default Parameter Values**

### **When no parameters are provided:**
```typescript
const prayerTimes = await getPrayerTimes({
  coordinates: { latitude: 40.7589, longitude: -73.9851 },
  // No parameters - these defaults will be used:
});
```

**Defaults applied:**
- **Method**: `CalculationMethod.MWL` (Muslim World League)
- **Madhab**: `Madhab.Shafi` (shadow length = 1.0)
- **Rounding**: `Rounding.Nearest`
- **High Latitude Rule**: `null` (no special rule)
- **User Adjustments**: All prayers = 0 minutes
- **Timezone**: System timezone

## 🏛️ **Built-in Method Adjustments**

Each calculation method has built-in adjustments that are **automatically applied** before any user adjustments. These match the official `adhan-swift` implementation exactly.

### **Muslim World League (MWL)** - *Default Method*
```
Angles: Fajr 18°, Isha 17°
Built-in adjustments: Dhuhr +1 minute
```

### **Egyptian General Authority**
```
Angles: Fajr 19.5°, Isha 17.5°
Built-in adjustments: Dhuhr +1 minute
```

### **University of Islamic Sciences, Karachi**
```
Angles: Fajr 18°, Isha 18°
Built-in adjustments: Dhuhr +1 minute
```

### **Islamic Society of North America (ISNA)**
```
Angles: Fajr 15°, Isha 15°
Built-in adjustments: Dhuhr +1 minute
```

### **Umm Al-Qura University, Makkah**
```
Angles: Fajr 18.5°, Isha 90 minutes after Maghrib
Built-in adjustments: None
```

### **Dubai (UAE)**
```
Angles: Fajr 18.2°, Isha 18.2°
Built-in adjustments:
  - Sunrise: -3 minutes
  - Dhuhr: +3 minutes  
  - Asr: +3 minutes
  - Maghrib: +3 minutes
```

### **Moonsighting Committee Worldwide**
```
Angles: Fajr 18°, Isha 18°
Built-in adjustments:
  - Dhuhr: +5 minutes
  - Maghrib: +3 minutes
```

### **Kuwait**
```
Angles: Fajr 18°, Isha 17.5°
Built-in adjustments: None
```

### **Qatar**
```
Angles: Fajr 18°, Isha 90 minutes after Maghrib
Built-in adjustments: None
```

### **Singapore**
```
Angles: Fajr 20°, Isha 18°
Built-in adjustments: Dhuhr +1 minute
Special: Uses rounding = up (always round up to next minute)
```

### **Institute of Geophysics, University of Tehran**
```
Angles: Fajr 17.7°, Isha 14°, Maghrib 4.5°
Built-in adjustments: None
```

### **Turkey (Diyanet approximation)**
```
Angles: Fajr 18°, Isha 17°
Built-in adjustments:
  - Fajr: +0 minutes
  - Sunrise: -7 minutes
  - Dhuhr: +5 minutes
  - Asr: +4 minutes
  - Maghrib: +7 minutes
  - Isha: +0 minutes
```

## 🔧 **How Adjustments Are Applied**

The final prayer time calculation follows this order:

1. **Base astronomical calculation** (using angles and intervals)
2. **Built-in method adjustments** (automatic, based on calculation method)
3. **User adjustments** (custom overrides via `adjustments` parameter)

```typescript
Final Time = Base Time + Method Adjustment + User Adjustment
```

### **Example: Dubai Method with User Adjustments**
```typescript
const result = await getPrayerTimes({
  coordinates: { latitude: 25.2048, longitude: 55.2708 },
  parameters: {
    method: CalculationMethod.Dubai,
    adjustments: {
      dhuhr: 2, // User wants +2 more minutes
    },
  },
});

// For Dhuhr prayer:
// 1. Base calculation: 12:05:30
// 2. Dubai method adjustment: +3 minutes = 12:08:30
// 3. User adjustment: +2 minutes = 12:10:30
// Final Dhuhr time: 12:10:30
```

## 📚 **Programming Examples**

### **Using Defaults (Recommended)**
```typescript
// Uses MWL method, Shafi madhab, nearest rounding
const times = await getPrayerTimes({
  coordinates: { latitude: 40.7589, longitude: -73.9851 },
});
```

### **Explicit Method Selection**
```typescript
// Explicitly choose ISNA method
const times = await getPrayerTimes({
  coordinates: { latitude: 40.7589, longitude: -73.9851 },
  parameters: {
    method: CalculationMethod.ISNA, // 15° angles + dhuhr +1min
  },
});
```

### **Custom Adjustments on Top of Method Adjustments**
```typescript
// Dubai method (built-in adjustments) + custom user adjustments
const times = await getPrayerTimes({
  coordinates: { latitude: 25.2048, longitude: 55.2708 },
  parameters: {
    method: CalculationMethod.Dubai, // Automatic: sunrise -3, dhuhr +3, asr +3, maghrib +3
    adjustments: {
      fajr: 5,    // User adds +5 minutes to fajr
      isha: -2,   // User subtracts 2 minutes from isha
    },
  },
});
```

### **Override Method Defaults**
```typescript
// Start with Dubai method but override the angles
const times = await getPrayerTimes({
  coordinates: { latitude: 25.2048, longitude: 55.2708 },
  parameters: {
    method: CalculationMethod.Dubai,    // Still gets Dubai's built-in adjustments
    fajrAngle: 18.5,                   // Override Dubai's 18.2° fajr angle
    ishaAngle: 18.5,                   // Override Dubai's 18.2° isha angle
  },
});
```

## ✅ **Best Practices**

1. **Use defaults when possible** - They follow established Islamic calculation standards
2. **Choose method based on location** - Each method is optimized for specific regions
3. **Test adjustments carefully** - Remember that method adjustments are already included
4. **Validate coordinates** - Always check that your coordinates are valid before calculation
5. **Handle timezones properly** - Specify timezone for accurate local times

## 🔍 **Verification**

You can verify these defaults are working correctly by:

1. **Running the integration tests**: `node test-integration.js`
2. **Comparing with adhan-swift** results for the same coordinates and date
3. **Checking that method adjustments are automatically applied**

These defaults ensure compatibility with the established `adhan-swift` library while providing the flexibility to customize when needed.