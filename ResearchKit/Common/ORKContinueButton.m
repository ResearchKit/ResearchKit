/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKContinueButton.h"
#import "ORKSkin.h"


static const CGFloat kContinueButtonTouchMargin = 10;

@implementation ORKContinueButton {
    NSLayoutConstraint *_widthConstraint;
    NSLayoutConstraint *_heightConstraint;
}

- (instancetype)initWithTitle:(NSString *)title isDoneButton:(BOOL)isDoneButton {
    self = [super init];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        self.isDoneButton = isDoneButton;
        self.contentEdgeInsets = (UIEdgeInsets){.left=6,.right=6};
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)didMoveToWindow {
    [self updateConstraintConstants];
}

- (void)updateConstraintConstants {
    
    UIWindow *window = [self window];
    ORKScreenType screenType = ORKGetScreenTypeForWindow(window);
    _widthConstraint.constant = ORKGetMetricForScreenType(ORKScreenMetricContinueButtonWidth, screenType);
}

- (void)updateConstraints {
    if (! _heightConstraint) {
        _heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:44];
        _heightConstraint.active = YES;
    }
    if (! _widthConstraint) {
        UIWindow *window = [self window];
        ORKScreenType screenType = ORKGetScreenTypeForWindow(window);
        _widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:ORKGetMetricForScreenType(ORKScreenMetricContinueButtonWidth, screenType)];
    }
    _heightConstraint.active = YES;
    _widthConstraint.active = YES;
    
    [super updateConstraints];
}

+ (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    return [UIFont systemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect outsetRect = UIEdgeInsetsInsetRect(self.bounds,
                                              (UIEdgeInsets){-kContinueButtonTouchMargin,
                                                             -kContinueButtonTouchMargin,
                                                             -kContinueButtonTouchMargin,
                                                             -kContinueButtonTouchMargin});
    BOOL isInside = [super pointInside:point withEvent:event] || CGRectContainsPoint(outsetRect, point);
    return isInside;
}

@end
