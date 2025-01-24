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

/// Represents the different measurement systems that can be used.
public enum MeasurementSystem {

    /// The US Customary measurement system.
    case USC

    /// The measurement system defined by the system.
    case local

    /// The metric measurement system.
    case metric

}

/// A question that allows for height input.
public struct HeightQuestion: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult
    
    @Environment(\.questionContext)
    private var questionContext: QuestionContext

    @Environment(\.questionRequired)
    private var isRequired: Bool
    
    @State
    private var managedHeight: Double?

    @State private var isInputActive = false
    @State private var hasChanges: Bool

    private let id: String
    private let title: String
    private let detail: String?
    private let measurementSystem: MeasurementSystem
    private let selection: StateManagementType<Double?>

    private var initialPrimaryValue: Double = 162  // Denotes height in cm, which is ~5'4", a good average height.

    private var resolvedResult: Binding<Double?> {
        switch selection {
        case let .automatic(key: key):
            return Binding(
                get: {
                    let height: Double?
                    if let managedHeight {
                        height = managedHeight
                    } else {
                        switch questionContext {
                        case .formEmbedded:
                            height = managedFormResult.resultForStep(key: key) ?? initialPrimaryValue
                        case .standalone:
                            height = initialPrimaryValue
                        }
                    }
                    return height
                },
                set: {
                    managedHeight = $0
                    
                    if case .formEmbedded = questionContext {
                        managedFormResult.setResultForStep(.height($0), key: key)
                    }
                }
            )
        case let .manual(value):
            return value
        }
    }

    /// Initializes an instance of ``HeightQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - measurementSystem: The measurement system for this question.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem
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
        self.selection = .automatic(key: .height(id: id))
    }

    /// Initializes an instance of ``HeightQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - measurementSystem: The measurement system for this question.
    ///   - height: The selected height.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        measurementSystem: MeasurementSystem,
        height: Binding<Double?>
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
        self.selection = .manual(height)
    }

    private var selectionString: String {
        guard let result = resolvedResult.wrappedValue else {
            return "\(Int(initialPrimaryValue)) cm"
        }
        if measurementSystem == .USC {
            let (feet, inches) = convertCentimetersToFeetAndInches(result)
            return "\(feet)' \(inches)\""
        } else {
            return "\(Int(result)) cm"
        }
    }

    public var body: some View {
        QuestionCard {
            Question(title: title, detail: detail) {
                HStack {
                    Text("Select Height")
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
                    #if !os(watchOS)
                        .popover(
                            isPresented: $isInputActive,
                            attachmentAnchor: .point(.bottom),
                            arrowEdge: .top
                        ) {
                            HeightPickerView(
                                measurementSystem: measurementSystem,
                                selection: resolvedResult,
                                hasChanges: $hasChanges
                            )
                            .frame(width: 300)
                            .presentationCompactAdaptation((.popover))
                        }
                    #else
                        .navigationDestination(
                            isPresented: $isInputActive
                        ) {
                            HeightPickerView(
                                measurementSystem: measurementSystem,
                                selection: resolvedResult,
                                hasChanges: $hasChanges
                            )
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

struct HeightPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstSelection: Int
    @State private var secondSelection: Int
    private let footToCentimetersMultiplier: Double = 30.48
    private let inchToCentimetersMultiplier: Double = 2.54

    private let measurementSystem: MeasurementSystem

    @Binding private var selection: Double?
    @Binding private var hasChanges: Bool

    init(
        measurementSystem: MeasurementSystem,
        selection: Binding<Double?>,
        hasChanges: Binding<Bool>
    ) {
        self.measurementSystem = measurementSystem
        self._selection = selection
        self._hasChanges = hasChanges

        guard let centimeters = selection.wrappedValue else {
            firstSelection = 0
            secondSelection = 0
            return
        }
        if Self.usesMetricSystem(measurementSystem: measurementSystem) == false
        {
            let (feet, inches) = convertCentimetersToFeetAndInches(centimeters)
            firstSelection = feet
            secondSelection = inches
        } else {
            firstSelection = Int(centimeters)
            secondSelection = 0
        }
    }

    private var upperValue: Int {
        if measurementSystem == .USC {
            return 10
        } else {
            return 300
        }
    }

    private var secondaryUpperValue: Int {
        // Numbers up to 1 foot or 12 inches
        return 12
    }

    private var primaryUnit: String {
        if measurementSystem == .USC {
            return "ft"
        } else {
            return "cm"
        }
    }

    private var secondaryUnit: String {
        return "in"
    }

    var body: some View {
        HStack(spacing: .zero) {
            Picker(selection: $firstSelection) {
                ForEach(0..<upperValue, id: \.self) { i in
                    Text("\(i) \(primaryUnit)")
                        .tag(i)
                }
            } label: {
                Text(primaryUnit)
            }
            .pickerStyle(.wheel)
            .onChange(of: firstSelection) { _, _ in
                hasChanges = true
                selection = standardizedHeight(
                    (firstSelection, secondSelection))
            }

            if measurementSystem == .USC {
                Picker(selection: $secondSelection) {
                    ForEach(0..<secondaryUpperValue, id: \.self) { i in
                        Text("\(i) \(secondaryUnit)")
                            .tag(i)
                    }
                } label: {
                    Text(secondaryUnit)
                }
                .pickerStyle(.wheel)
                .onChange(of: secondSelection) { _, _ in
                    hasChanges = true
                    selection = standardizedHeight(
                        (firstSelection, secondSelection))
                }
            }
        }
    }

    private func standardizedHeight(_ height: (Int, Int)) -> Double {
        if Self.usesMetricSystem(measurementSystem: measurementSystem) == false
        {
            let centimeters =
                (Double(height.0) * footToCentimetersMultiplier)
                + (Double(height.1) * inchToCentimetersMultiplier)
            return centimeters
        } else {
            return Double(height.0)
        }
    }

    private static func usesMetricSystem(measurementSystem: MeasurementSystem)
        -> Bool
    {
        switch measurementSystem {
        case .USC:
            return false
        case .local:
            if Locale.current.measurementSystem == .us {
                return false
            } else {
                return true
            }
        case .metric:
            return true
        }
    }
}

@available(iOS 18.0, *)
#Preview {
    @Previewable @State var selection: Double? = 162
    NavigationStack {
        HeightQuestion(
            id: UUID().uuidString,
            title: "Height question here",
            detail: nil,
            measurementSystem: .USC,
            height: $selection
        )
    }
}
