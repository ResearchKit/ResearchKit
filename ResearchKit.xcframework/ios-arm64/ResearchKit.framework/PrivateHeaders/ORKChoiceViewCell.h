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


@import UIKit;
#import <ResearchKit/ORKFormStep.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKAnswerTextView;

@interface ORKChoiceViewCell : UITableViewCell

@property (nonatomic, assign, getter=isImmediateNavigation) BOOL immediateNavigation;

@property (nonatomic, assign, getter=isCellSelected) BOOL cellSelected;

@property (nonatomic) bool useCardView;

@property (nonatomic) bool isLastItem;

@property (nonatomic) BOOL isFirstItemInSectionWithoutTitle;

@property (nonatomic) BOOL isExclusive;

@property (nonatomic) ORKCardViewStyle cardViewStyle;

- (void)setPrimaryText:(NSString *)primaryText;
- (void)setPrimaryAttributedText: (NSAttributedString *)primaryAttributedText;
- (void)setDetailText:(NSString *)detailText;
- (void)setDetailAttributedText:(NSAttributedString *)detailAttributedText;
- (void)setCellSelected:(BOOL)cellSelected highlight:(BOOL)highlight;

@end

@interface ORKChoiceOtherViewCell : ORKChoiceViewCell <UITextViewDelegate>

@property (nonatomic, strong, readonly) ORKAnswerTextView *textView;

@property (nonatomic, assign, setter=hideTextView:) BOOL textViewHidden;

@end

@interface ORKChoiceViewPlatterCell : ORKChoiceViewCell

@end

NS_ASSUME_NONNULL_END
