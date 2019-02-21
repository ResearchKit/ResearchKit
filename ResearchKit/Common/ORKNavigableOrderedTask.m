/*
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 
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


#import "ORKNavigableOrderedTask.h"

#import "ORKOrderedTask_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKResult.h"
#import "ORKStep_Private.h"
#import "ORKStepNavigationRule.h"

#import "ORKHelpers_Internal.h"


@implementation ORKNavigableOrderedTask {
    NSMutableDictionary<NSString *, ORKStepNavigationRule *> *_stepNavigationRules;
    NSMutableDictionary<NSString *, ORKSkipStepNavigationRule *> *_skipStepNavigationRules;
    NSMutableDictionary<NSString *, ORKStepModifier *> *_stepModifiers;
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray<ORKStep *> *)steps {
    self = [super initWithIdentifier:identifier steps:steps];
    if (self) {
        _stepNavigationRules = nil;
        _skipStepNavigationRules = nil;
        _shouldReportProgress = NO;
    }
    return self;
}

- (void)setNavigationRule:(ORKStepNavigationRule *)stepNavigationRule forTriggerStepIdentifier:(NSString *)triggerStepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepNavigationRule);
    ORKThrowInvalidArgumentExceptionIfNil(triggerStepIdentifier);
    
    if (!_stepNavigationRules) {
        _stepNavigationRules = [NSMutableDictionary new];
    }
    _stepNavigationRules[triggerStepIdentifier] = stepNavigationRule;
}

- (ORKStepNavigationRule *)navigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(triggerStepIdentifier);

    return _stepNavigationRules[triggerStepIdentifier];
}

- (void)removeNavigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(triggerStepIdentifier);
    
    [_stepNavigationRules removeObjectForKey:triggerStepIdentifier];
}

- (NSDictionary<NSString *, ORKStepNavigationRule *> *)stepNavigationRules {
    if (!_stepNavigationRules) {
        return @{};
    }
    return [_stepNavigationRules copy];
}

- (void)setSkipNavigationRule:(ORKSkipStepNavigationRule *)skipStepNavigationRule forStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(skipStepNavigationRule);
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    
    if (!_skipStepNavigationRules) {
        _skipStepNavigationRules = [NSMutableDictionary new];
    }
    _skipStepNavigationRules[stepIdentifier] = skipStepNavigationRule;
}

- (ORKSkipStepNavigationRule *)skipNavigationRuleForStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    
    return _skipStepNavigationRules[stepIdentifier];
}

- (void)removeSkipNavigationRuleForStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    
    [_skipStepNavigationRules removeObjectForKey:stepIdentifier];
}

- (NSDictionary<NSString *, ORKSkipStepNavigationRule *> *)skipStepNavigationRules {
    if (!_skipStepNavigationRules) {
        return @{};
    }
    return [_skipStepNavigationRules copy];
}

- (void)setStepModifier:(ORKStepModifier *)stepModifier forStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepModifier);
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    
    if (!_stepModifiers) {
        _stepModifiers = [NSMutableDictionary new];
    }
    _stepModifiers[stepIdentifier] = stepModifier;
}

- (ORKStepModifier *)stepModifierForStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    return _stepModifiers[stepIdentifier];
}

- (void)removeStepModifierForStepIdentifier:(NSString *)stepIdentifier {
    ORKThrowInvalidArgumentExceptionIfNil(stepIdentifier);
    
    [_stepModifiers removeObjectForKey:stepIdentifier];
}

- (NSDictionary<NSString *, ORKStepModifier *> *)stepModifiers {
    if (!_stepModifiers) {
        return @{};
    }
    return [_stepModifiers copy];
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    ORKStep *nextStep = nil;
    ORKStepNavigationRule *navigationRule = _stepNavigationRules[step.identifier];
    NSString *nextStepIdentifier = [navigationRule identifierForDestinationStepWithTaskResult:result];
    if (![nextStepIdentifier isEqualToString:ORKNullStepIdentifier]) { // If ORKNullStepIdentifier, return nil to end task
        if (nextStepIdentifier) {
            nextStep = [self stepWithIdentifier:nextStepIdentifier];
            
            if (step && nextStep && [self indexOfStep:nextStep] <= [self indexOfStep:step]) {
                ORK_Log_Warning(@"Index of next step (\"%@\") is equal or lower than index of current step (\"%@\") in ordered task. Make sure this is intentional as you could loop idefinitely without appropriate navigation rules. Also please note that you'll get duplicate result entries each time you loop over the same step.", nextStep.identifier, step.identifier);
            }
        } else {
            nextStep = [super stepAfterStep:step withResult:result];
        }
        
        ORKSkipStepNavigationRule *skipNavigationRule = _skipStepNavigationRules[nextStep.identifier];
        if ([skipNavigationRule stepShouldSkipWithTaskResult:result]) {
            return [self stepAfterStep:nextStep withResult:result];
        }
    }
    
    if (nextStep != nil) {
        ORKStepModifier *stepModifier = [self stepModifierForStepIdentifier:nextStep.identifier];
        [stepModifier modifyStep:nextStep withTaskResult:result];
    }
    
    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    ORKStep *previousStep = nil;
    __block NSInteger indexOfCurrentStepResult = -1;
    [result.results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ORKResult *currentResult, NSUInteger idx, BOOL *stop) {
        if ([currentResult.identifier isEqualToString:step.identifier]) {
            indexOfCurrentStepResult = idx;
            *stop = YES;
        }
    }];
    if (indexOfCurrentStepResult != -1 && indexOfCurrentStepResult != 0) {
        previousStep = [self stepWithIdentifier:result.results[indexOfCurrentStepResult - 1].identifier];
    }
    return previousStep;
}

// Assume ORKNavigableOrderedTask doesn't have a linear order unless user specifically overrides
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    if (_shouldReportProgress) {
        return [super progressOfCurrentStep:step withResult:result];
    }

    return ORKTaskProgressMake(0, 0);
}

#pragma mark Serialization private methods

// These methods should only be used by serialization tests (the stepNavigationRules and skipStepNavigationRules properties are published as readonly)
- (void)setStepNavigationRules:(NSDictionary *)stepNavigationRules {
    _stepNavigationRules = [stepNavigationRules mutableCopy];
}

- (void)setSkipStepNavigationRules:(NSDictionary *)skipStepNavigationRules {
    _skipStepNavigationRules = [skipStepNavigationRules mutableCopy];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_MUTABLE_DICTIONARY(aDecoder, stepNavigationRules, NSString, ORKStepNavigationRule);
        ORK_DECODE_OBJ_MUTABLE_DICTIONARY(aDecoder, skipStepNavigationRules, NSString, ORKSkipStepNavigationRule);
        ORK_DECODE_OBJ_MUTABLE_DICTIONARY(aDecoder, stepModifiers, NSString, ORKStepModifier);
        ORK_DECODE_BOOL(aDecoder, shouldReportProgress);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    ORK_ENCODE_OBJ(aCoder, stepNavigationRules);
    ORK_ENCODE_OBJ(aCoder, skipStepNavigationRules);
    ORK_ENCODE_OBJ(aCoder, stepModifiers);
    ORK_ENCODE_BOOL(aCoder, shouldReportProgress);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) task = [super copyWithZone:zone];
    task->_stepNavigationRules = ORKMutableDictionaryCopyObjects(_stepNavigationRules);
    task->_skipStepNavigationRules = ORKMutableDictionaryCopyObjects(_skipStepNavigationRules);
    task->_stepModifiers = ORKMutableDictionaryCopyObjects(_stepModifiers);
    task->_shouldReportProgress = _shouldReportProgress;
    return task;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame
    && ORKEqualObjects(self.stepNavigationRules, castObject.stepNavigationRules)
    && ORKEqualObjects(self.skipStepNavigationRules, castObject.skipStepNavigationRules)
    && ORKEqualObjects(self.stepModifiers, castObject.stepModifiers)
    && self.shouldReportProgress == castObject.shouldReportProgress;
}

- (NSUInteger)hash {
    return super.hash ^ _stepNavigationRules.hash ^ _skipStepNavigationRules.hash ^ _stepModifiers.hash ^ (_shouldReportProgress ? 0xf : 0x0);
}

@end
