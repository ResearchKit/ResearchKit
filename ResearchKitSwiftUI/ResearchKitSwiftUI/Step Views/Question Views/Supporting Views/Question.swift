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

struct Question<Header: View, Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    private let header: Header
    private let content: Content

    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header

            Divider()
                .padding(.horizontal)

            content
        }
    }
}

extension Question where Header == QuestionHeader {
    init(
        title: String,
        detail: String? = nil,
        content: () -> Content
    ) {
        self.header = QuestionHeader(title: title, detail: detail)
        self.content = content()
    }
}

/// A question header containing a title and detail.
public struct QuestionHeader: View {

    private let title: String
    private let detail: String?

    init(title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleText(title)

            if let detail {
                Text(detail)
                    .font(detailFont)
            }
        }
        #if os(watchOS)
            .padding(.horizontal)
            .padding(.bottom, 4)
            .padding(.top, 4)
        #else
            .padding()
        #endif
    }

    @ViewBuilder
    private func titleText(_ text: String) -> some View {
        Text(title)
            .foregroundStyle(Color.choice(for: .label))
            .fontWeight(.bold)
            #if os(watchOS)
                .font(.footnote)
            #else
                .font(.body)
            #endif
    }

    private var detailFont: Font {
        #if os(watchOS)
            .system(size: 12)
        #else
            .subheadline
        #endif
    }

}

#Preview("Detail and Title") {
    VStack {
        Spacer()
        Question(title: "What is your name?") {
            Text("Specific component content will show up here")
        }
        Spacer()
    }
    .padding()
    .background {
        Color.choice(for: .secondaryBackground)
    }
    .ignoresSafeArea()
}

#Preview("Just title") {
    VStack {
        Spacer()
        Question(title: "What is your name?") {
            Text("Specific component content will show up here")
        }
        Spacer()
    }
    .padding()
    .background {
        Color.choice(for: .secondaryBackground)
    }
    .ignoresSafeArea()
}
