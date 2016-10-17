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

#import "ORKHelpers_Private.h"

// Active step support
#import "ORKDataLogger.h"
#import "ORKErrors.h"

#import "ORKAnswerFormat_Private.h"
#import "ORKConsentSection_Private.h"
#import "ORKOrderedTask_Private.h"
#import "ORKRecorder_Private.h"
#import "ORKResult_Private.h"
#import "ORKStepNavigationRule_Private.h"
#import "ORKAudioLevelNavigationRule.h"

#import "ORKAudioStep.h"
#import "ORKCompletionStep.h"
#import "ORKCountdownStep.h"
#import "ORKFitnessStep.h"
#import "ORKHolePegTestPlaceStep.h"
#import "ORKHolePegTestRemoveStep.h"
#import "ORKPSATStep.h"
#import "ORKReactionTimeStep.h"
#import "ORKSpatialSpanMemoryStep.h"
#import "ORKTappingIntervalStep.h"
#import "ORKTimedWalkStep.h"
#import "ORKToneAudiometryPracticeStep.h"
#import "ORKToneAudiometryStep.h"
#import "ORKTowerOfHanoiStep.h"
#import "ORKWalkingTaskStep.h"

#import "ORKTaskViewController_Private.h"
#import "ORKQuestionStepViewController_Private.h"

#import "ORKAudioStepViewController.h"
#import "ORKConsentReviewStepViewController.h"
#import "ORKCountdownStepViewController.h"
#import "ORKFitnessStepViewController.h"
#import "ORKHolePegTestPlaceStepViewController.h"
#import "ORKHolePegTestRemoveStepViewController.h"
#import "ORKImageCaptureStepViewController.h"
#import "ORKPSATStepViewController.h"
#import "ORKQuestionStepViewController.h"
#import "ORKReviewStepViewController.h"
#import "ORKSpatialSpanMemoryStepViewController.h"
#import "ORKTappingIntervalStepViewController.h"
#import "ORKToneAudiometryPracticeStepViewController.h"
#import "ORKToneAudiometryStepViewController.h"
#import "ORKTimedWalkStepViewController.h"
#import "ORKVisualConsentStepViewController.h"
#import "ORKWalkingTaskStepViewController.h"

#import "ORKAccelerometerRecorder.h"
#import "ORKAudioRecorder.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKHealthQuantityTypeRecorder.h"
#import "ORKLocationRecorder.h"
#import "ORKPedometerRecorder.h"
#import "ORKTouchRecorder.h"

// For custom steps
#import "ORKCustomStepView.h"
