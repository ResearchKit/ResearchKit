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

/// The precision representing the granularity of a measurement's value. (e.g. 68 kg vs. 68.04 kg, or 150 lbs vs. 150 lbs 5 oz)
public enum NumericPrecision {
    case `default`, low, high
}

private class WeightFormatter {

    static let shared = WeightFormatter()

    private let weightFormatter: NumberFormatter

    private init() {
        let weightFormatter = NumberFormatter()
        weightFormatter.numberStyle = .decimal
        weightFormatter.roundingMode = .halfUp
        self.weightFormatter = weightFormatter
    }

    func string(for number: Double, precision: NumericPrecision) -> String? {
        switch precision {
        case .default:
            weightFormatter.minimumFractionDigits = 1
            weightFormatter.maximumFractionDigits = 1
        case .low:
            weightFormatter.minimumFractionDigits = 0
            weightFormatter.maximumFractionDigits = 0
        case .high:
            weightFormatter.minimumFractionDigits = 2
            weightFormatter.maximumFractionDigits = 2
        }
        return weightFormatter.string(for: number)
    }

}

/// A question that allows for weight input.
public struct WeightQuestion: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult

    @State private var isInputActive = false
    @State private var hasChanges: Bool

    @Environment(\.questionRequired)
    private var isRequired: Bool

    private let defaultWeightInKilograms = 68.039

    private let id: String
    private let title: String
    private let detail: String?
    private let measurementSystem: MeasurementSystem
    private let precision: NumericPrecision
    private let defaultValue: Double?
    private let minimumValue: Double?
    private let maximumValue: Double?
    private let selection: StateManagementType<Double?>

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

    /// Initializes an instance of ``WeightQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - measurementSystem: The measurement system for this question.
    ///   - precision: The precision for this question.
    ///   - defaultValue: The default weight.
    ///   - minimumValue: The minimum selectable weight.
    ///   - maximumValue: The maximum selectable weight.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        precision: NumericPrecision = .default,
        defaultValue: Double?,
        minimumValue: Double?,
        maximumValue: Double?
    ) {
        self.id = id
        self.hasChanges = false
        self.title = title
        self.detail = detail

        let system: MeasurementSystem = {
            switch measurementSystem {
            case .USC:
                return .USC
            case .local:
                if Locale.current.measurementSystem == .us {
                    return .USC
                } else {
                    return .metric
                }
            case .metric:
                return .metric
            }
        }()

        self.measurementSystem = system
        self.precision = precision
        self.defaultValue = defaultValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.selection = .automatic(key: .weight(id: id))
    }

    /// Initializes an instance of ``WeightQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - measurementSystem: The measurement system for this question.
    ///   - precision: The precision for this question.
    ///   - defaultValue: The default weight.
    ///   - minimumValue: The minimum selectable weight.
    ///   - maximumValue: The maximum selectable weight.
    ///   - weight: The selected weight.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        precision: NumericPrecision = .default,
        defaultValue: Double?,
        minimumValue: Double?,
        maximumValue: Double?,
        weight: Binding<Double?>
    ) {
        self.id = id
        self.hasChanges = false
        self.title = title
        self.detail = detail

        let system: MeasurementSystem = {
            switch measurementSystem {
            case .USC:
                return .USC
            case .local:
                if Locale.current.measurementSystem == .us {
                    return .USC
                } else {
                    return .metric
                }
            case .metric:
                return .metric
            }
        }()

        self.measurementSystem = system
        self.precision = precision
        self.defaultValue = defaultValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.selection = .manual(weight)
    }

    private var selectionString: String {
        let selectedResult: Double
        if let result = resolvedResult.wrappedValue {
            selectedResult = result
        } else {
            selectedResult = defaultValue ?? defaultWeightInKilograms
        }

        let (pounds, ounces) = convertKilogramsToPoundsAndOunces(selectedResult)
        if measurementSystem == .USC {
            switch precision {
            case .default, .low:
                return "\(Int(pounds)) lb"
            case .high:
                return "\(Int(pounds)) lb \(Int(ounces)) oz"
            }
        } else {
            if resolvedResult.wrappedValue == defaultWeightInKilograms {
                // 68.039 isn't exactly the prettiest value, but it maps
                // nice to 150 pounds, so if the user sticks with the default
                // we'll round to the nearest result which in our case would be 60kg.
                return "\(selectedResult.rounded()) kg"
            }

            return
                "\(WeightFormatter.shared.string(for: selectedResult, precision: precision) ?? "") kg"
        }
    }

    public var body: some View {
        QuestionCard {
            Question(title: title, detail: detail) {
                HStack {
                    Text("Select Weight")
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        isInputActive = true

                        #if !os(watchOS)
                            UIApplication.shared.endEditing()
                        #endif
                    } label: {
                        Text(selectionString)
                            .foregroundStyle(Color.primary)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    #if os(watchOS)
                        .navigationDestination(isPresented: $isInputActive) {
                            WeightPickerView(
                                measurementSystem: measurementSystem,
                                precision: precision,
                                defaultValue: defaultValue,
                                minimumValue: minimumValue,
                                maximumValue: maximumValue,
                                selection: .init(
                                    get: {
                                        resolvedResult.wrappedValue
                                            ?? defaultValue
                                            ?? defaultWeightInKilograms
                                    },
                                    set: {
                                        resolvedResult.wrappedValue = $0
                                    }
                                ),
                                hasChanges: $hasChanges
                            )
                        }
                    #else
                        .popover(
                            isPresented: $isInputActive,
                            attachmentAnchor: .point(.bottom),
                            arrowEdge: .top
                        ) {
                            WeightPickerView(
                                measurementSystem: measurementSystem,
                                precision: precision,
                                defaultValue: defaultValue
                                    ?? defaultWeightInKilograms,
                                minimumValue: minimumValue,
                                maximumValue: maximumValue,
                                selection: .init(
                                    get: {
                                        resolvedResult.wrappedValue
                                            ?? defaultValue
                                            ?? defaultWeightInKilograms
                                    },
                                    set: {
                                        resolvedResult.wrappedValue = $0
                                    }
                                ),
                                hasChanges: $hasChanges
                            )
                            .frame(width: 300)
                            .presentationCompactAdaptation((.popover))
                        }
                    #endif
                }
                .padding()
            }
            .preference(
                key: QuestionRequiredPreferenceKey.self, value: isRequired
            )
            .preference(
                key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }

    private var isAnswered: Bool {
        resolvedResult.wrappedValue != nil
    }
}

struct WeightPickerView: View {
    @Environment(\.dismiss) private var dismiss

    private let measurementSystem: MeasurementSystem
    private let precision: NumericPrecision
    private let defaultValue: Double?
    private let minimumValue: Double?
    private let maximumValue: Double?

    @Binding private var selection: Double?
    @Binding private var hasChanges: Bool

    @State private var highPrecisionSelection: Int = 0
    @State private var selectionOne: Double
    @State private var selectionTwo: Double

    private static let defaultValueInKilograms: Double = 68.0
    private static let defaultValueInPounds: Double = 150.0

    private var lowerValue: Double {
        guard let minimumValue else { return 0 }
        return minimumValue
    }

    private var upperValue: Double {
        if measurementSystem == .USC {
            guard let maximumValue else { return 1_450 }
            return maximumValue
        } else {
            guard let maximumValue else {
                switch precision {
                case .low, .high:
                    return 657
                case .default:
                    return 657.5
                }
            }
            return maximumValue
        }
    }

    private var primaryStep: Double {
        if measurementSystem != .USC {
            switch precision {
            case .default:
                return 0.5
            case .low, .high:
                return 1
            }
        } else {
            return 1
        }
    }

    private var secondaryStep: Double {
        if measurementSystem == .USC {
            return 1
        } else {
            return 0.01
        }
    }

    private var primaryUnit: String {
        if measurementSystem == .USC {
            return "lb"
        } else {
            return "kg"
        }
    }

    private var primaryRange: [Double] {
        var range: [Double] = []
        for i in stride(from: lowerValue, through: upperValue, by: primaryStep)
        {
            range.append(i)
        }
        return range
    }

    private var secondaryRange: [Double] {
        let upperValue = measurementSystem == .USC ? 15 : 0.99
        var range: [Double] = []
        for i in stride(
            from: lowerValue, through: upperValue, by: secondaryStep)
        {
            if case .USC = measurementSystem {
                range.append(i)
            } else {
                let decimal = Decimal(i).rounded(2, .plain)
                range.append(
                    NSDecimalNumber(decimal: decimal).doubleValue
                )
            }
        }
        return range
    }

    init(
        measurementSystem: MeasurementSystem = .metric,
        precision: NumericPrecision = .default,
        defaultValue: Double? = nil,
        minimumValue: Double? = nil,
        maximumValue: Double? = nil,
        selection: Binding<Double?>,
        hasChanges: Binding<Bool>
    ) {
        self.measurementSystem = measurementSystem
        self.precision = precision
        self.defaultValue = defaultValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self._selection = selection
        self._hasChanges = hasChanges

        let displayedValue = selection.wrappedValue ?? defaultValue ?? 0

        let selectionOneValue: Double = {
            if measurementSystem == .USC {
                return convertKilogramsToPoundsAndOunces(displayedValue).pounds
            } else {
                let roundedSelectionOne: Double
                switch precision {
                case .default:
                    roundedSelectionOne = (displayedValue * 10).rounded() / 10
                case .low:
                    roundedSelectionOne = displayedValue.rounded()
                case .high:
                    roundedSelectionOne = floor(displayedValue)
                }
                return roundedSelectionOne
            }
        }()
        self.selectionOne = selectionOneValue

        let selectionTwoValue: Double = {
            if measurementSystem == .USC {
                return convertKilogramsToPoundsAndOunces(displayedValue).ounces
            } else {
                if case .high = precision {
                    let selectionTwo = Decimal(displayedValue)
                    let selectionTwoFraction =
                        selectionTwo.rounded(2, .plain)
                        - selectionTwo.rounded(0, .down)
                    return NSDecimalNumber(decimal: selectionTwoFraction)
                        .doubleValue
                } else {
                    return 0
                }
            }
        }()
        self.selectionTwo = selectionTwoValue
    }

    var body: some View {
        HStack(spacing: .zero) {

            Picker(selection: $selectionOne) {
                ForEach(primaryRange, id: \.self) { i in
                    Text(primaryPickerString(for: i))
                        .tag(i)
                }
            } label: {
                Text(primaryUnit)
            }
            .pickerStyle(.wheel)
            .onChange(of: selectionOne) { _, _ in
                selection = standardizedWeight((selectionOne, selectionTwo))
                hasChanges = true
            }

            if precision == .high {
                Picker(selection: $selectionTwo) {
                    ForEach(secondaryRange, id: \.self) { i in
                        Text(secondaryPickerString(for: i))
                            .tag(i)
                    }
                } label: {
                    if measurementSystem == .USC {
                        Text("oz")
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: selectionTwo) { _, _ in
                    selection = standardizedWeight((selectionOne, selectionTwo))
                    hasChanges = true
                }
            }

            if measurementSystem != .USC,
                precision == .high
            {
                Picker(selection: $highPrecisionSelection) {
                    ForEach(0..<1, id: \.self) { i in
                        Text("\(primaryUnit)")
                            .tag(i)
                    }
                } label: {
                    Text("Tap Here")
                }
                .pickerStyle(.wheel)
            }
        }
    }

    private func primaryPickerString(
        for value: Double
    ) -> String {
        let formatter = NumberFormatter()

        let fractionalDigits: Int = {
            if measurementSystem != .USC && precision == .default {
                return 1
            }
            return 0
        }()

        formatter.minimumFractionDigits = fractionalDigits
        formatter.minimumIntegerDigits =
            measurementSystem != .USC && self.precision == .high ? 0 : 1

        let string = formatter.string(for: value) ?? "Unknown"

        let includeUnit: Bool = {
            if measurementSystem != .USC && precision == .high {
                return false
            }
            return true
        }()

        let finalString = includeUnit ? "\(string) \(primaryUnit)" : string
        return finalString
    }

    private func secondaryPickerString(
        for value: Double
    ) -> String {
        let formatter = NumberFormatter()

        let fractionalDigits: Int = {
            if measurementSystem != .USC && precision == .high {
                return 2
            }
            return 0
        }()

        formatter.minimumFractionDigits = fractionalDigits
        formatter.minimumIntegerDigits =
            measurementSystem != .USC && self.precision == .high ? 0 : 1

        let string = formatter.string(for: value) ?? "Unknown"

        let includeUnit: Bool = {
            if measurementSystem == .USC && precision == .high {
                return true
            }
            return false
        }()

        let finalString = includeUnit ? "\(string) oz" : string
        return finalString
    }

    private func standardizedWeight(_ weight: (Double, Double)) -> Double {
        if measurementSystem == .USC {
            return convertPoundsAndOuncesToKilograms(
                pounds: weight.0, ounces: weight.1)
        } else {
            switch precision {
            case .low, .default:
                return weight.0
            case .high:
                return weight.0 + weight.1
            }
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var selection: Double? = 133
    NavigationStack {
        WeightQuestion(
            id: UUID().uuidString,
            title: "Weight question here",
            detail: nil,
            measurementSystem: .USC,
            precision: .high,
            defaultValue: 150,
            minimumValue: 0,
            maximumValue: 1430,
            weight: $selection
        )
    }
}

extension Decimal {

    fileprivate func rounded(
        _ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode
    ) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }

}
