//
/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import <Foundation/Foundation.h>

//! Project version number for ResearchKitActiveTask.
FOUNDATION_EXPORT double ResearchKitActiveTaskVersionNumber;

//! Project version string for ResearchKitActiveTask.
FOUNDATION_EXPORT const unsigned char ResearchKitActiveTaskVersionString[];

#import <ResearchKitActiveTask/ORK3DModelManager.h>
#import <ResearchKitActiveTask/ORK3DModelStep.h>
#import <ResearchKitActiveTask/ORK3DModelStepViewController.h>
#import <ResearchKitActiveTask/ORKAccuracyStroopResult.h>
#import <ResearchKitActiveTask/ORKAccuracyStroopStep.h>
#import <ResearchKitActiveTask/ORKAccuracyStroopStepViewController.h>
#import <ResearchKitActiveTask/ORKActiveStepCustomView.h>
#import <ResearchKitActiveTask/ORKActiveStepViewController.h>
#import <ResearchKitActiveTask/ORKActiveTaskResult.h>
#import <ResearchKitActiveTask/ORKAmslerGridResult.h>
#import <ResearchKitActiveTask/ORKAmslerGridStepViewController.h>
#import <ResearchKitActiveTask/ORKAudioFitnessStepViewController.h>
#import <ResearchKitActiveTask/ORKAudioStepViewController.h>
#import <ResearchKitActiveTask/ORKAudiometryProtocol.h>
#import <ResearchKitActiveTask/ORKAudiometryStimulus.h>
#import <ResearchKitActiveTask/ORKCountdownStepViewController.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryOnboardingStepViewController.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryResult.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryStep.h>
#import <ResearchKitActiveTask/ORKdBHLToneAudiometryStepViewController.h>
#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterResult.h>
#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterStep.h>
#import <ResearchKitActiveTask/ORKEnvironmentSPLMeterStepViewController.h>
#import <ResearchKitActiveTask/ORKFitnessStepViewController.h>
#import <ResearchKitActiveTask/ORKFrontFacingCameraStepViewController.h>
#import <ResearchKitActiveTask/ORKHolePegTestPlaceStepViewController.h>
#import <ResearchKitActiveTask/ORKHolePegTestRemoveStepViewController.h>
#import <ResearchKitActiveTask/ORKHolePegTestResult.h>
#import <ResearchKitActiveTask/ORKNormalizedReactionTimeStep.h>
#import <ResearchKitActiveTask/ORKOrderedTask+ORKPredefinedActiveTask.h>
#import <ResearchKitActiveTask/ORKPSATResult.h>
#import <ResearchKitActiveTask/ORKPSATStepViewController.h>
#import <ResearchKitActiveTask/ORKRangeOfMotionResult.h>
#import <ResearchKitActiveTask/ORKRangeOfMotionStepViewController.h>
#import <ResearchKitActiveTask/ORKReactionTimeResult.h>
#import <ResearchKitActiveTask/ORKReactionTimeViewController.h>
#import <ResearchKitActiveTask/ORKShoulderRangeOfMotionStepViewController.h>
#import <ResearchKitActiveTask/ORKSpatialSpanMemoryResult.h>
#import <ResearchKitActiveTask/ORKSpatialSpanMemoryStepViewController.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseResult.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStep.h>
#import <ResearchKitActiveTask/ORKSpeechInNoiseStepViewController.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionResult.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionStep.h>
#import <ResearchKitActiveTask/ORKSpeechRecognitionStepViewController.h>
#import <ResearchKitActiveTask/ORKStroopResult.h>
#import <ResearchKitActiveTask/ORKStroopStepViewController.h>
#import <ResearchKitActiveTask/ORKTappingIntervalResult.h>
#import <ResearchKitActiveTask/ORKTappingIntervalStepViewController.h>
#import <ResearchKitActiveTask/ORKTimedWalkResult.h>
#import <ResearchKitActiveTask/ORKTimedWalkStep.h>
#import <ResearchKitActiveTask/ORKTimedWalkStepViewController.h>
#import <ResearchKitActiveTask/ORKToneAudiometryResult.h>
#import <ResearchKitActiveTask/ORKToneAudiometryStepViewController.h>
#import <ResearchKitActiveTask/ORKTouchAbilityGestureRecoginzerEvent.h>
#import <ResearchKitActiveTask/ORKTouchAbilityLongPressTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilityPinchTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilityRotationTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilityScrollTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilitySwipeTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilityTapTrial.h>
#import <ResearchKitActiveTask/ORKTouchAbilityTouch.h>
#import <ResearchKitActiveTask/ORKTouchAbilityTrack.h>
#import <ResearchKitActiveTask/ORKTouchAbilityTrial.h>
#import <ResearchKitActiveTask/ORKTouchAnywhereStep.h>
#import <ResearchKitActiveTask/ORKTouchAnywhereStepViewController.h>
#import <ResearchKitActiveTask/ORKTowerOfHanoiResult.h>
#import <ResearchKitActiveTask/ORKTowerOfHanoiStepViewController.h>
#import <ResearchKitActiveTask/ORKTrailmakingResult.h>
#import <ResearchKitActiveTask/ORKTrailmakingStepViewController.h>
#import <ResearchKitActiveTask/ORKUSDZModelManager.h>
#import <ResearchKitActiveTask/ORKUSDZModelManagerResult.h>
#import <ResearchKitActiveTask/ORKWalkingTaskStepViewController.h>
