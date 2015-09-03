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


#import "ORKPasscodeKeyboardView.h"
#import "ORKPasscodeButton.h"


@implementation ORKPasscodeKeyboardView {
    NSMutableArray *_buttonArray;
    CGFloat _buttonHeight;
    CGFloat _buttonWidth;
}

- (instancetype) init {
    self = [super init];
    if (self) {

        // Configure the view.
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat keyboardViewWidth = screenRect.size.width;
        CGFloat keyboardViewHeight = screenRect.size.height/2.5;
        [self setBounds:CGRectMake(0, 0, keyboardViewWidth, keyboardViewHeight)];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        // Calculate button dimensions.
        _buttonHeight = keyboardViewHeight/4;
        _buttonWidth = _buttonHeight * 1.8;
        
        // Add passcode keyboard buttons.
        _buttonArray = [NSMutableArray new];
        [self addButtons];
    }
    
    return self;
}

- (void)addButtons {
    // Generate all the buttons and store in an array.
    for (int i = 0; i < 11; i++) {
        NSString *character = [NSString stringWithFormat:@"%d", i];
        ORKPasscodeButton *button = [[ORKPasscodeButton alloc] initWithCharacter:character];
        
        // Backspace button
        if (i == 10) {
            button = [[ORKPasscodeButton alloc] initWithCharacter:@"<"];
            button.backgroundColor = [UIColor groupTableViewBackgroundColor];
        }
        
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonArray addObject:button];
        [self addSubview:_buttonArray[i]];
    }
    
    [self setButtonConstraints];
}

- (void)setButtonConstraints {
    
    // 0 : Anchor everything to the 0. Placing zero on the bottom and centered.
    {
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_buttonArray[0]
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:_buttonArray[0]
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0]
                               ]
         ];
    }
    
    // 1 : Put on the left of 2.
    [self placeButton:_buttonArray[1] leftOfButton:_buttonArray[2]];
    
    // 2 : Put on top of 5.
    [self placeButton:_buttonArray[2] topOfButton:_buttonArray[5]];
    
    // 3 : Put on the right of 2.
    [self placeButton:_buttonArray[3] rightOfButton:_buttonArray[2]];
    
    // 4 : Put on the left of 5.
    [self placeButton:_buttonArray[4] leftOfButton:_buttonArray[5]];
    
    // 5 : Put on top of 8.
    [self placeButton:_buttonArray[5] topOfButton:_buttonArray[8]];
    
    // 6 : Place on the right of 5.
    [self placeButton:_buttonArray[6] rightOfButton:_buttonArray[5]];
    
    // 7 : Place on the left of 8.
    [self placeButton:_buttonArray[7] leftOfButton:_buttonArray[8]];
    
    // 8 : Place on top of 0.
    [self placeButton:_buttonArray[8] topOfButton:_buttonArray[0]];
    
    // 9 : Place on the right of 8.
    [self placeButton:_buttonArray[9] rightOfButton:_buttonArray[8]];
    
    // < : Place to the right of 0.
    [self placeButton:_buttonArray[10] rightOfButton:_buttonArray[0]];
    
}

- (void)buttonPressed:(id)sender {
    ORKPasscodeButton *button = sender;
    NSLog(@"%@", button.titleLabel.text);
}

#pragma mark - Helpers

- (void)placeButton:(ORKPasscodeButton *)button leftOfButton:(ORKPasscodeButton *)leftButton {
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:leftButton
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.0
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:leftButton
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0]
                           ]
     ];
}

- (void)placeButton:(ORKPasscodeButton *)button rightOfButton:(ORKPasscodeButton *)rightButton {
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:rightButton
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.0
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:rightButton
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:0]
                           ]
     ];
}

- (void)placeButton:(ORKPasscodeButton *)button topOfButton:(ORKPasscodeButton *)topButton {
    [self addConstraints:@[
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:topButton
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:0],
                           [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:topButton
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0]
                           ]
     ];
}

@end
