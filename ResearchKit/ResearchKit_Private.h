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


#import <ResearchKit/ResearchKit.h>

#import <ResearchKit/ORKHelpers_Private.h>

// Active step support
#import <ResearchKit/ORKDataLogger.h>
#import <ResearchKit/ORKErrors.h>

#import <ResearchKit/ORKAnswerFormat_Private.h>
#import <ResearchKit/ORKConsentSection_Private.h>
#import <ResearchKit/ORKOrderedTask_Private.h>
#import <ResearchKit/ORKPageStep_Private.h>
#import <ResearchKit/ORKRecorder_Private.h>
#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKStepNavigationRule_Private.h>
#import <ResearchKit/ORKAudioLevelNavigationRule.h>

#import <ResearchKit/ORKAudioStep.h>
#import <ResearchKit/ORKCompletionStep.h>
#import <ResearchKit/ORKCountdownStep.h>
#import <ResearchKit/ORKFitnessStep.h>
#import <ResearchKit/ORKHolePegTestPlaceStep.h>
#import <ResearchKit/ORKHolePegTestRemoveStep.h>
#import <ResearchKit/ORKPSATStep.h>
#import <ResearchKit/ORKRangeOfMotionStep.h>
#import <ResearchKit/ORKReactionTimeStep.h>
#import <ResearchKit/ORKShoulderRangeOfMotionStep.h>
#import <ResearchKit/ORKSpatialSpanMemoryStep.h>
#import <ResearchKit/ORKStroopStep.h>
#import <ResearchKit/ORKTappingIntervalStep.h>
#import <ResearchKit/ORKTimedWalkStep.h>
#import <ResearchKit/ORKToneAudiometryPracticeStep.h>
#import <ResearchKit/ORKToneAudiometryStep.h>
#import <ResearchKit/ORKTowerOfHanoiStep.h>
#import <ResearchKit/ORKTrailmakingStep.h>
#import <ResearchKit/ORKWalkingTaskStep.h>

#import <ResearchKit/ORKTaskViewController_Private.h>
#import <ResearchKit/ORKQuestionStepViewController_Private.h>

#import <ResearchKit/ORKAudioStepViewController.h>
#import <ResearchKit/ORKConsentReviewStepViewController.h>
#import <ResearchKit/ORKConsentSharingStepViewController.h>
#import <ResearchKit/ORKCountdownStepViewController.h>
#import <ResearchKit/ORKFitnessStepViewController.h>
#import <ResearchKit/ORKHolePegTestPlaceStepViewController.h>
#import <ResearchKit/ORKHolePegTestRemoveStepViewController.h>
#import <ResearchKit/ORKImageCaptureStepViewController.h>
#import <ResearchKit/ORKPasscodeStepViewController.h>
#import <ResearchKit/ORKPSATStepViewController.h>
#import <ResearchKit/ORKQuestionStepViewController.h>
#import <ResearchKit/ORKReviewStepViewController.h>
#import <ResearchKit/ORKSignatureStepViewController.h>
#import <ResearchKit/ORKSpatialSpanMemoryStepViewController.h>
#import <ResearchKit/ORKStroopStepViewController.h>
#import <ResearchKit/ORKTappingIntervalStepViewController.h>
#import <ResearchKit/ORKToneAudiometryPracticeStepViewController.h>
#import <ResearchKit/ORKToneAudiometryStepViewController.h>
#import <ResearchKit/ORKTimedWalkStepViewController.h>
#import <ResearchKit/ORKVisualConsentStepViewController.h>
#import <ResearchKit/ORKWalkingTaskStepViewController.h>
#import <ResearchKit/ORKVideoInstructionStepViewController.h>

#import <ResearchKit/ORKAccelerometerRecorder.h>
#import <ResearchKit/ORKAudioRecorder.h>
#import <ResearchKit/ORKDeviceMotionRecorder.h>
#import <ResearchKit/ORKHealthQuantityTypeRecorder.h>
#import <ResearchKit/ORKLocationRecorder.h>
#import <ResearchKit/ORKPedometerRecorder.h>
#import <ResearchKit/ORKTouchRecorder.h>

// For custom steps
#import <ResearchKit/ORKCustomStepView.h>
