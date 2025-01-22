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

struct NavigationalLayout: View {

    @Environment(\.dismiss) var dismiss

    @State
    private var stepIdentifiers: [Subview.ID] = []

    @State
    private var researchFormCompletion: ResearchFormCompletion?

    private let steps: SubviewsCollection
    private let onResearchFormCompletion: ((ResearchFormCompletion) -> Void)?

    init(
        _ steps: SubviewsCollection,
        onResearchFormCompletion: ((ResearchFormCompletion) -> Void)?
    ) {
        self.steps = steps
        self.onResearchFormCompletion = onResearchFormCompletion
    }

    var body: some View {
        NavigationStack(path: $stepIdentifiers) {
            if let firstStep = steps.first {
                ResearchFormStepContentView(
                    isLastStep: isLastStep(for: firstStep)
                ) { completion in
                    switch completion {
                    case .failed, .discarded, .terminated:
                        dismiss()
                    case .completed(let result):
                        handle(formCompletion: completion, with: result)
                    case .saved:
                        if let currentStepIndex = index(for: firstStep) {
                            moveToNextStep(
                                relativeToCurrentIndex: currentStepIndex)
                        }
                    }
                } content: {
                    firstStep
                }
                .navigationTitle("1 of \(steps.count)")
                .navigationDestination(for: Subview.ID.self) { subviewID in
                    ResearchFormStepContentView(
                        isLastStep: isLastStep(for: subviewID)
                    ) { completion in
                        switch completion {
                        case .failed, .discarded, .terminated:
                            dismiss()
                        case .completed(let result):
                            handle(formCompletion: completion, with: result)
                        case .saved:
                            if let currentStepIndex = index(for: subviewID) {
                                moveToNextStep(
                                    relativeToCurrentIndex: currentStepIndex)
                            }
                        }
                    } content: {
                        if let currentStepIndex = index(for: subviewID) {
                            steps[currentStepIndex]
                        }
                    }
                    .navigationTitle(navigationTitle(for: subviewID))
                }
            }
        }
        #if os(watchOS)
            .preference(
                key: ResearchFormCompletionKey.self,
                value: researchFormCompletion)
        #endif
    }

    private func handle(
        formCompletion completion: ResearchFormCompletion,
        with result: ResearchFormResult
    ) {
        if let onResearchFormCompletion {
            #if os(watchOS)
                researchFormCompletion = .completed(result)
            #endif
            onResearchFormCompletion(completion)
        } else {
            dismiss()
        }
    }

    private func moveToNextStep(relativeToCurrentIndex currentIndex: Int) {
        let nextStepIndex = currentIndex + 1
        if nextStepIndex < steps.count {
            stepIdentifiers.append(steps[nextStepIndex].id)
        }
    }

    private func isLastStep(for subview: Subview) -> Bool {
        isLastStep(for: subview.id)
    }

    private func isLastStep(for id: Subview.ID) -> Bool {
        steps.firstIndex(where: { $0.id == id }) == steps.count - 1
    }

    private func index(for subview: Subview) -> Int? {
        index(for: subview.id)
    }

    private func index(for id: Subview.ID) -> Int? {
        steps.firstIndex { step in
            step.id == id
        }
    }

    private func navigationTitle(for id: Subview.ID) -> String {
        let navigationTitle: String
        if let index = index(for: id) {
            navigationTitle = "\(index + 1) of \(steps.count)"
        } else {
            navigationTitle = ""
        }
        return navigationTitle
    }

}

#if os(watchOS)
    struct ResearchFormCompletionKey: PreferenceKey {

        static var defaultValue: ResearchFormCompletion? = nil

        static func reduce(
            value: inout ResearchFormCompletion?,
            nextValue: () -> ResearchFormCompletion?
        ) {
            value = nextValue()
        }

    }
#endif
