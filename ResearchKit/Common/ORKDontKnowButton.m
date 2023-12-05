/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKDontKnowButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKCheckmarkView.h"
#import "ORKSkin.h"
#import "ORKLabel.h"

static const CGFloat DontKnowButtonCornerRadius = 10.0;
static const CGFloat DontKnowButtonEdgeInsetHorizontalSpacing = 10.0;
static const CGFloat DontKnowButtonEdgeInsetVerticalSpacing = 4.0;
static const CGFloat CheckMarkImageHeightOffset = 2.0;
static const CGFloat CheckMarkImageTrailingPadding = 2.0;

@implementation ORKDontKnowButton {
    UIView *_dontKnowButtonCustomView;
    UIImageView *_dontKnowButtonCustomImageView;
    ORKLabel *_dontKnowButtonTextLabel;
    ORKCheckmarkView *_checkmarkView;
    NSMutableArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self init_ORKDontKnowButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self init_ORKDontKnowButton];
    }
    return self;
}

- (void)init_ORKDontKnowButton {
    _dontKnowButtonStyle = ORKDontKnowButtonStyleStandard;
    [self setActive:NO];
    [self tintColorDidChange];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_dontKnowButtonCustomView && _dontKnowButtonCustomView.frame.size.width > 0 && _dontKnowButtonStyle == ORKDontKnowButtonStyleStandard) {
        _dontKnowButtonCustomView.layer.cornerRadius = _dontKnowButtonCustomView.frame.size.height / 2;
        [_dontKnowButtonCustomView.layer setCornerCurveContinuous];
    }
}

- (void)setActive:(BOOL)active {
    _active = active;
    
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
            [self setButtonConstraintsStandard];
            break;
        case ORKDontKnowButtonStyleCircleChoice:
            [self setupCircleChoiceView];
            break;
    }
}

- (void)setCustomDontKnowButtonText:(NSString *)customDontKnowButtonText {
    _customDontKnowButtonText = [customDontKnowButtonText copy];
    
    if (_customDontKnowButtonText) {
        _dontKnowButtonTextLabel.text = _customDontKnowButtonText;
    }
    
    [self setActive:_active];
}

- (void)setDontKnowButtonStyle:(ORKDontKnowButtonStyle)dontKnowButtonStyle {
    _dontKnowButtonStyle = dontKnowButtonStyle;
    
    [self setActive:_active];
}

- (void)createDontKnowButtonTextLabel {

    if (!_dontKnowButtonTextLabel) {
        _dontKnowButtonTextLabel = [[ORKLabel alloc] init];
        _dontKnowButtonTextLabel.text = _customDontKnowButtonText ? _customDontKnowButtonText : ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil);
        _dontKnowButtonTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _dontKnowButtonTextLabel.numberOfLines = 0;
        _dontKnowButtonTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    
    [_dontKnowButtonTextLabel setFont:[self dontKnowButtonTextLabelFont]];
    [_dontKnowButtonTextLabel setTextAlignment:[self dontKnowButtonTextLabelAlignment]];
    [_dontKnowButtonTextLabel setTextColor:[self dontKnowButtonTextLabelColor]];
}

- (void)createDontKnowButtonCustomView {
    
    if (_dontKnowButtonCustomView) {
        [_dontKnowButtonCustomView removeFromSuperview];
        _dontKnowButtonCustomView = nil;
    }
    
    _dontKnowButtonCustomView = [[UIView alloc] init];
    [_dontKnowButtonCustomView setUserInteractionEnabled:NO];
    _dontKnowButtonCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    [_dontKnowButtonCustomView setBackgroundColor:[self customViewBackgroundColor]];
    
    [self addSubview:_dontKnowButtonCustomView];
}

- (void)updateAppearance {
    
    // Backing Layer
    self.layer.cornerRadius = DontKnowButtonCornerRadius;
    [self.layer setCornerCurveContinuous];
    self.clipsToBounds = YES;
    
    // _Custom View
    [self createDontKnowButtonCustomView];
    
    // Dont Know Button Text Label
    [self createDontKnowButtonTextLabel];
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    if (_dontKnowButtonStyle == ORKDontKnowButtonStyleCircleChoice) {
        [_dontKnowButtonCustomView addSubview:_checkmarkView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setButtonConstraintsStandard {
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    _constraints = [NSMutableArray new];
    
    [self updateAppearance];
        
    if (@available(iOS 13.0, *)) {
            
        if (_active) {
                
            UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
            UIImage *checkMarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:imageConfig];
            UIImage *tintedCheckMarkImage = [checkMarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                
            _dontKnowButtonCustomImageView = [[UIImageView alloc] initWithImage:tintedCheckMarkImage];
            _dontKnowButtonCustomImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [_dontKnowButtonCustomImageView setTintColor:_dontKnowButtonTextLabel.textColor];
            [_dontKnowButtonCustomView addSubview:_dontKnowButtonCustomImageView];

            [_constraints addObjectsFromArray:@[
                [_dontKnowButtonCustomImageView.heightAnchor constraintEqualToAnchor:_dontKnowButtonCustomImageView.widthAnchor],
                [_dontKnowButtonCustomImageView.heightAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.heightAnchor constant:CheckMarkImageHeightOffset],
                [_dontKnowButtonCustomImageView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-CheckMarkImageTrailingPadding],
                [_dontKnowButtonCustomImageView.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor]
            ]];
        } else {
            [_dontKnowButtonCustomImageView removeFromSuperview];
            _dontKnowButtonCustomImageView = nil;
        }
    }
    
    if (_active && _dontKnowButtonCustomImageView) {
        [_constraints addObject:[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:_dontKnowButtonCustomImageView.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing]];
    } else {
        [_constraints addObject:[_dontKnowButtonTextLabel.centerXAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerXAnchor]];
        [_constraints addObject:[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing]];
    }
    
    [_constraints addObjectsFromArray:@[
        [_dontKnowButtonTextLabel.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor],
        
        [_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.topAnchor constant:-DontKnowButtonEdgeInsetVerticalSpacing],
        [_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.bottomAnchor constant:DontKnowButtonEdgeInsetVerticalSpacing],
        [_dontKnowButtonCustomView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.trailingAnchor constant:DontKnowButtonEdgeInsetHorizontalSpacing],
        
        [self.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor],
        [self.widthAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.widthAnchor]
    ]];

    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setupCircleChoiceView {
    if (!_checkmarkView) {
        [self setupCheckMarkView];
    }
    
    [_checkmarkView setChecked:_active];
    
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    
    [self updateAppearance];
    
    [_constraints addObjectsFromArray:@[
        
        [_dontKnowButtonTextLabel.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor],
        [_dontKnowButtonTextLabel.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor],
        [_dontKnowButtonTextLabel.leadingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.leadingAnchor constant:8.0],
        [_dontKnowButtonTextLabel.trailingAnchor constraintEqualToAnchor:_checkmarkView.leadingAnchor constant:-8.0],
        
        [_checkmarkView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.trailingAnchor constant:-ORKSurveyItemMargin],
        [_checkmarkView.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor],
        
        [_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        
        [self.widthAnchor constraintGreaterThanOrEqualToAnchor:_dontKnowButtonCustomView.widthAnchor]
    ]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setupCheckMarkView {
    _checkmarkView = [[ORKCheckmarkView alloc] initWithDefaults];
    _checkmarkView.contentMode = UIViewContentModeScaleAspectFill;
    _checkmarkView.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Styling

- (NSTextAlignment)dontKnowButtonTextLabelAlignment {
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
            return NSTextAlignmentCenter;
        case ORKDontKnowButtonStyleCircleChoice:
            return NSTextAlignmentLeft;
    }
}

- (UIColor *)dontKnowButtonTextLabelColor {
    
    UIColor *color;
    
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
        {
            if (@available(iOS 13.0, *)) {
                color = _active ? [UIColor systemBackgroundColor] : [UIColor secondaryLabelColor];
            } else {
                color = _active ? [UIColor whiteColor] : [UIColor grayColor];
            }
            break;
        }
        case ORKDontKnowButtonStyleCircleChoice:
        {
            if (@available(iOS 13.0, *)) {
                color = [UIColor labelColor];
            } else {
                color = [UIColor blackColor];
            }
            break;
        }
    }
    
    return color;
}

- (UIFont *)dontKnowButtonTextLabelFont {
    
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
        {
            UIFontDescriptor *dontKnowButtonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
            UIFontDescriptor *dontKnowButtonFontDescriptor = [dontKnowButtonDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
            return [UIFont fontWithDescriptor:dontKnowButtonFontDescriptor size:[[dontKnowButtonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
        }
        case ORKDontKnowButtonStyleCircleChoice:
        {
            UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
            return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
        }
    }
}

- (UIColor *)customViewBackgroundColor {
    
    UIColor *color;
    
    switch (_dontKnowButtonStyle) {
        case ORKDontKnowButtonStyleStandard:
        {
            if (!_active) {
                if (@available(iOS 13.0, *)) {
                    color = [UIColor systemFillColor];
                } else {
                    color = [UIColor grayColor];
                }
            } else {
                color = ORKViewTintColor(self);
            }
            
            break;
        }
        case ORKDontKnowButtonStyleCircleChoice:
        {
            if (@available(iOS 13.0, *)) {
                color = [UIColor secondarySystemGroupedBackgroundColor];
            } else {
                color = [UIColor whiteColor];
            }
            
            break;
        }
    }
    
    return color;
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *accessibilityLabelText = [NSString stringWithFormat:@"%@ %@", [self active] ? ORKLocalizedString(@"AX_SELECTED", nil) : ORKLocalizedString(@"AX_UNSELECTED", nil), _customDontKnowButtonText != nil ? _customDontKnowButtonText : ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil)];
    
    if ([self active]) {
        accessibilityLabelText = [accessibilityLabelText stringByAppendingFormat:@", %@", ORKLocalizedString(@"AX_BUTTON", nil)];
    }
    
    return accessibilityLabelText;
}

@end
