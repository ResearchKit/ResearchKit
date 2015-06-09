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


#import "ORKPVSATKeyboardView.h"
#import "ORKBorderedButton.h"


@interface ORKPVSATKeyboardView ()

@property (nonatomic, strong, readonly) ORKBorderedButton *answer2Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer3Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer4Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer5Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer6Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer7Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer8Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer9Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer10Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer11Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer12Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer13Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer14Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer15Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer16Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer17Button;
@property (nonatomic, strong, readonly) ORKBorderedButton *answer18Button;

@end


@implementation ORKPVSATKeyboardView {
    NSArray *_constraints;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _answer2Button = [ORKBorderedButton new];
        _answer2Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer2Button setTitle:@"2" forState:UIControlStateNormal];
        [_answer2Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer3Button = [ORKBorderedButton new];
        _answer3Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer3Button setTitle:@"3" forState:UIControlStateNormal];
        [_answer3Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer4Button = [ORKBorderedButton new];
        _answer4Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer4Button setTitle:@"4" forState:UIControlStateNormal];
        [_answer4Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer5Button = [ORKBorderedButton new];
        _answer5Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer5Button setTitle:@"5" forState:UIControlStateNormal];
        [_answer5Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer6Button = [ORKBorderedButton new];
        _answer6Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer6Button setTitle:@"6" forState:UIControlStateNormal];
        [_answer6Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer7Button = [ORKBorderedButton new];
        _answer7Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer7Button setTitle:@"7" forState:UIControlStateNormal];
        [_answer7Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer8Button = [ORKBorderedButton new];
        _answer8Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer8Button setTitle:@"8" forState:UIControlStateNormal];
        [_answer8Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer9Button = [ORKBorderedButton new];
        _answer9Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer9Button setTitle:@"9" forState:UIControlStateNormal];
        [_answer9Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer10Button = [ORKBorderedButton new];
        _answer10Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer10Button setTitle:@"10" forState:UIControlStateNormal];
        [_answer10Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer11Button = [ORKBorderedButton new];
        _answer11Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer11Button setTitle:@"11" forState:UIControlStateNormal];
        [_answer11Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer12Button = [ORKBorderedButton new];
        _answer12Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer12Button setTitle:@"12" forState:UIControlStateNormal];
        [_answer12Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer13Button = [ORKBorderedButton new];
        _answer13Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer13Button setTitle:@"13" forState:UIControlStateNormal];
        [_answer13Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer14Button = [ORKBorderedButton new];
        _answer14Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer14Button setTitle:@"14" forState:UIControlStateNormal];
        [_answer14Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer15Button = [ORKBorderedButton new];
        _answer15Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer15Button setTitle:@"15" forState:UIControlStateNormal];
        [_answer15Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer16Button = [ORKBorderedButton new];
        _answer16Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer16Button setTitle:@"16" forState:UIControlStateNormal];
        [_answer16Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer17Button = [ORKBorderedButton new];
        _answer17Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer17Button setTitle:@"17" forState:UIControlStateNormal];
        [_answer17Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        _answer18Button = [ORKBorderedButton new];
        _answer18Button.translatesAutoresizingMaskIntoConstraints = NO;
        [_answer18Button setTitle:@"18" forState:UIControlStateNormal];
        [_answer18Button addTarget:self action:@selector(buttonPressed:forEvent:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_answer2Button];
        [self addSubview:_answer3Button];
        [self addSubview:_answer4Button];
        [self addSubview:_answer5Button];
        [self addSubview:_answer6Button];
        [self addSubview:_answer7Button];
        [self addSubview:_answer8Button];
        [self addSubview:_answer9Button];
        [self addSubview:_answer10Button];
        [self addSubview:_answer11Button];
        [self addSubview:_answer12Button];
        [self addSubview:_answer13Button];
        [self addSubview:_answer14Button];
        [self addSubview:_answer15Button];
        [self addSubview:_answer16Button];
        [self addSubview:_answer17Button];
        [self addSubview:_answer18Button];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints];
    }
    
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [_answer2Button setEnabled:enabled];
    [_answer3Button setEnabled:enabled];
    [_answer4Button setEnabled:enabled];
    [_answer5Button setEnabled:enabled];
    [_answer6Button setEnabled:enabled];
    [_answer7Button setEnabled:enabled];
    [_answer8Button setEnabled:enabled];
    [_answer9Button setEnabled:enabled];
    [_answer10Button setEnabled:enabled];
    [_answer11Button setEnabled:enabled];
    [_answer12Button setEnabled:enabled];
    [_answer13Button setEnabled:enabled];
    [_answer14Button setEnabled:enabled];
    [_answer15Button setEnabled:enabled];
    [_answer16Button setEnabled:enabled];
    [_answer17Button setEnabled:enabled];
    [_answer18Button setEnabled:enabled];
}

- (void)updateConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_answer2Button, _answer3Button, _answer4Button, _answer5Button, _answer6Button, _answer7Button, _answer8Button, _answer9Button, _answer10Button, _answer11Button, _answer12Button, _answer13Button, _answer14Button, _answer15Button, _answer16Button, _answer17Button, _answer18Button);
    
    // First line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_answer2Button]-[_answer3Button(==_answer2Button)]-[_answer4Button(==_answer2Button)]-[_answer5Button(==_answer2Button)]-[_answer6Button(==_answer2Button)]-[_answer7Button(==_answer2Button)]-|"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    // Second line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_answer8Button]-[_answer9Button(==_answer8Button)]-[_answer10Button(==_answer8Button)]-[_answer11Button(==_answer8Button)]-[_answer12Button(==_answer8Button)]"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_answer8Button
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_answer2Button
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f constant:0.f]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_answer10Button
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.f constant:0.f]];
    
    // Third line of answer buttons
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_answer13Button]-[_answer14Button(==_answer13Button)]-[_answer15Button(==_answer13Button)]-[_answer16Button(==_answer13Button)]-[_answer17Button(==_answer13Button)]-[_answer18Button(==_answer13Button)]-|"
                                             options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom
                                             metrics:nil views:views]];
    
    // Align vertically
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_answer2Button]-[_answer8Button(==_answer2Button)]-[_answer13Button(==_answer2Button)]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    _constraints = constraints;
    [self addConstraints:_constraints];
    
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
        [self.delegate keyboardView:self didSelectAnswer:[tappedAnswerButton.titleLabel.text integerValue]];
    }
}

@end
