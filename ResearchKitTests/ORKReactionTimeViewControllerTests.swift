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

import Testing
import ResearchKitActiveTask
import ResearchKitActiveTask_Private

@Suite("ORKReactionTimeViewController result recording")
@MainActor
struct ORKReactionTimeViewControllerTests {

    private func makeVC(numberOfAttempts: Int = 3) -> ORKReactionTimeViewController {
        let step = ORKReactionTimeStep(identifier: "reactionTime")
        step.numberOfAttempts = numberOfAttempts
        step.minimumStimulusInterval = 1.0
        step.maximumStimulusInterval = 3.0
        step.thresholdAcceleration = 0.5
        step.timeout = 10.0
        let vc = ORKReactionTimeViewController(step: step)
        _ = vc.view
        return vc
    }

    // KVC access to private Obj-C ivars; strings must match _validResult and _stimulusTimestamp in ORKReactionTimeViewController.
    private func simulateAttempt(on vc: ORKReactionTimeViewController, valid: Bool, fileResults: [ORKFileResult] = []) {
        vc.setValue(valid, forKey: "validResult") // must match _validResult in ORKReactionTimeViewController.m
        let recorder = ORKRecorder(identifier: "motion", step: nil)
        vc.recorder(recorder, didCompleteWith: fileResults)
    }

    @Test("Failed attempt produces a result")
    func failedAttemptProducesResult() {
        let vc = makeVC()
        simulateAttempt(on: vc, valid: false)
        #expect(vc.result?.results?.count == 1)
    }

    @Test("Failed attempt attaches fileResults to its result")
    func failedAttemptAttachesFileResults() {
        let vc = makeVC()
        let fileResult = ORKFileResult(identifier: "deviceMotion")
        simulateAttempt(on: vc, valid: false, fileResults: [fileResult])
        let reactionResult = vc.result?.results?.first as? ORKReactionTimeResult
        #expect(reactionResult?.fileResults.contains(fileResult) == true)
    }

    @Test("Successful attempt is marked isSuccessful")
    func successfulAttemptIsMarkedSuccessful() {
        let vc = makeVC()
        simulateAttempt(on: vc, valid: true)
        let reactionResult = vc.result?.results?.first as? ORKReactionTimeResult
        #expect(reactionResult?.isSuccessful == true)
    }

    @Test("Failed attempt is marked not isSuccessful")
    func failedAttemptIsMarkedNotSuccessful() {
        let vc = makeVC()
        simulateAttempt(on: vc, valid: false)
        let reactionResult = vc.result?.results?.first as? ORKReactionTimeResult
        #expect(reactionResult?.isSuccessful == false)
    }

    #if targetEnvironment(simulator)
    @Test("Simulator timeout produces a result")
    func simulatorTimeoutProducesResult() {
        let vc = makeVC()
        vc.perform(NSSelectorFromString("timeoutTimerDidFire"))
        #expect(vc.result?.results?.count == 1)
    }
    #endif

    @Test("Pre-stimulus shake uses timestamp zero, not a stale value from a previous attempt")
    func preStimulusShakeHasZeroTimestamp() {
        let vc = makeVC(numberOfAttempts: 2)
        // Inject a non-zero stimulus timestamp as if left over from a previous attempt.
        vc.setValue(1234.5, forKey: "stimulusTimestamp") // must match _stimulusTimestamp in ORKReactionTimeViewController.m
        simulateAttempt(on: vc, valid: true) // first attempt: records and should reset _stimulusTimestamp
        simulateAttempt(on: vc, valid: false) // second attempt: pre-stimulus shake
        let secondResult = vc.result?.results?[1] as? ORKReactionTimeResult
        #expect(secondResult?.timestamp == 0)
    }
}

