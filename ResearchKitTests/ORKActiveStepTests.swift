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

class ORKActiveStepTests: XCTestCase {
    
    var activeStepTest: ORKActiveStep!
    
    override func setUp() {
        super.setUp()
        activeStepTest = ORKActiveStep(identifier: "Test")
    }
    
    func testIdentifier() {
        XCTAssert(activeStepTest.identifier == "Test")
    }
    
    func testStartsFinished() {
        activeStepTest.stepDuration = -1
        XCTAssertFalse(activeStepTest.startsFinished())
        
        activeStepTest.stepDuration = 2
        XCTAssertFalse(activeStepTest.startsFinished())
        
        activeStepTest.stepDuration = 0
        XCTAssert(activeStepTest.startsFinished())
    }
    
    func testHasCountdown() {
        // stepDuration > 0 && shouldShowDefaultTimer = true -> true
        activeStepTest.shouldShowDefaultTimer = true
        activeStepTest.stepDuration = -1
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.stepDuration = 0
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.stepDuration = 1
        activeStepTest.shouldShowDefaultTimer = false
        XCTAssertFalse(activeStepTest.hasCountDown())
        
        activeStepTest.shouldShowDefaultTimer = true
        XCTAssert(activeStepTest.hasCountDown())
    }
    
    func testHasTitle() {
        activeStepTest.title = ""
        XCTAssertFalse(activeStepTest.hasTitle())
        
        activeStepTest.title = nil
        XCTAssertFalse(activeStepTest.hasTitle())
        
        activeStepTest.title = "This should work"
        XCTAssert(activeStepTest.hasTitle())
    }
    
    func testHasText() {
        activeStepTest.text = ""
        XCTAssertFalse(activeStepTest.hasText())
        
        activeStepTest.text = nil
        XCTAssertFalse(activeStepTest.hasText())
        
        activeStepTest.text = "THIS SHOULD WORK"
        XCTAssert(activeStepTest.hasText())
    }
    
    func testHasVoice() {
        
        activeStepTest.spokenInstruction = nil
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = ""
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = "Do jumping jacks"
        activeStepTest.finishedSpokenInstruction = nil
        XCTAssert(activeStepTest.hasVoice())
        
        activeStepTest.spokenInstruction = nil
        activeStepTest.finishedSpokenInstruction = ""
        XCTAssertFalse(activeStepTest.hasVoice())
        
        activeStepTest.finishedSpokenInstruction = "Good job"
        XCTAssert(activeStepTest.hasVoice())
        
    }
}
