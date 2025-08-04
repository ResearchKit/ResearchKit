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


#import "ORKTouchAbilitySwipeStepViewController.h"


#import "ORKActiveStepView.h"
#import "ORKTouchAbilitySwipeContentView.h"
#import "ORKTouchAbilitySwipeResult.h"
#import "ORKTouchAbilitySwipeTrial.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilitySwipeStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"


@interface ORKTouchAbilitySwipeStepViewController () <ORKTouchAbilitySwipeContentViewDataSource, ORKTouchAbilityContentViewDelegate>

// Data
@property (nonatomic, assign) NSUInteger currentTrialIndex;
@property (nonatomic, strong) NSArray<NSNumber *> *targetDirectionQueue;
@property (nonatomic, strong) NSMutableArray<ORKTouchAbilitySwipeTrial *> *trials;

// UI
@property (nonatomic, strong) ORKTouchAbilitySwipeContentView *swipeContentView;

@end

@implementation ORKTouchAbilitySwipeStepViewController


#pragma mark - ORKActiveStepViewController

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
    
    ORKTouchAbilitySwipeResult *swipeResult = [[ORKTouchAbilitySwipeResult alloc] initWithIdentifier:self.step.identifier];
    
    swipeResult.trials = self.trials;
    
    [results addObject:swipeResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)finish {
    [self.swipeContentView endTrial];
    [super finish];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentTrialIndex = 0;
    self.targetDirectionQueue = [self targetDirections];
    self.trials = [NSMutableArray new];
    
    self.swipeContentView = [[ORKTouchAbilitySwipeContentView alloc] init];
    self.swipeContentView.dataSource = self;
    self.swipeContentView.delegate = self;
    
    self.activeStepView.activeCustomView = self.swipeContentView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self.swipeContentView startTrial];
}

- (NSArray<NSNumber *> *)targetDirections {
    
    NSMutableArray *directions = @[@(UISwipeGestureRecognizerDirectionUp),
                                   @(UISwipeGestureRecognizerDirectionDown),
                                   @(UISwipeGestureRecognizerDirectionLeft),
                                   @(UISwipeGestureRecognizerDirectionRight)].mutableCopy;
    [directions addObjectsFromArray:directions];
    
    NSUInteger count = [directions count];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [directions exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return [directions copy];
}

#pragma mark - ORKTouchAbilitySwipeContentViewDataSource

- (UISwipeGestureRecognizerDirection)targetDirectionInSwipeContentView:(ORKTouchAbilitySwipeContentView *)swipeContentView {
    return [self.targetDirectionQueue[self.currentTrialIndex] intValue];

}


#pragma mark - ORKTouchAbilityContentViewDelegate

- (void)touchAbilityContentViewDidBeginNewTrack:(ORKTouchAbilityContentView *)contentView {
    
}

- (void)touchAbilityContentViewDidCompleteNewTracks:(ORKTouchAbilityContentView *)contentView {
    
    
    // Calculate current progress and display using progress view.
    
    NSUInteger total = self.targetDirectionQueue.count;
    NSUInteger done = self.currentTrialIndex + 1;
    CGFloat progress = (CGFloat)done/(CGFloat)total;
    
    [contentView setProgress:progress animated:YES];
    
    
    // Animate the target view.
    
    ORKWeakTypeOf(contentView) weakContentView = contentView;
    
    [contentView setContentViewHidden:YES animated:YES completion:^(BOOL finished) {
        
        ORKStrongTypeOf(contentView) strongContentView = weakContentView;
        
        // Stop tracking new touch events.
        
        [strongContentView endTrial];
        
        [self.trials addObject:(ORKTouchAbilitySwipeTrial *)strongContentView.trial];
        
        
        // Determind if should continue or finish.
        
        self.currentTrialIndex += 1;
        if (self.currentTrialIndex < self.targetDirectionQueue.count) {
            
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
