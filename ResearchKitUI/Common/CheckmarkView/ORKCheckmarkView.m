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

#import "ORKCheckmarkView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKAccessibilityFunctions.h"

@implementation ORKCheckmarkView {
    CGFloat _dimension;
    BOOL _shouldShowCircle;
}

- (instancetype)initWithRadius:(CGFloat)radius checkedImage:(UIImage *)checkedImage uncheckedImage:(UIImage *)uncheckedImage shouldShowCircle:(BOOL)shouldShowCircle {
    self = [super init];
    if (self) {
        _dimension = 2*radius;
        _checkedImage = checkedImage;
        _uncheckedImage = uncheckedImage;
        _shouldShowCircle = shouldShowCircle;
    }
    [self setupView];
    return self;
}

- (instancetype)initWithRadius:(CGFloat)radius checkedImage:(UIImage *)checkedImage uncheckedImage:(UIImage *)uncheckedImage {
    return [self initWithRadius:CheckmarkViewDimension*0.5
                   checkedImage:[ORKCheckmarkView checkedImage]
                 uncheckedImage:[ORKCheckmarkView unCheckedImage]
               shouldShowCircle:YES];
}

- (instancetype)initWithDefaults {
    return [self initWithRadius:CheckmarkViewDimension*0.5
                   checkedImage:[ORKCheckmarkView checkedImage]
                 uncheckedImage:[ORKCheckmarkView unCheckedImage]];
}

- (instancetype)initWithDefaultsWithoutCircle {
    return [self initWithRadius:CheckmarkViewDimension*0.5
                   checkedImage:[ORKCheckmarkView checkedImageWithoutCircle]
                 uncheckedImage:nil
               shouldShowCircle:NO];
}

- (CGFloat)getDimension {
    return _dimension;
}

+ (UIImage *)unCheckedImage {
    UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:ORKImageScaleToUse()];
    return [UIImage systemImageNamed:@"circle" withConfiguration:configuration];
}

+ (UIImage *)checkedImage {
    UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:ORKImageScaleToUse()];
    return [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
}

+ (UIImage *)checkedImageWithoutCircle {
    UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:ORKImageScaleToUse()];
    return [UIImage systemImageNamed:@"checkmark" withConfiguration:configuration];
}

- (void)updateCheckView {
    if (_checked) {
        self.image = _checkedImage;
        if (![self.tintColor isEqual: ORKViewTintColor(self)]) {
            self.tintColor = ORKViewTintColor(self);
        }
    }
    else {
        self.image = _uncheckedImage;
        if (![self.tintColor isEqual: [UIColor systemGray3Color]]) {
            self.tintColor = _shouldIgnoreDarkMode ? [UIColor lightGrayColor] : [UIColor systemGray3Color];
        }
    }
}

- (void)setupView {
    [[self.widthAnchor constraintEqualToConstant:_dimension] setActive:YES];
    [[self.heightAnchor constraintEqualToConstant:_dimension] setActive:YES];
    
    self.contentMode = UIViewContentModeCenter;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    [self updateCheckView];
}

- (void)setShouldIgnoreDarkMode:(BOOL)shouldIgnoreDarkMode {
    _shouldIgnoreDarkMode = shouldIgnoreDarkMode;
    [self updateCheckView];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateCheckView];
}

@end

