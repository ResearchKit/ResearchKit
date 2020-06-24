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


#import "ORKChoiceViewCell_Internal.h"

#import "ORKSelectionTitleLabel.h"
#import "ORKSelectionSubTitleLabel.h"

#import "ORKAccessibility.h"
#import "ORKHelpers_Internal.h"
#import "ORKAnswerTextView.h"
#import "ORKSkin.h"
#import "ORKCheckmarkView.h"

static const CGFloat CardTopBottomMargin = 2.0;
static const CGFloat LabelTopBottomMargin = 14.0;
static const CGFloat TextViewTopMargin = 20.0;
static const CGFloat TextViewHeight = 100.0;
static const CGFloat LabelCheckViewPadding = 10.0;

@interface ORKChoiceViewCell() <CAAnimationDelegate>

@property (nonatomic) UIView *containerView;
@property (nonatomic) ORKSelectionTitleLabel *primaryLabel;
@property (nonatomic) ORKSelectionSubTitleLabel *detailLabel;
@property (nonatomic) ORKCheckmarkView *checkView;
@property (nonatomic) NSMutableArray<NSLayoutConstraint *> *containerConstraints;

@end

@implementation ORKChoiceViewCell {
    
    CGFloat _leftRightMargin;
    CGFloat _topBottomMargin;
    CAShapeLayer *_contentMaskLayer;
    UIColor *_fillColor;
    CAShapeLayer *_foreLayer;
    CAShapeLayer *_animationLayer;
    CGRect _foreLayerBounds;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        _leftRightMargin = 0.0;
        _topBottomMargin = 0.0;
        [self setupContainerView];
        [self setupCheckView];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        _fillColor = [UIColor secondarySystemGroupedBackgroundColor];
        // FIXME:- dark mode color displays solid black after animation ends if the views are stacked
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            _fillColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.180 alpha:1.0];
        }
    } else {
        _fillColor = [UIColor ork_borderGrayColor];
    }
}

- (void)setMaskLayers {
    if (_useCardView && !_animationLayer) {
        if (_contentMaskLayer) {
            for (CALayer *sublayer in [_contentMaskLayer.sublayers mutableCopy]) {
                [sublayer removeFromSuperlayer];
            }
            [_contentMaskLayer removeFromSuperlayer];
            _contentMaskLayer = nil;
        }
        _contentMaskLayer = [[CAShapeLayer alloc] init];
        UIColor *borderColor;
        if (@available(iOS 13.0, *)) {
            _fillColor = [UIColor secondarySystemGroupedBackgroundColor];
            // FIXME:- dark mode color displays solid black after animation ends if the views are stacked
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                _fillColor = [UIColor colorWithRed:0.173 green:0.173 blue:0.180 alpha:1.0];
            }
            borderColor = UIColor.separatorColor;
        } else {
            _fillColor = [UIColor ork_borderGrayColor];
            borderColor = [UIColor ork_midGrayTintColor];
        }
        [_contentMaskLayer setFillColor:[_fillColor CGColor]];
        
        [_foreLayer removeFromSuperlayer];
        _foreLayer = nil;
        _foreLayer = [CAShapeLayer layer];
        [_foreLayer setFillColor:[_fillColor CGColor]];
        _foreLayer.zPosition = 0.0f;
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        
        if (_isLastItem || _isFirstItemInSectionWithoutTitle) {
            NSUInteger rectCorners;
            if (_isLastItem && !_isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            else if (!_isLastItem && _isFirstItemInSectionWithoutTitle) {
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight;
            }
            else {
                rectCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight;
            }
            
            _foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - ORKCardDefaultBorderWidth);
            
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.containerView.bounds
                                                           byRoundingCorners: rectCorners
                                                                 cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
            
            CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
            
            _foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: _foreLayerBounds
                                                   byRoundingCorners: rectCorners
                                                         cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        }
        else {
            _foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height);
            _foreLayer.path = [UIBezierPath bezierPathWithRect:_foreLayerBounds].CGPath;
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
            
            CGRect lineBounds = CGRectMake(ORKSurveyItemMargin, self.containerView.bounds.size.height - 1.0, self.containerView.bounds.size.width - ORKSurveyItemMargin, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
        }
        
        lineLayer.fillColor = borderColor.CGColor;
        if (_cardViewStyle == ORKCardViewStyleBordered) {
            _contentMaskLayer.fillColor = borderColor.CGColor;
        }
        
        [_contentMaskLayer addSublayer:_foreLayer];
        
        [_contentMaskLayer addSublayer:lineLayer];
        [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
    }
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    [self addSubview:_containerView];
}

- (void)addContainerViewToSelfConstraints {
    [_containerConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:_leftRightMargin],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:-_leftRightMargin]
    ]];
}

- (void)addPrimaryLabelToContainerViewConstraints {
    if (_primaryLabel) {
        
        [_containerConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_primaryLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_containerView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:LabelTopBottomMargin],
            [NSLayoutConstraint constraintWithItem:_primaryLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_checkView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:-LabelCheckViewPadding],
            [NSLayoutConstraint constraintWithItem:_primaryLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_containerView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:ORKSurveyItemMargin]
        ]];
    }
}

- (void)addDetailLabelConstraints {
    if (_detailLabel) {
        [_containerConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_detailLabel
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_primaryLabel ? : _containerView
                                         attribute:_primaryLabel ? NSLayoutAttributeBottom : NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:_primaryLabel ? 0.0 : LabelTopBottomMargin],
            [NSLayoutConstraint constraintWithItem:_detailLabel
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_checkView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:-LabelCheckViewPadding],
            [NSLayoutConstraint constraintWithItem:_detailLabel
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_containerView
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:ORKSurveyItemMargin]
        ]];
    }
}

- (void)addContainerViewBottomConstraint {
    [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_containerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_detailLabel ? : _primaryLabel
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:LabelTopBottomMargin]];
}

- (void)setupConstraints {
    if (!_primaryLabel && !_detailLabel) {
        return;
    }
    
    if (_containerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    }
    
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _containerConstraints = [[NSMutableArray alloc] init];
    [self addContainerViewToSelfConstraints];
    [self addPrimaryLabelToContainerViewConstraints];
    [self addDetailLabelConstraints];
    [self addCheckViewToContainerViewConstraints];
    [self addContainerViewBottomConstraint];
    [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_containerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:_containerConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSelectedItem];
    [self setMaskLayers];
    [self setPrimaryLabelFont];
}

- (void)setUseCardView:(bool)useCardView {
    _useCardView = useCardView;
    _leftRightMargin = ORKCardLeftRightMarginForWindow(self.window);
    _topBottomMargin = CardTopBottomMargin;
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self setupConstraints];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateSelectedItem];
}

- (void)updateSelectedItem {
        [self updateCheckView];
}

- (void)setImmediateNavigation:(BOOL)immediateNavigation {
    _immediateNavigation = immediateNavigation;
}

- (void)setCellSelected:(BOOL)cellSelected highlight:(BOOL)highlight
{
    _cellSelected = cellSelected;
    
    [self updateSelectedItem];
    
    if (highlight)
    {
        _animationLayer = [CAShapeLayer layer];
        [_animationLayer setOpaque:NO];
        _animationLayer.frame = CGRectMake(_foreLayerBounds.origin.x, _foreLayerBounds.origin.y, _foreLayerBounds.size.width, _foreLayerBounds.size.height - 1.0);
        _animationLayer.zPosition = 1.0f;
        [_contentMaskLayer addSublayer:_animationLayer];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        
        if (@available(iOS 13.0, *))
        {
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight)
            {
                animation.fromValue = (__bridge id _Nullable)(UIColor.systemGray5Color.CGColor);
            }
            else
            {
                animation.fromValue = (__bridge id _Nullable)(UIColor.systemGray3Color.CGColor);
            }
        }
        else
        {
            animation.fromValue = (__bridge id _Nullable)([UIColor colorWithRed:0.282 green:0.282 blue:0.235 alpha:1.0].CGColor);
        }
        
        animation.toValue = (__bridge id _Nullable)(_fillColor.CGColor);
        animation.beginTime = 0.0;
        animation.duration = 0.45;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = YES;
        animation.delegate = self;
        
        [_animationLayer addAnimation:animation forKey:@"backgroundColor"];
        
        _animationLayer.backgroundColor = _fillColor.CGColor;
    }
}

- (void)setupPrimaryLabel {
    if (!_primaryLabel) {
        _primaryLabel = [ORKSelectionTitleLabel new];
        _primaryLabel.numberOfLines = 0;
        if (@available(iOS 13.0, *)) {
            _primaryLabel.textColor = [UIColor labelColor];
        } else {
            _primaryLabel.textColor = [UIColor blackColor];
        }
        [self.containerView addSubview:_primaryLabel];
        [self setPrimaryLabelFont];
        _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupConstraints];
    }
}

- (void)setupDetailLabel {
    if (!_detailLabel) {
        _detailLabel = [ORKSelectionSubTitleLabel new];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textColor = [UIColor ork_darkGrayColor];
        [self.containerView addSubview:_detailLabel];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self setupConstraints];
    }
}

- (UIImage *)unCheckedImage {
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        return [UIImage systemImageNamed:@"circle" withConfiguration:configuration];
    } else {
        return nil;
    }
}

- (UIImage *)checkedImage {
    if (@available(iOS 13.0, *)) {
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] scale:UIImageSymbolScaleLarge];
        return [UIImage systemImageNamed:@"checkmark.circle.fill" withConfiguration:configuration];
    } else {
        return [[UIImage imageNamed:@"checkmark" inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)setupCheckView {
    if (!_checkView) {
        _checkView = [[ORKCheckmarkView alloc] initWithDefaults];
    }
    [_checkView setChecked:NO];
    [self.containerView addSubview:_checkView];
}

- (void)addCheckViewToContainerViewConstraints {
    if (_checkView) {
        _checkView.translatesAutoresizingMaskIntoConstraints = NO;
        [_containerConstraints addObjectsFromArray:@[
            [NSLayoutConstraint constraintWithItem:_checkView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_containerView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1.0
                                          constant:0.0],
            [NSLayoutConstraint constraintWithItem:_checkView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:_containerView
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-ORKSurveyItemMargin]
        ]];
    }
}

- (void)setPrimaryText:(NSString *)primaryText {
    if (primaryText) {
        [self setupPrimaryLabel];
        _primaryLabel.text = primaryText;
    }
}

- (void)setPrimaryAttributedText:(NSAttributedString *)primaryAttributedText {
    if (primaryAttributedText) {
        [self setupPrimaryLabel];
        _primaryLabel.attributedText = primaryAttributedText;
    }
}

- (void)setDetailText:(NSString *)detailText {
    if (detailText) {
        [self setupDetailLabel];
        _detailLabel.text = detailText;
    }
}

- (void)setDetailAttributedText:(NSAttributedString *)detailAttributedText {
    if (detailAttributedText) {
        [self setupDetailLabel];
        _detailLabel.attributedText = detailAttributedText;
    }
}

- (void)setPrimaryLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    [_primaryLabel setFont:[UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
}

- (void)updateCheckView {
    if (_checkView) {
        [_checkView setChecked:_cellSelected];
    }
}


#pragma mark - Accessibility

- (NSString *)accessibilityLabel {
    return ORKAccessibilityStringForVariables(_primaryLabel.accessibilityLabel, _detailLabel.accessibilityLabel);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitButton | (self.isCellSelected ? UIAccessibilityTraitSelected : 0);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted
                 animated:animated];
    
    if (highlighted) {
        if (@available(iOS 13.0, *)) {
            [_foreLayer setFillColor:UIColor.systemGray5Color.CGColor];
        } else {
            self.layer.backgroundColor = [UIColor colorWithRed:0.282 green:0.282 blue:0.235 alpha:1.0].CGColor;
        }
    }
    else {
        _foreLayer.fillColor = _fillColor.CGColor;
    }
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [_animationLayer removeFromSuperlayer];
    _animationLayer = nil;
    [self setMaskLayers];
}

@end


@implementation ORKChoiceOtherViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _textViewHidden = NO;
    [self setupAnswerTextView];
    return self;
}

- (void)setupAnswerTextView {
    if (!_textView) {
        _textView = [[ORKAnswerTextView alloc] init];
        _textView.delegate = self;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 13.0, *)) {
            _textView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        }
        [self.containerView addSubview:_textView];
        [self updateTextView];
    }
}

- (void)hideTextView:(BOOL)textViewHidden {
    _textViewHidden = textViewHidden;
    [self updateTextView];
    [self setupConstraints];
}

- (void)updateTextView {
    [self.textView setHidden:_textViewHidden];
}

- (void)addOtherAnswerTextViewConstraints {
    
    NSLayoutConstraint *textViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:nil
                                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                                               multiplier:1.0
                                                                                 constant:MAX(_textView.font.pointSize, TextViewHeight)];
    textViewHeightConstraint.priority = UILayoutPriorityDefaultLow;
    
    [self.containerConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:_textView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.detailLabel ? : self.primaryLabel
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:TextViewTopMargin],
        [NSLayoutConstraint constraintWithItem:_textView
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.checkView
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:-LabelCheckViewPadding],
        [NSLayoutConstraint constraintWithItem:_textView
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.containerView
                                     attribute:NSLayoutAttributeLeading
                                    multiplier:1.0
                                      constant:ORKSurveyItemMargin],
        textViewHeightConstraint,
        [NSLayoutConstraint constraintWithItem:self.containerView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_textView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:LabelTopBottomMargin]
    ]];
}

// Overriding ContainerView Bottom Constraints
- (void)addContainerViewBottomConstraint {
    if (_textViewHidden) {
        [super addContainerViewBottomConstraint];
    }
    else {
        [self addOtherAnswerTextViewConstraints];
    }
}

- (void)setMaskLayers {
    [super setMaskLayers];
    _textView.layer.borderWidth = 0.25;
    [_textView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    _textView.layer.cornerRadius = 10.0;
}

# pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChoiceOtherCellDidBecomeFirstResponder:)]) {
        [self.delegate textChoiceOtherCellDidBecomeFirstResponder:self];
    }
    
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChoiceOtherCellDidResignFirstResponder:)]) {
        [self.delegate textChoiceOtherCellDidResignFirstResponder:self];
    }
}

@end
