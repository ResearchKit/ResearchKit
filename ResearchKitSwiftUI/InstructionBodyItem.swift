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

/// Displays an image and text side by side.
public struct InstructionBodyItem: View {

    private let image: Image?
    private let text: Text?

    /// Initializes an instance of ``InstructionBodyItem`` with the provided configuration.
    /// - Parameters:
    ///   - image: The image to display for this instruction.
    ///   - text: The text to display for this instruction.
    public init(image: Image? = nil, text: Text? = nil) {
        self.image = image
        self.text = text
    }

    public var body: some View {
        #if os(watchOS)
            VStack(alignment: .leading) {
                image?
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.bodyItemIconForegroundStyle)

                text?
                    .font(.subheadline)
            }
            .preference(key: QuestionCardPreferenceKey.self, value: false)
        #else
            HStack {
                image?
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.bodyItemIconForegroundStyle)

                text?
                    .font(.subheadline)
            }
            .preference(key: QuestionCardPreferenceKey.self, value: false)
        #endif
    }
}

struct QuestionCardPreferenceKey: PreferenceKey {

    static var defaultValue = true

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }

}

#Preview {
    ScrollView {
        ResearchFormStep(
            image: Image(systemName: "doc.text.magnifyingglass"),
            title: "Before You Join join"
        ) {
            InstructionBodyItem(
                image: Image(systemName: "heart.fill"),
                text: Text(
                    "The study will ask you to share some of your Health data.")
            )

            InstructionBodyItem(
                image: Image(systemName: "checkmark.circle.fill"),
                text: Text(
                    "You will be asked to complete various tasks over the duration of the study."
                )
            )

            InstructionBodyItem(
                image: Image(systemName: "signature"),
                text: Text(
                    "Before joining, we will ask you to sign an informed consent document."
                )
            )

            InstructionBodyItem(
                image: Image(systemName: "lock.fill"),
                text: Text("Your data is kept private and secure.")
            )
        }
    }
}
