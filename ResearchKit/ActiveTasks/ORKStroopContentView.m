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


CGFloat minimumButtonHeight = 60;
UIStackViewAlignment alignment = UILayoutConstraintAxisHorizontal;
CGFloat labelHeight = 250.0;
CGFloat labelWidth = 250.0;
static const CGFloat buttonStackViewSpacing = 20.0;


@implementation ORKStroopContentView {
    UILabel *_colorLabel;
    UIStackView *_buttonStackView;
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
        
        ORKScreenType screenType = ORKGetVerticalScreenTypeForWindow([[[UIApplication sharedApplication] delegate] window]);
        
        if (screenType == ORKScreenTypeiPhone5 ) {
            labelWidth = 200.0;
            labelHeight = 200.0;
        } else {
            labelWidth = 250.0;
            labelHeight = 250.0;
        }
    
        [self setupDefaultButtons];
        
        [self addSubview:_colorLabel];
        
        [self setUpConstraints];
    }
    return self;
}


-(void)setupButtons {
    _RButton = [[ORKBorderedButton alloc] init];
    [_RButton setNormalTintColor:[UIColor blackColor]];

    _RButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_RButton setTitle:ORKLocalizedString(@"STROOP_COLOR_RED_INITIAL", nil) forState:UIControlStateNormal];

    _GButton = [[ORKBorderedButton alloc] init];
    [_GButton setNormalTintColor:[UIColor blackColor]];

    _GButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_GButton setTitle:ORKLocalizedString(@"STROOP_COLOR_GREEN_INITIAL", nil) forState:UIControlStateNormal];

    _BButton = [[ORKBorderedButton alloc] init];
    [_BButton setNormalTintColor:[UIColor blackColor]];

    _BButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_BButton setTitle:ORKLocalizedString(@"STROOP_COLOR_BLUE_INITIAL", nil) forState:UIControlStateNormal];

    _YButton = [[ORKBorderedButton alloc] init];
    [_YButton setNormalTintColor:[UIColor blackColor]];

    _YButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_YButton setTitle:ORKLocalizedString(@"STROOP_COLOR_YELLOW_INITIAL", nil) forState:UIControlStateNormal];
    
}

-(void)setupDefaultButtons {
    [self setupButtons];
    if (!_buttonStackView) {
        _buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_RButton, _GButton, _BButton, _YButton]];
        alignment = UILayoutConstraintAxisHorizontal;
    }
    
    minimumButtonHeight = 60;
    
    _buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _buttonStackView.spacing = buttonStackViewSpacing;
    _buttonStackView.axis = alignment;
    [self addSubview:_buttonStackView];
    
}

-(void)setupGridButtons {
    if (_useGridLayoutForButtons) {
        [self setupButtons];

        [_buttonStackView removeFromSuperview];
        UIStackView* stack1 = [[UIStackView alloc] initWithArrangedSubviews:@[_RButton, _GButton]];
        UIStackView* stack2 = [[UIStackView alloc] initWithArrangedSubviews:@[_BButton, _YButton]];
        
        stack1.translatesAutoresizingMaskIntoConstraints = NO;
        stack1.spacing = buttonStackViewSpacing;
        stack1.axis = UILayoutConstraintAxisHorizontal;
        
        stack2.translatesAutoresizingMaskIntoConstraints = NO;
        stack2.spacing = buttonStackViewSpacing;
        stack2.axis = UILayoutConstraintAxisHorizontal;
        
        _buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[stack1,stack2]];
        
        _buttonStackView.axis = UILayoutConstraintAxisVertical;
        
        ORKScreenType screenType = ORKGetVerticalScreenTypeForWindow([[[UIApplication sharedApplication] delegate] window]);
        
        if (screenType == ORKScreenTypeiPhone6) {
            minimumButtonHeight = 150.0;
        } else if (screenType == ORKScreenTypeiPhone5 ) {
            minimumButtonHeight = 100.0;
        } else {
            minimumButtonHeight = 200;
        }
        
        alignment = UILayoutConstraintAxisVertical;
        _buttonStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _buttonStackView.spacing = buttonStackViewSpacing;
        _buttonStackView.axis = alignment;
        
        [self addSubview:_buttonStackView];
        [self setUpConstraints];
    }
}

- (void)setUseGridLayoutForButtons:(bool)useGridLayoutForButtons{
    _useGridLayoutForButtons = useGridLayoutForButtons;
    [self setupGridButtons];

}

-(void)setUseTextForStimuli:(bool)useTextForStimuli{
    _useTextForStimuli = useTextForStimuli;
    if (!_useTextForStimuli) {
        [_colorLabel setFont:[UIFont boldSystemFontOfSize:60]];
    }
}

- (void)setColorLabelText:(NSString *)colorLabelText {
    [_colorLabel setText:colorLabelText];
    [self setNeedsDisplay];
}

- (void)setColorLabelColor:(UIColor *)colorLabelColor {
    [_colorLabel setTextColor:colorLabelColor];
    if (!_useTextForStimuli) {
        [_colorLabel setBackgroundColor:colorLabelColor];
    }
    [self setNeedsDisplay];
}

- (NSString *)colorLabelText {
    return _colorLabel.text;
}

- (UIColor *)colorLabelColor {
    return _colorLabel.textColor;
}

- (void)setUpConstraints {

    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSDictionary *views = NSDictionaryOfVariableBindings(_colorLabel, _buttonStackView);

    int bottomStackViewSpace = _useGridLayoutForButtons ? 90 : 30;

    NSString * constraintString = [NSString stringWithFormat: @"V:|-(==30)-[_colorLabel]-(>=10)-[_buttonStackView]-(==%d)-|", bottomStackViewSpace];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    NSArray *baseLayouts = @[[NSLayoutConstraint constraintWithItem:_buttonStackView
                                       attribute:NSLayoutAttributeHeight
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:nil
                                       attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0
                                        constant:minimumButtonHeight],
          [NSLayoutConstraint constraintWithItem:_buttonStackView
                                       attribute:NSLayoutAttributeCenterX
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:self
                                       attribute:NSLayoutAttributeCenterX
                                      multiplier:1.0
                                        constant:0.0]];

    [constraints addObjectsFromArray:baseLayouts];

    if (!_useTextForStimuli) {

        [constraints addObjectsFromArray: @[[NSLayoutConstraint constraintWithItem:_colorLabel
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:labelWidth],
                                           [NSLayoutConstraint constraintWithItem:_colorLabel
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant: labelHeight],
                                           [NSLayoutConstraint constraintWithItem:_buttonStackView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:minimumButtonHeight]]];
    }

    for (ORKBorderedButton *button in @[_RButton, _GButton, _BButton, _YButton]) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:button
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:button
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0.0]];
    }

    [self addConstraints:constraints];
    [NSLayoutConstraint activateConstraints:constraints];
}

@end

