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


#import "ORKActiveStepQuantityView.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"
#import "ORKTintedImageView.h"
#import "ORKSubheadlineLabel.h"


@implementation ORKQuantityLabel

+ (UIFont *)defaultFont {
    return ORKTimeFontForSize(35);
}

@end


@implementation ORKActiveStepQuantityView {
    ORKSubheadlineLabel *_titleLabel;
    ORKQuantityLabel *_valueLabel;
    ORKTintedImageView *_imageView;
    UIView *_valueHolder;
    
    NSLayoutConstraint *_zeroWidthConstraint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [ORKSubheadlineLabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel = [ORKQuantityLabel new];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _imageView = [ORKTintedImageView new];
        _imageView.shouldApplyTint = YES;
        _valueHolder = [UIView new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _valueHolder.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_titleLabel];
        [_valueHolder addSubview:_valueLabel];
        [_valueHolder addSubview:_imageView];
        [self addSubview:_valueHolder];
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        _titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        _valueLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
#endif
        
        for (UIView *view in @[_titleLabel, _valueLabel, _imageView]) {
            view.isAccessibilityElement = NO;
        }
        
        [self setUpConstraints];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.hidden = !enabled;
    [self setNeedsUpdateConstraints];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setValue:(NSString *)value {
    _value = value;
    _valueLabel.text = value;
}

- (void)setImage:(UIImage *)image {
    _image = nil;
    _imageView.image = image;
}

- (void)setUpConstraints {
    
    const CGFloat TitleBaselineToValueBaseline = 40;
    const CGFloat ValueBaselineToBottom = 36;
    
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_titleLabel, _valueLabel, _imageView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]"
                                                                                       options:(NSLayoutFormatOptions)0
                                                                                       metrics:nil
                                                                                         views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel]|"
                                                                                       options:(NSLayoutFormatOptions)0
                                                                                       metrics:nil
                                                                                         views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]-10-[_valueLabel]|"
                                                                                       options:NSLayoutFormatAlignAllCenterY
                                                                                       metrics:nil
                                                                                         views:views]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueLabel
                                                                  attribute:NSLayoutAttributeFirstBaseline
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_titleLabel
                                                                  attribute:NSLayoutAttributeLastBaseline
                                                                 multiplier:1.0
                                                                   constant:TitleBaselineToValueBaseline]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_valueLabel
                                                                  attribute:NSLayoutAttributeLastBaseline
                                                                 multiplier:1.0
                                                                   constant:ValueBaselineToBottom]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueHolder
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueLabel
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:_valueHolder
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueLabel
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:_valueHolder
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueHolder
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_valueHolder
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = UILayoutPriorityRequired - 2;
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    _zeroWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:0.0];
    _zeroWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    _zeroWidthConstraint.active = !_enabled;
    [super updateConstraints];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return _titleLabel.accessibilityLabel;
}

- (NSString *)accessibilityValue {
    return _valueLabel.accessibilityLabel;
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitUpdatesFrequently;
}

@end


@implementation ORKQuantityPairView {
    UIView *_metricKeyline;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _leftView = [ORKActiveStepQuantityView new];
        _rightView = [ORKActiveStepQuantityView new];
        
        _leftView.translatesAutoresizingMaskIntoConstraints = NO;
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        _metricKeyline = [UIView new];
        _metricKeyline.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setKeylineHidden:NO];
        _metricKeyline.backgroundColor = [UIColor ork_midGrayTintColor];
        
        [self addSubview:_leftView];
        [self addSubview:_rightView];
        [self addSubview:_metricKeyline];
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_leftView, _rightView, _metricKeyline);
    
    // Leave space for the keyline between these views, and then constrain it to be 1px wide and go from top to bottom baseline of metric views.
    CGFloat scale = [UIScreen mainScreen].scale;
    NSArray *vertConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftView]|"
                                                                       options:(NSLayoutFormatOptions)0
                                                                       metrics:nil
                                                                         views:views];
    [constraints addObjectsFromArray:vertConstraints];
    
    NSArray *horizConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_leftView]-s-[_rightView]-|"
                                                                        options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom|NSLayoutFormatDirectionLeftToRight
                                                                        metrics:@{ @"s": @(1.0 / scale) }
                                                                          views:views];
    for (NSLayoutConstraint *constraint in horizConstraints) {
        constraint.priority = UILayoutPriorityDefaultHigh + 1;
    }
    [constraints addObjectsFromArray:horizConstraints];
    
    // Ensure baseline alignment of title and value
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftView.titleLabel
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_rightView.titleLabel
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_leftView.valueLabel
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_rightView.valueLabel
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_leftView][_metricKeyline(==s)]"
                                                                             options:NSLayoutFormatAlignAllTop|NSLayoutFormatDirectionLeftToRight
                                                                             metrics:@{ @"s": @(1.0 / scale) }
                                                                               views:views]];
    NSLayoutConstraint *keylineBottom = [NSLayoutConstraint constraintWithItem:_metricKeyline
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_leftView.valueLabel
                                                                     attribute:NSLayoutAttributeLastBaseline
                                                                    multiplier:1.0
                                                                      constant:0.0];
    [constraints addObject:keylineBottom];
    
    NSLayoutConstraint *maxWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:ORKScreenMetricMaxDimension];
    maxWidthConstraint.priority = UILayoutPriorityRequired - 2;
    [constraints addObject:maxWidthConstraint];
    
    
    // This constraint should be beaten out by the full-width-coverage and zero-width constraints if only one of the views is enabled.
    NSLayoutConstraint *equalWidthConstraint = [NSLayoutConstraint constraintWithItem:_leftView
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:_rightView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0.0];
    equalWidthConstraint.priority = UILayoutPriorityDefaultLow;
    [constraints addObject:equalWidthConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setKeylineHidden:(BOOL)keylineHidden {
    _keylineHidden = keylineHidden;
    _metricKeyline.hidden = keylineHidden;
}

@end
