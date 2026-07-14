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


/// Records a single response to a Stroop prompt.
public struct StroopStepResponse: Codable, Hashable, Sendable {
    /// A meaningful identifier associated with the response.
    public let identifier: String
    
    /// The color selected by the user, corresponding to the button tapped by the user as an answer.
    public let selectedColor: StroopColor
    
    /// The color name of the text displayed.
    public let trialWord: StroopColor

    /// The color of the question string.
    public let trialColor: StroopColor

    /// The type of the trial.
    public let trialType: StroopTrialType
    
    /// The timestamp when the prompt becomes visible to the user.
    public let startTime: Date
    
    /// The timestamp when the user answers a particular prompt by selecting a color.
    public let endTime: Date
    
    /// Instantiates a new ``StroopStepResponse`` representing the provided context.
    /// - Parameters:
    ///    - identifier: A meaningful identifier for the response.
    ///    - trial: The parameters used for a single trial.
    ///    - selectedColor: The color that was selected by the user.
    ///    - startTime: The timestamp when the prompt becomes visible.
    ///    - endTime: The timestamp when the user makes a selection.
    init(
        identifier: String,
        trial: StroopTrial,
        selectedColor: StroopColor,
        startTime: Date,
        endTime: Date
    ) {
        self.identifier = identifier
        self.selectedColor = selectedColor
        self.trialType = trial.type
        self.trialWord = trial.word
        self.trialColor = trial.color
        self.startTime = startTime
        self.endTime = endTime
    }
}
