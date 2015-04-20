/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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
#import "ORKHelpers.h"
#import "ORKVisualConsentStep.h"
#import "ORKStep_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKActiveStep.h"
#import "ORKActiveStep_Internal.h"
#import "ORKAudioStepViewController.h"
#import "ORKWalkingTaskStepViewController.h"
#import "ORKTappingIntervalStep.h"
#import "ORKCountdownStepViewController.h"
#import "ORKHelpers.h"
#import "ORKFitnessStepViewController.h"
#import "ORKCompletionStep.h"
#import "ORKActiveStep_Internal.h"
#import "ORKSpatialSpanMemoryStepViewController.h"
#import "ORKDefines_Private.h"
#import "ORKAudioStep.h"
#import "ORKCountdownStep.h"
#import "ORKFitnessStep.h"
#import "ORKWalkingTaskStep.h"
#import "ORKSpatialSpanMemoryStep.h"
#import "ORKAccelerometerRecorder.h"
#import "ORKAudioRecorder.h"

ORKTaskProgress ORKTaskProgressMake(NSUInteger current, NSUInteger total) {
    return (ORKTaskProgress){.current=current,.total=total};
}

@implementation ORKOrderedTask {
    NSString *_identifier;
}

- (instancetype)initWithIdentifier:(NSString *)identifier steps:(NSArray *)steps {
    self = [super init];
    if (self) {
        
        if ( nil == identifier) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"identifier can not be nil." userInfo:nil];
        }
        
        _identifier = [identifier copy];
        _steps = steps;
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKOrderedTask *task = [[[self class] allocWithZone:zone] init];
    task->_identifier = [_identifier copy];
    task->_steps = ORKArrayCopyObjects(_steps);
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
    return [_identifier hash] ^ [_steps hash];
}

#pragma mark - ORKTask

- (NSString *)identifier {
    return _identifier;
}

- (NSUInteger)indexOfStep:(ORKStep *)step {
    NSUInteger index = [_steps indexOfObject:step];
    if (index == NSNotFound) {
        NSArray *identifiers = [_steps valueForKey:@"identifier"];
        index = [identifiers indexOfObject:step.identifier];
    }
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
        
        if (NSNotFound != index && index != (steps.count-1)) {
            nextStep = steps[index+1];
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
    
    ORKStep *nextStep = nil;
    
    if (currentStep == nil) {
        nextStep = nil;
        
    } else {
        
        NSUInteger index = [self indexOfStep:step];
        
        if (NSNotFound != index && index != 0) {
            nextStep = steps[index-1];
        }
    }
    
    return nextStep;
    
}

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
    __block ORKStep *ret = nil;
    [_steps enumerateObjectsUsingBlock:^(ORKStep *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)taskResult {
    
    ORKTaskProgress progress;
    progress.current = [self indexOfStep:step];
    progress.total = [_steps count];
    
    if (![step showsProgress]) {
        progress.total = 0;
    }
    
    return progress;
}


- (NSSet *)requestedHealthKitTypesForReading {
    NSMutableSet *healthTypes = [NSMutableSet set];
    for (ORKStep *step in self.steps) {
        
        if ([step isKindOfClass:[ORKFormStep class]]) {
            ORKFormStep *formStep = (ORKFormStep *)step;
            
            for (ORKFormItem *formItem in formStep.formItems) {
                ORKAnswerFormat *answerFormat = [formItem answerFormat];
                HKObjectType *objType = [answerFormat healthKitObjectType];
                if (objType) {
                    [healthTypes addObject:objType];
                }
            }
        }
        else if ([step isKindOfClass:[ORKQuestionStep class]]) {
            HKObjectType *objType = [[(ORKQuestionStep *)step answerFormat] healthKitObjectType];
            if (objType)
            {
                [healthTypes addObject:objType];
            }
        }
        else if ([step isKindOfClass:[ORKActiveStep class]]) {
            ORKActiveStep *activeStep = (ORKActiveStep *)step;
            [healthTypes unionSet:[activeStep requestedHealthKitTypesForReading]];
        }
    }
    
    return [healthTypes count] ? healthTypes : nil;
}

- (NSSet *)requestedHealthKitTypesForWriting {
    return nil;
}

- (ORKPermissionMask)requestedPermissions {
    ORKPermissionMask mask = ORKPermissionNone;
    for (ORKStep *step in self.steps) {
        if ([step isKindOfClass:[ORKActiveStep class]]) {
            mask |= [(ORKActiveStep *)step requestedPermissions];
        }
    }
    return mask;
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

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, steps);
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
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



#pragma mark - Predefined

static NSString * const ORKInstruction0StepIdentifier = @"instruction";
static NSString * const ORKInstruction1StepIdentifier = @"instruction1";
static NSString * const ORKCountdownStepIdentifier = @"countdown";
static NSString * const ORKAudioStepIdentifier = @"audio";
static NSString * const ORKTappingStepIdentifier = @"tapping";
static NSString * const ORKConclusionStepIdentifier = @"conclusion";
static NSString * const ORKFitnessWalkStepIdentifier = @"fitness.walk";
static NSString * const ORKFitnessRestStepIdentifier = @"fitness.rest";
static NSString * const ORKShortWalkOutboundStepIdentifier = @"walking.outbound";
static NSString * const ORKShortWalkReturnStepIdentifier = @"walking.return";
static NSString * const ORKShortWalkRestStepIdentifier = @"walking.rest";
static NSString * const ORKSpatialSpanMemoryStepIdentifier = @"cognitive.memory.spatialspan";

+ (ORKCompletionStep *)makeCompletionStep {
    
    ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKConclusionStepIdentifier];
    step.title = ORKLocalizedString(@"TASK_COMPLETE_TITLE", nil);
    step.text = ORKLocalizedString(@"TASK_COMPLETE_TEXT", nil);
    step.shouldTintImages = YES;
    return step;
}

static void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step){
    [step validateParameters];
    [array addObject:step];
}

+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                       intendedUseDescription:(NSString *)intendedUseDescription
                                                     duration:(NSTimeInterval)duration
                                                      options:(ORKPredefinedTaskOption)options {
    
    NSString *durationString = [ORKDurationStringFormatter() stringFromTimeInterval:duration];
    
    NSMutableArray *steps = [NSMutableArray array];
    if (! (options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TAPPING_INTRO_TEXT", nil);
            
            NSString *imageName = @"phonetapping";
            if (! [[[NSLocale preferredLanguages] firstObject] hasPrefix:@"en"]) {
                imageName = [imageName stringByAppendingString:@"_notap"];
            }
            step.image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            NSString *template =  ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_FORMAT", nil);
            
            step.text = [NSString stringWithFormat:template, durationString];
            step.detailText = ORKLocalizedString(@"TAPPING_CALL_TO_ACTION", nil);
            
            UIImage *im1 = [UIImage imageNamed:@"handtapping01" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *im2 = [UIImage imageNamed:@"handtapping02" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            
            step.image = [UIImage animatedImageWithImages:@[im1, im2] duration:1];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        
        NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
        if (! (ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithFrequency:100]];
        }
        
        ORKTappingIntervalStep *step = [[ORKTappingIntervalStep alloc] initWithIdentifier:ORKTappingStepIdentifier];
        step.title = ORKLocalizedString(@"TAPPING_INSTRUCTION", nil);
        step.stepDuration = duration;
        step.shouldContinueOnFinish = YES;
        step.recorderConfigurations = recorderConfigurations;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (! (options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:[steps copy]];
    
    return task;
}



+ (ORKOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(NSString *)intendedUseDescription
                         speechInstruction:(NSString *)speechInstruction
                    shortSpeechInstruction:(NSString *)shortSpeechInstruction
                                  duration:(NSTimeInterval)duration
                         recordingSettings:(NSDictionary *)recordingSettings
                                   options:(ORKPredefinedTaskOption)options {
    
    NSDictionary *defaultRecordingSettings = @{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                               AVNumberOfChannelsKey : @(2),
                                               AVSampleRateKey: @(44100.0)
                                               };
    recordingSettings = recordingSettings ? : defaultRecordingSettings;
    
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }
    
    NSMutableArray *steps = [NSMutableArray array];
    if (! (options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"AUDIO_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phonewaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"AUDIO_TASK_TITLE", nil);
            step.text = speechInstruction?:ORKLocalizedString(@"AUDIO_INTRO_TEXT",nil);
            step.detailText = ORKLocalizedString(@"AUDIO_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonesoundwaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep * step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        // Collect audio during the countdown step too, to provide a baseline.
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithRecorderSettings:recordingSettings]];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:ORKAudioStepIdentifier];
        step.title = shortSpeechInstruction ? : ORKLocalizedString(@"AUDIO_INSTRUCTION", nil);
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithRecorderSettings:recordingSettings]];
        step.duration = duration;
        step.shouldContinueOnFinish = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (! (options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

+ (NSDateComponentsFormatter *)textTimeFormatter {
    
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
    
    
    /*
     Exception list:
     Korean, Chinese (all), Thai, and Vietnamese.
     */
    NSArray *nonSpelledOutLanguages = @[@"ko", @"zh", @"th", @"vi", @"ja"];
    NSString *currentLanguage = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    NSString *currentLanguageCode = [NSLocale componentsFromLocaleIdentifier:currentLanguage][NSLocaleLanguageCode];
    if ((currentLanguageCode != nil) && [nonSpelledOutLanguages containsObject:currentLanguageCode]) {
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    }
    
    
    formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropAll;
    return formatter;
}

+ (ORKOrderedTask *)fitnessCheckTaskWithIdentifier:(NSString *)identifier
                           intendedUseDescription:(NSString *)intendedUseDescription
                                     walkDuration:(NSTimeInterval)walkDuration
                                     restDuration:(NSTimeInterval)restDuration
                                          options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    
    NSMutableArray *steps = [NSMutableArray array];
    if (! (options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = intendedUseDescription ? : [NSString stringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            step.image = [UIImage imageNamed:@"heartbeat" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = [NSString stringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_2_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration], [formatter stringFromTimeInterval:restDuration]];
            step.image = [UIImage imageNamed:@"walkingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep * step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    {
        if (walkDuration > 0)
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
            if (! (ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[ORKPedometerRecorderConfiguration new]];
            }
            if (! (ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithFrequency:100]];
            }
            if (! (ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100]];
            }
            if (! (ORKPredefinedTaskOptionExcludeLocation & options)) {
                [recorderConfigurations addObject:[ORKLocationRecorderConfiguration new]];
            }
            if (! (ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithHealthQuantityType:heartRateType unit:bpmUnit]];
            }
            ORKFitnessStep *fitnessStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessWalkStepIdentifier];
            fitnessStep.stepDuration = walkDuration;
            fitnessStep.title = [NSString stringWithFormat:ORKLocalizedString(@"FITNESS_WALK_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            fitnessStep.spokenInstruction = fitnessStep.title;
            fitnessStep.recorderConfigurations = recorderConfigurations;
            fitnessStep.shouldShowDefaultTimer = NO;
            fitnessStep.shouldContinueOnFinish = YES;
            fitnessStep.optional = NO;
            fitnessStep.shouldStartTimerAutomatically = YES;
            fitnessStep.shouldTintImages = YES;
            fitnessStep.image = [UIImage imageNamed:@"walkingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            fitnessStep.shouldVibrateOnStart = YES;
            fitnessStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, fitnessStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
            if (! (ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithFrequency:100]];
            }
            if (! (ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100]];
            }
            if (! (ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithHealthQuantityType:heartRateType unit:bpmUnit]];
            }
            
            ORKFitnessStep *stillStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessRestStepIdentifier];
            stillStep.stepDuration = restDuration;
            stillStep.title = [NSString stringWithFormat:ORKLocalizedString(@"FITNESS_SIT_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:restDuration]];
            stillStep.spokenInstruction = stillStep.title;
            stillStep.recorderConfigurations = recorderConfigurations;
            stillStep.shouldShowDefaultTimer = NO;
            stillStep.shouldContinueOnFinish = YES;
            stillStep.optional = NO;
            stillStep.shouldStartTimerAutomatically = YES;
            stillStep.shouldTintImages = YES;
            stillStep.image = [UIImage imageNamed:@"sittingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            stillStep.shouldVibrateOnStart = YES;
            stillStep.shouldPlaySoundOnStart = YES;
            stillStep.shouldPlaySoundOnFinish = YES;
            stillStep.shouldVibrateOnFinish = YES;
            
            ORKStepArrayAddStep(steps, stillStep);
        }
    }
    
    
    if (! (options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}


+ (ORKOrderedTask *)shortWalkTaskWithIdentifier:(NSString *)identifier
                         intendedUseDescription:(NSString *)intendedUseDescription
                            numberOfStepsPerLeg:(NSInteger)numberOfStepsPerLeg
                                   restDuration:(NSTimeInterval)restDuration
                                        options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    
    NSMutableArray *steps = [NSMutableArray array];
    if (! (options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"WALK_INTRO_TEXT", nil);
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"WALK_TASK_TITLE", nil);
            step.text = [NSString stringWithFormat:ORKLocalizedString(@"WALK_INTRO_2_TEXT_%ld", nil),numberOfStepsPerLeg];
            step.detailText = ORKLocalizedString(@"WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"pocket" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep * step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        NSMutableArray *recorderConfigurations = [NSMutableArray array];
        NSMutableArray *recorderConfigurationsWithoutPedometer = [NSMutableArray array];
        if (! (ORKPredefinedTaskOptionExcludePedometer & options)) {
            [recorderConfigurations addObject:[ORKPedometerRecorderConfiguration new]];
        }
        if (! (ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithFrequency:100]];
            [recorderConfigurationsWithoutPedometer addObject:[recorderConfigurations lastObject]];
        }
        if (! (ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
            [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithFrequency:100]];
            [recorderConfigurationsWithoutPedometer addObject:[recorderConfigurations lastObject]];
        }
        
        {
            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkOutboundStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = [NSString stringWithFormat:ORKLocalizedString(@"WALK_OUTBOUND_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.title;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldShowDefaultTimer = NO;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.optional = NO;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        {
            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkReturnStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = [NSString stringWithFormat:ORKLocalizedString(@"WALK_RETURN_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.title;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldShowDefaultTimer = NO;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.optional = NO;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        if (restDuration > 0) {
            ORKFitnessStep *activeStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKShortWalkRestStepIdentifier];
            activeStep.recorderConfigurations = recorderConfigurationsWithoutPedometer;
            NSString *durationString = [formatter stringFromTimeInterval:restDuration];
            activeStep.title = [NSString stringWithFormat:ORKLocalizedString(@"WALK_STAND_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.spokenInstruction = [NSString stringWithFormat:ORKLocalizedString(@"WALK_STAND_VOICE_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.shouldStartTimerAutomatically = YES;
            activeStep.stepDuration = restDuration;
            activeStep.shouldShowDefaultTimer = NO;
            activeStep.shouldContinueOnFinish = YES;
            activeStep.optional = NO;
            activeStep.shouldVibrateOnStart = YES;
            activeStep.shouldPlaySoundOnStart = YES;
            activeStep.shouldVibrateOnFinish = YES;
            activeStep.shouldPlaySoundOnFinish = YES;
            
            
            ORKStepArrayAddStep(steps, activeStep);
        }
    }
    
    
    if (! (options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}


+ (ORKOrderedTask *)spatialSpanMemoryTaskWithIdentifier:(NSString *)identifier
                                 intendedUseDescription:(NSString *)intendedUseDescription
                                            initialSpan:(NSInteger)initialSpan
                                            minimumSpan:(NSInteger)minimumSpan
                                            maximumSpan:(NSInteger)maximumSpan
                                              playSpeed:(NSTimeInterval)playSpeed
                                               maxTests:(NSInteger)maxTests
                                 maxConsecutiveFailures:(NSInteger)maxConsecutiveFailures
                                      customTargetImage:(UIImage *)customTargetImage
                                 customTargetPluralName:(NSString *)customTargetPluralName
                                        requireReversal:(BOOL)requireReversal
                                                options:(ORKPredefinedTaskOption)options {
    
    
    NSString *targetPluralName = customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_PLURAL", nil);
    
    NSMutableArray *steps = [NSMutableArray array];
    if (! (options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = [NSString stringWithFormat:ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_TEXT_%@", nil),targetPluralName];
            
            step.image = [UIImage imageNamed:@"phone-memory" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = [NSString stringWithFormat:requireReversal ? ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_REVERSE_%@", nil) : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_%@", nil), targetPluralName, targetPluralName];
            step.detailText = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_CALL_TO_ACTION", nil);
            
            if (! customTargetImage) {
                step.image = [UIImage imageNamed:@"memory-second-screen" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            } else {
                step.image = customTargetImage;
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKSpatialSpanMemoryStep *step = [[ORKSpatialSpanMemoryStep alloc] initWithIdentifier:ORKSpatialSpanMemoryStepIdentifier];
        step.title = nil;
        step.text = nil;
        
        step.initialSpan = initialSpan;
        step.minimumSpan = minimumSpan;
        step.maximumSpan = maximumSpan;
        step.playSpeed = playSpeed;
        step.maxTests = maxTests;
        step.maxConsecutiveFailures = maxConsecutiveFailures;
        step.customTargetImage = customTargetImage;
        step.customTargetPluralName = customTargetPluralName;
        step.requireReversal = requireReversal;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    
    if (! (options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}


@end
