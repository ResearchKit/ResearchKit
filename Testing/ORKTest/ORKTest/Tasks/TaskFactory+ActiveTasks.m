/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015-2017, Ricardo Sanchez-Saez.
 Copyright (c) 2016-2017, Sage Bionetworks
 
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


#import "TaskFactory+ActiveTasks.h"

@import ResearchKit.Private;


@implementation TaskFactory (ActiveTasks)

/*
 This task demonstrates direct use of active steps, which is not particularly
 well-supported by the framework. The intended use of `ORKActiveStep` is as a
 base class for creating new types of active step, with matching view
 controllers appropriate to the particular task that uses them.
 
 Nonetheless, this functions as a test-bed for basic active task functonality.
 */
- (id<ORKTask>)makeActiveStepTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        /*
         Example of a fully-fledged instruction step.
         The text of this step is not appropriate to the rest of the task, but
         is helpful for verifying layout.
         */
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
        step.title = @"Demo Study";
        step.text = @"This 12-step walkthrough will explain the study and the impact it will have on your life.";
        step.detailText = @"You must complete the walkthough to participate in the study.";
        [steps addObject:step];
    }
    
    {
        /*
         Audio-recording active step, configured directly using `ORKActiveStep`.
         
         Not a recommended way of doing audio recording with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"step2"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:@"aid_001d.audio" recorderSettings:@{}]];
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        /*
         Audio-recording active step with lossless audio, configured directly
         using `ORKActiveStep`.
         
         Not a recommended way of doing audio recording with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"step3"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording lossless audio";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc]
                                         initWithIdentifier:@"aid_001e.audio" recorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                 AVNumberOfChannelsKey : @(2),
                                                                                                 AVSampleRateKey: @(44100.0)
                                                                                                 }]];
        [steps addObject:step];
    }
    
    {
        /*
         Touch recorder active step. This should record touches on the primary
         view for a 30 second period.
         
         Not a recommended way of collecting touch data with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"step4"];
        step.title = @"Touch";
        step.text = @"An active test, touch collection";
        step.shouldStartTimerAutomatically = NO;
        step.stepDuration = 30.0;
        step.spokenInstruction = @"An active test, touch collection";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKTouchRecorderConfiguration alloc] initWithIdentifier:@"aid_001a.touch"]];
        [steps addObject:step];
    }
    
    {
        /*
         Test for device motion recorder directly on an active step.
         
         Not a recommended way of customizing active steps with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"step5"];
        step.title = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"aid_001c.deviceMotion" frequency:100.0]];
        
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeAudioTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask audioTaskWithIdentifier:identifier
                                            intendedUseDescription:nil
                                                 speechInstruction:nil
                                            shortSpeechInstruction:nil
                                                          duration:10
                                                 recordingSettings:nil
                                                   checkAudioLevel:YES
                                                           options:(ORKPredefinedTaskOption)0];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeFitnessTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask fitnessCheckTaskWithIdentifier:identifier
                                                   intendedUseDescription:nil
                                                             walkDuration:360
                                                             restDuration:180
                                                                  options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeGaitTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask shortWalkTaskWithIdentifier:identifier
                                                intendedUseDescription:nil
                                                   numberOfStepsPerLeg:20
                                                          restDuration:30
                                                               options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeHandTremorTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask tremorTestTaskWithIdentifier:identifier
                                                 intendedUseDescription:nil
                                                     activeStepDuration:10
                                                      activeTaskOptions:
                            ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight |
                            ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent |
                            ORKTremorActiveTaskOptionExcludeHandToNose
                                                            handOptions:ORKPredefinedTaskHandOptionBoth
                                                                options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeHandRightTremorTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask tremorTestTaskWithIdentifier:identifier
                                                 intendedUseDescription:nil
                                                     activeStepDuration:10
                                                      activeTaskOptions:0
                                                            handOptions:ORKPredefinedTaskHandOptionRight
                                                                options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeHolePegTestTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKNavigableOrderedTask holePegTestTaskWithIdentifier:identifier
                                                           intendedUseDescription:nil
                                                                     dominantHand:ORKBodySagittalRight
                                                                     numberOfPegs:9
                                                                        threshold:0.2
                                                                          rotated:NO
                                                                        timeLimit:300.0
                                                                          options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}


- (id<ORKTask>)makeMemoryGameTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:identifier
                                                        intendedUseDescription:nil
                                                                   initialSpan:3
                                                                   minimumSpan:2
                                                                   maximumSpan:15
                                                                     playSpeed:1
                                                                  maximumTests:5
                                                    maximumConsecutiveFailures:3
                                                             customTargetImage:nil
                                                        customTargetPluralName:nil
                                                               requireReversal:NO
                                                                       options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makePsatTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask PSATTaskWithIdentifier:identifier
                                           intendedUseDescription:nil
                                                 presentationMode:(ORKPSATPresentationModeAuditory | ORKPSATPresentationModeVisual)
                                            interStimulusInterval:3.0
                                                 stimulusDuration:1.0
                                                     seriesLength:60
                                                          options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeReactionTimeTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask reactionTimeTaskWithIdentifier:identifier
                                                   intendedUseDescription:nil
                                                  maximumStimulusInterval:8
                                                  minimumStimulusInterval:4
                                                    thresholdAcceleration:0.5
                                                         numberOfAttempts:3
                                                                  timeout:10
                                                             successSound:0
                                                             timeoutSound:0
                                                             failureSound:0
                                                                  options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeStroopTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask stroopTaskWithIdentifier:identifier
                             intendedUseDescription:nil
                                   numberOfAttempts:15
                                            options:0];
}

- (id<ORKTask>)makeTimedWalkTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask timedWalkTaskWithIdentifier:identifier
                                                intendedUseDescription:nil
                                                      distanceInMeters:100
                                                             timeLimit:180
                                                   turnAroundTimeLimit:60
                                            includeAssistiveDeviceForm:YES
                                                               options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeToneAudiometryTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask toneAudiometryTaskWithIdentifier:identifier
                                                     intendedUseDescription:nil
                                                          speechInstruction:nil
                                                     shortSpeechInstruction:nil
                                                               toneDuration:20
                                                                    options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeTowerOfHanoiTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask towerOfHanoiTaskWithIdentifier:identifier
                                                   intendedUseDescription:nil
                                                            numberOfDisks:5
                                                                  options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}


- (id<ORKTask>)makeTrailMakingTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask trailmakingTaskWithIdentifier:identifier
                                                  intendedUseDescription:nil
                                                  trailmakingInstruction:nil
                                                               trailType:ORKTrailMakingTypeIdentifierA
                                                                 options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeTwoFingerTappingTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:identifier
                                                               intendedUseDescription:nil
                                                                             duration:20.0
                                                                          handOptions:ORKPredefinedTaskHandOptionBoth
                                                                              options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

- (id<ORKTask>)makeWalkAndTurnTaskWithIdentifier:(NSString *)identifier {
    ORKOrderedTask *task = [ORKOrderedTask walkBackAndForthTaskWithIdentifier:identifier
                                                       intendedUseDescription:nil
                                                                 walkDuration:30
                                                                 restDuration:30
                                                                      options:ORKPredefinedTaskOptionNone];
    task.hidesLearnMoreButtonOnInstructionStep = YES;
    return task;
}

@end
