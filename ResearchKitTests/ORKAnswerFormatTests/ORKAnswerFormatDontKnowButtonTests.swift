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

// MARK: - Tests

@Suite
struct ORKAnswerFormatDontKnowButtonTests {
    let shouldShowDontKnowButton = true
    let customDontKnowButtonText = "Not sure"
    let dontKnowButtonStyle: ORKDontKnowButtonStyle = .circleChoice
    
    @Test(arguments: formatTestCases)
    func shouldShowDontKnowButtonReturnsTrueWhenSetToTrue(_ testCase: FormatTestCase) {
        let format = testCase.makeFormat()
        format.shouldShowDontKnowButton = shouldShowDontKnowButton
        #expect(format.shouldShowDontKnowButton == shouldShowDontKnowButton)
    }

    @Test(arguments: formatTestCases)
    func shouldShowDontKnowButtonIsPreservedAfterCopyingViaORKFormItem(_ testCase: FormatTestCase) throws {
        let format = testCase.makeFormat()
        format.shouldShowDontKnowButton = shouldShowDontKnowButton
        format.customDontKnowButtonText = customDontKnowButtonText
        format.dontKnowButtonStyle = dontKnowButtonStyle
        
        let copy = try #require(formItemCopy(of: format))
        #expect(copy.shouldShowDontKnowButton == shouldShowDontKnowButton)
        #expect(copy.customDontKnowButtonText == customDontKnowButtonText)
        #expect(copy.dontKnowButtonStyle == dontKnowButtonStyle)
    }
}

// MARK: - Format factories

struct FormatTestCase: CustomTestStringConvertible, @unchecked Sendable {
    let testDescription: String
    let makeFormat: () -> ORKAnswerFormat
}

private let formatTestCases: [FormatTestCase] = [
    FormatTestCase(testDescription: "ORKValuePickerAnswerFormat") {
        ORKValuePickerAnswerFormat(textChoices: [])
    },
    FormatTestCase(testDescription: "ORKMultipleValuePickerAnswerFormat") {
        ORKMultipleValuePickerAnswerFormat(valuePickers: [])
    },
    FormatTestCase(testDescription: "ORKTextChoiceAnswerFormat") {
        ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: [])
    },
    FormatTestCase(testDescription: "ORKColorChoiceAnswerFormat") {
        ORKColorChoiceAnswerFormat(style: .singleChoice, colorChoices: [])
    },
    FormatTestCase(testDescription: "ORKLocationAnswerFormat") {
        ORKLocationAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKBooleanAnswerFormat") {
        ORKBooleanAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKImageChoiceAnswerFormat") {
        ORKImageChoiceAnswerFormat(imageChoices: [])
    },
    FormatTestCase(testDescription: "ORKScaleAnswerFormat") {
        ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 0,
            defaultValue: 5,
            step: 1
        )
    },
    FormatTestCase(testDescription: "ORKContinuousScaleAnswerFormat") {
        ORKContinuousScaleAnswerFormat(
            maximumValue: 10.0,
            minimumValue: 0.0,
            defaultValue: 5.0,
            maximumFractionDigits: 1
        )
    },
    FormatTestCase(testDescription: "ORKTextScaleAnswerFormat") {
        let choices = [
            ORKTextChoice(
                text: "A",
                detailText: nil,
                value: "a" as NSString,
                exclusive: false
            ),
            ORKTextChoice(
                text: "B",
                detailText: nil,
                value: "b" as NSString,
                exclusive: false
            )
        ]
        return ORKTextScaleAnswerFormat(textChoices: choices, defaultIndex: 0)
    },
    FormatTestCase(testDescription: "ORKNumericAnswerFormat") {
        ORKNumericAnswerFormat(style: .decimal)
    },
    FormatTestCase(testDescription: "ORKTimeOfDayAnswerFormat") {
        ORKTimeOfDayAnswerFormat(defaultComponents: nil)
    },
    FormatTestCase(testDescription: "ORKDateAnswerFormat") {
        ORKDateAnswerFormat(style: .date)
    },
    FormatTestCase(testDescription: "ORKTextAnswerFormat") {
        ORKTextAnswerFormat(maximumLength: 0)
    },
    FormatTestCase(testDescription: "ORKEmailAnswerFormat") {
        ORKEmailAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKTimeIntervalAnswerFormat") {
        ORKTimeIntervalAnswerFormat(defaultInterval: 60, step: 1)
    },
    FormatTestCase(testDescription: "ORKHeightAnswerFormat") {
        ORKHeightAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKWeightAnswerFormat") {
        ORKWeightAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKAgeAnswerFormat") {
        ORKAgeAnswerFormat()
    },
    FormatTestCase(testDescription: "ORKSESAnswerFormat") {
        ORKSESAnswerFormat(topRungText: nil, bottomRungText: nil)
    },
]

// MARK: - Helpers

private func formItemCopy(of answerFormat: ORKAnswerFormat) -> ORKAnswerFormat? {
    ORKFormItem(identifier: "test", text: nil, answerFormat: answerFormat).answerFormat
}
