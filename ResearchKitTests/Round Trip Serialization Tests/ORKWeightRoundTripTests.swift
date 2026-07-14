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

/// Round-trip serialization tests for the weight answer format.
///
/// Passthrough tests verify stored data survives the ORKTaskViewController pipeline
/// (fixture -> serialize -> deserialize -> pipeline -> re-serialize -> compare JSON).
/// Active-answer tests simulate user input via the native UIKit cell hook, then verify
/// the serialized result matches an expected fixture.
@MainActor
@Suite
struct ORKWeightRoundTripTests {

    @Test
    func weightRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKNumericQuestionResult(identifier: "weightItem")
        questionResult.numericAnswer = NSNumber(value: 70.0)
        questionResult.unit = "kg"
        questionResult.questionType = .weight
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
                identifier: "weightItem",
                text: "Your weight",
                answerFormat: ORKWeightAnswerFormat(measurementSystem: .metric)
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
        #expect(inputJSON == outputJSON, "Weight answer should survive the full round-trip")
    }

    // MARK: - Active-Answer Tests

    @Test
    func weightActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKNumericQuestionResult(identifier: "weightItem")
        expectedQuestionResult.numericAnswer = NSNumber(value: 70.0)
        expectedQuestionResult.unit = "kg"
        expectedQuestionResult.questionType = .weight
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
            ORKFormItem(identifier: "weightItem", text: "Your weight", answerFormat: ORKWeightAnswerFormat(measurementSystem: .metric))
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepVC = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepVC)

        let cell = try #require(FormItemTestHelper.findFormItemCell(in: formStepVC.tableView))

        // Act
        cell.ork_setAnswer(NSNumber(value: 70.0))

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)
        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(expectedJSON == outputJSON, "Setting weight via cell hook should produce correct serialized result")
    }
}
