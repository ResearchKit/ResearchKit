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


#import "ORKPasscodeStepView.h"


@implementation ORKPasscodeStepView {
    ORKPasscodeTextField *_textField;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Additional configuration for the passcode text field.
        _textField = [ORKPasscodeTextField new];
        _textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.stepView = _textField;
        
        // Setting image view with app icon (if available).
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        self.headerView.iconImageView.image = [UIImage imageNamed:icon];
        self.headerView.iconImageView.layer.cornerRadius = 15.0;
        self.headerView.iconImageView.layer.masksToBounds = YES;
        self.headerView.iconImageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        self.headerView.iconImageView.layer.borderWidth = 1.0;

        
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:_textField
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0]
                               ]
         ];
        
    }
    return self;
}

- (ORKPasscodeTextField *)textField {
    return _textField;
}

@end
