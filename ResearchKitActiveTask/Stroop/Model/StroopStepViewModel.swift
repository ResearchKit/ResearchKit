/*
 Copyright (c) 2025, Apple Inc. All rights reserved.

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

import SwiftUI

@MainActor
@Observable
final class StroopStepViewModel {

    typealias TaskResult = Result<StroopStepResult, Swift.Error>

    private var state: State = .readyToStart

    var taskResult: TaskResult {
        state.result
    }

    var isTaskComplete: Bool {
        state.isTaskComplete
    }

    var isWaitingForNextTrial: Bool {
        state.isWaitingForNextTrial || state.isTrialComplete
    }

    var currentTrial: StroopTrial? {
        state.trialInProgress
    }

    private(set) var previousSelectionWasCorrect: Bool = false

    let configuration: StroopStep

    private let resultBuilder: StroopResultBuilder
    private var trialIterator: StroopTrialIterator

    private var interTrialTask: Task<Void, Never>? {
        willSet { interTrialTask?.cancel() }
    }

    init(configuration: StroopStep) {
        self.configuration = configuration

        resultBuilder = StroopResultBuilder(configuration: configuration)

        let trialsBuilder = StroopTrialsGenerator(configuration: configuration)

        do {
            trialIterator = .init(trials: try trialsBuilder.generate())
            transition(to: .trialsStarted)
        } catch {
            trialIterator = .init()
            state = .taskComplete(.failure(error))
        }
    }

    func selectColor(_ selectedColor: StroopColor) {
        guard let currentTrial = self.state.trialInProgress else { return }
        self.previousSelectionWasCorrect = selectedColor == currentTrial.color
        self.transition(to: .trialComplete(selectedColor))
    }

    private func transition(to newState: State) {
        do {
            state = newState
            switch newState {
                case .readyToStart:
                    interTrialTask = nil

                case .trialsStarted:
                    resultBuilder.startTask()
                    prepareNextTrial()

                case .trialInProgress(let currentTrial):
                    try resultBuilder.startTrial(question: currentTrial)

                case .waitingForNextTrial:
                    interTrialTask = Task { await transitionToNextTrial(afterDelay: intertrialDelay) }

                case .trialComplete(let selectedColor):
                    try self.resultBuilder.completeTrial(with: selectedColor)
                    prepareNextTrial()

                case .trialsComplete:
                    completeTask()

                case .taskComplete:
                    interTrialTask = nil
            }
        } catch {
            state = .taskComplete(.failure(error))
            interTrialTask = nil
        }
    }

    private nonisolated var intertrialDelay: TimeInterval {
        .random(in: configuration.minimumInterTrialDelay...configuration.maximumInterTrialDelay)
    }

    private func transitionToNextTrial(afterDelay delay: TimeInterval) async {
        do {
            try await Task.sleep(for: .seconds(delay))
            try Task.checkCancellation()

            self.startNextTrial()

        } catch let error as CancellationError {
            ORKLogDebug("Transition to Next Trial Cancelled: \(error)")
        } catch {
            transition(to: .taskComplete(.failure(error)))
        }
    }

    private func prepareNextTrial() {
        let state: State = if let trial = trialIterator.next() {
            .waitingForNextTrial(trial)
        } else {
            .trialsComplete
        }
        transition(to: state)
    }

    private func startNextTrial() {
        if case let .waitingForNextTrial(trial) = state {
            transition(to: .trialInProgress(trial))
        } else if state.areAllTrialsComplete {
            completeTask()
        }
    }

    private func completeTask() {
        resultBuilder.endTask()
        let result = Result(catching: { try resultBuilder.buildResult() })
        transition(to: .taskComplete(result))
    }
}

extension View {
    func handleStroopStepCompletion(viewModel: StroopStepViewModel) -> some View {
        modifier(OnStroopStepCompletion(viewModel: viewModel))
    }
}

struct OnStroopStepCompletion: ViewModifier {

    @Environment(\.stepCompletion)
    private var onStepCompletion

    var viewModel: StroopStepViewModel

    func body(content: Content) -> some View {
        content
            .onChange(of: viewModel.isTaskComplete) { oldValue, newValue in
                guard newValue else { return }
                onStepCompletion(.init { try viewModel.taskResult.get() })
            }
    }
}

extension StroopStepViewModel {
    enum Error: LocalizedError {
        case invalidState(StroopStepViewModel.State)

        public var errorDescription: String? {
            switch self {
                case .invalidState(let state):
                    return "Invalid state: \(state)"
            }
        }
    }
}

extension StroopStepViewModel {
    enum State {
        case readyToStart
        case trialsStarted
        case trialInProgress(StroopTrial)
        case trialComplete(StroopColor)
        case waitingForNextTrial(StroopTrial)
        case trialsComplete
        case taskComplete(TaskResult)

        var isTaskComplete: Bool {
            switch self {
                case .taskComplete: true
                default: false
            }
        }

        var isTrialComplete: Bool {
            switch self {
                case .trialComplete: true
                default: false
            }
        }

        var isWaitingForNextTrial: Bool {
            switch self {
                case .waitingForNextTrial: true
                default: false
            }
        }

        var areAllTrialsComplete: Bool {
            switch self {
                case .trialsComplete: true
                default: false
            }
        }

        var result: TaskResult {
            if case let .taskComplete(result) = self {
                result
            } else {
                .failure(StroopStepViewModel.Error.invalidState(self))
            }
        }

        var isReadyToStart: Bool {
            switch self {
                case .readyToStart: true
                default: false
            }
        }

        var isTrialInProgress: Bool {
            trialInProgress != nil
        }

        var trialInProgress: StroopTrial? {
            switch self {
                case let .trialInProgress(trial): trial
                default: nil
            }
        }
    }
}
