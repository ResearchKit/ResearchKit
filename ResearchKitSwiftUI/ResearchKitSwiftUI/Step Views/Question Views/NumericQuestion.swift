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

import Foundation
import SwiftUI

/// A question that allows for numeric input.
@available(watchOS, unavailable)
public struct NumericQuestion<Header: View>: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    private enum FocusTarget {

        case numericQuestion

    }

    private let id: String
    private let header: Header
    private let prompt: String?
    @FocusState private var focusTarget: FocusTarget?
    private let selection: StateManagementType<Double?>

    @Environment(\.questionRequired)
    private var isRequired: Bool

    private var resolvedResult: Binding<Double?> {
        switch selection {
        case let .automatic(key: key):
            return Binding(
                get: { managedFormResult.resultForStep(key: key) ?? nil },
                set: {
                    managedFormResult.setResultForStep(.numeric($0), key: key)
                }
            )
        case let .manual(value):
            return value
        }
    }

    public var body: some View {
        QuestionCard {
            Question(
                header: {
                    header
                },
                content: {
                    TextField(
                        "", value: resolvedResult, format: .number,
                        prompt: placeholder
                    )
                    #if !os(watchOS) && !os(macOS)
                        .keyboardType(.decimalPad)
                        .focused($focusTarget, equals: .numericQuestion)
                    #endif
                    .doneKeyboardToolbar(
                        condition: {
                            focusTarget == .numericQuestion
                        },
                        action: {
                            focusTarget = nil
                        }
                    )
                    .padding()
                }
            )
            .preference(
                key: QuestionRequiredPreferenceKey.self, value: isRequired
            )
            .preference(
                key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }

    private var placeholder: Text? {
        if let prompt {
            return Text(prompt)
        }

        return nil
    }

    private var isAnswered: Bool {
        resolvedResult.wrappedValue != nil
    }
}

@available(watchOS, unavailable)
extension NumericQuestion where Header == QuestionHeader {

    /// Initializes an instance of ``NumericQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this numeric question.
    ///   - number: The entered number.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - prompt: The prompt that informs the user.
    public init(
        id: String,
        number: Binding<Double?>,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = QuestionHeader(title: title, detail: detail)
        self.prompt = prompt
        self.selection = .manual(number)
    }

    /// Initializes an instance of ``NumericQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - number: The entered number.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - prompt: The prompt that informs the user.
    public init(
        id: String,
        number: Decimal? = nil,
        title: String,
        detail: String? = nil,
        prompt: String?
    ) {
        self.id = id
        header = QuestionHeader(title: title, detail: detail)
        self.prompt = prompt
        self.selection = .automatic(key: .numeric(id: id))
    }

}

@available(watchOS, unavailable)
struct NumericQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.choice(for: .secondaryBackground)
                .ignoresSafeArea()

            ScrollView {
                NumericQuestion(
                    id: UUID().uuidString,
                    number: .constant(22.0),
                    title: "How old are you?",
                    detail: nil,
                    prompt: "Tap to enter age"
                )
                .padding(.horizontal)
            }
        }

    }
}
