/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import <ResearchKit/ResearchKit_Private.h>


NS_ASSUME_NONNULL_BEGIN


@class ORKCompletionStep, ORKStep;


FOUNDATION_EXPORT NSString *const ORKInstruction0StepIdentifier;
FOUNDATION_EXPORT NSString *const ORKInstruction1StepIdentifier;
FOUNDATION_EXPORT NSString *const ORKCountdownStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKAudioStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKAudioTooLoudStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKTappingStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKConclusionStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKFitnessWalkStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKFitnessRestStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKShortWalkOutboundStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKShortWalkReturnStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKShortWalkRestStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKSpatialSpanMemoryStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKToneAudiometryPracticeStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKToneAudiometryStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKReactionTimeStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKHolePegTestDominantPlaceStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKHolePegTestDominantRemoveStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKHolePegTestNonDominantPlaceStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKHolePegTestNonDominantRemoveStepIdentifier;
FOUNDATION_EXPORT NSString *const ORKAudioRecorderIdentifier;
FOUNDATION_EXPORT NSString *const ORKAccelerometerRecorderIdentifier;
FOUNDATION_EXPORT NSString *const ORKPedometerRecorderIdentifier;
FOUNDATION_EXPORT NSString *const ORKDeviceMotionRecorderIdentifier;
FOUNDATION_EXPORT NSString *const ORKLocationRecorderIdentifier;
FOUNDATION_EXPORT NSString *const ORKHeartRateRecorderIdentifier;

FOUNDATION_EXPORT void ORKStepArrayAddStep(NSMutableArray *array, ORKStep *step);

@interface ORKOrderedTask ()

+ (ORKCompletionStep *)makeCompletionStep;

@end

NS_ASSUME_NONNULL_END
