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

/// Tests structural composition behaviors that the per-format tests don't cover.
///
/// The per-format round-trip tests use one question per step, one step per task. These
/// tests verify that the pipeline correctly handles result aggregation when multiple
/// items share a step or multiple steps share a task. Only a minimal set is needed
/// since the goal is to drive the structural behavior (ordering, composition of the
/// results array), not to test every permutation of answer format combinations.
@MainActor
@Suite
struct ORKFormStepCompositionRoundTripTests {

    // MARK: - Multiple Items in One Step

    @Test
    func multipleItemsInOneStepRoundTrip() throws {
        // Arrange - fixture with a Boolean and a Numeric result in one step
        let booleanResult = ORKBooleanQuestionResult(identifier: "boolItem")
        booleanResult.booleanAnswer = NSNumber(value: true)
        booleanResult.questionType = .boolean
        booleanResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        booleanResult.endDate = Date(timeIntervalSinceReferenceDate: 30)

        let numericResult = ORKNumericQuestionResult(identifier: "numItem")
        numericResult.numericAnswer = NSNumber(value: 42)
        numericResult.questionType = .integer
        numericResult.startDate = Date(timeIntervalSinceReferenceDate: 30)
        numericResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let stepResult = ORKStepResult(stepIdentifier: "formStep", results: [booleanResult, numericResult])
        stepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        stepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let fixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        fixture.results = [stepResult]

        let inputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(fixture)
        let deserialized: ORKTaskResult = try SerializationTestHelper.deserializedFromPrettyPrintedString(inputJSON)

        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: ORKBooleanAnswerFormat()),
            ORKFormItem(identifier: "numItem", text: "Enter a number", answerFormat: ORKNumericAnswerFormat(style: .integer))
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
        #expect(inputJSON == outputJSON, "Multiple items in one step should survive the round-trip")
    }

    @Test
    func multipleItemsInOneStepActiveAnswer() throws {
        // Arrange - expected fixture
        let expectedBoolResult = ORKBooleanQuestionResult(identifier: "boolItem")
        expectedBoolResult.booleanAnswer = NSNumber(value: true)
        expectedBoolResult.questionType = .boolean
        expectedBoolResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedBoolResult.endDate = Date(timeIntervalSinceReferenceDate: 30)

        let expectedNumResult = ORKNumericQuestionResult(identifier: "numItem")
        expectedNumResult.numericAnswer = NSNumber(value: 42)
        expectedNumResult.questionType = .integer
        expectedNumResult.startDate = Date(timeIntervalSinceReferenceDate: 30)
        expectedNumResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult = ORKStepResult(stepIdentifier: "formStep", results: [expectedBoolResult, expectedNumResult])
        expectedStepResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task
        let formStep = ORKFormStep(identifier: "formStep")
        formStep.formItems = [
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: ORKBooleanAnswerFormat()),
            ORKFormItem(identifier: "numItem", text: "Enter a number", answerFormat: ORKNumericAnswerFormat(style: .integer))
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        // Act - answer the Boolean via choice row tap, then the Numeric via cell hook
        let yesIndexPath = try #require(FormItemTestHelper.findChoiceRowIndexPath(in: formStepVC.tableView, choiceIndex: 0))
        formStepVC.tableView.delegate?.tableView?(formStepVC.tableView, didSelectRowAt: yesIndexPath)

        let numericCell = try #require(FormItemTestHelper.findFormItemCell(in: formStepVC.tableView))
        numericCell.ork_setAnswer(NSNumber(value: 42))

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Answering multiple items in one step should produce correct serialized result")
    }

    // MARK: - Multiple Steps

    @Test
    func multipleStepsRoundTrip() throws {
        // Arrange - fixture with two form steps
        let booleanResult = ORKBooleanQuestionResult(identifier: "boolItem")
        booleanResult.booleanAnswer = NSNumber(value: false)
        booleanResult.questionType = .boolean
        booleanResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        booleanResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let stepResult1 = ORKStepResult(stepIdentifier: "step1", results: [booleanResult])
        stepResult1.startDate = Date(timeIntervalSinceReferenceDate: 0)
        stepResult1.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let textResult = ORKTextQuestionResult(identifier: "textItem")
        textResult.textAnswer = "Hello"
        textResult.questionType = .text
        textResult.startDate = Date(timeIntervalSinceReferenceDate: 120)
        textResult.endDate = Date(timeIntervalSinceReferenceDate: 180)

        let stepResult2 = ORKStepResult(stepIdentifier: "step2", results: [textResult])
        stepResult2.startDate = Date(timeIntervalSinceReferenceDate: 120)
        stepResult2.endDate = Date(timeIntervalSinceReferenceDate: 240)

        let fixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        fixture.results = [stepResult1, stepResult2]

        let inputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(fixture)
        let deserialized: ORKTaskResult = try SerializationTestHelper.deserializedFromPrettyPrintedString(inputJSON)

        let formStep1 = ORKFormStep(identifier: "step1")
        formStep1.formItems = [
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: ORKBooleanAnswerFormat())
        ]

        let formStep2 = ORKFormStep(identifier: "step2")
        formStep2.formItems = [
            ORKFormItem(identifier: "textItem", text: "Enter text", answerFormat: ORKTextAnswerFormat())
        ]

        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep1, formStep2])

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
        #expect(inputJSON == outputJSON, "Multiple steps should survive the round-trip")
    }

    @Test
    func multipleStepsActiveAnswer() throws {
        // Arrange - expected fixture with two steps
        let expectedBoolResult = ORKBooleanQuestionResult(identifier: "boolItem")
        expectedBoolResult.booleanAnswer = NSNumber(value: false)
        expectedBoolResult.questionType = .boolean
        expectedBoolResult.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedBoolResult.endDate = Date(timeIntervalSinceReferenceDate: 60)

        let expectedStepResult1 = ORKStepResult(stepIdentifier: "step1", results: [expectedBoolResult])
        expectedStepResult1.startDate = Date(timeIntervalSinceReferenceDate: 0)
        expectedStepResult1.endDate = Date(timeIntervalSinceReferenceDate: 120)

        let expectedTextResult = ORKTextQuestionResult(identifier: "textItem")
        expectedTextResult.textAnswer = "Hello"
        expectedTextResult.questionType = .text
        expectedTextResult.startDate = Date(timeIntervalSinceReferenceDate: 120)
        expectedTextResult.endDate = Date(timeIntervalSinceReferenceDate: 180)

        let expectedStepResult2 = ORKStepResult(stepIdentifier: "step2", results: [expectedTextResult])
        expectedStepResult2.startDate = Date(timeIntervalSinceReferenceDate: 120)
        expectedStepResult2.endDate = Date(timeIntervalSinceReferenceDate: 240)

        let expectedFixture = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
        expectedFixture.results = [expectedStepResult1, expectedStepResult2]

        let expectedJSON = try SerializationTestHelper.serializeToPrettyPrintedString(expectedFixture)

        // Build task
        let formStep1 = ORKFormStep(identifier: "step1")
        formStep1.formItems = [
            ORKFormItem(identifier: "boolItem", text: "Yes or no?", answerFormat: ORKBooleanAnswerFormat())
        ]

        let formStep2 = ORKFormStep(identifier: "step2")
        formStep2.formItems = [
            ORKFormItem(identifier: "textItem", text: "Enter text", answerFormat: ORKTextAnswerFormat())
        ]

        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep1, formStep2])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()

        // Answer step 1 (Boolean)
        subject.flipToPage(withIdentifier: "step1", forward: true, animated: false)
        let formStepVC1 = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC1)

        let noIndexPath = try #require(FormItemTestHelper.findChoiceRowIndexPath(in: formStepVC1.tableView, choiceIndex: 1))
        formStepVC1.tableView.delegate?.tableView?(formStepVC1.tableView, didSelectRowAt: noIndexPath)

        // Answer step 2 (Text)
        subject.flipToPage(withIdentifier: "step2", forward: true, animated: false)
        let formStepVC2 = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC2)

        let textCell = try #require(FormItemTestHelper.findFormItemCell(in: formStepVC2.tableView))
        textCell.ork_setAnswer("Hello" as NSString)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Answering multiple steps should produce correct serialized result")
    }
}
