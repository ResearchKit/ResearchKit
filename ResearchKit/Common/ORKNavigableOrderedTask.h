/*
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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

/**
 The `ORKNavigableOrderedTask` class adds conditional step navigation to the behavior inherited from
 `ORKOrderedTask`.
 
 For implementing conditional task navigation, you must instantiate concrete subclasses of
 `ORKStepNavigationRule` and attach them to trigger steps by using
 `setNavigationRule:forTriggerStepIdentifier:`.
 
 For example, if you want to display a survey question only when the user answered Yes to a previous
 question you can use `ORKPredicateStepNavigationRule`; or if you want to define an arbitrary jump
 between two steps you can use `ORKDirectStepNavigationRule`.
 */
ORK_CLASS_AVAILABLE
@interface ORKNavigableOrderedTask : ORKOrderedTask

/**
 Adds a navigation rule for a trigger step identifier.
 
 The rule will be used to obtain a new destination step when the participant goes forward from the
 trigger step. You cannot add two different navigation rules to the same trigger step identifier:
 only the most recently added rule is kept.
 
 @param stepNavigationRule      The step navigation rule to be used when navigating forward from the
                                    trigger step. A strong reference to the rule is maintained by
                                    the task.
 @param triggerStepIdentifier   The identifier of the step that should trigger the rule.
 */
- (void)setNavigationRule:(ORKStepNavigationRule *)stepNavigationRule forTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 Returns the step navigation rule (if any) associated to a trigger step identifier.
 
 @param triggerStepIdentifier   The identifier of the step whose rule you want to retrieve.

 @return A step navigation rule, or `nil` if the trigger step identifier has none.
 */
- (ORKStepNavigationRule *)navigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 Removes the navigation rule (if any) associated to the specified trigger step identifier.
 
 @param triggerStepIdentifier   The identifier of the step whose rule is to be removed.
 */
- (void)removeNavigationRuleForTriggerStepIdentifier:(NSString *)triggerStepIdentifier;

/**
 A dictionary of step navigation rules in the task, keyed by trigger step identifier.
 
 Each object in the dictionary should be a `ORKStepNavigationRule` subclass.
 */
@property (nonatomic, copy, readonly) NSDictionary *stepNavigationRules;

@end

 NS_ASSUME_NONNULL_END
