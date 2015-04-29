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
#import "ORKScaleValueLabel.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

@interface ORKScaleSliderView () <ORKScaleSliderLayoutWidthProvider>

@property (nonatomic, strong) id<ORKScaleAnswerFormatProvider> formatProvider;

@property (nonatomic, strong) ORKScaleSlider *slider;

@property (nonatomic, strong) ORKScaleRangeLabel *leftRangeLabel;

@property (nonatomic, strong) ORKScaleRangeLabel *rightRangeLabel;

@property (nonatomic, strong) ORKScaleValueLabel *valueLabel;

@property (nonatomic) CGFloat previousLayoutWidth;

@end


@implementation ORKScaleSliderView

- (instancetype)initWithFormatProvider:(id<ORKScaleAnswerFormatProvider>)formatProvider {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        
        self.leftRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider minimumNumber]];
        self.rightRangeLabel.text = [formatProvider localizedStringForNumber:[formatProvider maximumNumber]];
        
        self.slider.vertical = [formatProvider isVertical];
        
        self.slider.maximumValue = [[formatProvider maximumNumber] floatValue];
        self.slider.minimumValue = [[formatProvider minimumNumber] floatValue];
        
        NSInteger numberOfSteps = [formatProvider numberOfSteps];
        self.slider.numberOfSteps = numberOfSteps;
        
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
        self.slider.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_slider,_leftRangeLabel,_rightRangeLabel, _valueLabel);
        
        if ([formatProvider isVertical]) {
            // Vertical slider constraints
            // Keep the thumb the same distance from the value label as in horizontal mode
            const CGFloat kValueLabelSliderMargin = 23.0;
            // Keep the shadow of the thumb inside the bounds
            const CGFloat kSliderMargin = 20.0;
            const CGFloat kSideLabelMargin = 24;
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kVerticalSliderHorizontalMargin-[_slider]-kVerticalSliderHorizontalMargin-|"
                                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                                         metrics:@{@"kVerticalSliderHorizontalMargin": @(kVerticalSliderHorizontalMargin)}
                                                                           views:views]];

            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-kValueLabelSliderMargin-[_slider]-kSliderMargin-|"
                                                                         options:NSLayoutFormatAlignAllCenterX|NSLayoutFormatDirectionLeadingToTrailing
                                                                         metrics:@{@"kValueLabelSliderMargin": @(kValueLabelSliderMargin), @"kSliderMargin": @(kSliderMargin)}
                                                                           views:views]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightRangeLabel(==_leftRangeLabel)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:views]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.slider
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:-kSideLabelMargin]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeLabel
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.slider
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:-kSideLabelMargin]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightRangeLabel
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.slider
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0]];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftRangeLabel
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.slider
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0]];
        } else {
            // Horizontal slider constraints
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_valueLabel]-[_slider]-(>=8)-|"
                                                                         options:NSLayoutFormatAlignAllCenterX|NSLayoutFormatDirectionLeadingToTrailing
                                                                         metrics:nil
                                                                           views:views]];
        
            const CGFloat kMargin = 17.0;
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_leftRangeLabel]-kMargin-[_slider]-kMargin-[_rightRangeLabel(==_leftRangeLabel)]-kMargin-|"
                                                                         options:NSLayoutFormatAlignAllCenterY|NSLayoutFormatDirectionLeadingToTrailing
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
        self.slider.delegate = self;
        [self addSubview:_slider];
        
        self.leftRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        self.leftRangeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_leftRangeLabel];
        
        self.rightRangeLabel = [[ORKScaleRangeLabel alloc] initWithFrame:CGRectZero];
        self.rightRangeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_rightRangeLabel];

        self.valueLabel = [[ORKScaleValueLabel alloc] initWithFrame:CGRectZero];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.text = @" ";
        [self addSubview:_valueLabel];
        
#if LAYOUT_DEBUG
        self.valueLabel.backgroundColor = [UIColor blueColor];
        self.slider.backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor greenColor];
#endif
    }
    return self;
}

- (void)setCurrentValue:(NSNumber *)value {
    _currentValue = value;
    self.slider.showThumb = value? YES : NO;
    
    if (value) {
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

static const CGFloat kVerticalSliderHorizontalMargin = 48;

-(CGFloat)sliderLayoutWidth {
    // Use the delegate expected width, if available, or if we have no delegate, then use our own width.
    // Subtract the left and right margins from the width, to give the appropriate slider width.
    return (self.delegate ? self.delegate.sliderLayoutWidth : self.previousLayoutWidth)-(kVerticalSliderHorizontalMargin*2);
}

-(void)layoutSubviews {
    [super layoutSubviews];
    // This is currently only used by vertical sliders, but keep track of the width to implement the Protocol anyway
    CGFloat currentLayoutWidth = self.delegate ? self.delegate.sliderLayoutWidth : self.bounds.size.width;
    if(self.previousLayoutWidth != currentLayoutWidth) {
        self.previousLayoutWidth = currentLayoutWidth;
        if ([_formatProvider isVertical]) {
            [self.slider invalidateIntrinsicContentSize];
        }
    }
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
