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


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKAnswerFormat.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKQuestionStep` class is a concrete subclass of `ORKStep` that represents
 a step in which a single question is presented to the user.
 
 To use a question step, instantiate an `ORKQuestionStep` object, fill in its properties, and include it
 in a task. Next, create a task view controller for the task and present it.
 When the task completes, the user's answer is encoded in the result hierarchy
 in the task view controller.
 
 When a task view controller presents an `ORKQuestionStep` object, it instantiates an `ORKQuestionStepViewController` object to present the step. The actual
 visual presentation depends on the answer format.
 
 When you need to present more than one question at the same time, it can be appropriate
 to use `ORKFormStep` instead of `ORKQuestionStep`.
 
 The result of a question step is an `ORKStepResult` object that includes a single child
 (`ORKQuestionResult`).
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionStep : ORKStep

/**
 Returns a new question step that includes the specified identifier, title, and answer format.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param title         A localized string that represents the primary text of the question.
 @param answerFormat  The format in which the answer is expected.
 */
+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                    answer:(nullable ORKAnswerFormat *)answerFormat;

/**
 Returns a new question step that includes the specified identifier, title, text, and answer format.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param title         A localized string that represents the primary text of the question.
 @param text          A localized string that represents the additional text of the question.
 @param answerFormat  The format in which the answer is expected.
 */
+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                      text:(nullable NSString *)text
                                    answer:(nullable ORKAnswerFormat *)answerFormat;

/**
 The format of the answer.
 
 For example, the answer format might include the type of data to collect, the constraints
 to place on the answer, or a list of available choices (in the case of single
 or multiple select questions).
 */
@property (nonatomic, strong, nullable) ORKAnswerFormat *answerFormat;

/**
 The question type. (read-only)
 
 The value of this property is derived from the answer format.
 */
@property (nonatomic, readonly) ORKQuestionType questionType;

/**
 A localized string that represents the placeholder text displayed before an answer has been entered.
 
 For numeric and text-based answers, the placeholder content is displayed in the
 text field or text area when an answer has not yet been entered.
  */
@property (nonatomic, copy, nullable) NSString *placeholder;

@end

NS_ASSUME_NONNULL_END
