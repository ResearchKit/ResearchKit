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

import Foundation

@MainActor
final class StroopResultBuilder {

    private var startTime: Date?
    private var endTime: Date?

    private var responses: [StroopStepResponse] = []
    private let configuration: StroopStep

    private var inProgressResponse: InProgressStroopTrialResponse?

    init(configuration: StroopStep) {
        self.configuration = configuration
    }
    
    func startTask() {
        startTime = .now
        responses = []
        inProgressResponse = nil
    }
    
    func endTask() {
        endTime = .now
        inProgressResponse = nil
    }

    struct InProgressStroopTrialResponse {
        let startTime: Date
        let question: StroopTrial

        init(startTime: Date = .now, question: StroopTrial) {
            self.startTime = startTime
            self.question = question
        }
    }

    func startTrial(question: StroopTrial?) throws {
        guard let question else { return }
        guard inProgressResponse == nil else { throw StroopResultBuilder.Error.trialNotEnded }
        inProgressResponse = .init(question: question)
    }

    func completeTrial(with selectedColor: StroopColor) throws {
        guard let inProgressResponse else {
            throw StroopResultBuilder.Error.trialNotStarted
        }

        if configuration.recordResults {
            responses.append(
                StroopStepResponse(
                    identifier: "\(configuration.identifier)\(responses.count)",
                    trial: inProgressResponse.question,
                    selectedColor: selectedColor,
                    startTime: inProgressResponse.startTime,
                    endTime: .now
                )
            )
        }
        self.inProgressResponse = nil
    }
    
    func buildResult() throws -> StroopStepResult {
        guard let startTime else { throw StroopResultBuilder.Error.taskNotStarted }
        guard let endTime else { throw StroopResultBuilder.Error.taskNotEnded }

        return StroopStepResult(
            identifier: configuration.identifier,
            startTime: startTime,
            endTime: endTime,
            responses: responses
        )
    }
}

extension StroopResultBuilder {
    enum Error: LocalizedError {
        case taskNotStarted
        case trialNotStarted
        case trialNotEnded
        case taskNotEnded

        var errorDescription: String? {
            switch self {
                case .taskNotStarted:
                    "Task not started"
                case .taskNotEnded:
                    "Task not ended"
                case .trialNotStarted:
                    "Trial not started"
                case .trialNotEnded:
                    "Trial not ended"
            }
        }
    }
}
