/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2016, Sage Bionetworks
 
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

#import "ORKOrderedTask.h"
#import "ORKQuestionStep.h"
#import "ORKAnswerFormat.h"
#import "ORKInstructionStep.h"
#import "ORKCompletionStep.h"
#import "ORKStep_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#if TARGET_OS_IOS
#import "ORKFormStep.h"
#import "ORKFormStepViewController.h"
#import "ORKFormItem_Internal.h"
#import "ORKActiveStep_Internal.h"
#import "ORKEarlyTerminationConfiguration.h"
#endif

@implementation ORKOrderedTask {
    NSString *_identifier;
    NSMutableArray *_stepsThatDisplayProgress;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray<ORKStep *> *)steps {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        
        _identifier = [identifier copy];
        _steps = steps;
        
        _progressLabelColor = ORKColor(ORKProgressLabelColorKey);
        [self setUpArrayOfStepsThatShowProgress];
        [self validateParameters];
    }
    return self;
}

- (instancetype)copyWithSteps:(NSArray <ORKStep *> *)steps {
    ORKOrderedTask *task = [self copyWithZone:nil];
    task->_steps = ORKArrayCopyObjects(steps);
    return task;
}

- (instancetype)copyWithSteps:(NSArray <ORKStep *> *)steps identifier:(NSString *)identifier {
    ORKOrderedTask *task = [self copyWithZone:nil];
    task->_steps = ORKArrayCopyObjects(steps);
    task->_identifier = [identifier copy];
    return task;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKOrderedTask *task = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy]
                                                                           steps:ORKArrayCopyObjects(_steps)];
    return task;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.steps, castObject.steps));
}

- (NSUInteger)hash {
    return _identifier.hash ^ _steps.hash;
}

#pragma mark - ORKTask

- (void)validateParameters {
    NSInteger stepCount = 0;
    NSMutableSet<NSString *> *uniqueStepIdentifiers = [NSMutableSet new];
    for (ORKStep *step in self.steps) {
        [uniqueStepIdentifiers addObject:step.identifier];
        stepCount++;
        #if TARGET_OS_IOS
        if (step.earlyTerminationConfiguration.earlyTerminationStep != nil) {
            [uniqueStepIdentifiers addObject:step.earlyTerminationConfiguration.earlyTerminationStep.identifier];
            stepCount++;
        }
        #endif
    }
    BOOL itemsHaveNonUniqueIdentifiers = ( stepCount != uniqueStepIdentifiers.count );
    if (itemsHaveNonUniqueIdentifiers) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Each step should have a unique identifier" userInfo:nil];
    }
}

- (NSString *)identifier {
    return _identifier;
}

- (void)setUpArrayOfStepsThatShowProgress {
    _stepsThatDisplayProgress = [NSMutableArray new];
    
    // Steps will not be included in the _stepsThatDisplayProgress array if:
    // 1) The step is a instruction or completion step (or inherits from it) and is the first or last step in the task
    // 3) There is only ONE step in the entire task
    // 4) The showsProgress property is set to false
    
    for (ORKStep *stepObject in _steps) {
        NSUInteger indexOfStep = [self indexOfStep:stepObject];
        BOOL isFirstOrLastStep = indexOfStep == 0 || indexOfStep == _steps.count - 1;
        BOOL isInstructionOrCompletionStep = [stepObject isKindOfClass:[ORKInstructionStep class]] || [stepObject isKindOfClass:[ORKCompletionStep class]];
        
        if (!(isInstructionOrCompletionStep && isFirstOrLastStep) && [stepObject showsProgress]) {
            [_stepsThatDisplayProgress addObject:stepObject.identifier];
        }
    }
}

- (void)addStepsFromArray:(NSArray<ORKStep *> *)stepsToAdd {
    NSMutableArray *newSteps = [_steps mutableCopy];
    [newSteps addObjectsFromArray:stepsToAdd];
    _steps = [newSteps copy];
    [self validateParameters];
}

- (void)addStep:(ORKStep *)stepToAdd {
    [self addStepsFromArray:@[stepToAdd]];
    [self validateParameters];
}

- (void)insertSteps:(NSArray<ORKStep *> *)stepsToInsert atIndexes:(NSIndexSet *)indexSet {
    NSMutableArray *newSteps = [_steps mutableCopy];
    [newSteps insertObjects:stepsToInsert atIndexes:indexSet];
    _steps = [newSteps copy];
    [self validateParameters];
}

- (void)insertStep:(ORKStep *)stepToInsert atIndex:(NSUInteger)index {
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];
    [self insertSteps:@[stepToInsert] atIndexes:indexSet];
    [self validateParameters];
}

- (NSUInteger)indexOfStep:(ORKStep *)step {
    NSArray *identifiers = [_steps valueForKey:@"identifier"];
    NSUInteger index = [identifiers indexOfObject:step.identifier];
    return index;
}

- (ORKStep *)stepAfterStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    NSArray *steps = _steps;
    
    if (steps.count <= 0) {
        return nil;
    }
    
    ORKStep *currentStep = step;
    ORKStep *nextStep = nil;
    
    if (currentStep == nil) {
        nextStep = steps[0];
    } else {
        NSUInteger index = [self indexOfStep:step];
        
        if (NSNotFound != index && index != (steps.count - 1)) {
            nextStep = steps[index + 1];
        }
    }
    return nextStep;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step withResult:(ORKTaskResult *)result {
    NSArray *steps = _steps;
    
    if (steps.count <= 0) {
        return nil;
    }
    
    ORKStep *currentStep = step;
    ORKStep *previousStep = nil;
    
    if (currentStep == nil) {
        previousStep = nil;
        
    } else {
        NSUInteger index = [self indexOfStep:step];
        
        if (NSNotFound != index && index != 0) {
            previousStep = steps[index - 1];
        }
    }
    return previousStep;
}

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
    __block ORKStep *step = nil;
    [_steps enumerateObjectsUsingBlock:^(ORKStep *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            step = obj;
            *stop = YES;
        #if TARGET_OS_IOS
        } else if ([obj.earlyTerminationConfiguration.earlyTerminationStep.identifier isEqualToString:identifier]) {
            step = obj.earlyTerminationConfiguration.earlyTerminationStep;
            *stop = YES;
        #endif
        }
    }];
    return step;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)taskResult {
    ORKTaskProgress progress;
    
    if ([_stepsThatDisplayProgress containsObject:step.identifier]) {
        progress.current = [_stepsThatDisplayProgress indexOfObject:step.identifier];
        progress.total = _stepsThatDisplayProgress.count;
        progress.shouldBePresented = progress.total > 1 ? YES : NO;
    } else {
        progress.current = [self indexOfStep:step];
        progress.total = 0;
        progress.shouldBePresented = NO;
    }
    
    return progress;
}

- (ORKTaskTotalProgress)totalProgressOfCurrentStep:(ORKStep *)currentStep {
    ORKTaskTotalProgress totalProgress;
    int totalQuestions = 0;
    int currentStepStartingProgressNumber = 0;
    
    for (ORKStep *step in self.steps) {
#if TARGET_OS_IOS
        if ([step isKindOfClass:[ORKFormStep class]]) {
            ORKFormStep *formStep = (ORKFormStep *)step;
            if (formStep.identifier == currentStep.identifier) {
                currentStepStartingProgressNumber = (totalQuestions + 1);
            }
            NSMutableArray *allSections = [self calculateSectionsForFormItems:formStep.formItems];
            totalQuestions += allSections.count;
        } else if ([step isKindOfClass:[ORKQuestionStep class]]) {
            if (step.identifier == currentStep.identifier) {
                currentStepStartingProgressNumber = (totalQuestions + 1);
            }
            totalQuestions += 1;
        }
#else
        if ([step isKindOfClass:[ORKQuestionStep class]]) {
            if (step.identifier == currentStep.identifier) {
                currentStepStartingProgressNumber = (totalQuestions + 1);
            }
            totalQuestions += 1;
        }
#endif
    }
    
    totalProgress.currentStepStartingProgressPosition = currentStepStartingProgressNumber;
    totalProgress.total = totalQuestions;
    
    return totalProgress;
}

#if TARGET_OS_IOS
- (NSMutableArray *)calculateSectionsForFormItems:(NSArray *)formItems {
    NSMutableArray<NSMutableArray *> *_sections = [NSMutableArray new];
    NSMutableArray *section = nil;
    
    for (ORKFormItem *item in formItems) {
        BOOL itemRequiresSingleSection = [self doesItemRequireSingleSection:item];

        if (!item.answerFormat) {
            // Add new section
            section = [NSMutableArray new];
            [_sections addObject:section];
            
        } else if (itemRequiresSingleSection || _sections.count == 0) {
            
            NSMutableArray *newSection = [self buildSingleSection:item];
            [_sections addObject:newSection];
            section = newSection;
        } else {
            if (section) {
                [section addObject:item];
            }
        }
    }
    return _sections;
}

- (NSMutableArray *)buildSingleSection:(ORKFormItem *)item {
    NSMutableArray *section = nil;

    // Section header
    if ([item impliedAnswerFormat] == nil) {
        // Add new section
        section = [NSMutableArray new];
        return section;
    } else {

        if ([self doesItemRequireSingleSection:item]) {
            // Add new section
            section = [NSMutableArray new];
            [section addObject:item];
            return section;

        } else {
            // In case no section available, create new one.
            if (section == nil) {
                section = [NSMutableArray new];
            }
            [section addObject:item];
            return section;
        }
    }
}

- (BOOL)doesItemRequireSingleSection:(ORKFormItem *)item {
    if (item.impliedAnswerFormat == nil) {
        return NO;
    }
    
    ORKAnswerFormat *answerFormat = [item impliedAnswerFormat];
    
    NSArray *singleSectionTypes = @[@(ORKQuestionTypeBoolean),
                                    @(ORKQuestionTypeSingleChoice),
                                    @(ORKQuestionTypeMultipleChoice),
                                    @(ORKQuestionTypeLocation)];
    
    BOOL multiCellChoices = ([singleSectionTypes containsObject:@(answerFormat.questionType)] &&
                             NO == [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]);
    
    BOOL multilineTextEntry = (answerFormat.questionType == ORKQuestionTypeText && [(ORKTextAnswerFormat *)answerFormat multipleLines]);
    
    BOOL scale = (answerFormat.questionType == ORKQuestionTypeScale);
    
    // Items that require individual section
    if (multiCellChoices || multilineTextEntry || scale) {
        return YES;
    }
    
    return NO;
}

- (BOOL)providesBackgroundAudioPrompts {
    BOOL providesAudioPrompts = NO;
    for (ORKStep *step in self.steps) {
        if ([step isKindOfClass:[ORKActiveStep class]]) {
            ORKActiveStep *activeStep = (ORKActiveStep *)step;
            if ([activeStep hasVoice] || [activeStep hasCountDown]) {
                providesAudioPrompts = YES;
                break;
            }
        }
    }
    return providesAudioPrompts;
}

#endif

- (NSSet *)requestedHealthKitTypesForReading {
    NSMutableSet *healthTypes = [NSMutableSet set];
    for (ORKStep *step in self.steps) {
        NSSet *stepSet = [step requestedHealthKitTypesForReading];
        if (stepSet) {
            [healthTypes unionSet:stepSet];
        }
    }
    return healthTypes.count ? healthTypes : nil;
}

- (NSSet *)requestedHealthKitTypesForWriting {
    return nil;
}

- (ORKPermissionMask)requestedPermissions {
    ORKPermissionMask mask = ORKPermissionNone;
    for (ORKStep *step in self.steps) {
        mask |= [step requestedPermissions];
    }
    return mask;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, steps);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_ARRAY(aDecoder, steps, ORKStep);
        
        for (ORKStep *step in _steps) {
            if ([step isKindOfClass:[ORKStep class]]) {
                [step setTask:self];
            }
        }
    }
    return self;
}

@end
