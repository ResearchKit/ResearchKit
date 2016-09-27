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

#import "ORKNavigationContainerView.h"

#import "ORKAccessibility.h"
#import "ORKSkin.h"


@implementation ORKWaitStepView {
    NSArray *_customConstraints;
    ORKProgressIndicatorType _indicatorType;
    UIActivityIndicatorView *_activityIndicatorView;
    NSNumberFormatter *_percentFormatter;
}

- (instancetype)initWithIndicatorType:(ORKProgressIndicatorType)type {
    self = [super init];
    if (self) {
        
        _indicatorType = type;
        
        self.stepView = [UIView new];
        switch (_indicatorType) {
            case ORKProgressIndicatorTypeProgressBar:
                _progressView = [UIProgressView new];
                [self.stepView addSubview:_progressView];
                break;
            case ORKProgressIndicatorTypeIndeterminate:
                _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [_activityIndicatorView startAnimating];
                [self.stepView addSubview:_activityIndicatorView];
                break;
        }
        self.verticalCenteringEnabled = YES;
        self.continueHugsContent = YES;
        self.stepViewFillsAvailableSpace = NO;
        self.continueSkipContainer.neverHasContinueButton = YES;

        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
  
    UIView *indicatorView = _progressView ? :(_activityIndicatorView ? : nil);
    
    if (indicatorView) {
        
        const CGFloat horizontalMargin = 2 * ORKStandardHorizontalMarginForView(self);
        
        self.stepView.translatesAutoresizingMaskIntoConstraints = NO;
        indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSMutableArray *constraints = [NSMutableArray new];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-horizontalMargin-[indicatorView]-horizontalMargin-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:@{@"horizontalMargin": @(horizontalMargin)}
                                                                                   views:@{@"indicatorView": indicatorView}]];
        
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[indicatorView]-|"
                                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:nil
                                                                                   views:@{@"indicatorView": indicatorView}]];
        
        [NSLayoutConstraint activateConstraints:constraints];
    }
}

@end
