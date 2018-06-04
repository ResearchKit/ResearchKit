/*
 Copyright (c) 2017, Ricardo Sanchez-Saez.
 
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


#import "ORKAnswerFormat.h"
#import "ORKOrderedTask.h"
#import "ORKRegistrationStep.h"
#import "ORKQuestionStep.h"


NS_ASSUME_NONNULL_BEGIN

/**
 Deprecated in v2.0 (scheduled for removal).
 */

@interface ORKQuestionStep (Deprecated)

/**
 Returns a new question step that includes the specified identifier, title, question, and answer format.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param title         A localized string that represents the question.
 @param answerFormat  The format in which the answer is expected.
 */
+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                    answer:(nullable ORKAnswerFormat *)answerFormat __attribute__((deprecated("Use '-questionStepWithIdentifier:title:question:answer:' instead.","questionStepWithIdentifier")));

/**
 Returns a new question step that includes the specified identifier, title, question, and answer format.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param title         A localized string that represents the question.
 @param text          The primary text shown below the title string.
 @param answerFormat  The format in which the answer is expected.
 */
+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                      text:(nullable NSString *)text
                                    answer:(nullable ORKAnswerFormat *)answerFormat __attribute__((deprecated("Use '-questionStepWithIdentifier:title:question:answer:' instead.",
                          "questionStepWithIdentifier")));

@end

NS_ASSUME_NONNULL_END
