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


#import "ORKSpatialSpanGameState.h"
#import "ORKSpatialSpanGame.h"
#import "ORKHelpers.h"


@implementation ORKSpatialSpanGameState {
    NSMutableArray *_plays;
    ORKSpatialSpanTargetState *_states;
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithGame:(ORKSpatialSpanGame *)game {
    self = [super init];
    if (self) {
        _game = game;
        _plays = [NSMutableArray array];
        
        _states = calloc([_game gameSize], sizeof(ORKSpatialSpanTargetState));
        if (_states == NULL) {
            self = nil;
        }
    }
    return self;
}

- (void)dealloc {
    if (_states != NULL) {
        free(_states);
        _states = NULL;
    }
}

- (void)reset {
    const NSInteger gameSize = [_game gameSize];
    for (NSInteger tileIndex = 0; tileIndex < gameSize; tileIndex++) {
        _states[tileIndex] = ORKSpatialSpanTargetStateQuiescent;
    }
    [_plays removeAllObjects];
    _complete = NO;
}

/// Enumerate all tiles, indicating the state of each tile at this point in the game.
- (void)enumerateTilesWithHandler:(void (^)(NSInteger tileIndex, ORKSpatialSpanTargetState state, BOOL *stop))handler {
    const NSInteger gameSize = [_game gameSize];
    BOOL stop = NO;
    for (NSInteger tileIndex = 0; tileIndex < gameSize; tileIndex++) {
        handler(tileIndex, _states[tileIndex], &stop);
        if (stop) break;
    }
}

/// User tapped a tile. Returns YES if it was the correct next tile.
- (ORKSpatialSpanResult)playTileIndex:(NSInteger)tileIndex {
    if (_states[tileIndex] != ORKSpatialSpanTargetStateQuiescent) {
        return ORKSpatialSpanResultIgnore;
    }
    
    NSInteger sequencePosition = _plays.count;
    BOOL correct = ([_game tileIndexForStep:sequencePosition] == tileIndex);
    _states[tileIndex] = correct ? ORKSpatialSpanTargetStateCorrect : ORKSpatialSpanTargetStateIncorrect;
    if (correct) {
        [_plays addObject:@(tileIndex)];
    }
    if (_plays.count >= [_game sequenceLength]) {
        _complete = YES;
    }
    
    return correct ? ORKSpatialSpanResultCorrect : ORKSpatialSpanResultIncorrect;
}

- (NSInteger)currentStepIndex {
    return _plays.count;
}

- (NSInteger)lastSuccessfulTileIndex {
    if (!_plays.count) {
        return NSNotFound;
    }
    return ((NSNumber *)_plays.lastObject).integerValue;
}

@end
