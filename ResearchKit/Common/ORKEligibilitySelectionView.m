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


#import "ORKEligibilitySelectionView.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"


@implementation ORKEligibilitySelectionView {
    ORKEligibilityButton *_yesButton;
    ORKEligibilityButton *_noButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Create the buttons and add them to the view.
        _yesButton = [ORKEligibilityButton yesEligibilityButton];
        _noButton = [ORKEligibilityButton noEligibilityButton];
        
        [_yesButton addTarget:self
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
        [_noButton addTarget:self
                      action:@selector(buttonTapped:)
            forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_yesButton];
        [self addSubview:_noButton];
        
        // Create a separator for in between the buttons.
        UIView *separator = [UIView new];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
        
        // Constraints for the buttons and separator.
        ORKEnableAutoLayoutForViews(@[_yesButton, separator, _noButton]);
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_yesButton
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:separator
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_yesButton
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:separator
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_noButton
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_noButton
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_yesButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_noButton
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:1],
                               [NSLayoutConstraint constraintWithItem:separator
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:1],
                               [NSLayoutConstraint constraintWithItem:separator
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_yesButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_noButton
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_yesButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:separator
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_noButton
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0]
                               ]
         ];
    }
    return self;
}

- (void)toggleViewForAnswer:(id)answer {
    if (ORKIsAnswerEmpty(answer)) {
        _yesButton.selected = NO;
        _noButton.selected = NO;
    } else if ([answer boolValue] == YES) {
        _yesButton.selected = YES;
        _noButton.selected = NO;
    } else if ([answer boolValue] == NO) {
        _yesButton.selected = NO;
        _noButton.selected = YES;
    }
}

- (void)buttonTapped:(ORKEligibilityButton *)button {
    // Set answer based on selection.
    if (! button.isSelected) {
        _answer = ([button isEqual:_yesButton]) ? @1 : @0;
    } else {
        _answer = nil;
    }
    
    // Toggle button view for the selection.
    [self toggleViewForAnswer:_answer];
    
    // Send delegate callback.
    if ([self.delegate respondsToSelector:@selector(selectionViewSelectionDidChange:)]) {
        [self.delegate selectionViewSelectionDidChange:self];
    }
}

@end
