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

#import "ORKTouchAbilityScrollTrial.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTouchAbilityScrollTrial

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, direction);
    ORK_ENCODE_CGPOINT(aCoder, initialOffset);
    ORK_ENCODE_CGPOINT(aCoder, targetOffsetUpperBound);
    ORK_ENCODE_CGPOINT(aCoder, targetOffsetLowerBound);
    ORK_ENCODE_CGPOINT(aCoder, endDraggingOffset);
    ORK_ENCODE_CGPOINT(aCoder, endScrollingOffset);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        ORK_DECODE_ENUM(aDecoder, direction);
        ORK_DECODE_CGPOINT(aDecoder, initialOffset);
        ORK_DECODE_CGPOINT(aDecoder, targetOffsetUpperBound);
        ORK_DECODE_CGPOINT(aDecoder, targetOffsetLowerBound);
        ORK_DECODE_CGPOINT(aDecoder, endDraggingOffset);
        ORK_ENCODE_CGPOINT(aDecoder, endScrollingOffset);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityScrollTrial *trial = [super copyWithZone:zone];
    trial.direction = self.direction;
    trial.initialOffset = self.initialOffset;
    trial.targetOffsetUpperBound = self.targetOffsetUpperBound;
    trial.targetOffsetLowerBound = self.targetOffsetLowerBound;
    trial.endDraggingOffset = self.endDraggingOffset;
    trial.endScrollingOffset = self.endScrollingOffset;
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.direction == castObject.direction &&
            CGPointEqualToPoint(self.initialOffset, castObject.initialOffset) &&
            CGPointEqualToPoint(self.targetOffsetUpperBound, castObject.targetOffsetUpperBound) &&
            CGPointEqualToPoint(self.targetOffsetLowerBound, castObject.targetOffsetLowerBound) &&
            CGPointEqualToPoint(self.endDraggingOffset, castObject.endDraggingOffset) &&
            CGPointEqualToPoint(self.endScrollingOffset, castObject.endScrollingOffset));
}

- (NSString *)description {
    
    NSMutableString *sDescription = [[super description] mutableCopy];
    [sDescription deleteCharactersInRange:NSMakeRange(0, 1)];
    [sDescription deleteCharactersInRange:NSMakeRange(sDescription.length-1, 1)];
    
    NSString *directionString;
    if (self.direction == ORKTouchAbilityScrollTrialDirectionVertical) {
        directionString = @"vertical";
    } else {
        directionString = @"horizontal";
    }
    
    return [NSString stringWithFormat:@"<%@; direction: %@; initial offset: %@; target offset: [%@, %@]; end dragging offset: %@; end scrolling offset: %@;>",
            sDescription,
            directionString,
            [NSValue valueWithCGPoint:self.initialOffset],
            [NSValue valueWithCGPoint:self.targetOffsetUpperBound],
            [NSValue valueWithCGPoint:self.targetOffsetLowerBound],
            [NSValue valueWithCGPoint:self.endDraggingOffset],
            [NSValue valueWithCGPoint:self.endDraggingOffset]];
}

@end
