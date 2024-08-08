//
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

import ResearchKit
import ResearchKitUI
import XCTest

enum ORKIdentifier: String {
    case instructionStep1,
        questionStep1,
        questionStep2,
        questionStep3,
        questionStep4,
        completionStep1,
        orderedTask1
}

class FauxTaskViewController: NSObject, ORKTaskViewControllerDelegate {

    var expectation: XCTestExpectation?

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskFinishReason, error: Error?) {
        if reason == .completed {
            expectation?.fulfill()
        }
    }

    func taskViewControllerSupportsSaveAndRestore(_ taskViewController: ORKTaskViewController) -> Bool {
        return true
    }
}

final class ORKTaskViewControllerTests: XCTestCase {

    var taskCompletionExpectation: XCTestExpectation?

    var options = [
        ORKTextChoice(
            text: "Banana",
            value: 1 as NSCopying & NSSecureCoding & NSObjectProtocol
        ),
        ORKTextChoice(
            text: "Lychee",
            value: 2 as NSCopying & NSSecureCoding & NSObjectProtocol
        ),
        ORKTextChoice(
            text: "Kiwi",
            value: 3 as NSCopying & NSSecureCoding & NSObjectProtocol
        ),
        ORKTextChoice(
            text: "Orange",
            value: 4 as NSCopying & NSSecureCoding & NSObjectProtocol
        ),
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()

        taskCompletionExpectation = nil

        taskCompletionExpectation = XCTestExpectation(description: "TaskCompletion")

    }

    func createTask() -> ORKOrderedTask {
        // Step 1
        let instructionStep1 = ORKInstructionStep(identifier: ORKIdentifier.instructionStep1.rawValue)

        // Step 2
        let q1AnswerFormat = ORKNumericAnswerFormat(style: .integer)

        let questionStep1 = ORKQuestionStep(
            identifier: ORKIdentifier.questionStep1.rawValue,
            title: "First Question Title",
            question: "What is your age?",
            answer: q1AnswerFormat
        )

        // Step 3
        let q2AnswerFormat = ORKTextAnswerFormat()

        let questionStep2 = ORKQuestionStep(
            identifier: ORKIdentifier.questionStep2.rawValue,
            title: "Title for Second Question",
            question: "What is your name?",
            answer: q2AnswerFormat
        )

        // Step 4
        let q3AnswerFormat = ORKTextChoiceAnswerFormat(
            style: .singleChoice,
            textChoices: options
        )

        let questionStep3 = ORKQuestionStep(
            identifier: ORKIdentifier.questionStep3.rawValue,
            title: "Question 3",
            question: "What is your favorite fruit?",
            answer: q3AnswerFormat
        )

        // Step 5
        let q4AnswerFormat = ORKScaleAnswerFormat(
            maximumValue: 10,
            minimumValue: 1,
            defaultValue: 5,
            step: 1
        )

        let questionStep4 = ORKQuestionStep(
            identifier: ORKIdentifier.questionStep4.rawValue,
            title: "Question 4",
            question: "How many fingers do you have?",
            answer: q4AnswerFormat
        )

        // Step 6
        let completionStep1 = ORKCompletionStep(
            identifier: ORKIdentifier.completionStep1.rawValue
        )

        let task = ORKOrderedTask(
            identifier: ORKIdentifier.orderedTask1.rawValue,
            steps: [
                instructionStep1,
                questionStep1,
                questionStep2,
                questionStep3,
                questionStep4,
                completionStep1,
            ]
        )
        return task
    }

    func testTaskSerialization() {

        let task = createTask()
        let taskRunUUID = UUID()
        let initialTaskViewController = ORKTaskViewController(
            task: task,
            taskRun: taskRunUUID
        )
        let delegate = FauxTaskViewController()
        delegate.expectation = taskCompletionExpectation
        initialTaskViewController.delegate = delegate

        mockPresentTaskViewController(taskViewController: initialTaskViewController)

        wait(for: [taskCompletionExpectation!], timeout: 2.0)

        guard let restoredData = initialTaskViewController.restorationData else {
            XCTFail("Unable to get restoration data for task")
            return
        }

        let restoredTaskViewController = ORKTaskViewController(
            task: task,
            restorationData: restoredData,
            delegate: FauxTaskViewController(),
            error: nil
        )

        let initialResult = initialTaskViewController.result
        let restoredResult = restoredTaskViewController.result

        XCTAssertEqual(initialTaskViewController.task?.identifier, restoredTaskViewController.task?.identifier)
        XCTAssertEqual(initialResult.results?.count, restoredResult.results?.count)

        initialResult.results?.enumerated().forEach({ index, stepResult in
            guard
                let resCount = restoredResult.results?.count,
                index < resCount,
                let stepResult = stepResult as? ORKStepResult,
                let restoredStepResult = restoredResult.results?[index] as? ORKStepResult
            else {
                XCTFail("Unable to get same result after restoring with data")
                return
            }

            XCTAssertEqual(stepResult.identifier, restoredStepResult.identifier)

            switch stepResult.identifier {

            case ORKIdentifier.instructionStep1.rawValue, ORKIdentifier.completionStep1.rawValue:
                break
            case ORKIdentifier.questionStep1.rawValue:
                guard
                    let numericResult = stepResult.results?.first as? ORKNumericQuestionResult,
                    let restoredNumericResult = restoredStepResult.results?.first as? ORKNumericQuestionResult
                else {
                    XCTFail("Incorrect step result format")
                    return
                }
                XCTAssertEqual(numericResult.numericAnswer, restoredNumericResult.numericAnswer)

            case ORKIdentifier.questionStep2.rawValue:
                guard
                    let textResult = stepResult.results?.first as? ORKTextQuestionResult,
                    let restoredTextResult = restoredStepResult.results?.first as? ORKTextQuestionResult
                else {
                    XCTFail("Incorrect step result format")
                    return
                }
                XCTAssertEqual(textResult.textAnswer, restoredTextResult.textAnswer)

            case ORKIdentifier.questionStep3.rawValue:
                guard
                    let choiceResult = stepResult.results?.first as? ORKChoiceQuestionResult,
                    let restoredChoiceResult = restoredStepResult.results?.first as? ORKChoiceQuestionResult
                else {
                    XCTFail("Incorrect step result format")
                    return
                }
                XCTAssertEqual(choiceResult.answer as? Int, restoredChoiceResult.answer as? Int)

            case ORKIdentifier.questionStep4.rawValue:
                guard
                    let scaleResult = stepResult.results?.first as? ORKScaleQuestionResult,
                    let restoredScaleResult = restoredStepResult.results?.first as? ORKScaleQuestionResult
                else {
                    XCTFail("Incorrect step result format")
                    return
                }
                XCTAssertEqual(scaleResult.scaleAnswer, restoredScaleResult.scaleAnswer)
            default:
                XCTFail("Unidentifiable step identifier")
            }
        })
    }

    func mockPresentTaskViewController(taskViewController: ORKTaskViewController) {
        guard
            let orderedTask = taskViewController.task as? ORKOrderedTask,
            orderedTask.steps.isEmpty == false
        else {
            XCTFail("Incorrect number of steps in task")
            return
        }

        for step in orderedTask.steps {
            taskViewController.flipToPage(withIdentifier: step.identifier, forward: true, animated: false)

            guard
                let currentStepViewController = taskViewController.currentStepViewController
            else {
                XCTFail("Unable to find next StepViewController")
                return
            }

            switch step.identifier {
            case ORKIdentifier.instructionStep1.rawValue, ORKIdentifier.completionStep1.rawValue:
                break
            case ORKIdentifier.questionStep1.rawValue:
                let result = ORKNumericQuestionResult(identifier: step.identifier)
                result.questionType = .integer
                let answer = 31 as NSNumber
                result.numericAnswer = answer
                currentStepViewController.addResult(result)

            case ORKIdentifier.questionStep2.rawValue:
                let result = ORKTextQuestionResult(identifier: step.identifier)
                result.questionType = .text
                let answer = "SAMPLETEXT"
                result.textAnswer = answer
                currentStepViewController.addResult(result)

            case ORKIdentifier.questionStep3.rawValue:

                let result = ORKChoiceQuestionResult(identifier: step.identifier)
                result.questionType = .singleChoice
                guard
                    let answer = options.last?.value
                else {
                    return
                }
                result.choiceAnswers = [answer]
                currentStepViewController.addResult(result)

            case ORKIdentifier.questionStep4.rawValue:
                let result = ORKScaleQuestionResult(identifier: step.identifier)
                result.questionType = .scale
                let answer = 6 as NSNumber
                result.scaleAnswer = answer
                currentStepViewController.addResult(result)

            default:
                XCTFail("Unidentifiable step identifier")
            }

            taskViewController.stepViewController(currentStepViewController, didFinishWith: .forward)
        }
    }
}
