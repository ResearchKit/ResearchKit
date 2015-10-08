//
//  ORKWaitStepView.m
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/6/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//


#import "ORKWaitStepView.h"
#import "ORKProgressView.h"
#import "ORKAccessibility.h"


static const CGFloat horizontalMargin = 40.0;

@implementation ORKWaitStepView {
    NSArray *_customConstraints;
    ORKProgressIndicatorType _indicatorType;
    ORKProgressView *_activityIndicatorView;
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
        NSNumberFormatter *percentFormatter = [NSNumberFormatter new];
        percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
        return ORKAccessibilityStringForVariables(_progressView.accessibilityLabel,
                                                  [percentFormatter stringFromNumber:[NSNumber numberWithFloat:_progressView.progress]]);
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
