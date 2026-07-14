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

/// Round-trip serialization tests for the text choice answer format.
///
/// Passthrough tests verify stored data survives the ORKTaskViewController pipeline
/// (fixture -> serialize -> deserialize -> pipeline -> re-serialize -> compare JSON).
/// Active-answer tests simulate user input via the native UIKit cell hook, then verify
/// the serialized result matches an expected fixture.
@MainActor
@Suite
struct ORKTextChoiceRoundTripTests {

    private func textChoices() -> [ORKTextChoice] {
        [
            ORKTextChoice(text: "Red", value: "red" as NSString),
            ORKTextChoice(text: "Blue", value: "blue" as NSString),
            ORKTextChoice(text: "Green", value: "green" as NSString)
        ]
    }

    @Test
    func singleChoiceRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        questionResult.choiceAnswers = ["red" as NSString]
        questionResult.questionType = .singleChoice
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
                identifier: "choiceItem",
                text: "Pick a color",
                answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices())
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
            "Single choice answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    @Test
    func multipleChoiceRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        questionResult.choiceAnswers = ["red" as NSString, "blue" as NSString]
        questionResult.questionType = .multipleChoice
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
                identifier: "choiceItem",
                text: "Pick colors",
                answerFormat: ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices())
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
            "Multiple choice answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    // MARK: - Active-Answer Tests

    @Test
    func singleChoiceActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        expectedQuestionResult.choiceAnswers = ["red" as NSString]
        expectedQuestionResult.questionType = .singleChoice
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
                identifier: "choiceItem",
                text: "Pick a color",
                answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices())
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        // Act - simulate tapping "Red" (first choice, index 0)
        let redIndexPath = try #require(FormItemTestHelper.findChoiceRowIndexPath(in: formStepVC.tableView, choiceIndex: 0))
        formStepVC.tableView.delegate?.tableView?(formStepVC.tableView, didSelectRowAt: redIndexPath)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Tapping single choice should produce correct serialized result")
    }

    @Test
    func multipleChoiceActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        expectedQuestionResult.choiceAnswers = ["red" as NSString, "blue" as NSString]
        expectedQuestionResult.questionType = .multipleChoice
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
                identifier: "choiceItem",
                text: "Pick colors",
                answerFormat: ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices())
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        // Act - simulate tapping "Red" then "Blue" (cell indices 0 and 1)
        let redIndexPath = try #require(FormItemTestHelper.findChoiceRowIndexPath(in: formStepVC.tableView, choiceIndex: 0))
        formStepVC.tableView.delegate?.tableView?(formStepVC.tableView, didSelectRowAt: redIndexPath)

        let blueIndexPath = try #require(FormItemTestHelper.findChoiceRowIndexPath(in: formStepVC.tableView, choiceIndex: 1))
        formStepVC.tableView.delegate?.tableView?(formStepVC.tableView, didSelectRowAt: blueIndexPath)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Tapping multiple choices should produce correct serialized result")
    }

    // MARK: - TextChoiceOther Tests

    private func textChoicesWithOther() -> [ORKTextChoice] {
        [
            ORKTextChoice(text: "Red", value: "red" as NSString),
            ORKTextChoice(text: "Blue", value: "blue" as NSString),
            ORKTextChoice(text: "Green", value: "green" as NSString),
            ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSString, exclusive: true, textViewPlaceholderText: "Please specify")
        ]
    }

    @Test
    func textChoiceOtherRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        questionResult.choiceAnswers = ["Other" as NSString]
        questionResult.questionType = .singleChoice
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
                identifier: "choiceItem",
                text: "Pick a color",
                answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoicesWithOther())
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        // Act
        let subject = ORKTaskViewController(
            task: task,
            ongoingResult: deserialized,
            defaultResultSource: deserialized,
            delegate: nil
        )
        subject.loadViewIfNeeded()

        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: fixture)

        // Assert
        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(inputJSON == outputJSON, "Text choice 'Other' answer should survive the full round-trip")
    }

    @Test
    func textChoiceOtherActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKChoiceQuestionResult(identifier: "choiceItem")
        expectedQuestionResult.choiceAnswers = ["Other" as NSString]
        expectedQuestionResult.questionType = .singleChoice
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
                identifier: "choiceItem",
                text: "Pick a color",
                answerFormat: ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoicesWithOther())
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepViewController = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepViewController)

        // Act - simulate tapping the "Other" choice (fourth choice, index 3)
        let otherIndexPath = try #require(
            FormItemTestHelper.findChoiceRowIndexPath(in: formStepViewController.tableView, choiceIndex: 3),
            "Expected to find the 'Other' choice row"
        )
        formStepViewController.tableView.delegate?.tableView?(formStepViewController.tableView, didSelectRowAt: otherIndexPath)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Tapping 'Other' choice should produce correct serialized result")
    }
}
