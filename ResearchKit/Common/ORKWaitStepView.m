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

@implementation ORKWaitStepView

- (instancetype)initWithIndicatorMask:(ORKProgressIndicatorMask)mask heading:(NSString *)heading {
    self = [super init];
    if (self) {
        _indicatorMask = mask;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [ORKSubheadlineLabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.text =  heading ? heading : ORKLocalizedString(@"WAIT_LABEL", nil);
        [self addSubview:_textLabel];
        
        switch (_indicatorMask) {
            case ORKProgressIndicatorMaskProgressBar:
                _progressView = [UIProgressView new];
                _progressView.translatesAutoresizingMaskIntoConstraints = NO;
                _progressView.progressTintColor = self.tintColor;
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
}

- (void)setIndicatorMask:(ORKProgressIndicatorMask)indicatorMask {
    if (_indicatorMask != indicatorMask) {
        _indicatorMask = indicatorMask;
        
        switch (_indicatorMask) {
            case ORKProgressIndicatorMaskProgressBar:
                [_activityIndicatorView removeFromSuperview];
                _activityIndicatorView = nil;
                _progressView = [UIProgressView new];
                _progressView.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:_progressView];
                break;
            case ORKProgressIndicatorMaskIndeterminate:
                [_progressView removeFromSuperview];
                _progressView = nil;
                _activityIndicatorView = [[ORKProgressView alloc] init];
                _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:_activityIndicatorView];
                break;
            default:
                break;
        }
        
        [self setUpConstraints];
        [self setNeedsUpdateConstraints];
    }
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    if (_progressView) {
        NSString *percentage = [NSString stringWithFormat:@"%li%%", (NSInteger)(_progressView.progress * 100.0)];
        return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel, _progressView.accessibilityLabel, percentage);
    } else if (_activityIndicatorView) {
        return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel, _activityIndicatorView.accessibilityLabel);
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
