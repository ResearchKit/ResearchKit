/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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


#import "ORKLearnMoreItem.h"
#import "ORKLearnMoreInstructionStep.h"
#import "ORKHelpers_Internal.h"


@implementation ORKLearnMoreItem

- (instancetype)initWithText:(nullable NSString *)text learnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    self = [super init];
    if (self) {
        self.text = text;
        self.learnMoreInstructionStep = learnMoreInstructionStep;
    }
    return self;
}

+ (instancetype)learnMoreItemWithText:(NSString *)text learnMoreInstructionStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep {
    return [[ORKLearnMoreItem alloc] initWithText:text learnMoreInstructionStep:learnMoreInstructionStep];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    ORKLearnMoreItem *learnMoreItem = [[[self class] allocWithZone:zone] init];
    learnMoreItem->_text = [self.text copy];
    learnMoreItem->_learnMoreInstructionStep = [self.learnMoreInstructionStep copy];
    return learnMoreItem;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, learnMoreInstructionStep);
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, learnMoreInstructionStep, ORKLearnMoreInstructionStep);
    }
    return self;
}

- (NSUInteger)hash {
    return _text.hash ^ _learnMoreInstructionStep.hash;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.learnMoreInstructionStep, castObject.learnMoreInstructionStep));
}

@end
