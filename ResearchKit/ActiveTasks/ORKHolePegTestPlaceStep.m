/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKHolePegTestPlaceStep.h"
#import "ORKHolePegTestPlaceStepViewController.h"
#import "ORKHelpers_Internal.h"


@implementation ORKHolePegTestPlaceStep

+ (Class)stepViewControllerClass {
    return [ORKHolePegTestPlaceStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldShowDefaultTimer = NO;
        self.shouldContinueOnFinish = YES;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    int const ORKHolePegTestMinimumNumberOfPegs = 1;
    
    double const ORKHolePegTestMinimumThreshold = 0.0f;
    double const ORKHolePegTestMaximumThreshold = 1.0f;
    
    NSTimeInterval const ORKHolePegTestMinimumDuration = 1.0f;
    
    if (self.movingDirection != ORKBodySagittalLeft &&
        self.movingDirection != ORKBodySagittalRight) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"moving direction should be left or right."] userInfo:nil];
    }
    
    if (self.numberOfPegs < ORKHolePegTestMinimumNumberOfPegs) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of pegs must be greater than or equal to %@.", @(ORKHolePegTestMinimumNumberOfPegs)] userInfo:nil];
    }
    
    if (self.threshold < ORKHolePegTestMinimumThreshold ||
        self.threshold > ORKHolePegTestMaximumThreshold) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"threshold must be greater than or equal to %@ and lower or equal to %@.", @(ORKHolePegTestMinimumThreshold), @(ORKHolePegTestMaximumThreshold)] userInfo:nil];
    }
    
    if (self.stepDuration < ORKHolePegTestMinimumDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"duration cannot be shorter than %@ seconds.", @(ORKHolePegTestMinimumDuration)] userInfo:nil];
    }
}

- (BOOL)allowsBackNavigation {
    return NO;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, movingDirection);
        ORK_DECODE_BOOL(aDecoder, dominantHandTested);
        ORK_DECODE_INTEGER(aDecoder, numberOfPegs);
        ORK_DECODE_DOUBLE(aDecoder, threshold);
        ORK_DECODE_BOOL(aDecoder, rotated);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, movingDirection);
    ORK_ENCODE_BOOL(aCoder, dominantHandTested);
    ORK_ENCODE_INTEGER(aCoder, numberOfPegs);
    ORK_ENCODE_DOUBLE(aCoder, threshold);
    ORK_ENCODE_BOOL(aCoder, rotated);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) step = [super copyWithZone:zone];
    step.movingDirection = self.movingDirection;
    step.dominantHandTested = self.dominantHandTested;
    step.numberOfPegs = self.numberOfPegs;
    step.threshold = self.threshold;
    step.rotated = self.rotated;
    return step;
}

- (NSUInteger)hash {
    return [super hash] ^ self.movingDirection ^ self.dominantHandTested ^ self.numberOfPegs ^ (NSInteger)(self.threshold * 100) ^ self.rotated;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.movingDirection == castObject.movingDirection) &&
            (self.dominantHandTested == castObject.dominantHandTested) &&
            (self.numberOfPegs == castObject.numberOfPegs) &&
            (self.threshold == castObject.threshold) &&
            (self.rotated == castObject.rotated));
}

@end
