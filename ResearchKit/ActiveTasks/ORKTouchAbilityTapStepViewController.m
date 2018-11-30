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


#import "ORKTouchAbilityTapStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTouchAbilityTapContentView.h"
#import "ORKTouchAbilityTapResult.h"
#import "ORKTouchAbilityTrial.h"
#import "ORKTouchAbilityTrial_Internal.h"
#import "ORKTouchAbilityTapTrial.h"
#import "ORKTouchAbilityTouchTracker.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilityTapStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"


NSUInteger numberOfColumnsForTraitCollection(UITraitCollection *traitCollection) {
    
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        return 5;
    } else {
        return 3;
    }
}

NSUInteger numberOfRowsForTraitCollection(UITraitCollection *traitCollection) {
    
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        return 5;
    } else {
        return 3;
    }
}

NSMutableArray<NSValue *> *targetPointsForTraitCollection(UITraitCollection *traitCollection) {
    
    NSUInteger columns = numberOfColumnsForTraitCollection(traitCollection);
    NSUInteger rows = numberOfRowsForTraitCollection(traitCollection);
    
    NSMutableArray *points = [NSMutableArray new];
    for (NSUInteger i = 0; i < columns; i++) {
        for (NSUInteger j = 0; j < rows; j++) {
            CGPoint point = CGPointMake(i, j);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
    }
    
    NSUInteger count = [points count];
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [points exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return points;
}


@interface ORKTouchAbilityTapStepViewController () <ORKTouchAbilityTapContentViewDataSource, ORKTouchAbilityCustomViewDelegate>

// Data
@property (nonatomic, strong) NSMutableArray<NSValue *> *targetPointsQueue;
@property (nonatomic, strong) NSMutableArray<ORKTouchAbilityTapTrial *> *trials;

// UI
@property (nonatomic, strong) ORKTouchAbilityTapContentView *touchAbilityTapContentView;

@end

@implementation ORKTouchAbilityTapStepViewController


#pragma mark - ORKActiveStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (ORKTouchAbilityTapStep *)touchAbilityTapStep {
    return (ORKTouchAbilityTapStep *)self.step;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:sResult.results];
    
    ORKTouchAbilityTapResult *tapResult = [[ORKTouchAbilityTapResult alloc] initWithIdentifier:self.step.identifier];
    
    tapResult.trials = [self.trials mutableCopy];
    
    [results addObject:tapResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)finish {
    [self.touchAbilityTapContentView stopTracking];
    [super finish];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trials = [NSMutableArray new];
    self.targetPointsQueue = targetPointsForTraitCollection(self.traitCollection);
    
    self.touchAbilityTapContentView = [[ORKTouchAbilityTapContentView alloc] init];
    self.touchAbilityTapContentView.dataSource = self;
    self.touchAbilityTapContentView.delegate = self;
    
    self.activeStepView.activeCustomView = self.touchAbilityTapContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.activeStepView.scrollContainerShouldCollapseNavbar = NO;
    
    [self.activeStepView updateTitle:nil text:@"FOOOOOOOOOO barrrrrrr"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self.touchAbilityTapContentView startTracking];
}


#pragma mark - ORKTouchAbilityTapContentViewDataSource

- (NSUInteger)numberOfColumns:(ORKTouchAbilityTapContentView *)tapContentView {
    return numberOfColumnsForTraitCollection(self.traitCollection);
}

- (NSUInteger)numberOfRows:(ORKTouchAbilityTapContentView *)tapContentView {
    return numberOfRowsForTraitCollection(self.traitCollection);
}

- (NSUInteger)targetColumn:(ORKTouchAbilityTapContentView *)tapContentView {
    return [self.targetPointsQueue.lastObject CGPointValue].x;
}

- (NSUInteger)targetRow:(ORKTouchAbilityTapContentView *)tapContentView {
    return [self.targetPointsQueue.lastObject CGPointValue].y;
}


#pragma mark - ORKTouchAbilityCustomViewDelegate

- (void)touchAbilityCustomViewDidBeginNewTrack:(ORKTouchAbilityCustomView *)customView {
//    if (!self.isStarted) {
//        [self start];
//    }
}

- (void)touchAbilityCustomViewDidCompleteNewTracks:(ORKTouchAbilityCustomView *)customView {
    
    
    // Convert target view's frame to window.
    
    ORKTouchAbilityTapContentView *tapContentView = (ORKTouchAbilityTapContentView *)customView;
    CGRect frame = [tapContentView.targetView convertRect:tapContentView.targetView.bounds toView:nil];
    
    
    // Initiate a new trial.
    
    ORKTouchAbilityTapTrial *trial = [[ORKTouchAbilityTapTrial alloc] initWithTargetFrameInWindow:frame];
    trial.tracks = tapContentView.tracks;
    trial.gestureRecognizerEvents = tapContentView.gestureRecognizerEvents;
    
    
    // Add the trial to trials and remove the target point from the target points queue.
    
    [self.trials addObject:trial];
    [self.targetPointsQueue removeLastObject];
    
    
    // Calculate current progress and display using progress view.
    
    NSUInteger total = numberOfColumnsForTraitCollection(self.traitCollection) * numberOfRowsForTraitCollection(self.traitCollection);
    NSUInteger done = total - self.targetPointsQueue.count;
    CGFloat progress = (CGFloat)done/(CGFloat)total;
    
    [self.touchAbilityTapContentView setProgress:progress animated:YES];
    
    
    // Determind if should continue or finish.
    
    if (self.targetPointsQueue.count > 0) {
        [self.touchAbilityTapContentView setTargetViewHidden:YES animated:YES];
        [self performSelector:@selector(presentNextTrial) withObject:nil afterDelay:1.0];
    } else {
        [self.touchAbilityTapContentView stopTracking];
        [self.touchAbilityTapContentView setTargetViewHidden:YES animated:YES];
        [self performSelector:@selector(finish) withObject:nil afterDelay:1.0]; // [self finish];
    }
}

- (void)presentNextTrial {
    [self.touchAbilityTapContentView stopTracking];
    [self.touchAbilityTapContentView reloadData];
    [self.touchAbilityTapContentView setTargetViewHidden:NO animated:NO];
    [self.touchAbilityTapContentView startTracking];
}

@end
