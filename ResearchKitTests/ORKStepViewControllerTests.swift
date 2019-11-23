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
import ResearchKit

class ORKStepViewControllerTests: XCTestCase {
    
    var testController: ORKStepViewController!
    var step: ORKStep!
    var result: ORKResult!
    var negativeTest: Bool!
    var forwardExpectation: XCTestExpectation!
    var reverseExpectation: XCTestExpectation!
    var testExpectation: XCTestExpectation!
    var appearExpectation: XCTestExpectation!
    var failExpectation: XCTestExpectation!
    var recorderExpectation: XCTestExpectation!
    var testingWillExpectation: Bool!
    var utilities: TopLevelUIUtilities<ORKStepViewController>!
    
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
    
    func testAttributes() {
        let backButton = UIBarButtonItem(title: "BACK", style: .plain, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "CANCEL", style: .plain, target: nil, action: nil)
        let countinueString = "COUNTINUE"
        let learnMoreString = "LEARN MORE"
        let skipString = "SKIP"
        
        testController.continueButtonTitle = countinueString
        testController.learnMoreButtonTitle = learnMoreString
        testController.skipButtonTitle = skipString
        testController.backButtonItem = backButton
        testController.cancelButtonItem = cancelButton
        XCTAssertEqual(testController.continueButtonTitle, countinueString)
        XCTAssertEqual(testController.skipButtonTitle, skipString)
        XCTAssertEqual(testController.backButtonItem, backButton)
        XCTAssertEqual(testController.cancelButtonItem, cancelButton)
    }
    
    func testiPhoneViewDidLoad() {
        let step = ORKStep(identifier: "STEP")
        testController = ORKStepViewController(step: step)
        testController.viewDidLoad()
        XCTAssertEqual(testController.view.backgroundColor?.cgColor, ORKColor(ORKBackgroundColorKey).cgColor)
    }
    
    func testViewWillAppear() {
        testingWillExpectation = true
        appearExpectation = expectation(description: "ORKStepViewController notifies delegate its status(Will Appear)")
        
        testController.viewWillAppear(false)
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        XCTAssertEqual(testController.continueButtonItem, testController.internalContinueButtonItem)
        XCTAssertEqual(testController.backButtonItem, nil)
        
        testController.delegate = nil
        testController.viewWillAppear(false)

        XCTAssertEqual(testController.continueButtonItem, testController.internalDoneButtonItem)
        XCTAssertEqual(testController.backButtonItem, nil)
        XCTAssertEqual(testController.hasBeenPresented, true)
        XCTAssert(testController.presentedDate != nil)
        XCTAssertNil(testController.dismissedDate)
    }
    
        
    func testShowValidityAlertWithTitle() {

        var completed = testController.showValidityAlert(withMessage: "HELLO")
        XCTAssert(completed, "Alert should display")
        
        completed = testController.showValidityAlert(withTitle: "", message: "")
        XCTAssertFalse(completed, "Alert should not display")
        
        _ = testController.showValidityAlert(withMessage: "HELLO")
        completed = testController.showValidityAlert(withMessage: "HELLO")
        XCTAssertFalse(completed, "Alert should not display")
        
        testController.viewDidDisappear(true)
        completed = testController.showValidityAlert(withMessage: "HELLO")
        XCTAssertFalse(completed, "Alert should not display")
    }

    func testNavigation() {
        negativeTest = false
        XCTAssertEqual(testController.hasPreviousStep(), true)
        XCTAssertEqual(testController.hasNextStep(), true)
        
        negativeTest = true
        XCTAssertEqual(testController.hasPreviousStep(), false)
        XCTAssertEqual(testController.hasNextStep(), false)
    }
    
    func testAddResult() {
        let resultOne = ORKResult(identifier: "RESULT ONE")
        testController.addResult(resultOne)
        
        XCTAssertEqual(testController.result?.results, [resultOne])
        
        let resultTwo = ORKResult(identifier: "RESULT TWO")
        testController.addResult(resultTwo)
        XCTAssertEqual(testController.result?.results, [resultOne, resultTwo])
        
        testController.addResult(resultOne)
        XCTAssertEqual(testController.result?.results, [resultOne, resultOne, resultTwo])
    }
    
    func testGoForward() {
        forwardExpectation = expectation(description: "ORKStepViewController notifies delegate with Forward Direction")
        testController.goForward()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testGoBackward() {
        reverseExpectation = expectation(description: "ORKStepViewController notifies delegate with Reverse Direction")
        testController.goBackward()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    func testResultDidChangeDelegate() {
        testExpectation = expectation(description: "ORKStepViewController notifies delegate that results changed")
        testController.notifyDelegateOnResultChange()
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    
    func testSkip() {
        
        forwardExpectation = expectation(description: "ORKStepViewController notifies delegate with Forward Direction")
        
        guard let skipButton = testController.skipButtonItem else {
            XCTFail("failed to unwrap the skipButtonItem")
            return
        }
        
        _ = skipButton.target?.perform(skipButton.action, with: testController.view)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        let reviewStep = ORKReviewStep(identifier: "REVIEW STEP")
        testController.parentReviewStep = reviewStep
        _ = skipButton.target?.perform(skipButton.action, with: testController.view)
        
        guard (testController.presentedViewController as? UIAlertController) != nil else {
            XCTFail("alert was not presented")
            return
        }
    }
    
    func testViewDelegates() {
        failExpectation = expectation(description: "ORKStepViewController notifies delegate it did fail")
        testController.delegate?.stepViewControllerDidFail(testController, withError: nil)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        recorderExpectation = expectation(description: "ORKStepViewController notifies delegate that it's recorder failed")
        let recorder = ORKRecorder(identifier: "RECORDER", step: nil, outputDirectory: nil)
        testController!.delegate!.stepViewController(testController, recorder: recorder, didFailWithError: TestError.recorderError)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
}

extension ORKStepViewControllerTests: ORKStepViewControllerDelegate {
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
        testExpectation.fulfill()
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

enum TestError: Error {
    case recorderError
}
