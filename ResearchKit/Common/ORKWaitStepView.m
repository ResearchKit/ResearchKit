/*
 Copyright (c) 2015, Alejandro Martinez, Quintiles Inc.
 Copyright (c) 2015, Brian Kelly, Quintiles Inc.
 Copyright (c) 2015, Bryan Strothmann, Quintiles Inc.
 Copyright (c) 2015, Greg Yip, Quintiles Inc.
 Copyright (c) 2015, John Reites, Quintiles Inc.
 Copyright (c) 2015, Pavel Kanzelsberger, Quintiles Inc.
 Copyright (c) 2015, Richard Thomas, Quintiles Inc.
 Copyright (c) 2015, Shelby Brooks, Quintiles Inc.
 Copyright (c) 2015, Steve Cadwallader, Quintiles Inc.
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


#import "ORKWaitStepView.h"
#import "ORKProgressView.h"
#import "ORKAccessibility.h"


static const CGFloat horizontalMargin = 40.0;

@implementation ORKWaitStepView {
    NSArray *_customConstraints;
    ORKProgressIndicatorType _indicatorType;
    ORKProgressView *_activityIndicatorView;
    NSNumberFormatter *_percentFormatter;
}

- (instancetype)initWithIndicatorType:(ORKProgressIndicatorType)type {
    self = [super init];
    if (self) {
        
        _indicatorType = type;
        
        self.stepView = [UIView new];
        self.stepView.translatesAutoresizingMaskIntoConstraints = NO;
        self.verticalCenteringEnabled = YES;
        
        switch (_indicatorType) {
            case ORKProgressIndicatorTypeProgressBar:
                _progressView = [UIProgressView new];
                [self.stepView addSubview:_progressView];
                break;
            case ORKProgressIndicatorTypeIndeterminate:
                _activityIndicatorView = [ORKProgressView new];
                [self.stepView addSubview:_activityIndicatorView];
                break;
        }
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    if (_progressView) {
        ORKEnableAutoLayoutForViews(@[_progressView]);
        
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_progressView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:_progressView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:_progressView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:-horizontalMargin]
                                           ]];
    } else {
        ORKEnableAutoLayoutForViews(@[_activityIndicatorView]);
        
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0.0],
                                           [NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.stepView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:-0.0]
                                           ]];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    if (_progressView) {
        if (!_percentFormatter) {
            _percentFormatter = [[NSNumberFormatter alloc] init];
            _percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
        }
        return ORKAccessibilityStringForVariables(_progressView.accessibilityLabel,
                                                  [_percentFormatter stringFromNumber:[NSNumber numberWithFloat:_progressView.progress]]);
    } else if (_activityIndicatorView) {
        return ORKAccessibilityStringForVariables(_activityIndicatorView.accessibilityLabel);
    }
    return nil;
}

- (UIAccessibilityTraits)accessibilityTraits {
    if (_progressView) {
        return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
    } else {
        return [super accessibilityTraits];
    }
}

@end
