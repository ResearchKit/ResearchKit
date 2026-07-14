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

/// Round-trip serialization tests for the color choice answer format.
///
/// Color choices use ORKColorChoice objects (with a color property) instead of text
/// or images. This verifies the color choice answer format produces correctly
/// serialized results through the pipeline.
@MainActor
@Suite
struct ORKColorChoiceRoundTripTests {

    private func colorChoices() -> [ORKColorChoice] {
        [
            ORKColorChoice(color: .red, text: "Red", detailText: nil, value: "red" as NSString),
            ORKColorChoice(color: .green, text: "Green", detailText: nil, value: "green" as NSString),
            ORKColorChoice(color: .blue, text: "Blue", detailText: nil, value: "blue" as NSString)
        ]
    }

    @Test
    func colorChoiceRoundTrip() throws {
        // Arrange - build fixture
        let questionResult = ORKChoiceQuestionResult(identifier: "colorItem")
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
                identifier: "colorItem",
                text: "Pick a color",
                answerFormat: ORKColorChoiceAnswerFormat(style: .singleChoice, colorChoices: colorChoices())
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
            "Color choice answer should survive the full round-trip through ORKTaskViewController"
        )
    }

    // MARK: - Active-Answer Tests

    @Test
    func colorChoiceActiveAnswer() throws {
        // Arrange - build expected fixture
        let expectedQuestionResult = ORKChoiceQuestionResult(identifier: "colorItem")
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
                identifier: "colorItem",
                text: "Pick a color",
                answerFormat: ORKColorChoiceAnswerFormat(style: .singleChoice, colorChoices: colorChoices())
            )
        ]
        let task = ORKNavigableOrderedTask(identifier: "task", steps: [formStep])

        let subject = ORKTaskViewController(task: task, taskRun: nil)
        subject.loadViewIfNeeded()
        subject.flipToPage(withIdentifier: "formStep", forward: true, animated: false)

        let formStepViewController = try #require(subject.currentStepViewController as? ORKFormStepViewController)
        FormItemTestHelper.materializeFormStep(formStepViewController)

        // Act - simulate tapping "Red" (first choice, index 0)
        let redIndexPath = try #require(
            FormItemTestHelper.findChoiceRowIndexPath(in: formStepViewController.tableView, choiceIndex: 0),
            "Expected to find the 'Red' color choice row"
        )
        formStepViewController.tableView.delegate?.tableView?(formStepViewController.tableView, didSelectRowAt: redIndexPath)

        // Assert
        let output = subject.result
        FormItemTestHelper.stampVolatileFields(on: output, from: expectedFixture)

        let outputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(output)
        #expect(
            expectedJSON == outputJSON,
            "Tapping a color choice should produce correct serialized result"
        )
    }
}
