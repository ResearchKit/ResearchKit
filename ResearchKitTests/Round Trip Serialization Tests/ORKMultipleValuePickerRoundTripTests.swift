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

import ResearchKit
import ResearchKitUI
import Testing

/// Round-trip serialization tests for the multiple value picker answer format.
///
/// The multiple value picker combines several independent pickers into one form item.
/// This verifies that selections across multiple picker components are correctly
/// serialized and survive the pipeline round-trip.
@MainActor
@Suite
struct ORKMultipleValuePickerRoundTripTests {

    private func multipleValuePickerAnswerFormat() -> ORKMultipleValuePickerAnswerFormat {
        let firstPicker = ORKValuePickerAnswerFormat(textChoices: [
            ORKTextChoice(text: "A", value: "a" as NSString),
            ORKTextChoice(text: "B", value: "b" as NSString),
            ORKTextChoice(text: "C", value: "c" as NSString)
        ])

        let secondPicker = ORKValuePickerAnswerFormat(textChoices: [
            ORKTextChoice(text: "X", value: "x" as NSString),
            ORKTextChoice(text: "Y", value: "y" as NSString),
            ORKTextChoice(text: "Z", value: "z" as NSString)
        ])

        return ORKMultipleValuePickerAnswerFormat(valuePickers: [firstPicker, secondPicker])
    }

    @Test
    func multipleValuePickerRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKMultipleComponentQuestionResult(identifier: "multiPickerItem")
        questionResult.componentsAnswer = ["a" as NSString, "x" as NSString]
        questionResult.separator = " "
        questionResult.questionType = .multiplePicker
        questionResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        questionResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let stepResult = ORKStepResult(stepIdentifier: "formStep", results: [questionResult])
        stepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        stepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let fixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        fixture.results = [stepResult]

        let inputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(fixture)
        let deserialized: ORKTaskResult = try SerializationTestHelper.deserializedFromPrettyPrintedString(inputJSON)

        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(
                identifier: "multiPickerItem",
                text: "Pick values",
                answerFormat: multipleValuePickerAnswerFormat()
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        // Act - feed through pipeline (user does nothing)
        let subject = ORKTaskViewController(
            task: task,
            ongoingResult: deserialized,
            defaultResultSource: deserialized,
            delegate: nil
        )
        subject.loadViewIfNeeded()

        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: fixture)

        // Assert - full JSON comparison
        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(
            inputJSON == outputJSON,
            "Multiple value picker answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    // MARK: - Active-Answer Tests

    @Test
    func multipleValuePickerActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKMultipleComponentQuestionResult(identifier: "multiPickerItem")
        expectedQuestionResult.componentsAnswer = ["a" as NSString, "x" as NSString]
        expectedQuestionResult.separator = " "
        expectedQuestionResult.questionType = .multiplePicker
        expectedQuestionResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedQuestionResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult = ORKStepResult(stepIdentifier: "formStep", results: [expectedQuestionResult])
        expectedStepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task
        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(
                identifier: "multiPickerItem",
                text: "Pick values",
                answerFormat: multipleValuePickerAnswerFormat()
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepViewController = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepViewController)

        let cell = try #require(FormItemTestHelper.findFormItemCell(in: formStepViewController.tableView))

        // Act - set the answer via the cell hook (first values from each picker)
        cell.ork_setAnswer(["a" as NSString, "x" as NSString])

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(
            expectedJSON == outputJSON,
            "Setting multiple value picker via cell hook should produce correct serialized result"
        )
    }
}
