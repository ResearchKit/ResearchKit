//
//  ORKVASSliderView.m
//  ResearchKit
//
//  Created by Janusz Bień on 16.03.2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKVASSliderView.h"
#import "ORKVASSlider.h"
#import "ORKScaleRangeLabel.h"
#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleValueLabel.h"
#import "ORKScaleRangeImageView.h"
#import "ORKSkin.h"


// #define LAYOUT_DEBUG 1

@implementation ORKVASSliderView {
    id<ORKVASAnswerFormatProvider> _formatProvider;
    ORKVASSlider *_slider;
    ORKScaleRangeDescriptionLabel *_leftRangeDescriptionLabel;
    ORKScaleRangeDescriptionLabel *_rightRangeDescriptionLabel;
    NSNumber *_currentNumberValue;
}

- (instancetype)initWithFormatProvider:(id<ORKVASAnswerFormatProvider>)formatProvider
                              delegate:(id<ORKVASSliderViewDelegate>)delegate {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        _formatProvider = formatProvider;
        _delegate = delegate;
        
        _slider = [[ORKVASSlider alloc] initWithFrame:CGRectZero];
        _slider.userInteractionEnabled = YES;
        _slider.contentMode = UIViewContentModeRedraw;
        [self addSubview:_slider];
        _slider.maximumValue = [formatProvider maximumNumber].floatValue;
        _slider.minimumValue = [formatProvider minimumNumber].floatValue;
        
        _slider.numberOfSteps = 100;
        _slider.markerStyle = [formatProvider markerStyle];
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        _leftRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        _leftRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_leftRangeDescriptionLabel];
        
        _rightRangeDescriptionLabel = [[ORKScaleRangeDescriptionLabel alloc] initWithFrame:CGRectZero];
        _rightRangeDescriptionLabel.numberOfLines = -1;
        [self addSubview:_rightRangeDescriptionLabel];
        
        CGRect arrowFrame = CGRectMake(0.0f, 0.0f, 11.0f, 54.0f);
        UIImage *arrowImage = [self arrowImageInRect:arrowFrame];
        _leftArrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _leftArrowView.contentMode = UIViewContentModeCenter;
        _leftArrowView.image = arrowImage;
        [self addSubview:_leftArrowView];
        
        _rightArrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rightArrowView.contentMode = UIViewContentModeCenter;
        _rightArrowView.image = arrowImage;
        [self addSubview:_rightArrowView];
        
            
#if LAYOUT_DEBUG
        self.backgroundColor = [UIColor greenColor];
        _slider.backgroundColor = [UIColor redColor];
        _leftRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
        _rightRangeDescriptionLabel.backgroundColor = [UIColor yellowColor];
#endif
        _leftRangeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
        _rightRangeDescriptionLabel.textAlignment = NSTextAlignmentRight;
            
        _leftRangeDescriptionLabel.text = [formatProvider minimumValueDescription];
        _rightRangeDescriptionLabel.text = [formatProvider maximumValueDescription];
            
        _leftRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rightRangeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _leftArrowView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightArrowView.translatesAutoresizingMaskIntoConstraints = NO;

        self.translatesAutoresizingMaskIntoConstraints = NO;
        _slider.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSDictionary *views = nil;
    views = NSDictionaryOfVariableBindings(_slider, _leftRangeDescriptionLabel, _rightRangeDescriptionLabel, _leftArrowView, _rightArrowView);
    
    NSMutableArray *constraints = [NSMutableArray new];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_slider(==80)]-(>=15)-|"
                                                 options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
    
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_leftArrowView]-(==4)-[_leftRangeDescriptionLabel]-(>=8)-|"
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_slider]-[_rightArrowView]-(==4)-[_rightRangeDescriptionLabel]-(>=8)-|"
                                                 options:NSLayoutFormatDirectionLeftToRight
                                                 metrics:nil
                                                   views:views]];
        
        const CGFloat kMargin = 17.0;
        const CGFloat kArrowMargin = kMargin - 4.0f;
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_slider]-kMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                 metrics:@{@"kMargin": @(kMargin)}
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kArrowMargin-[_leftArrowView]-(>=11)-[_rightArrowView(==_leftArrowView)]-kArrowMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                 metrics:@{@"kArrowMargin": @(kArrowMargin)}
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-kMargin-[_leftRangeDescriptionLabel]-(>=16)-[_rightRangeDescriptionLabel(==_leftRangeDescriptionLabel)]-kMargin-|"
                                                 options:NSLayoutFormatAlignAllCenterY | NSLayoutFormatDirectionLeftToRight
                                                 metrics:@{@"kMargin": @(kMargin)}
                                                   views:views]];
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
    _slider.showThumb = _currentNumberValue ? YES : NO;
    _slider.value = _currentNumberValue.floatValue;
}

- (NSUInteger)currentTextChoiceIndex {
    return _currentNumberValue.unsignedIntegerValue - 1;
}

- (IBAction)sliderValueChanged:(id)sender {
    _currentNumberValue = [_formatProvider normalizedValueForNumber:@(_slider.value)];
    [self notifyDelegate];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(VASSliderViewCurrentValueDidChange:)]) {
        [self.delegate VASSliderViewCurrentValueDidChange:self];
    }
}

- (id)currentAnswerValue {
    return _currentNumberValue;
}

- (void)setCurrentAnswerValue:(id)currentAnswerValue {
    return [self setCurrentNumberValue:currentAnswerValue];
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

#pragma mark Drawings

-(UIImage *)arrowImageInRect: (CGRect) rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, 0.0f, 15.0f);
    CGContextAddLineToPoint(context, rect.size.width/2.0f, 0.0f);
    CGContextAddLineToPoint(context, 11.0f, 15.0f);
    CGContextMoveToPoint(context, rect.size.width/2.0f, 0.0f);
    CGContextAddLineToPoint(context, rect.size.width/2.0f, rect.size.height);
    
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
