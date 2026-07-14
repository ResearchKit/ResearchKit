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

import Testing

@testable import ResearchKit

@Suite("TimeZone Tests")
struct TimeZoneTests {
    @Test(
        """
        For ISO8601-formatted date strings with a negative offset, no offset, and a positive offset from UTC, the initializer yields the expected result
        """,
        arguments: [
            ("1987-03-06T07:30:00-0400", -4 * 3600),
            ("1987-03-06T07:30:00-0000", 0),
            ("1987-03-06T07:30:00+0400", 4 * 3600),
        ]
    )
    func initializerReturnsExpectedValue(
        for validInput: (iso8601DateString: String, expectedSecondsFromGMT: Int)
    ) {
        #expect(
            TimeZone(
                iso8601String: validInput.iso8601DateString
            ) == TimeZone(
                secondsFromGMT: validInput.expectedSecondsFromGMT
            )
        )
    }
    
    @Test(
        "For a non ISO8601 formatted date string, the initializer returns nil.",
        arguments: [
            "2020-09-07 20:26:03.623359300+02:00", // RFC3339
            "123456789"
        ]
    )
    func initializerReturnsExpectedNilValue(for invalidISO8601DateString: String) {
        #expect(TimeZone(iso8601String: invalidISO8601DateString) == nil)
    }
}
