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
struct ORKScaleAnswerFormatSerializationTests {
    @Test
    func testORKScaleAnswerFormatBasicInit() throws {
        let instance = ORKScaleAnswerFormat(
            maximumValue: 100,
            minimumValue: 0,
            defaultValue: 0,
            step: 10
        )
        instance.gradientColors = [.red, .blue]
        instance.customDontKnowButtonText = ""
        instance.gradientLocations = [0.5]

        let expectation = """
        {
          "_class" : "ORKScaleAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 0,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [
            {
              "a" : 1,
              "b" : 0,
              "g" : 0,
              "r" : 1
            },
            {
              "a" : 1,
              "b" : 1,
              "g" : 0,
              "r" : 0
            }
          ],
          "gradientLocations" : [
            0.5
          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "hideValueMarkers" : false,
          "maximum" : 100,
          "minimum" : 0,
          "showDontKnowButton" : false,
          "step" : 10,
          "vertical" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKScaleAnswerFormatWithVertical() throws {
        let instance = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: 5,
            step: 1,
            vertical: true
        )
        
        instance.gradientColors = []
        instance.customDontKnowButtonText = ""
        instance.gradientLocations = []

        let expectation = """
        {
          "_class" : "ORKScaleAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 5,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "hideValueMarkers" : false,
          "maximum" : 10,
          "minimum" : 0,
          "showDontKnowButton" : false,
          "step" : 1,
          "vertical" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testInvalidORKScaleAnswerFormat() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKScaleAnswerFormat(
                    maximumValue: 1,
                    minimumValue: 100,
                    defaultValue: 1,
                    step: 1
                )
            }
        }
    }

}

@Suite(.tags(.serialization))
struct ORKContinuousScaleAnswerFormatSerializationTests {
    @Test
    func testORKContinuousScaleAnswerFormatBasicInit() throws {
        let instance = ORKContinuousScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 1,
            maximumFractionDigits: 2
        )
        instance.gradientColors = []
        instance.customDontKnowButtonText = ""
        instance.gradientLocations = []

        let expectation = """
        {
          "_class" : "ORKContinuousScaleAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 1,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "maximum" : 10,
          "maximumFractionDigits" : 2,
          "minimum" : 1,
          "numberStyle" : "default",
          "showDontKnowButton" : false,
          "vertical" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)

    }
    
    @Test
    func testORKContinuousScaleAnswerFormatWithVertical() throws {
        let instance = ORKContinuousScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 1.0,
            maximumFractionDigits: 1,
            vertical: true
        )
        instance.gradientColors = []
        instance.customDontKnowButtonText = ""
        instance.gradientLocations = []

        let expectation = """
        {
          "_class" : "ORKContinuousScaleAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 1,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "maximum" : 10,
          "maximumFractionDigits" : 1,
          "minimum" : 1,
          "numberStyle" : "default",
          "showDontKnowButton" : false,
          "vertical" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKContinuousScaleAnswerFormatComplexInit() throws {
        let instance = ORKContinuousScaleAnswerFormat(
            maximumValue: 10.0,
            minimumValue: 1.0,
            defaultValue: 1.0,
            maximumFractionDigits: 1,
            vertical: true,
            maximumValueDescription: "maxValue",
            minimumValueDescription: "minValue"
        )
        instance.gradientColors = []
        instance.customDontKnowButtonText = ""
        instance.gradientLocations = []
        instance.shouldHideLabels = true
        instance.shouldHideRanges = true
        instance.shouldHideSelectedValueLabel = true

        let expectation = """
        {
          "_class" : "ORKContinuousScaleAnswerFormat",
          "customDontKnowButtonText" : "",
          "defaultValue" : 1,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : true,
          "hideRanges" : true,
          "hideSelectedValue" : true,
          "maximum" : 10,
          "maximumFractionDigits" : 1,
          "maximumValueDescription" : "maxValue",
          "minimum" : 1,
          "minimumValueDescription" : "minValue",
          "numberStyle" : "default",
          "showDontKnowButton" : false,
          "vertical" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testInvalidORKContinuousScaleAnswerFormat() {
        #expect(
            throws: (any Error).self,
            "The values passed to this initializer are expected to fail"
        ) {
            try NSObject.executeUsingObjCExceptionHandling {
                let _ = ORKContinuousScaleAnswerFormat(
                    maximumValue: 1,
                    minimumValue: 100,
                    defaultValue: 1,
                    maximumFractionDigits: 1
                )
            }
        }
    }
}
