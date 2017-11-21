/*
 Copyright (c) 2017, Apple Inc. All rights reserved.
 
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


#import "ORKStroopContentView.h"
#import "ORKUnitLabel.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKBorderedButton.h"


@implementation ORKStroopContentView {
    UILabel *_colorLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _colorLabel = [UILabel new];
        _colorLabel.numberOfLines = 1;
        _colorLabel.textAlignment = NSTextAlignmentCenter;
        _colorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_colorLabel setFont:[UIFont systemFontOfSize:60]];
        [_colorLabel setAdjustsFontSizeToFitWidth:YES];
        
        
        self.RButton = [[ORKBorderedButton alloc] init];
        self.RButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.RButton setTitle:ORKLocalizedString(@"STROOP_COLOR_RED_INITIAL", nil) forState:UIControlStateNormal];
        
        self.GButton = [[ORKBorderedButton alloc] init];
        self.GButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.GButton setTitle:ORKLocalizedString(@"STROOP_COLOR_GREEN_INITIAL", nil) forState:UIControlStateNormal];
        
        self.BButton = [[ORKBorderedButton alloc] init];
        self.BButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.BButton setTitle:ORKLocalizedString(@"STROOP_COLOR_BLUE_INITIAL", nil) forState:UIControlStateNormal];
        
        self.YButton = [[ORKBorderedButton alloc] init];
        self.YButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.YButton setTitle:ORKLocalizedString(@"STROOP_COLOR_YELLOW_INITIAL", nil) forState:UIControlStateNormal];
        
        [self addSubview:_colorLabel];
        [self addSubview:self.RButton];
        [self addSubview:self.GButton];
        [self addSubview:self.BButton];
        [self addSubview:self.YButton];
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setColorLabelText:(NSString *)colorLabelText {
    [_colorLabel setText:colorLabelText];
    [self setNeedsDisplay];
}

- (void)setColorLabelColor:(UIColor *)colorLabelColor {
    [_colorLabel setTextColor:colorLabelColor];
    [self setNeedsDisplay];
}

- (NSString *)colorLabelText {
    return _colorLabel.text;
}

- (UIColor *)colorLabelColor {
    return _colorLabel.textColor;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_colorLabel, _RButton, _GButton, _BButton, _YButton);
    CGFloat minimumButtonHeight = 60;
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_colorLabel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:self.RButton
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.RButton
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.GButton
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.GButton
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.BButton
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.BButton
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.YButton
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight],
                                       [NSLayoutConstraint constraintWithItem:self.YButton
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:minimumButtonHeight]
                                       ]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_colorLabel]-(==300)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=10)-[_colorLabel]-(>=10)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_RButton]-(==100)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:self.GButton
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:-10.0],
                                       [NSLayoutConstraint constraintWithItem:self.BButton
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:10.0],
                                       [NSLayoutConstraint constraintWithItem:self.RButton
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.GButton
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:-20.0],
                                       [NSLayoutConstraint constraintWithItem:self.YButton
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.BButton
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1.0
                                                                     constant:20.0],
                                       [NSLayoutConstraint constraintWithItem:self.GButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.RButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:self.BButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.RButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:self.YButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.RButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0.0]]];

    [self addConstraints:constraints];
    [NSLayoutConstraint activateConstraints:constraints];
}

@end

