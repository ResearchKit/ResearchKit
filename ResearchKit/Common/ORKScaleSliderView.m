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
#import "ORKScaleRangeImageView.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

@interface ORKScaleSliderView ()

@property (nonatomic, strong) id<ORKScaleAnswerFormatProvider> formatProvider;

@property (nonatomic, strong) ORKScaleSlider *slider;

@property (nonatomic, strong) ORKScaleRangeLabel *leftRangeLabel;

@property (nonatomic, strong) ORKScaleRangeImageView *leftRangeImageView;

@property (nonatomic, strong) ORKScaleRangeDescriptionLabel *leftRangeDescriptionLabel;

@property (nonatomic, strong) ORKScaleRangeLabel *rightRangeLabel;

@property (nonatomic, strong) ORKScaleRangeImageView *rightRangeImageView;

@property (nonatomic, strong) ORKScaleRangeDescriptionLabel *rightRangeDescriptionLabel;

@property (nonatomic, strong) ORKScaleValueLabel *valueLabel;

@end


@implementation ORKScaleSliderView

- (instancetype)initWithFormatProvider:(id<ORKScaleAnswerFormatProvider>)formatProvider {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        
        UIView *rightRangeView = nil;
        UIView *leftRangeView = nil;
        
        self.slider.textChoices = [formatProvider textChoices];
        
        if ([formatProvider minimumImage]) {
            self.leftRangeImageView = [[ORKScaleRangeImageView alloc] initWithImage:[formatProvider minimumImage]];
            leftRangeView = self.leftRangeImageView;
        } else {
            self.leftRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
            self.leftRangeLabel.textAlignment = NSTextAlignmentCenter;
            self.leftRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider minimumNumber]];
            leftRangeView = self.leftRangeLabel;
        }
        
        if ([formatProvider maximumImage]) {
            self.rightRangeImageView = [[ORKScaleRangeImageView alloc] initWithImage:[formatProvider maximumImage]];
            rightRangeView = self.rightRangeImageView;
        } else {
            self.rightRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
            self.rightRangeLabel.textAlignment = NSTextAlignmentCenter;
            self.rightRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider maximumNumber]];
            rightRangeView = self.rightRangeLabel;
        }
        
        [self addSubview:leftRangeView];
        [self addSubview:rightRangeView];
        
        self.leftRangeDescriptionLabel.text = [formatProvider minimumValueDescription];
        self.rightRangeDescriptionLabel.text = [formatProvider maximumValueDescription];
        
        self.slider.vertical = [formatProvider isVertical];
        
        self.slider.maximumValue = [[formatProvider maximumNumber] floatValue];
        self.slider.minimumValue = [[formatProvider minimumNumber] floatValue];
        
        NSInteger numberOfSteps = [formatProvider numberOfSteps];
        self.slider.numberOfSteps = numberOfSteps;
        
        if (self.slider.textChoices) {
            self.leftRangeDescriptionLabel.textColor = [UIColor blackColor];
            self.rightRangeDescriptionLabel.textColor = [UIColor blackColor];
            self.leftRangeLabel.text = @"";
            self.rightRangeLabel.text = @"";
        }
        
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
        leftRangeView.translatesAutoresizingMaskIntoConstraints = NO;
        rightRangeView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.slider.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_slider, leftRangeView, rightRangeView, _valueLabel, _leftRangeDescriptionLabel, _rightRangeDescriptionLabel);
        
        if ([formatProvider isVertical]) {
            // Vertical slider constraints
            // Keep the thumb the same distance from the value label as in horizontal mode
            const CGFloat kValueLabelSliderMargin = 23.0;
            // Keep the shadow of the thumb inside the bounds
            const CGFloat kSliderMargin = 20.0;
            const CGFloat kSideLabelMargin = 24;
            
            if (self.slider.textChoices) {
                // Remove the extra controls from superview.
                [_valueLabel removeFromSuperview];
                [leftRangeView removeFromSuperview];
                [rightRangeView removeFromSuperview];
                [_leftRangeDescriptionLabel removeFromSuperview];
                [_rightRangeDescriptionLabel removeFromSuperview];
                
                // Generating an array of labels for all the text choices.
                NSMutableArray *textChoiceLabels = [NSMutableArray new];
                for (int i = 0; i <= self.slider.numberOfSteps; i++) {
                    ORKTextChoice *textChoice = self.slider.textChoices[i];
                    ORKScaleRangeLabel *stepLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
                    stepLabel.text = textChoice.text;
                    stepLabel.textAlignment = NSTextAlignmentLeft;
                    stepLabel.translatesAutoresizingMaskIntoConstraints = NO;
                    [self addSubview:stepLabel];
                    [textChoiceLabels addObject:stepLabel];
                }
            
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_slider
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
                
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-kSliderMargin-[_slider]-kSliderMargin-|"
                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:@{@"kSliderMargin": @(kSliderMargin)}
                                                           views:views]];
                
                
                for (int i = 0; i < textChoiceLabels.count; i++) {
                    
                    // Move to the right side of the slider.
                    [self addConstraint:[NSLayoutConstraint constraintWithItem:textChoiceLabels[i]
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.slider
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:kSideLabelMargin]];
                    
                    if (i == 0) {
                        
                        /*
                         First label constraints
                         */
                        [self addConstraints:@[
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0],
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.slider
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0],
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:0.5
                                                                             constant:0]
                                               ]];
                    } else {
                        
                        /*
                         In-between labels constraints
                         */
                        
                        [self addConstraints:@[
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i-1]
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0],
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i-1]
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:0],
                                               [NSLayoutConstraint constraintWithItem:textChoiceLabels[i-1]
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:textChoiceLabels[i]
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0]
                                               ]];
                        
                        /*
                         Last label constraints
                         */
                        if (i==textChoiceLabels.count-1) {
                            [self addConstraint:[NSLayoutConstraint constraintWithItem:textChoiceLabels[i]
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.slider
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0]];
                        }
                    }
                }

            } else {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:_slider
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
                
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-(>=kValueLabelSliderMargin)-[_slider]-(>=kSliderMargin)-|"
                                                         options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:@{@"kValueLabelSliderMargin": @(kValueLabelSliderMargin), @"kSliderMargin": @(kSliderMargin)}
                                                           views:views]];
                    
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-(>=8)-[_rightRangeDescriptionLabel]"
                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:nil
                                                           views:views]];
                
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightRangeView(==leftRangeView)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

                // Set the margin between `slider` and `rangeView`
                [self addConstraint:[NSLayoutConstraint constraintWithItem:rightRangeView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.slider
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:-kSideLabelMargin]];
                
                [self addConstraint:[NSLayoutConstraint constraintWithItem:leftRangeView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.slider
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:-kSideLabelMargin]];

                // Align range view with slider's bottom
                [self addConstraint:[NSLayoutConstraint constraintWithItem:rightRangeView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.slider
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0]];
                
                [self addConstraint:[NSLayoutConstraint constraintWithItem:leftRangeView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.slider
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0]];
                
                self.leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
                self.rightRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
                
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeDescriptionLabel]-(>=8)-|"
                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:nil
                                                           views:views]];
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_leftRangeDescriptionLabel(==_rightRangeDescriptionLabel)]-(>=8)-|"
                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:nil
                                                           views:views]];
                
                [self addConstraints:
                 [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_rightRangeDescriptionLabel]-(>=8)-[_leftRangeDescriptionLabel]-(>=8)-|"
                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                         metrics:nil
                                                           views:views]];
                
                
                // Set the margin between `slider` and `descriptionLabels`
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.slider
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:kSideLabelMargin]];
                
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.slider
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:kSideLabelMargin]];
                    
                // Limit the height of descriptionLabels
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:_slider
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.5
                                                                  constant:kSliderMargin]];
                    
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:_slider
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.5
                                                                  constant:kSliderMargin]];
                
                // Align descriptionLabel with rangeView
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rightRangeView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
                
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeDescriptionLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:leftRangeView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
            }
            
        } else {

            self.leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
            self.rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
            
            // Horizontal slider constraints
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-[_slider]-(>=8)-|"
                                                     options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeftToRight
                                                     metrics:nil
                                                       views:views]];
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_leftRangeDescriptionLabel]-(>=8)-|"
                                                     options:NSLayoutFormatDirectionLeftToRight
                                                     metrics:nil
                                                       views:views]];
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_rightRangeDescriptionLabel]-(>=8)-|"
                                                     options:NSLayoutFormatDirectionLeftToRight
                                                     metrics:nil
                                                       views:views]];
        
            const CGFloat kMargin = 17.0;
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[leftRangeView]-kMargin-[_slider]-kMargin-[rightRangeView(==leftRangeView)]-kMargin-|"
                                                     options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                     metrics:@{@"kMargin": @(kMargin)}
                                                       views:views]];
            [self addConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_leftRangeDescriptionLabel]-(>=16)-[_rightRangeDescriptionLabel(==_leftRangeDescriptionLabel)]-kMargin-|"
                                                     options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                     metrics:@{@"kMargin": @(kMargin)}
                                                       views:views]];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.slider = [[ORKScaleSlider alloc] initWithFrame:CGRectZero];
        self.slider.userInteractionEnabled = YES;
        self.slider.contentMode = UIViewContentModeRedraw;
        [self addSubview:_slider];
        
        self.leftRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        self.leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        self.leftRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_leftRangeDescriptionLabel];
        
        self.rightRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        self.rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
        self.rightRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_rightRangeDescriptionLabel];

        self.valueLabel = [[ORKScaleValueLabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.text = @" ";
        [self addSubview:_valueLabel];
        
#if LAYOUT_DEBUG
        self.valueLabel.backgroundColor = [UIColor blueColor];
        self.slider.backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor greenColor];
        self.leftRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
        self.rightRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
#endif
    }
    return self;
}

- (void)setCurrentValue:(NSNumber *)value {
    _currentValue = value;
    self.slider.showThumb = value? YES : NO;
    
    NSArray *textChoices = [_formatProvider textChoices];
    
    if (textChoices && value) {
        ORKTextChoice *textChoice = textChoices[MAX(0, [value intValue] - 1)];
        self.valueLabel.text = textChoice.text;
    } else if (value) {
        NSNumber *newValue = [_formatProvider normalizedValueForNumber:value];
        self.slider.value = [newValue floatValue];
        self.valueLabel.text = [_formatProvider localizedStringForNumber:newValue];
    } else {
        self.valueLabel.text = @"";
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    NSNumber *newValue = [_formatProvider normalizedValueForNumber:@(self.slider.value)];
    [self setCurrentValue:newValue];
}

#pragma mark - Accessibility

// Since the slider is the only interesting thing within this cell, we make the
// cell a container with only one element, i.e. the slider.

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    return (self.slider != nil ? 1 : 0);
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return self.slider;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return (element == self.slider ? 0 : NSNotFound);
}

@end
