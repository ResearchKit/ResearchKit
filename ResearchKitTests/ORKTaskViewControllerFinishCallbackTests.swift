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
import ResearchKit
import ResearchKitUI

// MARK: - Test infrastructure

fileprivate final class FinishSpyDelegate: NSObject, ORKTaskViewControllerDelegate {
    private(set) var finishCallCount = 0

    func taskViewController(
        _ taskViewController: ORKTaskViewController,
        didFinishWith reason: ORKTaskFinishReason,
        error: Error?
    ) {
        finishCallCount += 1
        // Deliberately not dismissing, to simulate a delegate that shows an error
        // and leaves the task on screen.
    }
}

// MARK: - Tests

@Suite("ORKTaskViewController finish callback")
@MainActor
struct ORKTaskViewControllerFinishCallbackTests {
    private let taskVC: ORKTaskViewController
    private let spy: FinishSpyDelegate

    init() {
        let task = ORKOrderedTask(identifier: "task", steps: [ORKInstructionStep(identifier: "step")])
        let taskVC = ORKTaskViewController(task: task, taskRun: nil)
        let spy = FinishSpyDelegate()
        taskVC.delegate = spy
        
        self.taskVC = taskVC
        self.spy = spy
    }
    
    @Test("Same-tick duplicate call does not fire the delegate twice")
    func sameTickDuplicateIsBlocked() {
        // Two calls in the same synchronous sequence (same run loop pass).
        taskVC.finish(with: .completed, error: nil)
        taskVC.finish(with: .completed, error: nil)

        #expect(spy.finishCallCount == 1)
    }
    
    @Test(
        "After non-dismissal, the delegate is called again when the user retries",
        arguments: [ORKTaskFinishReason.completed, .discarded, .saved, .failed, .earlyTermination]
    )
    func delegateIsCalledAgainAfterNonDismissal(reason: ORKTaskFinishReason) async {
        taskVC.finish(with: reason, error: nil)

        // Yield past the re-arm dispatch so the flag resets before the second call.
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            DispatchQueue.main.async { continuation.resume() }
        }

        taskVC.finish(with: reason, error: nil)

        #expect(spy.finishCallCount == 2)
    }
}
