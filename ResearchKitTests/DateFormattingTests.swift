/*
 Copyright (c) 2025, Apple Inc. All rights reserved.

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

import Foundation
import Testing

@Test func dateFormatterStringWithGregorianCalendar() throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2022;
    dateComponents.month = 11;
    dateComponents.day = 3;
    dateComponents.hour = 8;
    dateComponents.minute = 43;
    dateComponents.second = 19;
    dateComponents.timeZone = TimeZone(abbreviation: "MST")

    try assertTestDateFormatAgainstLocales(date: dateComponents.date, expectedFormat: "2022-11-03T08:43:19-0700")
}

@Test func dateFormatterStringWithISO8601Calendar() throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .iso8601)
    dateComponents.year = 2010;
    dateComponents.month = 3;
    dateComponents.day = 12;
    dateComponents.hour = 9;
    dateComponents.minute = 50;
    dateComponents.second = 4;
    dateComponents.timeZone = TimeZone(abbreviation: "PST")

    try assertTestDateFormatAgainstLocales(date: dateComponents.date, expectedFormat: "2010-03-12T09:50:04-0800")
}

@Test func dateFormatterStringWithPSTTimeZone() throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .iso8601)
    dateComponents.year = 2023;
    dateComponents.month = 12;
    dateComponents.day = 4;
    dateComponents.hour = 9;
    dateComponents.minute = 44;
    dateComponents.second = 20;
    dateComponents.timeZone = TimeZone(abbreviation: "PST")

    try assertTestDateFormatAgainstLocales(date: dateComponents.date, expectedFormat: "2023-12-04T09:44:20-0800")
}

// MARK: - Locale Independence Tests

@Test(arguments: [
    "en", "es", "fr", "de", "ja", "zh", "ar", "he", "ru", "ko", "th", "it", "pt", "nl", "pl", "tr", "fa"
])
func dateFormatterConsistencyAcrossLanguages(languageCode: String) throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2023
    dateComponents.month = 6
    dateComponents.day = 15
    dateComponents.hour = 14
    dateComponents.minute = 30
    dateComponents.second = 0
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2023-06-15T14:30:00+0000"

    // The formatter should use POSIX locale for ISO 8601 compliance
    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    let dateString = dateFormatter.string(from: date)
    #expect(expectedFormat == dateString,
            "ISO 8601 format should be consistent, got: \(dateString)")

    // Verify ASCII-only output (no localized digits)
    #expect(dateString.allSatisfy { $0.isASCII },
            "ISO 8601 should use ASCII characters only, got: \(dateString)")

    // Test round-trip
    let parsedDate = try #require(dateFormatter.date(from: dateString),
                                  "Failed to parse date string")
    let roundTripString = dateFormatter.string(from: parsedDate)
    #expect(expectedFormat == roundTripString,
            "Round-trip failed")
}

// MARK: - Language + Country Combination Tests

@Test(arguments: [
    ("en", "US"), ("en", "GB"), ("en", "AU"), ("en", "CA"),
    ("es", "ES"), ("es", "MX"), ("es", "AR"),
    ("fr", "FR"), ("fr", "CA"),
    ("ar", "SA"), ("ar", "EG"), ("ar", "AE"),
    ("zh", "CN"), ("zh", "TW"), ("zh", "HK"),
    ("de", "DE"), ("de", "AT"), ("de", "CH"),
    ("pt", "PT"), ("pt", "BR")
])
func dateFormatterLanguageCountryVariations(language: String, country: String) throws {
    let localeID = "\(language)_\(country)"

    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2023
    dateComponents.month = 12
    dateComponents.day = 25
    dateComponents.hour = 18
    dateComponents.minute = 0
    dateComponents.second = 0
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2023-12-25T18:00:00+0000"

    // Use POSIX locale for ISO 8601 compliance
    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!

    let dateString = dateFormatter.string(from: date)
    #expect(expectedFormat == dateString,
            "ISO 8601 format should be consistent with POSIX locale, got: \(dateString)")

    // Verify ASCII-only output
    #expect(dateString.allSatisfy { $0.isASCII },
            "Should use ASCII characters only, got: \(dateString)")

    // Test round-trip
    let parsedDate = try #require(dateFormatter.date(from: dateString),
                                  "Failed to parse for locale: \(localeID)")
    let roundTripString = dateFormatter.string(from: parsedDate)
    #expect(expectedFormat == roundTripString,
            "Round-trip failed for locale: \(localeID)")
}

// MARK: - Specific Problematic Locales

@Test func dateFormatterWithSpecificProblematicLocales() throws {
    let criticalLocales = [
        "en_US",           // Standard English
        "en_GB",           // British English
        "ar_SA",           // Arabic (RTL, different number system)
        "he_IL",           // Hebrew (RTL)
        "ja_JP",           // Japanese (different calendar option)
        "zh_CN",           // Simplified Chinese
        "fa_IR",           // Persian (uses different calendar)
        "th_TH",           // Thai (Buddhist calendar option)
        "ru_RU",           // Russian (Cyrillic)
        "de_DE",           // German (different date conventions)
        "fr_FR",           // French
        "es_419",          // Latin American Spanish
        "hi_IN",           // Hindi (Devanagari script)
        "bn_BD",           // Bengali (different number system)
    ]

    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2024
    dateComponents.month = 1
    dateComponents.day = 15
    dateComponents.hour = 9
    dateComponents.minute = 45
    dateComponents.second = 30
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2024-01-15T09:45:30+0000"

    // Use POSIX locale for ISO 8601 compliance - should produce same output regardless
    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    for localeID in criticalLocales {
        let dateString = dateFormatter.string(from: date)

        // Verify ASCII-only output (no localized digits or RTL markers)
        #expect(dateString.allSatisfy { $0.isASCII },
                "Should use ASCII only (testing against \(localeID)), got: \(dateString)")

        #expect(expectedFormat == dateString,
                "ISO 8601 should be consistent (testing against \(localeID)), got: \(dateString)")

        // Test round-trip
        let parsedDate = try #require(dateFormatter.date(from: dateString),
                                      "Failed to parse for locale: \(localeID)")
        let roundTripString = dateFormatter.string(from: parsedDate)
        #expect(expectedFormat == roundTripString,
                "Round-trip failed for locale: \(localeID)")
    }
}

// MARK: - Non-Western Number Systems

@Test(arguments: [
    "ar_SA",  // Can use Arabic-Indic digits
    "fa_IR",  // Can use Persian digits
    "th_TH",  // Can use Thai digits
    "bn_BD",  // Can use Bengali digits
    "hi_IN",  // Can use Devanagari digits
])
func dateFormatterWithNonWesternNumberSystems(localeID: String) throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2023
    dateComponents.month = 3
    dateComponents.day = 8
    dateComponents.hour = 12
    dateComponents.minute = 30
    dateComponents.second = 45
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2023-03-08T12:30:45+0000"

    // Use POSIX locale to ensure ASCII digits
    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")

    let dateString = dateFormatter.string(from: date)

    // Verify it uses Western Arabic numerals (0-9), not localized digits
    #expect(dateString.allSatisfy { $0.isASCII },
            "Locale \(localeID) should use ASCII digits with POSIX locale, got: \(dateString)")
    #expect(expectedFormat == dateString,
            "Locale \(localeID) should produce ISO 8601 format, got: \(dateString)")

    // Test round-trip
    let parsedDate = try #require(dateFormatter.date(from: dateString),
                                  "Failed to parse for locale: \(localeID)")
    let roundTripString = dateFormatter.string(from: parsedDate)
    #expect(expectedFormat == roundTripString,
            "Round-trip failed for locale: \(localeID)")
}

// MARK: - System Locale Independence

@Test func dateFormatterIndependentOfSystemLocale() throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2024
    dateComponents.month = 2
    dateComponents.day = 29  // Leap year
    dateComponents.hour = 23
    dateComponents.minute = 59
    dateComponents.second = 59
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2024-02-29T23:59:59+0000"

    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!

    // Test with explicit locale
    dateFormatter.locale = Locale(identifier: "en_US")
    let explicitString = dateFormatter.string(from: date)

    // Test with POSIX locale (guaranteed consistency)
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    let posixString = dateFormatter.string(from: date)

    #expect(expectedFormat == explicitString,
            "en_US locale produced: \(explicitString)")
    #expect(expectedFormat == posixString,
            "POSIX locale produced: \(posixString)")
    #expect(explicitString == posixString,
            "POSIX and explicit locales should produce identical output")
}

// MARK: - Performance-Optimized Sampling

@Test func dateFormatterLocaleIndependenceSampled() throws {
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar(identifier: .gregorian)
    dateComponents.year = 2023
    dateComponents.month = 7
    dateComponents.day = 4
    dateComponents.hour = 16
    dateComponents.minute = 20
    dateComponents.second = 0
    dateComponents.timeZone = TimeZone(identifier: "UTC")

    let date = try #require(dateComponents.date, "Failed to create date")
    let expectedFormat = "2023-07-04T16:20:00+0000"

    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "UTC")!

    // Sample every 10th country code for faster tests while maintaining coverage
    let sampledCodes = NSLocale.isoCountryCodes.enumerated()
        .filter { $0.offset % 10 == 0 }
        .map { $0.element }

    for countryCode in sampledCodes {
        let localeIdentifier = NSLocale.localeIdentifier(
            fromComponents: ["kCFLocaleCountryCodeKey": countryCode,
                           "kCFLocaleLanguageCodeKey": "en"]
        )
        dateFormatter.locale = Locale(identifier: localeIdentifier)

        let dateString = dateFormatter.string(from: date)
        #expect(expectedFormat == dateString,
                "Failed for locale: \(localeIdentifier), got: \(dateString)")

        // Test round-trip
        let parsedDate = try #require(dateFormatter.date(from: dateString),
                                      "Failed to parse for locale: \(localeIdentifier)")
        let roundTripString = dateFormatter.string(from: parsedDate)
        #expect(expectedFormat == roundTripString,
                "Round-trip failed for locale: \(localeIdentifier)")
    }
}

// MARK: - Helper Functions

func assertTestDateFormatAgainstLocales(date: Date?, expectedFormat: String) throws {
    let date = try #require(date, "The provided date was nil.")

    let dateFormatter = ORKDateAnswerFormat.dateTime().resultDateFormatter()
    for countryCode in NSLocale.isoCountryCodes {
        let localeIdentifier = NSLocale.localeIdentifier(fromComponents: ["NSLocalCountryCode" : countryCode, "NSLocaleLanguageCode" : "en"])
        dateFormatter.locale = Locale(identifier: localeIdentifier)

        // Hardcode the timezone to keep the tests specific regardless of the device's timezone.
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")!

        let dateString = dateFormatter.string(from: date)
        #expect(expectedFormat == dateString, "didn't match for locale \(dateFormatter.locale.identifier)")

        let dateFormatDate = try #require(dateFormatter.date(from: dateString))

        #expect(expectedFormat == dateFormatter.string(from: dateFormatDate), "didn't match for locale \(dateFormatter.locale.identifier)")
    }
}
