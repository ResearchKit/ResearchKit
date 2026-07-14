/*
 Copyright (c) 2026, Apple Inc. All rights reserved.

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

import Testing

@Suite("Email Answer Format Validation")
struct ORKEmailAnswerFormatValidationTests {

    private let format = ORKEmailAnswerFormat.emailAnswerFormat()

    // MARK: - Non-ASCII local part

    @Test("Valid email with non-ASCII local part", arguments: [
        "用户@example.com",               // Chinese
        "مستخدم@example.com",            // Arabic
        "ユーザー@example.com",           // Japanese
        "пользователь@example.com",      // Russian (Cyrillic)
        "उपयोगकर्ता@example.com",        // Hindi (Devanagari)
        "משתמש@example.com",             // Hebrew
        "사용자@example.com",             // Korean
        "ผู้ใช้@example.com",            // Thai
        "χρήστης@example.com",           // Greek
        "ব্যবহারকারী@example.com",       // Bengali
    ])
    func validNonASCIILocalPart(_ email: String) {
        #expect(format.isAnswerValid(with: email))
    }

    // MARK: - Internationalized domain name (IDN)

    @Test("Valid email with internationalized domain name", arguments: [
        "user@münchen.de",               // German
        "user@例子.com",                  // Chinese
        "user@مثال.com",                 // Arabic
        "user@пример.com",               // Russian (Cyrillic)
        "user@उदाहरण.com",               // Hindi (Devanagari)
        "user@דוגמה.com",                // Hebrew
        "user@예시.com",                  // Korean
        "user@ตัวอย่าง.com",             // Thai
        "user@παράδειγμα.com",           // Greek
        "user@উদাহরণ.com",               // Bengali
    ])
    func validIDNDomain(_ email: String) {
        #expect(format.isAnswerValid(with: email))
    }

    // MARK: - Non-ASCII TLD

    @Test("Valid email with non-ASCII TLD", arguments: [
        "user@example.测试",               // Chinese
        "user@example.テスト",             // Japanese
        "user@example.한국",               // Korean
        "user@example.ру",               // Russian (Cyrillic)
        "user@example.परीक्षा",            // Hindi (Devanagari, contains combining marks)
        "user@example.ಭಾರತ",              // Kannada (India)
        "user@münchen.测试",              // non-ASCII domain + non-ASCII TLD
        "用户@例子.中国",                   // non-ASCII local part, domain, and TLD
    ])
    func validNonASCIITLD(_ email: String) {
        #expect(format.isAnswerValid(with: email))
    }

    // MARK: - Long TLD (> 6 chars)

    @Test("Valid email with TLD longer than 6 characters", arguments: [
        "user@example.photography",    // 11 chars
        "user@example.international",  // 13 chars
        "user@example.construction",   // 12 chars
    ])
    func validLongTLD(_ email: String) {
        #expect(format.isAnswerValid(with: email))
    }

    // MARK: - Valid ASCII (migrated from ORKAnswerFormatTests.m)

    @Test("Valid ASCII email addresses", arguments: [
        "someone@researchkit.org",
        "some.one@researchkit.org",
        "someone@researchkit.org.uk",
        "some_one@researchkit.org",
        "some-one@researchkit.org",
        "someone1@researchkit.org",
        "Someone1@ResearchKit.org",
    ])
    func validASCIIEmails(_ email: String) {
        #expect(format.isAnswerValid(with: email))
    }

    // MARK: - Invalid (migrated from ORKAnswerFormatTests.m)

    @Test("Invalid email addresses", arguments: [
        "emailtest",             // no @ or domain
        "emailtest@",            // empty domain
        "emailtest@.org",        // missing domain label
        "emailtest@researchkit", // domain with no TLD
        "12345",                 // no @ at all
        "",                      // empty string
    ])
    func invalidEmails(_ email: String) {
        #expect(!format.isAnswerValid(with: email))
    }

    // MARK: - Invalid: malformed domain structure

    @Test("Invalid email addresses with malformed domain", arguments: [
        "user@..com",                    // consecutive dots
        "user@example-.com",             // trailing hyphen in domain label
        "user@-example.com",             // leading hyphen in domain label
        "user@example.\u{0300}com",      // TLD starts with bare combining mark
    ])
    func invalidMalformedDomain(_ email: String) {
        #expect(!format.isAnswerValid(with: email))
    }

    // MARK: - Invalid: malformed local part

    @Test("Invalid email addresses with malformed local part", arguments: [
        "\u{0300}@example.com",      // bare combining mark as entire local part
        "\u{0300}user@example.com",  // combining mark before base character
    ])
    func invalidMalformedLocalPart(_ email: String) {
        #expect(!format.isAnswerValid(with: email))
    }
}
