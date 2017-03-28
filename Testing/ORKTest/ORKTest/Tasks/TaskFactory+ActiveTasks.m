 //
//  TaskFactory+ActiveTasks.m
//  ORKTest
//
//  Created by Ricardo Sanchez-Saez on 3/28/17.
//  Copyright © 2017 ResearchKit. All rights reserved.
//

#import "TaskFactory+ActiveTasks.h"

@import ResearchKit;


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
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
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
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001d"];
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
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001e"];
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
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001a"];
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
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001c"];
        step.title = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"aid_001c.deviceMotion" frequency:100.0]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ActiveStepTaskIdentifier steps:steps];
    return task;
}

- (id<ORKTask>)makeAudioTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask audioTaskWithIdentifier:AudioTaskIdentifier
                            intendedUseDescription:nil
                                 speechInstruction:nil
                            shortSpeechInstruction:nil
                                          duration:10
                                 recordingSettings:nil
                                   checkAudioLevel:YES
                                           options:(ORKPredefinedTaskOption)0];
}

- (id<ORKTask>)makeFitnessTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask fitnessCheckTaskWithIdentifier:FitnessTaskIdentifier
                                   intendedUseDescription:nil
                                             walkDuration:360
                                             restDuration:180
                                                  options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeGaitTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask shortWalkTaskWithIdentifier:GaitTaskIdentifier
                                intendedUseDescription:nil
                                   numberOfStepsPerLeg:20
                                          restDuration:30
                                               options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeHandTremorTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask tremorTestTaskWithIdentifier:HandTremorTaskIdentifier
                                 intendedUseDescription:nil
                                     activeStepDuration:10
                                      activeTaskOptions:
            ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight |
            ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent |
            ORKTremorActiveTaskOptionExcludeHandToNose
                                            handOptions:ORKPredefinedTaskHandOptionBoth
                                                options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeHandRightTremorTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask tremorTestTaskWithIdentifier:HandRightTremorTaskIdentifier
                                 intendedUseDescription:nil
                                     activeStepDuration:10
                                      activeTaskOptions:0
                                            handOptions:ORKPredefinedTaskHandOptionRight
                                                options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeHolePegTestTaskWithIdentifier:(NSString *)identifier {
    return [ORKNavigableOrderedTask holePegTestTaskWithIdentifier:HolePegTestTaskIdentifier
                                           intendedUseDescription:nil
                                                     dominantHand:ORKBodySagittalRight
                                                     numberOfPegs:9
                                                        threshold:0.2
                                                          rotated:NO
                                                        timeLimit:300.0
                                                          options:ORKPredefinedTaskOptionNone];
}


- (id<ORKTask>)makeMemoryGameTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:MemoryGameTaskIdentifier
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
}

- (id<ORKTask>)makePsatTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask PSATTaskWithIdentifier:PsatTaskIdentifier
                           intendedUseDescription:nil
                                 presentationMode:(ORKPSATPresentationModeAuditory | ORKPSATPresentationModeVisual)
                            interStimulusInterval:3.0
                                 stimulusDuration:1.0
                                     seriesLength:60
                                          options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeReactionTimeTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask reactionTimeTaskWithIdentifier:ReactionTimeTaskIdentifier
                                   intendedUseDescription:nil
                                  maximumStimulusInterval:8
                                  minimumStimulusInterval:4
                                    thresholdAcceleration:0.5
                                         numberOfAttempts:3
                                                  timeout:10
                                             successSound:0
                                             timeoutSound:0
                                             failureSound:0
                                                  options:0];
}

- (id<ORKTask>)makeTimedWalkTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask timedWalkTaskWithIdentifier:TimedWalkTaskIdentifier
                                intendedUseDescription:nil
                                      distanceInMeters:100
                                             timeLimit:180
                                   turnAroundTimeLimit:60
                            includeAssistiveDeviceForm:YES
                                               options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeToneAudiometryTaskIdentifier:(NSString *)identifier {
    return [ORKOrderedTask toneAudiometryTaskWithIdentifier:ToneAudiometryTaskIdentifier
                                     intendedUseDescription:nil
                                          speechInstruction:nil
                                     shortSpeechInstruction:nil
                                               toneDuration:20
                                                    options:(ORKPredefinedTaskOption)0];
}

- (id<ORKTask>)makeTowerOfHanoiTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask towerOfHanoiTaskWithIdentifier:TowerOfHanoiTaskIdentifier
                                   intendedUseDescription:nil
                                            numberOfDisks:5
                                                  options:0];
}


- (id<ORKTask>)makeTrailMakingTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask trailmakingTaskWithIdentifier:TrailMakingTaskIdentifier
                                  intendedUseDescription:nil
                                  trailmakingInstruction:nil
                                               trailType:ORKTrailMakingTypeIdentifierA
                                                 options:ORKPredefinedTaskOptionNone];
}

- (id<ORKTask>)makeTwoFingerTapTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:TwoFingerTapTaskIdentifier
                                               intendedUseDescription:nil
                                                             duration:20.0
                                                          handOptions:ORKPredefinedTaskHandOptionBoth
                                                              options:(ORKPredefinedTaskOption)0];
}

- (id<ORKTask>)makeWalkAndTurnTaskWithIdentifier:(NSString *)identifier {
    return [ORKOrderedTask walkBackAndForthTaskWithIdentifier:WalkAndTurnTaskIdentifier
                                       intendedUseDescription:nil
                                                 walkDuration:30
                                                 restDuration:30
                                                      options:ORKPredefinedTaskOptionNone];
}

@end
