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

import Foundation
import UIKit
import SwiftUI

protocol AgePickerViewModelProtocol {
    init(for formItem: ORKFormItem?)
    func setSelectedAge(_ selectedAge: Any?)
    func startObserving(onAnswerChanged: @escaping (AgeSelection) -> Void)
    func stopObserving()
}

@objc public class ORKAgePickerFormItemCell: ORKFormItemCell {
    private var viewModel: AgePickerViewModelProtocol?

    public override func configure(
        with formItem: ORKFormItem,
        answer: Any,
        maxLabelWidth: CGFloat,
        delegate: any ORKFormItemCellDelegate
    ) {
        guard #available(iOS 16.0, *) else { return }

        let viewModel = ORKAgePickerView.ViewModel(for: formItem)
        self.viewModel = viewModel

        super.configure(
            with: formItem,
            answer: answer,
            maxLabelWidth: maxLabelWidth,
            delegate: delegate
        )

        start(viewModel: viewModel)
        addCellContent()
    }

    public override var answer: Any? {
        didSet {
            viewModel?.setSelectedAge(answer)
        }
    }

    @available(iOS 16.0, *)
    private func start(viewModel: ORKAgePickerView.ViewModel) {
        viewModel.startObserving(onAnswerChanged: { [weak cell = self, delegate] age in
            guard let cell, let delegate else { return }
            delegate.formItemCell(cell, answerDidChangeTo: age.objectValue)
        })
    }

    private func addCellContent() {
        guard let viewModel, #available(iOS 16.0, *) else { return }

        @ViewBuilder
        func makeBody(with viewModel: AgePickerViewModelProtocol) -> some View {
            if let viewModel = viewModel as? ORKAgePickerView.ViewModel {
                contentView(for: viewModel)
            } else {
                EmptyView()
            }
        }

        let bodyView = UIHostingConfiguration(content: { makeBody(with: viewModel) })
            .margins(.top, 8)
            .margins(.bottom, 3)
            .makeContentView()
        containerView.addFullSizedSubview(bodyView)
    }

    private func removeCellContent() {
        guard let viewModel, #available(iOS 16.0, *) else { return }
        viewModel.stopObserving()
        containerView.subviews.forEach { $0.removeFromSuperview() }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        removeCellContent()
    }

    @available(iOS 16.0, *)
    @ViewBuilder
    func contentView(for viewModel: ORKAgePickerView.ViewModel) -> some View {
        ORKAgePickerView(viewModel)
    }
}
