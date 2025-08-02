//
//  CalculationMethod.swift
//  Adhan
//
//  Copyright © 2018 Batoul Apps. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
  Preset calculation parameters for different regions.

  *Descriptions of the different options*

  **muslimWorldLeague**

  Muslim World League. Standard Fajr time with an angle of 18°. Earlier Isha time with an angle of 17°.

  **egyptian**

  Egyptian General Authority of Survey. Early Fajr time using an angle 19.5° and a slightly earlier Isha time using an angle of 17.5°.

  **karachi**

  University of Islamic Sciences, Karachi. A generally applicable method that uses standard Fajr and Isha angles of 18°.

  **ummAlQura**

  Umm al-Qura University, Makkah. Uses a fixed interval of 90 minutes from maghrib to calculate Isha. And a slightly earlier Fajr time
  with an angle of 18.5°. Note: you should add a +30 minute custom adjustment for Isha during Ramadan.

  **dubai**

  Used in the UAE. Slightly earlier Fajr time and slightly later Isha time with angles of 18.2° for Fajr and Isha in addition to 3 minute
  offsets for sunrise, Dhuhr, Asr, and Maghrib.

  **moonsightingCommittee**

  Method developed by Khalid Shaukat, founder of Moonsighting Committee Worldwide. Uses standard 18° angles for Fajr and Isha in addition
  to seasonal adjustment values. This method automatically applies the 1/7 approximation rule for locations above 55° latitude.
  Recommended for North America and the UK.

  **northAmerica**

  Also known as the ISNA method. Can be used for North America, but the moonsightingCommittee method is preferable. Gives later Fajr times and early
  Isha times with angles of 15°.

  **kuwait**

  Standard Fajr time with an angle of 18°. Slightly earlier Isha time with an angle of 17.5°.

  **qatar**

  Same Isha interval as `ummAlQura` but with the standard Fajr time using an angle of 18°.

  **singapore**

  Used in Singapore, Malaysia, and Indonesia. Early Fajr time with an angle of 20° and standard Isha time with an angle of 18°.

  **tehran**

  Institute of Geophysics, University of Tehran. Early Isha time with an angle of 14°. Slightly later Fajr time with an angle of 17.7°.
  Calculates Maghrib based on the sun reaching an angle of 4.5° below the horizon.

  **turkey**

  An approximation of the Diyanet method used in Turkey. This approximation is less accurate outside the region of Turkey.

  **other**

  Defaults to angles of 0°, should generally be used for making a custom method and setting your own values.

*/
public enum CalculationMethod: String, Codable, CaseIterable {

    // Muslim World League
    case muslimWorldLeague

    // Egyptian General Authority of Survey
    case egyptian

    // University of Islamic Sciences, Karachi
    case karachi

    // Umm al-Qura University, Makkah
    case ummAlQura

    // UAE
    case dubai

    // Moonsighting Committee
    case moonsightingCommittee

    // ISNA
    case northAmerica

    // Kuwait
    case kuwait

    // Qatar
    case qatar

    // Singapore
    case singapore

    // Institute of Geophysics, University of Tehran
    case tehran

    // Dianet
    case turkey

    // Other
    case other

    public var params: (fajrAngle: Double, ishaAngle: Double, ishaInterval: Minute, maghribAngle: Double?, methodAdjustments: PrayerAdjustments, rounding: Rounding) {
        switch(self) {
        case .muslimWorldLeague:
            return (fajrAngle: 18, ishaAngle: 17, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 1), rounding: .nearest)
        case .egyptian:
            return (fajrAngle: 19.5, ishaAngle: 17.5, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 1), rounding: .nearest)
        case .karachi:
            return (fajrAngle: 18, ishaAngle: 18, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 1), rounding: .nearest)
        case .ummAlQura:
            return (fajrAngle: 18.5, ishaAngle: 0, ishaInterval: 90, maghribAngle: nil, methodAdjustments: PrayerAdjustments(), rounding: .nearest)
        case .dubai:
            return (fajrAngle: 18.2, ishaAngle: 18.2, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(sunrise: -3, dhuhr: 3, asr: 3, maghrib: 3), rounding: .nearest)
        case .moonsightingCommittee:
            return (fajrAngle: 18, ishaAngle: 18, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 5, maghrib: 3), rounding: .nearest)
        case .northAmerica:
            return (fajrAngle: 15, ishaAngle: 15, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 1), rounding: .nearest)
        case .kuwait:
            return (fajrAngle: 18, ishaAngle: 17.5, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(), rounding: .nearest)
        case .qatar:
            return (fajrAngle: 18, ishaAngle: 0, ishaInterval: 90, maghribAngle: nil, methodAdjustments: PrayerAdjustments(), rounding: .nearest)
        case .singapore:
            return (fajrAngle: 20, ishaAngle: 18, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(dhuhr: 1), rounding: .up)
        case .tehran:
            return (fajrAngle: 17.7, ishaAngle: 14, ishaInterval: 0, maghribAngle: 4.5, methodAdjustments: PrayerAdjustments(), rounding: .nearest)
        case .turkey:
            return (fajrAngle: 18, ishaAngle: 17, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(fajr: 0, sunrise: -7, dhuhr: 5, asr: 4, maghrib: 7, isha: 0), rounding: .nearest)
        case .other:
            return (fajrAngle: 0, ishaAngle: 0, ishaInterval: 0, maghribAngle: nil, methodAdjustments: PrayerAdjustments(), rounding: .nearest)
        }
    }
}
