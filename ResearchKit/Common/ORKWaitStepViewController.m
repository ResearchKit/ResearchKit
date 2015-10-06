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
#import "ORKWaitStepView.h"


@interface ORKWaitStepViewController ()

@property (nonatomic, strong) ORKWaitStepView *waitStepView;

@end


@implementation ORKWaitStepViewController {
    ORKProgressIndicatorMask _indicatorMask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.learnMoreButtonItem = nil;
    [self stepDidChange];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if ([self step] && [self isViewLoaded]) {
        if (!_waitStepView) {
            _waitStepView = [[ORKWaitStepView alloc] initWithIndicatorMask:((ORKWaitStep *)self.step).indicatorMask heading:(self.step.title ? self.step.title : ORKLocalizedString(@"WAIT_LABEL", nil))];
            _waitStepView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:_waitStepView];
            [self setUpConstraints];
        } else {
            _waitStepView.indicatorMask = ((ORKWaitStep *)self.step).indicatorMask;
            _waitStepView.textLabel.text = self.step.title ? self.step.title : ORKLocalizedString(@"WAIT_LABEL", nil);
            [self.view setNeedsUpdateConstraints];
        }
    }
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_waitStepView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_waitStepView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setCurrentProgressIndicatorMask:(ORKProgressIndicatorMask)mask {
    ((ORKWaitStep *)self.step).indicatorMask = mask;
    [super stepDidChange];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [_waitStepView.progressView setProgress:progress animated:animated];
}

- (void)setProgressDescription:(NSString *)description {
    _waitStepView.textLabel.text = description;
    [self.view setNeedsLayout];
}

@end
