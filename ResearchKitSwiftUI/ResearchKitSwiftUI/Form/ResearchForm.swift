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

/// Manages the navigation between steps in a survey.
///
/// To add steps to a `ResearchForm`, create instances of ``ResearchFormStep`` and pass them into a `ResearchForm`. To display questions in each step, ResearchKit provides various question formats that can be used within a ``ResearchFormStep`` such as ``MultipleChoiceQuestion``, ``DateTimeQuestion``, and more. These questions can be marked as optional or required, which a `ResearchForm` tracks as part of navigation management.
///
/// Additionally, a `ResearchForm` manages survey results for questions that manage their own bindings internally. Results are passed through a ``ResearchFormResult`` once a survey is completed. For instance, a text question for which no binding is provided has its result stored in ``ResearchFormResult``. However, a text question that has been provided a binding does not have its result stored in ``ResearchFormResult``, and in this case, you are expected to manage the result for the text question.
public struct ResearchForm<Content: View>: View {
    @State
    private var managedFormResult: ResearchFormResult

    #if os(watchOS)
        @State
        private var researchFormCompletion: ResearchFormCompletion?
    #endif

    private let taskKey: StepResultKey<String?>
    private let steps: Content

    private var onResearchFormCompletion: ((ResearchFormCompletion) -> Void)?

    /// Initializes an instance of ``ResearchForm`` with the provided configuration.
    /// - Parameters:
    ///   - taskIdentifier: An identifier that uniquely identifies this research form.
    ///   - restorationResult: A result used to pre-populate questions that had previously been answered.
    ///   - steps: The steps in a survey, each of which can contain a set of questions.
    ///   - onResearchFormCompletion: A completion that is triggered when the survey is dismissed.
    public init(
        id: String,
        restorationResult: ResearchFormResult? = nil,
        @ViewBuilder steps: () -> Content,
        onResearchFormCompletion: ((ResearchFormCompletion) -> Void)? = nil
    ) {
        self.taskKey = .text(id: id)
        self.steps = steps()
        self.onResearchFormCompletion = onResearchFormCompletion
        self.managedFormResult = restorationResult ?? ResearchFormResult()
    }

    public var body: some View {
        Group(subviews: steps) { steps in
            NavigationalLayout(
                steps, onResearchFormCompletion: onResearchFormCompletion)
        }
        .environmentObject(managedFormResult)
        .environment(\.questionContext, .formEmbedded)
        #if os(watchOS)
            // On the watch, an x button is automatically added to the top left of the screen when presenting content, so we have
            // to remove the cancel button, which had invoked `onResearchFormCompletion` with a completion of `discarded`.
            //
            // Here, we track the completions that come in, and in `onDisappear`, we invoke the completion with the `discarded`
            // state if no completion was ever set. This helps with passing through the discarded state even when there is
            // no cancel button on the watch.
            .onPreferenceChange(
                ResearchFormCompletionKey.self,
                perform: { researchFormCompletion in
                    self.researchFormCompletion = researchFormCompletion
                }
            )
            .onDisappear {
                if researchFormCompletion == nil {
                    onResearchFormCompletion?(.discarded)
                }
            }
        #endif
    }

}
