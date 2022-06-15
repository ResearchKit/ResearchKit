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

static const CGFloat CheckmarkViewBorderWidth = 2.0;

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
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        return [UIImage systemImageNamed:@"circle" withConfiguration:configuration];
    } else {
        return nil;
    }
}

+ (UIImage *)checkedImage {
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        return [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    } else {
        return [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

+ (UIImage *)checkedImageWithoutCircle {
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        return [UIImage systemImageNamed:@"checkmark" withConfiguration:configuration];
    } else {
        return [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)updateCheckView {
    if (_checked) {
         self.image = _checkedImage;
        //        FIXME: Need to be replaced.
        if (@available(iOS 13.0, *)) {
            self.tintColor = UIColor.systemBlueColor;
        } else {
            self.backgroundColor = [self tintColor];
            self.tintColor = UIColor.whiteColor;
        }
    }
    else {
        self.image = _uncheckedImage;
        if (@available(iOS 13.0, *)) {
            self.tintColor = [UIColor systemGray3Color];
        } else {
            self.tintColor = nil;
            self.image = nil;
            self.backgroundColor = UIColor.clearColor;
        }
    }
}

- (void)setupView {
    [[self.widthAnchor constraintEqualToConstant:_dimension] setActive:YES];
    [[self.heightAnchor constraintEqualToConstant:_dimension] setActive:YES];
    
    if (@available(iOS 13.0, *)) {
        // use SFSymbols directly
    } else {
        self.layer.cornerRadius = _dimension * 0.5;
        self.layer.borderWidth = CheckmarkViewBorderWidth;
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.masksToBounds = YES;
    }
    
    self.contentMode = UIViewContentModeCenter;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    [self updateCheckView];
}

@end

