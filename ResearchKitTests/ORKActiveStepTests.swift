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
import ResearchKit
import ResearchKitActiveTask
import ResearchKitActiveTask_Private
import Testing

@Suite
struct ORKActiveStepTests {

    let step: ORKActiveStep

    init() {
        step = ORKActiveStep(identifier: "Test")
    }

    @Test
    func identifier() {
        #expect(step.identifier == "Test")
    }

    @Test
    func startsFinished() {
        step.stepDuration = -1
        #expect(!step.startsFinished())

        step.stepDuration = 2
        #expect(!step.startsFinished())

        step.stepDuration = 0
        #expect(step.startsFinished())
    }

    @Test
    func hasCountdown() {
        // stepDuration > 0 && shouldShowDefaultTimer = true -> true
        step.shouldShowDefaultTimer = true
        step.stepDuration = -1
        #expect(!step.hasCountDown())

        step.stepDuration = 0
        #expect(!step.hasCountDown())

        step.stepDuration = 1
        step.shouldShowDefaultTimer = false
        #expect(!step.hasCountDown())

        step.shouldShowDefaultTimer = true
        #expect(step.hasCountDown())
    }

    @Test
    func hasTitle() {
        step.title = ""
        #expect(!step.hasTitle())

        step.title = nil
        #expect(!step.hasTitle())

        step.title = "This should work"
        #expect(step.hasTitle())
    }

    @Test
    func hasText() {
        step.text = ""
        #expect(!step.hasText())

        step.text = nil
        #expect(!step.hasText())

        step.text = "THIS SHOULD WORK"
        #expect(step.hasText())
    }

    @Test
    func hasVoice() {
        step.spokenInstruction = nil
        #expect(!step.hasVoice())

        step.spokenInstruction = ""
        #expect(!step.hasVoice())

        step.spokenInstruction = "Do jumping jacks"
        step.finishedSpokenInstruction = nil
        #expect(step.hasVoice())

        step.spokenInstruction = nil
        step.finishedSpokenInstruction = ""
        #expect(!step.hasVoice())

        step.finishedSpokenInstruction = "Good job"
        #expect(step.hasVoice())
    }
}

// MARK: - Step subclass shouldShowDefaultTimer defaults

@Suite
struct ORKActiveStepSubclassDefaultsTests {

    @Test
    func baseClassDefaultsToShowTimer() {
        let step = ORKActiveStep(identifier: "base")
        #expect(step.shouldShowDefaultTimer == true,
                "ORKActiveStep should default shouldShowDefaultTimer to YES")
    }

    @Test
    func toneAudiometryStepDefaultsToNoTimer() {
        let step = ORKToneAudiometryStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func towerOfHanoiStepDefaultsToNoTimer() {
        let step = ORKTowerOfHanoiStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func speechRecognitionStepDefaultsToNoTimer() {
        let step = ORKSpeechRecognitionStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func reactionTimeStepDefaultsToNoTimer() {
        let step = ORKReactionTimeStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func normalizedReactionTimeStepDefaultsToNoTimer() {
        let step = ORKNormalizedReactionTimeStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func touchAnywhereStepDefaultsToNoTimer() {
        let step = ORKTouchAnywhereStep(identifier: "id", instructionText: "tap")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func rangeOfMotionStepDefaultsToNoTimer() {
        let step = ORKRangeOfMotionStep(identifier: "id", limbOption: .left)
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func shoulderRangeOfMotionStepDefaultsToNoTimer() {
        let step = ORKShoulderRangeOfMotionStep(identifier: "id", limbOption: .left)
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func spatialSpanMemoryStepDefaultsToNoTimer() {
        let step = ORKSpatialSpanMemoryStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func speechInNoiseStepDefaultsToNoTimer() {
        let step = ORKSpeechInNoiseStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func accuracyStroopStepDefaultsToNoTimer() {
        let step = ORKAccuracyStroopStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }

    @Test
    func model3DStepDefaultsToNoTimer() {
        let step = ORK3DModelStep(identifier: "id")
        #expect(step.shouldShowDefaultTimer == false)
    }
}

// MARK: - ORKActiveStepViewController timerView behavior

@MainActor
@Suite
struct ORKActiveStepViewControllerTimerTests {

    /// A step with stepDuration > 0 and shouldShowDefaultTimer = YES should
    /// produce a non-nil timerView after view load.
    @Test
    func timerViewSetWhenHasCountDown() {
        let step = ORKActiveStep(identifier: "countdown")
        step.stepDuration = 30
        step.shouldShowDefaultTimer = true

        let vc = ORKActiveStepViewController(step: step)
        _ = vc.view

        let timerView = vc.activeStepView?.timerView
        #expect(timerView != nil,
                "timerView should be set when hasCountDown is true")
    }

    /// A step with shouldShowDefaultTimer = NO should leave timerView nil.
    @Test
    func timerViewNilWhenShouldShowDefaultTimerFalse() {
        let step = ORKActiveStep(identifier: "notimer")
        step.stepDuration = 30
        step.shouldShowDefaultTimer = false

        let vc = ORKActiveStepViewController(step: step)
        _ = vc.view

        let timerView = vc.activeStepView?.timerView
        #expect(timerView == nil,
                "timerView should be nil when shouldShowDefaultTimer is false")
    }

    /// A step with stepDuration = 0 should leave timerView nil even if
    /// shouldShowDefaultTimer is true (hasCountDown requires stepDuration > 0).
    @Test
    func timerViewNilWhenStepDurationZero() {
        let step = ORKActiveStep(identifier: "zeroduration")
        step.stepDuration = 0
        step.shouldShowDefaultTimer = true

        let vc = ORKActiveStepViewController(step: step)
        _ = vc.view

        let timerView = vc.activeStepView?.timerView
        #expect(timerView == nil,
                "timerView should be nil when stepDuration is 0")
    }

    /// Setting activeCustomView after view load should NOT clear the timerView —
    /// both slots must coexist independently.
    @Test
    func timerViewSurvivesSettingActiveCustomView() {
        let step = ORKActiveStep(identifier: "both")
        step.stepDuration = 30
        step.shouldShowDefaultTimer = true

        let vc = ORKActiveStepViewController(step: step)
        _ = vc.view

        // Simulate a subclass setting its own custom content view.
        vc.activeStepView?.activeCustomView = ORKActiveStepCustomView()

        let timerView = vc.activeStepView?.timerView
        #expect(timerView != nil,
                "timerView should survive a subsequent activeCustomView assignment")
        #expect(vc.activeStepView?.activeCustomView != nil,
                "activeCustomView should be set")
    }
}
