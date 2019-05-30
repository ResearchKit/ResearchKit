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

#import "ORKTouchAbilitySwipeTrial.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTouchAbilitySwipeTrial

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, targetDirection);
    ORK_ENCODE_ENUM(aCoder, resultDirection);
    ORK_ENCODE_BOOL(aCoder, success);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        ORK_DECODE_ENUM(aDecoder, targetDirection);
        ORK_DECODE_ENUM(aDecoder, resultDirection);
        ORK_DECODE_BOOL(aDecoder, success);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilitySwipeTrial *trial = [super copyWithZone:zone];
    trial.targetDirection = self.targetDirection;
    trial.resultDirection = self.resultDirection;
    trial.success = self.success;
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.targetDirection == castObject.targetDirection &&
            self.resultDirection == castObject.resultDirection &&
            self.success == castObject.success);
}

- (instancetype)initWithTargetDirection:(UISwipeGestureRecognizerDirection)direction {
    if (self = [super init]) {
        self.targetDirection = direction;
        self.resultDirection = direction;
        self.success = NO;
    }
    return self;
}

- (NSString *)description {
    
    NSMutableString *sDescription = [[super description] mutableCopy];
    [sDescription deleteCharactersInRange:NSMakeRange(0, 1)];
    [sDescription deleteCharactersInRange:NSMakeRange(sDescription.length-1, 1)];
    
    return [NSString stringWithFormat:@"<%@; target direction: %@; result direction: %@; success: %@>", sDescription, [self directionStringFor:self.targetDirection], [self directionStringFor:self.resultDirection], self.success ? @"true" : @"false"];
}

- (NSString *)directionStringFor:(UISwipeGestureRecognizerDirection)direction {
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp:
            return @"up";
        case UISwipeGestureRecognizerDirectionDown:
            return @"down";
        case UISwipeGestureRecognizerDirectionLeft:
            return @"left";
        case UISwipeGestureRecognizerDirectionRight:
            return @"right";
    }
}

@end
