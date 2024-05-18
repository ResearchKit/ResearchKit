/*
 Copyright (c) 2016, Motus Design Group Inc. All rights reserved.
 
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


#import "ORKTrailmakingResult.h"

#import "ORKResult_Private.h"
#import "ORKHelpers_Internal.h"


@implementation ORKTrailmakingResult

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _taps = @[];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, numberOfErrors);
    ORK_ENCODE_OBJ(aCoder, taps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, numberOfErrors);
        ORK_DECODE_OBJ_ARRAY(aDecoder, taps, ORKTrailmakingTap);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return super.hash ^ self.numberOfErrors ^ self.taps.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            self.numberOfErrors == castObject.numberOfErrors &&
            ORKEqualObjects(self.taps, castObject.taps));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTrailmakingResult *result = [super copyWithZone:zone];
    result.numberOfErrors = self.numberOfErrors;
    result.taps = ORKArrayCopyObjects(self.taps);
    return result;
}

@end


@implementation ORKTrailmakingTap

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_INTEGER(aCoder, index);
    ORK_ENCODE_BOOL(aCoder, incorrect);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_INTEGER(aDecoder, index);
        ORK_DECODE_BOOL(aDecoder, incorrect);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return [super hash] ^ (NSUInteger)self.timestamp*100 ^ self.index;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return self.timestamp == castObject.timestamp &&
    self.index == castObject.index &&
    self.incorrect == castObject.incorrect;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTrailmakingTap *tap = [[[self class] allocWithZone:zone] init];
    tap.timestamp = self.timestamp;
    tap.index = self.index;
    tap.incorrect = self.incorrect;
    return tap;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; timestamp: %@; index: %@; error: %@>", self.class.description, self, @(self.timestamp), @(self.index), @(self.incorrect)];
}

@end
