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

/// Represents a text choice.
public struct TextChoice: Identifiable {

    /// The id for this multiple choice option.
    public let id: String
    let choiceText: String
    let value: ResultValue

    /// Initializes an instance of ``TextChoice`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this multiple choice option.
    ///   - choiceText: The text for this multiple choice option.
    ///   - value: The integer value associated with this multiple choice option.
    public init(
        id: String,
        choiceText: String,
        value: Int
    ) {
        self.init(id: id, choiceText: choiceText, value: .int(value))
    }

    /// Initializes an instance of ``TextChoice`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this multiple choice option.
    ///   - choiceText: The text for this multiple choice option.
    ///   - value: The string value associated with this multiple choice option.
    public init(
        id: String,
        choiceText: String,
        value: String
    ) {
        self.init(id: id, choiceText: choiceText, value: .string(value))
    }

    /// Initializes an instance of ``TextChoice`` with the provided configuration.
    /// - Parameters:
    ///   - id: The unique identifier for this multiple choice option.
    ///   - choiceText: The text for this multiple choice option.
    ///   - value: The date value associated with this multiple choice option.
    public init(
        id: String,
        choiceText: String,
        value: Date
    ) {
        self.init(id: id, choiceText: choiceText, value: .date(value))
    }

    private init(
        id: String,
        choiceText: String,
        value: ResultValue
    ) {
        self.id = id
        self.choiceText = choiceText
        self.value = value
    }

}
