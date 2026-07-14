/*
 Copyright (c) 2026, Apple Inc. All rights reserved.
 
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

@import Foundation;
@import ObjectiveC;
@import UIKit;
#import "ORKSkin.h"

@implementation UIView (Additions)

+ (instancetype)layoutContainerFor:(UIView *)view {
    return [self layoutContainerFor:view shouldAddFooterPadding:YES];
}

+ (instancetype)layoutContainerFor:(UIView *)view shouldAddFooterPadding:(BOOL)shouldAddFooterPadding {
    NSDirectionalEdgeInsets edgeInsets;
    if (shouldAddFooterPadding) {
        edgeInsets = ORKLargeContentLayoutMargins;
    } else {
        edgeInsets = NSDirectionalEdgeInsetsMake(ORKLargeContentLayoutMargins.top, 0, ORKLargeContentLayoutMargins.bottom, 0);
    }

    return [self layoutContainerFor:view margins:edgeInsets];
}

+ (instancetype)layoutContainerFor:(UIView *)contentView margins:(NSDirectionalEdgeInsets)layoutMargins {

#if DEBUG
    // Creating a custom runtime UIView sublcass allows for easier identification of these
    // layout containers in the view hierarchy debugger in Xcode.
    Class layoutContainerClass = objc_getClass("ORKContentLayoutMarginContainer");
    if (layoutContainerClass == nil) {
        layoutContainerClass = objc_allocateClassPair([UIView class],
                                                      "ORKContentLayoutMarginContainer",
                                                      0);
        objc_registerClassPair(layoutContainerClass);
    }
#else
    Class layoutContainerClass = [UIView class];
#endif

    UIView *layoutContainer = [[layoutContainerClass alloc] initWithFrame:contentView.bounds];
    layoutContainer.directionalLayoutMargins = layoutMargins;

    [layoutContainer addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.topAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.bottomAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:layoutContainer.layoutMarginsGuide.trailingAnchor]
    ]];
    [layoutContainer setNeedsLayout];
    [layoutContainer setHidden:[contentView isHidden]];
    return layoutContainer;
}

@end
