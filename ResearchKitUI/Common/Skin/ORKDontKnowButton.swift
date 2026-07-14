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
import UIKit

// MARK: - TEMPORARY SHIM

/// A `UIControl` subclass that hosts a `DontKnowButtonView` via a `UIHostingController`.
/// `UIControl` handles all touch input; the SwiftUI view is purely for rendering.
/// ObjC callers use `addTarget:action:forControlEvents:UIControlEventTouchUpInside` unchanged.
@objc(ORKDontKnowButton)
public final class ORKDontKnowButton: UIControl {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    @objc
    public var customDontKnowButtonText: String? {
        didSet { updateHostedView() }
    }

    @objc
    public var active: Bool = false {
        didSet { updateHostedView() }
    }

    /// Deprecated — kept as a no-op for binary compatibility.
    @available(*, deprecated, message: "dontKnowButtonStyle is deprecated and will be removed in a future release.")
    @objc
    public var dontKnowButtonStyle: Int = 0
    
    private var hostingController: UIHostingController<DontKnowOptionView>?

    private func setup() {
        let hc = UIHostingController(rootView: makeSwiftUIView())
        hc.view.backgroundColor = .clear
        // Disable interaction on the hosted view so touches reach this UIControl directly.
        hc.view.isUserInteractionEnabled = false
        hc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hc.view)
        NSLayoutConstraint.activate([
            hc.view.topAnchor.constraint(equalTo: topAnchor),
            hc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        hostingController = hc
    }

    private func updateHostedView() {
        hostingController?.rootView = makeSwiftUIView()
    }

    private func makeSwiftUIView() -> DontKnowOptionView {
        DontKnowOptionView(
            title: customDontKnowButtonText ?? ORKLocalizedHiddenString("SLIDER_I_DONT_KNOW"),
            isActive: active,
            action: {}  // Interaction is handled by UIControl; action is unused.
        )
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 46)
    }
}

// MARK: - Accessibility

extension ORKDontKnowButton {
    override public var isAccessibilityElement: Bool {
        get { true }
        set { }
    }

    override public var accessibilityLabel: String? {
        get { hostingController?.rootView.accessibilityLabelText }
        set { }
    }
}
