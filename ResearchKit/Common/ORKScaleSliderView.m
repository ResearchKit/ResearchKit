/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2015, Bruce Duncan.

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
#import "ORKScaleSlider.h"
#import "ORKScaleRangeLabel.h"
#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleValueLabel.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

@implementation ORKScaleSliderView {
    id<ORKScaleAnswerFormatProvider> _formatProvider;
    ORKScaleSlider *_slider;
    ORKScaleRangeLabel *_leftRangeLabel;
    ORKScaleRangeDescriptionLabel *_leftRangeDescriptionLabel;
    ORKScaleRangeLabel *_rightRangeLabel;
    ORKScaleRangeDescriptionLabel *_rightRangeDescriptionLabel;
    ORKScaleValueLabel *_valueLabel;
}

- (instancetype)initWithFormatProvider:(id<ORKScaleAnswerFormatProvider>)formatProvider {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        
        _leftRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider minimumNumber]];
        _rightRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider maximumNumber]];
        
        _leftRangeDescriptionLabel.text = [formatProvider minimumValueDescription];
        _rightRangeDescriptionLabel.text = [formatProvider maximumValueDescription];
        
        _slider.vertical = [formatProvider isVertical];
        
        _slider.maximumValue = [formatProvider maximumNumber].floatValue;
        _slider.minimumValue = [formatProvider minimumNumber].floatValue;
        
        NSInteger numberOfSteps = [formatProvider numberOfSteps];
        _slider.numberOfSteps = numberOfSteps;
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        _leftRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rightRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSDictionary *views = NSDictionaryOfVariableBindings(_slider, _leftRangeLabel, _rightRangeLabel, _valueLabel,_leftRangeDescriptionLabel, _rightRangeDescriptionLabel);
    
    NSMutableArray *constraints = [NSMutableArray new];
    if ([_formatProvider isVertical]) {
        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        
        // Vertical slider constraints
        // Keep the thumb the same distance from the value label as in horizontal mode
        const CGFloat kValueLabelSliderMargin = 23.0;
        // Keep the shadow of the thumb inside the bounds
        const CGFloat kSliderMargin = 20.0;
        const CGFloat kSideLabelMargin = 24;
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_slider
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-kValueLabelSliderMargin-[_slider]-kSliderMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeadingToTrailing
                                                 metrics:@{@"kValueLabelSliderMargin": @(kValueLabelSliderMargin), @"kSliderMargin": @(kSliderMargin)}
                                                   views:views]];
        
        [constraints addObjectsFromArray
         :[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeLabel(==_leftRangeLabel)]"
                                                  options:(NSLayoutFormatOptions)0
                                                  metrics:nil
                                                    views:views]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeLabel
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_slider
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:-kSideLabelMargin]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeLabel
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_slider
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:-kSideLabelMargin]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeLabel
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_slider
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeLabel
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
        
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_slider
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:kSideLabelMargin]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_slider
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:kSideLabelMargin]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_rightRangeDescriptionLabel
                                                            attribute:NSLayoutAttributeBaseline
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_rightRangeLabel
                                                            attribute:NSLayoutAttributeBaseline
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftRangeDescriptionLabel
                                                            attribute:NSLayoutAttributeBaseline
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_leftRangeLabel
                                                            attribute:NSLayoutAttributeBaseline
                                                           multiplier:1.0
                                                             constant:0.0]];
    } else {
        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
        
        // Horizontal slider constraints
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-[_slider]-(>=8)-|"
                                                 options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_leftRangeDescriptionLabel]-(>=8)-|"
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_rightRangeDescriptionLabel]-(>=8)-|"
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
        
        const CGFloat kMargin = 17.0;
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_leftRangeLabel]-kMargin-[_slider]-kMargin-[_rightRangeLabel(==_leftRangeLabel)]-kMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                 metrics:@{@"kMargin": @(kMargin)}
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_leftRangeDescriptionLabel]-(>=16)-[_rightRangeDescriptionLabel(==_leftRangeDescriptionLabel)]-kMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                 metrics:@{@"kMargin": @(kMargin)}
                                                   views:views]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _slider = [[ORKScaleSlider alloc] initWithFrame:CGRectZero];
        _slider.userInteractionEnabled = YES;
        _slider.contentMode = UIViewContentModeRedraw;
        [self addSubview:_slider];
        
        _leftRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        _leftRangeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_leftRangeLabel];
        
        _leftRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _leftRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_leftRangeDescriptionLabel];
        
        _rightRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        _rightRangeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rightRangeLabel];
        
        _rightRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
        _rightRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_rightRangeDescriptionLabel];

        _valueLabel = [[ORKScaleValueLabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.text = @" ";
        [self addSubview:_valueLabel];
        
#if LAYOUT_DEBUG
        self.backgroundColor = [UIColor greenColor];
        _valueLabel.backgroundColor = [UIColor blueColor];
        _slider.backgroundColor = [UIColor redColor];
        _leftRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
        _rightRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
#endif
    }
    return self;
}

- (void)setCurrentValue:(NSNumber *)value {
    _currentValue = value;
    _slider.showThumb = value? YES : NO;
    
    if (value) {
        NSNumber *newValue = [_formatProvider normalizedValueForNumber:value];
        _slider.value = newValue.floatValue;
        _valueLabel.text = [_formatProvider localizedStringForNumber:newValue];
    } else {
        _valueLabel.text = @"";
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    NSNumber *newValue = [_formatProvider normalizedValueForNumber:@(_slider.value)];
    [self setCurrentValue:newValue];
}

#pragma mark - Accessibility

// Since the slider is the only interesting thing within this cell, we make the
// cell a container with only one element, i.e. the slider.

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return (_slider != nil ? 1 : 0);
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return _slider;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return (element == _slider ? 0 : NSNotFound);
}

@end
