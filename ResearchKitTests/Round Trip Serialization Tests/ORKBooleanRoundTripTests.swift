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

/// Round-trip serialization tests for the boolean answer format.
///
/// Passthrough tests verify stored data survives the ORKTaskViewController pipeline
/// (fixture -> serialize -> deserialize -> pipeline -> re-serialize -> compare JSON).
/// Active-answer tests simulate user input via the native UIKit cell hook, then verify
/// the serialized result matches an expected fixture.
@MainActor
@Suite
struct ORKBooleanRoundTripTests {

    @Test
    func booleanTrueRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        questionResult.booleanAnswer = NSNumber(value: true)
        questionResult.questionType = .boolean
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
                identifier: "boolItem",
                text: "Yes or no?",
                answerFormat: ORKBooleanAnswerFormat()
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
            "Boolean answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    @Test
    func booleanFalseRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        questionResult.booleanAnswer = NSNumber(value: false)
        questionResult.questionType = .boolean
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
                identifier: "boolItem",
                text: "Yes or no?",
                answerFormat: ORKBooleanAnswerFormat()
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
            "Boolean false answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    // MARK: - Active-Answer Tests

    @Test
    func booleanFalseActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        expectedQuestionResult.booleanAnswer = NSNumber(value: false)
        expectedQuestionResult.questionType = .boolean
        expectedQuestionResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedQuestionResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult = ORKStepResult(stepIdentifier: "formStep", results: [expectedQuestionResult])
        expectedStepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task and present form step
        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(
                identifier: "boolItem",
                text: "Yes or no?",
                answerFormat: ORKBooleanAnswerFormat()
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        let tableView = formStepVC.tableView

        // Find the "No" choice row (second choice, index 1) and simulate tap
        let noIndexPath = try #require(
            FormItemTestHelper.findChoiceRowIndexPath(in: tableView, choiceIndex: 1),
            "Expected to find the 'No' choice row"
        )

        // Act - simulate user tapping "No" via table view selection
        tableView.delegate?.tableView?(tableView, didSelectRowAt: noIndexPath)

        // Assert - serialize and compare
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(
            expectedJSON == outputJSON,
            "Tapping 'No' should produce correct serialized boolean false result"
        )
    }

    @Test
    func booleanTrueActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        expectedQuestionResult.booleanAnswer = NSNumber(value: true)
        expectedQuestionResult.questionType = .boolean
        expectedQuestionResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedQuestionResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult = ORKStepResult(stepIdentifier: "formStep", results: [expectedQuestionResult])
        expectedStepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task and present form step
        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(
                identifier: "boolItem",
                text: "Yes or no?",
                answerFormat: ORKBooleanAnswerFormat()
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        let tableView = formStepVC.tableView

        // Find the "Yes" choice row (first choice, index 0) and simulate tap
        let yesIndexPath = try #require(
            FormItemTestHelper.findChoiceRowIndexPath(in: tableView, choiceIndex: 0),
            "Expected to find the 'Yes' choice row"
        )

        // Act - simulate user tapping "Yes" via table view selection
        tableView.delegate?.tableView?(tableView, didSelectRowAt: yesIndexPath)

        // Assert - serialize and compare
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(
            expectedJSON == outputJSON,
            "Tapping 'Yes' should produce correct serialized boolean true result"
        )
    }

    // MARK: - Don't Know Tests

    @Test
    func dontKnowRoundTrip() throws {
        // Arrange - build fixture with a Don't Know answer
        let answerFormat = ORKBooleanAnswerFormat()
        answerFormat.shouldShowDontKnowButton = true

        let questionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        questionResult.noAnswerType = ORKDontKnowAnswer.answer()
        questionResult.questionType = .boolean
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
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: answerFormat)
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
        #expect(inputJSON == outputJSON, "Don't Know answer should survive the full round-trip")
    }

    @Test
    func dontKnowActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKBooleanQuestionResult(identifier: "boolItem")
        expectedQuestionResult.noAnswerType = ORKDontKnowAnswer.answer()
        expectedQuestionResult.questionType = .boolean
        expectedQuestionResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedQuestionResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult = ORKStepResult(stepIdentifier: "formStep", results: [expectedQuestionResult])
        expectedStepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task with Don't Know button enabled
        let answerFormat = ORKBooleanAnswerFormat()
        answerFormat.shouldShowDontKnowButton = true

        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: answerFormat)
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepViewController = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepViewController)

        let tableView = formStepViewController.tableView

        // The Don't Know button renders as an ORKChoiceViewCell after the Yes/No choices.
        // Boolean has 2 choices (Yes=0, No=1), so Don't Know is at choiceIndex 2.
        let dontKnowIndexPath = try #require(
            FormItemTestHelper.findChoiceRowIndexPath(in: tableView, choiceIndex: 2),
            "Expected to find the 'Don't Know' choice row"
        )

        // Act - simulate tapping the Don't Know button
        tableView.delegate?.tableView?(tableView, didSelectRowAt: dontKnowIndexPath)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Tapping 'Don't Know' should produce correct serialized result")
    }
}
