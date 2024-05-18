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

#import "ORKTouchAbilityPinchTrial.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTouchAbilityPinchTrial

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, targetScale);
    ORK_ENCODE_DOUBLE(aCoder, resultScale);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        ORK_DECODE_DOUBLE(aDecoder, targetScale);
        ORK_DECODE_DOUBLE(aDecoder, resultScale);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityPinchTrial *trial = [super copyWithZone:zone];
    trial.targetScale = self.targetScale;
    trial.resultScale = self.resultScale;
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    
    return (isParentSame &&
            self.targetScale == castObject.targetScale &&
            self.resultScale == castObject.resultScale);
}

- (instancetype)init {
    if (self = [super init]) {
        self.targetScale = 1.0;
        self.resultScale = 1.0;
    }
    return self;
}

- (instancetype)initWithTargetScale:(CGFloat)targetScale {
    if (self = [super init]) {
        self.targetScale = targetScale;
        self.resultScale = 1.0;
    }
    return self;
}

- (NSString *)description {
    
    NSMutableString *sDescription = [[super description] mutableCopy];
    [sDescription deleteCharactersInRange:NSMakeRange(0, 1)];
    [sDescription deleteCharactersInRange:NSMakeRange(sDescription.length-1, 1)];
    
    return [NSString stringWithFormat:@"<%@; target scale: %@; result scale: %@>", sDescription, @(self.targetScale), @(self.resultScale)];
}

@end
