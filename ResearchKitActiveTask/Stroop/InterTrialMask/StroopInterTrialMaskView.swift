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

struct StroopInterTrialMaskView: View {
    
    let maskType: StroopInterTrialMask
    let selectionWasCorrect: Bool

    private var shouldShowCorrectFeedback: Bool {
        selectionWasCorrect && (maskType == .correctFeedback || maskType == .incorrectAndCorrectFeedback)
    }
    private var shouldShowIncorrectFeedback: Bool {
        !selectionWasCorrect && (maskType == .incorrectFeedback || maskType == .incorrectAndCorrectFeedback)
    }

    var body: some View {
        if maskType == .neutral {
            neutralMask()
        } else if shouldShowCorrectFeedback {
            correctFeedbackMask()
        } else if shouldShowIncorrectFeedback {
            incorrectFeedbackMask()
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    private func neutralMask() -> some View {
        Image(systemName: "plus")
            .feedbackMaskStyle(foregroundColor: .gray)
            .opacity(0.7)
    }
    
    @ViewBuilder
    private func incorrectFeedbackMask() -> some View {
        Text("X")
            .feedbackMaskStyle(foregroundColor: .red)
    }
    
    @ViewBuilder
    private func correctFeedbackMask() -> some View {
        Image(systemName: "checkmark")
            .feedbackMaskStyle(foregroundColor: .green)
    }
}

extension View {
    func feedbackMaskStyle(foregroundColor: Color) -> some View {
        modifier(FeedbackMaskStyle(foregroundColor: foregroundColor))
    }
}

struct FeedbackMaskStyle: ViewModifier {
    let foregroundColor: Color
    let fontSize: CGFloat
    let fontWeight: Font.Weight

    init(foregroundColor: Color, fontSize: CGFloat = 48, fontWeight: Font.Weight = .bold) {
        self.foregroundColor = foregroundColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize, weight: fontWeight, design: .default))
            .foregroundStyle(foregroundColor)
    }
}


#Preview {
    @Previewable @State var maskType: StroopInterTrialMask = .none
    @Previewable @State var selectionWasCorrect: Bool = false
    
    VStack {
        StroopInterTrialMaskView(maskType: maskType, selectionWasCorrect: selectionWasCorrect)
        
        HStack {
            Picker("Mask type", selection: $maskType) {
                ForEach(StroopInterTrialMask.allCases, id: \.self) { maskType in
                    Text(String(describing: maskType)).tag(maskType)
                }
            }
            
            Spacer()
            
            Toggle("Correct", isOn: $selectionWasCorrect)
        }
    }
}
