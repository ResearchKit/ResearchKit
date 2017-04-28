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

#import "ORKAudioStepViewController.h"
#import "ORKCountdownStepViewController.h"
#import "ORKTouchAnywhereStepViewController.h"
#import "ORKFitnessStepViewController.h"
#import "ORKToneAudiometryStepViewController.h"
#import "ORKSpatialSpanMemoryStepViewController.h"
#import "ORKWalkingTaskStepViewController.h"

#import "ORKAccelerometerRecorder.h"
#import "ORKActiveStep_Internal.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAudioLevelNavigationRule.h"
#import "ORKAudioRecorder.h"
#import "ORKAudioStep.h"
#import "ORKCompletionStep.h"
#import "ORKCountdownStep.h"
#import "ORKTouchAnywhereStep.h"
#import "ORKFitnessStep.h"
#import "ORKFormStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKPSATStep.h"
#import "ORKQuestionStep.h"
#import "ORKReactionTimeStep.h"
#import "ORKSpatialSpanMemoryStep.h"
#import "ORKStep_Private.h"
#import "ORKTappingIntervalStep.h"
#import "ORKTimedWalkStep.h"
#import "ORKToneAudiometryStep.h"
#import "ORKToneAudiometryPracticeStep.h"
#import "ORKTowerOfHanoiStep.h"
#import "ORKTrailmakingStep.h"
#import "ORKVisualConsentStep.h"
#import "ORKRangeOfMotionStep.h"
#import "ORKShoulderRangeOfMotionStep.h"
#import "ORKWaitStep.h"
#import "ORKWalkingTaskStep.h"
#import "ORKResultPredicate.h"

#import "ORKHelpers_Internal.h"
#import "UIImage+ResearchKit.h"
#import <limits.h>

ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierA = @"A";
ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierB = @"B";


ORKTaskProgress ORKTaskProgressMake(NSUInteger current, NSUInteger total) {
    return (ORKTaskProgress){.current=current, .total=total};
}

@implementation ORKOrderedTask {
    NSString *_identifier;
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
        
        [self validateParameters];
    }
    return self;
}

- (instancetype)copyWithSteps:(NSArray <ORKStep *> *)steps {
    ORKOrderedTask *task = [self copyWithZone:nil];
    task->_steps = ORKArrayCopyObjects(steps);
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
    NSArray *uniqueIdentifiers = [self.steps valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
    BOOL itemsHaveNonUniqueIdentifiers = ( self.steps.count != uniqueIdentifiers.count );
    
    if (itemsHaveNonUniqueIdentifiers) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Each step should have a unique identifier" userInfo:nil];
    }
}

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
    ORKStep *nextStep = nil;
    
    if (currentStep == nil) {
        nextStep = nil;
        
    } else {
        NSUInteger index = [self indexOfStep:step];
        
        if (NSNotFound != index && index != 0) {
            nextStep = steps[index - 1];
        }
    }
    return nextStep;
}

- (ORKStep *)stepWithIdentifier:(NSString *)identifier {
    __block ORKStep *step = nil;
    [_steps enumerateObjectsUsingBlock:^(ORKStep *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            step = obj;
            *stop = YES;
        }
    }];
    return step;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep *)step withResult:(ORKTaskResult *)taskResult {
    ORKTaskProgress progress;
    progress.current = [self indexOfStep:step];
    progress.total = _steps.count;
    
    if (![step showsProgress]) {
        progress.total = 0;
    }
    return progress;
}

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

#pragma mark - Predefined

NSString *const ORKInstruction0StepIdentifier = @"instruction";
NSString *const ORKInstruction1StepIdentifier = @"instruction1";
NSString *const ORKInstruction2StepIdentifier = @"instruction2";
NSString *const ORKInstruction3StepIdentifier = @"instruction3";
NSString *const ORKInstruction4StepIdentifier = @"instruction4";
NSString *const ORKInstruction5StepIdentifier = @"instruction5";
NSString *const ORKInstruction6StepIdentifier = @"instruction6";
NSString *const ORKInstruction7StepIdentifier = @"instruction7";
NSString *const ORKCountdownStepIdentifier = @"countdown";
NSString *const ORKCountdown1StepIdentifier = @"countdown1";
NSString *const ORKCountdown2StepIdentifier = @"countdown2";
NSString *const ORKCountdown3StepIdentifier = @"countdown3";
NSString *const ORKCountdown4StepIdentifier = @"countdown4";
NSString *const ORKCountdown5StepIdentifier = @"countdown5";
NSString *const ORKTouchAnywhereStepIdentifier = @"touch.anywhere";
NSString *const ORKAudioStepIdentifier = @"audio";
NSString *const ORKAudioTooLoudStepIdentifier = @"audio.tooloud";
NSString *const ORKTappingStepIdentifier = @"tapping";
NSString *const ORKActiveTaskLeftHandIdentifier = @"left";
NSString *const ORKActiveTaskRightHandIdentifier = @"right";
NSString *const ORKActiveTaskSkipHandStepIdentifier = @"skipHand";
NSString *const ORKConclusionStepIdentifier = @"conclusion";
NSString *const ORKFitnessWalkStepIdentifier = @"fitness.walk";
NSString *const ORKFitnessRestStepIdentifier = @"fitness.rest";
NSString *const ORKKneeRangeOfMotionStepIdentifier = @"knee.range.of.motion";
NSString *const ORKShoulderRangeOfMotionStepIdentifier = @"shoulder.range.of.motion";
NSString *const ORKShortWalkOutboundStepIdentifier = @"walking.outbound";
NSString *const ORKShortWalkReturnStepIdentifier = @"walking.return";
NSString *const ORKShortWalkRestStepIdentifier = @"walking.rest";
NSString *const ORKSpatialSpanMemoryStepIdentifier = @"cognitive.memory.spatialspan";
NSString *const ORKToneAudiometryPracticeStepIdentifier = @"tone.audiometry.practice";
NSString *const ORKToneAudiometryStepIdentifier = @"tone.audiometry";
NSString *const ORKReactionTimeStepIdentifier = @"reactionTime";
NSString *const ORKTowerOfHanoiStepIdentifier = @"towerOfHanoi";
NSString *const ORKTimedWalkFormStepIdentifier = @"timed.walk.form";
NSString *const ORKTimedWalkFormAFOStepIdentifier = @"timed.walk.form.afo";
NSString *const ORKTimedWalkFormAssistanceStepIdentifier = @"timed.walk.form.assistance";
NSString *const ORKTimedWalkTrial1StepIdentifier = @"timed.walk.trial1";
NSString *const ORKTimedWalkTurnAroundStepIdentifier = @"timed.walk.turn.around";
NSString *const ORKTimedWalkTrial2StepIdentifier = @"timed.walk.trial2";
NSString *const ORKTremorTestInLapStepIdentifier = @"tremor.handInLap";
NSString *const ORKTremorTestExtendArmStepIdentifier = @"tremor.handAtShoulderLength";
NSString *const ORKTremorTestBendArmStepIdentifier = @"tremor.handAtShoulderLengthWithElbowBent";
NSString *const ORKTremorTestTouchNoseStepIdentifier = @"tremor.handToNose";
NSString *const ORKTremorTestTurnWristStepIdentifier = @"tremor.handQueenWave";
NSString *const ORKTrailmakingStepIdentifier = @"trailmaking";
NSString *const ORKActiveTaskMostAffectedHandIdentifier = @"mostAffected";
NSString *const ORKPSATStepIdentifier = @"psat";
NSString *const ORKAudioRecorderIdentifier = @"audio";
NSString *const ORKAccelerometerRecorderIdentifier = @"accelerometer";
NSString *const ORKPedometerRecorderIdentifier = @"pedometer";
NSString *const ORKDeviceMotionRecorderIdentifier = @"deviceMotion";
NSString *const ORKLocationRecorderIdentifier = @"location";
NSString *const ORKHeartRateRecorderIdentifier = @"heartRate";

+ (ORKCompletionStep *)makeCompletionStep {
    ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:ORKConclusionStepIdentifier];
    step.title = ORKLocalizedString(@"TASK_COMPLETE_TITLE", nil);
    step.text = ORKLocalizedString(@"TASK_COMPLETE_TEXT", nil);
    step.shouldTintImages = YES;
    return step;
}

void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step) {
    [step validateParameters];
    [array addObject:step];
}

+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                       intendedUseDescription:(NSString *)intendedUseDescription
                                                     duration:(NSTimeInterval)duration
                                                      options:(ORKPredefinedTaskOption)options {
    return [self twoFingerTappingIntervalTaskWithIdentifier:identifier
                                     intendedUseDescription:intendedUseDescription
                                                   duration:duration
                                                handOptions:0
                                                    options:options];
}
    
+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                        intendedUseDescription:(NSString *)intendedUseDescription
                                                      duration:(NSTimeInterval)duration
                                                   handOptions:(ORKPredefinedTaskHandOption)handOptions
                                                       options:(ORKPredefinedTaskOption)options {
    
    NSString *durationString = [ORKDurationStringFormatter() stringFromTimeInterval:duration];
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TAPPING_INTRO_TEXT", nil);
            
            NSString *imageName = @"phonetapping";
            if (![[NSLocale preferredLanguages].firstObject hasPrefix:@"en"]) {
                imageName = [imageName stringByAppendingString:@"_notap"];
            }
            step.image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // Setup which hand to start with and how many hands to add based on the handOptions parameter
    // Hand order is randomly determined.
    NSUInteger handCount = ((handOptions & ORKPredefinedTaskHandOptionBoth) == ORKPredefinedTaskHandOptionBoth) ? 2 : 1;
    BOOL undefinedHand = (handOptions == 0);
    BOOL rightHand;
    switch (handOptions) {
        case ORKPredefinedTaskHandOptionLeft:
            rightHand = NO; break;
        case ORKPredefinedTaskHandOptionRight:
        case ORKPredefinedTaskHandOptionUnspecified:
            rightHand = YES; break;
        default:
            rightHand = (arc4random()%2 == 0); break;
        }
        
    for (NSUInteger hand = 1; hand <= handCount; hand++) {
        
        NSString * (^appendIdentifier) (NSString *) = ^ (NSString * identifier) {
            if (undefinedHand) {
                return identifier;
            } else {
                NSString *handIdentifier = rightHand ? ORKActiveTaskRightHandIdentifier : ORKActiveTaskLeftHandIdentifier;
                return [NSString stringWithFormat:@"%@.%@", identifier, handIdentifier];
            }
        };
        
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:appendIdentifier(ORKInstruction1StepIdentifier)];
            
            // Set the title based on the hand
            if (undefinedHand) {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE", nil);
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE_RIGHT", nil);
            } else {
                step.title = ORKLocalizedString(@"TAPPING_TASK_TITLE_LEFT", nil);
            }
            
            // Set the instructions for the tapping test screen that is displayed prior to each hand test
            NSString *restText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_REST_PHONE", nil);
            NSString *tappingTextFormat = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_FORMAT", nil);
            NSString *tappingText = [NSString localizedStringWithFormat:tappingTextFormat, durationString];
            NSString *handText = nil;
            
            if (hand == 1) {
                if (undefinedHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_MOST_AFFECTED", nil);
                } else if (rightHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_RIGHT_FIRST", nil);
                } else {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_LEFT_FIRST", nil);
                }
            } else {
                if (rightHand) {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_RIGHT_SECOND", nil);
                } else {
                    handText = ORKLocalizedString(@"TAPPING_INTRO_TEXT_2_LEFT_SECOND", nil);
                }
            }
            
            step.text = [NSString localizedStringWithFormat:@"%@ %@ %@", restText, handText, tappingText];
            
            // Continue button will be different from first hand and second hand
            if (hand == 1) {
                step.detailText = ORKLocalizedString(@"TAPPING_CALL_TO_ACTION", nil);
            } else {
                step.detailText = ORKLocalizedString(@"TAPPING_CALL_TO_ACTION_NEXT", nil);
            }
            
            // Set the image
            UIImage *im1 = [UIImage imageNamed:@"handtapping01" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *im2 = [UIImage imageNamed:@"handtapping02" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            UIImage *imageAnimation = [UIImage animatedImageWithImages:@[im1, im2] duration:1];
            
            if (rightHand || undefinedHand) {
                step.image = imageAnimation;
            } else {
                step.image = [imageAnimation ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    
        // TAPPING STEP
    {
        NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
        if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                      frequency:100]];
        }
        
            ORKTappingIntervalStep *step = [[ORKTappingIntervalStep alloc] initWithIdentifier:appendIdentifier(ORKTappingStepIdentifier)];
            if (undefinedHand) {
                step.title = ORKLocalizedString(@"TAPPING_INSTRUCTION", nil);
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TAPPING_INSTRUCTION_RIGHT", nil);
            } else {
                step.title = ORKLocalizedString(@"TAPPING_INSTRUCTION_LEFT", nil);
            }
            step.stepDuration = duration;
            step.shouldContinueOnFinish = YES;
            step.recorderConfigurations = recorderConfigurations;
            step.optional = (handCount == 2);
            
            ORKStepArrayAddStep(steps, step);
        }
        
        // Flip to the other hand (ignored if handCount == 1)
        rightHand = !rightHand;
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
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
    
    return [self audioTaskWithIdentifier:identifier
                  intendedUseDescription:intendedUseDescription
                       speechInstruction:speechInstruction
                  shortSpeechInstruction:shortSpeechInstruction
                                duration:duration
                       recordingSettings:recordingSettings
                         checkAudioLevel:NO
                                 options:options];
}

+ (ORKNavigableOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                   speechInstruction:(nullable NSString *)speechInstruction
                              shortSpeechInstruction:(nullable NSString *)shortSpeechInstruction
                                            duration:(NSTimeInterval)duration
                                   recordingSettings:(nullable NSDictionary *)recordingSettings
                                     checkAudioLevel:(BOOL)checkAudioLevel
                                             options:(ORKPredefinedTaskOption)options {

    recordingSettings = recordingSettings ? : @{ AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                 AVNumberOfChannelsKey : @(2),
                                                AVSampleRateKey: @(44100.0) };
    
    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
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
            step.text = speechInstruction ? : ORKLocalizedString(@"AUDIO_INTRO_TEXT",nil);
            step.detailText = ORKLocalizedString(@"AUDIO_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonesoundwaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        // Collect audio during the countdown step too, to provide a baseline.
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:ORKAudioRecorderIdentifier
                                                                                 recorderSettings:recordingSettings]];
        
        // If checking the sound level then add text indicating that's what is happening
        if (checkAudioLevel) {
            step.text = ORKLocalizedString(@"AUDIO_LEVEL_CHECK_LABEL", nil);
        }
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (checkAudioLevel) {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKAudioTooLoudStepIdentifier];
        step.text = ORKLocalizedString(@"AUDIO_TOO_LOUD_MESSAGE", nil);
        step.detailText = ORKLocalizedString(@"AUDIO_TOO_LOUD_ACTION_NEXT", nil);
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKAudioStep *step = [[ORKAudioStep alloc] initWithIdentifier:ORKAudioStepIdentifier];
        step.title = shortSpeechInstruction ? : ORKLocalizedString(@"AUDIO_INSTRUCTION", nil);
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:ORKAudioRecorderIdentifier
                                                                                 recorderSettings:recordingSettings]];
        step.stepDuration = duration;
        step.shouldContinueOnFinish = YES;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    if (checkAudioLevel) {
    
        // Add rules to check for audio and fail, looping back to the countdown step if required
        ORKAudioLevelNavigationRule *audioRule = [[ORKAudioLevelNavigationRule alloc] initWithAudioLevelStepIdentifier:ORKCountdownStepIdentifier destinationStepIdentifier:ORKAudioStepIdentifier recordingSettings:recordingSettings];
        ORKDirectStepNavigationRule *loopRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKCountdownStepIdentifier];
    
        [task setNavigationRule:audioRule forTriggerStepIdentifier:ORKCountdownStepIdentifier];
        [task setNavigationRule:loopRule forTriggerStepIdentifier:ORKAudioTooLoudStepIdentifier];
    }
    
    return task;
}

+ (NSDateComponentsFormatter *)textTimeFormatter {
    NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleSpellOut;
    
    // Exception list: Korean, Chinese (all), Thai, and Vietnamese.
    NSArray *nonSpelledOutLanguages = @[@"ko", @"zh", @"th", @"vi", @"ja"];
    NSString *currentLanguage = [[NSBundle mainBundle] preferredLocalizations].firstObject;
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
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = intendedUseDescription ? : [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            step.image = [UIImage imageNamed:@"heartbeat" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"FITNESS_TASK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_INTRO_2_TEXT_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration], [formatter stringFromTimeInterval:restDuration]];
            step.image = [UIImage imageNamed:@"walkingman" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    {
        if (walkDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray arrayWithCapacity:5];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeLocation & options)) {
                [recorderConfigurations addObject:[[ORKLocationRecorderConfiguration alloc] initWithIdentifier:ORKLocationRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:ORKHeartRateRecorderIdentifier
                                                                                                      healthQuantityType:heartRateType unit:bpmUnit]];
            }
            ORKFitnessStep *fitnessStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessWalkStepIdentifier];
            fitnessStep.stepDuration = walkDuration;
            fitnessStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_WALK_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:walkDuration]];
            fitnessStep.spokenInstruction = fitnessStep.title;
            fitnessStep.recorderConfigurations = recorderConfigurations;
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
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeHeartRate & options)) {
                [recorderConfigurations addObject:[[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:ORKHeartRateRecorderIdentifier
                                                                                                      healthQuantityType:heartRateType unit:bpmUnit]];
            }
            
            ORKFitnessStep *stillStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKFitnessRestStepIdentifier];
            stillStep.stepDuration = restDuration;
            stillStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"FITNESS_SIT_INSTRUCTION_FORMAT", nil), [formatter stringFromTimeInterval:restDuration]];
            stillStep.spokenInstruction = stillStep.title;
            stillStep.recorderConfigurations = recorderConfigurations;
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
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
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
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
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
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_INTRO_2_TEXT_%ld", nil),numberOfStepsPerLeg];
            step.detailText = ORKLocalizedString(@"WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"pocket" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkOutboundStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_OUTBOUND_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.title;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.optional = NO;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkReturnStepIdentifier];
            walkingStep.numberOfStepsPerLeg = numberOfStepsPerLeg;
            walkingStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_RETURN_INSTRUCTION_FORMAT", nil), (long long)numberOfStepsPerLeg];
            walkingStep.spokenInstruction = walkingStep.title;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.optional = NO;
            walkingStep.stepDuration = numberOfStepsPerLeg * 1.5; // fallback duration in case no step count
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }

            ORKFitnessStep *activeStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKShortWalkRestStepIdentifier];
            activeStep.recorderConfigurations = recorderConfigurations;
            NSString *durationString = [formatter stringFromTimeInterval:restDuration];
            activeStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_STAND_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.spokenInstruction = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_STAND_VOICE_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.shouldStartTimerAutomatically = YES;
            activeStep.stepDuration = restDuration;
            activeStep.shouldContinueOnFinish = YES;
            activeStep.optional = NO;
            activeStep.shouldVibrateOnStart = YES;
            activeStep.shouldPlaySoundOnStart = YES;
            activeStep.shouldVibrateOnFinish = YES;
            activeStep.shouldPlaySoundOnFinish = YES;
            
            ORKStepArrayAddStep(steps, activeStep);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}


+ (ORKOrderedTask *)walkBackAndForthTaskWithIdentifier:(NSString *)identifier
                                intendedUseDescription:(NSString *)intendedUseDescription
                                          walkDuration:(NSTimeInterval)walkDuration
                                          restDuration:(NSTimeInterval)restDuration
                                               options:(ORKPredefinedTaskOption)options {
    
    NSDateComponentsFormatter *formatter = [self textTimeFormatter];
    formatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
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
            step.text = ORKLocalizedString(@"WALK_INTRO_2_TEXT_BACK_AND_FORTH_INSTRUCTION", nil);
            step.detailText = ORKLocalizedString(@"WALK_INTRO_2_DETAIL_BACK_AND_FORTH_INSTRUCTION", nil);
            step.image = [UIImage imageNamed:@"pocket" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludePedometer & options)) {
                [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
            }
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            
            ORKWalkingTaskStep *walkingStep = [[ORKWalkingTaskStep alloc] initWithIdentifier:ORKShortWalkOutboundStepIdentifier];
            walkingStep.numberOfStepsPerLeg = 1000; // Set the number of steps very high so it is ignored
            NSString *walkingDurationString = [formatter stringFromTimeInterval:walkDuration];
            walkingStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_BACK_AND_FORTH_INSTRUCTION_FORMAT", nil), walkingDurationString];
            walkingStep.spokenInstruction = walkingStep.title;
            walkingStep.recorderConfigurations = recorderConfigurations;
            walkingStep.shouldContinueOnFinish = YES;
            walkingStep.optional = NO;
            walkingStep.shouldStartTimerAutomatically = YES;
            walkingStep.stepDuration = walkDuration; // Set the walking duration to the step duration
            walkingStep.shouldVibrateOnStart = YES;
            walkingStep.shouldPlaySoundOnStart = YES;
            walkingStep.shouldSpeakRemainingTimeAtHalfway = (walkDuration > 20);
            
            ORKStepArrayAddStep(steps, walkingStep);
        }
        
        if (restDuration > 0) {
            NSMutableArray *recorderConfigurations = [NSMutableArray array];
            if (!(ORKPredefinedTaskOptionExcludeAccelerometer & options)) {
                [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                          frequency:100]];
            }
            if (!(ORKPredefinedTaskOptionExcludeDeviceMotion & options)) {
                [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                         frequency:100]];
            }
            
            ORKFitnessStep *activeStep = [[ORKFitnessStep alloc] initWithIdentifier:ORKShortWalkRestStepIdentifier];
            activeStep.recorderConfigurations = recorderConfigurations;
            NSString *durationString = [formatter stringFromTimeInterval:restDuration];
            activeStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"WALK_BACK_AND_FORTH_STAND_INSTRUCTION_FORMAT", nil), durationString];
            activeStep.spokenInstruction = activeStep.title;
            activeStep.shouldStartTimerAutomatically = YES;
            activeStep.stepDuration = restDuration;
            activeStep.shouldContinueOnFinish = YES;
            activeStep.optional = NO;
            activeStep.shouldVibrateOnStart = YES;
            activeStep.shouldPlaySoundOnStart = YES;
            activeStep.shouldVibrateOnFinish = YES;
            activeStep.shouldPlaySoundOnFinish = YES;
            activeStep.finishedSpokenInstruction = ORKLocalizedString(@"WALK_BACK_AND_FORTH_FINISHED_VOICE", nil);
            activeStep.shouldSpeakRemainingTimeAtHalfway = (restDuration > 20);
            
            ORKStepArrayAddStep(steps, activeStep);
        }
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

+ (ORKOrderedTask *)kneeRangeOfMotionTaskWithIdentifier:(NSString *)identifier
                                             limbOption:(ORKPredefinedTaskLimbOption)limbOption
                                 intendedUseDescription:(NSString *)intendedUseDescription
                                                options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    NSString *limbType = ORKLocalizedString(@"LIMB_RIGHT", nil);
    UIImage *kneeFlexedImage = [UIImage imageNamed:@"knee_flexed_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    UIImage *kneeExtendedImage = [UIImage imageNamed:@"knee_extended_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];

    if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
        limbType = ORKLocalizedString(@"LIMB_LEFT", nil);
    
        kneeFlexedImage = [UIImage imageNamed:@"knee_flexed_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        kneeExtendedImage = [UIImage imageNamed:@"knee_extended_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        ORKInstructionStep *instructionStep0 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
        instructionStep0.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep0.text = intendedUseDescription;
        instructionStep0.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_%@", nil), limbType];
        instructionStep0.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep0);
 
        ORKInstructionStep *instructionStep1 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
        instructionStep1.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep1.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_%@", nil), limbType];
        ORKStepArrayAddStep(steps, instructionStep1);
        
        ORKInstructionStep *instructionStep2 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
        instructionStep2.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep2.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_%@", nil), limbType];
        instructionStep2.image = kneeFlexedImage;
        instructionStep2.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep2);
        
        ORKInstructionStep *instructionStep3 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction3StepIdentifier];
        instructionStep3.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep3.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_%@", nil), limbType];
        instructionStep3.image = kneeExtendedImage;
        instructionStep3.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep3);
    }

    ORKTouchAnywhereStep *touchAnywhereStep = [[ORKTouchAnywhereStep alloc] initWithIdentifier:ORKTouchAnywhereStepIdentifier instructionText:[NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_%@", nil), limbType]];
    ORKStepArrayAddStep(steps, touchAnywhereStep);
    
    ORKDeviceMotionRecorderConfiguration *deviceMotionRecorderConfig = [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency:100];
    
    ORKRangeOfMotionStep *kneeRangeOfMotionStep = [[ORKRangeOfMotionStep alloc] initWithIdentifier:ORKKneeRangeOfMotionStepIdentifier limbOption:limbOption];
    kneeRangeOfMotionStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"KNEE_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_%@", nil), limbType];
    kneeRangeOfMotionStep.spokenInstruction = kneeRangeOfMotionStep.title;

    kneeRangeOfMotionStep.recorderConfigurations = @[deviceMotionRecorderConfig];
    kneeRangeOfMotionStep.optional = NO;

    ORKStepArrayAddStep(steps, kneeRangeOfMotionStep);

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *completionStep = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, completionStep);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

+ (ORKOrderedTask *)shoulderRangeOfMotionTaskWithIdentifier:(NSString *)identifier
                                                 limbOption:(ORKPredefinedTaskLimbOption)limbOption
                                     intendedUseDescription:(NSString *)intendedUseDescription
                                                    options:(ORKPredefinedTaskOption)options {
    NSMutableArray *steps = [NSMutableArray array];
    NSString *limbType = ORKLocalizedString(@"LIMB_RIGHT", nil);
    UIImage *shoulderFlexedImage = [UIImage imageNamed:@"shoulder_flexed_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    UIImage *shoulderExtendedImage = [UIImage imageNamed:@"shoulder_extended_right" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];

    if (limbOption == ORKPredefinedTaskLimbOptionLeft) {
        limbType = ORKLocalizedString(@"LIMB_LEFT", nil);
        shoulderFlexedImage = [UIImage imageNamed:@"shoulder_flexed_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        shoulderExtendedImage = [UIImage imageNamed:@"shoulder_extended_left" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        ORKInstructionStep *instructionStep0 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
        instructionStep0.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep0.text = intendedUseDescription;
        instructionStep0.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_0_%@", nil), limbType];
        instructionStep0.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep0);
        
        ORKInstructionStep *instructionStep1 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
        instructionStep1.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep1.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_1_%@", nil), limbType];
        ORKStepArrayAddStep(steps, instructionStep1);
        
        ORKInstructionStep *instructionStep2 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
        instructionStep2.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep2.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_2_%@", nil), limbType];
        instructionStep2.image = shoulderFlexedImage;
        instructionStep2.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep2);
        
        ORKInstructionStep *instructionStep3 = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction3StepIdentifier];
        instructionStep3.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TITLE_%@", nil), [limbType capitalizedString]];
        instructionStep3.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TEXT_INSTRUCTION_3_%@", nil), limbType];
        instructionStep3.image = shoulderExtendedImage;
        instructionStep3.shouldTintImages = YES;
        ORKStepArrayAddStep(steps, instructionStep3);
    }
    
    ORKTouchAnywhereStep *touchAnywhereStep = [[ORKTouchAnywhereStep alloc] initWithIdentifier:ORKTouchAnywhereStepIdentifier instructionText:[NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_TOUCH_ANYWHERE_STEP_INSTRUCTION_%@", nil), limbType]];
    ORKStepArrayAddStep(steps, touchAnywhereStep);
    
    ORKDeviceMotionRecorderConfiguration *deviceMotionRecorderConfig = [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency:100];
    
    ORKShoulderRangeOfMotionStep *shoulderRangeOfMotionStep = [[ORKShoulderRangeOfMotionStep alloc] initWithIdentifier:ORKShoulderRangeOfMotionStepIdentifier limbOption:limbOption];
    shoulderRangeOfMotionStep.title = [NSString localizedStringWithFormat:ORKLocalizedString(@"SHOULDER_RANGE_OF_MOTION_SPOKEN_INSTRUCTION_%@", nil), limbType];
    shoulderRangeOfMotionStep.spokenInstruction = shoulderRangeOfMotionStep.title;
    
    shoulderRangeOfMotionStep.recorderConfigurations = @[deviceMotionRecorderConfig];
    shoulderRangeOfMotionStep.optional = NO;
    
    ORKStepArrayAddStep(steps, shoulderRangeOfMotionStep);
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKCompletionStep *completionStep = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, completionStep);
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
                                               maximumTests:(NSInteger)maximumTests
                                 maximumConsecutiveFailures:(NSInteger)maximumConsecutiveFailures
                                      customTargetImage:(UIImage *)customTargetImage
                                 customTargetPluralName:(NSString *)customTargetPluralName
                                        requireReversal:(BOOL)requireReversal
                                                options:(ORKPredefinedTaskOption)options {
    
    NSString *targetPluralName = customTargetPluralName ? : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TARGET_PLURAL", nil);
    
    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = [NSString localizedStringWithFormat:ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_TEXT_%@", nil),targetPluralName];
            
            step.image = [UIImage imageNamed:@"phone-memory" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:requireReversal ? ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_REVERSE_%@", nil) : ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_INTRO_2_TEXT_%@", nil), targetPluralName, targetPluralName];
            step.detailText = ORKLocalizedString(@"SPATIAL_SPAN_MEMORY_CALL_TO_ACTION", nil);
            
            if (!customTargetImage) {
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
        step.maximumTests = maximumTests;
        step.maximumConsecutiveFailures = maximumConsecutiveFailures;
        step.customTargetImage = customTargetImage;
        step.customTargetPluralName = customTargetPluralName;
        step.requireReversal = requireReversal;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

+ (ORKOrderedTask *)toneAudiometryTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                   speechInstruction:(nullable NSString *)speechInstruction
                              shortSpeechInstruction:(nullable NSString *)shortSpeechInstruction
                                        toneDuration:(NSTimeInterval)toneDuration
                                             options:(ORKPredefinedTaskOption)options {

    if (options & ORKPredefinedTaskOptionExcludeAudio) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Audio collection cannot be excluded from audio task" userInfo:nil];
    }

    NSMutableArray *steps = [NSMutableArray array];
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TONE_AUDIOMETRY_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phonewaves_inverted" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
            step.text = speechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_INTRO_TEXT", nil);
            step.detailText = ORKLocalizedString(@"TONE_AUDIOMETRY_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phonefrequencywaves" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKToneAudiometryPracticeStep *step = [[ORKToneAudiometryPracticeStep alloc] initWithIdentifier:ORKToneAudiometryPracticeStepIdentifier];
        step.title = ORKLocalizedString(@"TONE_AUDIOMETRY_TASK_TITLE", nil);
        step.text = speechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_PREP_TEXT", nil);
        ORKStepArrayAddStep(steps, step);
        
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;

        ORKStepArrayAddStep(steps, step);
    }

    {
        ORKToneAudiometryStep *step = [[ORKToneAudiometryStep alloc] initWithIdentifier:ORKToneAudiometryStepIdentifier];
        step.title = shortSpeechInstruction ? : ORKLocalizedString(@"TONE_AUDIOMETRY_INSTRUCTION", nil);
        step.toneDuration = toneDuration;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];

        ORKStepArrayAddStep(steps, step);
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];

    return task;
}

+ (ORKOrderedTask *)towerOfHanoiTaskWithIdentifier:(NSString *)identifier
                            intendedUseDescription:(nullable NSString *)intendedUseDescription
                                     numberOfDisks:(NSUInteger)numberOfDisks
                                           options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phone-tower-of-hanoi" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TITLE", nil);
            step.text = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_INTRO_TEXT", nil);
            step.detailText = ORKLocalizedString(@"TOWER_OF_HANOI_TASK_TASK_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"tower-of-hanoi-second-screen" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    ORKTowerOfHanoiStep *towerOfHanoiStep = [[ORKTowerOfHanoiStep alloc]initWithIdentifier:ORKTowerOfHanoiStepIdentifier];
    towerOfHanoiStep.numberOfDisks = numberOfDisks;
    ORKStepArrayAddStep(steps, towerOfHanoiStep);
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc]initWithIdentifier:identifier steps:steps];
    
    return task;
}

+ (ORKOrderedTask *)reactionTimeTaskWithIdentifier:(NSString *)identifier
                            intendedUseDescription:(nullable NSString *)intendedUseDescription
                           maximumStimulusInterval:(NSTimeInterval)maximumStimulusInterval
                           minimumStimulusInterval:(NSTimeInterval)minimumStimulusInterval
                             thresholdAcceleration:(double)thresholdAcceleration
                                  numberOfAttempts:(int)numberOfAttempts
                                           timeout:(NSTimeInterval)timeout
                                      successSound:(UInt32)successSoundID
                                      timeoutSound:(UInt32)timeoutSoundID
                                      failureSound:(UInt32)failureSoundID
                                           options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"REACTION_TIME_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"REACTION_TIME_TASK_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"phoneshake" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"REACTION_TIME_TASK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat: ORKLocalizedString(@"REACTION_TIME_TASK_INTRO_TEXT_FORMAT", nil), numberOfAttempts];
            step.detailText = ORKLocalizedString(@"REACTION_TIME_TASK_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"phoneshakecircle" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    ORKReactionTimeStep *step = [[ORKReactionTimeStep alloc] initWithIdentifier:ORKReactionTimeStepIdentifier];
    step.maximumStimulusInterval = maximumStimulusInterval;
    step.minimumStimulusInterval = minimumStimulusInterval;
    step.thresholdAcceleration = thresholdAcceleration;
    step.numberOfAttempts = numberOfAttempts;
    step.timeout = timeout;
    step.successSound = successSoundID;
    step.timeoutSound = timeoutSoundID;
    step.failureSound = failureSoundID;
    step.recorderConfigurations = @[ [[ORKDeviceMotionRecorderConfiguration  alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier frequency: 100]];

    ORKStepArrayAddStep(steps, step);
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

+ (ORKOrderedTask *)timedWalkTaskWithIdentifier:(NSString *)identifier
                         intendedUseDescription:(nullable NSString *)intendedUseDescription
                               distanceInMeters:(double)distanceInMeters
                                      timeLimit:(NSTimeInterval)timeLimit
                     includeAssistiveDeviceForm:(BOOL)includeAssistiveDeviceForm
                                        options:(ORKPredefinedTaskOption)options {

    NSMutableArray *steps = [NSMutableArray array];

    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    lengthFormatter.numberFormatter.maximumFractionDigits = 1;
    lengthFormatter.numberFormatter.maximumSignificantDigits = 3;
    NSString *formattedLength = [lengthFormatter stringFromMeters:distanceInMeters];

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_DETAIL", nil);
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (includeAssistiveDeviceForm) {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:ORKTimedWalkFormStepIdentifier
                                                              title:ORKLocalizedString(@"TIMED_WALK_FORM_TITLE", nil)
                                                               text:ORKLocalizedString(@"TIMED_WALK_FORM_TEXT", nil)];

        ORKAnswerFormat *answerFormat1 = [ORKAnswerFormat booleanAnswerFormat];
        ORKFormItem *formItem1 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAFOStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_TEXT", nil)
                                                            answerFormat:answerFormat1];
        formItem1.optional = NO;

        NSArray *textChoices = @[ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_2", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_3", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_4", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_5", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_6", nil)];
        ORKAnswerFormat *answerFormat2 = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *formItem2 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAssistanceStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TITLE", nil)
                                                            answerFormat:answerFormat2];
        formItem2.placeholder = ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TEXT", nil);
        formItem2.optional = NO;

        step.formItems = @[formItem1, formItem2];
        step.optional = NO;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TIMED_WALK_INTRO_2_TEXT_%@", nil), formattedLength];
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"timer" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;

        ORKStepArrayAddStep(steps, step);
    }
    
    {
        NSMutableArray *recorderConfigurations = [NSMutableArray array];
        if (!(options & ORKPredefinedTaskOptionExcludePedometer)) {
            [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeAccelerometer)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                      frequency:100]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeDeviceMotion)) {
            [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                     frequency:100]];
        }
        if (! (options & ORKPredefinedTaskOptionExcludeLocation)) {
            [recorderConfigurations addObject:[[ORKLocationRecorderConfiguration alloc] initWithIdentifier:ORKLocationRecorderIdentifier]];
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial1StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_%@", nil), formattedLength];
            step.text = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil);
            step.spokenInstruction = step.title;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-outbound" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial2StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_2", nil), formattedLength];
            step.text = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil);
            step.spokenInstruction = step.title;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-return" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];

        ORKStepArrayAddStep(steps, step);
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

+ (ORKOrderedTask *)timedWalkTaskWithIdentifier:(NSString *)identifier
                         intendedUseDescription:(nullable NSString *)intendedUseDescription
                               distanceInMeters:(double)distanceInMeters
                                      timeLimit:(NSTimeInterval)timeLimit
                            turnAroundTimeLimit:(NSTimeInterval)turnAroundTimeLimit
                     includeAssistiveDeviceForm:(BOOL)includeAssistiveDeviceForm
                                        options:(ORKPredefinedTaskOption)options {

    NSMutableArray *steps = [NSMutableArray array];

    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    lengthFormatter.numberFormatter.maximumFractionDigits = 1;
    lengthFormatter.numberFormatter.maximumSignificantDigits = 3;
    NSString *formattedLength = [lengthFormatter stringFromMeters:distanceInMeters];

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_DETAIL", nil);
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (includeAssistiveDeviceForm) {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:ORKTimedWalkFormStepIdentifier
                                                              title:ORKLocalizedString(@"TIMED_WALK_FORM_TITLE", nil)
                                                               text:ORKLocalizedString(@"TIMED_WALK_FORM_TEXT", nil)];

        ORKAnswerFormat *answerFormat1 = [ORKAnswerFormat booleanAnswerFormat];
        ORKFormItem *formItem1 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAFOStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_TEXT", nil)
                                                            answerFormat:answerFormat1];
        formItem1.optional = NO;

        NSArray *textChoices = @[ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_2", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_3", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_4", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_5", nil),
                                 ORKLocalizedString(@"TIMED_WALK_QUESTION_2_CHOICE_6", nil)];
        ORKAnswerFormat *answerFormat2 = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *formItem2 = [[ORKFormItem alloc] initWithIdentifier:ORKTimedWalkFormAssistanceStepIdentifier
                                                                    text:ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TITLE", nil)
                                                            answerFormat:answerFormat2];
        formItem2.placeholder = ORKLocalizedString(@"TIMED_WALK_QUESTION_2_TEXT", nil);
        formItem2.optional = NO;

        step.formItems = @[formItem1, formItem2];
        step.optional = NO;

        ORKStepArrayAddStep(steps, step);
    }

    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_TITLE", nil);
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"TIMED_WALK_INTRO_2_TEXT_%@", nil), formattedLength];
            step.detailText = ORKLocalizedString(@"TIMED_WALK_INTRO_2_DETAIL", nil);
            step.image = [UIImage imageNamed:@"timer" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;

            ORKStepArrayAddStep(steps, step);
        }
    }

    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;

        ORKStepArrayAddStep(steps, step);
    }

    {
        NSMutableArray *recorderConfigurations = [NSMutableArray array];
        if (!(options & ORKPredefinedTaskOptionExcludePedometer)) {
            [recorderConfigurations addObject:[[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:ORKPedometerRecorderIdentifier]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeAccelerometer)) {
            [recorderConfigurations addObject:[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:ORKAccelerometerRecorderIdentifier
                                                                                                      frequency:100]];
        }
        if (!(options & ORKPredefinedTaskOptionExcludeDeviceMotion)) {
            [recorderConfigurations addObject:[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:ORKDeviceMotionRecorderIdentifier
                                                                                                     frequency:100]];
        }
        if (! (options & ORKPredefinedTaskOptionExcludeLocation)) {
            [recorderConfigurations addObject:[[ORKLocationRecorderConfiguration alloc] initWithIdentifier:ORKLocationRecorderIdentifier]];
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial1StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_%@", nil), formattedLength];
            step.text = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil);
            step.spokenInstruction = step.title;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-outbound" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTurnAroundStepIdentifier];
            step.title = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TURN", nil);
            step.text = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil);
            step.spokenInstruction = step.title;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = 1;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"turnaround" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = turnAroundTimeLimit == 0 ? CGFLOAT_MAX : turnAroundTimeLimit;

            ORKStepArrayAddStep(steps, step);
        }

        {
            ORKTimedWalkStep *step = [[ORKTimedWalkStep alloc] initWithIdentifier:ORKTimedWalkTrial2StepIdentifier];
            step.title = [[NSString alloc] initWithFormat:ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_2", nil), formattedLength];
            step.text = ORKLocalizedString(@"TIMED_WALK_INSTRUCTION_TEXT", nil);
            step.spokenInstruction = step.title;
            step.recorderConfigurations = recorderConfigurations;
            step.distanceInMeters = distanceInMeters;
            step.shouldTintImages = YES;
            step.image = [UIImage imageNamed:@"timed-walkingman-return" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.stepDuration = timeLimit == 0 ? CGFLOAT_MAX : timeLimit;

            ORKStepArrayAddStep(steps, step);
        }
    }

    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];

        ORKStepArrayAddStep(steps, step);
    }

    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

+ (ORKOrderedTask *)PSATTaskWithIdentifier:(NSString *)identifier
                    intendedUseDescription:(nullable NSString *)intendedUseDescription
                          presentationMode:(ORKPSATPresentationMode)presentationMode
                     interStimulusInterval:(NSTimeInterval)interStimulusInterval
                          stimulusDuration:(NSTimeInterval)stimulusDuration
                              seriesLength:(NSInteger)seriesLength
                                   options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray *steps = [NSMutableArray array];
    NSString *versionTitle = @"";
    NSString *versionDetailText = @"";
    
    if (presentationMode == ORKPSATPresentationModeAuditory) {
        versionTitle = ORKLocalizedString(@"PASAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PASAT_INTRO_TEXT", nil);
    } else if (presentationMode == ORKPSATPresentationModeVisual) {
        versionTitle = ORKLocalizedString(@"PVSAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PVSAT_INTRO_TEXT", nil);
    } else {
        versionTitle = ORKLocalizedString(@"PAVSAT_TITLE", nil);
        versionDetailText = ORKLocalizedString(@"PAVSAT_INTRO_TEXT", nil);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = versionTitle;
            step.detailText = versionDetailText;
            step.text = intendedUseDescription;
            step.image = [UIImage imageNamed:@"phonepsat" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = versionTitle;
            step.text = [NSString localizedStringWithFormat:ORKLocalizedString(@"PSAT_INTRO_TEXT_2_%@", nil), [NSNumberFormatter localizedStringFromNumber:@(interStimulusInterval) numberStyle:NSNumberFormatterDecimalStyle]];
            step.detailText = ORKLocalizedString(@"PSAT_CALL_TO_ACTION", nil);
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 5.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKPSATStep *step = [[ORKPSATStep alloc] initWithIdentifier:ORKPSATStepIdentifier];
        step.title = ORKLocalizedString(@"PSAT_INITIAL_INSTRUCTION", nil);
        step.stepDuration = (seriesLength + 1) * interStimulusInterval;
        step.presentationMode = presentationMode;
        step.interStimulusInterval = interStimulusInterval;
        step.stimulusDuration = stimulusDuration;
        step.seriesLength = seriesLength;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:[steps copy]];
    
    return task;
}

+ (NSString *)stepIdentifier:(NSString *)stepIdentifier withHandIdentifier:(NSString *)handIdentifier {
    return [NSString stringWithFormat:@"%@.%@", stepIdentifier, handIdentifier];
}

+ (NSMutableArray *)stepsForOneHandTremorTestTaskWithIdentifier:(NSString *)identifier
                                             activeStepDuration:(NSTimeInterval)activeStepDuration
                                              activeTaskOptions:(ORKTremorActiveTaskOption)activeTaskOptions
                                                       lastHand:(BOOL)lastHand
                                                       leftHand:(BOOL)leftHand
                                                 handIdentifier:(NSString *)handIdentifier
                                                introDetailText:(NSString *)detailText
                                                        options:(ORKPredefinedTaskOption)options {
    NSMutableArray<ORKActiveStep *> *steps = [NSMutableArray array];
    NSString *stepFinishedInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_FINISHED_INSTRUCTION", nil);
    BOOL rightHand = !leftHand && ![handIdentifier isEqualToString:ORKActiveTaskMostAffectedHandIdentifier];
    
    {
        NSString *stepIdentifier = [self stepIdentifier:ORKInstruction1StepIdentifier withHandIdentifier:handIdentifier];
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
        step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
        
        if ([identifier isEqualToString:ORKActiveTaskMostAffectedHandIdentifier]) {
            step.text = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DEFAULT_TEXT", nil);
            step.detailText = detailText;
        } else {
            if (leftHand) {
                step.text = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_LEFT_HAND_TEXT", nil);
            } else {
                step.text = ORKLocalizedString(@"TREMOR_TEST_INTRO_2_RIGHT_HAND_TEXT", nil);
            }
        }
        
        NSString *imageName = leftHand ? @"tremortestLeft" : @"tremortestRight";
        step.image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        step.shouldTintImages = YES;
        
        ORKStepArrayAddStep(steps, step);
    }

    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandInLap)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction2StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest3a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest3b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown1StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_IN_LAP_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestInLapStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac1_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac1_motion" frequency:100.0]];
            step.title = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.title;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction4StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest4a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest4b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown2StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_EXTEND_ARM_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestExtendArmStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac2_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac2_motion" frequency:100.0]];
            step.title = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.title;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.image = [UIImage imageNamed:@"tremortest4a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction5StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest5a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest5b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown3StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_BEND_ARM_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestBendArmStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac3_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac3_motion" frequency:100.0]];
            step.title = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.title;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeHandToNose)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction6StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest6a" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.auxiliaryImage = [UIImage imageNamed:@"tremortest6b" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
                step.auxiliaryImage = [step.auxiliaryImage ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown4StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TOUCH_NOSE_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestTouchNoseStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac4_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac4_motion" frequency:100.0]];
            step.title = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.title;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    if (!(activeTaskOptions & ORKTremorActiveTaskOptionExcludeQueenWave)) {
        if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
            NSString *stepIdentifier = [self stepIdentifier:ORKInstruction7StepIdentifier withHandIdentifier:handIdentifier];
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:stepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO", nil);
            step.text = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_INTRO_TEXT", nil);
            step.image = [UIImage imageNamed:@"tremortest7" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (leftHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO_LEFT", nil);
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            } else if (rightHand) {
                step.title = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INTRO_RIGHT", nil);
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *stepIdentifier = [self stepIdentifier:ORKCountdown5StepIdentifier withHandIdentifier:handIdentifier];
            ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:stepIdentifier];
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            NSString *titleFormat = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_TURN_WRIST_INSTRUCTION_%ld", nil);
            NSString *stepIdentifier = [self stepIdentifier:ORKTremorTestTurnWristStepIdentifier withHandIdentifier:handIdentifier];
            ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:stepIdentifier];
            step.recorderConfigurations = @[[[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:@"ac5_acc" frequency:100.0], [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"ac5_motion" frequency:100.0]];
            step.title = [NSString localizedStringWithFormat:titleFormat, (long)activeStepDuration];
            step.spokenInstruction = step.title;
            step.finishedSpokenInstruction = stepFinishedInstruction;
            step.stepDuration = activeStepDuration;
            step.shouldPlaySoundOnStart = YES;
            step.shouldVibrateOnStart = YES;
            step.shouldPlaySoundOnFinish = YES;
            step.shouldVibrateOnFinish = YES;
            step.shouldContinueOnFinish = NO;
            step.shouldStartTimerAutomatically = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // fix the spoken instruction on the last included step, depending on which hand we're on
    ORKActiveStep *lastStep = (ORKActiveStep *)[steps lastObject];
    if (lastHand) {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_COMPLETED_INSTRUCTION", nil);
    } else if (leftHand) {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_SWITCH_HANDS_RIGHT_INSTRUCTION", nil);
    } else {
        lastStep.finishedSpokenInstruction = ORKLocalizedString(@"TREMOR_TEST_ACTIVE_STEP_SWITCH_HANDS_LEFT_INSTRUCTION", nil);
    }
    
    return steps;
}

+ (ORKNavigableOrderedTask *)tremorTestTaskWithIdentifier:(NSString *)identifier
                                   intendedUseDescription:(nullable NSString *)intendedUseDescription
                                       activeStepDuration:(NSTimeInterval)activeStepDuration
                                        activeTaskOptions:(ORKTremorActiveTaskOption)activeTaskOptions
                                              handOptions:(ORKPredefinedTaskHandOption)handOptions
                                                  options:(ORKPredefinedTaskOption)options {
    
    NSMutableArray<__kindof ORKStep *> *steps = [NSMutableArray array];
    // coin toss for which hand first (in case we're doing both)
    BOOL leftFirstIfDoingBoth = arc4random_uniform(2) == 1;
    BOOL doingBoth = ((handOptions & ORKPredefinedTaskHandOptionLeft) && (handOptions & ORKPredefinedTaskHandOptionRight));
    BOOL firstIsLeft = (leftFirstIfDoingBoth && doingBoth) || (!doingBoth && (handOptions & ORKPredefinedTaskHandOptionLeft));
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TREMOR_TEST_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TREMOR_TEST_INTRO_1_DETAIL", nil);
            step.image = [UIImage imageNamed:@"tremortest1" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            if (firstIsLeft) {
                step.image = [step.image ork_flippedImage:UIImageOrientationUpMirrored];
            }
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    // Build the string for the detail texts
    NSArray<NSString *>*detailStringForNumberOfTasks = @[
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_1_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_2_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_3_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_4_TASK", nil),
                                                         ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_5_TASK", nil)
                                                         ];
    
    // start with the count for all the tasks, then subtract one for each excluded task flag
    static const NSInteger allTasks = 5; // hold in lap, outstretched arm, elbow bent, repeatedly touching nose, queen wave
    NSInteger actualTasksIndex = allTasks - 1;
    for (NSInteger i = 0; i < allTasks; ++i) {
        if (activeTaskOptions & (1 << i)) {
            actualTasksIndex--;
        }
    }
    
    NSString *detailFormat = doingBoth ? ORKLocalizedString(@"TREMOR_TEST_SKIP_QUESTION_BOTH_HANDS_%@", nil) : ORKLocalizedString(@"TREMOR_TEST_INTRO_2_DETAIL_DEFAULT_%@", nil);
    NSString *detailText = [NSString localizedStringWithFormat:detailFormat, detailStringForNumberOfTasks[actualTasksIndex]];
    
    if (doingBoth) {
        // If doing both hands then ask the user if they need to skip one of the hands
        ORKTextChoice *skipRight = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_RIGHT_HAND", nil)
                                                          value:ORKActiveTaskRightHandIdentifier];
        ORKTextChoice *skipLeft = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_LEFT_HAND", nil)
                                                          value:ORKActiveTaskLeftHandIdentifier];
        ORKTextChoice *skipNeither = [ORKTextChoice choiceWithText:ORKLocalizedString(@"TREMOR_SKIP_NEITHER", nil)
                                                             value:@""];

        ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                         textChoices:@[skipRight, skipLeft, skipNeither]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:ORKActiveTaskSkipHandStepIdentifier
                                                                      title:ORKLocalizedString(@"TREMOR_TEST_TITLE", nil)
                                                                       text:detailText
                                                                     answer:answerFormat];
        step.optional = NO;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    // right or most-affected hand
    NSArray<__kindof ORKStep *> *rightSteps = nil;
    if (handOptions == ORKPredefinedTaskHandOptionUnspecified) {
        rightSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                    activeStepDuration:activeStepDuration
                                                     activeTaskOptions:activeTaskOptions
                                                              lastHand:YES
                                                              leftHand:NO
                                                        handIdentifier:ORKActiveTaskMostAffectedHandIdentifier
                                                       introDetailText:detailText
                                                               options:options];
    } else if (handOptions & ORKPredefinedTaskHandOptionRight) {
        rightSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                    activeStepDuration:activeStepDuration
                                                     activeTaskOptions:activeTaskOptions
                                                              lastHand:firstIsLeft
                                                              leftHand:NO
                                                        handIdentifier:ORKActiveTaskRightHandIdentifier
                                                       introDetailText:nil
                                                               options:options];
    }
    
    // left hand
    NSArray<__kindof ORKStep *> *leftSteps = nil;
    if (handOptions & ORKPredefinedTaskHandOptionLeft) {
        leftSteps = [self stepsForOneHandTremorTestTaskWithIdentifier:identifier
                                                   activeStepDuration:activeStepDuration
                                                    activeTaskOptions:activeTaskOptions
                                                             lastHand:!firstIsLeft || !(handOptions & ORKPredefinedTaskHandOptionRight)
                                                             leftHand:YES
                                                       handIdentifier:ORKActiveTaskLeftHandIdentifier
                                                      introDetailText:nil
                                                              options:options];
    }
    
    if (firstIsLeft && leftSteps != nil) {
        [steps addObjectsFromArray:leftSteps];
    }
    
    if (rightSteps != nil) {
        [steps addObjectsFromArray:rightSteps];
    }
    
    if (!firstIsLeft && leftSteps != nil) {
        [steps addObjectsFromArray:leftSteps];
    }
    
    BOOL hasCompletionStep = NO;
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        hasCompletionStep = YES;
        ORKCompletionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    if (doingBoth) {
        // Setup rules for skipping all the steps in either the left or right hand if called upon to do so.
        ORKResultSelector *resultSelector = [ORKResultSelector selectorWithStepIdentifier:ORKActiveTaskSkipHandStepIdentifier
                                                                         resultIdentifier:ORKActiveTaskSkipHandStepIdentifier];
        NSPredicate *predicateRight = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:ORKActiveTaskRightHandIdentifier];
        NSPredicate *predicateLeft = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:ORKActiveTaskLeftHandIdentifier];
        
        // Setup rule for skipping first hand
        NSString *secondHandIdentifier = firstIsLeft ? [[rightSteps firstObject] identifier] : [[leftSteps firstObject] identifier];
        NSPredicate *firstPredicate = firstIsLeft ? predicateLeft : predicateRight;
        ORKStepNavigationRule *skipFirst = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[firstPredicate]
                                                                                 destinationStepIdentifiers:@[secondHandIdentifier]];
        [task setNavigationRule:skipFirst forTriggerStepIdentifier:ORKActiveTaskSkipHandStepIdentifier];
        
        // Setup rule for skipping the second hand
        NSString *triggerIdentifier = firstIsLeft ? [[leftSteps lastObject] identifier] : [[rightSteps lastObject] identifier];
        NSString *conclusionIdentifier = hasCompletionStep ? [[steps lastObject] identifier] : ORKNullStepIdentifier;
        NSPredicate *secondPredicate = firstIsLeft ? predicateRight : predicateLeft;
        ORKStepNavigationRule *skipSecond = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[secondPredicate]
                                                                                  destinationStepIdentifiers:@[conclusionIdentifier]];
        [task setNavigationRule:skipSecond forTriggerStepIdentifier:triggerIdentifier];
        
        // Setup step modifier to change the finished spoken step if skipping the second hand
        NSString *key = NSStringFromSelector(@selector(finishedSpokenInstruction));
        NSString *value = ORKLocalizedString(@"TREMOR_TEST_COMPLETED_INSTRUCTION", nil);
        ORKStepModifier *stepModifier = [[ORKKeyValueStepModifier alloc] initWithResultPredicate:secondPredicate
                                                                                     keyValueMap:@{key: value}];
        [task setStepModifier:stepModifier forStepIdentifier:triggerIdentifier];
    }
    
    return task;
}

+ (ORKOrderedTask *)trailmakingTaskWithIdentifier:(NSString *)identifier
                           intendedUseDescription:(nullable NSString *)intendedUseDescription
                           trailmakingInstruction:(nullable NSString *)trailmakingInstruction
                                        trailType:(ORKTrailMakingTypeIdentifier)trailType
                                          options:(ORKPredefinedTaskOption)options {
    
    NSArray *supportedTypes = @[ORKTrailMakingTypeIdentifierA, ORKTrailMakingTypeIdentifierB];
    NSAssert1([supportedTypes containsObject:trailType], @"Trail type %@ is not supported.", trailType);
    
    NSMutableArray<__kindof ORKStep *> *steps = [NSMutableArray array];
    
    if (!(options & ORKPredefinedTaskOptionExcludeInstructions)) {
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction0StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            step.text = intendedUseDescription;
            step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE", nil);
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction1StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            if ([trailType isEqualToString:ORKTrailMakingTypeIdentifierA]) {
                step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE2_A", nil);
            } else {
                step.detailText = ORKLocalizedString(@"TRAILMAKING_INTENDED_USE2_B", nil);
            }
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
        
        
        {
            ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:ORKInstruction2StepIdentifier];
            step.title = ORKLocalizedString(@"TRAILMAKING_TASK_TITLE", nil);
            step.text = trailmakingInstruction ? : ORKLocalizedString(@"TRAILMAKING_INTRO_TEXT",nil);
            step.detailText = ORKLocalizedString(@"TRAILMAKING_CALL_TO_ACTION", nil);
            step.image = [UIImage imageNamed:@"trailmaking" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
            step.shouldTintImages = YES;
            
            ORKStepArrayAddStep(steps, step);
        }
    }
    
    {
        ORKCountdownStep *step = [[ORKCountdownStep alloc] initWithIdentifier:ORKCountdownStepIdentifier];
        step.stepDuration = 3.0;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    {
        ORKTrailmakingStep *step = [[ORKTrailmakingStep alloc] initWithIdentifier:ORKTrailmakingStepIdentifier];
        step.trailType = trailType;
        
        ORKStepArrayAddStep(steps, step);
    }
    
    if (!(options & ORKPredefinedTaskOptionExcludeConclusion)) {
        ORKInstructionStep *step = [self makeCompletionStep];
        
        ORKStepArrayAddStep(steps, step);
    }

    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    return task;
}

@end
