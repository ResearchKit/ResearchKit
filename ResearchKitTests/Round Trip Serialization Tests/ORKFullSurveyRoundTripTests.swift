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

/// Full-survey round-trip test using a real survey definition from the codebase.
///
/// The per-format and composition tests use hand-built fixtures with 1-2 questions.
/// Those tests verify individual answer format serialization and structural composition,
/// but they don't exercise the pipeline at the scale of a real survey. A production
/// survey has dozens of steps with mixed answer formats, and the pipeline needs to
/// preserve all of that data faithfully when restoring a partially or fully completed
/// survey from serialized results.
///
/// This test loads a survey definition (11 form steps with
/// TextChoice, SES, Text, Height, and Weight formats), builds a matching
/// result fixture with answers for every question, serializes it, feeds
/// it through the ORKTaskViewController pipeline (user does nothing),
/// re-serializes, and verifies the JSON is identical.
@MainActor
@Suite
struct ORKFullSurveyRoundTripTests {

    @Test
    func surveyRoundTrip() throws {
        let surveyURL = try surveyFileURL(named: "survey_task.json")
        let surveyData = try Data(contentsOf: surveyURL)
        let task: ORKNavigableOrderedTask = try SerializationTestHelper.deserializedFromPrettyPrintedString(
            String(data: surveyData, encoding: .utf8)!
        )

        // Build a matching result fixture with one answer per form item
        let fixture = try buildResultFixture(for: task)
        let inputJSON = try SerializationTestHelper.serializeToPrettyPrintedString(fixture)
        let deserialized: ORKTaskResult = try SerializationTestHelper.deserializedFromPrettyPrintedString(inputJSON)

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
            "A full survey's worth of answer data should survive the round-trip through ORKTaskViewController"
        )
    }

    // MARK: - Helpers

    private final class BundleAnchor {}

    /// Locates a survey JSON file in the test bundle.
    private func surveyFileURL(named fileName: String) throws -> URL {
        let bundle = Bundle(for: BundleAnchor.self)
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw NSError(domain: "ORKFullSurveyRoundTripTests", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Survey file not found in test bundle: \(fileName)"])
        }
        return url
    }

    /// Builds an ORKTaskResult fixture with one answer per form item in the task.
    /// Inspects each form item's answer format to create the appropriate result type.
    private func buildResultFixture(for task: ORKNavigableOrderedTask) throws -> ORKTaskResult {
        let taskResult = ORKTaskResult(taskIdentifier: task.identifier, taskRun: UUID(), outputDirectory: nil)
        var stepResults: [ORKStepResult] = []
        var timeOffset: TimeInterval = 0

        for step in task.steps {
            guard let formStep = step as? ORKFormStep,
                  let formItems = formStep.formItems else { continue }

            var itemResults: [ORKResult] = []
            for formItem in formItems {
                guard let answerFormat = formItem.answerFormat else { continue }
                let result = try buildQuestionResult(for: formItem, answerFormat: answerFormat, timeOffset: timeOffset)
                itemResults.append(result)
                timeOffset += 30
            }

            let stepResult = ORKStepResult(stepIdentifier: formStep.identifier, results: itemResults)
            stepResult.startDate = Date(timeIntervalSinceReferenceDate: timeOffset)
            stepResult.endDate = Date(timeIntervalSinceReferenceDate: timeOffset + 60)
            stepResults.append(stepResult)
            timeOffset += 60
        }

        taskResult.results = stepResults
        return taskResult
    }

    /// Creates the appropriate ORKQuestionResult subclass for an answer format,
    /// populated with a realistic answer value.
    private func buildQuestionResult(
        for formItem: ORKFormItem,
        answerFormat: ORKAnswerFormat,
        timeOffset: TimeInterval
    ) throws -> ORKQuestionResult {

        let result: ORKQuestionResult

        if let textChoiceFormat = answerFormat as? ORKTextChoiceAnswerFormat {
            let choiceResult = ORKChoiceQuestionResult(identifier: formItem.identifier)
            // Select the first choice value
            if let firstChoice = textChoiceFormat.textChoices.first {
                choiceResult.choiceAnswers = [firstChoice.value]
            }
            choiceResult.questionType = textChoiceFormat.questionType
            result = choiceResult

        } else if answerFormat is ORKSESAnswerFormat {
            let sesResult = ORKSESQuestionResult(identifier: formItem.identifier)
            sesResult.rungPicked = NSNumber(value: 5)
            sesResult.questionType = .SES
            result = sesResult

        } else if answerFormat is ORKTextAnswerFormat {
            let textResult = ORKTextQuestionResult(identifier: formItem.identifier)
            textResult.textAnswer = "Test"
            textResult.questionType = .text
            result = textResult

        } else if answerFormat is ORKHeightAnswerFormat {
            let numericResult = ORKNumericQuestionResult(identifier: formItem.identifier)
            numericResult.numericAnswer = NSNumber(value: 170.0)
            numericResult.unit = "cm"
            numericResult.questionType = .height
            result = numericResult

        } else if answerFormat is ORKWeightAnswerFormat {
            let numericResult = ORKNumericQuestionResult(identifier: formItem.identifier)
            numericResult.numericAnswer = NSNumber(value: 70.0)
            numericResult.unit = "kg"
            numericResult.questionType = .weight
            result = numericResult

        } else {
            throw NSError(domain: "ORKFullSurveyRoundTripTests", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Unsupported answer format: \(type(of: answerFormat))"])
        }

        result.startDate = Date(timeIntervalSinceReferenceDate: timeOffset)
        result.endDate = Date(timeIntervalSinceReferenceDate: timeOffset + 30)
        return result
    }
}
