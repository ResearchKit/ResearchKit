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
#import "ORKTintedImageView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKActiveStep_Internal.h"
#import "ORKStep_Private.h"


@implementation  ORKActiveStepView {
    ORKTintedImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [ORKTintedImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self tintColorDidChange];
    }
    return self;
}

- (void)updateStepView {
    if (_activeCustomView) {
        self.stepView = _activeCustomView;
    } else if (_imageView.image) {
        self.stepView = _imageView;
    } else {
        self.stepView = nil;
    }
}

- (void)setActiveStep:(ORKActiveStep *)step {
    self.continueSkipContainer.useNextForSkip = step.shouldUseNextAsSkipButton;
    _activeStep = step;
    self.headerView.instructionLabel.hidden = !(_activeStep.hasText);
    
    self.headerView.captionLabel.text = _activeStep.title;
    self.headerView.instructionLabel.text = _activeStep.text;
    self.continueSkipContainer.optional = _activeStep.optional;
    self.stepViewFillsAvailableSpace = YES;
    
    _imageView.image = _activeStep.image;
    _imageView.shouldApplyTint = _activeStep.shouldTintImages;
    [self updateStepView];
    
    BOOL neverHasContinueButton = (step.shouldContinueOnFinish && !step.startsFinished);
    [self.continueSkipContainer setNeverHasContinueButton:neverHasContinueButton];
    
    [self.continueSkipContainer updateContinueAndSkipEnabled];
}

- (void)updateTitle:(NSString *)title text:(NSString *)text {
    ORKStepHeaderView *headerView = [self headerView];
    [headerView.captionLabel setText:title];
    [headerView.instructionLabel setText:text];
    headerView.instructionLabel.hidden = (text == nil);
    [headerView updateCaptionLabelPreferredWidth];
}

- (void)setActiveCustomView:(ORKActiveStepCustomView *)activeCustomView {
    _activeCustomView = activeCustomView;
    [self updateStepView];
}

@end
