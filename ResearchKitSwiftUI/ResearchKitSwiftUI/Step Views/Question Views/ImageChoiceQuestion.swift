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

/// An image choice.
public struct ImageChoice: Identifiable, Equatable {

    /// The unique identifier for this image choice.
    public let id: String

    /// The image for the unselected state.
    public let normalImage: UIImage

    /// The image for the selected state.
    public let selectedImage: UIImage?

    /// The text that describes the image.
    public let text: String

    let value: ResultValue

    /// Initializes an instance of ``ImageChoice`` with the provided configuration.
    /// - Parameters:
    ///   - normalImage: The image for the unselected state.
    ///   - selectedImage: The image for the selected state.
    ///   - text: The text that describes the image.
    ///   - value: The selection value for this image.
    public init(
        normalImage: UIImage,
        selectedImage: UIImage?,
        text: String,
        value: Int
    ) {
        self.init(
            normalImage: normalImage,
            selectedImage: selectedImage,
            text: text,
            value: .int(value)
        )
    }

    /// Initializes an instance of ``ImageChoice`` with the provided configuration.
    /// - Parameters:
    ///   - normalImage: The image for the unselected state.
    ///   - selectedImage: The image for the selected state.
    ///   - text: The text that describes the image.
    ///   - value: The selection value for this image.
    public init(
        normalImage: UIImage,
        selectedImage: UIImage?,
        text: String,
        value: String
    ) {
        self.init(
            normalImage: normalImage,
            selectedImage: selectedImage,
            text: text,
            value: .string(value)
        )
    }

    /// Initializes an instance of ``ImageChoice`` with the provided configuration.
    /// - Parameters:
    ///   - normalImage: The image for the unselected state.
    ///   - selectedImage: The image for the selected state.
    ///   - text: The text that describes the image.
    ///   - value: The selection value for this image.
    public init(
        normalImage: UIImage,
        selectedImage: UIImage?,
        text: String,
        value: Date
    ) {
        self.init(
            normalImage: normalImage,
            selectedImage: selectedImage,
            text: text,
            value: .date(value)
        )
    }

    private init(
        normalImage: UIImage,
        selectedImage: UIImage?,
        text: String,
        value: ResultValue
    ) {
        self.id = String(describing: value)
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        self.text = text
        self.value = value
    }

    public static func == (lhs: ImageChoice, rhs: ImageChoice) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text
    }
}

/// Represents the number of of choices that can be selected.
public enum ChoiceSelectionLimit {

    /// Allows for the selection of only one choice.
    case single

    /// Allows for the selection of more than one choice.
    case multiple

}

/// A question that allows for image input.
public struct ImageChoiceQuestion: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    @Environment(\.questionRequired)
    private var isRequired: Bool

    private let id: String
    private let title: String
    private let detail: String?
    private let choices: [ImageChoice]
    private let choiceSelectionLimit: ChoiceSelectionLimit
    private let vertical: Bool
    private let selection: StateManagementType<[ResultValue]?>

    private var resolvedResult: Binding<[ResultValue]?> {
        switch selection {
        case .automatic(let key):
            return Binding(
                get: { managedFormResult.resultForStep(key: key) ?? [] },
                set: {
                    managedFormResult.setResultForStep(.image($0), key: key)
                }
            )
        case .manual(let value):
            return value
        }
    }

    /// Initializes an instance of ``ImageChoiceQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The image choices for this question.
    ///   - choiceSelectionLimit: The choice selection limit for this image choice question.
    ///   - vertical: Whether or not the images should be displayed horizontally or vertically.
    ///   - imageValue: The selected value associated with one of the image choices.
    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        vertical: Bool,
        imageValue: Binding<[Int]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            vertical: vertical,
            selection: .init(
                get: {
                    guard let integers = imageValue.wrappedValue else {
                        return nil
                    }
                    return integers.map { .int($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        imageValue.wrappedValue = nil
                        return
                    }

                    imageValue.wrappedValue = newValues.compactMap {
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

    /// Initializes an instance of ``ImageChoiceQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The image choices for this question.
    ///   - choiceSelectionLimit: The choice selection limit for this image choice question.
    ///   - vertical: Whether or not the images should be displayed horizontally or vertically.
    ///   - imageValue: The selected value associated with one of the image choices.
    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        vertical: Bool,
        imageValue: Binding<[String]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            vertical: vertical,
            selection: .init(
                get: {
                    guard let strings = imageValue.wrappedValue else {
                        return nil
                    }
                    return strings.map { .string($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        imageValue.wrappedValue = nil
                        return
                    }

                    imageValue.wrappedValue = newValues.compactMap {
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

    /// Initializes an instance of ``ImageChoiceQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The image choices for this question.
    ///   - choiceSelectionLimit: The choice selection limit for this image choice question.
    ///   - vertical: Whether or not the images should be displayed horizontally or vertically.
    ///   - imageValue: The selected value associated with one of the image choices.
    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        vertical: Bool,
        imageValue: Binding<[Date]?>
    ) {
        self.init(
            id: id,
            title: title,
            detail: detail,
            choices: choices,
            choiceSelectionLimit: choiceSelectionLimit,
            vertical: vertical,
            selection: .init(
                get: {
                    guard let dates = imageValue.wrappedValue else {
                        return nil
                    }
                    return dates.map { .date($0) }
                },
                set: { newValues in
                    guard let newValues else {
                        imageValue.wrappedValue = nil
                        return
                    }

                    imageValue.wrappedValue = newValues.compactMap {
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
        detail: String?,
        choices: [ImageChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        vertical: Bool,
        selection: Binding<[ResultValue]?>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.choiceSelectionLimit = choiceSelectionLimit
        self.vertical = vertical
        self.selection = .manual(selection)
    }

    /// Initializes an instance of ``ImageChoiceQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - choices: The image choices for this question.
    ///   - choiceSelectionLimit: The choice selection limit for this image choice question.
    ///   - vertical: Whether or not the images should be displayed horizontally or vertically.
    public init(
        id: String,
        title: String,
        detail: String?,
        choices: [ImageChoice],
        choiceSelectionLimit: ChoiceSelectionLimit,
        vertical: Bool
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.choices = choices
        self.choiceSelectionLimit = choiceSelectionLimit
        self.vertical = vertical
        self.selection = .automatic(key: .imageChoice(id: id))
    }

    public var body: some View {
        QuestionCard {
            Question(title: title, detail: detail) {
                VStack {
                    if choiceSelectionLimit == .multiple {
                        multipleSelectionHeader()
                    }

                    if vertical {
                        VStack {
                            imageChoices()
                        }
                        .padding()
                    } else {
                        HStack {
                            imageChoices()
                        }
                        .padding()
                    }
                    selectionText()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
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

    @ViewBuilder
    private func selectionText() -> some View {

        if let result = resolvedResult.wrappedValue,
            result.isEmpty == false
        {
            let strings: [String] = {
                var strings: [String] = []
                for i in result {
                    if let choice = choices.first(where: { $0.value == i }) {
                        strings.append(choice.text)
                    }
                }
                return strings
            }()

            Text(strings.joined(separator: ", "))
                .foregroundStyle(.primary)
        } else {
            Text("Tap to select")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func imageChoices() -> some View {
        ForEach(choices, id: \.id) { choice in
            Button {
                if let index = resolvedResult.wrappedValue?.firstIndex(where: {
                    $0 == choice.value
                }) {
                    resolvedResult.wrappedValue?.remove(at: index)
                } else {
                    resolvedResult.wrappedValue?.append(choice.value)
                }
            } label: {
                if let result = resolvedResult.wrappedValue,
                    result.contains(where: { $0 == choice.value })
                {
                    Image(uiImage: choice.selectedImage ?? choice.normalImage)
                        .resizable()
                        .imageSizeConstraints()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            choice.selectedImage == nil
                                ? Color.choice(for: .systemGray5) : Color.clear
                        )
                        .cornerRadius(24)
                        .imageChoiceHoverEffect()
                } else {
                    Image(uiImage: choice.normalImage)
                        .resizable()
                        .imageSizeConstraints()
                        .scaledToFit()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(24)
                        .imageChoiceHoverEffect()
                        .contentShape(Capsule())
                }

            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func multipleSelectionHeader() -> some View {
        #if !os(watchOS)
            Text("SELECT ALL THAT APPLY")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            Divider()
        #else
            Text("SELECT ALL THAT APPLY")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        #endif
    }
}

extension View {
    fileprivate func imageChoiceHoverEffect() -> some View {
        self
            #if !os(watchOS)
                .contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 24))
                .hoverEffect()
            #endif
    }

    fileprivate func imageSizeConstraints() -> some View {
        self
            #if !os(watchOS)
                .frame(
                    minWidth: 10, maxWidth: 50,
                    minHeight: 10, maxHeight: 50
                )
            #else
                .frame(
                    minWidth: 10, maxWidth: 30,
                    minHeight: 10, maxHeight: 30
                )
            #endif
    }
}

#Preview {
    @Previewable @State var selection: [Int]? = []
    ScrollView {
        ImageChoiceQuestion(
            id: UUID().uuidString,
            title: "Which do you prefer?",
            detail: nil,
            choices: [
                ImageChoice(
                    normalImage: UIImage(systemName: "carrot")!,
                    selectedImage: nil,
                    text: "carrot",
                    value: 0
                ),
                ImageChoice(
                    normalImage: UIImage(systemName: "birthday.cake")!,
                    selectedImage: nil,
                    text: "cake",
                    value: 1
                ),
            ],
            choiceSelectionLimit: .multiple,
            vertical: false,
            imageValue: $selection
        )
    }
}
