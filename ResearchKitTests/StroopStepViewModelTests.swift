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
@testable import ResearchKitActiveTask

extension Tag {
    @Tag static var Stroop: Self
}

private func makeConfiguration(
    trialCount: Int = 10,
    minimumInterTrialDelay: TimeInterval = 0.25,
    maximumInterTrialDelay: TimeInterval = 0.25
) throws -> StroopStep {
    try StroopStep(
        identifier: "testStroop",
        trialCount: trialCount,
        minimumInterTrialDelay: minimumInterTrialDelay,
        maximumInterTrialDelay: maximumInterTrialDelay
    )
}

@MainActor
private func makeViewModel(
    trialCount: Int = 10,
    minimumInterTrialDelay: TimeInterval = 0.25,
    maximumInterTrialDelay: TimeInterval = 0.25
) throws -> StroopStepViewModel {
    let config = try makeConfiguration(
        trialCount: trialCount,
        minimumInterTrialDelay: minimumInterTrialDelay,
        maximumInterTrialDelay: maximumInterTrialDelay
    )
    return StroopStepViewModel(configuration: config)
}
/// Use this to await async state transitions driven by `stateDidChange`.
private func waitForCondition(
    _ description: String? = nil,
    timeout: Duration = .seconds(5),
    pollingInterval: Duration = .milliseconds(10),
    condition: @MainActor () -> Bool
) async throws {
    let deadline = ContinuousClock.now + timeout
    while ContinuousClock.now < deadline {
        if await condition() { return }
        try await Task.sleep(for: pollingInterval)
    }
    #expect(Bool(false), "Timed out waiting for condition: \(description)")
}

// MARK: - Initialization

@Suite(.tags(.Stroop))
struct StroopStepViewModelInitialization {

    @Test @MainActor
    func `has a current trial after initialization`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        #expect(viewModel.currentTrial != nil)
    }

    @Test @MainActor
    func `is not complete after initialization`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        #expect(viewModel.isTaskComplete == false)
    }

    @Test @MainActor
    func `is not waiting for next trial after initialization`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        #expect(viewModel.isWaitingForNextTrial == false)
    }

    @Test @MainActor
    func `previousSelectionWasCorrect is false after initialization`() throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        #expect(viewModel.previousSelectionWasCorrect == false)
    }

    @Test @MainActor
    func `configuration is preserved`() throws {
        let config = try makeConfiguration(trialCount: 12)
        let viewModel = StroopStepViewModel(configuration: config)

        #expect(viewModel.configuration.trialCount == 12)
        #expect(viewModel.configuration.identifier == "testStroop")
    }

    @Test @MainActor
    func `invalid configuration completes with failure`() async throws {
        let config = StroopStep(
            withoutValidation: "invalidStroop",
            colorChoices: [.red],  // below minimum of 2
            trialCount: 10
        )
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.isTaskComplete }

        #expect(viewModel.isTaskComplete == true)
        #expect(viewModel.currentTrial == nil)

        switch viewModel.taskResult {
            case .failure: break // expected
            case .success: #expect(Bool(false), "Expected failure for invalid configuration")
        }
    }
}

// MARK: - Color Selection

@Suite(.tags(.Stroop))
struct StroopStepViewModelColorSelection {

    @Test @MainActor
    func `selecting a color transitions away from current trial`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        let trial = try #require(viewModel.currentTrial)
        viewModel.selectColor(trial.color)

        // After debounce, should transition to waiting/next trial
        try await waitForCondition { viewModel.currentTrial != trial }
    }

    @Test @MainActor
    func `selecting the correct color sets previousSelectionWasCorrect to true`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        let correctColor = try #require(viewModel.currentTrial?.color)
        viewModel.selectColor(correctColor)

        try await waitForCondition { viewModel.previousSelectionWasCorrect }

        #expect(viewModel.previousSelectionWasCorrect == true)
    }

    @Test @MainActor
    func `selecting the wrong color sets previousSelectionWasCorrect to false`() async throws {
        let config = try makeConfiguration()
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        let correctColor = try #require(viewModel.currentTrial?.color)
        let wrongColor = StroopColor.allCases.first(where: { $0 != correctColor }) ?? .red
        viewModel.selectColor(wrongColor)

        try await waitForCondition { viewModel.currentTrial == nil || viewModel.currentTrial?.color != correctColor }

        #expect(viewModel.previousSelectionWasCorrect == false)
    }

    @Test @MainActor
    func `selecting a color when no trial is in progress does nothing`() async throws {
        let config = StroopStep(
            withoutValidation: "invalidStroop",
            colorChoices: [.red],  // invalid — will fail immediately
            trialCount: 10
        )
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.isTaskComplete }

        viewModel.selectColor(.red)

        // Should still be in task complete state
        #expect(viewModel.isTaskComplete == true)
        #expect(viewModel.previousSelectionWasCorrect == false)
    }
}

// MARK: - Trial Progression

@Suite(.tags(.Stroop))
struct StroopStepViewModelTrialProgression {

    @Test @MainActor
    func `advances to next trial after selection and delay`() async throws {
        let config = try makeConfiguration(minimumInterTrialDelay: 0.25, maximumInterTrialDelay: 0.25)
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        let firstTrial = viewModel.currentTrial
        let color = try #require(firstTrial?.color)
        viewModel.selectColor(color)

        // Wait for inter-trial delay + debounce to pass and next trial to appear
        try await waitForCondition(timeout: .seconds(3)) {
            viewModel.currentTrial != nil && viewModel.currentTrial != firstTrial
        }

        #expect(viewModel.currentTrial != nil)
        #expect(viewModel.isTaskComplete == false)
    }

    @Test @MainActor
    func `enters waiting state between trials`() async throws {
        let config = try makeConfiguration(minimumInterTrialDelay: 0.5, maximumInterTrialDelay: 0.5)
        let viewModel = StroopStepViewModel(configuration: config)

        try await waitForCondition { viewModel.currentTrial != nil }

        let color = try #require(viewModel.currentTrial?.color)
        viewModel.selectColor(color)

        // Should enter waiting state after debounce
        try await waitForCondition { viewModel.isWaitingForNextTrial }

        #expect(viewModel.isWaitingForNextTrial == true)
        #expect(viewModel.currentTrial == nil)
    }
}

// MARK: - Task Completion

@Suite(.tags(.Stroop))
struct StroopStepViewModelTaskCompletion {

    @Test @MainActor
    func `completes after all trials are answered`() async throws {
        let viewModel = try makeViewModel(
            trialCount: 10,
            minimumInterTrialDelay: 0.25,
            maximumInterTrialDelay: 0.25
        )

        for _ in 0..<10 {
            try await waitForCondition("trial in progress") { viewModel.currentTrial != nil }
            let color = try #require(StroopColor.allCases.randomElement())
            viewModel.selectColor(color)

            try await waitForCondition("next trial or completion", timeout: .seconds(3)) {
                viewModel.currentTrial != nil || viewModel.isTaskComplete
            }
        }

        try await waitForCondition(condition: { viewModel.isTaskComplete })

        //These are implied true by the wait conditions, but just to be sure
        #expect(viewModel.isTaskComplete == true)
        #expect(viewModel.currentTrial == nil)

        switch viewModel.taskResult {
            case .success(let result):
                #expect(result.identifier == "testStroop")
                #expect(result.responses.count == 10)
            case .failure(let error):
                #expect(Bool(false), "Expected success but got: \(error)")
        }
    }

    @Test @MainActor
    func `result has valid start and end times`() async throws {
        let startTime = Date.now
        let viewModel = try makeViewModel(
            trialCount: 10,
            minimumInterTrialDelay: 0.25,
            maximumInterTrialDelay: 0.25
        )

        for _ in 0..<10 {
            try await waitForCondition("trial in progress") { viewModel.currentTrial != nil }
            viewModel.selectColor(try #require(StroopColor.allCases.randomElement()))

            try await waitForCondition("next trial or completion", timeout: .seconds(3)) {
                viewModel.currentTrial != nil || viewModel.isTaskComplete
            }
        }

        try await waitForCondition("task is complete", timeout: .seconds(10)) { viewModel.isTaskComplete }

        let result = try viewModel.taskResult.get()
        #expect(result.start >= startTime)
        #expect(result.end >= result.start)
    }
}
