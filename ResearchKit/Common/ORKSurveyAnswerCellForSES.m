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

#import "ORKSurveyAnswerCellForSES.h"
#import "ORKSESSelectionView.h"
#import "ORKQuestionStep.h"


@interface ORKSurveyAnswerCellForSES() <ORKSESSelectionViewDelegate>

@end
@implementation ORKSurveyAnswerCellForSES {
    ORKSESSelectionView *_selectionView;
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return UITableViewAutomaticDimension;
}

- (NSArray *)suggestedCellHeightConstraintsForView:(UIView *)view {
    return @[];
}

- (void)prepareView {
    [super prepareView];

    _selectionView = [[ORKSESSelectionView alloc] initWithAnswerFormat:(ORKSESAnswerFormat *)self.step.answerFormat answer:self.answer];
    _selectionView.delegate = self;
    _selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_selectionView];
    
    [[_selectionView.topAnchor constraintEqualToAnchor:self.topAnchor] setActive:YES];
    [[_selectionView.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
    [[_selectionView.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
    [[self.bottomAnchor constraintEqualToAnchor:_selectionView.bottomAnchor] setActive:YES];
    
}

#pragma mark - ORKSESSelectionViewDelegate

- (void)buttonPressedAtIndex:(NSInteger)index {
    _selectionView.answer = [NSNumber numberWithInteger:index];
    [self ork_setAnswer:_selectionView.answer];
}

- (void)dontKnowButtonPressed {
    _selectionView.answer = [ORKDontKnowAnswer answer];
    [self ork_setAnswer:_selectionView.answer];
}

@end
