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


#import "ORKSpatialSpanMemoryStep.h"
#import "ORKSpatialSpanMemoryStepViewController.h"
#import "ORKHelpers.h"
#import "ORKStep_Private.h"


@implementation ORKSpatialSpanMemoryStep

+ (Class)stepViewControllerClass {
    return [ORKSpatialSpanMemoryStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldStartTimerAutomatically = YES;
        self.shouldContinueOnFinish = YES;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryStep *step = [super copyWithZone:zone];
    step.initialSpan = self.initialSpan;
    step.minimumSpan = self.minimumSpan;
    step.maximumSpan = self.maximumSpan;
    step.playSpeed = self.playSpeed;
    step.maximumTests = self.maximumTests;
    step.maximumConsecutiveFailures = self.maximumConsecutiveFailures;
    step.requireReversal = self.requireReversal;
    step.customTargetImage = self.customTargetImage;
    step.customTargetPluralName = self.customTargetPluralName;
    return step;
}

- (void)validateParameters {
    [super validateParameters];
    
    NSInteger const ORKSpatialSpanMemoryTaskMinimumInitialSpan = 2;
    NSInteger const ORKSpatialSpanMemoryTaskMaximumSpan = 20;
    NSTimeInterval const ORKSpatialSpanMemoryTaskMinimumPlaySpeed = 0.5;
    NSTimeInterval const ORKSpatialSpanMemoryTaskMaximumPlaySpeed = 20;
    NSInteger const ORKSpatialSpanMemoryTaskMinimumMaxTests = 1;
    NSInteger const ORKSpatialSpanMemoryTaskMinimumMaxConsecutiveFailures = 1;
    
    if ( self.initialSpan < ORKSpatialSpanMemoryTaskMinimumInitialSpan) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"initialSpan cannot be less than %@.", @(ORKSpatialSpanMemoryTaskMinimumInitialSpan)]
                                     userInfo:nil];
    }
    
    if ( self.minimumSpan > self.initialSpan) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"initialSpan cannot be less than minimumSpan." userInfo:nil];
    }
    
    if ( self.initialSpan > self.maximumSpan) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"maximumSpan cannot be less than initialSpan." userInfo:nil];
    }
    
    if ( self.maximumSpan > ORKSpatialSpanMemoryTaskMaximumSpan) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maximumSpan cannot be more than %@.", @(ORKSpatialSpanMemoryTaskMaximumSpan)]
                                     userInfo:nil];
    }
    
    if  (self.playSpeed < ORKSpatialSpanMemoryTaskMinimumPlaySpeed) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"playSpeed cannot be shorter than %@ seconds.", @(ORKSpatialSpanMemoryTaskMinimumPlaySpeed)]
                                     userInfo:nil];
    }
    
    if  (self.playSpeed > ORKSpatialSpanMemoryTaskMaximumPlaySpeed) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"playSpeed cannot be longer than %@ seconds.", @(ORKSpatialSpanMemoryTaskMaximumPlaySpeed)]
                                     userInfo:nil];
    }
    
    if  (self.maximumTests < ORKSpatialSpanMemoryTaskMinimumMaxTests) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maximumTests cannot be less than %@.", @(ORKSpatialSpanMemoryTaskMinimumMaxTests)]
                                     userInfo:nil];
    }
    
    if  (self.maximumConsecutiveFailures < ORKSpatialSpanMemoryTaskMinimumMaxConsecutiveFailures) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maximumConsecutiveFailures cannot be less than %@.", @(ORKSpatialSpanMemoryTaskMinimumMaxConsecutiveFailures)]
                                     userInfo:nil];
    }
}

- (BOOL)startsFinished {
    return NO;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, initialSpan);
        ORK_DECODE_INTEGER(aDecoder, minimumSpan);
        ORK_DECODE_INTEGER(aDecoder, maximumSpan);
        ORK_DECODE_INTEGER(aDecoder, playSpeed);
        ORK_DECODE_INTEGER(aDecoder, maximumTests);
        ORK_DECODE_INTEGER(aDecoder, maximumConsecutiveFailures);
        ORK_DECODE_BOOL(aDecoder, requireReversal);
        ORK_DECODE_IMAGE(aDecoder, customTargetImage);
        ORK_DECODE_OBJ_CLASS(aDecoder, customTargetPluralName, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, initialSpan);
    ORK_ENCODE_INTEGER(aCoder, minimumSpan);
    ORK_ENCODE_INTEGER(aCoder, maximumSpan);
    ORK_ENCODE_INTEGER(aCoder, playSpeed);
    ORK_ENCODE_INTEGER(aCoder, maximumTests);
    ORK_ENCODE_INTEGER(aCoder, maximumConsecutiveFailures);
    ORK_ENCODE_BOOL(aCoder, requireReversal);
    ORK_ENCODE_IMAGE(aCoder, customTargetImage);
    ORK_ENCODE_OBJ(aCoder, customTargetPluralName);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.initialSpan == castObject.initialSpan) &&
            (self.minimumSpan == castObject.minimumSpan) &&
            (self.maximumSpan == castObject.maximumSpan) &&
            (self.playSpeed == castObject.playSpeed) &&
            (self.maximumTests == castObject.maximumTests) &&
            (self.maximumConsecutiveFailures == castObject.maximumConsecutiveFailures) &&
            (ORKEqualObjects(self.customTargetPluralName, castObject.customTargetPluralName)) &&
            (self.requireReversal == castObject.requireReversal));
}

- (BOOL)allowsBackNavigation {
    return NO;
}

@end
