/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKHealthCondition.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKCollectionResult.h"
#import "ORKHelpers_Internal.h"


@implementation ORKHealthCondition

- (instancetype)initWithIdentifier:(NSString *)identifier
                       displayName:(NSString *)name
                             value:(NSObject<NSCopying,NSSecureCoding> *)value {
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _displayName = [name copy];
        _value = [value copy];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, displayName);
    ORK_ENCODE_OBJ(aCoder, value);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, displayName, NSString);
        ORK_DECODE_OBJ_CLASSES(aDecoder, value, ORKAllowableValueClasses());
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ORKHealthCondition *healthCondition = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]
                                                                                    displayName:[_displayName copy]
                                                                                          value:[_value copy]];
    return healthCondition;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.displayName, castObject.displayName)
            && ORKEqualObjects(self.value, castObject.value));
}

- (NSUInteger)hash {
    return super.hash ^ self.identifier.hash ^ self.displayName.hash ^ self.value.hash;
}

@end
