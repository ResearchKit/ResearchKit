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


#import <ResearchKit/ORKStepNavigationRule.h>


// This 'Private' header is needed because ORKESerialization uses ORKPredicateStepNavigationRule's
// internal initializer in order to avoid argument array validation.
NS_ASSUME_NONNULL_BEGIN

@interface ORKPredicateStepNavigationRule ()

/**
 Returns an initialized predicate step navigation rule using the specified result predicates,
 destination step identifiers, and an optional default step identifier.
 
 @param resultPredicates            An array of result predicates. Each result predicate can match
                                        one or more step results in the ongoing task.
 @param destinationStepIdentifiers  An array of possible destination step identifiers. This array
                                        must contain one step identifier for each of the predicates
                                        in the `resultPredicates` parameter.
 @param defaultStepIdentifier       The identifier of the step which is used if none of the
                                    result predicates match. If this argument is `nil` and none
                                    of the predicates match, the default ordered task navigation
                                    behavior takes place (that is, the task goes to the next step in
                                    order).
 @param validateArrays              `YES` to throw an exception if result predicates or
                                        destination step identifiers are `nil` or empty; `NO` to skip
                                        their validation.
 
 @return An initialized predicate step navigation rule.
 */
- (instancetype)initWithResultPredicates:(NSArray<NSPredicate *> *)resultPredicates
              destinationStepIdentifiers:(NSArray<NSString *> *)destinationStepIdentifiers
                   defaultStepIdentifier:(nullable NSString *)defaultStepIdentifier
                          validateArrays:(BOOL)validateArrays NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
