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


#import "ORKSpatialSpanGame.h"
#import "ORKHelpers.h"

@implementation ORKSpatialSpanGame {
    NSInteger *_sequence;
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (void)generateSequence {
    _sequence = calloc(_gameSize, sizeof(NSInteger));
    if (_sequence == NULL) {
        return;
    }
    for (NSInteger i = 0; i < _gameSize; i++) {
        _sequence[i] = i;
    }
    
    // Knuth algorithm: swap each with a random element elsewhere in the array.
    // Note: we will only use the first _sequenceLength elements of this array
    srandom(_seed);
    for (NSInteger i = 0; i < _gameSize; i++) {
        NSInteger rand_i = random() % _gameSize;
        NSInteger tmp = _sequence[i];
        _sequence[i] = _sequence[rand_i];
        _sequence[rand_i] = tmp;
    }
}

- (void)dealloc {
    if (_sequence != NULL) {
        free(_sequence);
        _sequence = NULL;
    }
}

- (instancetype)initWithGameSize:(NSInteger)gameSize
                  sequenceLength:(NSInteger)sequenceLength
                            seed:(uint32_t)seed {
    self = [super init];
    if (self) {
        _gameSize = gameSize;
        _sequenceLength = sequenceLength;
        NSParameterAssert(_gameSize > 0);
        NSParameterAssert(_sequenceLength > 0);
        NSParameterAssert(_sequenceLength < _gameSize);
        _seed = seed;
        if (_seed == 0) {
            _seed = arc4random();
        }
        [self generateSequence];
        
        if (_sequence == NULL) {
            self = nil;
        }
    }
    return self;
}

/// Step parameter is the step in the sequence; tileIndex is the value of that step of the sequence.
- (void)enumerateSequenceWithHandler:(void(^)(NSInteger step, NSInteger tileIndex, BOOL isLastStep, BOOL *stop))handler {
    BOOL stop = NO;
    for (NSInteger i = 0; i < _sequenceLength; i++) {
        handler(i, _sequence[i], (i == _sequenceLength), &stop);
        if (stop) break;
    }
}

- (NSInteger)tileIndexForStep:(NSInteger)step {
    return _sequence[step];
}

@end
