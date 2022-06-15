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

static const CGFloat DontKnowButtonCornerRadius = 10.0;
static const CGFloat DontKnowButtonEdgeInsetHorizontalSpacing = 10.0;
static const CGFloat DontKnowButtonEdgeInsetVerticalSpacing = 4.0;
static const CGFloat CheckMarkImageHeightOffset = 2.0;
static const CGFloat CheckMarkImageTrailingPadding = 2.0;

@implementation ORKDontKnowButton {
    UIView *_dontKnowButtonCustomView;
    UILabel *_dontKnowButtonTextLabel;
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
    _isDontKnowButtonActive = NO;
    
    [self setButtonInactive];
    [self tintColorDidChange];
}

- (void)updateAppearance {
    self.layer.cornerRadius = DontKnowButtonCornerRadius;
    self.clipsToBounds = YES;
    
    if (_dontKnowButtonCustomView) {
        [_dontKnowButtonCustomView removeFromSuperview];
    }
    
    _dontKnowButtonCustomView = [UIView new];
    [_dontKnowButtonCustomView setUserInteractionEnabled:NO];
    _dontKnowButtonCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_dontKnowButtonCustomView];
    
    _dontKnowButtonTextLabel = [UILabel new];
    _dontKnowButtonTextLabel.text = _customDontKnowButtonText ? : ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil);
    _dontKnowButtonTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dontKnowButtonTextLabel.numberOfLines = 0;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setButtonInactive {
    _isDontKnowButtonActive = NO;
    [self updateAppearance];
    
    UIFontDescriptor *dontKnowButtonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *dontKnowButtonFontDescriptor = [dontKnowButtonDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_dontKnowButtonTextLabel setFont:[UIFont fontWithDescriptor:dontKnowButtonFontDescriptor size:[[dontKnowButtonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    if (@available(iOS 13.0, *)) {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor systemFillColor]];
        [_dontKnowButtonTextLabel setTextColor:[UIColor secondaryLabelColor]];
    } else {
        [_dontKnowButtonCustomView setBackgroundColor:[UIColor grayColor]];
        [_dontKnowButtonTextLabel setTextColor:[UIColor grayColor]];
    }

    CGSize neededSize = [_dontKnowButtonTextLabel sizeThatFits:CGSizeMake( _dontKnowButtonTextLabel.frame.size.width, CGFLOAT_MAX)];
    [[_dontKnowButtonTextLabel.heightAnchor constraintEqualToConstant:neededSize.height] setActive: YES];
    [[_dontKnowButtonTextLabel.centerYAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.centerYAnchor] setActive:YES];
    
    [[_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.trailingAnchor constant:DontKnowButtonEdgeInsetHorizontalSpacing] setActive:YES];
    [[_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing] setActive:YES];
    [[_dontKnowButtonCustomView.heightAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.heightAnchor multiplier:1.0 constant:DontKnowButtonEdgeInsetVerticalSpacing * 2] setActive:YES];
    
    [[self.trailingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.trailingAnchor constant:0.0] setActive:YES];
    [[self.leadingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.leadingAnchor constant:0.0] setActive:YES];
    [[self.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor constant:0.0] setActive:YES];
    [[self.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor constant:0.0] setActive:YES];
}

- (void)setButtonActive {
    _isDontKnowButtonActive = YES;
    [self updateAppearance];
    
    UIFontDescriptor *dontKnowButtonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *dontKnowButtonFontDescriptor = [dontKnowButtonDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_dontKnowButtonTextLabel setFont:[UIFont fontWithDescriptor:dontKnowButtonFontDescriptor size:[[dontKnowButtonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    [_dontKnowButtonCustomView addSubview:_dontKnowButtonTextLabel];
    
    if (@available(iOS 13.0, *)) {
        [_dontKnowButtonTextLabel setTextColor:[UIColor systemBackgroundColor]];
        
        //image, image view and add to custom view
        UIImageSymbolConfiguration *imageConfig = [UIImageSymbolConfiguration configurationWithScale:UIImageSymbolScaleSmall];
        UIImage *checkMarkImage = [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:imageConfig];
        UIImage *tintedCheckMarkImage = [checkMarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:tintedCheckMarkImage];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [imageView setTintColor:_dontKnowButtonTextLabel.textColor];
        
        [_dontKnowButtonCustomView addSubview:imageView];
        
        CGSize neededSize = [_dontKnowButtonTextLabel sizeThatFits:CGSizeMake( _dontKnowButtonTextLabel.frame.size.width, CGFLOAT_MAX)];
        [[_dontKnowButtonTextLabel.heightAnchor constraintEqualToConstant:neededSize.height] setActive: YES];
        
        [imageView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.leadingAnchor constant:-CheckMarkImageTrailingPadding].active = YES;
        [[imageView.heightAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.heightAnchor multiplier:1.0 constant:CheckMarkImageHeightOffset] setActive:YES];
        [[imageView.widthAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.heightAnchor multiplier:1.0] setActive:YES];
        [imageView.centerYAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.centerYAnchor].active = YES;
        
        [_dontKnowButtonCustomView.trailingAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.trailingAnchor constant:DontKnowButtonEdgeInsetHorizontalSpacing].active = YES;
        [_dontKnowButtonCustomView.topAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.topAnchor constant:-DontKnowButtonEdgeInsetVerticalSpacing].active = YES;
        [_dontKnowButtonCustomView.bottomAnchor constraintEqualToAnchor:_dontKnowButtonTextLabel.bottomAnchor constant:DontKnowButtonEdgeInsetVerticalSpacing].active = YES;
        [_dontKnowButtonCustomView.leadingAnchor constraintEqualToAnchor:imageView.leadingAnchor constant:-DontKnowButtonEdgeInsetHorizontalSpacing].active = YES;
        
        [[self.trailingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.trailingAnchor constant:0.0] setActive:YES];
        [[self.leadingAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.leadingAnchor constant:0.0] setActive:YES];
        [[self.topAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.topAnchor constant:0.0] setActive:YES];
        [[self.bottomAnchor constraintEqualToAnchor:_dontKnowButtonCustomView.bottomAnchor constant:0.0] setActive:YES];
    } else {
        [_dontKnowButtonTextLabel setTextColor:[UIColor whiteColor]];
    }
    
    [_dontKnowButtonCustomView setBackgroundColor:[UIColor systemBlueColor]];
}

- (void)setCustomDontKnowButtonText:(NSString *)customDontKnowButtonText {
    _customDontKnowButtonText = customDontKnowButtonText;
    
    if (_isDontKnowButtonActive) {
        [self setButtonActive];
    } else {
        [self setButtonInactive];
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    NSString *accessibilityLabelText = [NSString stringWithFormat:@"%@ %@", [self isDontKnowButtonActive] ? ORKLocalizedString(@"AX_SELECTED", nil) : ORKLocalizedString(@"AX_UNSELECTED", nil), _customDontKnowButtonText != nil ? _customDontKnowButtonText : ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil)];
    
    if ([self isDontKnowButtonActive]) {
        accessibilityLabelText = [accessibilityLabelText stringByAppendingFormat:@", %@", ORKLocalizedString(@"AX_BUTTON", nil)];
    }
    
    return accessibilityLabelText;
}

@end


