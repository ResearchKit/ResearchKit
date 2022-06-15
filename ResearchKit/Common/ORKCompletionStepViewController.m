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


#import "ORKCompletionStepViewController.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKInstructionStepContainerView.h"
#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepView_Private.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepContentView_Private.h"

#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKCompletionCheckmarkView.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"


@implementation ORKCompletionStepViewController {
    ORKCompletionCheckmarkView *_completionCheckmarkView;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    self.cancelButtonItem = nil;
    _completionCheckmarkView = [self.stepView.stepContentView completionCheckmarkView];
    [_completionCheckmarkView setNeedsLayout];
    if (self.checkmarkColor) {
        _completionCheckmarkView.tintColor = self.checkmarkColor;
    }
    self.stepView.customContentFillsAvailableSpace = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _completionCheckmarkView.animationPoint = animated ? 0 : 1;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (animated) {
        [_completionCheckmarkView setAnimationPoint:1 animated:YES];
    }
}

- (void)setCheckmarkColor:(UIColor *)checkmarkColor {
    _checkmarkColor = [checkmarkColor copy];
    _completionCheckmarkView.tintColor = checkmarkColor;
}

@end
