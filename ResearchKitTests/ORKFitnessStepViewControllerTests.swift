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

import Foundation
import Testing
import ResearchKitActiveTask
import ResearchKitActiveTask_Private

@Suite("ORKFitnessStepViewController goForward behavior")
@MainActor
struct ORKFitnessStepViewControllerTests {

    private let delegate = MockStepViewControllerDelegate()

    private func makeStep(optional: Bool) -> ORKFitnessStep {
        let step = ORKFitnessStep(identifier: "testFitnessStep")
        step.stepDuration = 10.0
        step.isOptional = optional
        return step
    }

    @Test("When finished, goForward navigates forward without presenting an alert")
    func goForwardWhenFinished() async {
        let step = makeStep(optional: true)
        let vc = ORKFitnessStepViewController(step: step)
        vc.delegate = delegate

        _ = vc.view
        vc.setValue(true, forKey: "finished")
        vc.goForward()

        #expect(delegate.forwardCount == 1)
        #expect(vc.presentedViewController == nil)
    }

    @Test("When not optional and not finished, goForward navigates forward without presenting an alert")
    func goForwardWhenNotOptional() async {
        let step = makeStep(optional: false)
        let vc = ORKFitnessStepViewController(step: step)
        vc.delegate = delegate

        _ = vc.view
        vc.setValue(false, forKey: "finished")
        vc.goForward()

        #expect(delegate.forwardCount == 1)
        #expect(vc.presentedViewController == nil)
    }

    @Test("When optional and not finished, goForward presents a skip confirmation alert")
    func goForwardWhenOptionalAndNotFinishedPresentsAlert() async throws {
        let step = makeStep(optional: true)
        let vc = ORKFitnessStepViewController(step: step)
        vc.delegate = delegate

        let window = UIWindow()
        window.isHidden = false
        window.rootViewController = vc
        vc.viewDidAppear(false)
        vc.setValue(false, forKey: "finished")
        vc.goForward()

        // Allow the presentation animation to complete
        try await Task.sleep(for: .milliseconds(500))

        #expect(delegate.forwardCount == 0)
        #expect(vc.presentedViewController is UIAlertController)
    }
}

private final class MockStepViewControllerDelegate: NSObject, ORKStepViewControllerDelegate {
    var forwardCount = 0

    func stepViewController(_ stepViewController: ORKStepViewController, didFinishWith direction: ORKStepViewControllerNavigationDirection) {
        if direction == .forward {
            forwardCount += 1
        }
    }

    func stepViewControllerWillAppear(_ stepViewController: ORKStepViewController) {}
    func stepViewControllerResultDidChange(_ stepViewController: ORKStepViewController) {}
    func stepViewControllerDidFail(_ stepViewController: ORKStepViewController, withError error: (any Error)?) {}
    func stepViewController(_ stepViewController: ORKStepViewController, recorder: ORKRecorder, didFailWithError error: any Error) {}
    func stepViewControllerHasNextStep(_ stepViewController: ORKStepViewController) -> Bool { true }
    func stepViewControllerHasPreviousStep(_ stepViewController: ORKStepViewController) -> Bool { false }
}
