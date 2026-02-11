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

#import <ResearchKit/ORKPredicateFormItemVisibilityRule_Private.h>
#import <ResearchKit/ORKCollectionResult.h>
#import <ResearchKit/ORKResultPredicate.h>

#import "ORKHelpers_Internal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ORKPredicateFormItemVisibilityRule

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (nullable instancetype)initWithPredicateFormat:(NSString *)predicateFormat {
    NSPredicate *predicate = ORKPredicateWithFormat(predicateFormat, @"ORKPredicateFormItemVisibilityRule");
    
    if (predicate != nil) {
        self = [self initWithPredicate:predicate];
        _predicateFormat = [predicateFormat copy];
    }
    return self;
}

- (instancetype)initWithPredicate:(NSPredicate *)predicate {
    self = [super init];
    if (self != nil) {
        _predicate = [predicate copy];
    }
    return self;
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    // [predicate allowEvaluation] is needed because Foundation doesn’t want any old predicate decoded and then end up providing a vector for user data to execute arbitrary code. 
    if (self && (aDecoder.requiresSecureCoding == YES)) {
        ORK_DECODE_OBJ_CLASS(aDecoder, predicate, NSPredicate);
        ORK_DECODE_OBJ_CLASS(aDecoder, predicateFormat, NSString);
        [self.predicate allowEvaluation];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, predicate);
    ORK_ENCODE_OBJ(aCoder, predicateFormat);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    __typeof(self) rule = [[[self class] allocWithZone:zone] initWithPredicate:_predicate];
    rule->_predicateFormat = [_predicateFormat copy];
    return rule;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    BOOL result = isParentSame
    && ORKEqualObjects(_predicate, castObject->_predicate)
    && ORKEqualObjects(_predicateFormat, castObject->_predicateFormat);

    return result;
}

- (NSUInteger)hash {
    NSUInteger hash = _predicate.hash ^ _predicateFormat.hash;
    return hash;
}

- (BOOL)formItemVisibilityForTaskResult:(nullable ORKTaskResult *)taskResult {
    
    // Our ORKPredicates expect evaluateWithObject to be called with an array of taskResults.
    // if taskResult is nil, we have to pass an empty array
    NSArray<ORKTaskResult *> *evaluationObject = (taskResult != nil) ? @[taskResult] : @[];
    NSString *taskResultIdentifier = taskResult.identifier ?: @"";
    
    BOOL result = [self.predicate evaluateWithObject:evaluationObject substitutionVariables: @{
        ORKResultPredicateTaskIdentifierVariableName: taskResultIdentifier
    }];
    return result;
}

@end

NS_ASSUME_NONNULL_END
