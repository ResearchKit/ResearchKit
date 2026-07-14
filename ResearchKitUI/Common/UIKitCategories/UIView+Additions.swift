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

extension UIView {
    private func horizontalFullSizeConstraints(to subview: UIView) -> [NSLayoutConstraint] {
        let contentGuide = layoutMarginsGuide
        let subviewGuide = subview.safeAreaLayoutGuide

        let contentViewXAnchors = [
            contentGuide.leadingAnchor,
            contentGuide.trailingAnchor
        ]
        let hostedViewXAnchors = [
            subviewGuide.leadingAnchor,
            subviewGuide.trailingAnchor
        ]
        return zip(contentViewXAnchors, hostedViewXAnchors)
            .map { contentAnchor, hostedAnchor in
                contentAnchor.constraint(equalTo: hostedAnchor)
            }
    }

    private func verticalFullSizeConstraints(to subview: UIView) -> [NSLayoutConstraint] {
        let contentGuide = layoutMarginsGuide
        let subviewGuide = subview.safeAreaLayoutGuide

        let contentViewYAnchors = [
            contentGuide.topAnchor,
            contentGuide.bottomAnchor
        ]
        let hostedViewYAnchors = [
            subviewGuide.topAnchor,
            subviewGuide.bottomAnchor
        ]
        return zip(contentViewYAnchors, hostedViewYAnchors)
            .map { contentAnchor, hostedAnchor in
                contentAnchor.constraint(equalTo: hostedAnchor)
            }
    }

    /** Adds the `subview` and sets the subview's top and bottom anchors to the parent view's
     safeAreaLayoutGuide top and bottom anchors, respectively.
     The subview's leading and trailing anchors will be set to the layoutMarginsGuide
     leading and trailing anchors respectively.

     Parameters:
     - subview: The view that will be displayed in the parent view
     */
    func addFullSizedSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false

        let fullSizeConstraints = [
            horizontalFullSizeConstraints(to: subview),
            verticalFullSizeConstraints(to: subview)
        ].flatMap { $0 }

        NSLayoutConstraint.activate(fullSizeConstraints)
    }
}
