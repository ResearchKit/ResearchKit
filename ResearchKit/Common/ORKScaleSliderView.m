/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2018, Brian Ganninger.
 
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


#import "ORKScaleSliderView.h"

#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleRangeImageView.h"
#import "ORKScaleRangeLabel.h"
#import "ORKScaleSlider.h"
#import "ORKScaleValueLabel.h"
#import "ORKDontKnowButton.h"

#import "ORKAnswerFormat_Internal.h"

#import "ORKSkin.h"

#import "ORKHelpers_Internal.h"

static const CGFloat ValueLabelTopPadding = 16.0;
static const CGFloat ValueLabelBottomPadding = 20.5;
static const CGFloat MoveSliderLabelTopPadding = 8.0;
static const CGFloat MoveSliderLabelBottomPadding = 38.0;
static const CGFloat RangeViewHorizontalPadding = 16.0;
static const CGFloat SliderBottomPadding = 16.0;
static const CGFloat DontKnowButtonTopBottomPadding = 16.0;
static const CGFloat kMargin = 25.0;


// #define LAYOUT_DEBUG 1

@implementation ORKScaleSliderView {
    id<ORKScaleAnswerFormatProvider> _formatProvider;
    UIStackView *_topStackView;
    ORKScaleSlider *_slider;
    UILabel *_moveSliderLabel;
    ORKDontKnowButton *_dontKnowButton;
    UIView *_dontKnowBackgroundView;
    ORKScaleRangeDescriptionLabel *_leftRangeDescriptionLabel;
    ORKScaleRangeDescriptionLabel *_rightRangeDescriptionLabel;
    UIView *_leftRangeView;
    UIView *_rightRangeView;
    UIView *_dividerView;
    ORKScaleValueLabel *_valueLabel;
    NSMutableArray<ORKScaleRangeLabel *> *_textChoiceLabels;
    NSNumber *_currentNumberValue;
    NSMutableArray *constraints;
}

- (instancetype)initWithFormatProvider:(id<ORKScaleAnswerFormatProvider>)formatProvider
                              delegate:(id<ORKScaleSliderViewDelegate>)delegate {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        _delegate = delegate;
        
        _slider = [[ORKScaleSlider alloc] initWithFrame:CGRectZero];
        _slider.hideValueMarkers = [formatProvider shouldHideValueMarkers];
        _slider.isWaitingForUserFeedback = ([formatProvider defaultAnswer] == nil && ![formatProvider isVertical]) ? YES : NO;
        _slider.minimumTrackTintColor = [UIColor systemBlueColor];
        _slider.userInteractionEnabled = YES;
        _slider.contentMode = UIViewContentModeRedraw;
        self.accessibilityElements = [self.accessibilityElements arrayByAddingObject:_slider];
        [self addSubview:_slider];
        
        _slider.maximumValue = [formatProvider maximumNumber].floatValue;
        _slider.minimumValue = [formatProvider minimumNumber].floatValue;
        
        NSInteger numberOfSteps = [formatProvider numberOfSteps];
        _slider.numberOfSteps = numberOfSteps;
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        BOOL isVertical = [formatProvider isVertical];
        _slider.vertical = isVertical;
        
        NSArray<ORKTextChoice *> *textChoices = [[self textScaleFormatProvider] textChoices];
        _slider.textChoices = textChoices;
        
        _slider.gradientColors = [formatProvider gradientColors];
        _slider.gradientLocations = [formatProvider gradientLocations];
        
        if (isVertical && textChoices) {
            // Generate an array of labels for all the text choices
            _textChoiceLabels = [NSMutableArray new];
            for (int i = 0; i <= numberOfSteps; i++) {
                ORKTextChoice *textChoice = textChoices[i];
                ORKScaleRangeLabel *stepLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
                stepLabel.text = textChoice.text;
                stepLabel.textAlignment = NSTextAlignmentLeft;
                stepLabel.numberOfLines = 0;
                stepLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [self addSubview:stepLabel];
                [_textChoiceLabels addObject:stepLabel];
            }
        } else {
            [self setupTopLabels];
            [self setUpSliderAndRangeLabels];
            [self setupRangeDescriptionLabels];
            [self setupDontKnowButton];
            
            _topStackView = [[UIStackView alloc] init];
            _topStackView.axis = UILayoutConstraintAxisHorizontal;
            _topStackView.distribution = UIStackViewDistributionFill;
            _topStackView.alignment = _slider.isWaitingForUserFeedback ? UIStackViewAlignmentLeading : UIStackViewAlignmentCenter;
            _topStackView.translatesAutoresizingMaskIntoConstraints = NO;
           
            [self addSubview:_leftRangeView];
            [self addSubview:_rightRangeView];
            [self addSubview:_leftRangeDescriptionLabel];
            [self addSubview:_rightRangeDescriptionLabel];
            [self addSubview:_valueLabel];

            if (![formatProvider isVertical]) {
                [self addSubview:_topStackView];
                
                [_topStackView addArrangedSubview: _slider.isWaitingForUserFeedback ? _moveSliderLabel : _valueLabel];
                
                if ([formatProvider shouldShowDontKnowButton]) {
                    [self addSubview:_dontKnowBackgroundView];
                    [self addSubview:_dividerView];
                    [self addSubview:_dontKnowButton];
                    self.accessibilityElements = [self.accessibilityElements arrayByAddingObject:_dontKnowButton];
                }
            }
            
            if (textChoices) {
                if (@available(iOS 13.0, *)) {
                    [_leftRangeDescriptionLabel setTextColor:[UIColor labelColor]];
                    [_rightRangeDescriptionLabel setTextColor:[UIColor labelColor]];
                } else {
                    _leftRangeDescriptionLabel.textColor = [UIColor blackColor];
                    _rightRangeDescriptionLabel.textColor = [UIColor blackColor];
                }
                
                _leftRangeLabel.text = @"";
                _rightRangeLabel.text = @"";
            }
            
#if LAYOUT_DEBUG
            self.backgroundColor = [UIColor greenColor];
            _valueLabel.backgroundColor = [UIColor blueColor];
            _slider.backgroundColor = [UIColor redColor];
            _leftRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
            _rightRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
#endif
            
            
            if (isVertical) {
                _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
                _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
            } else {
                _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
                _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
            }
            
            _leftRangeDescriptionLabel.text = [formatProvider shouldHideLabels] ? @"" : [formatProvider minimumValueDescription];
            _rightRangeDescriptionLabel.text = [formatProvider shouldHideLabels] ? @"" : [formatProvider maximumValueDescription];
            
            _moveSliderLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _leftRangeView.translatesAutoresizingMaskIntoConstraints = NO;
            _rightRangeView.translatesAutoresizingMaskIntoConstraints = NO;
            _leftRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _rightRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
            _dontKnowButton.translatesAutoresizingMaskIntoConstraints = NO;
            _dividerView.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setupTopLabels {
    _moveSliderLabel = [UILabel new];
    _moveSliderLabel.text = ORKLocalizedString(@"SLIDER_MOVE_SLIDER_FOR_VALUE", nil);
    _moveSliderLabel.textAlignment = NSTextAlignmentLeft;
    _moveSliderLabel.numberOfLines = 0;
    _moveSliderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIFontDescriptor *moveSliderDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *moveSliderFontDescriptor = [moveSliderDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_moveSliderLabel setFont: [UIFont fontWithDescriptor:moveSliderFontDescriptor size:[[moveSliderFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    if (@available(iOS 13.0, *)) {
        _moveSliderLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        _moveSliderLabel.textColor = [UIColor grayColor];
    }
    
    _valueLabel = [[ORKScaleValueLabel alloc] initWithFrame:CGRectZero];
    _valueLabel.text = @"";
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    UIFontDescriptor *valueLabelDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle2];
    UIFontDescriptor *valueLabelFontDescriptor = [valueLabelDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    [_valueLabel setFont: [UIFont fontWithDescriptor:valueLabelFontDescriptor size:[[valueLabelFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    [_valueLabel setTextColor:[UIColor systemBlueColor]];
}

- (void)setUpSliderAndRangeLabels {
    UIFontDescriptor *rangeLabelDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    UIFontDescriptor *rangeLabelRangeFontDescriptor = [rangeLabelDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    
    _leftRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
    _leftRangeLabel.textAlignment = NSTextAlignmentCenter;
    if (@available(iOS 13.0, *)) {
        [_leftRangeLabel setTextColor:[UIColor labelColor]];
    }
    [_leftRangeLabel setFont: [UIFont fontWithDescriptor:rangeLabelRangeFontDescriptor size:[[rangeLabelRangeFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    _rightRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
    _rightRangeLabel.textAlignment = NSTextAlignmentCenter;
    if (@available(iOS 13.0, *)) {
        [_rightRangeLabel setTextColor:[UIColor labelColor]];
    }
    [_rightRangeLabel setFont: [UIFont fontWithDescriptor:rangeLabelRangeFontDescriptor size:[[rangeLabelRangeFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    if ([_formatProvider minimumImage]) {
        _leftRangeView = [[ORKScaleRangeImageView alloc] initWithImage:[_formatProvider minimumImage]];
    } else {
        ORKScaleRangeLabel *leftRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        leftRangeLabel.textAlignment = NSTextAlignmentCenter;
        leftRangeLabel.text = [_formatProvider localizedStringForNumber:[_formatProvider minimumNumber]];
        if ([_formatProvider shouldHideRanges]) {
            leftRangeLabel.text = @"";
        } else {
            leftRangeLabel.text = [_formatProvider localizedStringForNumber:[_formatProvider minimumNumber]];
        }
        _leftRangeView = leftRangeLabel;
    }
    
    if ([_formatProvider maximumImage]) {
        _rightRangeView = [[ORKScaleRangeImageView alloc] initWithImage:[_formatProvider maximumImage]];
    } else {
        ORKScaleRangeLabel *rightRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        rightRangeLabel.textAlignment = NSTextAlignmentCenter;
        if ([_formatProvider shouldHideRanges]) {
            rightRangeLabel.text = @"";
        } else {
            rightRangeLabel.text = [_formatProvider localizedStringForNumber:[_formatProvider maximumNumber]];
        }
        
        _rightRangeView = rightRangeLabel;
    }
}

- (void)setupRangeDescriptionLabels {
    UIFontDescriptor *rangeDescriptionLabelDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *rangeDescriptionLabelFontDescriptor = [rangeDescriptionLabelDescriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    
    _leftRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
    _leftRangeDescriptionLabel.numberOfLines = 0;
    _leftRangeDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_leftRangeDescriptionLabel setFont: [UIFont fontWithDescriptor:rangeDescriptionLabelFontDescriptor size:[[rangeDescriptionLabelFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    _leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        [_leftRangeDescriptionLabel setTextColor:[UIColor labelColor]];
    }
   
    _rightRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
    _rightRangeDescriptionLabel.numberOfLines = 0;
    _rightRangeDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_rightRangeDescriptionLabel setFont: [UIFont fontWithDescriptor:rangeDescriptionLabelFontDescriptor size:[[rangeDescriptionLabelFontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    _rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        [_rightRangeDescriptionLabel setTextColor:[UIColor labelColor]];
    }
}

- (void)setupDontKnowButton {
    if(!_dontKnowBackgroundView) {
        _dontKnowBackgroundView = [UIView new];

        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        [_dontKnowBackgroundView addGestureRecognizer:tapGesture1];
        _dontKnowBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if (!_dontKnowButton) {
        _dontKnowButton = [ORKDontKnowButton new];
        _dontKnowButton.customDontKnowButtonText = [_formatProvider customDontKnowButtonText];
        [_dontKnowButton addTarget:self action:@selector(dontKnowButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!_dividerView) {
        _dividerView = [UIView new];
        if (@available(iOS 13.0, *)) {
            [_dividerView setBackgroundColor:[UIColor separatorColor]];
        } else {
            [_dividerView setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
}

- (void)setUpConstraints {
    BOOL isVertical = [_formatProvider isVertical];
    NSArray<ORKTextChoice *> *textChoices = _slider.textChoices;
    NSDictionary *views = nil;
    
    if (isVertical && textChoices) {
        views = NSDictionaryOfVariableBindings(_slider);
    } else {
        views = NSDictionaryOfVariableBindings(_topStackView, _slider, _leftRangeView, _rightRangeView, _leftRangeDescriptionLabel, _rightRangeDescriptionLabel, _dividerView, _dontKnowButton, _valueLabel);
    }
    
    if (constraints) {
        [NSLayoutConstraint deactivateConstraints:constraints];
    }
    
    constraints = [NSMutableArray new];
    if (isVertical) {
        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        
        // Vertical slider constraints
        // Keep the thumb the same distance from the value label as in horizontal mode
        const CGFloat ValueLabelSliderMargin = 23.0;
        // Keep the shadow of the thumb inside the bounds
        const CGFloat SliderMargin = 20.0;
        const CGFloat SideLabelMargin = 24;
        
        if (textChoices) {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:0.25
                                                                 constant:0.0]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-kSliderMargin-[_slider]-kSliderMargin-|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:@{@"kSliderMargin": @(SliderMargin)}
                                                       views:views]];
            
            
            for (int i = 0; i < _textChoiceLabels.count; i++) {
                // Put labels to the right side of the slider.
                [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:_slider
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:SideLabelMargin]];
                
                if (i == 0) {
                    // First label
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_slider
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0]];
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:0.75
                                                                         constant:0]];
                    
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:-SideLabelMargin]];
                    
                } else {
                    // Middle labels
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0]];
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0.0]];
                    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i - 1]
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_textChoiceLabels[i]
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0]];
                    
                    // Last label
                    if (i == (_textChoiceLabels.count - 1)) {
                        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_slider
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:0.0]];
                    }
                }
            }
        } else {
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-(>=kValueLabelSliderMargin)-[_slider]-(>=kSliderMargin)-|"
                                                     options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:@{@"kValueLabelSliderMargin": @(ValueLabelSliderMargin), @"kSliderMargin": @(SliderMargin)}
                                                       views:views]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-(>=8)-[_rightRangeDescriptionLabel]"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            
            [constraints addObjectsFromArray
             :[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeView(==_leftRangeView)]"
                                                      options:(NSLayoutFormatOptions)0
                                                      metrics:nil
                                                        views:views]];
            
            // Set the margin between slider and the rangeViews
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeView
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:-SideLabelMargin]];
            
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeView
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:-SideLabelMargin]];
            
            // Align the rangeViews with the slider's bottom
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeDescriptionLabel]-(>=8)-|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_leftRangeDescriptionLabel(==_rightRangeDescriptionLabel)]-(>=8)-|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            
            [constraints addObjectsFromArray:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightRangeDescriptionLabel]-(>=8)-[_leftRangeDescriptionLabel]-(>=8)-|"
                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                     metrics:nil
                                                       views:views]];
            
            // Set the margin between the slider and the descriptionLabels
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:SideLabelMargin]];
            
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_slider
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:SideLabelMargin]];
            
            // Limit the height of the descriptionLabels
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeDescriptionLabel
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                toItem:_slider
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:0.5
                                                              constant:SliderMargin]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeDescriptionLabel
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                toItem:_slider
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:0.5
                                                              constant:SliderMargin]];
            
            
            // Align the descriptionLabels with the rangeViews
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_rightRangeView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
            
            [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:_leftRangeView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
        }
    } else {
        
        [[_topStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kMargin] setActive:YES];
        [[_topStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kMargin] setActive:YES];
        
        //Vertical Constraints
        if (_slider.isWaitingForUserFeedback) {
            [constraints addObject:[_topStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:MoveSliderLabelTopPadding]];
            [constraints addObject:[_slider.topAnchor constraintEqualToAnchor:_topStackView.bottomAnchor constant:MoveSliderLabelBottomPadding]];
        } else {
            [constraints addObject:[_topStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:ValueLabelTopPadding]];
            [constraints addObject:[_slider.topAnchor constraintEqualToAnchor:_topStackView.bottomAnchor constant:ValueLabelBottomPadding]];
        }
        
        [[_leftRangeDescriptionLabel.topAnchor constraintEqualToAnchor:_slider.bottomAnchor constant:SliderBottomPadding] setActive:YES];
        [[_rightRangeDescriptionLabel.topAnchor constraintEqualToAnchor:_slider.bottomAnchor constant:SliderBottomPadding] setActive:YES];
        
        //Horizontal constraints for center elements
        [[_leftRangeView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kMargin] setActive:YES];
        [[_rightRangeView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kMargin] setActive:YES];
        [[_leftRangeView.centerYAnchor constraintEqualToAnchor:_slider.centerYAnchor] setActive:YES];
        [[_rightRangeView.centerYAnchor constraintEqualToAnchor:_slider.centerYAnchor] setActive:YES];
        [[_slider.leadingAnchor constraintEqualToAnchor:_leftRangeView.trailingAnchor constant:RangeViewHorizontalPadding] setActive:YES];
        [[_slider.trailingAnchor constraintEqualToAnchor:_rightRangeView.leadingAnchor constant:-RangeViewHorizontalPadding] setActive:YES];
        
        //Horizontal constraints for bottom elements
        [[_leftRangeDescriptionLabel.leadingAnchor constraintEqualToAnchor:_slider.leadingAnchor] setActive:YES];
        [[_leftRangeDescriptionLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.centerXAnchor] setActive:YES];
        [[_rightRangeDescriptionLabel.trailingAnchor constraintEqualToAnchor:_slider.trailingAnchor] setActive:YES];
        [[_rightRangeDescriptionLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.centerXAnchor] setActive:YES];
        
        UILabel *largerDescriptionLabel = _leftRangeDescriptionLabel.text.length >= _rightRangeDescriptionLabel.text.length ? _leftRangeDescriptionLabel : _rightRangeDescriptionLabel;
        
        //Constraints for dont know button elements
        if ([_formatProvider shouldShowDontKnowButton]) {
            [[_dontKnowBackgroundView.topAnchor constraintEqualToAnchor:_dividerView.topAnchor] setActive:YES];
            [[_dontKnowBackgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor] setActive:YES];
            [[_dontKnowBackgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor] setActive:YES];
            [[_dontKnowBackgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor] setActive:YES];

             CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;

            [[_dividerView.leftAnchor constraintEqualToAnchor:self.leftAnchor] setActive:YES];
            [[_dividerView.rightAnchor constraintEqualToAnchor:self.rightAnchor] setActive:YES];
            [[_dividerView.heightAnchor constraintEqualToConstant:separatorHeight] setActive:YES];
            [[_dividerView.topAnchor constraintGreaterThanOrEqualToAnchor: largerDescriptionLabel.bottomAnchor constant:8.0] setActive:YES];

            [[_dontKnowButton.topAnchor constraintGreaterThanOrEqualToAnchor:_dividerView.bottomAnchor constant:DontKnowButtonTopBottomPadding] setActive:YES];
            [[_dontKnowButton.centerXAnchor constraintEqualToAnchor:_dividerView.centerXAnchor] setActive:YES];
            
            [[self.bottomAnchor constraintEqualToAnchor:_dontKnowButton.bottomAnchor constant:DontKnowButtonTopBottomPadding] setActive: YES];
        } else {
            [[self.bottomAnchor constraintEqualToAnchor:largerDescriptionLabel.bottomAnchor constant:8.0] setActive: YES];
        }
        
    }
    
    if ([_formatProvider shouldHideSelectedValueLabel] &&
             !([_formatProvider isVertical] && [self textScaleFormatProvider]) && !_slider.isWaitingForUserFeedback) {
        _valueLabel.layer.opacity = 0.0;
    } else {
         _valueLabel.layer.opacity = 1.0;
    }
       
    [NSLayoutConstraint activateConstraints:constraints];
}

- (id<ORKTextScaleAnswerFormatProvider>)textScaleFormatProvider {
    if ([[_formatProvider class] conformsToProtocol:@protocol(ORKTextScaleAnswerFormatProvider)]) {
        return (id<ORKTextScaleAnswerFormatProvider>)_formatProvider;
    }
    return nil;
}

- (void)setCurrentNumberValue:(NSNumber *)value {
    _currentNumberValue = value ? [_formatProvider normalizedValueForNumber:value] : nil;
    _slider.showThumb = YES;
    
    if (_currentNumberValue && _slider.isWaitingForUserFeedback) {
        [self resetViewToDefault];
    }
    
    [self updateCurrentValueLabel];
    _slider.value = _currentNumberValue.floatValue;
}

- (NSUInteger)currentTextChoiceIndex {
    return _currentNumberValue.unsignedIntegerValue - 1;
}

- (void)updateCurrentValueLabel {
    
    if (_currentNumberValue) {
        if ([self textScaleFormatProvider]) {
            ORKTextChoice *textChoice = [[self textScaleFormatProvider] textChoiceAtIndex:[self currentTextChoiceIndex]];
            self.valueLabel.text = textChoice.text;
            if (textChoice.primaryTextAttributedString) {
                self.valueLabel.attributedText = textChoice.primaryTextAttributedString;
            }
        } else {
            NSNumber *newValue = [_formatProvider normalizedValueForNumber:_currentNumberValue];
            _valueLabel.text = [_formatProvider localizedStringForNumber:newValue];
        }
    } else {
        _valueLabel.text = @"";
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    if (_slider.isWaitingForUserFeedback) {
        [self resetViewToDefault];
    }
    
    if (_dontKnowButton && [_dontKnowButton isDontKnowButtonActive]) {
        [_dontKnowButton setButtonInactive];
    }
    
    _currentNumberValue = [_formatProvider normalizedValueForNumber:@(_slider.value)];
    [self updateCurrentValueLabel];
    [self notifyDelegate];
}

- (void)resetViewToDefault {
    _slider.isWaitingForUserFeedback = NO;
    [_topStackView removeArrangedSubview:_moveSliderLabel];
    [_moveSliderLabel removeFromSuperview];
    [_topStackView addArrangedSubview:_valueLabel];
     _topStackView.alignment = UIStackViewAlignmentCenter;
    
    [NSLayoutConstraint deactivateConstraints:constraints];
    [constraints removeAllObjects];
    [self setUpConstraints];
}

- (void)dontKnowButtonWasPressed {

    if (_dontKnowButton && ![_dontKnowButton isDontKnowButtonActive]) {
        [_slider setShowThumb:YES];
        [_dontKnowButton setButtonActive];
        _currentNumberValue = nil;
        [self notifyDelegate];
    }

    if (!_slider.isWaitingForUserFeedback) {
        _slider.isWaitingForUserFeedback = YES;
        
        [_topStackView removeArrangedSubview:_valueLabel];
        [_valueLabel removeFromSuperview];
        
        [_topStackView addArrangedSubview:_moveSliderLabel];
        _topStackView.alignment = UIStackViewAlignmentLeading;
        
        [NSLayoutConstraint deactivateConstraints:constraints];
        [constraints removeAllObjects];
        [self setUpConstraints];
        _slider.value =  [_formatProvider minimumNumber].floatValue;
    }
}

- (void) tapGesture: (id)sender {
    //this tap gesture is here to avoid the cell being selected if the user missed the dont know button
}

- (void)notifyDelegate {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scaleSliderViewCurrentValueDidChange:)]) {
        [self.delegate scaleSliderViewCurrentValueDidChange:self];
    }
}

- (void)setCurrentTextChoiceValue:(id<NSCopying, NSCoding, NSObject>)currentTextChoiceValue {
    
    if (currentTextChoiceValue) {
        NSUInteger index = [[self textScaleFormatProvider] textChoiceIndexForValue:currentTextChoiceValue];
        if (index != NSNotFound) {
            [self setCurrentNumberValue:@(index + 1)];
        } else {
            [self setCurrentNumberValue:nil];
        }
    } else {
        [self setCurrentNumberValue:nil];
    }
}

- (id<NSCopying, NSCoding, NSObject>)currentTextChoiceValue {
    id<NSCopying, NSCoding, NSObject> value = [[self textScaleFormatProvider] textChoiceAtIndex:[self currentTextChoiceIndex]].value;
    return value;
}

- (id)currentAnswerValue {
    if ([_dontKnowButton isDontKnowButtonActive]) {
        return [ORKDontKnowAnswer answer];
    }
    if ([self textScaleFormatProvider]) {
        id<NSCopying, NSCoding, NSObject> value = [self currentTextChoiceValue];
        return value ? @[value] : @[];
    } else {
        return _currentNumberValue;
    }
}

- (void)setCurrentAnswerValue:(id)currentAnswerValue {
    if (currentAnswerValue == [ORKDontKnowAnswer answer] && _dontKnowButton) {
        [self dontKnowButtonWasPressed];
    } else if ([self textScaleFormatProvider]) {
        
        if (ORKIsAnswerEmpty(currentAnswerValue)) {
            [self setCurrentTextChoiceValue:nil];
        } else {
            [self setCurrentTextChoiceValue:[currentAnswerValue firstObject]];
        }
    } else {
        [self setCurrentNumberValue:currentAnswerValue];
    }
    
}

#pragma mark - Accessibility

// Since the slider is the only interesting thing within this cell, we make the
// cell a container with only one element, i.e. the slider.

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return [self.accessibilityElements objectAtIndex:index];
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return [self.accessibilityElements indexOfObject:element];
}

@end
