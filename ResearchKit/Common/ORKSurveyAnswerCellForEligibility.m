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


#import "ORKSurveyAnswerCellForEligibility.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"


@implementation ORKSurveyAnswerCellForEligibility

- (void)prepareView {
    [super prepareView];

    // Add the selection view to the content view of the form item cell.
    ORKEligibilitySelectionView *selectionView = [[ORKEligibilitySelectionView alloc] initWithFrame:CGRectZero];
    selectionView.delegate = self;
    selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:selectionView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(selectionView);
    ORKEnableAutoLayoutForViews([views allValues]);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectionView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
}

- (BOOL)isAnswerValid {
    
    if (self.answer == ORKNullAnswerValue()) {
        return YES;
    }
    
    ORKEligibilityAnswerFormat *answerFormat = (ORKEligibilityAnswerFormat *) [self.step impliedAnswerFormat];
    return [answerFormat isAnswerValid:self.answer];
}

- (BOOL)shouldContinue {
    BOOL isValid = [self isAnswerValid];
    if (! isValid) {
         [self showValidityAlertWithMessage:[[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:self.answer]];
    }
    return isValid;
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return EligibilityButtonHeight;
}

#pragma mark - ORKEligibilitySelectionViewDelegate

- (void)selectionViewSelectionDidChange:(ORKEligibilitySelectionView *)view {
    [self ork_setAnswer:view.answer];
}

@end
