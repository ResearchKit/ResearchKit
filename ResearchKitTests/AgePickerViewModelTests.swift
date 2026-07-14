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
@testable import ResearchKitUI

extension Tag {
    @Tag static var AgePicker: Self
}

@Suite(.tags(.AgePicker))
struct AgePickerViewModelWithNilFormItem {
    let testViewModel: ORKAgePickerView.ViewModel
    let defaultAnswerFormat: ORKAgeAnswerFormat
    init() {
        self.defaultAnswerFormat = .init()
        self.testViewModel = .init()
    }

    @Test
    func `the default answer format is ORKAgeAnswerFormat`() {
        #expect(testViewModel.formItem.identifier == "")
    }

    @Test
    func `the selectable ages are between the default minimum and maximum`() {

        let selectableAges = defaultAnswerFormat.minimumAge...defaultAnswerFormat.maximumAge

        #expect(
            testViewModel.answers.count == selectableAges.upperBound - selectableAges.lowerBound + 1
        )
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerViewModelFormItemHasInvalidAnswerFormat {

    @Test
    func `initializer should throw an error`() {
        let formItem = ORKFormItem(
            identifier: "test",
            text:"",
            answerFormat: ORKHeightAnswerFormat()
        )
        #expect(throws: NSError.self) {
            try ORKAgePickerView.ViewModel(formItem: formItem)
        }
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerViewModelWhereFormItemHasValidAgeAnswerFormatFormItem {
    let testViewModel: ORKAgePickerView.ViewModel
    let defaultAgeValue: Int = 18

    init() throws {
        self.testViewModel = try viewModel(with:
                .testAnswerFormat(age: .init(default: defaultAgeValue))
        )
    }

    @Test
    func `initially selected answer should be answerFormat defaultValue`() {
        #expect(self.testViewModel.selectedAge == defaultAgeValue)
    }

    @Test
    func `lowest selectable age is 10`() {
        #expect(self.testViewModel.answers.min() == 10)
    }

    @Test
    func `highest selectable age is 30`() {
        #expect(self.testViewModel.answers.max() == 30)
    }

    @Test(.disabled("Fails when run as part of the suite, but passes when run as a standalone test. Needs investigation."))
    func `when selecting a new age selected age should update`() async {
        await confirmation(expectedCount: 1) { confirm in
            testViewModel.startObserving { selection in
                #expect(selection == 15)
                confirm()
            }

            testViewModel.setSelectedAge(15)
        }
    }

    @Test(.disabled("Fails when run as part of the suite, but passes when run as a standalone test. Needs investigation."))
    func `when selecting an age outside the range it should not update the selection`() async {
        await confirmation(expectedCount: 1) { confirm in
            testViewModel.startObserving { selection in
                #expect(selection == defaultAgeValue)
                confirm()
            }
            testViewModel.setSelectedAge(40)
        }
    }

    @Test
    func `after stop observing no updates are delivered`() throws {
        testViewModel.startObserving { selection in
            #expect(selection == 30)
        }

        testViewModel.setSelectedAge(30)

        testViewModel.stopObserving()
        testViewModel.setSelectedAge(15)

        #expect(testViewModel.selectedAge == 15)
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerSelectedAnswerFormat {
    let testAnswerFormat: ORKAgeAnswerFormat
    let testViewModel: ORKAgePickerView.ViewModel

    init() throws {
        self.testAnswerFormat = .testAnswerFormat(options: .init(minAgeAsRange: true, maxAgeAsRange: true))
        self.testViewModel = try viewModel(with: testAnswerFormat)
    }

    @Test
    func `when selected age is same as minAge objectValue should match custom text`() throws {
        let minimumAge = testAnswerFormat.minimumAge
        testViewModel.setSelectedAge(minimumAge)
        let objectValue = try #require(testViewModel.selectedAge.objectValue as? Int32)
        #expect(objectValue == -1)
    }

    @Test
    func `when selected age is same as maxAge objectValue should match custom text`() throws {
        let maximumAge = testAnswerFormat.maximumAge
        testViewModel.setSelectedAge(maximumAge)
        let objectValue = try #require(testViewModel.selectedAge.objectValue as? Int32)
        #expect(objectValue == -2)
    }

    @Test
    func `when setting selected age as min sentinel value age value should be min age`() throws {
        testViewModel.setSelectedAge(-1)
        let ageValue = try #require(testViewModel.selectedAge.age)
        #expect(ageValue == testAnswerFormat.minimumAge)
    }

    @Test
    func `when setting selected age as max sentinel value age should be max age`() throws {
        testViewModel.setSelectedAge(-2)
        let ageValue = try #require(testViewModel.selectedAge.age)
        #expect(ageValue == testAnswerFormat.maximumAge)
    }

    @Test
    func `when setting selected age with an invalid sentinel value it should be ignored`() throws {
        let defaultAge = 20
        let viewModel = try viewModel(with: .testAnswerFormat(age: .init(default: defaultAge)))

        viewModel.setSelectedAge(-999)
        #expect(viewModel.selectedAge == viewModel.defaultDontKnowAnswer)
    }

    @Test
    func `selectedAge should remain consistent after invalid setSelectedAge calls`() throws {
        let viewModel = try viewModel(with: .testAnswerFormat())

        viewModel.setSelectedAge("invalid")
        #expect(viewModel.selectedAge == viewModel.defaultDontKnowAnswer)
    }
}

private func viewModel(with answerFormat: ORKAgeAnswerFormat) throws -> ORKAgePickerView.ViewModel {
    let formItem = ORKFormItem(
        identifier: "test",
        text:"",
        answerFormat: answerFormat
    )
    return try .init(formItem: formItem)
}

private var currentYear: Int {
    Calendar.current.component(.year, from: Date())
}

@Suite(.tags(.AgePicker))
struct AgePickerSelectableOptionFormatting {
    let answerFormat: ORKAgeAnswerFormat

    init() throws {
        self.answerFormat = .testAnswerFormat(options: .init(showYear: true))
    }

    @Test
    func `relative year for age calculations is current year`() throws {
        let viewModel = try viewModel(with: answerFormat)
        #expect(viewModel.answerFormat.relativeYear == currentYear)
    }

    @Test
    func `formatting selectable option should show the age and year value as a string`() throws {
        let relativeYear = currentYear - 10
        let formatted = try viewModel(with: answerFormat).formatOption(10)

        #expect(formatted == "\(relativeYear) (10)")
    }

    @Test
    func `the selected option should show the age value as a string`() throws {
        let formatted = try viewModel(with: answerFormat).formatSelection(20)

        #expect(formatted == "20")
    }
}
@Suite(.tags(.AgePicker))
struct AgePickerViewModel_when_useYearForResult_is_false {
    let answerFormat: ORKAgeAnswerFormat

    init() throws {
        self.answerFormat = .testAnswerFormat(options: .init(useYearForResult: false))
    }

    @Test
    func `selected age is the same as the selected option`() throws {
        let viewModel = try viewModel(with: answerFormat)
        let selectableOption = viewModel.formatOption(10)

        #expect(selectableOption == "10")
    }

    @Test
    func `formatting selectable option should show the correct value`() throws {
        let viewModel = try viewModel(with: answerFormat)
        viewModel.setSelectedAge(11)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int)
        #expect(selectedAge == 11)
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerViewModel_when_useYearForResult_is_true {
    let answerFormat: ORKAgeAnswerFormat

    init() throws {
        self.answerFormat = .testAnswerFormat(options: .init(useYearForResult: true))
    }

    @Test
    func `formatting selectable option should show the age value as a string`() throws {
        let formatted = try viewModel(with: answerFormat).formatOption(10)

        #expect(formatted == "10")
    }

    @Test
    func `formatting selected option should show the age value as an integer year`() throws {
        let viewModel = try viewModel(with: answerFormat)
        viewModel.setSelectedAge(21)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int)
        #expect(selectedAge == currentYear - 21)
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerSetSelectedAge {
    @Test
    func `when treatMinAgeAsRange is true and selected age is minimum then use sentinel value`() throws {
        let viewModel = try viewModel(with: .testAnswerFormat(options: .init(minAgeAsRange: true)))
        viewModel.setSelectedAge(10)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int32)
        #expect(selectedAge == -1)
    }

    @Test
    func `when treatMinAgeAsRange is true and selected age is maximum then the objectValue is an integer age`() throws {
        let viewModel = try viewModel(with: .testAnswerFormat(options: .init(minAgeAsRange: true)))
        viewModel.setSelectedAge(30)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int)
        #expect(selectedAge == 30)
    }

    @Test
    func `when treatMaxAgeAsRange is true and selected age is minimum then the objectValue is an integer age`() throws {
        let viewModel = try viewModel(with: .testAnswerFormat(options: .init(maxAgeAsRange: true)))
        viewModel.setSelectedAge(10)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int)
        #expect(selectedAge == 10)
    }

    @Test
    func `when treatMaxAgeAsRange is true and selected age is maximum then use sentinel value`() throws {
        let viewModel = try viewModel(with: .testAnswerFormat(options: .init(maxAgeAsRange: true)))
        viewModel.setSelectedAge(30)

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? Int32)
        #expect(selectedAge == -2)
    }

    @Test
    func `when preferNotToAnswer is selected then selected age is dontKnowAnswer`() throws {
        let viewModel = try viewModel(
            with: .testAnswerFormat(options: .init(minAgeAsRange: true, maxAgeAsRange: true))
        )
        viewModel.setSelectedAge(ORKDontKnowAnswer.answer())

        let selectedAge = try #require(viewModel.selectedAge.objectValue as? ORKDontKnowAnswer)
        #expect(selectedAge == ORKDontKnowAnswer.answer())
    }

    @Test
    func `when setSelectedAge receives NSNull the selected age is the default age`() throws {
        let defaultAgeValue = 25
        let viewModel = try viewModel(with: .testAnswerFormat(age: .init(default: defaultAgeValue)))
        viewModel.setSelectedAge(NSNull())

        #expect(viewModel.selectedAge == defaultAgeValue)
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerMinimumCustomAgeTextFormatting {
    let answerFormat: ORKAgeAnswerFormat

    init() throws {
        self.answerFormat = .testAnswerFormat(messages: .init(min: "Not Tall Enough to Ride"), options: .init(useYearForResult: true))
    }

    @Test
    func `formatter returns custom minimum age text when formatting minimum age`() throws {
        let formatted = try viewModel(with: answerFormat).formatOption(10)
        #expect(formatted == "Not Tall Enough to Ride")
    }

    @Test
    func `formatter returns only age when formatting age option`() throws {
        let formatted = try viewModel(with: answerFormat).formatOption(30)
        #expect(formatted == "30")
    }

    @Test
    func `formatter returns year for selection`() throws {
        let formatted = try viewModel(with: answerFormat).formatSelection(30)
        #expect(formatted == "\(currentYear - 30)")
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerMaxiumumCustomAgeTextFormatting {
    let answerFormat: ORKAgeAnswerFormat

    init() throws {
        self.answerFormat = .testAnswerFormat(messages: .init(max: "Over the Hill"), options: .init(useYearForResult: true))
    }

    @Test
    func `formatter returns only age when formatting age option`() throws {
        let formatted = try viewModel(with: answerFormat).formatOption(10)
        #expect(formatted == "10")
    }

    @Test
    func `formatter returns year for selection`() throws {
        let formatted = try viewModel(with: answerFormat).formatSelection(10)
        #expect(formatted == "\(currentYear - 10)")
    }

    @Test
    func `formatter returns custom maximum age text when formatting minimum age`() throws {
        let formatted = try viewModel(with: answerFormat).formatOption(30)
        #expect(formatted == "Over the Hill")
    }
}

@Suite(.tags(.AgePicker))
struct AgePickerShowDontKnowOption {
    @Test
    func `when shouldShowDontKnowButton is false then dontKnowAnswer is nil`() throws {
        let answerFormat = ORKAgeAnswerFormat.testAnswerFormat()
        answerFormat.shouldShowDontKnowButton = false
        let viewModel = try viewModel(with: answerFormat)
        #expect(viewModel.dontKnowAnswer == nil)
    }

    @Test
    func `when shouldShowDontKnowButton is true then dontKnowAnswer is not nil`() throws {
        let answerFormat = ORKAgeAnswerFormat.testAnswerFormat()
        answerFormat.customDontKnowButtonText = "Guess?"
        answerFormat.shouldShowDontKnowButton = true
        let viewModel = try viewModel(with: answerFormat)
        #expect(viewModel.dontKnowAnswer != nil)
    }
}

extension ORKAgeAnswerFormat {
    struct MessagesOption {
        let min: String?
        let max: String?

        init(min: String? = nil, max: String? = nil) {
            self.min = min
            self.max = max
        }
    }

    struct FeatureOption {
        let showYear: Bool
        let useYearForResult: Bool
        let minAgeAsRange: Bool
        let maxAgeAsRange: Bool

        init(showYear: Bool = false, useYearForResult: Bool = false, minAgeAsRange: Bool = false, maxAgeAsRange: Bool = false) {
            self.showYear = showYear
            self.useYearForResult = useYearForResult
            self.minAgeAsRange = minAgeAsRange
            self.maxAgeAsRange = maxAgeAsRange
        }
    }

    struct AgeOption {
        let min: Int
        let max: Int
        let `default`: Int
        init(min: Int = 10, max: Int = 30, `default`: Int = 20) {
            self.min = min
            self.max = max
            self.default = `default`
        }
    }

    static func testAnswerFormat(age: AgeOption = .init(), messages: MessagesOption = .init(), options: FeatureOption = .init()) -> ORKAgeAnswerFormat {
        .init(
            minimumAge: age.min,
            maximumAge: age.max,
            minimumAgeCustomText: messages.min,
            maximumAgeCustomText: messages.max,
            showYear: options.showYear,
            useYearForResult: options.useYearForResult,
            treatMinAgeAsRange: options.minAgeAsRange,
            treatMaxAgeAsRange: options.maxAgeAsRange,
            defaultValue: age.default
        )
    }
}
