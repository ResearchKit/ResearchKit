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


#import <ResearchKit/ORKTypes.h>

#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKActiveStep.h>
#import <ResearchKit/ORKConsentReviewStep.h>
#import <ResearchKit/ORKConsentSharingStep.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKImageCaptureStep.h>
#import <ResearchKit/ORKInstructionStep.h>
#import <ResearchKit/ORKLoginStep.h>
#import <ResearchKit/ORKNavigablePageStep.h>
#import <ResearchKit/ORKPageStep.h>
#import <ResearchKit/ORKPasscodeStep.h>
#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKRegistrationStep.h>
#import <ResearchKit/ORKReviewStep.h>
#import <ResearchKit/ORKSignatureStep.h>
#import <ResearchKit/ORKTableStep.h>
#import <ResearchKit/ORKTouchAnywhereStep.h>
#import <ResearchKit/ORKVerificationStep.h>
#import <ResearchKit/ORKVideoCaptureStep.h>
#import <ResearchKit/ORKVisualConsentStep.h>
#import <ResearchKit/ORKWaitStep.h>
#import <ResearchKit/ORKVideoInstructionStep.h>
#import <ResearchKit/ORKHrCaptureStep.h>

#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKOrderedTask.h>
#import <ResearchKit/ORKNavigableOrderedTask.h>
#import <ResearchKit/ORKStepNavigationRule.h>

#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKHealthAnswerFormat.h>

#import <ResearchKit/ORKResult.h>
#import <ResearchKit/ORKResultPredicate.h>

#import <ResearchKit/ORKTextButton.h>
#import <ResearchKit/ORKBorderedButton.h>
#import <ResearchKit/ORKContinueButton.h>

#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKActiveStepViewController.h>
#import <ResearchKit/ORKCompletionStepViewController.h>
#import <ResearchKit/ORKFormStepViewController.h>
#import <ResearchKit/ORKInstructionStepViewController.h>
#import <ResearchKit/ORKLoginStepViewController.h>
#import <ResearchKit/ORKPageStepViewController.h>
#import <ResearchKit/ORKPasscodeViewController.h>
#import <ResearchKit/ORKTableStepViewController.h>
#import <ResearchKit/ORKTaskViewController.h>
#import <ResearchKit/ORKTouchAnywhereStepViewController.h>
#import <ResearchKit/ORKVerificationStepViewController.h>
#import <ResearchKit/ORKWaitStepViewController.h>

#import <ResearchKit/ORKRecorder.h>

#import <ResearchKit/ORKConsentDocument.h>
#import <ResearchKit/ORKConsentSection.h>
#import <ResearchKit/ORKConsentSignature.h>

#import <ResearchKit/ORKKeychainWrapper.h>

#import <ResearchKit/ORKChartTypes.h>
#import <ResearchKit/ORKBarGraphChartView.h>
#import <ResearchKit/ORKDiscreteGraphChartView.h>
#import <ResearchKit/ORKLineGraphChartView.h>
#import <ResearchKit/ORKPieChartView.h>

#import <ResearchKit/ORKDataCollectionManager.h>
#import <ResearchKit/ORKCollector.h>

#import <ResearchKit/ORKDeprecated.h>
