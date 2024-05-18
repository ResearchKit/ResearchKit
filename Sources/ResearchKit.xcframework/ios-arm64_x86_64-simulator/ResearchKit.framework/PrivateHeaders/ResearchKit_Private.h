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

#import <ResearchKit/CLLocationManager+ResearchKit.h>
#import <ResearchKit/ORKActiveStep_Internal.h>
#import <ResearchKit/ORKAnswerFormat_Internal.h>
#import <ResearchKit/ORKAnswerFormat_Private.h>
#import <ResearchKit/ORKBodyItem_Internal.h>
#import <ResearchKit/ORKChoiceAnswerFormatHelper.h>
#import <ResearchKit/ORKCollectionResult_Private.h>
#import <ResearchKit/ORKConsentDocument_Private.h>
#import <ResearchKit/ORKConsentSection_Private.h>
#import <ResearchKit/ORKDataLogger.h>
#import <ResearchKit/ORKDevice_Private.h>
#import <ResearchKit/ORKErrors.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKHelpers_Private.h>
#import <ResearchKit/ORKOrderedTask_Private.h>
#import <ResearchKit/ORKPageStep_Private.h>
#import <ResearchKit/ORKPredicateFormItemVisibilityRule_Private.h>
#import <ResearchKit/ORKQuestionResult_Private.h>
#import <ResearchKit/ORKQuestionStep_Private.h>
#import <ResearchKit/ORKRecorder_Private.h>
#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKSignatureResult_Private.h>
#import <ResearchKit/ORKSkin_Private.h>
#import <ResearchKit/ORKStepNavigationRule_Private.h>
#import <ResearchKit/ORKStep_Private.h>
#import <ResearchKit/ORKTypes_Private.h>
#import <ResearchKit/ORKWebViewStepResult_Private.h>
