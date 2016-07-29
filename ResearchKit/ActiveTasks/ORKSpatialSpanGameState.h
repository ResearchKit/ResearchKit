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


#import <Foundation/Foundation.h>
#import "ORKSpatialSpanTargetView.h"


NS_ASSUME_NONNULL_BEGIN

@class ORKSpatialSpanGame;

typedef NS_ENUM(NSInteger, ORKSpatialSpanResult) {
    ORKSpatialSpanResultIgnore,
    ORKSpatialSpanResultCorrect,
    ORKSpatialSpanResultIncorrect
};

@interface ORKSpatialSpanGameState : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithGame:(ORKSpatialSpanGame *)game NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly, nullable) ORKSpatialSpanGame *game;

@property (nonatomic, readonly, getter=isComplete) BOOL complete;

/// Enumerates all tiles, indicating the state of each tile at the specified state of the game.
- (void)enumerateTilesWithHandler:(void (^)(NSInteger tileIndex, ORKSpatialSpanTargetState state, BOOL *stop))handler;

/// Returns a result indicating whether the user's tap was correct, incorrect, or ignorable.
- (ORKSpatialSpanResult)playTileIndex:(NSInteger)tileIndex;

- (void)reset;

// Returns `NSNotFound` if there have been no plays
- (NSInteger)lastSuccessfulTileIndex;

// Number of tiles that have been successfully tapped
- (NSInteger)currentStepIndex;

@end

NS_ASSUME_NONNULL_END
