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

@implementation ORKWaitStepView {
    NSArray *_customConstraints;
}

- (instancetype)initWithIndicatorMask:(ORKProgressIndicatorMask)mask heading:(NSString *)heading {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [ORKSubheadlineLabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.text =  heading ? heading : ORKLocalizedString(@"WAIT_LABEL", nil);
        [self addSubview:_textLabel];
        
        _indicatorMask = mask;
        [self updateIndicatorMaskView];
        
        [self setUpConstraints];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabel]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_textLabel)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_textLabel)]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    
    NSMutableArray *constraints = [NSMutableArray new];
    [self removeConstraints:_customConstraints];
    
    if (_progressView) {
        NSDictionary *screenMetric = @{@"progressWidth": [NSNumber numberWithFloat:([UIScreen mainScreen].bounds.size.width - 40.0)]};
        
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20.0)-[_progressView(progressWidth)]-(20.0)-|"
                                                 options:NSLayoutFormatAlignAllBaseline
                                                 metrics:screenMetric
                                                   views:NSDictionaryOfVariableBindings(_progressView)]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel]-[_progressView]|"
                                                 options:NSLayoutFormatAlignAllCenterX
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(_progressView, _textLabel)]];
        
    } else if (_activityIndicatorView) {
        
        [constraints addObject:
         [NSLayoutConstraint constraintWithItem:_activityIndicatorView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0
                                       constant:0.0]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_activityIndicatorView]-(>=0)-|"
                                                 options:NSLayoutFormatAlignAllBaseline
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(_activityIndicatorView)]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel]-[_activityIndicatorView]|"
                                                 options:NSLayoutFormatAlignAllCenterX
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings(_activityIndicatorView, _textLabel)]];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    _customConstraints = [constraints copy];
    
    [super updateConstraints];
}

- (void)setIndicatorMask:(ORKProgressIndicatorMask)indicatorMask {
    if (_indicatorMask != indicatorMask) {
        _indicatorMask = indicatorMask;
        [self updateIndicatorMaskView];
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateIndicatorMaskView {
    
    if (_activityIndicatorView) {
        [_activityIndicatorView removeFromSuperview];
        _activityIndicatorView = nil;
    }
    if (_progressView) {
        [_progressView removeFromSuperview];
        _progressView = nil;
    }
    
    switch (_indicatorMask) {
        case ORKProgressIndicatorMaskProgressBar:
            _progressView = [UIProgressView new];
            _progressView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_progressView];
            break;
        case ORKProgressIndicatorMaskIndeterminate:
            _activityIndicatorView = [[ORKProgressView alloc] init];
            _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_activityIndicatorView];
            break;
        default:
            break;
    }
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    if (_progressView) {
        NSNumberFormatter *percentFormatter = [[NSNumberFormatter alloc] init];
        percentFormatter.numberStyle = NSNumberFormatterPercentStyle;
        return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel,
                                                  _progressView.accessibilityLabel,
                                                  [percentFormatter stringFromNumber:[NSNumber numberWithFloat:_progressView.progress]]);
    } else if (_activityIndicatorView) {
        return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel,
                                                  _activityIndicatorView.accessibilityLabel);
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
