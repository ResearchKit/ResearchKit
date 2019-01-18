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


#import "ORKSpatialSpanMemoryStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKSpatialSpanMemoryContentView.h"
#import "ORKVerticalContainerView_Internal.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKStepHeaderView_Internal.h"

#import "ORKActiveStep_Internal.h"
#import "ORKCollectionResult_Private.h"
#import "ORKSpatialSpanMemoryResult.h"
#import "ORKStep_Private.h"
#import "ORKSpatialSpanGame.h"
#import "ORKSpatialSpanGameState.h"
#import "ORKSpatialSpanMemoryStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import <QuartzCore/CABase.h>


static const NSTimeInterval MemoryGameActivityTimeout = 20;

typedef NS_ENUM(NSInteger, ORKSpatialSpanStepState) {
    ORKSpatialSpanStepStateInitial,
    ORKSpatialSpanStepStatePlayback,
    ORKSpatialSpanStepStateGameplay,
    ORKSpatialSpanStepStateTimeout,
    ORKSpatialSpanStepStateFailed,
    ORKSpatialSpanStepStateSuccess,
    ORKSpatialSpanStepStateRestart,
    ORKSpatialSpanStepStateComplete,
    ORKSpatialSpanStepStateStopped,
    ORKSpatialSpanStepStatePaused
};

@class ORKState;

typedef void (^_ORKStateHandler)(ORKState *fromState, ORKState *_toState, id context);

// Poor man's state machine:
// Define entry and exit handlers for each state.
// Transitions are a free for all!
@interface ORKState : NSObject

+ (ORKState *)stateWithState:(NSInteger)state entryHandler:(_ORKStateHandler)entryHandler exitHandler:(_ORKStateHandler)exitHandler context:(id)context;

@property (nonatomic, assign) NSInteger state;

@property (nonatomic, weak) id context;

@property (nonatomic, copy) _ORKStateHandler entryHandler;
- (void)setEntryHandler:(_ORKStateHandler)entryHandler;

@property (nonatomic, copy) _ORKStateHandler exitHandler;
- (void)setExitHandler:(_ORKStateHandler)exitHandler;

@end


@implementation ORKState

+ (ORKState *)stateWithState:(NSInteger)state entryHandler:(_ORKStateHandler)entryHandler exitHandler:(_ORKStateHandler)exitHandler context:(id)context {
    ORKState *s = [ORKState new];
    s.state = state;
    s.entryHandler = entryHandler;
    s.exitHandler = exitHandler;
    s.context = context;
    return s;
}

@end


@interface ORKSpatialSpanMemoryStepViewController () <ORKSpatialSpanMemoryGameViewDelegate>

@end


@implementation ORKSpatialSpanMemoryStepViewController {
    ORKSpatialSpanMemoryContentView *_contentView;
    ORKState *_state;
    NSDictionary *_states;
    ORKGridSize _gridSize;
    
    ORKSpatialSpanGameState *_currentGameState;
    UIBarButtonItem *_customLearnMoreButtonItem;
    UIBarButtonItem *_learnMoreButtonItem;
    
    // ORKSpatialSpanMemoryGameRecord
    NSMutableArray *_gameRecords;
    NSTimeInterval _gameStartTime;
    NSInteger _lastRoundScore;
    
    NSInteger _playbackIndex;
    
    NSInteger _score;
    NSInteger _numberOfItems;
    
    NSInteger _gamesCounter;
    NSInteger _consecutiveGamesFailed;
    NSInteger _nextGameSequenceLength;
    
    NSTimer *_playbackTimer;
    NSTimer *_activityTimer;
}

- (ORKSpatialSpanMemoryStep *)spatialSpanStep {
    return (ORKSpatialSpanMemoryStep *)self.step;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

#pragma mark Overrides

- (void)viewDidLoad {
    
    // Setup to always have a learn more button item but with an empty title
    BOOL usesDefaultCopyright = (self.learnMoreButtonItem == nil);
    if (usesDefaultCopyright) {
        self.learnMoreButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_COPYRIGHT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showCopyright)];
    }
    
    [super viewDidLoad];
    
    _contentView = [ORKSpatialSpanMemoryContentView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    _contentView.footerHidden = YES;
    _contentView.gameView.delegate = self;
    self.activeStepView.activeCustomView = _contentView;
    self.activeStepView.stepViewFillsAvailableSpace = NO;
    self.activeStepView.minimumStepHeaderHeight = ORKGetMetricForWindow(ORKScreenMetricMinimumStepHeaderHeightForMemoryGame, self.view.window);
    
    [self resetUI];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
    [self.activeStepView addGestureRecognizer:tapGestureRecognizer];
    
    if (usesDefaultCopyright) {
        self.activeStepView.headerView.learnMoreButton.alpha = 0;
    }
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [self initializeStates];
    
}

- (void)start {
    [super start];
    
    if (!_state) {
        [self transitionToState:ORKSpatialSpanStepStateInitial];
    }
    
    [self transitionToState:ORKSpatialSpanStepStatePlayback];
}

- (void)suspend {
    [super suspend];
    switch (_state.state) {
        case ORKSpatialSpanStepStatePlayback:
        case ORKSpatialSpanStepStateGameplay:
            [self transitionToState:ORKSpatialSpanStepStatePaused];
            break;
        default:
            break;
    }
}

- (void)resume {
    [super resume];
}

- (void)finish {
    [super finish];
    [self transitionToState:ORKSpatialSpanStepStateStopped];
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    
    ORKSpatialSpanMemoryResult *memoryResult = [[ORKSpatialSpanMemoryResult alloc] initWithIdentifier:self.step.identifier];
    memoryResult.startDate = stepResult.startDate;
    memoryResult.endDate = now;
    
    NSMutableArray *records = [NSMutableArray new];
    
    __block NSInteger numberOfFailures = 0;
    __block NSInteger score = 0;
    // Only include valid records
    [_gameRecords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ORKSpatialSpanMemoryGameRecord *record = (ORKSpatialSpanMemoryGameRecord *)obj;
        if (record.gameStatus != ORKSpatialSpanMemoryGameStatusUnknown) {
            [records addObject:record];
            
            score += record.score;
            
            if (record.gameStatus != ORKSpatialSpanMemoryGameStatusSuccess) {
                numberOfFailures++;
            }
        }
    }];
    
    memoryResult.score = score;
    memoryResult.numberOfFailures = numberOfFailures;
    memoryResult.numberOfGames = records.count;
    memoryResult.gameRecords = [records copy];
    
    [results addObject:memoryResult];
    stepResult.results = [results copy];
    
    return stepResult;
}

#pragma mark UpdateGameRecord

- (ORKSpatialSpanMemoryGameRecord *)currentGameRecord {
    return _gameRecords ? _gameRecords.lastObject : nil;
}

- (void)createGameRecord {
    if (_gameRecords == nil) {
        _gameRecords = [NSMutableArray new];
    }
    
    ORKSpatialSpanMemoryGameRecord *gameRecord = [ORKSpatialSpanMemoryGameRecord new];
    gameRecord.seed = _currentGameState.game.seed;
    gameRecord.gameSize = _currentGameState.game.gameSize;
    
    NSMutableArray *targetSequence = [NSMutableArray new];
    [_currentGameState.game enumerateSequenceWithHandler:^(NSInteger step, NSInteger tileIndex, BOOL isLastStep, BOOL *stop) {
        [targetSequence addObject:@(tileIndex)];
    }];
    gameRecord.sequence = [targetSequence copy];
    [_gameRecords addObject:gameRecord];
    
    _lastRoundScore = _score;
}

- (void)updateGameRecordTargetRects {
    ORKSpatialSpanMemoryGameRecord *record = [self currentGameRecord];
    NSArray *tileViews = _contentView.gameView.tileViews;
    NSMutableArray *targetRects = [NSMutableArray new];
    for (UIView *tileView in tileViews) {
        CGRect rect = [self.view convertRect:tileView.frame fromView:tileView.superview];
        [targetRects addObject:[NSValue valueWithCGRect:rect]];
    }
    record.targetRects = [targetRects copy];
    NSAssert(tileViews.count == 0 || tileViews.count == record.gameSize, nil);
}

- (void)updateGameRecordOnStartingGamePlay {
    _gameStartTime = CACurrentMediaTime();
}

- (void)handleUserTap:(UITapGestureRecognizer *)tapRecognizer {
    if (_state.state != ORKSpatialSpanStepStateGameplay) {
        return;
    }
    [self updateGameRecordOnTouch:-1 location:[tapRecognizer locationInView: self.view]];
}

- (void)updateGameRecordOnTouch:(NSInteger)targetIndex location:(CGPoint)location {
    ORKSpatialSpanMemoryGameTouchSample *sample = [ORKSpatialSpanMemoryGameTouchSample new];
    
    sample.timestamp = CACurrentMediaTime() - _gameStartTime;
    sample.location = location;
    sample.targetIndex = targetIndex;
    
    ORKSpatialSpanMemoryGameRecord *record = [self currentGameRecord];
    
    NSAssert(record, nil);
    
    NSInteger currentStep = 0;
    
    for (ORKSpatialSpanMemoryGameTouchSample *aSample in record.touchSamples) {
        if (aSample.isCorrect) {
            currentStep++;
        }
    }
    
    sample.correct = (targetIndex == [_currentGameState.game tileIndexForStep:currentStep]);
    
    NSMutableArray *sampleArray = [NSMutableArray arrayWithArray:record.touchSamples];
    
    [sampleArray addObject:sample];
    
    record.touchSamples = [sampleArray copy];
}

- (void)updateGameRecordOnSuccess {
    [self currentGameRecord].gameStatus = ORKSpatialSpanMemoryGameStatusSuccess;
}

- (void)updateGameRecordOnFailure {
    [self currentGameRecord].gameStatus = ORKSpatialSpanMemoryGameStatusFailure;
}

- (void)updateGameRecordOnTimeout {
    [self currentGameRecord].gameStatus = ORKSpatialSpanMemoryGameStatusTimeout;
}

- (void)updateGameRecordScore {
    [self currentGameRecord].score = _score - _lastRoundScore;
}

- (void)updateGameRecordOnPause {
    [self currentGameRecord].gameStatus = ORKSpatialSpanMemoryGameStatusUnknown;
}

#pragma mark ORKSpatialSpanStepStateInitial

- (ORKGridSize)gridSizeForSpan:(NSInteger)span {
    NSInteger numberOfGridEntriesDesired = span * 2;
    NSInteger value = (NSInteger)ceil(sqrt(numberOfGridEntriesDesired));
    value = MAX(value, 2);
    value = MIN(value, 6);
    return (ORKGridSize){value,value};
}

- (void)resetGameAndUI {
    _score = 0;
    _numberOfItems = 0;
    _gamesCounter = 0;
    _consecutiveGamesFailed = 0;
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    _nextGameSequenceLength = step.initialSpan;
    
    [self resetForNewGame];
}

- (void)resetUI {
    _contentView.numberOfItems = _score;
    _contentView.score = _numberOfItems;
    _contentView.footerHidden = YES;
    _contentView.buttonItem = nil;
    _contentView.gameView.gridSize = _gridSize;
    
    _contentView.gameView.customTargetImage = [[self spatialSpanStep] customTargetImage];
}

- (void)resetForNewGame {
    [self.activeStepView updateTitle:nil text:self.step.text];
    
    _numberOfItems = 0;
    
    NSInteger sequenceLength = _nextGameSequenceLength;
    _gridSize = [self gridSizeForSpan:sequenceLength];
    
    ORKSpatialSpanGame *game = [[ORKSpatialSpanGame alloc] initWithGameSize:_gridSize.width * _gridSize.height sequenceLength:sequenceLength seed:0];
    ORKSpatialSpanGameState *gameState = [[ORKSpatialSpanGameState alloc] initWithGame:game];
    
    _currentGameState = gameState;
    
    [self createGameRecord];
    
    [self resetUI];
}

#pragma mark ORKSpatialSpanStepStatePlayback

- (void)applyTargetState:(ORKSpatialSpanTargetState)targetState toSequenceIndex:(NSInteger)index duration:(NSTimeInterval)duration {
    ORKSpatialSpanGame *game = _currentGameState.game;
    if (index == NSNotFound || index < 0 || index >= game.sequenceLength ) {
        return;
    }
    
    NSInteger tileIndex = [game tileIndexForStep:index];
    ORKSpatialSpanMemoryGameView *gameView = _contentView.gameView;
    [gameView setState:targetState forTileIndex:tileIndex animated:YES];
    if (duration > 0 && targetState != ORKSpatialSpanTargetStateQuiescent) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self applyTargetState:ORKSpatialSpanTargetStateQuiescent toSequenceIndex:index duration:0];
        });
    }
}

- (void)playbackNextItem {
    const NSInteger sequenceLength = _currentGameState.game.sequenceLength;
    if (_playbackIndex >= sequenceLength) {
        [self transitionToState:ORKSpatialSpanStepStateGameplay];
    } else {
        ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
        
        NSInteger index = _playbackIndex;
        NSInteger previousIndex = index - 1;
        if (step.requireReversal) {
            // Play the indexes in reverse order when we require reversal. The participant
            // is then required to tap the sequence in the forward direction, which
            // appears as a reversal to them.
            index = sequenceLength - 1 - index;
            previousIndex = sequenceLength - 1 - previousIndex;
        }
        
        // Make sure the previous step *is *cleared
        [self applyTargetState:ORKSpatialSpanTargetStateQuiescent toSequenceIndex:previousIndex duration:0];
        
        // The active display should be visible for half the timer interval
        [self applyTargetState:ORKSpatialSpanTargetStateActive toSequenceIndex:index duration:(step.playSpeed / 2)];
    }
    _playbackIndex++;
}

- (void)startPlayback {
    _playbackIndex = 0;
    _contentView.footerHidden = YES;
    _contentView.buttonItem = nil;
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    NSString *title = [NSString localizedStringWithFormat:ORKLocalizedString(@"MEMORY_GAME_PLAYBACK_TITLE_%@", nil), step.customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_PLURAL", nil)];
    
    [self.activeStepView updateTitle:title text:nil];
    
    [_contentView.gameView resetTilesAnimated:NO];
    
    _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:step.playSpeed target:self selector:@selector(playbackNextItem) userInfo:nil repeats:YES];
}

- (void)finishPlayback {
    [_playbackTimer invalidate];
    _playbackTimer = nil;
}

#pragma mark ORKSpatialSpanStepStateGameplay

- (void)setNumberOfItems:(NSInteger)numberOfItems {
    _numberOfItems = numberOfItems;
    [_contentView setNumberOfItems:_numberOfItems];
}

- (void)setScore:(NSInteger)score {
    _score = score;
    [_contentView setScore:_score];
    [self updateGameRecordScore];
}

- (void)activityTimeout {
    [self transitionToState:ORKSpatialSpanStepStateTimeout];
}

- (void)resetActivityTimer {
    [_activityTimer invalidate];
    _activityTimer = nil;
    
    _activityTimer = [NSTimer scheduledTimerWithTimeInterval:MemoryGameActivityTimeout target:self selector:@selector(activityTimeout) userInfo:nil repeats:NO];
}

- (void)startGameplay {
    [self setNumberOfItems:0];
    
    // Update the target rects here, since layout will be complete by this point.
    [self updateGameRecordTargetRects];
    
    _contentView.footerHidden = NO;
    _contentView.buttonItem = nil;
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    NSString *pluralItemName = step.customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_PLURAL", nil);
    NSString *standaloneItemName = step.customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_STANDALONE", nil);
    _contentView.capitalizedPluralItemDescription = [standaloneItemName capitalizedStringWithLocale:[NSLocale currentLocale]];
    NSString *titleFormat = step.requireReversal ?  ORKLocalizedString(@"MEMORY_GAME_GAMEPLAY_REVERSE_TITLE_%@", nil) : ORKLocalizedString(@"MEMORY_GAME_GAMEPLAY_TITLE_%@", nil);
    NSString *title = [NSString stringWithFormat:titleFormat, pluralItemName];
    [self.activeStepView updateTitle:title text:nil];
    
    [self resetActivityTimer];
    
    // Ensure tiles are all reset at this point
    [_currentGameState reset];
    [_contentView.gameView resetTilesAnimated:NO];
    [_contentView setScore:_score];
    [_contentView setNumberOfItems:_numberOfItems];
    
    [self updateGameRecordOnStartingGamePlay];
}

- (void)finishGameplay {
    [_activityTimer invalidate];
    _activityTimer = nil;
}

- (void)gameView:(ORKSpatialSpanMemoryGameView *)gameView didTapTileWithIndex:(NSInteger)tileIndex recognizer:(UITapGestureRecognizer *)recognizer {
    if (_state.state != ORKSpatialSpanStepStateGameplay) {
        return;
    }
    
    [self updateGameRecordOnTouch:tileIndex location:[recognizer locationInView:self.view]];
    
    ORKSpatialSpanResult result = [_currentGameState playTileIndex:tileIndex];
    switch (result) {
        case ORKSpatialSpanResultIgnore:
            break;
            
        case ORKSpatialSpanResultCorrect:
            [gameView setState:ORKSpatialSpanTargetStateCorrect forTileIndex:tileIndex animated:YES];
            NSInteger stepIndex = [_currentGameState currentStepIndex];
            
            [self setNumberOfItems:_numberOfItems + 1];
            [self setScore:_score + (round(log2(stepIndex)) + 1) * 5];
            
            [self resetActivityTimer];
            if ([_currentGameState isComplete]) {
                [self transitionToState:ORKSpatialSpanStepStateSuccess];
            }
            break;
            
        case ORKSpatialSpanResultIncorrect:
            [gameView setState:ORKSpatialSpanTargetStateIncorrect forTileIndex:tileIndex animated:YES];
            [self transitionToState:ORKSpatialSpanStepStateFailed];
            break;
    }
}

#pragma mark ORKSpatialSpanStepStateSuccess

- (void)updateGameCountersForSuccess:(BOOL)success {
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    if (success) {
        NSInteger sequenceLength = [_currentGameState.game sequenceLength];
        [self setScore:_score + (round(log2(sequenceLength)) + 1) * 5];
        _gamesCounter++;
        _consecutiveGamesFailed = 0;
        _nextGameSequenceLength = MIN(_nextGameSequenceLength + 1, step.maximumSpan);
    } else {
        _gamesCounter++;
        _consecutiveGamesFailed++;
        _nextGameSequenceLength = MAX(_nextGameSequenceLength - 1, step.minimumSpan);
    }
}

- (void)continueAction {
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    if (_gamesCounter < step.maximumTests && _consecutiveGamesFailed < step.maximumConsecutiveFailures) {
        // Generate a new game
        [self transitionToState:ORKSpatialSpanStepStateRestart];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    } else {
        [self finish];
    }
}

- (void)showSuccess {
    [self updateGameRecordOnSuccess];
    
    [self updateGameCountersForSuccess:YES];
    if ([self finishIfCompletedGames]) {
        return;
    }
    
    [self.activeStepView updateTitle:ORKLocalizedString(@"MEMORY_GAME_COMPLETE_TITLE", nil) text:ORKLocalizedString(@"MEMORY_GAME_COMPLETE_MESSAGE", nil)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _contentView.buttonItem = [ORKBorderedButton new];
        [_contentView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
        [_contentView.buttonItem addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    });
}

#pragma mark ORKSpatialSpanStepStateFailed

- (void)tryAgainAction {
    // Restart with a new, shorter game
    [self transitionToState:ORKSpatialSpanStepStateRestart];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (BOOL)finishIfCompletedGames {
    ORKSpatialSpanMemoryStep *step = [self spatialSpanStep];
    if (_consecutiveGamesFailed >= step.maximumConsecutiveFailures || _gamesCounter >= step.maximumTests) {
        [self transitionToState:ORKSpatialSpanStepStateComplete];
        return YES;
    }
    return NO;
}

- (void)showFailed {
    [self updateGameRecordOnFailure];
    
    [self updateGameCountersForSuccess:NO];
    if ([self finishIfCompletedGames]) {
        return;
    }
    [self.activeStepView updateTitle:ORKLocalizedString(@"MEMORY_GAME_FAILED_TITLE", nil) text:ORKLocalizedString(@"MEMORY_GAME_FAILED_MESSAGE", nil)];
    
    _contentView.buttonItem = [ORKBorderedButton new];
    [_contentView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
    [_contentView.buttonItem addTarget:self action:@selector(tryAgainAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ORKSpatialSpanStepStateTimeout

- (void)showTimeout {
    [self updateGameRecordOnTimeout];
    
    [self updateGameCountersForSuccess:NO];
    if ([self finishIfCompletedGames]) {
        return;
    }
    
    [self.activeStepView updateTitle:ORKLocalizedString(@"MEMORY_GAME_TIMEOUT_TITLE", nil) text:ORKLocalizedString(@"MEMORY_GAME_TIMEOUT_MESSAGE", nil)];
    
    _contentView.buttonItem = [ORKBorderedButton new];
    [_contentView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
    [_contentView.buttonItem addTarget:self action:@selector(tryAgainAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ORKSpatialSpanStepStateComplete

- (void)showComplete {
    [self.activeStepView updateTitle:ORKLocalizedString(@"MEMORY_GAME_COMPLETE_TITLE", nil) text:nil];
    
    // Show the copyright
    self.activeStepView.headerView.learnMoreButton.alpha = 1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _contentView.buttonItem = [ORKBorderedButton new];
        [_contentView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
        [_contentView.buttonItem addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)showCopyright {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:ORKLocalizedString(@"MEMORY_GAME_COPYRIGHT_TEXT", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OK", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark ORKSpatialSpanStepStateRestart

- (void)doRestart {
    [self resetForNewGame];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Dispatch, so we don't do this in the middle of a state transition
        if (_state.state == ORKSpatialSpanStepStateRestart) {
            [self transitionToState:ORKSpatialSpanStepStatePlayback];
        }
    });
}

- (void)showPausedFromState:(ORKState *)fromState {
    [self updateGameRecordOnPause];
    
    // Do not update game counters - doesn't count as a game.
    
    [_activityTimer invalidate]; _activityTimer = nil;
    [_playbackTimer invalidate]; _playbackTimer = nil;
    
    [self resetForNewGame];
    [self.activeStepView updateTitle:ORKLocalizedString(@"MEMORY_GAME_PAUSED_TITLE", nil) text:ORKLocalizedString(@"MEMORY_GAME_PAUSED_MESSAGE", nil)];
    _contentView.buttonItem = [ORKBorderedButton new];
    [_contentView.buttonItem setTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) forState:UIControlStateNormal];
    [_contentView.buttonItem addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark State machine

- (void)initializeStates {
    NSMutableDictionary *states = [NSMutableDictionary dictionary];
    
    states[@(ORKSpatialSpanStepStateInitial)] = [ORKState stateWithState:ORKSpatialSpanStepStateInitial
                                                            entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                [this resetGameAndUI];
                                                            }
                                                             exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStatePlayback)] = [ORKState stateWithState:ORKSpatialSpanStepStatePlayback
                                                             entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                 [this startPlayback];
                                                             }
                                                              exitHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                  [this finishPlayback];
                                                              } context:self];
    
    states[@(ORKSpatialSpanStepStateGameplay)] = [ORKState stateWithState:ORKSpatialSpanStepStateGameplay
                                                             entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                 [this startGameplay];
                                                             }
                                                              exitHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                  [this finishGameplay];
                                                              } context:self];
    
    states[@(ORKSpatialSpanStepStateSuccess)] = [ORKState stateWithState:ORKSpatialSpanStepStateSuccess
                                                            entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                [this showSuccess];
                                                            }
                                                             exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStateFailed)] = [ORKState stateWithState:ORKSpatialSpanStepStateFailed
                                                           entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                               [this showFailed];
                                                           }
                                                            exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStateTimeout)] = [ORKState stateWithState:ORKSpatialSpanStepStateTimeout
                                                            entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                [this showTimeout];
                                                            }
                                                             exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStateRestart)] = [ORKState stateWithState:ORKSpatialSpanStepStateRestart
                                                            entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                [this doRestart];
                                                            }
                                                             exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStateComplete)] = [ORKState stateWithState:ORKSpatialSpanStepStateComplete
                                                             entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                                 [this showComplete];
                                                             } exitHandler:nil context:self];
    
    states[@(ORKSpatialSpanStepStateStopped)] = [ORKState stateWithState:ORKSpatialSpanStepStateStopped
                                                            entryHandler:nil
                                                             exitHandler:nil
                                                                 context:self];
    
    states[@(ORKSpatialSpanStepStatePaused)] = [ORKState stateWithState:ORKSpatialSpanStepStatePaused
                                                           entryHandler:^(ORKState *from, ORKState *to, ORKSpatialSpanMemoryStepViewController *this) {
                                                               [this showPausedFromState:from];
                                                           } exitHandler:nil context:self];
    
    _states = states;
    
    [self transitionToState:ORKSpatialSpanStepStateInitial];
}

- (void)transitionToState:(ORKSpatialSpanStepState)state {
    ORKState *stateObject = _states[@(state)];
    
    ORKState *oldState = _state;
    if (oldState.exitHandler != nil) {
        oldState.exitHandler(oldState, stateObject, oldState.context);
    }
    _state = stateObject;
    if (stateObject.entryHandler) {
        stateObject.entryHandler(oldState, stateObject, stateObject.context);
    }
}

@end
