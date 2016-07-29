/*
 Copyright (c) 2015, Oliver Schaefer.
 
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


#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKResult.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKReviewStep` class is a concrete subclass of `ORKStep` that represents
 a step in which existing question results can be reviewed by the user.
 
 There are two separate scenarios for using `ORKReviewStep`. The first one is to embed a review step within an ongoing 
 survey, which means an instance of `ORKReviewStep` might be placed at the end or in the middle of a task. The second 
 scenario is meant to use `ORKReviewStep` standalone for reviewing an already completed task.
 
 To use a review step, instantiate an `ORKReviewStep` object, fill in its properties, and include it in a task. Next, 
 create a task view controller for the task and present it.
 
 When a task view controller presents an `ORKReviewStep` object, it instantiates an `ORKReviewStepViewController` object 
 to present the step. This view controller lists both steps and step results to provide all entered data at a glance. It
 also allows the user to navigate directly to a certain step. However, results may only be changed from there, if the 
 review step is used within an ongoing survey (`embedded`).
 */
ORK_CLASS_AVAILABLE
@interface ORKReviewStep : ORKStep

/**
 Returns a new standalone review step that includes the specified identifier, steps, and result source.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param steps         The steps that should be reviewed.
 @param resultSource  The source that should be consulted to obtain the corresponding step results.
 */
+ (instancetype)standaloneReviewStepWithIdentifier:(NSString *)identifier
                                             steps:(NSArray *)steps
                                      resultSource:(id<ORKTaskResultSource, NSSecureCoding>)resultSource;

/**
 Returns a new embedded review step that includes the specified identifier. Steps and step results are directly taken 
 from the current task.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 */
+ (instancetype)embeddedReviewStepWithIdentifier:(NSString *)identifier;

/**
 The steps to be reviewed. (read-only)
 
 This property contains all steps that are included in the review process. Currently, only question, instruction and 
 form steps can be reviewed. Any other step type will be ignored.
 */
@property (nonatomic, copy, readonly) NSArray<ORKStep *> *steps;

/**
 The result source to obtain step results from. (read-only)
 
 This property contains the source that should be consulted to obtain step results.
 */
@property (nonatomic, readonly) id<ORKTaskResultSource, NSSecureCoding> resultSource;

/**
 A Boolean value indicating whether instruction steps should be excluded from review.
 
 The default value of this property is `NO`. When the value is `YES`, any instances of `ORKInstructionStep` are 
 excluded from the review step in either embedded or standalone mode.
 */
@property (nonatomic) BOOL excludeInstructionSteps;

@end

NS_ASSUME_NONNULL_END
