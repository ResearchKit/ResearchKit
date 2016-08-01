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


#import "ORKVerificationStepView.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"


@implementation ORKVerificationStepView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.stepView = [UIView new];
        self.stepView.translatesAutoresizingMaskIntoConstraints = NO;
        
        _resendEmailButton = [UIButton new];
        [_resendEmailButton setTitle:ORKLocalizedString(@"RESEND_EMAIL_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        [_resendEmailButton setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self.stepView addSubview:_resendEmailButton];
        
        [self setUpConstraints];
        
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_resendEmailButton);
    ORKEnableAutoLayoutForViews(views.allValues);
    const CGFloat textBaselineToResendButtonBaselineMetric = ORKGetMetricForWindow(ORKScreenMetricVerificationTextBaselineToResendButtonBaseline, self.window);
    
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_resendEmailButton
                                                                    attribute:NSLayoutAttributeFirstBaseline
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.headerView.instructionLabel
                                                                    attribute:NSLayoutAttributeLastBaseline
                                                                   multiplier:1.0
                                                                     constant:textBaselineToResendButtonBaselineMetric],
                                       [NSLayoutConstraint constraintWithItem:_resendEmailButton
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.stepView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0]
                                       ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_resendEmailButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_resendEmailButton]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [_resendEmailButton setTitleColor:self.tintColor forState:UIControlStateNormal];
}

@end
