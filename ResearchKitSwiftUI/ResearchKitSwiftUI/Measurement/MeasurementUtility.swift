/*
 Copyright (c) 2024, Apple Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import SwiftUI
import math_h

func convertCentimetersToFeetAndInches(_ centimeters: Double) -> (
    feet: Int, inches: Int
) {
    var feet = 0
    var inches = 0
    let centimetersToInches = centimeters * 0.393701
    inches = Int(centimetersToInches)
    feet = inches / 12
    inches = inches % 12
    return (feet, inches)
}

func convertKilogramsToPoundsAndOunces(_ kilograms: Double) -> (
    pounds: Double, ounces: Double
) {
    let poundPerKilogram = 2.20462262
    let fractionalPounds = kilograms * poundPerKilogram
    var pounds = floor(fractionalPounds)
    var ounces = round((fractionalPounds - pounds) * 16)
    if ounces == 16 {
        pounds += 1
        ounces = 0
    }
    return (pounds, ounces)
}

func convertPoundsAndOuncesToKilograms(pounds: Double, ounces: Double) -> Double
{
    let kilogramsPerPound = 0.45359237
    let kg = (pounds + (ounces / 16)) * kilogramsPerPound
    return round(kg * 100) / 100
}

func convertKilogramsToWholeAndFraction(_ kilograms: Double) -> (
    whole: Double, fraction: Double
) {
    let whole = floor(kilograms)
    let fraction = round((kilograms - floor(kilograms)) * 100)
    return (whole, fraction)
}

extension Binding {
    func unwrapped<T>(defaultValue: T) -> Binding<T> where Value == T? {
        Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 })
    }
}
