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

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilityTapStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"

@interface ORKTouchAbilityTapStepViewController () <ORKTouchAbilityTapContentViewDataSource, ORKTouchAbilityCustomViewDelegate>

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKTouchAbilityTapContentView *touchAbilityTapContentView;
@property (nonatomic, assign) NSUInteger successes;
@property (nonatomic, assign) NSUInteger failures;


@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger targetColumn;
@property (nonatomic, assign) NSUInteger targetRow;
@property (nonatomic, assign) CGSize targetSize;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, copy) NSArray *targetConstraints;

@end

@implementation ORKTouchAbilityTapStepViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberOfColumns = 5;
    self.numberOfRows = 5;
    self.targetColumn = 1;
    self.targetRow = 0;
    self.targetSize = CGSizeMake(76, 76);
    
    self.touchAbilityTapContentView = [[ORKTouchAbilityTapContentView alloc] init];
    self.touchAbilityTapContentView.dataSource = self;
    self.touchAbilityTapContentView.delegate = self;
//    self.touchAbilityTapContentView.backgroundColor = [UIColor redColor];
    self.activeStepView.activeCustomView = self.touchAbilityTapContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.activeStepView.scrollContainerShouldCollapseNavbar = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.touchAbilityTapContentView startTracking];
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [super result];
    
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:sResult.results];
    
    ORKTouchAbilityTapResult *tapResult = [[ORKTouchAbilityTapResult alloc] initWithIdentifier:self.step.identifier];
    
    tapResult.trials = [NSMutableArray new];
    
    [results addObject:tapResult];
    sResult.results = [results copy];
    
    return sResult;
}

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _targetView;
}


#pragma mark - ORKTouchAbilityTapContentViewDataSource

- (NSUInteger)numberOfColumns:(ORKTouchAbilityTapContentView *)tapContentView {
    return 5;
}

- (NSUInteger)numberOfRows:(ORKTouchAbilityTapContentView *)tapContentView {
    return 5;
}

- (NSUInteger)targetColumn:(ORKTouchAbilityTapContentView *)tapContentView {
    return 0; //arc4random_uniform(5);
}

- (NSUInteger)targetRow:(ORKTouchAbilityTapContentView *)tapContentView {
    return 0; //arc4random_uniform(5);
}


#pragma mark - ORKTouchAbilityCustomViewDelegate

- (void)touchAbilityCustomViewDidCompleteNewTracks:(ORKTouchAbilityCustomView *)customView {
    [self.touchAbilityTapContentView reloadData];
    [self.touchAbilityTapContentView startTracking];
}

@end
