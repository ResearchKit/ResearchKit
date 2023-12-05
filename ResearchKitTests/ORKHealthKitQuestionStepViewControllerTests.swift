/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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
import ResearchKit.Private

final class ORKHealthKitQuestionStepViewControllerTests: XCTestCase {
    var testController: ORKStepViewController!
    var step: ORKStep!
    var result: ORKResult!
    var negativeTest: Bool!
    var forwardExpectation: XCTestExpectation!
    var reverseExpectation: XCTestExpectation!
    var appearExpectation: XCTestExpectation!
    var failExpectation: XCTestExpectation!
    var recorderExpectation: XCTestExpectation!
    var testingWillExpectation: Bool!
    var utilities: TopLevelUIUtilities<ORKStepViewController>!
    private let weight = HKObjectType.quantityType(forIdentifier: .bodyMass)!

    override func setUp() {
        super.setUp()
        negativeTest = false
        testingWillExpectation = false
        
        step = ORKStep(identifier: "STEP")
        result = ORKResult(identifier: "RESULT")
        testController = ORKStepViewController(step: step, result: result)
        testController.delegate = self
        
        utilities = TopLevelUIUtilities<ORKStepViewController>()
        utilities.setupTopLevelUI(withViewController: testController)
    }
    
    func testHealthKitAnswerFormats() {
        let healthAnswerFormats = [
            ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, unit: HKUnit.gramUnit(with: .kilo), style: .decimal),
            ORKHealthKitQuantityTypeAnswerFormat(quantityType: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!, unit: HKUnit.meterUnit(with: .centi), style: .integer)
        ]
        
        for answerFormat in healthAnswerFormats {
            let healthKitStep = ORKQuestionStep(identifier: String(describing: "HealthKitStep"), title: NSLocalizedString("Some Title", comment: ""), question: "Some Question", answer: answerFormat)
            helperTestHealthKit(healthKitStep: healthKitStep)
        }
    }
    
    func helperTestHealthKit(healthKitStep: ORKQuestionStep) {
        testController = ORKQuestionStepViewController(step: healthKitStep)
        testController.delegate = self
        
        utilities = TopLevelUIUtilities<ORKStepViewController>()
        utilities.setupTopLevelUI(withViewController: testController)
        
        testController.stepDidChange()
        // Test that [self hasAnswer] && self.hasChangedAnswer are false
        XCTAssertNil((testController as! ORKQuestionStepViewController).answer())
        XCTAssertFalse((testController as! ORKQuestionStepViewController).hasChangedAnswer())
        
        // Simulating picker update to a value of 50
        (testController as! ORKQuestionStepViewController).testAnswerDidChange(to: 50.0)
        
        // Test that [self hasAnswer] has a value
        XCTAssertEqual((testController as! ORKQuestionStepViewController).answer() as! Double, 50.0)
        // && self.hasChangedAnswer is true
        XCTAssertTrue((testController as! ORKQuestionStepViewController).hasChangedAnswer())
    }
    
}

extension ORKHealthKitQuestionStepViewControllerTests: ORKStepViewControllerDelegate {
    func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
        if direction == .forward {
            forwardExpectation.fulfill()
        } else {
            reverseExpectation.fulfill()
        }
    }
    
    func stepViewControllerWillAppear(_ stepViewController: ORKStepViewController) {
        if testingWillExpectation {
            appearExpectation.fulfill()
        }
    }
    
    func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {
        // pass
    }

    func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: Error?) {
        failExpectation.fulfill()
    }
    
    func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: Error) {
        recorderExpectation.fulfill()
    }
    
    func stepViewControllerHasNextStep(_ stepViewController: ORKStepViewController) -> Bool {
        if negativeTest { return false }
        return true
    }
    
    func stepViewControllerHasPreviousStep(_ stepViewController: ORKStepViewController) -> Bool {
        if negativeTest { return false }
        return true
    }
}

