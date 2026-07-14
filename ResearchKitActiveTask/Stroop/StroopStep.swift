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

/// A ``StroopStep`` specifies the configuration and context for a Stroop step. It drives the task
/// by containing the state that determines how the task is executed (e.g. number of trials,
/// frequency of congruent vs. incongruent vs. neutral samples, etc.).
///
/// To initiate a ``StroopStepView`` with a custom configuration, first initialize a ``StroopStep`` and
/// set the properties you wish to customize.
///
/// ```swift
/// let view = StroopStepView(step: .init(withoutValidation: "identifier"))
///
/// ```
///
public struct StroopStep: Sendable {
    
    /// A meaningful identifier associated with the results of the task.
    public private(set) var identifier: String
    
    /// A collection of ``StroopColor``s that specifies the possible options for text/color combinations in a trial.
    public var colorChoices: [StroopColor]

    /// The number of trials delivered over the course of the task.
    public var trialCount: Int
    
    /// If true, data will be recorded in the results of the trial. Otherwise, an empty result will be generated.
    public var recordResults: Bool
    
    /// The type of mask to show between trials.
    public var interTrialMaskType: StroopInterTrialMask
    
    /// A percentage value in [0, 1] that determines the frequency of congruent trials.
    public var congruentFrequency: Double

    /// A percentage value in [0, 1] that determines the frequency of incongruent trials.
    public var incongruentFrequency: Double

    /// A percentage value in [0, 1] that determines the frequency of neutral trials.
    public var neutralFrequency: Double

    /// The lower bound of the time interval between when the current trial vanishes and the next trial appears in seconds.
    ///
    /// `minimumInterTrialDelay` must be at least ``StroopTask.ParamBounds.minInterTrialDelay`` seconds
    /// and at most `maximumInterTrialDelay`.
    ///
    /// When the two are equal, the inter-trial delay will be constant and deterministic.
    public var minimumInterTrialDelay: TimeInterval

    /// The upper bound of the time interval between when the current trial vanishes and the next trial appears in seconds.
    ///
    /// `maximumInterTrialDelay` must be at least `minimumInterTrialDelay` and at most ``StroopTask.ParamBounds.maxInterTrialDelay`` seconds.
    ///
    /// When the two are equal, the inter-trial delay will be constant and deterministic.
    public var maximumInterTrialDelay: TimeInterval
    
    /// Initializes a new ``StroopTask`` with the provided context and a potentially non-deterministic inter-trial interval.
    /// - Parameters:
    ///    - identifier: A unique identifier associated with the results of the task.
    ///    - colorChoices: The possible colors that the trial content is drawn from. Defaults to `.red`, `.green`, `.yellow`, and `.blue`.
    ///    - trialCount: The number of trials included in the task. Defaults to 10.
    ///    - recordResults: If true, data will be recorded in the results of the trial. Otherwise, an empty result will be generated. Defaults to true.
    ///    - interTrialMaskType: The type of mask to show between trials. Defaults to `.none`.
    ///    - congruentFrequency: A percentage value in [0, 1] that determines the frequency of congruent trials. Defaults to 0.50.
    ///    - incongruentFrequency: A percentage value in [0, 1] that determines the frequency of incongruent trials. Defaults to 0.50.
    ///    - neutralFrequency: A percentage value in [0, 1] that determines the frequency of neutral trials. Defaults to 0.00.
    ///    - minimumInterTrialDelay: The lower bound of the time interval between when the current trial vanishes and the next trial appears in seconds. Defaults to 0.5.
    ///    - maximumInterTrialDelay: The upper bound of the time interval between when the current trial vanishes and the next trial appears in seconds. Defaults to 0.5.
    public init(
        identifier: String,
        colorChoices: [StroopColor] = ParamDefaults.colorChoices,
        trialCount: Int = ParamDefaults.trialCount,
        recordResults: Bool = ParamDefaults.recordResults,
        interTrialMaskType: StroopInterTrialMask = ParamDefaults.interTrialMaskType,
        congruentFrequency: Double = ParamDefaults.congruentFrequency,
        incongruentFrequency: Double = ParamDefaults.incongruentFrequency,
        neutralFrequency: Double = ParamDefaults.neutralFrequency,
        minimumInterTrialDelay: TimeInterval = ParamDefaults.minimumInterTrialDelay,
        maximumInterTrialDelay: TimeInterval = ParamDefaults.maximumInterTrialDelay
    ) throws {
        self.init(
            withoutValidation: identifier,
            colorChoices: colorChoices,
            trialCount: trialCount,
            recordResults: recordResults,
            interTrialMaskType: interTrialMaskType,
            congruentFrequency: congruentFrequency,
            incongruentFrequency: incongruentFrequency,
            neutralFrequency: neutralFrequency,
            minimumInterTrialDelay: minimumInterTrialDelay,
            maximumInterTrialDelay: maximumInterTrialDelay
        )
        try self.validateParameters()
    }

    public init(withoutValidation identifier: String,
                colorChoices: [StroopColor] = ParamDefaults.colorChoices,
                trialCount: Int = ParamDefaults.trialCount,
                recordResults: Bool = ParamDefaults.recordResults,
                interTrialMaskType: StroopInterTrialMask = ParamDefaults.interTrialMaskType,
                congruentFrequency: Double = ParamDefaults.congruentFrequency,
                incongruentFrequency: Double = ParamDefaults.incongruentFrequency,
                neutralFrequency: Double = ParamDefaults.neutralFrequency,
                minimumInterTrialDelay: TimeInterval = ParamDefaults.minimumInterTrialDelay,
                maximumInterTrialDelay: TimeInterval = ParamDefaults.maximumInterTrialDelay
    ) {
        self.identifier = identifier
        self.colorChoices = colorChoices
        self.trialCount = trialCount
        self.recordResults = recordResults
        self.interTrialMaskType = interTrialMaskType
        self.congruentFrequency = congruentFrequency
        self.incongruentFrequency = incongruentFrequency
        self.neutralFrequency = neutralFrequency
        self.minimumInterTrialDelay = minimumInterTrialDelay
        self.maximumInterTrialDelay = maximumInterTrialDelay
    }

    /// Valid parameter boundaries.
    private struct ParamBounds {
        static let minimumNumberOfTrials: Int = 10
        static let minimumNumberOfColorChoices: Int = 2
        static let minimumInterTrialDelay: TimeInterval = 0.25      // Delays in seconds.
        static let maximumInterTrialDelay: TimeInterval = 1.5
    }
    
    /// Default values for the Stroop task configuration.
    public struct ParamDefaults {
        public static let colorChoices: [StroopColor] = [.red, .green, .yellow, .blue]
        public static let trialCount: Int = 10
        public static let recordResults: Bool = true
        public static let interTrialMaskType: StroopInterTrialMask = .none
        public static let congruentFrequency: Double = 0.5
        public static let incongruentFrequency: Double = 0.5
        public static let neutralFrequency: Double = 0.0
        public static let interTrialDelay: TimeInterval = 0.5
        public static let minimumInterTrialDelay: TimeInterval = interTrialDelay
        public static let maximumInterTrialDelay: TimeInterval = interTrialDelay
    }
}

extension StroopStep: ORKStepIdentifiable {}

extension StroopStep: ORKStepValidatable {
    public func validateParameters() throws {
        // Validation to ensure frequencies are in [0, 1] and sum to 1.
        guard congruentFrequency <= 1.0 && congruentFrequency >= 0.0 else {
            throw InvalidParameterError.invalidFrequencyDistribution
        }

        guard incongruentFrequency <= 1.0 && incongruentFrequency >= 0.0 else {
            throw InvalidParameterError.invalidFrequencyDistribution
        }

        guard neutralFrequency <= 1.0 && neutralFrequency >= 0.0 else {
            throw InvalidParameterError.invalidFrequencyDistribution
        }

        let totalFrequency = congruentFrequency + incongruentFrequency + neutralFrequency
        guard abs(totalFrequency - 1.0) < 0.0001 else {
            throw InvalidParameterError.invalidFrequencyDistribution
        }

        // Make sure the number of trials specified is high enough.
        guard trialCount >= ParamBounds.minimumNumberOfTrials else {
            throw InvalidParameterError.numberOfTrialsBelowMinimum
        }

        // Make sure that there are at least enough color choices to have an incongruent case.
        guard colorChoices.count >= ParamBounds.minimumNumberOfColorChoices else {
            throw InvalidParameterError.numberOfColorChoicesBelowMinimum
        }

        // Make sure that the bounds of the inter-trial delay make a valid range.
        guard minimumInterTrialDelay <= maximumInterTrialDelay else {
            throw InvalidParameterError.interTrialDelayRangeInvalid
        }

        // Make sure the bounds of the inter-trial delay are within a reasonable range.
        guard minimumInterTrialDelay >= ParamBounds.minimumInterTrialDelay else {
            throw InvalidParameterError.interTrialDelayOutOfBounds
        }

        guard maximumInterTrialDelay <= ParamBounds.maximumInterTrialDelay else {
            throw InvalidParameterError.interTrialDelayOutOfBounds
        }
    }
}

extension StroopStep: Hashable {}

extension StroopStep {

    /// An error representing an invalid parameter in a ``StroopTask`` configuration.
    public enum InvalidParameterError: LocalizedError {
        /// The specified number of trials fell outside the permitted bounds.
        case numberOfTrialsBelowMinimum

        /// The specified number of color choices fell outside the permitted bounds.
        case numberOfColorChoicesBelowMinimum

        /// The specified inter-trial delay fell outside the permitted bounds.
        case interTrialDelayOutOfBounds

        /// The specified inter-trial delay range had invalid bounds.
        case interTrialDelayRangeInvalid

        /// The specified trial type frequencies do not sum to 1 or any of the frequencies are outside the bounds of [0, 1].
        case invalidFrequencyDistribution

        public var errorDescription: String? {
            MainActor.assumeIsolated {
                switch self {
                    case .numberOfTrialsBelowMinimum:
                        return "The number of trials must be at least \(ParamBounds.minimumNumberOfTrials)."
                    case .numberOfColorChoicesBelowMinimum:
                        return "The number of color choices must be at least \(ParamBounds.minimumNumberOfColorChoices)."
                    case .interTrialDelayOutOfBounds:
                        return "The inter-trial delay must be between \(ParamBounds.minimumInterTrialDelay) and \(ParamBounds.maximumInterTrialDelay) seconds."
                    case .interTrialDelayRangeInvalid:
                        return "The lower bound of the inter-trial delay range must be less than or equal to the upper bound."
                    case .invalidFrequencyDistribution:
                        return "The specified trial type frequencies do not sum to 1 or any of the frequencies are outside the bounds of [0, 1]."
                }
            }
        }
    }
}
