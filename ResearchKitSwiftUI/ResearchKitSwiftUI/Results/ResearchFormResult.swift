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

import Combine
import SwiftUI

/// Represents responses for the different kinds of questions.
public enum AnswerFormat {
    case text(String?)
    case numeric(Double?)
    case date(Date?)
    case weight(Double?)
    case height(Double?)
    case multipleChoice([ResultValue]?)
    case image([ResultValue]?)
    case scale(Double?)
}

extension AnswerFormat: Codable {}

extension AnswerFormat: Equatable {

    public static func == (lhs: AnswerFormat, rhs: AnswerFormat) -> Bool {
        let isEqual: Bool

        switch (lhs, rhs) {
        case let (.text(lhsValue), .text(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.numeric(lhsValue), .numeric(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.date(lhsValue), .date(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.weight(lhsValue), .weight(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.height(lhsValue), .height(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.multipleChoice(lhsValue), .multipleChoice(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.image(lhsValue), .image(rhsValue)):
            isEqual = lhsValue == rhsValue
        case let (.scale(lhsValue), .scale(rhsValue)):
            isEqual = lhsValue == rhsValue
        default:
            isEqual = false

        }

        return isEqual
    }

}

/// Captures the responses to questions for which no binding has been provided. It is passed through ``ResearchForm``'s `onResearchFormCompletion` handler, which is passed through the initializer, upon survey completion.
public final class ResearchFormResult: ObservableObject {

    private var stepResults: [String: AnswerFormat]

    /// Initializes an instance of ``ResearchFormResult`` that contains no responses.
    public convenience init() {
        self.init(results: [])
    }

    /// Initializes an instance of ``ResearchFormResult`` with the provided configuration.
    /// - Parameter results: The results from which an instance of `ResearchFormResult` is created.
    public init(results: [Result]) {
        stepResults = results.reduce(into: [String: AnswerFormat]()) {
            partialResult, result in
            partialResult[result.identifier] = result.answer
        }
    }

    /// Initializes an instance of ``ResearchFormResult`` with the provided configuration.
    /// - Parameter decoder: The decoder used to deserialize an instance of `ResearchFormResult`.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stepResults = try container.decode(
            [String: AnswerFormat].self, forKey: .stepResults)
    }

    func resultForStep<Result>(key: StepResultKey<Result>) -> Result? {
        let answerFormat = stepResults[key.id]
        switch answerFormat {
        case let .text(answer):
            return answer as? Result
        case .numeric(let decimal):
            return decimal as? Result
        case .date(let date):
            return date as? Result
        case .height(let height):
            return height as? Result
        case .weight(let weight):
            return weight as? Result
        case .image(let image):
            return image as? Result
        case .multipleChoice(let multipleChoice):
            return multipleChoice as? Result
        case .scale(let double):
            return double as? Result
        default:
            return nil
        }
    }

    func setResultForStep<Result>(
        _ format: AnswerFormat, key: StepResultKey<Result>
    ) {
        stepResults[key.id] = format
    }

    /// Maps the captured responses to a type of your choice.
    /// - Parameter transform: The mapping function used to transform a response to a type of your choice.
    /// - Returns: An array containing the type to which the responses were transformed.
    public func compactMap<T>(_ transform: (Result) -> T?) -> [T] {
        stepResults.compactMap { entry in
            transform(
                Result(identifier: entry.key, answer: entry.value)
            )
        }
    }
}

/// The response context for a question.
public struct Result {

    /// The question identifier associated with this result.
    public let identifier: String

    /// The response to the question associated with the `identifier`.
    public let answer: AnswerFormat

    /// Initializes an instance of ``Result`` with the provided configuration.
    /// - Parameters:
    ///   - identifier: The question identifier associated with this response.
    ///   - answer: The response to the question associated with the `identifier`.
    public init(identifier: String, answer: AnswerFormat) {
        self.identifier = identifier
        self.answer = answer
    }

}

extension ResearchFormResult: Codable {

    enum CodingKeys: CodingKey {

        case stepResults

    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(stepResults, forKey: .stepResults)
    }

}

extension ResearchFormResult: Equatable {

    public static func == (lhs: ResearchFormResult, rhs: ResearchFormResult)
        -> Bool
    {
        lhs.stepResults == rhs.stepResults
    }

}

extension EnvironmentValues {
    
    var questionContext: QuestionContext {
        get {
            self[QuestionContextKey.self]
        }
        set {
            self[QuestionContextKey.self] = newValue
        }
    }
    
}

enum QuestionContext {
    
    case standalone, formEmbedded
    
}

private struct QuestionContextKey: EnvironmentKey {
    
    static var defaultValue: QuestionContext = .standalone
    
}
