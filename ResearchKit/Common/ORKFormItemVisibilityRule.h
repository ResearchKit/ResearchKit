/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>

@class ORKTaskResult;

NS_ASSUME_NONNULL_BEGIN

/**
 An abstract base class for concrete formItem visibility rules.
 
 FormItem visibility rules are meant to be assigned to an `ORKFormItem` object. The visibility rule's
 `formItemVisibilityForTaskResult:` method is invoked to determine whether a formItem should be
 visible. `ORKTaskViewController` also uses the result of this visibility method to elide results from its `results`.

 Subclasses must implement the `formItemVisibilityForTaskResult:` method, which returns
 YES to allow the parent formItem to be visible in the form UI, and returns NO otherwise. formItems that are not visible
 don't have results in the enclosing step or task results either. 
 
 One concrete subclass is included: `ORKPredicateFormItemVisibilityRule`
 */
ORK_CLASS_AVAILABLE
@interface ORKFormItemVisibilityRule: NSObject <NSCopying, NSSecureCoding>

- (BOOL)formItemVisibilityForTaskResult:(nullable ORKTaskResult *)taskResult;

@end

NS_ASSUME_NONNULL_END
