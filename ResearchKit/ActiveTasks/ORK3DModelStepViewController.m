/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORK3DModelManager.h"
#import "ORK3DModelManager_Internal.h"
#import "ORK3DModelStep.h"
#import "ORK3DModelStepContentView.h"
#import "ORK3DModelStepViewController.h"
#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKCollectionResult_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepViewController_Internal.h"

@implementation ORK3DModelStepViewController {
    ORK3DModelManager *_modelManager;
    ORK3DModelStepContentView *_stepContentview;
    ORK3DModelStep *_step;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        _step = [self threeDimensionalModelStep];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _stepContentview = [ORK3DModelStepContentView new];
    _stepContentview.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _stepContentview;
    self.activeStepView.customContentFillsAvailableSpace = NO;
    self.activeStepView.navigationFooterView.neverHasContinueButton = NO;
    
    [[_stepContentview.bottomAnchor constraintEqualToAnchor:self.activeStepView.navigationFooterView.topAnchor] setActive:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableContinueButton:)
                                                 name:ORK3DModelDisableContinueButtonNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(enableContinueButton:)
                                                    name:ORK3DModelEnableContinueButtonNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endStep:)
                                                 name:ORK3DModelEndStepNotification
                                               object:nil];
    
    [self activate3DModelManager];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORK3DModelDisableContinueButtonNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORK3DModelEnableContinueButtonNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORK3DModelEndStepNotification object:nil];
}

- (void)activate3DModelManager {
    _modelManager = _step.modelManager;
    
    [_modelManager addContentToView:_stepContentview];
}

- (void)stepDidFinish {
    [super stepDidFinish];
    
    if (_modelManager) {
        [_modelManager stepWillEnd];
    }
    
    [self goForward];
}

- (ORK3DModelStep *)threeDimensionalModelStep {
    return (ORK3DModelStep *)self.step;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    if (_modelManager) {
        NSArray<ORKResult *> *managerResults = [_modelManager provideResults];
        if (managerResults) {
            stepResult.results = [managerResults copy];
        }
    }
    
    return stepResult;
}

#pragma mark - Notification Methods

- (void)disableContinueButton:(NSNotification *)notification {
    self.activeStepView.navigationFooterView.continueEnabled = NO;
}

- (void)enableContinueButton:(NSNotification *)notification {
    self.activeStepView.navigationFooterView.continueEnabled = YES;
}

- (void)endStep:(NSNotification *)notification {
    [self finish];
}

@end

