/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKPSATKeyboardView.h"

#import "ORKBorderedButton.h"


NSUInteger const ORKPSATMinimumAnswer = 3;
NSUInteger const ORKPSATMaximumAnswer = 17;

@interface ORKPSATKeyboardView ()

@property (nonatomic, strong, readonly) NSArray *answerButtons;
@property (nonatomic, strong) NSArray *constraints;

@end


@implementation ORKPSATKeyboardView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] initWithCapacity:(ORKPSATMaximumAnswer - ORKPSATMinimumAnswer) + 1];
        ORKBorderedButton *answerButton = nil;
        for (int i = ORKPSATMinimumAnswer; i <= ORKPSATMaximumAnswer; i++) {
            answerButton = [self answerButtonWithTitle:[NSNumberFormatter localizedStringFromNumber:@(i)
                                                                                        numberStyle:NSNumberFormatterNoStyle]];
            [buttonsArray addObject:answerButton];
            [self addSubview:answerButton];
        }
        _answerButtons = [NSArray arrayWithArray:buttonsArray];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (ORKBorderedButton *)answerButtonWithTitle:(NSString *)title {
    ORKBorderedButton *answerButton = [ORKBorderedButton new];
    answerButton.translatesAutoresizingMaskIntoConstraints = NO;
    [answerButton setTitle:title forState:UIControlStateNormal];
    [answerButton addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    answerButton.accessibilityTraits |= UIAccessibilityTraitKeyboardKey;
    return answerButton;
}

- (void)setEnabled:(BOOL)enabled {
    for (ORKBorderedButton *answerButton in self.answerButtons) {
        [answerButton setEnabled:enabled];
    }
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    ORKBorderedButton *answer3Button = self.answerButtons[0];
    ORKBorderedButton *answer4Button = self.answerButtons[1];
    ORKBorderedButton *answer5Button = self.answerButtons[2];
    ORKBorderedButton *answer6Button = self.answerButtons[3];
    ORKBorderedButton *answer7Button = self.answerButtons[4];
    ORKBorderedButton *answer8Button = self.answerButtons[5];
    ORKBorderedButton *answer9Button = self.answerButtons[6];
    ORKBorderedButton *answer10Button = self.answerButtons[7];
    ORKBorderedButton *answer11Button = self.answerButtons[8];
    ORKBorderedButton *answer12Button = self.answerButtons[9];
    ORKBorderedButton *answer13Button = self.answerButtons[10];
    ORKBorderedButton *answer14Button = self.answerButtons[11];
    ORKBorderedButton *answer15Button = self.answerButtons[12];
    ORKBorderedButton *answer16Button = self.answerButtons[13];
    ORKBorderedButton *answer17Button = self.answerButtons[14];

    
    NSDictionary *views = NSDictionaryOfVariableBindings(answer3Button, answer4Button, answer5Button, answer6Button, answer7Button, answer8Button, answer9Button, answer10Button, answer11Button, answer12Button, answer13Button, answer14Button, answer15Button, answer16Button, answer17Button);
    
    // First line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answer3Button]-[answer4Button(==answer3Button)]-[answer5Button(==answer3Button)]-[answer6Button(==answer3Button)]-[answer7Button(==answer3Button)]-|"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    // Second line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answer8Button]-[answer9Button(==answer8Button)]-[answer10Button(==answer8Button)]-[answer11Button(==answer8Button)]-[answer12Button(==answer8Button)]-|"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    // Third line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[answer13Button]-[answer14Button(==answer13Button)]-[answer15Button(==answer13Button)]-[answer16Button(==answer13Button)]-[answer17Button(==answer13Button)]-|"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    // Align vertically
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[answer3Button]-[answer8Button(==answer3Button)]-[answer13Button(==answer3Button)]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

#pragma mark buttonAction

- (IBAction)buttonPressed:(id)button forEvent:(UIEvent *)event {
    ORKBorderedButton *tappedAnswerButton = (ORKBorderedButton *)button;
    
    [self.selectedAnswerButton setSelected:NO];
    self.selectedAnswerButton = tappedAnswerButton;
    [self.selectedAnswerButton setSelected:YES];
    
    if ([self.delegate respondsToSelector:@selector(keyboardView:didSelectAnswer:)]) {
        NSInteger answerValue = [self.answerButtons indexOfObject:tappedAnswerButton] + ORKPSATMinimumAnswer;
        [self.delegate keyboardView:self didSelectAnswer:answerValue];
    }
}

@end
