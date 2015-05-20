/*
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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
#import "ORKOrderedTask_Internal.h"
#import "ORKHelpers.h"
#import "ORKStepNavigationRule.h"


@implementation ORKNavigableOrderedTask {
    NSMutableDictionary *_stepNavigationRules;
    NSMutableOrderedSet *_stepIdentifierStack;
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray *)steps {
    self = [super initWithIdentifier:identifier steps:steps];
    if (self) {
        _stepNavigationRules = nil;
        _stepIdentifierStack = nil;
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

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    ORKStep *nextStep = nil;
    ORKStepNavigationRule *navigationRule = _stepNavigationRules[step.identifier];
    NSString *nextStepIdentifier = [navigationRule identifierForDestinationStepWithTaskResult:result];
    if (![nextStepIdentifier isEqualToString:ORKNullStepIdentifier]) { // If ORKNullStepIdentifier, return nil to end task
        if (nextStepIdentifier) {
            nextStep = [self stepWithIdentifier:nextStepIdentifier];
            
            #if defined(DEBUG) && DEBUG
            if (step && nextStep && [self indexOfStep:nextStep] <= [self indexOfStep:step]) {
                ORK_Log_Debug(@"Warning: index of next step (\"%@\") is equal or lower than index of current step (\"%@\") in ordered task. Make sure this is intentional as you could loop idefinitely without appropriate navigation rules.", nextStep.identifier, step.identifier);
            }
            #endif
        } else {
            nextStep = [super stepAfterStep:step withResult:result];
        }
        if (nextStep) {
            [self updateStepIdentifierStackWithSourceIdentifier:step.identifier destinationIdentifier:nextStep.identifier];
        }
    }
    return nextStep;
}
    
- (void)updateStepIdentifierStackWithSourceIdentifier:(NSString *)sourceIdentifier destinationIdentifier:(NSString *)destinationIdentifier {
    NSParameterAssert(destinationIdentifier);
    
    if (!_stepIdentifierStack) {
        _stepIdentifierStack = [NSMutableOrderedSet new];
        // sourceIdentifier is nil if the task starts fresh,
        // but can have a value if the task is being restored to a specific step
        if (sourceIdentifier) {
            [_stepIdentifierStack addObject:sourceIdentifier];
        }
        [_stepIdentifierStack addObject:destinationIdentifier];
        return;
    }
    
    NSUInteger indexOfSource = [_stepIdentifierStack indexOfObject:sourceIdentifier];
    if (indexOfSource == NSNotFound) {
        ORK_Log_Debug(@"WARNING: you are calling an out of on order step in an ongoing task (\"%@\" -> \"%@\"). Clearing navigation stack.", sourceIdentifier, destinationIdentifier);
        [_stepIdentifierStack removeAllObjects];
        if (sourceIdentifier) {
            [_stepIdentifierStack addObject:sourceIdentifier];
        }
        [_stepIdentifierStack addObject:destinationIdentifier];
        return;
    }
    
    NSUInteger stackCount = [_stepIdentifierStack count];
    if (indexOfSource != stackCount - 1) {
        [_stepIdentifierStack removeObjectsInRange:NSMakeRange(indexOfSource + 1, stackCount - (indexOfSource + 1))];
    }
    [_stepIdentifierStack addObject:destinationIdentifier];
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    ORKStep *previousStep = nil;
    if (_stepIdentifierStack) {
        NSUInteger indexOfSource = [_stepIdentifierStack indexOfObject:step.identifier];
        if (indexOfSource != NSNotFound && indexOfSource >= 1) {
            previousStep = [self stepWithIdentifier:_stepIdentifierStack[indexOfSource - 1]];
        }
    }
    return previousStep;
}

// ORKNavigableOrderedTask doesn't have a linear order
- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    return ORKTaskProgressMake(0, 0);
}

// This method should only be used by serialization (the stepNavigationRules property is published as readonly)
- (void)setStepNavigationRules:(NSDictionary *)stepNavigationRules {
    _stepNavigationRules = [stepNavigationRules mutableCopy];
}

#pragma mark NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_MUTABLE_DICTIONARY(aDecoder, stepNavigationRules, NSString, ORKStepNavigationRule);
        ORK_DECODE_OBJ_MUTABLE_ORDERED_SET(aDecoder, stepIdentifierStack, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    ORK_ENCODE_OBJ(aCoder, stepNavigationRules);
    ORK_ENCODE_OBJ(aCoder, stepIdentifierStack);
}

#pragma mark NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    typeof(self) task = [super copyWithZone:zone];
    task->_stepNavigationRules = ORKMutableDictionaryCopyObjects(_stepNavigationRules);
    task->_stepIdentifierStack = ORKMutableOrderedSetCopyObjects(_stepIdentifierStack);
    return task;
}

// Note: 'isEqual:' and 'hash' ignore _stepIdentifierStack
- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame
    && ORKEqualObjects(self->_stepNavigationRules, castObject->_stepNavigationRules);
}

- (NSUInteger)hash {
    return [super hash] ^ [_stepNavigationRules hash];
}

@end
