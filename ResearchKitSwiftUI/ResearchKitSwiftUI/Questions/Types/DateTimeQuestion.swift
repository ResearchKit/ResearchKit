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

/// A question that allows for date and time input.
public struct DateTimeQuestion<Header: View>: View {

    @EnvironmentObject
    private var managedFormResult: ResearchFormResult
    
    @Environment(\.questionContext)
    private var questionContext: QuestionContext

    @Environment(\.questionRequired)
    private var isRequired: Bool
    
    @State
    private var managedDate: Date?

    @State
    private var showDatePickerModal = false

    @State
    private var showTimePickerModal = false
    private let id: String
    private let header: Header
    private let pickerPrompt: String
    private let displayedComponents: DatePicker.Components
    private let range: ClosedRange<Date>
    private let selection: StateManagementType<Date?>

    private var resolvedResult: Binding<Date?> {
        switch selection {
        case let .automatic(key: key):
            return Binding(
                get: {
                    let date: Date?
                    if let managedDate {
                        date = managedDate
                    } else {
                        switch questionContext {
                        case .formEmbedded:
                            date = managedFormResult.resultForStep(key: key) ?? Date()
                        case .standalone:
                            date = Date()
                        }
                    }
                    return date
                },
                set: {
                    managedDate = $0
                    
                    if case .formEmbedded = questionContext {
                        managedFormResult.setResultForStep(.date($0), key: key)
                    }
                }
            )
        case let .manual(value):
            return value
        }
    }

    /// Initializes an instance of ``DateTimeQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - header: The header for this question.
    ///   - date: The selected date.
    ///   - pickerPrompt: The prompt that informs the user.
    ///   - displayedComponents: The date-time components that are displayed for this question.
    ///   - range: The range of selectable dates.
    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        date: Date = Date(),
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = header()
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.selection = .automatic(key: .date(id: id))
    }

    /// Initializes an instance of ``DateTimeQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - header: The header for this question.
    ///   - date: The selected date.
    ///   - pickerPrompt: The prompt that informs the user.
    ///   - displayedComponents: The date-time components that are displayed for this question.
    ///   - range: The range of selectable dates.
    public init(
        id: String,
        @ViewBuilder header: () -> Header,
        date: Binding<Date?>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = header()
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.selection = .manual(date)
    }

    public var body: some View {
        QuestionCard {
            Question {
                header
            } content: {
                #if os(watchOS)
                    VStack {
                        if displayedComponents.contains(.date) {
                            Button {
                                showDatePickerModal.toggle()
                            } label: {
                                Text(
                                    resolvedResult.wrappedValue ?? Date(),
                                    format: .dateTime.day().month().year()
                                )
                            }
                        }

                        if displayedComponents.contains(.hourMinuteAndSecond) {
                            Button {
                                showTimePickerModal.toggle()
                            } label: {
                                Text(
                                    resolvedResult.wrappedValue ?? Date(),
                                    format: .dateTime.hour().minute().second()
                                )
                            }
                        } else if displayedComponents.contains(.hourAndMinute) {
                            Button {
                                showTimePickerModal.toggle()
                            } label: {
                                Text(
                                    resolvedResult.wrappedValue ?? Date(),
                                    format: .dateTime.hour().minute()
                                )
                            }
                        }
                    }
                    .buttonBorderShape(.roundedRectangle)
                    .buttonStyle(.bordered)
                    .padding()
                    .navigationDestination(isPresented: $showDatePickerModal) {
                        watchDatePicker(displayedComponents: .date)
                    }
                    .navigationDestination(isPresented: $showTimePickerModal) {
                        watchDatePicker(
                            displayedComponents: displayedComponents.contains(
                                .hourMinuteAndSecond)
                                ? .hourMinuteAndSecond : .hourAndMinute)
                    }
                #else
                    DatePicker(
                        pickerPrompt,
                        selection: resolvedResult.unwrapped(
                            defaultValue: Date()),
                        in: range,
                        displayedComponents: displayedComponents
                    )
                    .datePickerStyle(.compact)
                    .foregroundStyle(.primary)
                    .padding()
                #endif
            }
            .preference(
                key: QuestionRequiredPreferenceKey.self, value: isRequired
            )
            .preference(
                key: QuestionAnsweredPreferenceKey.self, value: isAnswered)
        }
    }

    @ViewBuilder
    private func watchDatePicker(displayedComponents: DatePicker.Components)
        -> some View
    {
        VStack(alignment: .leading) {
            header
            DatePicker(
                pickerPrompt,
                selection: resolvedResult.unwrapped(defaultValue: Date()),
                in: range,
                displayedComponents: displayedComponents
            )
            #if !os(watchOS)
                .padding(.horizontal)
            #endif
        }
    }

    private var isAnswered: Bool {
        return resolvedResult.wrappedValue != nil
    }
}

extension DateTimeQuestion where Header == QuestionHeader {

    /// Initializes an instance of ``DateTimeQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - date: The selected date.
    ///   - pickerPrompt: The prompt that informs the user.
    ///   - displayedComponents: The date-time components that are displayed for this question.
    ///   - range: The range of selectable dates.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        date: Date = Date(),
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = QuestionHeader(title: title, detail: detail)
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.selection = .automatic(key: .date(id: id))
    }

    /// Initializes an instance of ``DateTimeQuestion`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this question.
    ///   - title: The title for this question.
    ///   - detail: The details for this question.
    ///   - date: The selected date.
    ///   - pickerPrompt: The prompt that informs the user.
    ///   - displayedComponents: The date-time components that are displayed for this question.
    ///   - range: The range of selectable dates.
    public init(
        id: String,
        title: String,
        detail: String? = nil,
        date: Binding<Date?>,
        pickerPrompt: String,
        displayedComponents: DatePicker.Components,
        range: ClosedRange<Date>
    ) {
        self.id = id
        self.header = QuestionHeader(title: title, detail: detail)
        self.pickerPrompt = pickerPrompt
        self.displayedComponents = displayedComponents
        self.range = range
        self.selection = .manual(date)
    }

}

#Preview("Date Only") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeQuestion(
                id: UUID().uuidString,
                title: "What is your birthday?",
                detail: "Question 1 of 4",
                date: $date,
                pickerPrompt: "Select Date",
                displayedComponents: [.date],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

#Preview("Time Only") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeQuestion(
                id: UUID().uuidString,
                title: "What time is it?",
                detail: "Question 2 of 4",
                date: $date,
                pickerPrompt: "Select Time",
                displayedComponents: [.hourAndMinute],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}

#Preview("Time and Date") {
    @Previewable @State var date: Date? = Date()
    NavigationStack {
        ScrollView {
            DateTimeQuestion(
                id: UUID().uuidString,
                title: "What is the time and date?",
                detail: "Question 2 of 4",
                date: $date,
                pickerPrompt: "Select Time and Date",
                displayedComponents: [.date, .hourAndMinute],
                range: Date.distantPast...Date.distantFuture
            )
            .padding(.horizontal)
        }
    }
}
