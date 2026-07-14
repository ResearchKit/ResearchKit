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
struct ORKTextScaleAnswerFormatSerializationTests {
    @Test
    func testORKTextScaleAnswerFormat() throws {
        let instance = ORKTextScaleAnswerFormat(
            textChoices:
                [
                    ORKTextChoice(
                        text: "Poor",
                        value: 1 as NSNumber
                    ),
                    ORKTextChoice(
                        text: "Excellent",
                        value: 2 as NSNumber
                    )
                ],
            defaultIndex: 0
        )
        instance.gradientColors = []
        instance.customDontKnowButtonText = "Don't know"
        instance.gradientLocations = []

        let expectation = """
        {
          "_class" : "ORKTextScaleAnswerFormat",
          "customDontKnowButtonText" : "Don't know",
          "defaultIndex" : 0,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "hideValueMarkers" : false,
          "showDontKnowButton" : false,
          "textChoices" : [
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Poor",
              "value" : 1
            },
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Excellent",
              "value" : 2
            }
          ],
          "vertical" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKTextScaleAnswerFormatWithGradientColors() throws {
        let instance = ORKTextScaleAnswerFormat(
            textChoices:
                [
                    ORKTextChoice(
                        text: "Poor",
                        value: 1 as NSNumber
                    ),
                    ORKTextChoice(
                        text: "Excellent",
                        value: 2 as NSNumber
                    )
                ],
            defaultIndex: 0
        )
        instance.gradientColors = [.red, .blue]
        instance.customDontKnowButtonText = "Don't know"
        instance.gradientLocations = [0.75]

        let expectation = """
        {
          "_class" : "ORKTextScaleAnswerFormat",
          "customDontKnowButtonText" : "Don't know",
          "defaultIndex" : 0,
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
            0.75
          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "hideValueMarkers" : false,
          "showDontKnowButton" : false,
          "textChoices" : [
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Poor",
              "value" : 1
            },
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Excellent",
              "value" : 2
            }
          ],
          "vertical" : false
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }
    
    @Test
    func testORKTextScaleAnswerComplexInit() throws {
        let instance = ORKTextScaleAnswerFormat(
            textChoices:
                [
                    ORKTextChoice(
                        text: "Poor",
                        value: 1 as NSNumber
                    ),
                    ORKTextChoice(
                        text: "Excellent",
                        value: 2 as NSNumber
                    )
                ],
            defaultIndex: 0,
            vertical: true
        )
        instance.gradientColors = []
        instance.customDontKnowButtonText = "Don't know"
        instance.gradientLocations = []

        let expectation = """
        {
          "_class" : "ORKTextScaleAnswerFormat",
          "customDontKnowButtonText" : "Don't know",
          "defaultIndex" : 0,
          "dontKnowButtonStyle" : 1,
          "gradientColors" : [

          ],
          "gradientLocations" : [

          ],
          "hideLabels" : false,
          "hideRanges" : false,
          "hideSelectedValue" : false,
          "hideValueMarkers" : false,
          "showDontKnowButton" : false,
          "textChoices" : [
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Poor",
              "value" : 1
            },
            {
              "_class" : "ORKTextChoice",
              "exclusive" : false,
              "text" : "Excellent",
              "value" : 2
            }
          ],
          "vertical" : true
        }
        """

        try SerializationTestHelper.assertEquality(instance, expectation)
    }

}
