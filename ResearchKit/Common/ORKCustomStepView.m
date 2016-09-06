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


#import "ORKCustomStepView.h"
#import "ORKCustomStepView_Internal.h"

#import "ORKSurveyAnswerCell.h"

#import "ORKStepViewController.h"

#import "ORKSkin.h"


@implementation ORKActiveStepCustomView

- (void)resetStep:(ORKStepViewController *)viewController {
}

- (void)startStep:(ORKStepViewController *)viewController {
}

- (void)suspendStep:(ORKStepViewController *)viewController {
}

- (void)resumeStep:(ORKStepViewController *)viewController {
}

- (void)finishStep:(ORKStepViewController *)viewController {
}

- (void)updateDisplay:(ORKActiveStepViewController *)viewController {
}

@end


@implementation ORKQuestionStepCustomView

@end


@implementation ORKQuestionStepCellHolderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)tapAction {
    [_cell becomeFirstResponder];
}

- (void)setCell:(ORKSurveyAnswerCell *)cell {
    // Removing old cell from superview automatically removes its constraints
    [_cell removeFromSuperview];
    _cell = cell;
    
    _cell.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([[_cell class] shouldDisplayWithSeparators]) {
        _cell.showTopSeparator = YES;
        _cell.showBottomSeparator = YES;
    }
    
    [self addSubview:_cell];
    [self setUpCellConstraints];
}

- (void)setUpCellConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTopMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottomMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeftMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_cell
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRightMargin
                                                       multiplier:1.0
                                                         constant:0.0]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.layoutMargins = ORKStandardFullScreenLayoutMarginsForView(self);
}

@end