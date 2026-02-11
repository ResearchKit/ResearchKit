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

#import "ORKTouchAbilityScrollStepViewController.h"
#import "ORKTouchAbilityScrollStep.h"

#import "ORKActiveStepView.h"
#import "ORKTouchAbilityScrollContentView.h"
#import "ORKTouchAbilityScrollResult.h"
#import "ORKTouchAbilityScrollTrial.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilitySwipeStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"


#define TrialData(n, m, t, d) @[@(n), @(m), @(t), @(d)]

#define TrialDataGetNumberOfItems(data) [data[0] unsignedIntegerValue]
#define TrialDataGetNumberOfMiddleItems(data) [data[1] unsignedIntegerValue]
#define TrialDataGetTargetItem(data) [data[2] unsignedIntegerValue]
#define TrialDataGetDestination(data) [data[3] unsignedIntegerValue]

@interface ORKTouchAbilityScrollStepViewController () <
ORKTouchAbilityScrollContentViewDataSource,
ORKTouchAbilityContentViewDelegate
>

// Data
@property (nonatomic, assign) NSUInteger currentTrialIndex;
@property (nonatomic, strong) NSArray<NSArray *> *trialDataQueue;
@property (nonatomic, strong) NSMutableArray<ORKTouchAbilityScrollTrial *> *trials;

@property (nonatomic, copy) dispatch_block_t endTrialWork;

// UI
@property (nonatomic, strong) ORKTouchAbilityScrollContentView *contentView;

@end

@implementation ORKTouchAbilityScrollStepViewController

- (BOOL)isHorizontalStep {
    return ((ORKTouchAbilityScrollStep *)self.step).isHorizontal;
}


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
    
    ORKTouchAbilityScrollResult *scrollResult = [[ORKTouchAbilityScrollResult alloc] initWithIdentifier:self.step.identifier];
    
    scrollResult.trials = self.trials;
    
    [results addObject:scrollResult];
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
    
    self.currentTrialIndex = 0;
    self.trialDataQueue = [self makeTrialDataQueue];
    self.trials = [NSMutableArray new];
    
    self.contentView = [[ORKTouchAbilityScrollContentView alloc] init];
    self.contentView.direction = self.isHorizontalStep ? ORKTouchAbilityScrollTrialDirectionHorizontal : ORKTouchAbilityScrollTrialDirectionVertical;
    self.contentView.dataSource = self;
    self.contentView.delegate = self;
    
    self.activeStepView.activeCustomView = self.contentView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self.contentView startTrial];
}

- (NSArray *)makeTrialDataQueue {
    
    NSMutableArray *array = [NSMutableArray array];
    
    [array addObject:TrialData(19, 5, 7, 11)];
    [array addObject:TrialData(19, 5, 9, 11)];
    [array addObject:TrialData(19, 5, 9, 7)];
    [array addObject:TrialData(19, 5, 11, 7)];
    [array addObjectsFromArray:array];
    
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return [array copy];
}

#pragma mark - ORKTouchAbilityScrollContentViewDataSource

- (NSUInteger)numberOfItemsInScrollContentView:(ORKTouchAbilityScrollContentView *)scrollContentView {
    return TrialDataGetNumberOfItems(self.trialDataQueue[self.currentTrialIndex]);
}

- (NSUInteger)numberOfVisibleItemsInScrollContentView:(ORKTouchAbilityScrollContentView *)scrollContentView {
    return TrialDataGetNumberOfMiddleItems(self.trialDataQueue[self.currentTrialIndex]) + 1;
}

- (NSUInteger)initialItemInScrollContentView:(ORKTouchAbilityScrollContentView *)scrollContentView {
    return TrialDataGetTargetItem(self.trialDataQueue[self.currentTrialIndex]);
}

- (NSUInteger)targetItemInScrollContentView:(ORKTouchAbilityScrollContentView *)scrollContentView {
    return TrialDataGetDestination(self.trialDataQueue[self.currentTrialIndex]);
}


#pragma mark - ORKTouchAbilityContentViewDelegate

- (void)touchAbilityContentViewDidBeginNewTrack:(ORKTouchAbilityContentView *)contentView {
    
    if (self.endTrialWork) {
        dispatch_block_cancel(self.endTrialWork);
        self.endTrialWork = nil;
    }
}

- (void)touchAbilityContentViewDidCompleteNewTracks:(ORKTouchAbilityContentView *)contentView {
    
    self.endTrialWork = dispatch_block_create(DISPATCH_BLOCK_NO_QOS_CLASS, ^{
        [self endTrial];
    });
    
    NSTimeInterval delay = self.contentView.timeIntervalBeforeStopDecelarating + 1.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), self.endTrialWork);
}

- (void)endTrial {
    
    // Calculate current progress and display using progress view.
    
    NSUInteger total = self.trialDataQueue.count;
    NSUInteger done = self.currentTrialIndex + 1;
    CGFloat progress = (CGFloat)done/(CGFloat)total;
    
    [self.contentView setProgress:progress animated:YES];
    
    
    // Animate the target view.
    
    ORKWeakTypeOf(self) weakSelf = self;
    [self.contentView setContentViewHidden:YES animated:YES completion:^(BOOL finished) {
        
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        
        // Stop tracking new touch events.
        
        [strongSelf.contentView endTrial];
        
        [strongSelf.trials addObject:(ORKTouchAbilityScrollTrial *)strongSelf.contentView.trial];
        
        
        // Determind if should continue or finish.
        
        strongSelf.currentTrialIndex += 1;
        if (strongSelf.currentTrialIndex < strongSelf.trialDataQueue.count) {
            
            // Reload and start tracking again.
            [strongSelf.contentView reloadData];
            [strongSelf.contentView setContentViewHidden:NO animated:NO];
            [strongSelf.contentView startTrial];
            
        } else {
            
            // Finish step.
            [strongSelf finish];
        }
        
    }];
    
}

@end
