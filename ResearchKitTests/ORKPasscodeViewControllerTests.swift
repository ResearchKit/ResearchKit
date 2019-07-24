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
@testable import ResearchKit
import ResearchKit.Private

class ORKPasscodeViewControllerTests: XCTestCase {
    
    var testController: ORKPasscodeViewController!
    var resultController: ORKPasscodeStepViewController?
    var asyncExpectation: XCTestExpectation?
    
    func testPasscodeAuthenticationView() {
        testController = ORKPasscodeViewController.passcodeAuthenticationViewController(withText: "TEST", delegate: self)
        XCTAssertEqual(testController.navigationBar.isTranslucent, false)
        XCTAssert(testController.navigationBar.shadowImage != nil)
        
        
        guard let stepViewController = testController.viewControllers.first as? ORKPasscodeStepViewController,
            let step = stepViewController.step as? ORKPasscodeStep else {
                XCTFail("failed to cast step as ORKPascodeStep")
                return
        }
        
        XCTAssertEqual(step.identifier, "passcode_step")
        XCTAssertEqual(step.passcodeFlow, ORKPasscodeFlow.authenticate)
        XCTAssertEqual(step.passcodeType, ORKPasscodeType.type4Digit)
        XCTAssertEqual(step.text, "TEST")
    }
    
    func testPasscodeEditView() {
        testController = ORKPasscodeViewController.passcodeEditingViewController(withText: "TEST", delegate: self, passcodeType: .type6Digit)
        
        guard let stepViewController = testController.viewControllers.first as? ORKPasscodeStepViewController,
            let step = stepViewController.step as? ORKPasscodeStep else {
                XCTFail("failed to cast step as ORKPascodeStep")
                return
        }
        
        XCTAssertEqual(step.passcodeFlow, ORKPasscodeFlow.edit)
        XCTAssertEqual(step.passcodeType, ORKPasscodeType.type6Digit)
    }
    
    func testPasscodeViewControllerDelegateCalls() {
        testController = ORKPasscodeViewController.passcodeEditingViewController(withText: "TEST", delegate: self, passcodeType: .type4Digit)
        
        guard let stepController = testController.viewControllers.first as? ORKPasscodeStepViewController else {
            XCTFail("unable to cast view controller as ORKPasscodeStepViewController")
            return
        }
        
        var testExpectation = expectation(description: "ORKPasscodeViewController calls the delegate as the result of the user authenticating or finishing editing")
        self.asyncExpectation = testExpectation
        
        stepController.passcodeDelegate?.passcodeViewControllerDidFinish(withSuccess: stepController)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationWithTimeout error: \(error)")
            }
        }
        
        testExpectation = expectation(description: "ORKPasscodeViewController calls the delegate as the result of the user cancelling")
        self.asyncExpectation = testExpectation
        
        stepController.passcodeDelegate?.passcodeViewControllerDidCancel?(stepController)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationWithTimeout error: \(error)")
            }
        }
        
        testExpectation = expectation(description: "ORKPasscodeViewController calls the delegate as the result of failed authentication")
        self.asyncExpectation = testExpectation
        
        stepController.passcodeDelegate?.passcodeViewControllerDidFailAuthentication(stepController)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationWithTimeout error: \(error)")
            }
        }
        
        
        testExpectation = expectation(description: "ORKPasscodeViewController calls the delegate as the result of user forgetting passcode")
        self.asyncExpectation = testExpectation
        
        stepController.passcodeDelegate?.passcodeViewControllerForgotPasscodeTapped?(stepController)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail("waitForExpectationWithTimeout error: \(error)")
            }
        }
    }
}

extension ORKPasscodeViewControllerTests: ORKPasscodeDelegate {
    func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        guard let expectation = asyncExpectation else {
            XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        expectation.fulfill()
    }
    
    func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        guard let expectation = asyncExpectation else {
            XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        expectation.fulfill()
    }
    
    func passcodeViewControllerDidCancel(_ viewController: UIViewController) {
        guard let expectation = asyncExpectation else {
            XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        expectation.fulfill()
    }
    
    func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
        guard let expectation = asyncExpectation else {
            XCTFail("Delegate was not setup correctly. Missing XCTExpectation reference")
            return
        }
        expectation.fulfill()
    }
}
