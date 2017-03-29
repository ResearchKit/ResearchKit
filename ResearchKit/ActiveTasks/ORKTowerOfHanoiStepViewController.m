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


#import "ORKTowerOfHanoiStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKTowerOfHanoiTowerView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKResult.h"
#import "ORKTowerOfHanoiStep.h"
#import "ORKTowerOfHanoiTower.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


static const NSUInteger NumberOfTowers = 3;

@interface ORKTowerOfHanoiViewController () <ORKTowerOfHanoiTowerViewDataSource, ORKTowerOfHanoiTowerViewDelegate>

@property (nonatomic, strong) NSDateComponentsFormatter *dateComponentsFormatter;
@property (nonatomic, strong) NSMutableArray *moves;

@end


@implementation ORKTowerOfHanoiViewController {
    ORKActiveStepCustomView *_towerOfHanoiCustomView;
    NSNumber *_selectedIndex;
    NSArray *_variableConstraints;
    NSMutableArray *_towers;
    NSArray *_towerViews;
    NSTimer *_timer;
    NSInteger _secondsElapsed;
    NSDate *_firstMoveDate;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _towerOfHanoiCustomView = [ORKActiveStepCustomView new];
    _towerOfHanoiCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _towerOfHanoiCustomView;
    self.activeStepView.minimumStepHeaderHeight = ORKGetMetricForWindow(ORKScreenMetricMinimumStepHeaderHeightForTowerOfHanoiPuzzle, self.view.window);
    
    [self setUpTowers];
    [self setUpTowerViews];
    [self reloadData];
    NSString *title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_INTRO_TEXT",nil);
    NSString *text = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_INTRO_TEXT",nil);
    NSString *skip = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_SKIP_BUTTON_TITLE", nil);
    [self.activeStepView updateTitle:title text:text];
    [self setSkipButtonTitle:skip];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    _variableConstraints = nil;
    
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }
    
    BOOL needCompactLayout =
    (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) &&
    (self.traitCollection.verticalSizeClass != UIUserInterfaceSizeClassCompact);
    _variableConstraints = needCompactLayout ? [self compactConstraints] : [self regularConstraints];
    [NSLayoutConstraint activateConstraints:_variableConstraints];
}

#pragma mark - ORKStepViewController

- (void)skipForward {
    [self finish];
}

#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKStepResult *stepResult = [super result];
    ORKTowerOfHanoiResult *result = [[ORKTowerOfHanoiResult alloc] initWithIdentifier:self.step.identifier];
    result.moves = self.moves;
    result.puzzleWasSolved = [self puzzleIsSolved];
    if (_firstMoveDate != nil) {
        result.startDate = _firstMoveDate;
    }
    stepResult.results = [self.addedResults arrayByAddingObject:result] ? : @[result];
    return stepResult;
}

#pragma mark - ORKTowerOfHanoiTowerViewDataSource
 
- (NSUInteger)numberOfDisksInTowerOfHanoiView:(ORKTowerOfHanoiTowerView *)towerView {
    NSInteger towerIndex = [_towerViews indexOfObject:towerView];
    ORKTowerOfHanoiTower *tower = _towers[towerIndex];
    return tower.disks.count;
}
 
- (NSNumber *)towerOfHanoiView:(ORKTowerOfHanoiTowerView *)towerView diskAtIndex:(NSUInteger)index {
    NSInteger towerIndex = [_towerViews indexOfObject:towerView];
    ORKTowerOfHanoiTower *tower = _towers[towerIndex];
    return (index >= tower.disks.count) ? nil :tower.disks[index];
}

#pragma mark - ORKTowerOfHanoiTowerViewDelegate

- (void)towerOfHanoiTowerViewWasSelected:(ORKTowerOfHanoiTowerView *)towerView {
    NSInteger newSelectedIndex = [_towerViews indexOfObject:towerView];
    if (_selectedIndex == nil) {
        _selectedIndex = @(newSelectedIndex);
    }
    else if ([_selectedIndex isEqual:@(newSelectedIndex)]) {
        _selectedIndex = nil;
    } else {
        [self transferDiskFromTowerAtIndex:_selectedIndex.integerValue toTowerAtIndex:newSelectedIndex];
    }
    [self reloadData];
    [self evaluatePuzzle];
}

- (ORKTowerOfHanoiTowerView *)towerOfHanoiHighlightedTowerView {
    return (_selectedIndex != nil ? _towerViews[_selectedIndex.integerValue] : nil);
}

#pragma mark - ORKTowerOfHanoiViewController

- (NSMutableArray *)moves {
    if (_moves == nil) {
        _moves = [NSMutableArray array];
    }
    return _moves;
}

- (NSDateComponentsFormatter *)dateComponentsFormatter {
    if (_dateComponentsFormatter == nil) {
        _dateComponentsFormatter = [NSDateComponentsFormatter new];
        _dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        _dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _dateComponentsFormatter.allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
    return _dateComponentsFormatter;
}

- (NSUInteger)numberOfDisks {
    return ((ORKTowerOfHanoiStep *)self.step).numberOfDisks;
}

- (void)updateTitleText {
    NSString *moves = ORKLocalizedStringFromNumber(@(self.moves.count));
    NSString *time = [self.dateComponentsFormatter stringFromTimeInterval:_secondsElapsed];
    NSString *title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_INTRO_TEXT",nil);
    NSString *text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TOWER_OF_HANOI_TASK_ACTIVE_STEP_PROGRESS_TEXT", nil), moves, time];
    [self.activeStepView updateTitle:title text:text];
}

- (void)reloadData {
    for (ORKTowerOfHanoiTowerView *towerView in _towerViews) {
        towerView.highlighted = _selectedIndex != nil && [_towerViews indexOfObject:towerView] == _selectedIndex.integerValue;
        [towerView reloadData];
    }
}

- (BOOL)puzzleIsSolved {
    return ((ORKTowerOfHanoiTower *)_towers.lastObject).disks.count == [self numberOfDisks];
}

- (void)evaluatePuzzle {
    if ([self puzzleIsSolved]) {
        [self finish];
    }
}

- (void)setUpTowers {
    NSMutableArray *diskStack = [NSMutableArray array];
    for (NSInteger disk = [self numberOfDisks] ; disk > 0 ; disk--) {
        [diskStack addObject: @(disk)];
    }
    _towers = [@[[[ORKTowerOfHanoiTower alloc] initWithDisks:diskStack], [ORKTowerOfHanoiTower emptyTower], [ORKTowerOfHanoiTower emptyTower]] mutableCopy];
}

- (void)setUpTowerViews {
    NSMutableArray *towerViews = [NSMutableArray array];
    for (NSInteger index = 0 ; index < 3 ; index++) {
        ORKTowerOfHanoiTowerView *towerView = [[ORKTowerOfHanoiTowerView alloc] initWithFrame:CGRectZero maximumNumberOfDisks:[self numberOfDisks]];
        towerView.delegate = self;
        towerView.dataSource = self;
        towerView.targeted = (index == NumberOfTowers - 1);
        [towerViews addObject:towerView];
        towerView.translatesAutoresizingMaskIntoConstraints = NO;
        [_towerOfHanoiCustomView addSubview:towerView];
    }
    _towerViews = towerViews;
}

- (void)transferDiskFromTowerAtIndex:(NSInteger)donorTowerIndex toTowerAtIndex:(NSInteger)recipientTowerIndex {
    ORKTowerOfHanoiTower *donorTower = _towers[donorTowerIndex];
    ORKTowerOfHanoiTower *recipientTower = _towers[recipientTowerIndex];
    if ([recipientTower recieveDiskFrom:donorTower]) {
        [self makeMoveFromTowerAtIndex:donorTowerIndex toTowerAtIndex:recipientTowerIndex];
    } else {
        NSNumber *donorSize = [self towerOfHanoiView:_towerViews[donorTowerIndex] diskAtIndex:0];
        NSNumber *recipientSize = [self towerOfHanoiView:_towerViews[recipientTowerIndex] diskAtIndex:0];
        
        if (donorSize && recipientSize) {
            // Only announce if the both donor and recipient are valid
            NSString *invalidMoveAnnouncement = [NSString stringWithFormat:ORKLocalizedString(@"AX_TOWER_OF_HANOI_INVALID_MOVE_FORMAT", nil), donorSize.stringValue, recipientSize.stringValue];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, invalidMoveAnnouncement);
            });
        }
    }
}

- (void)makeMoveFromTowerAtIndex:(NSUInteger)donorTowerIndex toTowerAtIndex:(NSUInteger)recipientTowerIndex {
    ORKTowerOfHanoiMove *move = [[ORKTowerOfHanoiMove alloc] init];
    move.donorTowerIndex = donorTowerIndex;
    move.recipientTowerIndex = recipientTowerIndex;
    move.timestamp = (self.moves.count == 0) ? 0 : fabs([_firstMoveDate timeIntervalSinceNow]);
    [_moves addObject:move];
    [self didMakeMove];
}

- (void)didMakeMove {
    _selectedIndex = nil;
    if (self.moves.count == 1) {
        _firstMoveDate = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
    }
    [self updateTitleText];
}

- (void)timerTicked {
    _secondsElapsed++;
    [self updateTitleText];
}

- (NSArray *)compactConstraints {
    CGFloat compactWidth = ([[UIScreen mainScreen]bounds].size.height - (3 * 8)) / 3;
    NSDictionary *views = @{ @"A": _towerViews[0], @"B": _towerViews[1], @"C": _towerViews[2]};
    NSMutableArray *newConstraints = [NSMutableArray new];

    [newConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[A]-[B]-[C]-|"]
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[0]
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_towerViews[1]
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[2]
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_towerViews[1]
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    for (int index = 0 ; index < _towerViews.count ; index++) {
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[index]
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:compactWidth]];
        [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[index]
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_towerOfHanoiCustomView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    }

    return newConstraints;
}

- (NSArray *)regularConstraints {
    NSDictionary *views = @{ @"A": _towerViews[0], @"B": _towerViews[1], @"C": _towerViews[2]};
    NSMutableArray *newConstraints = [NSMutableArray new];
    
    [newConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[A]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [newConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[B]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [newConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[C]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [newConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[A]-[B]-[C]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[0]
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_towerViews[1]
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0]];
    [newConstraints addObject:[NSLayoutConstraint constraintWithItem:_towerViews[2]
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:_towerViews[1]
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    return newConstraints;
}

@end
