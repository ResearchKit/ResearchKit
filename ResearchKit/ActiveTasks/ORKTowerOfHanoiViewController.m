/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKTowerOfHanoiViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKTowerOfHanoiTowerView.h"
#import "ORKActiveStepView.h"
#import "ORKTowerOfHanoiTower.h"
#import "ORKTowerOfHanoiStep.h"

@interface ORKTowerOfHanoiViewController () <ORKTowerOfHanoiTowerViewDataSource, ORKTowerOfHanoiTowerViewDelegate>

@end

@implementation ORKTowerOfHanoiViewController {
    ORKActiveStepCustomView *_towerOfHanoiCustomView;
    NSNumber *_selectedIndex;
    NSArray *_currentConstraints;
    NSMutableArray *_towers;
    NSArray *_towerViews;
    NSInteger _numberOfDisks;
    NSInteger _numberOfMoves;
    NSTimer *_timer;
    NSInteger _secondsElapsed;
    NSDate *_firstMoveDate;
}

#pragma Mark -- UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _towerOfHanoiCustomView = [ORKActiveStepCustomView new];
    [_towerOfHanoiCustomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.activeStepView.activeCustomView = _towerOfHanoiCustomView;
    _numberOfDisks = ((ORKTowerOfHanoiStep *)self.step).numberOfDisks;
    
    [self setupTowers];
    [self setupTowerViews];
    [self reloadData];
    [self.activeStepView updateTitle:nil text: ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_INTRO_TEXT", nil)];
    [self setSkipButtonTitle:ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_SKIP_BUTTON_TITLE", nil)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    if (_currentConstraints) {
        [NSLayoutConstraint deactivateConstraints:_currentConstraints];
        _currentConstraints = nil;
    }
    BOOL needCompactLayout = self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact &&
    self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact;
    _currentConstraints = needCompactLayout ? [self compactConstraints] : [self regularConstraints];
    [NSLayoutConstraint activateConstraints:_currentConstraints];
}

#pragma Mark -- ORKStepViewController

- (void)skipForward {
    [self finish];
}

#pragma Mark -- ORKActiveTaskViewController

- (ORKResult *)result {
    ORKTowerOfHanoiResult *result = [[ORKTowerOfHanoiResult alloc] initWithIdentifier:self.step.identifier];
    result.numberOfMoves = _numberOfMoves;
    result.puzzleWasSolved = [self puzzleIsSolved];
    if (_firstMoveDate != nil) {
        result.startDate = _firstMoveDate;
    }
    return result;
}

#pragma Mark -- ORKTowerOfHanoiTowerViewDataSource
 
- (NSInteger)numberOfDisksInTowerOfHanoiView:(ORKTowerOfHanoiTowerView *)towerView {
     NSInteger towerIndex = [_towerViews indexOfObject:towerView];
     ORKTowerOfHanoiTower *tower = _towers[towerIndex];
     return tower.disks.count;
}
 
- (NSInteger)towerOfHanoiView:(ORKTowerOfHanoiTowerView *)towerView sizeForDiskAtIndex:(NSInteger)index {
     NSInteger towerIndex = [_towerViews indexOfObject:towerView];
     ORKTowerOfHanoiTower *tower = _towers[towerIndex];
     return [tower.disks[index]integerValue];
}

#pragma Mark -- ORKTowerOfHanoiTowerViewDelegate

- (void)towerOfHanoiTowerViewWasSelected:(ORKTowerOfHanoiTowerView *)towerView {
    NSInteger newSelectedIndex = [_towerViews indexOfObject:towerView];
    if (_selectedIndex == nil) {
        _selectedIndex = @(newSelectedIndex);
    }
    else if ([_selectedIndex isEqual: @(newSelectedIndex)]) {
        _selectedIndex = nil;
    }
    else {
        [self transferDiskFromTowerAtIndex:_selectedIndex.integerValue toTowerAtIndex:newSelectedIndex];
    }
    [self reloadData];
    [self evaluatePuzzle];
}

#pragma Mark -- ORKTowerOfHanoiViewController

- (void)updateTitleText {
    NSString *text = [NSString stringWithFormat: ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_PROGRESS_TEXT", nil), (int)_numberOfMoves, [self timeElapsedString]];
    [self.activeStepView updateTitle:nil text: text];
}

- (NSString *)timeElapsedString {
    NSString *seconds = [NSString stringWithFormat:@"%02d", (int)_secondsElapsed % 60];
    NSString *minutes = [NSString stringWithFormat:@"%02d", (int)(_secondsElapsed / 60) % 60];
    NSString *hours = [NSString stringWithFormat:@"%02d",(int)_secondsElapsed / 3600];
    NSString *time = [NSString stringWithFormat:@"%@:%@", minutes,seconds];
    if (![hours isEqualToString: @"00"]) {
        time = [NSString stringWithFormat:@"%@:%@",hours,time];
    }
    return time;
}

- (void)reloadData {
    for (ORKTowerOfHanoiTowerView *towerView in _towerViews) {
        towerView.highlighted = _selectedIndex != nil && [_towerViews indexOfObject:towerView] == _selectedIndex.integerValue;
        [towerView reloadData];
    }
}

- (BOOL)puzzleIsSolved {
    return ((ORKTowerOfHanoiTower *)_towers.lastObject).disks.count == _numberOfDisks;
}

- (void)evaluatePuzzle {
    if ([self puzzleIsSolved]) {
        [self finish];
    }
}

- (void)setupTowers {
    NSMutableArray *diskStack = [NSMutableArray array];
    for (NSInteger disk = _numberOfDisks ; disk > 0 ; disk--) {
        [diskStack addObject: @(disk)];
    }
    _towers = [@[[[ORKTowerOfHanoiTower alloc]initWithDisks:diskStack], [ORKTowerOfHanoiTower empty], [ORKTowerOfHanoiTower empty]] mutableCopy];
}

- (void)setupTowerViews {
    NSMutableArray *towerViews = [NSMutableArray array];
    for (NSInteger idx = 0 ; idx < 3 ; idx++) {
        ORKTowerOfHanoiTowerView *towerView = [[ORKTowerOfHanoiTowerView alloc] initWithFrame:CGRectZero maximumNumberOfDisks:_numberOfDisks];
        towerView.delegate = self;
        towerView.dataSource = self;
        towerView.targetTower = idx == 2;
        [towerViews addObject:towerView];
        [towerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_towerOfHanoiCustomView addSubview:towerView];
    }
    _towerViews = towerViews;
}

- (void)transferDiskFromTowerAtIndex:(NSInteger)donorTowerIndex toTowerAtIndex:(NSInteger)recipientTowerIndex {
    ORKTowerOfHanoiTower *donorTower = _towers[donorTowerIndex];
    ORKTowerOfHanoiTower *recipientTower = _towers[recipientTowerIndex];
    if (donorTower.disks.count > 0 && [recipientTower canRecieveDisk:(NSNumber *)donorTower.disks.lastObject]) {
        NSMutableArray *recipientDisks = [recipientTower.disks mutableCopy];
        NSMutableArray *donorDisks = [donorTower.disks mutableCopy];
        [recipientDisks addObject:donorDisks.lastObject];
        [donorDisks removeLastObject];
        _towers[recipientTowerIndex] = [[ORKTowerOfHanoiTower alloc]initWithDisks:recipientDisks];
        _towers[donorTowerIndex] = [[ORKTowerOfHanoiTower alloc]initWithDisks:donorDisks];
        [self didTransferDisk];
    }
}

- (void)didTransferDisk {
    _selectedIndex = nil;
    if (_numberOfMoves == 0) {
        _firstMoveDate = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
    }
    _numberOfMoves++;
    [self updateTitleText];
}

- (void)timerTicked {
    _secondsElapsed++;
    [self updateTitleText];
}

- (NSArray *)compactConstraints {
    CGFloat compactWidth = ([[UIScreen mainScreen]bounds].size.height - (3 * 8)) / 3;
    NSDictionary *views = @{ @"A" : _towerViews[0], @"B" : _towerViews[1], @"C" : _towerViews[2]};
    NSMutableArray *newConstraints = [NSMutableArray new];

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[A]-[B]-[C]-|"] options:0 metrics:nil views:views]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[0] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_towerViews[1] attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[2] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_towerViews[1] attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    for (int index = 0 ; index < _towerViews.count ; index++) {
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[index] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:compactWidth]];
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[index] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_towerOfHanoiCustomView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }

    return newConstraints;
}

- (NSArray *)regularConstraints {
    NSDictionary *views = @{ @"A" : _towerViews[0], @"B" : _towerViews[1], @"C" : _towerViews[2]};
    NSMutableArray *newConstraints = [NSMutableArray new];
    
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[A]-|" options:0 metrics:nil views:views]];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[B]-|" options:0 metrics:nil views:views]];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[C]-|" options:0 metrics:nil views:views]];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[A]-[B]-[C]-|" options:0 metrics:nil views:views]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[0] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_towerViews[1] attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[2] attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_towerViews[1] attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    return newConstraints;
}

@end
