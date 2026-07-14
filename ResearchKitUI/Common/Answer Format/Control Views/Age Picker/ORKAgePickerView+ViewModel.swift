/*
 Copyright (c) 2025, Apple Inc. All rights reserved.
 
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

@available(iOS 16.0, *)
extension ORKAgePickerView.ViewModel: AgePickerViewModelProtocol {}

@available(iOS 16.0, *)
extension ORKAgePickerView {
    final class ViewModel: ObservableObject {
        typealias OnAnswerChangedFunction = (AgeSelection) -> Void

        let formItem: ORKFormItem
        let answerFormat: ORKAgeAnswerFormat
        private var onAnswerChanged: OnAnswerChangedFunction?

        var identifier: String {
            formItem.identifier
        }

        @Published
        var selectedAge: AgeSelection {
            didSet {
                Task { @MainActor in
                    onAnswerChanged?(selectedAge)
                }
            }
        }

        convenience init(for formItem: ORKFormItem?) {
            do {
                if let formItem = formItem {
                    try self.init(formItem: formItem)
                } else {
                    throw NSError(domain: "", code: 0, userInfo: nil)
                }
            } catch {
                self.init()
                assertionFailure("Tried to initialize \(String(describing: Self.self)) with an invalid form item. Defaulting to a form item with an ORKAgeAnswerFormat.")
            }
        }

        convenience init(formItem: ORKFormItem) throws {
            guard let answerFormat = formItem.answerFormat as? ORKAgeAnswerFormat else {
                throw NSError(
                    domain: ORKErrorDomain,
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Expected \(type(of: formItem)) to be \(type(of: ORKAgeAnswerFormat.self))"
                    ]
                )
            }
            self.init(formItem: formItem, answerFormat: answerFormat)
        }

        convenience init() {
            let answerFormat = ORKAgeAnswerFormat()
            let formItem = ORKFormItem(identifier: "", text: nil, answerFormat: answerFormat)
            self.init(formItem: formItem, answerFormat: answerFormat)
        }

        private init(formItem: ORKFormItem, answerFormat: ORKAgeAnswerFormat) {
            self.formItem = formItem
            self.answerFormat = answerFormat

            self.selectedAge = .selected(Age(answerFormat.defaultValue), format: answerFormat)
        }

        func startObserving(onAnswerChanged: @escaping OnAnswerChangedFunction) {
            self.onAnswerChanged = onAnswerChanged
        }

        func stopObserving() {
            onAnswerChanged = nil
        }

        func setSelectedAge(_ answer: Any?) {
            let formatter = AgeAnswerFormatConverter(
                usingFormat: answerFormat,
                dontKnowAnswer: dontKnowAnswer ?? defaultDontKnowAnswer
            )
            selectedAge = formatter(answer)
        }

        @available(iOS 16.0, *)
        struct AgeAnswerFormatConverter {
            let defaultAge: Age
            let selection: (Age) -> AgeSelection
            let relativeYear: Int
            let ageRange: ClosedRange<Age>
            let dontKnowAnswer: AgeSelection

            fileprivate init(
                usingFormat answerFormat: ORKAgeAnswerFormat,
                dontKnowAnswer: AgeSelection
            ) {
                self.selection = { .selected($0, format: answerFormat) }
                self.ageRange = Age(answerFormat.minimumAge)...Age(answerFormat.maximumAge)
                self.dontKnowAnswer = dontKnowAnswer
                self.relativeYear = answerFormat.relativeYear

                let potentialDefaultAge = Age(answerFormat.defaultValue)
                self.defaultAge = if ageRange.contains(potentialDefaultAge) {
                    potentialDefaultAge
                } else {
                    ageRange.lowerBound
                }
            }

            private var birthYearRange: ClosedRange<Int> {
                (relativeYear - ageRange.upperBound.rawValue)...(
                    relativeYear - ageRange.lowerBound.rawValue
                )
            }

            fileprivate func convert(from anyObject: Any?) -> AgeSelection {
                guard let anyObject, !(anyObject is NSNull) else {
                    return selection(defaultAge)
                }
                guard let selectedAge = Age(from: anyObject) else {
                    return dontKnowAnswer
                }
                return if ageRange.contains(selectedAge) {
                        selection(selectedAge)
                    } else if selectedAge == ORKAgeAnswerFormat.maximumAgeSentinelValue() {
                            selection(ageRange.upperBound)
                    } else if selectedAge == ORKAgeAnswerFormat.minimumAgeSentinelValue() {
                            selection(ageRange.lowerBound)
                    } else if birthYearRange.contains(selectedAge.rawValue) {
                        selection(relativeYear - selectedAge)
                    } else {
                        dontKnowAnswer
                    }
            }

            func callAsFunction(_ anyObject: Any?) -> AgeSelection {
                convert(from: anyObject)
            }
        }
        
        var label: String {
            formItem.text ?? formItem.description
        }

        var dontKnowAnswer: AgeSelection? {
            if answerFormat.shouldShowDontKnowButton {
                if let customMessage = answerFormat.customDontKnowButtonText {
                    .preferNotToAnswer(message: customMessage)
                } else {
                    defaultDontKnowAnswer
                }
            } else {
                nil
            }
        }

        var defaultDontKnowAnswer: AgeSelection {
            .preferNotToAnswer(message: ORKLocalizedHiddenString("SLIDER_I_DONT_KNOW"))
        }

        var answers: [Age] {
            (answerFormat.minimumAge...answerFormat.maximumAge)
                .map {
                    Age($0)
                }
        }

        func pickerTag(for age: Age) -> AgeSelection {
            .selected(age, format: answerFormat)
        }

        func formatOption(_ age: Age) -> String {
            let format: AgeFormat = if age == answerFormat.minimumAge, let customText = answerFormat.minimumAgeCustomText {
                .customMessage(customText)
            } else if age == answerFormat.maximumAge, let customText = answerFormat.maximumAgeCustomText {
                .customMessage(customText)
            } else if answerFormat.showYear {
                .birthYearWithAge
            } else {
                .ageOnly
            }
            return format(age, relativeTo: answerFormat.relativeYear)
        }

        func formatSelection(_ age: AgeSelection) -> String {
            let format: AgeFormat = if age == answerFormat.minimumAge, let customText = answerFormat.minimumAgeCustomText {
                .customMessage(customText)
            } else if age == answerFormat.maximumAge, let customText = answerFormat.maximumAgeCustomText {
                .customMessage(customText)
            } else if answerFormat.useYearForResult {
                .birthYear
            } else if case .preferNotToAnswer(let message) = age {
                .customMessage(message)
            } else {
                .ageOnly
            }

            return format(age)
        }
    }
}

struct Age: Identifiable, Hashable, Comparable, ExpressibleByIntegerLiteral, CustomStringConvertible {

    let rawValue: Int

    var id: Int {
        rawValue
    }

    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }

    init(integerLiteral: Int) {
        self.rawValue = integerLiteral
    }

    init?(from anyObject: Any?) {
        guard let age = anyObject.flatMap ({ $0 as? Int })
        else { return nil }
        self.init(age)
    }

    var description: String {
        String(rawValue)
    }

    static func - (lhs: Int, rhs: Age) -> Age {
        .init(lhs - rhs.rawValue)
    }

    static func < (lhs: Age, rhs: Age) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static func == <T>(left: Age, right: T) -> Bool where T: BinaryInteger {
        left.rawValue == right
    }
}

enum AgeSelection: Hashable, ExpressibleByIntegerLiteral {
    case preferNotToAnswer(message: String)
    case selected(Age, format: ORKAgeAnswerFormat)

    init(integerLiteral: Int) {
        self = .selected(Age(integerLiteral), format: .init())
    }

    var objectValue: Any {
        switch self {
            case .preferNotToAnswer: ORKDontKnowAnswer.answer()
            case .selected(let age, let format):
                if format.treatMinAgeAsRange && age.rawValue == format.minimumAge {
                    ORKAgeAnswerFormat.minimumAgeSentinelValue()
                } else if format.treatMaxAgeAsRange && age.rawValue == format.maximumAge {
                    ORKAgeAnswerFormat.maximumAgeSentinelValue()
                } else if format.useYearForResult {
                    format.relativeYear - age.rawValue
                } else {
                    age.rawValue
                }
        }
    }

    var age: Age? {
        switch self {
            case .preferNotToAnswer: nil
            case .selected(let age, format: _):
                age
        }
    }
}

enum AgeFormat {
    case customMessage(String)
    case ageOnly
    case birthYearWithAge
    case birthYear

    private func format(_ age: Age, relativeTo year: Int) -> String {
        switch self {
            case .customMessage(let message):
                message
            case .ageOnly:
                String(age.rawValue)
            case .birthYearWithAge:
                "\(year - age.rawValue) (\(age))"
            case .birthYear:
                "\(year - age.rawValue)"
        }
    }

    func callAsFunction(_ age: Age, relativeTo year: Int) -> String {
        format(age, relativeTo: year)
    }

    func callAsFunction(_ age: AgeSelection) -> String {
        switch age {
            case .preferNotToAnswer(let message):
                message
            case .selected(let age, let answerFormat):
                format(age, relativeTo: answerFormat.relativeYear)
        }
    }
}

extension AgeSelection {
    public static func == (lhs: Self, rhs: Int) -> Bool {
        switch lhs {
            case .selected(let age, _): return age == rhs
            default: return false
        }
    }
}
