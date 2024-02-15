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

#import <ResearchKit/ORKQuestionStep.h>
#import <ResearchKit/ORKAnswerFormat_Private.h>

NS_ASSUME_NONNULL_BEGIN

/// Available presentation styles to apply to the question
typedef NSString *ORKQuestionStepPresentationStyle NS_STRING_ENUM;

/// The default presentation style.
ORK_EXTERN ORKQuestionStepPresentationStyle const ORKQuestionStepPresentationStyleDefault;

/// Uses an intracell spacing, rounds all corners and removes any cell separators.
ORK_EXTERN ORKQuestionStepPresentationStyle const ORKQuestionStepPresentationStylePlatter;

@protocol ORKQuestionStepPresentation <NSObject>

@property (nonatomic, copy) ORKQuestionStepPresentationStyle presentationStyle;

@end

@interface ORKQuestionStep () <ORKQuestionStepPresentation>

/**
 
 Platter presentation style initializer. Since this uses a custom layout for step details, this is the recommended way use the ORKQuestionStepPresentationStylePlatter.
 
 In scenarios where the question step is being initialized via JSON, it is recommended to use the default initializer and set the following properties:
 
 @property title will be used to display the question. Using the `question` property with `ORKQuestionStepPresentationStylePlatter` is not supported
 
 @property text will be used to display additional text below the title and above the tableView.
 
 Using configurations other than what is specified above will cause a runtime exception.
 
 */
+ (instancetype)platterQuestionWithIdentifier:(NSString *)identifier
                                     question:(NSString *)question
                                         text:(NSString *)text
                                 answerFormat:(ORKAnswerFormat<ORKAnswerFormatPlatterPresentable> *)answerFormat;

@end

NS_ASSUME_NONNULL_END
