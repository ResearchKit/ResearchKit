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

#import <ResearchKit/ResearchKit-Swift.h>

#import "ORKActiveStepQuantityView.h"

#import "ORKSubheadlineLabel.h"
#import "ORKTintedImageView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@implementation ORKQuantityLabel

+ (UIFont *)defaultFont {
    return ORKTimeFontForSize(35);
}

@end

@interface ORKActiveStepQuantityView ()
@property (nonatomic, readonly, strong) UIStackView *contentView;
@end

@implementation ORKActiveStepQuantityView {
    UIStackView *_contentView;
    UIStackView *_valueContentView;
    ORKSubheadlineLabel *_titleLabel;
    ORKQuantityLabel *_valueLabel;
    ORKTintedImageView *_imageView;
    UIView *_valueHolder;
    UIView *_spacerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        self.titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        self.valueLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
#endif
        
        for (UIView *view in @[self.titleLabel, self.valueLabel, self.imageView]) {
            view.isAccessibilityElement = NO;
        }
    }
    return self;
}

- (UIStackView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.valueContentView, self.spacerView]];
        _contentView.axis = UILayoutConstraintAxisVertical;
        _contentView.distribution = UIStackViewDistributionFill;
        _contentView.alignment = UIStackViewAlignmentCenter;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _contentView;
}

- (UIView *)spacerView {
    if (_spacerView == nil) {
        _spacerView = [UIView new];
        [_spacerView setContentHuggingPriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisVertical];
    }
    return _spacerView;
}

- (UIView *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [ORKSubheadlineLabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _titleLabel;
}

- (UIView *)valueLabel {
    if (_valueLabel == nil) {
        _valueLabel = [ORKQuantityLabel new];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _valueLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [ORKTintedImageView new];
        _imageView.shouldApplyTint = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

- (UIStackView *)valueContentView {
    if (_valueContentView == nil) {
        _valueContentView = [[UIStackView alloc] initWithArrangedSubviews:@[self.imageView, self.valueLabel]];
        _valueContentView.axis = UILayoutConstraintAxisHorizontal;
        _valueContentView.distribution = UIStackViewDistributionFill;
        _valueContentView.alignment = UIStackViewAlignmentLastBaseline;
        _valueContentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _valueContentView;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.hidden = !enabled;
    [self setNeedsUpdateConstraints];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setValue:(NSString *)value {
    _value = value;
    self.valueLabel.text = value;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}

- (void)didMoveToSuperview {
    [self addSubview:self.contentView];
    [self setUpConstraints];
}

- (void)setUpConstraints {
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
}

#pragma mark Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return self.titleLabel.accessibilityLabel;
}

- (NSString *)accessibilityValue {
    return self.valueLabel.accessibilityLabel;
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
    CGFloat scale = self.safeDisplayScale;

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
