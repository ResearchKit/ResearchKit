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

/// A question that allows for multiple choice input.
public struct MultipleChoiceQuestion: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult
    
    @Environment(\.questionContext)
    private var questionContext: QuestionContext

    @Environment(\.questionRequired)
    private var isRequired: Bool
    
    @State
    private var managedResults: [ResultValue]?

    private var resolvedResult: Binding<[ResultValue]?> {
        switch selection {
        case let .automatic(key: key):
            return Binding(
                get: {
                    let result: [ResultValue]?
                    if let managedResults {
                        result = managedResults
                    } else {
                        switch questionContext {
                        case .formEmbedded:
                            result = managedFormResult.resultForStep(key: key) ?? nil
                        case .standalone:
                            result = nil
                        }
                    }
                    return result
                },
                set: {
                    managedResults = $0
                    
                    if case .formEmbedded = questionContext {
                        managedFormResult.setResultForStep(.multipleChoice($0), key: key)
                    }
                }
            )
        case let .manual(value):
            return value
        }
    }

    private let id: String
    private let title: String
    private let detail: String?
    private let choices: [TextChoice]
    private let choiceSelectionLimit: ChoiceSelectionLimit
    private let selection: StateManagementType<[ResultValue]?>

    /// Initializes an instance of ``MultipleChoiceQuestion`` with the provided configuration for an integer result.
    /// - Parameters:
    ///   - id: The unique identifier associated with this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The choices that can be selected for this question.
    ///   - choiceSelectionLimit: The selection type for this question.
    ///   - selection: The selected choices, where the choice values are represented as integers.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [TextChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        selection: Binding<[Int]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            selection: .init(
                get: {
                    guard let integers = selection.wrappedValue else {
                        return nil
                    }
                    return integers.map { .int($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        selection.wrappedValue = nil
                        return
                    }

                    selection.wrappedValue = newValues.compactMap {
                        resultValue in
                        guard case let .int(value) = resultValue else {
                            return nil
                        }
                        return value
                    }
                }
            )
        )
    }

    /// Initializes an instance of ``MultipleChoiceQuestion`` with the provided configuration for a string result.
    /// - Parameters:
    ///   - id: The unique identifier associated with this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The choices that can be selected for this question.
    ///   - choiceSelectionLimit: The selection type for this question.
    ///   - selection: The selected choices, where the choice values are represented as strings.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [TextChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        selection: Binding<[String]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            selection: .init(
                get: {
                    guard let strings = selection.wrappedValue else {
                        return nil
                    }
                    return strings.map { .string($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        selection.wrappedValue = nil
                        return
                    }

                    selection.wrappedValue = newValues.compactMap {
                        resultValue in
                        guard case let .string(value) = resultValue else {
                            return nil
                        }
                        return value
                    }
                }
            )
        )
    }

    /// Initializes an instance of ``MultipleChoiceQuestion`` with the provided configuration for a date result.
    /// - Parameters:
    ///   - id: The unique identifier associated with this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The choices that can be selected for this question.
    ///   - choiceSelectionLimit: The selection type for this question.
    ///   - selection: The selected choices, where the choice values are represented as dates.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [TextChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        selection: Binding<[Date]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            selection: .init(
                get: {
                    guard let dates = selection.wrappedValue else {
                        return nil
                    }
                    return dates.map { .date($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        selection.wrappedValue = nil
                        return
                    }

                    selection.wrappedValue = newValues.compactMap {
                        resultValue in
                        guard case let .date(value) = resultValue else {
                            return nil
                        }
                        return value
                    }
                }
            )
        )
    }

    private init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [TextChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        selection: Binding<[ResultValue]?>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.choiceSelectionLimit = choiceSelectionLimit
        self.selection = .manual(selection)
    }

    /// Initializes an instance of ``MultipleChoiceQuestion`` with the provided configuration and manages a binding internally.
    /// - Parameters:
    ///   - id: The unique identifier associated with this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The choices that can be selected for this question.
    ///   - choiceSelectionLimit: The selection type for this question.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        choices: [TextChoice],
        choiceSelectionLimit: ChoiceSelectionLimit
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.choiceSelectionLimit = choiceSelectionLimit
        self.selection = .automatic(key: .multipleChoice(id: id))
    }

    public var body: some View {
        QuestionCard {
            Question(title: title, detail: detail) {
                ForEach(Array(choices.enumerated()), id: \.offset) {
                    index, option in
                    VStack(spacing: .zero) {
                        if index != 0 {
                            Divider()
                        }

                        TextChoiceOption(
                            title: Text(option.choiceText),
                            isSelected: isSelected(option)
                        ) {
                            choiceSelected(option)
                        }
                        .padding(.horizontal, 8)
                        #if !os(watchOS)
                            .contentShape(
                                .hoverEffect, RoundedRectangle(cornerRadius: 12)
                            )
                            .hoverEffect()
                        #endif
                        .padding(.horizontal, -8)
                    }
                }
            }
            .preference(
                key: QuestionRequiredPreferenceKey.self, value: isRequired
            )
            .preference(
                key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }

    private var isAnswered: Bool {
        if let resultArray = resolvedResult.wrappedValue, !resultArray.isEmpty {
            return true
        }
        return false
    }

    private func isSelected(_ option: TextChoice) -> Bool {
        resolvedResult.wrappedValue?.contains(where: { choice in
            choice == option.value
        }) ?? false
    }

    private func choiceSelected(_ option: TextChoice) {
        if let resultArray = resolvedResult.wrappedValue,
            let index = resultArray.firstIndex(where: { $0 == option.value })
        {
            resolvedResult.wrappedValue?.remove(at: index)
        } else {
            switch choiceSelectionLimit {
            case .single:
                resolvedResult.wrappedValue = [option.value]
            case .multiple:
                resolvedResult.wrappedValue =
                    (resolvedResult.wrappedValue ?? []) + [option.value]
            }
        }
    }
}

struct MultipleChoiceQuestionView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.choice(for: .secondaryBackground)
                .ignoresSafeArea()

            MultipleChoiceQuestion(
                id: UUID().uuidString,
                title: "Which do you prefer?",
                choices: [
                    TextChoice(id: "a", choiceText: "Option A", value: 0),
                    TextChoice(id: "b", choiceText: "Option B", value: 1),
                    TextChoice(id: "c", choiceText: "Option C", value: 2),
                ],
                choiceSelectionLimit: .multiple,
                selection: .constant([0])
            )
            .padding(.horizontal)
        }

    }
}
