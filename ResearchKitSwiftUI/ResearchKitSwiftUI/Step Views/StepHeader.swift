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

/// A step header containing an image, title, and subtitle.
public struct StepHeader: View {

    private let image: Image?
    private let title: Text?
    private let subtitle: Text?

    /// Initializes an instance of ``StepHeader`` with the provided configuration.
    /// - Parameters:
    ///   - image: The image for this step header.
    ///   - title: The title for this step header.
    ///   - subtitle: The subtitle for this header.
    init(image: Image? = nil, title: Text? = nil, subtitle: Text? = nil) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        #if os(watchOS)
            compactBody()
        #else
            defaultBody()
        #endif
    }

    @ViewBuilder
    private func compactBody() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                icon(size: 20)

                title?
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            subtitle
                .font(.body)
        }
    }

    @ViewBuilder
    private func defaultBody() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            icon(size: 80)

            title?
                .font(.title)
                .fontWeight(.bold)

            subtitle
        }
    }

    @ViewBuilder
    private func icon(size: CGFloat) -> some View {
        image?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(.stepIconForegroundStyle)
    }
}

#Preview {
    StepHeader(
        image: Image(systemName: "hand.wave"),
        title: Text("Welcome"),
        subtitle: Text("Hello")
    )
}
