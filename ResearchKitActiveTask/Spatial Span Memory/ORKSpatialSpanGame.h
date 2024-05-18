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


@import Foundation;


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKSpatialSpanGame` class represents a model object that represents one game-like experience in a spatial span memory task.
 
 A game consists of a subset of a permutation of the integers [0 .. gameSize - 1],
 which represent the sequence of targets that should be tapped.
 */
@interface ORKSpatialSpanGame : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized spatial span game using the specified game size, sequence length, and seed.
 
 This method is the designated initializer.
 @param gameSize         The number of tiles in the game.
 @param sequenceLength   The number of elements in the sequence that the user has to remember.
 @param seed             The generator that should be used for generating the sequence. A value of 0 means that a random seed is used.
 */
- (instancetype)initWithGameSize:(NSInteger)gameSize
                  sequenceLength:(NSInteger)sequenceLength
                            seed:(uint32_t)seed NS_DESIGNATED_INITIALIZER;

/// The number of tiles in the game.
@property (nonatomic, readonly) NSInteger gameSize;

/// The length of the sequence. A sequence is a sub-array of a random permutation of integers (0..gameSize-1) that  has a length of `sequenceLength`.
@property (nonatomic, readonly) NSInteger sequenceLength;

/// The seed to use to generate the sequence. Note that if you pass `seed` to another game, you get the same game.
@property (nonatomic, readonly) uint32_t seed;

/**
 Enumerates the sequence, calling the block once for each element.
 
 @param handler     The block to be called for each element in the sequence. The `handler` block takes the following parameters:
 
 `step`         The step in the sequence. The step starts at 0 and increments by one on each call.
 `tileIndex`    The index in [ 0 .. gameSize ] that corresponds to the step's element of the sequence.
 `isLastStep`   A Boolean value that indicates if this is the last step in the sequence.
 `stop`         A Boolean value that indicates if the enumeration should be terminated (pass `NO` to terminate the enumeration).
 */

- (void)enumerateSequenceWithHandler:(void(^)(NSInteger step, NSInteger tileIndex, BOOL isLastStep, BOOL *stop))handler;

/// Returns the value of the specified step in the sequence.
- (NSInteger)tileIndexForStep:(NSInteger)step;

@end

NS_ASSUME_NONNULL_END
