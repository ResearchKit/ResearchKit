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

import Testing

@Suite(.tags(.serialization))
struct ORKAgeAnswerFormatSerializationTests {
    @Test
    func testORKAgeAnswerFormatMinInit() throws {
        let instance = ORKAgeAnswerFormat(
            minimumAge: 0,
            maximumAge: 80
        )
        instance.customDontKnowButtonText = ""

        let year = Calendar.current.component(.year, from: Date())

        let expectation = """
        {
          "_class" : "ORKAgeAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 0,
          "dontKnowButtonStyle" : 1,
          "maximumAge" : 80,
          "minimumAge" : 0,
          "relativeYear" : \(year),
          "showDontKnowButton" : false,
          "showYear" : false,
          "treatMaxAgeAsRange" : false,
          "treatMinAgeAsRange" : false,
          "useYearForResult" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

    @Test
    func testORKAgeAnswerFormatMinInitAndRelativeYear() throws {
        let instance = ORKAgeAnswerFormat(
            minimumAge: 0,
            maximumAge: 80
        )
        
        instance.relativeYear = 3
        instance.customDontKnowButtonText = ""

        let expectation = """
        {
          "_class" : "ORKAgeAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 0,
          "dontKnowButtonStyle" : 1,
          "maximumAge" : 80,
          "minimumAge" : 0,
          "relativeYear" : 3,
          "showDontKnowButton" : false,
          "showYear" : false,
          "treatMaxAgeAsRange" : false,
          "treatMinAgeAsRange" : false,
          "useYearForResult" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKAgeAnswerFormatYearResult() throws {
        let instance = ORKAgeAnswerFormat(
            minimumAge: 0,
            maximumAge: 80,
            minimumAgeCustomText: "",
            maximumAgeCustomText: "",
            showYear: true,
            useYearForResult: false,
            defaultValue: 0
        )
        
        instance.customDontKnowButtonText = ""

        let year = Calendar.current.component(.year, from: Date())

        let expectation = """
        {
          "_class" : "ORKAgeAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 0,
          "dontKnowButtonStyle" : 1,
          "maximumAge" : 80,
          "maximumAgeCustomText" : "",
          "minimumAge" : 0,
          "minimumAgeCustomText" : "",
          "relativeYear" : \(year),
          "showDontKnowButton" : false,
          "showYear" : true,
          "treatMaxAgeAsRange" : false,
          "treatMinAgeAsRange" : false,
          "useYearForResult" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKAgeAnswerFormatFullInit() throws {
        let instance = ORKAgeAnswerFormat(
            minimumAge: 0,
            maximumAge: 80,
            minimumAgeCustomText: "",
            maximumAgeCustomText: "",
            showYear: false,
            useYearForResult: false,
            treatMinAgeAsRange: true,
            treatMaxAgeAsRange: true,
            defaultValue: 0
        )
        
        instance.customDontKnowButtonText = ""

        let year = Calendar.current.component(.year, from: Date())

        let expectation = """
        {
          "_class" : "ORKAgeAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 0,
          "dontKnowButtonStyle" : 1,
          "maximumAge" : 80,
          "maximumAgeCustomText" : "",
          "minimumAge" : 0,
          "minimumAgeCustomText" : "",
          "relativeYear" : \(year),
          "showDontKnowButton" : false,
          "showYear" : false,
          "treatMaxAgeAsRange" : true,
          "treatMinAgeAsRange" : true,
          "useYearForResult" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKAgeAnswerFormatInvalid() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKAgeAnswerFormat(
                    minimumAge: -1,
                    maximumAge: 80,
                    minimumAgeCustomText: nil,
                    maximumAgeCustomText: nil,
                    showYear: false,
                    useYearForResult: false,
                    treatMinAgeAsRange: true,
                    treatMaxAgeAsRange: true,
                    defaultValue: 0
                )
            }
        }
    }

    @Test
    func testORKAgeAnswerFormatInvalidMax() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKAgeAnswerFormat(
                    minimumAge: 0,
                    maximumAge: 151,
                    minimumAgeCustomText: nil,
                    maximumAgeCustomText: nil,
                    showYear: false,
                    useYearForResult: false,
                    treatMinAgeAsRange: true,
                    treatMaxAgeAsRange: true,
                    defaultValue: 0
                )
            }
        }
    }

    @Test
    func testORKAgeAnswerFormatInvalidMinMax() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKAgeAnswerFormat(
                    minimumAge: 100,
                    maximumAge: 2,
                    minimumAgeCustomText: nil,
                    maximumAgeCustomText: nil,
                    showYear: false,
                    useYearForResult: false,
                    treatMinAgeAsRange: true,
                    treatMaxAgeAsRange: true,
                    defaultValue: 0
                )
            }
        }
    }
}
