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

#import "ORKConditionStepConfiguration.h"

#import "ORKCollectionResult.h"
#import "ORKFormStep.h"
#import "ORKHealthCondition.h"
#import "ORKHelpers_Internal.h"


@implementation ORKConditionStepConfiguration

- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier
          conditionsFormItemIdentifier:(NSString *)conditionsFormItemIdentifier
                            conditions:(NSArray<ORKHealthCondition *> *)conditions
                             formItems:(nonnull NSArray<ORKFormItem *> *)formItems {
    self = [super init];
    
    if (self) {
        _stepIdentifier = [stepIdentifier copy];
        _conditionsFormItemIdentifier = [conditionsFormItemIdentifier copy];
        _conditions = [conditions copy];
        _formItems = [formItems copy];
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, stepIdentifier);
    ORK_ENCODE_OBJ(aCoder, conditionsFormItemIdentifier);
    ORK_ENCODE_OBJ(aCoder, conditions);
    ORK_ENCODE_OBJ(aCoder, formItems);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, stepIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, conditionsFormItemIdentifier, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, conditions, ORKHealthCondition);
        ORK_DECODE_OBJ_ARRAY(aDecoder, formItems, ORKFormItem);
    }
    return self;
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    ORKConditionStepConfiguration *conditionStepConfiguration = [[[self class] alloc] init];
    conditionStepConfiguration->_stepIdentifier = [_stepIdentifier copy];
    conditionStepConfiguration->_conditionsFormItemIdentifier = [_conditionsFormItemIdentifier copy];
    conditionStepConfiguration->_conditions = [_conditions copy];
    conditionStepConfiguration->_formItems = [_formItems copy];
    
    return conditionStepConfiguration;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(_stepIdentifier, castObject->_stepIdentifier)
            && ORKEqualObjects(_conditionsFormItemIdentifier, castObject->_conditionsFormItemIdentifier)
            && ORKEqualObjects(_conditions, castObject->_conditions)
            && ORKEqualObjects(_formItems, castObject->_formItems));
}

- (NSUInteger)hash {
    return super.hash ^ _stepIdentifier.hash ^ _conditionsFormItemIdentifier.hash ^ _conditions.hash ^ _formItems.hash;
}

@end
