/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
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


@import UIKit;


/*  NOTE: The task creation utility funtions are alphabetically sorted within their
 *        their own sections. Make sure you insert your code in the appropriate place
 *        so all the sections remain alphabetically sorted
 */

#define DefineStringKey(x) static NSString *const x = @#x

/// Task Identifiers
// Active Taks
DefineStringKey(ActiveStepTaskIdentifier);
DefineStringKey(AudioTaskIdentifier);
DefineStringKey(FitnessTaskIdentifier);
DefineStringKey(GaitTaskIdentifier);
DefineStringKey(HandTremorTaskIdentifier);
DefineStringKey(HandRightTremorTaskIdentifier);
DefineStringKey(HolePegTestTaskIdentifier);
DefineStringKey(MemoryGameTaskIdentifier);
DefineStringKey(PsatTaskIdentifier);
DefineStringKey(ReactionTimeTaskIdentifier);
DefineStringKey(TimedWalkTaskIdentifier);
DefineStringKey(ToneAudiometryTaskIdentifier);
DefineStringKey(TowerOfHanoiTaskIdentifier);
DefineStringKey(TrailMakingTaskIdentifier);
DefineStringKey(TwoFingerTapTaskIdentifier);
DefineStringKey(WalkAndTurnTaskIdentifier);

// Forms
DefineStringKey(ConfirmationFormItemTaskIdentifier);
DefineStringKey(MiniFormTaskIdentifier);
DefineStringKey(OptionalFormTaskIdentifier);

// Onboarding
DefineStringKey(ConsentTaskIdentifier);
DefineStringKey(ConsentReviewTaskIdentifier);
DefineStringKey(EligibilityFormTaskIdentifier);
DefineStringKey(EligibilitySurveyTaskIdentifier);
DefineStringKey(LoginTaskIdentifier);
DefineStringKey(RegistrationTaskIdentifier);
DefineStringKey(VerificationTaskIdentifier);

// Passcode Management
DefineStringKey(CreatePasscodeTaskIdentifier);

// Question Steps
DefineStringKey(DatePickersTaskIdentifier);
DefineStringKey(ImageCaptureTaskIdentifier);
DefineStringKey(ImageChoiceTaskIdentifier);
DefineStringKey(LocationTaskIdentifier);
DefineStringKey(ScaleTaskIdentifier);
DefineStringKey(ScaleColorGradientTaskIdentifier);
DefineStringKey(SelectionSurveyTaskIdentifier);
DefineStringKey(VideoCaptureTaskIdentifier);

// Task Customization
DefineStringKey(CustomViewControllerTaskIdentifier);
DefineStringKey(CustomNavigationItemTaskIdentifier);
DefineStringKey(DynamicTaskIdentifier);
DefineStringKey(InterruptibleTaskIdentifier);
DefineStringKey(NavigableOrderedTaskIdentifier);
DefineStringKey(NavigableOrderedLoopTaskIdentifier);
DefineStringKey(StepWillDisappearTaskIdentifier);

// Task Review
DefineStringKey(EmbeddedReviewTaskIdentifier);
DefineStringKey(StandaloneReviewTaskIdentifier);

// Utility Steps
DefineStringKey(AuxiliaryImageStepTaskIdentifier);
DefineStringKey(CompletionStepTaskIdentifier);
DefineStringKey(FootnoteStepTaskIdentifier);
DefineStringKey(IconImageStepTaskIdentifier);
DefineStringKey(PageStepTaskIdentifier);
DefineStringKey(PredicateTestsTaskIdentifier);
DefineStringKey(SignatureStepTaskIdentifier);
DefineStringKey(TableStepTaskIdentifier);
DefineStringKey(VideoInstructionStepTaskIdentifier);
DefineStringKey(WaitStepTaskIdentifier);

/// Non-Task Identifiers 
// Steps
DefineStringKey(StepWillDisappearFirstStepIdentifier);
DefineStringKey(CollectionViewHeaderReuseIdentifier);
DefineStringKey(CollectionViewCellReuseIdentifier);


@protocol ORKTask;
@class ORKConsentDocument;
@class ORKTaskResult;

@interface TaskFactory : NSObject

+ (instancetype)sharedInstance;

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier;

- (ORKConsentDocument *)buildConsentDocument;

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size border:(BOOL)border;

@property (nonatomic, copy) ORKConsentDocument *currentConsentDocument;

@property (nonatomic, strong) ORKTaskResult *embeddedReviewTaskResult;

@end
