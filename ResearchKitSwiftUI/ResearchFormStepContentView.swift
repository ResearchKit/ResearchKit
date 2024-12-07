/*
 Copyright (c) 2024, Apple Inc. All rights reserved.

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

struct ResearchFormStepContentView<Content: View>: View {
    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    private let content: Content

    private let isLastStep: Bool
    private var onStepCompletion: ((ResearchFormCompletion) -> Void)?

    @State
    private var doneButtonEnabled: Bool = true

    init(
        isLastStep: Bool,
        onStepCompletion: ((ResearchFormCompletion) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isLastStep = isLastStep
        self.onStepCompletion = onStepCompletion
        self.content = content()
    }

    var body: some View {
        StickyScrollView {
            content
                .onPreferenceChange(StepCompletedPreferenceKey.self) {
                    doneButtonEnabled = $0
                }
                .padding()
                #if !os(watchOS)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                onStepCompletion?(.discarded)
                            } label: {
                                Text("Cancel")
                            }
                        }
                    }
                #endif
        } footerContent: {
            Button {
                if isLastStep {
                    onStepCompletion?(.completed(managedFormResult))
                } else {
                    onStepCompletion?(.saved(managedFormResult))
                }
            } label: {
                Text(isLastStep ? "Done" : "Next")
                    .fontWeight(.bold)
                    .frame(maxWidth: maxWidthForDoneButton)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.researchFormStep)
            .disabled(!doneButtonEnabled)
        }
        .background(Color.choice(for: .secondaryBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var maxWidthForDoneButton: CGFloat {
        #if os(visionOS)
            300
        #else
            .infinity
        #endif
    }

}

private struct ResearchFormStepButtonStyle: ButtonStyle {

    @Environment(\.isEnabled)
    private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
            configuration.label
                .foregroundStyle(.white)
                .frame(height: 50)
                .background(
                    isEnabled ? Color.accentColor : Color.accentColor.opacity(0.5),
                    in: RoundedRectangle(cornerRadius: 12)
                )
        #elseif os(visionOS)
            configuration.label
                .foregroundStyle(isEnabled ? .white : .gray)
                .frame(height: 50)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 25)
                )
                .hoverEffect(.highlight)
        #elseif os(watchOS)
            configuration.label
                .foregroundStyle(isEnabled ? .white : .gray)
                .frame(height: 50)
                .background(
                    Color.choice(for: .systemGray4),
                    in: RoundedRectangle(cornerRadius: 25)
                )
        #endif
    }

}

extension ButtonStyle where Self == ResearchFormStepButtonStyle {

    fileprivate static var researchFormStep: ResearchFormStepButtonStyle {
        .init()
    }

}
