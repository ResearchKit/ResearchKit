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


#import "ORKTowerOfHanoiResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKTowerOfHanoiResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, moves);
    ORK_ENCODE_BOOL(aCoder, puzzleWasSolved);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, moves, ORKTowerOfHanoiMove);
        ORK_DECODE_BOOL(aDecoder, puzzleWasSolved);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return isParentSame &&
    self.puzzleWasSolved == castObject.puzzleWasSolved &&
    ORKEqualObjects(self.moves, castObject.moves);
}

- (NSUInteger)hash {
    return super.hash ^ self.puzzleWasSolved ^ self.moves.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTowerOfHanoiResult *result = [super copyWithZone:zone];
    result.puzzleWasSolved = self.puzzleWasSolved;
    result.moves = [self.moves copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; puzzleSolved: %d; moves: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.puzzleWasSolved, self.moves, self.descriptionSuffix];
}

@end


@implementation ORKTowerOfHanoiMove

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_INTEGER(aCoder, donorTowerIndex);
    ORK_ENCODE_INTEGER(aCoder, recipientTowerIndex);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_INTEGER(aDecoder, donorTowerIndex);
        ORK_DECODE_INTEGER(aDecoder, recipientTowerIndex);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return self.timestamp == castObject.timestamp &&
    self.donorTowerIndex == castObject.donorTowerIndex &&
    self.recipientTowerIndex == castObject.recipientTowerIndex;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTowerOfHanoiMove *move = [[[self class] allocWithZone:zone] init];
    move.timestamp = self.timestamp;
    move.donorTowerIndex = self.donorTowerIndex;
    move.recipientTowerIndex = self.recipientTowerIndex;
    return move;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; timestamp: %@; donorTower: %@; recipientTower: %@>", self.class.description, self, @(self.timestamp), @(self.donorTowerIndex), @(self.recipientTowerIndex)];
}

@end
