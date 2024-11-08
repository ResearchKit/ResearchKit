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

extension StickyScrollView {

    struct StickyLayout: Layout {

        let allowsExtendedLayout: Bool

        let size: CGSize

        let bodySize: CGSize

        var offset: CGFloat

        let safeAreaInsets: EdgeInsets

        let keyboardIgnoringSafeAreaInsets: EdgeInsets

        let isContentCenteringEnabled: Bool

        @Binding
        var totalLayoutHeight: CGFloat

        @Binding
        var availableContentHeight: CGFloat

        @Binding
        var isFooterBackgroundVisible: Bool

        func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout Void
        ) -> CGSize {

            let bottomInset = safeAreaInsets.bottom

            let contentHeight = subviews[0].dimensions(in: proposal).height

            let stickyHeight = subviews[1].dimensions(in: proposal).height

            if contentHeight + stickyHeight > size.height {
                return CGSize(
                    width: proposal.replacingUnspecifiedDimensions().width,
                    height: contentHeight + stickyHeight - bottomInset
                )
            }

            return CGSize(
                width: proposal.replacingUnspecifiedDimensions().width,
                height: contentHeight + stickyHeight + bottomInset
            )

        }

        func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout Void
        ) {

            let stickyContent = subviews[1]
            let stickyContentHeight = stickyContent.dimensions(in: proposal)
                .height

            let content = subviews[0]
            let contentHeight = content.dimensions(in: proposal).height

            let totalHeight = contentHeight + stickyContentHeight
            let bodyHeight = bodySize.height
            let topWhiteSpace =
                isContentCenteringEnabled == false
                ? 0
                : (contentHeight - bodyHeight) / 2

            // This is the bottom inset to the top of the keyboard (and attachments)
            let bottomInset = safeAreaInsets.bottom

            // This is the bottom inset with no keyboard
            let keyboardIgnoringBottomInset = keyboardIgnoringSafeAreaInsets
                .bottom

            let shouldFooterFixPosition =
                allowsExtendedLayout == false
                || contentHeight + (stickyContentHeight - safeAreaInsets.bottom)
                    < size.height

            let shouldFooterBackgroundShow: Bool = {
                let bottomOfBodyFromTop =
                    bodySize.height + topWhiteSpace + self.offset
                let topOfStickyFooter =
                    size.height + bottomInset - stickyContentHeight
                let isHeightGreaterThanAvailableSpace =
                    bottomOfBodyFromTop > topOfStickyFooter
                return isHeightGreaterThanAvailableSpace
                    && shouldFooterFixPosition
            }()

            DispatchQueue.main.async {
                isFooterBackgroundVisible = shouldFooterBackgroundShow

                // The following conditionals are a hack to deal with lack of keyboard management support in SwiftUI.
                // The point of these conditionals is to allow bottom spacing for the sticky section, but not
                // allow that space when the keyboard is visible.

                // There are 3 cases for the layout:
                if totalHeight > size.height {
                    if bottomInset > keyboardIgnoringBottomInset {
                        // 1. The content is greater than the view size, and the keyboard is visible.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            self.totalLayoutHeight =
                                totalHeight - bottomInset - stickyContentHeight
                                + bottomInset
                        }
                        // Need to cancel these (for quick dismisses)
                    } else {
                        // 2. The content is greater than the view size, and the keyboard is not visible
                        self.totalLayoutHeight = totalHeight - bottomInset
                    }
                } else {
                    // 3. The content is not greater than the view size, doesn't matter if the keyboard is visible
                    self.totalLayoutHeight = contentHeight
                }
                self.availableContentHeight =
                    size.height - stickyContentHeight + bottomInset
            }

            let contentPlacementProposal = ProposedViewSize(
                width: bounds.width,
                height: .infinity
            )

            let stickyPlacementProposal = ProposedViewSize(
                width: bounds.width,
                height: .infinity
            )

            content.place(
                at: CGPoint(
                    x: bounds.origin.x,
                    y: bounds.origin.y
                ),
                anchor: .topLeading,
                proposal: contentPlacementProposal
            )

            let offset =
                shouldFooterFixPosition
                ? size.height - stickyContentHeight - self.offset + bottomInset
                : max(contentHeight, size.height - stickyContentHeight)

            stickyContent.place(
                at: CGPoint(
                    x: bounds.origin.x,
                    y: bounds.origin.y + offset + safeAreaInsets.bottom
                        - keyboardIgnoringSafeAreaInsets.bottom
                ),
                anchor: .topLeading,
                proposal: stickyPlacementProposal
            )

        }

    }

}
