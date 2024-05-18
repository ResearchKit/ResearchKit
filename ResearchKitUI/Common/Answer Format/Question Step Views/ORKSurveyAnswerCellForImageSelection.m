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


#import "ORKSurveyAnswerCellForImageSelection.h"

#import "ORKImageSelectionView.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@interface ORKSurveyAnswerCellForImageSelection () <ORKImageSelectionViewDelegate>

@end


@implementation ORKSurveyAnswerCellForImageSelection {
    ORKImageSelectionView *_selectionView;
}

- (void)prepareView {
    [super prepareView];
    
    _selectionView = [[ORKImageSelectionView alloc] initWithImageChoiceAnswerFormat:(ORKImageChoiceAnswerFormat *)self.step.answerFormat answer:self.answer];
    _selectionView.delegate = self;
    _selectionView.frame = self.bounds;
    
    [self addSubview:_selectionView];
    
    _selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"selectionView": _selectionView };
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectionView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectionView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    NSLayoutConstraint *resistCompressingConstraint = [NSLayoutConstraint constraintWithItem:_selectionView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                      toItem:nil
                                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                                  multiplier:1.0
                                                                                    constant:ORKScreenMetricMaxDimension];
    resistCompressingConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject:resistCompressingConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark ORKImageSelectionViewDelegate
- (void)selectionViewSelectionDidChange:(ORKImageSelectionView *)view {
    [self ork_setAnswer:view.answer];
}

- (void)answerDidChange {
    [_selectionView setAnswer:self.answer];
}

- (NSArray *)suggestedCellHeightConstraintsForView:(UIView *)view {
    return @[];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSArray *)accessibilityElements {
    return @[_selectionView];
}

@end
