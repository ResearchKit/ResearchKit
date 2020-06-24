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

#import "ORKIconButton.h"
#import "ORKHelpers_Internal.h"
#import "ORKLabel.h"

@implementation ORKIconButton {
    UIView *_customView;
    UIImageView *_imageView;
    ORKLabel *_textLabel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self init_ORKIconButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self init_ORKIconButton];
    }
    return self;
}

- (instancetype)initWithButtonText:(NSString *)buttonText buttonIcon:(UIImage *)buttonIcon {
    self = [super init];
    if (self) {
        self.buttonText = buttonText;
        self.buttonIcon = buttonIcon;
        [self init_ORKIconButton];
    }
    return self;
}

- (void)init_ORKIconButton {
    self.layer.cornerRadius = 10.0;
    self.clipsToBounds = YES;
    
    [self setupCustomView];
    [self setupTextLabel];
    [self setupImageView];
    [self setupConstraints];
}

- (void)setupCustomView {
    _customView = [UIView new];
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [_customView setBackgroundColor:[UIColor lightGrayColor]];
    [_customView setUserInteractionEnabled:NO];
    
    [self addSubview:_customView];
}

- (void)setupTextLabel {
    _textLabel = [ORKLabel new];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.textAlignment = NSTextAlignmentLeft;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.numberOfLines = 0;
    _textLabel.text = !_buttonText ? @"" : _buttonText;
    [_textLabel setTextColor:[UIColor systemBlueColor]];
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_textLabel setFont:[UIFont fontWithDescriptor:fontDescriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    [_customView addSubview:_textLabel];
}

- (void)setupImageView {
    _imageView = [UIImageView new];
    _imageView.image = _buttonIcon;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_customView addSubview:_imageView];
}

- (void)setupConstraints {
    [[_textLabel.centerYAnchor constraintEqualToAnchor:_customView.centerYAnchor] setActive:YES];
    [[_textLabel.leadingAnchor constraintEqualToAnchor:_customView.leadingAnchor constant:15.0] setActive:YES];
    [[_textLabel.trailingAnchor constraintEqualToAnchor:_imageView.leadingAnchor constant:-10.0] setActive:YES];
    
    [[_imageView.centerYAnchor constraintEqualToAnchor:_customView.centerYAnchor] setActive:YES];
    [[_imageView.trailingAnchor constraintEqualToAnchor:_customView.trailingAnchor constant:-15.0] setActive:YES];
    
    [[_customView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
    [[_customView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
    [[_customView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_customView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];
}

- (void)setButtonText:(NSString *)buttonText {
    _buttonText = [buttonText copy];
    _textLabel.text = _buttonText;
}

- (void)setButtonIcon:(UIImage *)buttonIcon {
    _buttonIcon = buttonIcon;
    _imageView.image = buttonIcon;
}

- (void)updateTextAndImageColor:(UIColor *)color {
    [_textLabel setTextColor:color];
    [_imageView setTintColor:color];
}

@end
