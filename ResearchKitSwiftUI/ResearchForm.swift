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

/// Represents a step in a survey and lays out the header and questions on one page. Question numbers (e.g. 1 of 3) are automatically added at the top of each question to denote progress in a step.
public struct ResearchFormStep<Header: View, Content: View>: View {

    @State
    private var shouldWrapInQuestionCard = true

    private let header: Header
    private let content: Content

    /// Initializes an instance of ``ResearchFormStep`` with the provided configuration.
    /// - Parameters:
    ///   - header: The header that is displayed at the top of the step.
    ///   - content: The questions that are displayed below the header.
    public init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
        self.content = content()
    }

    @State
    private var visibleQuestions = Set<Subview.ID>()

    @State
    private var requiredQuestions = Set<Subview.ID>()

    @State
    private var answeredQuestions = Set<Subview.ID>()

    private var canMoveToNextStep: Bool {
        requiredQuestions
            .filter { visibleQuestions.contains($0) }
            .subtracting(answeredQuestions).isEmpty
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Group(
                subviews: cardConsideredContent()
            ) { questions in
                ForEach(subviews: questions) { question in
                    Group {
                        if shouldWrapInQuestionCard {
                            QuestionCard {
                                VStack(alignment: .leading, spacing: 0) {
                                    if let questionIndex = questions.firstIndex(
                                        where: { $0.id == question.id })
                                    {
                                        let questionNumber = questionIndex + 1
                                        Text(
                                            "Question \(questionNumber) of \(questions.count)"
                                        )
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        #if os(watchOS)
                                            .padding([.horizontal])
                                            .padding(.top, 4)
                                        #else
                                            .fontWeight(.bold)
                                            .padding([.horizontal, .top])
                                        #endif
                                    }

                                    question
                                }
                            }
                        } else {
                            question
                        }
                    }
                    .onPreferenceChange(QuestionRequiredPreferenceKey.self) {
                        if $0 == true {
                            requiredQuestions.insert(question.id)
                        }
                    }
                    .onPreferenceChange(QuestionAnsweredPreferenceKey.self) {
                        if $0 == true {
                            answeredQuestions.insert(question.id)
                        } else {
                            answeredQuestions.remove(question.id)
                        }
                    }
                    .onAppear {
                        visibleQuestions.insert(question.id)
                    }
                    .onDisappear {
                        visibleQuestions.remove(question.id)
                    }
                }
            }
        }
        .preference(
            key: StepCompletedPreferenceKey.self, value: canMoveToNextStep
        )

        #if os(iOS)
            .frame(maxWidth: .infinity, alignment: .leading)
        #endif
        .onPreferenceChange(QuestionCardPreferenceKey.self) {
            shouldWrapInQuestionCard in
            self.shouldWrapInQuestionCard = shouldWrapInQuestionCard
        }
    }

    @ViewBuilder
    private func cardConsideredContent() -> some View {
        if shouldWrapInQuestionCard {
            content.environment(\.isQuestionCardEnabled, false)
        } else {
            content
        }
    }

}

extension ResearchFormStep where Header == EmptyView {

    /// Initializes an instance of ``ResearchFormStep`` with just the questions and no header.
    /// - Parameter content: The questions for the step.
    public init(@ViewBuilder content: () -> Content) {
        self.init(
            header: {
                EmptyView()
            },
            content: content
        )
    }

}

extension ResearchFormStep where Header == StepHeader, Content == EmptyView {

    /// Initializes an instance of ``ResearchFormStep`` with the provided configuration. There are no questions displayed beneath the header.
    /// - Parameters:
    ///   - image: The image displayed in the header.
    ///   - title: The title displayed in the header.
    ///   - subtitle: The subtitle displayed in the header.
    public init(
        image: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil
    ) {
        self.init(
            image: image,
            title: title,
            subtitle: subtitle,
            content: {
                EmptyView()
            }
        )
    }

}

extension ResearchFormStep where Header == StepHeader {

    /// Initializes an instance of ``ResearchFormStep`` with the provided configuration. The questions are displayed beneath the header.
    /// - Parameters:
    ///   - image: The image displayed in the header.
    ///   - title: The title displayed in the header.
    ///   - subtitle: The subtitle displayed in the header.
    ///   - content: The questions for the step that are displayed beneath the header.
    public init(
        image: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        let titleText: Text?
        if let title, !title.isEmpty {
            titleText = Text(title)
        } else {
            titleText = nil
        }

        let subtitleText: Text?
        if let subtitle, !subtitle.isEmpty {
            subtitleText = Text(subtitle)
        } else {
            subtitleText = nil
        }

        self.init(
            header: {
                StepHeader(
                    image: image,
                    title: titleText,
                    subtitle: subtitleText
                )
            },
            content: content
        )
    }

}
