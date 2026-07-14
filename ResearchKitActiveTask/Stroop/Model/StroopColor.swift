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

import SwiftUI
import ResearchKitUI

/// A representation of the possible color options for the questions of the Stroop Active Task.
///
/// A ``StroopColor`` case can refer to both the content of the text of the question and the color
/// of the text of the question (e.g. it's appropriate to say that the ``StroopColor`` of a question
/// whose text reads "Red" is `.red`).
public enum StroopColor: String, Codable, CaseIterable, Sendable, Identifiable, CustomStringConvertible {
    case red
    case green
    case yellow
    case blue
    case orange
    case brown
    case pink
    case purple
    case gray

    /// Refers to a context where there is no color, such as the text of a neutral prompt.
    case none

    public var id: Self {
        self
    }

    /// The preferred name to refer to the color.
    var displayName: String {
        switch self {
            case .red: "Red"
            case .green: "Green"
            case .yellow: "Yellow"
            case .blue: "Blue"
            case .brown: "Brown"
            case .gray: "Gray"
            case .orange: "Orange"
            case .pink: "Pink"
            case .purple: "Purple"
            case .none: "XXXX"
        }
    }

    /// The participant-facing color name, localized from the `STROOP_COLOR_*` strings.
    ///
    /// Use this for any on-screen text. ``displayName`` stays in English for recorded results and
    /// accessibility identifiers; this varies by language. `.none` has no color word, so it falls
    /// back to ``displayName``.
    var localizedName: String {
        guard let key = localizationKey else { return displayName }
        return ORKLocalizedHiddenString(key)
    }

    private var localizationKey: String? {
        switch self {
            case .red: "STROOP_COLOR_RED"
            case .green: "STROOP_COLOR_GREEN"
            case .blue: "STROOP_COLOR_BLUE"
            case .yellow: "STROOP_COLOR_YELLOW"
            case .orange: "STROOP_COLOR_ORANGE"
            case .brown: "STROOP_COLOR_BROWN"
            case .pink: "STROOP_COLOR_PINK"
            case .purple: "STROOP_COLOR_PURPLE"
            case .gray: "STROOP_COLOR_GRAY"
            case .none: nil
        }
    }

    var displayColor: Color {
        switch self {
            case .red: .red
            case .blue: .blue
            case .green: .green
            case .yellow: .yellow
            case .brown: .brown
            case .gray: .gray
            case .pink: .pink
            case .purple: .purple
            case .orange: .orange
            case .none: .clear
        }
    }

    public var description: String {
        displayName
    }
}
