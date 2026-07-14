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

/// The response context for a Stroop active task.
public struct StroopStepResult: Codable, Hashable, Sendable, Equatable, StepResult {
    
    /// A unique identifier corresponding to the results of a given task.
    public let identifier: String
    
    /// A timestamp when the task begins.
    public let start: Date
    
    /// A timestamp when the task ends.
    public let end: Date
    
    /// A collection representing the user's responses to the questions of the task.
    public let responses: [StroopStepResponse]

    /// Instantiates a new ``StroopTaskResult`` with the provided context.
    /// - Parameters:
    ///    - identifier: A unique identifier associated with the results.
    ///    - startTime: The time that the task started.
    ///    - endTime: The time that the task ended.
    ///    - responses: A collection of the user's responses to each prompt of the task.
    public init(identifier: String, startTime: Date, endTime: Date, responses: [StroopStepResponse]) {
        self.identifier = identifier
        self.start = startTime
        self.end = endTime
        self.responses = responses
    }
}

extension ORKStroopResult {
    convenience init(response: StroopStepResponse, startTimestamp: Date) {
        self.init(identifier: response.identifier)
        self.startTime = response.startTime.timeIntervalSince(startTimestamp)
        self.endTime = response.endTime.timeIntervalSince(startTimestamp)
        self.color = response.trialColor.description
        self.colorSelected = response.selectedColor.description
        self.text = response.trialWord.description
    }
}
