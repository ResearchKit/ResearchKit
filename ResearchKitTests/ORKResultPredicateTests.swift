/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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
}
