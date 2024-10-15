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

#import "ResearchKitActiveTask.h"
#import "ResearchKitActiveTask_Private.h"

@implementation ORK3DModelStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORK3DModelStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKAccuracyStroopStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKAccuracyStroopStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKActiveStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKActiveStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKAmslerGridStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKAmslerGridStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKAudioFitnessStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKAudioFitnessStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKAudioStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKAudioStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKCountdownStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKCountdownStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKEnvironmentSPLMeterStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKEnvironmentSPLMeterStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKFitnessStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFitnessStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKFrontFacingCameraStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKFrontFacingCameraStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKHolePegTestPlaceStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKHolePegTestPlaceStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKHolePegTestRemoveStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKHolePegTestRemoveStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKPSATStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKPSATStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKRangeOfMotionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKRangeOfMotionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKReactionTimeStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKReactionTimeViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKShoulderRangeOfMotionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKShoulderRangeOfMotionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSpatialSpanMemoryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKSpatialSpanMemoryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSpeechInNoiseStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKSpeechInNoiseStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKSpeechRecognitionStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKSpeechRecognitionStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKStroopStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKStroopStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTappingIntervalStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTappingIntervalStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTimedWalkStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTimedWalkStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKToneAudiometryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKToneAudiometryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTouchAnywhereStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTouchAnywhereStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTowerOfHanoiStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTowerOfHanoiViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKTrailmakingStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKTrailmakingStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKWalkingTaskStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKWalkingTaskStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKdBHLToneAudiometryOnboardingStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKdBHLToneAudiometryOnboardingStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKdBHLToneAudiometryStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKdBHLToneAudiometryStepViewController alloc] initWithStep:self result:result];
}

@end

@implementation ORKNormalizedReactionTimeStep (ViewControllerProviding)

- (ORKStepViewController *)makeViewControllerWithResult:(ORKResult *)result {
    return [[ORKNormalizedReactionTimeViewController alloc] initWithStep:self result:result];
}

@end

