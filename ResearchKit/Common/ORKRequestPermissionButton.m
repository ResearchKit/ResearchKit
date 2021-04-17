/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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

#import "ORKRequestPermissionButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

static const CGFloat ButtonLabelVerticalPadding = 4;
static const CGFloat StandardPadding = 15.0;
static const CGFloat HighlightedOpacity = 0.5;

@implementation ORKRequestPermissionButton {
    UILabel *_titleLabel;
    ORKRequestPermissionsButtonState _state;
    UIViewPropertyAnimator *highlightAnimator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        highlightAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.1 curve:UIViewAnimationCurveEaseOut animations:nil];

        [self setupTitleLabel];
        [self setState:ORKRequestPermissionsButtonStateDefault];
        [self updateFonts];
    }
    return self;
}

- (void)setupTitleLabel {
    _titleLabel = [UILabel new];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];

    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [_titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:StandardPadding],
        [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-StandardPadding],
        [_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:ButtonLabelVerticalPadding],
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-ButtonLabelVerticalPadding],
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
    ]];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    // Animate the opacity transition
    [highlightAnimator stopAnimation:true];
    __weak __typeof__(self) weakSelf = self;
    [highlightAnimator addAnimations:^{
        weakSelf.alpha = highlighted ? HighlightedOpacity : 1;
    }];
    [highlightAnimator startAnimation];
}

- (void)setState:(ORKRequestPermissionsButtonState)state {
    _state = state;

    switch (state) {

        case ORKRequestPermissionsButtonStateDefault:
            _titleLabel.text = ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_DEFAULT", nil);
            break;

        case ORKRequestPermissionsButtonStateConnected:
            _titleLabel.text = ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_CONNECTED", nil);
            break;

        case ORKRequestPermissionsButtonStateNotSupported:
            _titleLabel.text = ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_NOT_SUPPORTED", nil);
            break;

        case ORKRequestPermissionsButtonStateError:
            _titleLabel.text = ORKLocalizedString(@"REQUEST_PERMISSION_BUTTON_STATE_ERROR", nil);
            break;
    }

    [self setStyleForState:state];
}

- (void)setStyleForState:(ORKRequestPermissionsButtonState)state {
    switch (state) {

        case ORKRequestPermissionsButtonStateDefault:
            [self setBackgroundColor:self.tintColor];
            _titleLabel.textColor = UIColor.whiteColor;
            [self setEnabled:YES];
            break;

        case ORKRequestPermissionsButtonStateConnected:
        case ORKRequestPermissionsButtonStateNotSupported:
        case ORKRequestPermissionsButtonStateError:
            _titleLabel.textColor = UIColor.systemGrayColor;

            if (@available(iOS 13.0, *)) {
                [self setBackgroundColor:UIColor.tertiarySystemFillColor];
            } else {
                [self setBackgroundColor:UIColor.lightGrayColor];
            }
            [self setEnabled:NO];
            break;
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (previousTraitCollection.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory) {
        [self updateFonts];
    }
}

- (void)updateFonts {
    if (_titleLabel) {
        _titleLabel.font = [self fontWithTextStyle:UIFontTextStyleBody weight:UIFontWeightMedium];
    }
}

- (UIFont *)fontWithTextStyle:(UIFontTextStyle)textStyle weight:(UIFontWeight)weight {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
    return [UIFont systemFontOfSize:descriptor.pointSize weight:weight];
}

- (void)tintColorDidChange {
    if (_state == ORKRequestPermissionsButtonStateDefault) {
        [self setBackgroundColor:self.tintColor];
    }
}

@end
