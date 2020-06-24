/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKRequestPermissionView.h"
#import "ORKStepContainerView_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

ORKRequestPermissionsNotification const ORKRequestPermissionsNotificationCardViewStatusChanged = @"ORKRequestPermissionsNotificationCardViewStatusChanged";

static const CGFloat RequestHealthDataViewTopBottomPadding = 15.0;
static const CGFloat StandardPadding = 8.0;
static const CGFloat IconImageViewWidthHeight = 48.0;
static const CGFloat IconImageViewBottomPadding = 10.0;
static const CGFloat DetailTextLabelBottomPadding = 10.0;
static const CGFloat RequestDataButtonWidth = 125.0;

@implementation ORKRequestPermissionView {
    NSMutableArray *_constraints;
    
    UIImage *_iconImage;
    UIImageView *_iconImageView;
    
    NSString *_title;
    NSString *_detailText;
    
    UILabel *_titleLabel;
    UILabel *_detailTextLabel;
    UILabel *_buttonStateMessageLabel;
    
    UIImageView *_buttonStateImageView;
}

- (instancetype)initWithIconImage:(nullable UIImage *)iconImage title:(NSString *)title detailText:(NSString *)detailText {
    self = [self initWithFrame:CGRectZero];
    
    if (self) {
        _iconImage = iconImage;
        _title = title;
        _detailText = detailText;
        _enableContinueButton = YES;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    if (@available(iOS 13.0, *)) {
        self.layer.borderColor = [[UIColor separatorColor] CGColor];
    } else {
        self.layer.borderColor = [[UIColor ork_midGrayTintColor] CGColor];
    }

    [self setupSubviews];
    [self setUpConstraints];
}

- (void)layoutSubviews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        [self setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    self.layer.cornerRadius = 10.0;
    self.clipsToBounds = YES;
}

- (void)setupSubviews {

    [self setupIconImageView];
    [self setUpTitleLabel];
    [self setUpDetailTextLabel];
    [self setupRequestDataButton];
}

- (void)setupIconImageView {
    if (_iconImage) {
        _iconImageView = [[UIImageView alloc] initWithImage:_iconImage];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_iconImageView];
    }
}

- (void)setUpTitleLabel {
    if (_title) {
        _titleLabel = [UILabel new];
        _titleLabel.text = _title;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.numberOfLines = 0;
        if (@available(iOS 13.0, *)) {
            _titleLabel.textColor = [UIColor labelColor];
        } else {
            _titleLabel.textColor = [UIColor blackColor];
        }
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textAlignment = NSTextAlignmentNatural;
        UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
        [_titleLabel setFont:[UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
        [self addSubview:_titleLabel];
    }
}

- (void)setUpDetailTextLabel {
    if (_detailText) {
        _detailTextLabel = [UILabel new];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.text = _detailText;
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailTextLabel.textAlignment = NSTextAlignmentNatural;
        UIFontDescriptor *descriptorForDetailText = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        [_detailTextLabel setFont:[UIFont fontWithDescriptor:descriptorForDetailText size:[[descriptorForDetailText objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
        [self addSubview:_detailTextLabel];
    }
}

- (void)setupRequestDataButton {
    if (!_requestPermissionButton) {
        _requestPermissionButton = [UIButton new];
        _requestPermissionButton.translatesAutoresizingMaskIntoConstraints = NO;
        _requestPermissionButton.layer.cornerRadius = 10.0;
        _requestPermissionButton.clipsToBounds = YES;
        _requestPermissionButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_requestPermissionButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0)];
        [self addSubview:_requestPermissionButton];
    }
}

- (void)setupMessageStateSubviews {
    if (_requestPermissionButton) {
        [_requestPermissionButton removeFromSuperview];
    }
    
    if (!_buttonStateMessageLabel) {
        _buttonStateMessageLabel = [UILabel new];
        
        _buttonStateMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonStateMessageLabel.numberOfLines = 0;
        _buttonStateMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _buttonStateMessageLabel.textAlignment = NSTextAlignmentNatural;
        UIFontDescriptor *descriptorForDetailText = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        [_buttonStateMessageLabel setFont:[UIFont fontWithDescriptor:descriptorForDetailText size:[[descriptorForDetailText objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
        [self addSubview:_buttonStateMessageLabel];
        
        _buttonStateImageView = [UIImageView new];
        _buttonStateImageView.contentMode = UIViewContentModeScaleAspectFit;
        _buttonStateImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_buttonStateImageView];
    }
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray array];
        
    [_constraints addObject:[_iconImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:RequestHealthDataViewTopBottomPadding]];
    [_constraints addObject:[_iconImageView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:StandardPadding]];
    [_constraints addObject:[_iconImageView.widthAnchor constraintEqualToConstant:IconImageViewWidthHeight]];
    [_constraints addObject:[_iconImageView.heightAnchor constraintEqualToConstant:IconImageViewWidthHeight]];
    
    [_constraints addObject:[_titleLabel.topAnchor constraintEqualToAnchor:_iconImageView.bottomAnchor constant:IconImageViewBottomPadding]];
    [_constraints addObject:[_titleLabel.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:StandardPadding]];
    [_constraints addObject:[_titleLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-StandardPadding]];
    
    [_constraints addObject:[_detailTextLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:StandardPadding]];
    [_constraints addObject:[_detailTextLabel.leftAnchor constraintEqualToAnchor:_titleLabel.leftAnchor]];
    [_constraints addObject:[_detailTextLabel.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-StandardPadding]];
    
    if (!_buttonStateMessageLabel) {
        [_constraints addObject:[_requestPermissionButton.topAnchor constraintEqualToAnchor:_detailTextLabel.bottomAnchor constant:DetailTextLabelBottomPadding]];
        [_constraints addObject:[_requestPermissionButton.leftAnchor constraintEqualToAnchor:_titleLabel.leftAnchor]];
        [_constraints addObject:[_requestPermissionButton.widthAnchor constraintEqualToConstant:RequestDataButtonWidth]];
        [_constraints addObject:[_requestPermissionButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-RequestHealthDataViewTopBottomPadding]];
    } else {
        [_constraints addObject:[_buttonStateMessageLabel.topAnchor constraintEqualToAnchor:_detailTextLabel.bottomAnchor constant:DetailTextLabelBottomPadding]];
        [_constraints addObject:[_buttonStateMessageLabel.leftAnchor constraintEqualToAnchor:_titleLabel.leftAnchor]];
        [_constraints addObject:[_buttonStateMessageLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-RequestHealthDataViewTopBottomPadding]];
        
        [_constraints addObject:[_buttonStateImageView.leftAnchor constraintEqualToAnchor:_buttonStateMessageLabel.rightAnchor constant: StandardPadding]];
        [_constraints addObject:[_buttonStateImageView.centerYAnchor constraintEqualToAnchor:_buttonStateMessageLabel.centerYAnchor]];
    }
   
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)updateIconTintColor:(UIColor *)iconTintColor {
    if (_iconImageView) {
        [_iconImageView setTintColor:[UIColor redColor]];
    }
}

- (void)setEnableContinueButton:(BOOL)enableContinueButton {
    _enableContinueButton = enableContinueButton;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKRequestPermissionsNotificationCardViewStatusChanged object:self];
}

@end

