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


#import "ORKWaitStepViewController.h"
#import "ORKWaitStep.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKActiveStepViewController_internal.h"
#import "ORKVerticalContainerView.h"
#import "ORKStepViewController_Internal.h"
#import "ORKResult.h"
#import "ORKLabel.h"
#import "ORKSubheadlineLabel.h"
#import "ORKHelpers.h"
#import "ORKAccessibility.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"


@interface ORKWaitView: ORKActiveStepCustomView

- (instancetype)initWithIndicatorMask:(ORKProgressIndicatorMask)mask heading:(NSString *)heading;

@property (nonatomic, strong) ORKSubheadlineLabel *textLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKProgressView *activityIndicatorView;
@property (nonatomic, assign) ORKProgressIndicatorMask indictatorMask;

@end


@implementation ORKWaitView

- (instancetype)initWithIndicatorMask:(ORKProgressIndicatorMask)mask heading:(NSString *)heading {
    self = [super init];
    if (self) {
        _indictatorMask = mask;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _textLabel = [ORKSubheadlineLabel new];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.text =  heading ? heading : ORKLocalizedString(@"WAIT_LABEL", nil);
        [self addSubview:_textLabel];
        
        switch (_indictatorMask) {
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
        
        [self setupConstraints];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    _progressView.progressTintColor = self.tintColor;
    _activityIndicatorView.tintColor = self.tintColor;
}

- (void)setupConstraints {
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_textLabel]-|"
                                                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                                                   metrics:nil
                                                                views:NSDictionaryOfVariableBindings(_textLabel)]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textLabel]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_textLabel)]];

    if (_progressView) {
        NSDictionary *screenMetric = @{@"progressWidth": [NSNumber numberWithFloat:([UIScreen mainScreen].bounds.size.width - 40.0)]};
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20.0)-[_progressView(progressWidth)]-(20.0)-|" options:NSLayoutFormatAlignAllBaseline metrics:screenMetric views:NSDictionaryOfVariableBindings(_progressView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel]-[_progressView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_progressView, _textLabel)]];

    } else if (_activityIndicatorView) {

        [constraints addObject:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[_activityIndicatorView]-(>=0)-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(_activityIndicatorView)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel]-[_activityIndicatorView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_activityIndicatorView, _textLabel)]];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    if (_progressView) {
        return ORKAccessibilityStringForVariables(_textLabel.accessibilityLabel, _progressView.accessibilityLabel);
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


@interface ORKWaitStepViewController ()

@property (nonatomic, strong) ORKWaitView *waitView;

@end


@implementation ORKWaitStepViewController {
    ORKProgressIndicatorMask _indicatorMask;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.learnMoreButtonItem = nil;
    self.activeStepView.headerView.captionLabel.text = nil;
}

- (void)stepDidChange {
    [super stepDidChange];

    if (!_waitView) {
        _waitView = [[ORKWaitView alloc] initWithIndicatorMask:((ORKWaitStep *)self.step).indicatorMask heading:self.step.title];
        _waitView.translatesAutoresizingMaskIntoConstraints = NO;
        self.activeStepView.activeCustomView = _waitView;
        if (((ORKWaitStep *)self.step).shouldContinueOnFinish) {
            self.activeStepView.continueSkipContainer.hidden = YES;
        } else {
            self.activeStepView.continueSkipContainer.continueEnabled = false;
        }
    }

    _waitView.indictatorMask = ((ORKWaitStep *)self.step).indicatorMask;
    _waitView.textLabel.text = self.step.title ? self.step.title : ORKLocalizedString(@"WAIT_LABEL", nil);
}

- (void)setCurrentProgressIndicatorMask:(ORKProgressIndicatorMask)mask {
    ((ORKWaitStep *)self.step).indicatorMask = mask;
    [super stepDidChange];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [_waitView.progressView setProgress:progress animated:animated];
}

- (void)setProgressDescription:(NSString *)description {
    _waitView.textLabel.text = description;
    [self.view setNeedsLayout];
}

- (void)finish {
    [super finish];
    
    if (!((ORKWaitStep *)self.step).shouldContinueOnFinish) {
        self.activeStepView.continueSkipContainer.continueEnabled = YES;
    }
}

@end
