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

/// A configuration representing the kind of `SliderQuestion` to be used.
enum SliderQuestionConfiguration {

    @available(watchOS, unavailable)
    case textChoice([TextChoice])

    case integerRange(ClosedRange<Int>)
    case doubleRange(ClosedRange<Double>)
}

/// A question that allows for integer, double, or text input by means of a slider.
public struct SliderQuestion: View {

    private let id: String
    private let title: String
    private let detail: String?
    private let sliderQuestionConfiguration: SliderQuestionConfiguration
    private let step: Double

    private enum ScaleSelectionBindingValue: Equatable {

        static func == (
            lhs: SliderQuestion.ScaleSelectionBindingValue,
            rhs: SliderQuestion.ScaleSelectionBindingValue
        ) -> Bool {
            switch lhs {
            case .textChoice(let binding):
                guard case .textChoice(let rhsBinding) = rhs else {
                    return false
                }
                return rhsBinding.wrappedValue.id == binding.wrappedValue.id
            case .int(let binding):
                guard case .int(let rhsBinding) = rhs else {
                    return false
                }
                return rhsBinding.wrappedValue == binding.wrappedValue
            case .double(let binding):
                guard case .double(let rhsBinding) = rhs else {
                    return false
                }
                return rhsBinding.wrappedValue == binding.wrappedValue
            }
        }

        case int(Binding<Int?>)
        case double(Binding<Double?>)

        @available(watchOS, unavailable)
        case textChoice(Binding<TextChoice>)

    }

    private enum ScaleSelectionPrimitiveValue: Equatable {

        static func == (
            lhs: SliderQuestion.ScaleSelectionPrimitiveValue,
            rhs: SliderQuestion.ScaleSelectionPrimitiveValue
        ) -> Bool {
            switch lhs {
            case .textChoice(let lhsValue):
                guard case .textChoice(let rhsValue) = rhs else {
                    return false
                }
                return lhsValue.id == rhsValue.id
            case .int(let lhsValue):
                guard case .int(let rhsValue) = rhs else {
                    return false
                }
                return lhsValue == rhsValue
            case .double(let lhsValue):
                guard case .double(let rhsValue) = rhs else {
                    return false
                }
                return lhsValue == rhsValue
            }
        }

        case int(Int)
        case double(Double)

        @available(watchOS, unavailable)
        case textChoice(TextChoice)

    }

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    @Environment(\.questionRequired)
    private var isRequired: Bool

    @State
    private var isWaitingForUserFeedback: Bool = true

    private let stateManagementType: StateManagementType<Double>

    private var resolvedBinding: Binding<ScaleSelectionBindingValue> {
        let resolvedBinding: Binding<ScaleSelectionBindingValue>
        switch stateManagementType {
        case .automatic:
            resolvedBinding = resolvedManagedResult
        case .manual:
            resolvedBinding = .init(
                get: {
                    clientManagedSelection
                },
                // This binding isn't invoked with respect to `set` because another binding is returned in `get`.
                set: { _ in }
            )
        }
        return resolvedBinding
    }

    // Actual underlying value of the slider
    @State
    private var sliderUIValue: Double

    private var resolvedManagedResult: Binding<ScaleSelectionBindingValue> {
        .init(
            get: {
                // `resolvedManagedResult` is only applicable in the `automatic` case,
                // as implemented in `resolvedBinding`.
                guard case .automatic(let key) = stateManagementType else {
                    // Return dummy binding since this should never be invoked.
                    return .int(
                        .init(
                            get: {
                                0
                            },
                            set: { _ in }
                        )
                    )
                }
                let scaleSelectionBinding: ScaleSelectionBindingValue
                switch sliderQuestionConfiguration {
                #if !os(watchOS)
                    case .textChoice(let multipleChoiceOptions):
                        scaleSelectionBinding = .textChoice(
                            .init(
                                get: {
                                    guard
                                        let sliderValue =
                                            managedFormResult.resultForStep(
                                                key: key)
                                    else {
                                        return TextChoice(
                                            id: "", choiceText: "", value: 0)
                                    }
                                    return multipleChoiceOptions[
                                        Int(sliderValue)]
                                },
                                set: { multipleChoiceOption in
                                    guard
                                        let index =
                                            multipleChoiceOptions.firstIndex(
                                                where: {
                                                    $0.id
                                                        == multipleChoiceOption
                                                        .id
                                                })
                                    else {
                                        return
                                    }
                                    managedFormResult.setResultForStep(
                                        .scale(Double(index)), key: key)
                                }
                            )
                        )
                #endif
                case .integerRange:
                    scaleSelectionBinding = .int(
                        .init(
                            get: {
                                guard
                                    let sliderValue =
                                        managedFormResult.resultForStep(
                                            key: key)
                                else {
                                    return 0
                                }
                                return Int(sliderValue)
                            },
                            set: {
                                guard let result = $0 else { return }
                                managedFormResult.setResultForStep(
                                    .scale(Double(result)), key: key)
                            }
                        )
                    )
                case .doubleRange:
                    scaleSelectionBinding = .double(
                        .init(
                            get: {
                                guard
                                    let sliderValue =
                                        managedFormResult.resultForStep(
                                            key: key)
                                else {
                                    return 0
                                }
                                return sliderValue
                            },
                            set: {
                                guard let result = $0 else { return }
                                managedFormResult.setResultForStep(
                                    .scale(result), key: key)
                            }
                        )
                    )
                }

                return scaleSelectionBinding
            },
            set: { newValue in
                // `resolvedManagedResult` is only applicable in the `automatic` case,
                // as implemented in `resolvedBinding`.
                guard case .automatic(let key) = stateManagementType else {
                    return
                }

                switch (newValue, sliderQuestionConfiguration) {
                #if !os(watchOS)
                    case let (
                        .textChoice(binding), .textChoice(multipleChoiceOptions)
                    ):
                        let index =
                            multipleChoiceOptions.firstIndex(
                                where: { binding.wrappedValue.id == $0.id }
                            ) ?? 0
                        managedFormResult.setResultForStep(
                            .scale(Double(index)), key: key)
                #endif
                case let (.int(binding), .integerRange):
                    guard let result = binding.wrappedValue else { return }
                    managedFormResult.setResultForStep(
                        .scale(Double(result)), key: key)

                case let (.double(binding), .doubleRange):
                    guard let result = binding.wrappedValue else { return }
                    managedFormResult.setResultForStep(.scale(result), key: key)

                default:
                    break
                }
            }
        )
    }

    private var clientManagedSelection: ScaleSelectionBindingValue

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration and manages the binding for double values internally.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - range: The range of selectable values for this question.
    ///   - step: The amount of change between each increment or decrement.
    ///   - selection: The selected value.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Double
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .doubleRange(range)
        self.step = step
        self.clientManagedSelection = .double(
            .init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic(key: StepResultKey(id: id))
        self._sliderUIValue = State(wrappedValue: selection)
    }

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration for double values.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - range: The range of selectable values for this question.
    ///   - step: The amount of change between each increment or decrement.
    ///   - selection: The selected value.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        selection: Binding<Double?>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .doubleRange(range)
        self.step = step
        self.clientManagedSelection = .double(selection)
        self.stateManagementType = .manual(
            .init(
                get: {
                    Double(selection.wrappedValue ?? range.lowerBound)
                },
                set: { newValue in
                    selection.wrappedValue = newValue
                }
            )
        )
        self._sliderUIValue = State(
            wrappedValue: selection.wrappedValue ?? range.lowerBound)
    }

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration for integer values.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - range: The range of selectable values for this slider question.
    ///   - step: The amount of change between each increment or decrement.
    ///   - selection: The selected value.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Int?
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .integerRange(range)
        self.step = step
        self.clientManagedSelection = .int(
            .init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic(key: StepResultKey(id: id))
        self._sliderUIValue = State(
            wrappedValue: Double(selection ?? range.lowerBound))
    }

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration for integer values.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - range: The range of selectable values for this slider question.
    ///   - step: The amount of change between each increment or decrement.
    ///   - selection: The selected value.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        range: ClosedRange<Int>,
        step: Double = 1.0,
        selection: Binding<Int?>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .integerRange(range)
        self.step = step
        self.clientManagedSelection = .int(selection)
        self.stateManagementType = .manual(
            .init(
                get: {
                    Double(selection.wrappedValue ?? range.lowerBound)
                },
                set: { newValue in
                    selection.wrappedValue = Int(newValue)
                }
            )
        )
        self._sliderUIValue = State(
            wrappedValue: Double(selection.wrappedValue ?? range.lowerBound))
    }

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration for text values.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - multipleChoiceOptions: The text options that this slider can represent.
    ///   - selection: The selected value.
    @available(watchOS, unavailable)
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [TextChoice],
        selection: TextChoice
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.clientManagedSelection = .textChoice(
            .init(get: { selection }, set: { _ in }))
        self.stateManagementType = .automatic(key: StepResultKey(id: id))

        let index = multipleChoiceOptions.firstIndex(where: {
            selection.id == $0.id
        })
        let sliderValue = index ?? Array<TextChoice>.Index(0.0)
        self._sliderUIValue = State(wrappedValue: Double(sliderValue))
    }

    /// Initializes an instance of ``SliderQuestion`` with the provided configuration for text values.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - multipleChoiceOptions: The text options that this slider can represent.
    ///   - selection: The selected value.
    @available(watchOS, unavailable)
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        multipleChoiceOptions: [TextChoice],
        selection: Binding<TextChoice>
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.sliderQuestionConfiguration = .textChoice(multipleChoiceOptions)
        self.step = 1.0
        self.clientManagedSelection = .textChoice(selection)
        self.stateManagementType = .manual(
            .init(
                get: {
                    guard
                        let index = multipleChoiceOptions.firstIndex(
                            where: { selection.wrappedValue.id == $0.id }
                        )
                    else {
                        return 0
                    }
                    return Double(index)
                },
                set: { newValue in
                    let index = Int(newValue)
                    guard index >= 0, index < multipleChoiceOptions.count else {
                        return
                    }
                    let newSelection = multipleChoiceOptions[index]
                    selection.wrappedValue = newSelection
                }
            )
        )

        let index = multipleChoiceOptions.firstIndex(where: {
            selection.id == $0.id
        })
        let sliderValue = index ?? Array<TextChoice>.Index(0.0)
        self._sliderUIValue = State(wrappedValue: Double(sliderValue))
    }

    public var body: some View {
        QuestionCard {
            Question(title: title, detail: detail) {
                scaleView(selectionConfiguration: sliderQuestionConfiguration)
                    .onChange(of: sliderUIValue) { oldValue, newValue in
                        isWaitingForUserFeedback = false
                        switch resolvedBinding.wrappedValue {
                        case .double(let doubleBinding):
                            doubleBinding.wrappedValue = newValue
                        case .int(let intBinding):
                            intBinding.wrappedValue = Int(newValue)
                        case .textChoice(let textChoiceBinding):
                            guard
                                case let .textChoice(array) =
                                    sliderQuestionConfiguration
                            else {
                                return
                            }
                            let index = Int(newValue)
                            textChoiceBinding.wrappedValue = array[index]
                        }
                    }
                    .onChange(of: clientManagedSelection) {
                        oldValue, newValue in
                        switch newValue {
                        case .textChoice(let binding):
                            guard
                                case let .textChoice(array) =
                                    sliderQuestionConfiguration
                            else {
                                return
                            }
                            let selectedIndex =
                                array.firstIndex(where: {
                                    $0.id == binding.wrappedValue.id
                                }) ?? 0
                            sliderUIValue = Double(selectedIndex)
                        case .int(let binding):
                            if let value = binding.wrappedValue {
                                sliderUIValue = Double(value)
                            }
                        case .double(let binding):
                            if let value = binding.wrappedValue {
                                sliderUIValue = value
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        guard case .automatic(let key) = stateManagementType,
                            let sliderValue = managedFormResult.resultForStep(
                                key: key)
                        else {
                            return
                        }
                        sliderUIValue = sliderValue
                    }
            }
            .preference(
                key: QuestionRequiredPreferenceKey.self, value: isRequired
            )
            .preference(
                key: QuestionAnsweredPreferenceKey.self,
                value: !isWaitingForUserFeedback)
        }
    }

    @ViewBuilder
    private func scaleView(selectionConfiguration: SliderQuestionConfiguration)
        -> some View
    {
        VStack {
            Text("\(value(for: selectionConfiguration))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.sliderValueForegroundStyle)

            slider(selectionConfiguration: selectionConfiguration)
        }
    }

    @ViewBuilder
    private func sliderLabel(_ value: String) -> some View {
        Text(value)
            .fixedSize()
            .foregroundStyle(Color.choice(for: .label))
            .font(.subheadline)
            .fontWeight(.bold)
    }

    @ViewBuilder
    private func slider(selectionConfiguration: SliderQuestionConfiguration)
        -> some View
    {
        Slider(
            value: $sliderUIValue,
            in: sliderBounds(for: selectionConfiguration),
            step: sliderStep(for: selectionConfiguration)
        ) {
            Text("Slider for \(selectionConfiguration)")
        } minimumValueLabel: {
            sliderLabel(
                "\(minimumValueDescription(for: selectionConfiguration))")
        } maximumValueLabel: {
            sliderLabel(
                "\(maximumValueDescription(for: selectionConfiguration))")
        }
    }

    private func value(for selectionConfiguration: SliderQuestionConfiguration)
        -> any CustomStringConvertible
    {
        let value: any CustomStringConvertible
        switch selectionConfiguration {
        case .integerRange:
            value = Int(sliderUIValue)
        case .doubleRange:
            value = String(format: "%.1f", sliderUIValue)
        case .textChoice(let choices):
            value = choices[Int(sliderUIValue)].choiceText
        }
        return value
    }

    private func sliderBounds(
        for selectionConfiguration: SliderQuestionConfiguration
    ) -> ClosedRange<Double> {
        let sliderBounds: ClosedRange<Double>
        switch selectionConfiguration {
        case .textChoice(let choices):
            sliderBounds = 0...Double(choices.count - 1)
        case .integerRange(let range):
            sliderBounds = Double(range.lowerBound)...Double(range.upperBound)
        case .doubleRange(let range):
            sliderBounds = range.lowerBound...range.upperBound
        }
        return sliderBounds
    }

    private func sliderStep(
        for selectionConfiguration: SliderQuestionConfiguration
    ) -> Double.Stride {
        let sliderStep: Double.Stride
        switch selectionConfiguration {
        case .textChoice:
            sliderStep = 1
        case .integerRange, .doubleRange:
            sliderStep = step
        }
        return sliderStep
    }

    private func minimumValueDescription(
        for selectionConfiguration: SliderQuestionConfiguration
    ) -> any CustomStringConvertible {
        let minimumValueLabel: any CustomStringConvertible
        switch selectionConfiguration {
        case .textChoice(let choices):
            minimumValueLabel = choices.first?.choiceText ?? ""
        case .integerRange(let range):
            minimumValueLabel = range.lowerBound
        case .doubleRange(let range):
            minimumValueLabel = range.lowerBound
        }
        return minimumValueLabel
    }

    private func maximumValueDescription(
        for selectionConfiguration: SliderQuestionConfiguration
    ) -> any CustomStringConvertible {
        let maximumValueDescription: any CustomStringConvertible
        switch selectionConfiguration {
        case .textChoice(let choices):
            maximumValueDescription = choices.last?.choiceText ?? ""
        case .integerRange(let range):
            maximumValueDescription = range.upperBound
        case .doubleRange(let range):
            maximumValueDescription = range.upperBound
        }
        return maximumValueDescription
    }
}

struct ScaleSliderQuestionView_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            (Color.choice(for: .secondaryBackground))
                .ignoresSafeArea()

            SliderQuestion(
                id: UUID().uuidString,
                title: "On a scale of 1-10, how would you rate today?",
                range: 1...10,
                selection: .constant(7)
            )
            .padding(.horizontal)
        }

    }
}

#Preview("Int") {
    ScrollView {
        SliderQuestion(
            id: UUID().uuidString,
            title: "On a scale of 1-10, how would you rate today?",
            range: 1...10,
            selection: .constant(7)
        )
    }
}

#Preview("Double") {
    @Previewable @State var selection: Double? = 0.0

    ScrollView {
        SliderQuestion(
            id: UUID().uuidString,
            title: "Double Slider Question Example",
            range: 0.0...10.0,
            step: 0.1,
            selection: $selection
        )
    }
}

#if !os(watchOS)
    #Preview("Text") {
        ScrollView {
            SliderQuestion(
                id: UUID().uuidString,
                title: "On a scale of Pun - Poem, how would rate today?",
                multipleChoiceOptions: [
                    .init(id: "1", choiceText: "Pun", value: 1),
                    .init(id: "2", choiceText: "Dad Joke", value: 2),
                    .init(id: "3", choiceText: "Knock-Knock Joke", value: 3),
                    .init(id: "4", choiceText: "One-Liner", value: 4),
                    .init(id: "5", choiceText: "Parody", value: 5),
                    .init(id: "5", choiceText: "Poem", value: 6),
                ],
                selection: .constant(
                    .init(id: "2", choiceText: "Dad Joke", value: 2)))
        }
    }
#endif
