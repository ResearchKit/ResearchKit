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
import Combine

@available(iOS 16.0, *)
struct ORKAgePickerView: View {
    @ObservedObject
    private var viewModel: ViewModel

    init(_ viewModel: ViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                if #available(iOS 18.0, *) {
                    Picker(selection: $viewModel.selectedAge) {
                        ForEach(viewModel.answers) { age in
                            Text(viewModel.formatOption(age))
                                .tag(viewModel.pickerTag(for: age))
                        }
                    } label: {
                        Text(viewModel.label)
                    } currentValueLabel: {
                        Text(
                            viewModel
                                .formatSelection(viewModel.selectedAge)
                        )
                    }
                    .labelsHidden()
                } else {
                    Picker(selection: $viewModel.selectedAge) {
                        ForEach(viewModel.answers) { age in
                            Text(viewModel.formatOption(age))
                                .tag(viewModel.pickerTag(for: age))
                        }
                    } label: {
                        Text(viewModel.label)
                    }
                    .labelsHidden()
                }
            }

            if let dontKnowAnswer = viewModel.dontKnowAnswer {
                VStack(spacing: 0) {
                    Divider()
                    DontKnowOptionView(
                        title: viewModel.formatSelection(dontKnowAnswer),
                        isActive: viewModel.selectedAge == dontKnowAnswer,
                        action: { viewModel.selectedAge = dontKnowAnswer }
                    )
                }
            }
        }
    }
}

