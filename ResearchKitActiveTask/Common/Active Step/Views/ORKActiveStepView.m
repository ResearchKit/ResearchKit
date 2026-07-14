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


#import "ORKActiveStepView.h"
#import "ORKActiveStepView_Private.h"

#import "ORKActiveStepCustomView.h"
#import "ORKActiveStepTimerView.h"
#import "ORKTintedImageView.h"
#import "ORKStepContainerView_Private.h"

#import "ORKActiveStep_Internal.h"
#import "ORKStep_Private.h"


@implementation  ORKActiveStepView {
    ORKTintedImageView *_imageView;
    ORKActiveStepTimerView *_timerView;
}

- (void)setActiveStep:(ORKActiveStep *)step {
    _activeStep = step;
    self.stepTitle = step.title;
    self.stepText = step.text;
    self.stepDetailText = step.detailText;
    self.stepTopContentImage = step.image;
    self.stepTopContentImageContentMode = step.imageContentMode;
}

- (void)updateTitle:(NSString *)title text:(NSString *)text {
    self.stepTitle = title;
    self.stepText = text;
}

- (void)setActiveCustomView:(ORKActiveStepCustomView *)activeCustomView {
    _activeCustomView = activeCustomView;
    if (_activeCustomView) {
        [self setCustomContentView:activeCustomView withPadding:NSDirectionalEdgeInsetsMake(20, 0, 0, 0)];
    }
}

- (NSArray<UIView *> *)canonicalContentViewOrder {
    NSMutableArray<UIView *> *order = [[super canonicalContentViewOrder] mutableCopy];
    if (_timerView) {
        // Insert timerView immediately before customContentView (after stepContentViewLayoutContainer).
        // If customContentView is absent, insert immediately after stepContentView so the timer
        // stays in the content area above flexible spacer and navigation views.
        NSUInteger idx = [order indexOfObject:self.customContentView];
        if (idx == NSNotFound) {
            NSUInteger scvIdx = [order indexOfObject:self.stepContentView];
            idx = (scvIdx != NSNotFound) ? scvIdx + 1 : 0;
        }
        [order insertObject:_timerView atIndex:MIN(idx, order.count)];
    }
    return order;
}

- (ORKActiveStepTimerView *)timerView {
    return _timerView;
}

- (void)setTimerView:(ORKActiveStepTimerView *)timerView {
    if (_timerView) {
        [self.scrollContentView removeArrangedSubview:_timerView];
        [_timerView removeFromSuperview];
    }
    _timerView = timerView;
    if (_timerView) {
        [self.scrollContentView addArrangedSubview:_timerView];
        [self arrangeContentViews];
        [self.scrollContentView setCustomSpacing:20 afterView:self.stepContentView];
    }
}

- (void)hideStartTimerButton {
    [_timerView hideStartTimerButton];
}

@end
