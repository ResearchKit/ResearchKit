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



#import "ORKTouchAbilityLongPressStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTouchAbilityLongPressContentView.h"
#import "ORKTouchAbilityLongPressResult.h"
#import "ORKTouchAbilityTrial.h"
#import "ORKTouchAbilityTrial_Internal.h"
#import "ORKTouchAbilityLongPressTrial.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilityLongPressStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"


//NSUInteger numberOfColumnsForTraitCollection(UITraitCollection *traitCollection) {
//
//    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
//        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
//        return 5;
//    } else {
//        return 3;
//    }
//}
//
//NSUInteger numberOfRowsForTraitCollection(UITraitCollection *traitCollection) {
//
//    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
//        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
//        return 5;
//    } else {
//        return 3;
//    }
//}
//
//NSMutableArray<NSValue *> *targetPointsForTraitCollection(UITraitCollection *traitCollection) {
//
//    NSUInteger columns = numberOfColumnsForTraitCollection(traitCollection);
//    NSUInteger rows = numberOfRowsForTraitCollection(traitCollection);
//
//    NSMutableArray *points = [NSMutableArray new];
//    for (NSUInteger i = 0; i < columns; i++) {
//        for (NSUInteger j = 0; j < rows; j++) {
//            CGPoint point = CGPointMake(i, j);
//            [points addObject:[NSValue valueWithCGPoint:point]];
//        }
//    }
//
//    NSUInteger count = [points count];
//    for (NSUInteger i = 0; i < count; i++) {
//        NSUInteger nElements = count - i;
//        NSUInteger n = (arc4random() % nElements) + i;
//        [points exchangeObjectAtIndex:i withObjectAtIndex:n];
//    }
//
//    return points;
//}


@interface ORKTouchAbilityLongPressStepViewController () <ORKTouchAbilityLongPressContentViewDataSource, ORKTouchAbilityCustomViewDelegate>

// Data
@property (nonatomic, strong) NSMutableArray<NSValue *> *targetPointsQueue;
@property (nonatomic, strong) NSMutableArray<ORKTouchAbilityLongPressTrial *> *trials;

// UI
@property (nonatomic, strong) ORKTouchAbilityLongPressContentView *touchAbilityLongPressContentView;

@end

@implementation ORKTouchAbilityLongPressStepViewController


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
    
    ORKTouchAbilityLongPressResult *lpResult = [[ORKTouchAbilityLongPressResult alloc] initWithIdentifier:self.step.identifier];
    
    lpResult.trials = [self.trials mutableCopy];
    
    [results addObject:lpResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (void)finish {
    [self.touchAbilityLongPressContentView stopTracking];
    [super finish];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.trials = [NSMutableArray new];
    self.targetPointsQueue = [self targetPointsForTraitCollection:self.traitCollection];
    
    self.touchAbilityLongPressContentView = [[ORKTouchAbilityLongPressContentView alloc] init];
    self.touchAbilityLongPressContentView.dataSource = self;
    self.touchAbilityLongPressContentView.delegate = self;
    
    self.activeStepView.activeCustomView = self.touchAbilityLongPressContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.activeStepView.scrollContainerShouldCollapseNavbar = NO;
    
    [self.activeStepView updateTitle:nil text:@"FOOOOOOOOOO barrrrrrr"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self start];
    [self.touchAbilityLongPressContentView startTracking];
}


#pragma mark - ORKTouchAbilityLongPressStepViewController

- (NSUInteger)numberOfColumnsForTraitCollection:(UITraitCollection *)traitCollection {
    
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        return 5;
    } else {
        return 3;
    }
}

- (NSUInteger)numberOfRowsForTraitCollection:(UITraitCollection *)traitCollection {
    
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {
        return 5;
    } else {
        return 3;
    }
}

- (NSMutableArray<NSValue *> *)targetPointsForTraitCollection:(UITraitCollection *)traitCollection {
    
    NSUInteger columns = [self numberOfColumnsForTraitCollection:self.traitCollection];
    NSUInteger rows = [self numberOfRowsForTraitCollection:self.traitCollection];
    
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


#pragma mark - ORKTouchAbilityTapContentViewDataSource

- (NSUInteger)numberOfColumns:(ORKTouchAbilityLongPressContentView *)tapContentView {
    return [self numberOfColumnsForTraitCollection:self.traitCollection];
}

- (NSUInteger)numberOfRows:(ORKTouchAbilityLongPressContentView *)tapContentView {
    return [self numberOfRowsForTraitCollection:self.traitCollection];
}

- (NSUInteger)targetColumn:(ORKTouchAbilityLongPressContentView *)tapContentView {
    return [self.targetPointsQueue.lastObject CGPointValue].x;
}

- (NSUInteger)targetRow:(ORKTouchAbilityLongPressContentView *)tapContentView {
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
    
    ORKTouchAbilityLongPressContentView *longPressContentView = (ORKTouchAbilityLongPressContentView *)customView;
    CGRect frame = [longPressContentView.targetView convertRect:longPressContentView.targetView.bounds toView:nil];
    
    
    // Initiate a new trial.
    
    ORKTouchAbilityLongPressTrial *trial = [[ORKTouchAbilityLongPressTrial alloc] initWithTargetFrameInWindow:frame];
    trial.tracks = longPressContentView.tracks;
    trial.gestureRecognizerEvents = longPressContentView.gestureRecognizerEvents;
    
    
    // Add the trial to trials and remove the target point from the target points queue.
    
    [self.trials addObject:trial];
    [self.targetPointsQueue removeLastObject];
    
    
    // Calculate current progress and display using progress view.
    
    NSUInteger total = [self numberOfColumnsForTraitCollection:self.traitCollection] * [self numberOfRowsForTraitCollection:self.traitCollection];
    NSUInteger done = total - self.targetPointsQueue.count;
    CGFloat progress = (CGFloat)done/(CGFloat)total;
    
    [self.touchAbilityLongPressContentView setProgress:progress animated:YES];
    
    
    // Determind if should continue or finish.
    
    if (self.targetPointsQueue.count > 0) {
        [self.touchAbilityLongPressContentView setTargetViewHidden:YES animated:YES];
        [self performSelector:@selector(presentNextTrial) withObject:nil afterDelay:1.0];
    } else {
        [self.touchAbilityLongPressContentView stopTracking];
        [self.touchAbilityLongPressContentView setTargetViewHidden:YES animated:YES];
        [self performSelector:@selector(finish) withObject:nil afterDelay:1.0]; // [self finish];
    }
}

- (void)presentNextTrial {
    [self.touchAbilityLongPressContentView stopTracking];
    [self.touchAbilityLongPressContentView reloadData];
    [self.touchAbilityLongPressContentView setTargetViewHidden:NO animated:NO];
    [self.touchAbilityLongPressContentView startTracking];
}

@end