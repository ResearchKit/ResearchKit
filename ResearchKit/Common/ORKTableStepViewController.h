/*
 Copyright (c) 2016, Sage Bionetworks
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import <ResearchKit/ResearchKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKTableStepViewController` class is an base class that inherits from `ORKStepViewController` 
 and provides a UITableView.
 
 `ORKTableStepViewController` is designed to take advantage of the internal class methods 
 used by `ORKFormStepViewController`, `ORKQuestionStepViewController` and `ORKReviewStepViewController` 
 to allow for a consistent UI in a custom implementation of a main view that is a UITableView.
 
 This will class will setup a consistent look for the title, text, learn more, skip and next UI elements
 that are used by these classes as well as most of the other view controllers within this framework by 
 automatically adding them as the header and footer of the tableview.
 
 The base class implementation REQUIRES using an `ORKTableStep` as its data source. If you do not inherit 
 the step from ORKTableStep, then subclasses MUST override `-cellForRowAtIndexPath`.
 
 */
ORK_CLASS_AVAILABLE
@interface ORKTableStepViewController : ORKStepViewController <UITableViewDataSource, UITableViewDelegate>

/**
 @return    The step associated with this view controller if it can be cast to ORKTableStep.
 */
@property (nonatomic, readonly, nullable) ORKTableStep *tableStep;

/**
 @return    The table view managed by the controller object.
 */
@property (nonatomic, readonly) UITableView *tableView;

/**
 Whether or not the continue button should be enabled for this step. Default = YES
 
 Set to `NO` if there is a validation that needs to be handled before the step
 can progress. Your implementation is responsible for overriding selection as needed
 to trigger validation and state changes.
 
 @return    State of continue button
 */
- (BOOL)continueButtonEnabled;

@end

NS_ASSUME_NONNULL_END
