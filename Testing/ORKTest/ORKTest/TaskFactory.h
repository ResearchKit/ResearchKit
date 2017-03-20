//
//  TaskFactory.h
//  ORKTest
//
//  Created by Ricardo Sanchez-Saez on 1/9/17.
//  Copyright © 2017 ResearchKit. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DefineStringKey(x) static NSString *const x = @#x

DefineStringKey(ConsentTaskIdentifier);
DefineStringKey(ConsentReviewTaskIdentifier);
DefineStringKey(EligibilityFormTaskIdentifier);
DefineStringKey(EligibilitySurveyTaskIdentifier);
DefineStringKey(LoginTaskIdentifier);
DefineStringKey(RegistrationTaskIdentifier);
DefineStringKey(VerificationTaskIdentifier);

DefineStringKey(CompletionStepTaskIdentifier);
DefineStringKey(DatePickingTaskIdentifier);
DefineStringKey(ImageCaptureTaskIdentifier);
DefineStringKey(VideoCaptureTaskIdentifier);
DefineStringKey(ImageChoicesTaskIdentifier);
DefineStringKey(InstantiateCustomVCTaskIdentifier);
DefineStringKey(LocationTaskIdentifier);
DefineStringKey(ScalesTaskIdentifier);
DefineStringKey(ColorScalesTaskIdentifier);
DefineStringKey(MiniFormTaskIdentifier);
DefineStringKey(OptionalFormTaskIdentifier);
DefineStringKey(SelectionSurveyTaskIdentifier);
DefineStringKey(PredicateTestsTaskIdentifier);

DefineStringKey(ActiveStepTaskIdentifier);
DefineStringKey(AudioTaskIdentifier);
DefineStringKey(AuxillaryImageTaskIdentifier);
DefineStringKey(FitnessTaskIdentifier);
DefineStringKey(FootnoteTaskIdentifier);
DefineStringKey(GaitTaskIdentifier);
DefineStringKey(IconImageTaskIdentifier);
DefineStringKey(HolePegTestTaskIdentifier);
DefineStringKey(MemoryTaskIdentifier);
DefineStringKey(PSATTaskIdentifier);
DefineStringKey(ReactionTimeTaskIdentifier);
DefineStringKey(TrailMakingTaskIdentifier);
DefineStringKey(TwoFingerTapTaskIdentifier);
DefineStringKey(TimedWalkTaskIdentifier);
DefineStringKey(ToneAudiometryTaskIdentifier);
DefineStringKey(TowerOfHanoiTaskIdentifier);
DefineStringKey(TremorTaskIdentifier);
DefineStringKey(TremorRightHandTaskIdentifier);
DefineStringKey(WalkBackAndForthTaskIdentifier);

DefineStringKey(CreatePasscodeTaskIdentifier);

DefineStringKey(CustomNavigationItemTaskIdentifier);
DefineStringKey(DynamicTaskIdentifier);
DefineStringKey(InterruptibleTaskIdentifier);
DefineStringKey(NavigableOrderedTaskIdentifier);
DefineStringKey(NavigableLoopTaskIdentifier);
DefineStringKey(WaitTaskIdentifier);

DefineStringKey(CollectionViewHeaderReuseIdentifier);
DefineStringKey(CollectionViewCellReuseIdentifier);

DefineStringKey(EmbeddedReviewTaskIdentifier);
DefineStringKey(StandaloneReviewTaskIdentifier);
DefineStringKey(ConfirmationFormTaskIdentifier);

DefineStringKey(StepWillDisappearTaskIdentifier);
DefineStringKey(StepWillDisappearFirstStepIdentifier);

DefineStringKey(TableStepTaskIdentifier);
DefineStringKey(SignatureStepTaskIdentifier);
DefineStringKey(VideoInstructionStepTaskIdentifier);
DefineStringKey(PageStepTaskIdentifier);

@protocol ORKTask;

@class ORKConsentDocument;
@class ORKTaskResult;

@interface TaskFactory : NSObject

+ (instancetype)sharedInstance;

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier;

@property (nonatomic, copy) ORKConsentDocument *currentConsentDocument;
@property (nonatomic, strong) ORKTaskResult *embeddedReviewTaskResult;

@end
