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


#import "ORKQuestionStepView.h"

#import "ORKCustomStepView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"

#import "ORKStep_Private.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKSkin.h"

@implementation ORKQuestionStepView

- (void)setQuestionCustomView:(ORKQuestionStepCustomView *)questionCustomView {
    _questionCustomView = questionCustomView;
    questionCustomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stepView = _questionCustomView;
}

- (void)setQuestionStep:(ORKQuestionStep *)step {
    _questionStep = step;
    self.headerView.instructionLabel.hidden = ![_questionStep text].length;
    
    self.minimumStepHeaderHeight = ORKQuestionStepMinimumHeaderHeight;
    self.headerView.captionLabel.useSurveyMode = step.useSurveyMode;
    self.headerView.instructionLabel.text = _questionStep.text;
}

- (void)setCustomHeaderTitle:(nullable NSString *)text {
    if (text) {
        self.headerView.captionLabel.text = text;
    }
}


#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSArray *)accessibilityElements {
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    
    // VO elements in containers with UIPickers of any kind are often not spoken in right order.
    // This is caused by the picker's frame overlapping other elements on screen, so we have to manually
    // tell VO the order of the elements.
    // Desired order: Headline label, Instruction label, "Learn more" button, picker, "Next" button, "Skip" button
    
    if (self.headerView.captionLabel != nil) {
        [elements addObject:self.headerView.captionLabel];
    }
    if (self.headerView.instructionLabel != nil) {
        [elements addObject:self.headerView.instructionLabel];
    }
    if (self.headerView.learnMoreButton != nil) {
        [elements addObject:self.headerView.learnMoreButton];
    }
    if (self.questionCustomView) {
        [elements addObject:self.questionCustomView];
    }
    return elements;
}

@end
