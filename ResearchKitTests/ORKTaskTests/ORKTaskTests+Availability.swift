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

import ResearchKit
import Testing

// MARK: - Helpers

private class UnavailableStep: ORKStep {
    override var isStepAvailable: Bool { false }
}

private func makeTaskResult(visitedStepIdentifiers: [String] = []) -> ORKTaskResult {
    let result = ORKTaskResult(taskIdentifier: "task", taskRun: UUID(), outputDirectory: nil)
    result.results = visitedStepIdentifiers.map { ORKStepResult(stepIdentifier: $0, results: []) }
    return result
}

// MARK: - Step Availability Tests (ORKOrderedTask)

@Suite("Step Availability Tests (ORKOrderedTask)")
struct ORKOrderedTaskStepAvailabilityTests {

    @Test
    func skipsUnavailableStepForward() {
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = UnavailableStep(identifier: "B")
        let stepC = ORKInstructionStep(identifier: "C")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC])

        #expect(task.step(after: stepA, with: makeTaskResult()) === stepC)
    }

    @Test
    func skipsUnavailableStepBackward() {
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = UnavailableStep(identifier: "B")
        let stepC = ORKInstructionStep(identifier: "C")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC])

        #expect(task.step(before: stepC, with: makeTaskResult()) === stepA)
    }

    @Test
    func skipsConsecutiveUnavailableSteps() {
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = UnavailableStep(identifier: "B")
        let stepC = UnavailableStep(identifier: "C")
        let stepD = ORKInstructionStep(identifier: "D")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC, stepD])

        #expect(task.step(after: stepA, with: makeTaskResult()) === stepD)
        #expect(task.step(before: stepD, with: makeTaskResult()) === stepA)
    }

    @Test
    func skipsFirstStep() {
        let stepA = UnavailableStep(identifier: "A")
        let stepB = ORKInstructionStep(identifier: "B")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB])

        #expect(task.step(after: nil, with: makeTaskResult()) === stepB)
    }

    @Test
    func skipsLastStep() {
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = UnavailableStep(identifier: "B")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB])

        #expect(task.step(after: stepA, with: makeTaskResult()) == nil)
    }

    @Test
    func allStepsUnavailable() {
        let stepA = UnavailableStep(identifier: "A")
        let stepB = UnavailableStep(identifier: "B")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB])

        #expect(task.step(after: nil, with: makeTaskResult()) == nil)
    }

    @Test
    func requiredStepIdentifiers() {
        let stepA = ORKInstructionStep(identifier: "A")
        stepA.requiredStepIdentifiers = ["B"]
        let stepB = UnavailableStep(identifier: "B")
        let stepC = ORKInstructionStep(identifier: "C")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC])

        // stepA depends on stepB which is unavailable, so stepA should also be skipped
        #expect(task.step(after: nil, with: makeTaskResult()) === stepC)
    }

    @Test
    func availableStepsUnchanged() {
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = ORKInstructionStep(identifier: "B")
        let stepC = ORKInstructionStep(identifier: "C")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC])
        let result = makeTaskResult()

        #expect(task.step(after: nil, with: result) === stepA)
        #expect(task.step(after: stepA, with: result) === stepB)
        #expect(task.step(after: stepB, with: result) === stepC)
        #expect(task.step(after: stepC, with: result) == nil)

        #expect(task.step(before: stepA, with: result) == nil)
        #expect(task.step(before: stepB, with: result) === stepA)
        #expect(task.step(before: stepC, with: result) === stepB)
    }

    @Test
    func progressExcludesUnavailableSteps() {
        // 5 steps: A(instruction, first) → B(available) → C(unavailable) → D(available) → E(instruction, last)
        // First/last instruction steps are excluded from progress by default.
        // C is unavailable, so progress should only count B and D.
        let stepA = ORKInstructionStep(identifier: "A")
        let stepB = ORKStep(identifier: "B")
        let stepC = UnavailableStep(identifier: "C")
        let stepD = ORKStep(identifier: "D")
        let stepE = ORKInstructionStep(identifier: "E")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC, stepD, stepE])
        let result = makeTaskResult()

        let progressB = task.progress(ofCurrentStep: stepB, with: result)
        let progressD = task.progress(ofCurrentStep: stepD, with: result)

        // B should be step 0, D should be step 1; C is excluded
        #expect(progressB.current == 0)
        #expect(progressD.current == 1)
        #expect(progressB.total == 2)
        #expect(progressD.total == 2)
    }
}

// MARK: - Step Availability Tests (ORKNavigableOrderedTask)

@Suite("Step Availability Tests (ORKNavigableOrderedTask)")
struct ORKNavigableOrderedTaskStepAvailabilityTests {

    // Shared setup: A(available) → B(unavailable) → C(available).
    // Swift Testing instantiates the suite struct fresh for each @Test, so
    // per-test mutations (e.g. adding a nav rule) don't affect other tests.
    private let stepA = ORKInstructionStep(identifier: "A")
    private let stepB = UnavailableStep(identifier: "B")
    private let stepC = ORKInstructionStep(identifier: "C")
    let task: ORKNavigableOrderedTask

    init() {
        task = ORKNavigableOrderedTask(identifier: "task", steps: [stepA, stepB, stepC])
    }

    @Test
    func skipsUnavailableStepWithNavRule() {
        // Add a navigation rule that directs from A to B (which is unavailable)
        let rule = ORKDirectStepNavigationRule(destinationStepIdentifier: "B")
        task.setNavigationRule(rule, forTriggerStepIdentifier: "A")

        // stepB is unavailable, so the nav rule path should skip it and return stepC
        #expect(task.step(after: stepA, with: makeTaskResult()) === stepC)
    }

    @Test
    func skipsUnavailableStepWithoutNavRule() {
        // No navigation rules — falls through to super (ORKOrderedTask) path
        #expect(task.step(after: stepA, with: makeTaskResult()) === stepC)
    }

    @Test
    func backwardSkipsUnavailable() {
        // Simulate result history: stepA was visited, then stepC (stepB was skipped, so no result for it)
        let taskResult = makeTaskResult(visitedStepIdentifiers: ["A", "C"])

        // Going back from C should land on A (not B, since B was never visited)
        #expect(task.step(before: stepC, with: taskResult) === stepA)
    }

    @Test
    func transitiveRequiredStepIdentifiers() {
        // A is unavailable, B depends on A, C depends on B — all three should be skipped
        let stepA = UnavailableStep(identifier: "A")
        let stepB = ORKInstructionStep(identifier: "B")
        stepB.requiredStepIdentifiers = ["A"]
        let stepC = ORKInstructionStep(identifier: "C")
        stepC.requiredStepIdentifiers = ["B"]
        let stepD = ORKInstructionStep(identifier: "D")
        let task = ORKOrderedTask(identifier: "task", steps: [stepA, stepB, stepC, stepD])

        // A is unavailable, B depends on A, C depends on B — first available step should be D
        #expect(task.step(after: nil, with: makeTaskResult()) === stepD)
    }
}
