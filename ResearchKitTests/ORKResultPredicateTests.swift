/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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

import XCTest

class ORKResultPredicateTests: XCTestCase {
    
    var selector: ORKResultSelector!
    var identifier: String!
    
    override func setUp() {
        super.setUp()
        identifier = "TESTING"
        selector = ORKResultSelector(resultIdentifier: identifier)
    }
    
    func testPredicateForBooleanQuestion() {
        let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: selector, expectedAnswer: true)
        let predicateString = TestPredicateFormat.boolean
        let expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForNilQuestion() {
        let predicate = ORKResultPredicate.predicateForNilQuestionResult(with: selector)
        let predicateString = TestPredicateFormat.nilPredicate
        let expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicatedForConsent() {
        let predicate = ORKResultPredicate.predicateForConsent(with: selector, didConsent: true)
        let predicateString = TestPredicateFormat.consent
        let expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForTextQuestion() {
        let expectedString = "EXPECTED"
        let predicate = ORKResultPredicate.predicateForTextQuestionResult(with: selector, expectedString: expectedString)
        let predicateString = TestPredicateFormat.text
        let expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier, expectedString)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForScaleQuestion() {
        var predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: selector, expectedAnswer: 5)
        var predicateString = TestPredicateFormat.scale
        var expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: selector, maximumExpectedAnswerValue: 20)
        predicateString = TestPredicateFormat.scaleMax
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForScaleQuestionResult(with: selector, minimumExpectedAnswerValue: 10)
        predicateString = TestPredicateFormat.scaleMin
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForChoiceQuestion() {
        let pattern = "PATTERN"
        var predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: selector, matchingPattern: pattern)
        var predicateString = TestPredicateFormat.choice
        var expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier, pattern)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        let resultOne = ORKChoiceQuestionResult(identifier: "RESULT_ONE")
        let resultTwo = ORKChoiceQuestionResult(identifier: "RESULT_TWO")
        let results = [resultOne, resultTwo]
        
        predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: selector, expectedAnswerValue: resultOne)
        predicateString = TestPredicateFormat.choiceObject
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier, resultOne)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: selector, expectedAnswerValues: results)
        predicateString = TestPredicateFormat.choiceObjects
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier, resultOne, resultTwo)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForNumericQuestion() {
        var predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: selector, expectedAnswer: 25)
        var predicateString = TestPredicateFormat.numeric
        var expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: selector, maximumExpectedAnswerValue: 50)
        predicateString = TestPredicateFormat.numericMax
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForNumericQuestionResult(with: selector, minimumExpectedAnswerValue: 0)
        predicateString = TestPredicateFormat.numericMin
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForTimeIntervalQuestion() {
        var predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: selector, maximumExpectedAnswerValue: 100)
        var predicateString = TestPredicateFormat.timeMax
        var expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: selector, minimumExpectedAnswerValue: 16)
        predicateString = TestPredicateFormat.timeMin
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
        
        predicate = ORKResultPredicate.predicateForTimeIntervalQuestionResult(with: selector, minimumExpectedAnswerValue: 10, maximumExpectedAnswerValue: 1000)
        predicateString = TestPredicateFormat.timeMinAndMax
        expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }
    
    func testPredicateForTimeOfDayQuestion() {
        let predicate = ORKResultPredicate.predicateForTimeOfDayQuestionResult(with: selector, minimumExpectedHour: 2, minimumExpectedMinute: 30, maximumExpectedHour: 10, maximumExpectedMinute: 10)
        let predicateString = TestPredicateFormat.timeOfDay
        let expectedPredicate = NSPredicate(format: predicateString.rawValue, identifier, identifier)
        XCTAssert(predicate.isEqual(expectedPredicate))
    }

    func testPredicateForTimeOfDayQuestionComparesHourAndMinuteTogether() {
        // Regression test for https://github.com/ResearchKit/ResearchKit/issues/1391:
        // 6:06 must fall within 6:00-7:00 even though its minute (6) is
        // greater than the maximum minute (0).
        let predicate = ORKResultPredicate.predicateForTimeOfDayQuestionResult(
            with: selector,
            minimumExpectedHour: 6,
            minimumExpectedMinute: 0,
            maximumExpectedHour: 7,
            maximumExpectedMinute: 0
        )

        XCTAssertTrue(evaluate(predicate, hour: 6, minute: 0), "The minimum bound should be inclusive")
        XCTAssertTrue(evaluate(predicate, hour: 6, minute: 6))
        XCTAssertTrue(evaluate(predicate, hour: 6, minute: 59))
        XCTAssertTrue(evaluate(predicate, hour: 7, minute: 0), "The maximum bound should be inclusive")

        XCTAssertFalse(evaluate(predicate, hour: 5, minute: 59))
        XCTAssertFalse(evaluate(predicate, hour: 7, minute: 1))
        XCTAssertFalse(evaluate(predicate, hour: 18, minute: 30))
    }

    func testPredicateForTimeOfDayQuestionWithMinutesInBothBounds() {
        let predicate = ORKResultPredicate.predicateForTimeOfDayQuestionResult(
            with: selector,
            minimumExpectedHour: 2,
            minimumExpectedMinute: 30,
            maximumExpectedHour: 10,
            maximumExpectedMinute: 10
        )

        XCTAssertTrue(evaluate(predicate, hour: 2, minute: 30))
        XCTAssertTrue(evaluate(predicate, hour: 3, minute: 15), "Minute below the minimum minute, hour past it")
        XCTAssertTrue(evaluate(predicate, hour: 9, minute: 45), "Minute above the maximum minute, hour before it")
        XCTAssertTrue(evaluate(predicate, hour: 10, minute: 10))

        XCTAssertFalse(evaluate(predicate, hour: 2, minute: 29))
        XCTAssertFalse(evaluate(predicate, hour: 10, minute: 11))
        XCTAssertFalse(evaluate(predicate, hour: 1, minute: 45))
    }

    func testPredicateForTimeOfDayQuestionDoesNotMatchSkippedQuestion() {
        let predicate = ORKResultPredicate.predicateForTimeOfDayQuestionResult(
            with: selector,
            minimumExpectedHour: 0,
            minimumExpectedMinute: 0,
            maximumExpectedHour: 23,
            maximumExpectedMinute: 59
        )

        XCTAssertFalse(evaluate(predicate, timeOfDay: nil))
    }

    private func evaluate(_ predicate: NSPredicate, hour: Int, minute: Int) -> Bool {
        return evaluate(predicate, timeOfDay: DateComponents(hour: hour, minute: minute))
    }

    /// Evaluates `predicate` against a task result that holds a single time-of-day answer for `identifier`.
    private func evaluate(_ predicate: NSPredicate, timeOfDay: DateComponents?) -> Bool {
        let questionResult = ORKTimeOfDayQuestionResult(identifier: identifier)
        questionResult.dateComponentsAnswer = timeOfDay
        let stepResult = ORKStepResult(stepIdentifier: identifier, results: [questionResult])
        let taskResult = ORKTaskResult(taskIdentifier: "TaskIdentifier", taskRun: UUID(), outputDirectory: nil)
        taskResult.results = [stepResult]
        return predicate.evaluate(with: [taskResult], substitutionVariables: [
            ORKResultPredicateTaskIdentifierVariableName: taskResult.identifier
        ])
    }
}
