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

import Foundation
import SwiftUI
import ResearchKitUI

extension StroopStep: ORKStepViewProvider {
    public func makeView(for step: Self) -> some View {
        StroopStepView(step: step)
    }
}

extension StroopStep: ORKClassicStepConvertible {
    public init(classicType: ORKSwiftStroopStep) {
        do {
            try self.init(
                identifier: classicType.identifier,
                colorChoices: classicType.colorChoices,
                trialCount: classicType.numberOfAttempts,
                interTrialMaskType: classicType.interTrialMaskType,
                congruentFrequency: classicType.congruentFrequency,
                incongruentFrequency: classicType.incongruentFrequency,
                neutralFrequency: classicType.neutralFrequency,
                minimumInterTrialDelay: classicType.minimumInterTrialDelay,
                maximumInterTrialDelay: classicType.maximumInterTrialDelay
            )
        } catch {
            ORKLogError("Error converting \(type(of: classicType)) to \(type(of: self)): \(error)")
            self = .init(withoutValidation: classicType.identifier)
        }
    }
}

extension ORKSwiftStroopStep: ORKClassicStep, ORKStepViewControllerProviding {}

extension StroopStepResult: ORKStepResultLegacyProvider {
    public var legacyResult: ORKStepResult {
        let result = ORKStepResult(
            stepIdentifier: identifier,
            results: responses.map { ORKStroopResult(response: $0, startTimestamp: start) })
        result.startDate = start
        result.endDate = end
        return result
    }
}
