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

extension Color {
    public enum ColorChoice {
        case background
        case secondaryBackground
        case label
        case systemGray4
        case systemGray5
    }

    public static func choice(for choice: ColorChoice) -> Color {
        switch choice {
        case .background:
            #if os(watchOS)
                return Color.primary
            #else
                return Color(uiColor: UIColor.systemBackground)
            #endif

        case .secondaryBackground:
            #if os(watchOS)
                return Color.secondary
            #else
                return Color(uiColor: UIColor.secondarySystemBackground)
            #endif

        case .label:
            #if os(watchOS)
                return Color.primary
            #else
                return Color(uiColor: UIColor.label)
            #endif

        case .systemGray4:
            #if os(watchOS)
                return Color.secondary.opacity(0.4)
            #else
                return Color(uiColor: UIColor.systemGray4)
            #endif
        case .systemGray5:
            #if os(watchOS)
                return Color.secondary.opacity(0.5)
            #else
                return Color(uiColor: UIColor.systemGray5)
            #endif
        }
    }
}
