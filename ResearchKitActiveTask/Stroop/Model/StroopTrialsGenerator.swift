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


struct StroopTrialsGenerator {
    private let configuration: StroopStep

    init(configuration: StroopStep) {
        self.configuration = configuration
    }

    // Generates a randomized array of `StroopTrial`s that conforms to the
    // counter-balancing specified by the trial's configuration.
    func generate() throws -> [StroopTrial] {
        var generatedTrials: [StroopTrial] = []
        
        // Decide how many of each trial type to build based on configured frequency.
        let congruentCount = Int(Double(configuration.trialCount) * configuration.congruentFrequency)
        let incongruentCount = Int(Double(configuration.trialCount) * configuration.incongruentFrequency)
        let neutralCount = Int(Double(configuration.trialCount) * configuration.neutralFrequency)
        
        let trialCounts: [(type: StroopTrialType, count: Int)] = [
            (.congruous, congruentCount),
            (.incongruous, incongruentCount),
            (.neutral, neutralCount)
        ]
        
        // Build a balanced collection of each trial type.
        for (trialType, trialTypeCount) in trialCounts {
            let balancedTrials = try generate(count: trialTypeCount, type: trialType)
            generatedTrials.append(contentsOf: balancedTrials)
        }
        
        // Due to rounding errors, we might have less trials than trial count, so fill in the rest by drawing
        // random types from a distribution determined by the configured frequencies.
        //
        // Because the rounding errors come from rounding down from a decimal count of each type, the deficit
        // will be less than the number of trial types.
        let trialCountDeficit = configuration.trialCount - generatedTrials.count
        for _ in 0..<trialCountDeficit {
            let randomDraw = Double.random(in: 0...1)

            let newTrialType: StroopTrialType = if randomDraw < configuration.congruentFrequency {
                .congruous
            } else if randomDraw < configuration.congruentFrequency + configuration.incongruentFrequency {
                .incongruous
            } else {
                .neutral
            }
            
            let newTrial = try makeRandomTrial(type: newTrialType)
            generatedTrials.append(newTrial)
        }
        
        return generatedTrials.shuffled()
    }
    
    // Builds a collection of `count` trials of the provided type.
    //
    // For congruous and neutral types, the resulting collection will have each color in `colorChoices` be
    // represented as equally as possible.
    //
    // For incongruous types, the resulting collection will have each color in `colorChoices` be the correct
    // answer as equally as possible. Within each color, each color in `colorChoices` will be the mismatched word
    // as equally as possible.
    private func generate(count: Int, type: StroopTrialType) throws -> [StroopTrial] {
        switch type {
        case .congruous:
             try balancedCongruousTrials(count: count)
        case .incongruous:
            try balancedIncongruousTrials(count: count)
        case .neutral:
            try balancedNeutralTrials(count: count)
        }
    }
    
    private func balancedCongruousTrials(count: Int) throws -> [StroopTrial] {
        let colorCycle = configuration.colorChoices.shuffled().circular()

        func congruousNextTrial(from colorCycle: CircularArrayIterator<StroopColor>) -> (Int) throws -> StroopTrial {
            { _ in
                guard let color = colorCycle.next() else { throw Error.insufficientColorChoices }
                return StroopTrial(word: color, color: color, type: .congruous)
            }
        }

        return try (0..<count).map(congruousNextTrial(from: colorCycle))
    }
    
    private func balancedIncongruousTrials(count: Int) throws -> [StroopTrial] {
        let colorCycle = configuration.colorChoices.shuffled().circular()
        let differentColorCyclesMap = Dictionary(uniqueKeysWithValues: configuration.colorChoices.map { colorChoice in
            let differentColors = configuration.colorChoices.filter { $0 != colorChoice }
            return (colorChoice, differentColors.shuffled().circular())
        })

        func incongruousNextTrial(from colorCycle: CircularArrayIterator<StroopColor>) -> (_: Int) throws -> StroopTrial {
            { _ in
                guard let color = colorCycle.next()
                else { throw Error.insufficientColorChoices }

                guard let colorMap = differentColorCyclesMap[color]
                else { throw Error.colorMapNotConfigured }

                guard let mappedColor = colorMap.next()
                else { throw Error.insufficientColorChoices }

                return StroopTrial(word: mappedColor, color: color, type: .incongruous)
            }
        }

        return try (0..<count).map(incongruousNextTrial(from: colorCycle))
    }
    
    private func balancedNeutralTrials(count: Int) throws -> [StroopTrial] {
        let colorCycle = configuration.colorChoices.shuffled().circular()

        func neutralNextTrial(from colorCycle: CircularArrayIterator<StroopColor>) -> (Int) throws -> StroopTrial {
            { _ in
                guard let color = colorCycle.next() else { throw Error.insufficientColorChoices }
                return StroopTrial(word: .none, color: color, type: .neutral)
            }
        }

        return try (0..<count).map(neutralNextTrial(from: colorCycle))
    }
    
    private func makeRandomTrial(type: StroopTrialType) throws -> StroopTrial {
        guard let randomColor = configuration.colorChoices.randomElement() else {
            throw Error.insufficientColorChoices
        }

        let trialWord: StroopColor
        switch type {
        case .congruous:
            trialWord = randomColor
        case .neutral:
            trialWord = .none
        case .incongruous:
            let differentColors = configuration.colorChoices.filter { $0 != randomColor }
            guard let randomDifferentColor = differentColors.randomElement() else {
                throw Error.insufficientColorChoices
            }
            trialWord = randomDifferentColor
        }
        
        return StroopTrial(word: trialWord, color: randomColor, type: type)
    }
}

extension StroopTrialsGenerator {
    enum Error: LocalizedError {
        case insufficientColorChoices
        case colorMapNotConfigured

        var errorDescription: String? {
            switch self {
                case .insufficientColorChoices:
                    return "Not enough color choices to build a trial."
                case .colorMapNotConfigured:
                    return "Color map not configured."
            }
        }
    }
}
