/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>

@class ORKOrderedTask;
@class ORKTaskResult;
@class ORKBodyItem;
@class ORKStepResult;
@class ORKReviewViewController;
@class ORKNavigableOrderedTask;
@class ORKTaskViewController;
@class ORKLearnMoreInstructionStep;
@class ORKStepViewController;
@class ORKStep;
@class ORKTaskViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol ORKReviewViewControllerDelegate <NSObject>

@required


- (void)reviewViewController:(ORKReviewViewController *)reviewViewController willPresentTaskViewController:(ORKTaskViewController *)taskViewController;
- (void)reviewViewController:(ORKReviewViewController *)reviewViewController didUpdateResult:(ORKTaskResult *)updatedResult source:(ORKTaskResult *)resultSource;
- (void)reviewViewControllerDidSelectIncompleteCell:(ORKReviewViewController *)reviewViewController;

@optional
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep;
@end

ORK_CLASS_AVAILABLE
@interface ORKReviewViewController : UIViewController

- (instancetype)initWithTask:(ORKOrderedTask *)task result:(ORKTaskResult *)result delegate:(id<ORKReviewViewControllerDelegate>)delegate;
- (instancetype)initWithNavigableTask:(ORKNavigableOrderedTask *)task result:(ORKTaskResult *)result delegate:(id<ORKReviewViewControllerDelegate>)delegate;
- (instancetype)initWithTask:(ORKNavigableOrderedTask *)task delegate:(id<ORKReviewViewControllerDelegate>)delegate isCompleted:(BOOL)isCompleted incompleteText:(NSString *)incompleteText;

- (void)updateResultSource:(ORKTaskResult *)result forTask:(ORKOrderedTask *)task;

- (void)updateResultSource:(ORKTaskResult *)result;

- (nullable ORKNavigableOrderedTask *)taskForStep:(nullable ORKStep *)step sourceTask:(ORKNavigableOrderedTask *)sourceTask;
- (nullable ORKStep *)stepForIdentifier:(NSString *)identifier;

@property (nonatomic, weak)id<ORKReviewViewControllerDelegate> delegate;

@property (nonatomic) NSString *reviewTitle;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *detailText;

@property (nonatomic) UIImage *image;
@property (nonatomic) NSArray<ORKBodyItem *> *bodyItems;

@end

NS_ASSUME_NONNULL_END
