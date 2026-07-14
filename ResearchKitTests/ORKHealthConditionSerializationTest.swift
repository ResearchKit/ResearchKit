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

import ResearchKit
import Testing

@Suite(.tags(.serialization))
struct ORKHealthConditionSerializationTests {
    @Test
    func testORKHealthCondition() throws {
        let instance = ORKHealthCondition(
            identifier: "id",
            displayName: "health condition",
            value: 5 as NSNumber
        )
        
        let expectation = """
        {
          "_class" : "ORKHealthCondition",
          "displayName" : "health condition",
          "identifier" : "id",
          "value" : 5
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}

import XCTest

class ORKHealthConditionSerializationTest: XCTestCase {
    /// - Important: This test must keep using XCTest until exit tests become available in Swift Testing for iOS.
    ///
    /// The behavior of `NSKeyedUnarchiver` differs across iOS versions.
    /// - On older iOS, decoding NSDictionary throws a catchable Swift error or returns nil -- both of which can be
    /// handled by Swift Testing.
    /// - On iOS 19+, the secure-coding violation aborts the process instead of throwing.
    /// XCTest catches the resulting `NSException` via its `@try/@catch` wrapper and `XCTExpectFailure` marks it as
    /// expected, which works consistently across versions.
    /// `#expect(processExitsWith:)` would be the Swift Testing equivalent but is not available for iOS.
    func testORKHealthConditionWithInvalidValue() throws {
        let instance = ORKHealthCondition(
            identifier: "id",
            displayName: "health condition",
            value: ["key": "value"] as NSDictionary
        )
        
        let expectation = """
        {
          "_class" : "ORKHealthCondition",
          "displayName" : "health condition",
          "identifier" : "id",
          "value" : {
            "key" : "value"
          }
        }
        """
                                                                                                                    
        XCTExpectFailure("The values passed to this initializer are expected to fail")
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
