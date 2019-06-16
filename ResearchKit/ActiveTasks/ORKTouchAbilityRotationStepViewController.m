/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityRotationStepViewController.h"

#import "ORKTouchAbilityRotationContentView.h"
#import "ORKTouchAbilityRotationStep.h"
#import "ORKTouchAbilityRotationResult.h"

#import "ORKActiveStepView.h"
#import "ORKNavigableOrderedTask.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"

@interface ORKTouchAbilityRotationStepViewController () <ORKTouchAbilityRotationContentViewDataSource, ORKTouchAbilityContentViewDelegate>

// Data
@property (nonatomic, assign) NSUInteger currentTrialIndex;
@property (nonatomic, strong) NSArray<NSNumber *> *targetRotationQueue;
@property (nonatomic, strong) NSMutableArray<ORKTouchAbilityRotationTrial *> *trials;

// UI
@property (nonatomic, strong) ORKTouchAbilityRotationContentView *contentView;

@end

@implementation ORKTouchAbilityRotationStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:sResult.results];
    
    ORKTouchAbilityRotationResult *rotationResult = [[ORKTouchAbilityRotationResult alloc] initWithIdentifier:self.step.identifier];
    
    rotationResult.trials = self.trials;
    
    [results addObject:rotationResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)finish {
    [self.contentView endTrial];
    [super finish];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trials = [NSMutableArray new];
    self.targetRotationQueue = [self targetRotation];
    self.currentTrialIndex = 0;
    
    self.contentView = [[ORKTouchAbilityRotationContentView alloc] init];
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    
    self.activeStepView.activeCustomView = self.contentView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self.contentView startTrial];
}

- (NSArray *)targetRotation {
    
    NSMutableArray *array = @[@(M_PI/3.0), @(M_PI/6.0), @(-M_PI/6.0), @(-M_PI/3.0)].mutableCopy;
    [array addObjectsFromArray:array];
    
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return [array copy];
}


#pragma mark - ORKTouchAbilityRotationContentViewDataSource

- (CGFloat)targetRotationInRotationContentView:(ORKTouchAbilityRotationContentView *)rotationContentView {
    return [self.targetRotationQueue[self.currentTrialIndex] doubleValue];
}


#pragma mark - ORKTouchAbilityContentViewDelegate

- (void)touchAbilityContentViewDidCompleteNewTracks:(ORKTouchAbilityContentView *)contentView {
    
    NSUInteger total = self.targetRotationQueue.count;
    NSUInteger done = self.currentTrialIndex + 1;
    CGFloat progress = (CGFloat)done/(CGFloat)total;
    
    [contentView setProgress:progress animated:YES];
    
    // Animate the target view.
    
    ORKWeakTypeOf(contentView) weakContentView = contentView;
    [contentView setContentViewHidden:YES animated:YES completion:^(BOOL finished) {
        ORKStrongTypeOf(contentView) strongContentView = weakContentView;
        
        // Stop tracking new touch events.
        
        [strongContentView endTrial];
        
        [self.trials addObject:(ORKTouchAbilityRotationTrial *)strongContentView.trial];
        
        // Determind if should continue or finish.
        
        self.currentTrialIndex += 1;
        if (self.currentTrialIndex < self.targetRotationQueue.count) {
            
            // Reload and start tracking again.
            [strongContentView reloadData];
            [strongContentView setContentViewHidden:NO animated:NO];
            [strongContentView startTrial];
            
        } else {
            
            // Finish step.
            [self finish];
        }
    }];
}

@end
