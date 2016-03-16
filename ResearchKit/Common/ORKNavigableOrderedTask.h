/*
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 
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


#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKOrderedTask.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKStepNavigationRule;
@class ORKSkipStepNavigationRule;

/**
 The `ORKNavigableOrderedTask` class adds conditional step navigation to the behavior inherited from
 the `ORKOrderedTask` class.
 
 For implementing conditional task navigation, you must instantiate concrete subclasses of
 `ORKStepNavigationRule` and `ORKSkipStepNavigationRule` and attach them to trigger steps by using
 the `setNavigationRule:forTriggerStepIdentifier:` and `setSkipNavigationRule:forStepIdentifier:`
 methods.
 
 For example, if you want to display a survey question only when the user answered Yes to a previous
 question you can use `ORKPredicateStepNavigationRule`; or if you want to define an arbitrary jump
 between two steps you can use `ORKDirectStepNavigationRule`. You can also optionally omit steps by
 using `ORKPredicateSkipStepNavigationRule` objects.
 
 Note that each step in the task can have at most one attached navigation rule and one attached skip
 navigation rule.
 
 Navigable ordered tasks support looping over previously visited steps. Note, however, that results
 for steps that are visited more than once will be ovewritten when you revisit the step on the loop.
 Thus, going over a loop will produce duplicate results within the task results for the steps that
 are seen more than once, but all the duplicate step results will point to the same result instance:
 the one corresponding to the last time you visited the step.
 
 The same applies when navigating backwards over looped steps: only your last valid answer is shown
 every time you encounter a revisited step.
 */
ORK_CLASS_AVAILABLE
@interface ORKNavigableOrderedTask : ORKOrderedTask

/**
 Adds a navigation rule for a trigger step identifier.
 
 The rule will be used to obtain a new destination step when the participant goes forward from the
 trigger step. You cannot add two different navigation rules to the same trigger step identifier;
 only the most recently added rule is kept.
 
 @param stepNavigationRule      The step navigation rule to be used when navigating forward from the
                                    trigger step. A strong reference to the rule is kept by the
                                    task.
 @param triggerStepIdentifier   The identifier of the step that triggers the rule.
 */
- (void)setNavigationRule:(ORKStepNavigationRule *)stepNavigationRule forTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 Returns the step navigation rule associated with a trigger step identifier, or `nil` if there is
 no rule associated with that step identifier.
 
 @param triggerStepIdentifier   The identifier of the step whose rule you want to retrieve.

 @return A step navigation rule, or `nil` if the trigger step identifier has none.
 */
- (nullable ORKStepNavigationRule *)navigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 Removes the navigation rule, if any, associated with the specified trigger step identifier.
 
 @param triggerStepIdentifier   The identifier of the step whose rule is to be removed.
 */
- (void)removeNavigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 A dictionary of step navigation rules in the task, keyed by trigger step identifier.
 
 Each object in the dictionary should be a `ORKStepNavigationRule` subclass.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, ORKStepNavigationRule *> *stepNavigationRules;

/**
 Adds a skip step navigation rule for a step identifier.
 
 The rule will be used to decide if the identified step needs to be skipped. You cannot add two
 different skip navigation rules to the same step identifier; only the most recently added rule is
 kept.
 
 @param skipStepNavigationRule      The skip step navigation rule to be used to determine if the
                                        step should be skipped. A strong reference to the rule is
                                        kept by the task.
 @param stepIdentifier              The identifier of the step that is checked against the skip
                                        rule.
 */
- (void)setSkipNavigationRule:(ORKSkipStepNavigationRule *)skipStepNavigationRule forStepIdentifier:(NSString *)stepIdentifier;

/**
 Returns the skip step navigation rule associated with a step identifier,  or `nil` if there is no
 skip rule associated with that step identifier.
 
 @param stepIdentifier      The identifier of the step whose skip rule you want to retrieve.
 
 @return A skip step navigation rule, or `nil` if the step identifier has none.
 */
- (nullable ORKSkipStepNavigationRule *)skipNavigationRuleForStepIdentifier:(NSString *)stepIdentifier;

/**
 Removes the skip step navigation rule, if any, associated with the specified step identifier.
 
 @param stepIdentifier   The identifier of the step whose rule is to be removed.
 */
- (void)removeSkipNavigationRuleForStepIdentifier:(NSString *)stepIdentifier;

/**
 A dictionary of step navigation rules in the task, keyed by trigger step identifier.
 
 Each object in the dictionary should be a `ORKStepNavigationRule` subclass.
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, ORKSkipStepNavigationRule *> *skipStepNavigationRules;

/**
 Determines whether the task should report its progress as a linear ordered task or not.
 The default value of this property is `NO`.
 */
@property (nonatomic) BOOL shouldReportProgress;

@end


@interface ORKNavigableOrderedTask (ORKPredefinedActiveTask)

/**
 Returns a predefined task that measures the upper extremity function.
 
 In a hole peg test task, the participant is asked to fill holes with pegs.
 
 A hole peg test task can be used to assess arm and hand function, especially in patients with severe disability.
 
 Data collected in this task is in the form of an `ORKHolePegTestResult` object.
 
 @param identifier              The task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription  A localized string describing the intended use of the data
                                  collected. If the value of this parameter is `nil`, the default
                                  localized text will be displayed.
 @param dominantHand            The participant dominant hand that will be tested first.
 @param numberOfPegs            The number of pegs to place in the pegboard.
 @param threshold               The threshold value used for the detection area.
 @param rotated                 A test variant that also requires peg rotation.
 @param timeLimit               The duration allowed to validate the peg position.
 @param options                 Options that affect the features of the predefined task.
 
 @return An active hole peg test task that can be presented with an `ORKTaskViewController` object.
 */
+ (ORKNavigableOrderedTask *)holePegTestTaskWithIdentifier:(NSString *)identifier
                                    intendedUseDescription:(nullable NSString *)intendedUseDescription
                                              dominantHand:(ORKBodySagittal)dominantHand
                                              numberOfPegs:(int)numberOfPegs
                                                 threshold:(double)threshold
                                                   rotated:(BOOL)rotated
                                                 timeLimit:(NSTimeInterval)timeLimit
                                                   options:(ORKPredefinedTaskOption)options;

@end

 NS_ASSUME_NONNULL_END
