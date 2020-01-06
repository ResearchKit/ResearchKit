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

#import "ORKPlaybackButton.h"

static const CGFloat ImageViewDimension = 60.0;
static const CGFloat ImageToLabelPadding = 2.0;

@implementation ORKPlaybackButton {
    UILabel *_textLabel;
    UIImageView *_imageView;
}

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image {
    self = [super init];
    if (self) {
        self.text = text;
        self.image = image;
    }
    [self setColors];
    [self setupImageView];
    [self setupTextLabel];
    return self;
}

- (void)setColors {
    _highlightTintColor = self.tintColor;
    _normalTintColor = [self.tintColor colorWithAlphaComponent:0.4];
}

- (void)setupImageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
    }
    _imageView.image = _image;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];
    
    [[_imageView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_imageView.widthAnchor constraintEqualToConstant:ImageViewDimension] setActive:YES];
    [[_imageView.heightAnchor constraintEqualToConstant:ImageViewDimension] setActive:YES];
    [[_imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
}

- (UIFont *)bodyTextFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)setupTextLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
    }
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.text = _text;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = self.tintColor;
    _textLabel.font = [self bodyTextFont];
    [self addSubview:_textLabel];
    
    [[_textLabel.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:ImageToLabelPadding] setActive:YES];
    [[_textLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
    [[self.widthAnchor constraintEqualToAnchor:_textLabel.widthAnchor] setActive:YES];
    [[self.bottomAnchor constraintEqualToAnchor:_textLabel.bottomAnchor] setActive:YES];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _imageView.tintColor = tintColor;
    _textLabel.textColor = tintColor;
}

- (void)setNormalTintColor:(UIColor *)normalTintColor {
    _normalTintColor = normalTintColor;
    [self setHighlighted:self.isHighlighted];
}

- (void)setHighlightTintColor:(UIColor *)highlightTintColor {
    _highlightTintColor = highlightTintColor;
    [self setHighlighted:self.isHighlighted];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        _textLabel.textColor = _highlightTintColor;
        _imageView.tintColor = _highlightTintColor;
    }
    else {
        _textLabel.textColor = _normalTintColor;
        _imageView.tintColor = _normalTintColor;
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        _textLabel.textColor = _highlightTintColor;
        _imageView.tintColor = _highlightTintColor;
    }
    else {
        _textLabel.textColor = _normalTintColor;
        _imageView.tintColor = _normalTintColor;
    }
}

- (void)setText:(NSString *)text {
    _text = text;
    _textLabel.text = text;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

@end
