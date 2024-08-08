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
static const CGFloat LabelTopBottomMarginWithColorSwatch = 18.0;
static const CGFloat TextViewTopMargin = 20.0;
static const CGFloat TextViewHeight = 100.0;
static const CGFloat LabelCheckViewPadding = 10.0;
static const CGFloat ColorSwatchViewHeightWidth = 40.0;
static const CGFloat ColorSwatchViewTopBottomPadding = 12.0;
static const CGFloat ColorSwatchExpandedRightPadding = 16.0;

@interface ORKChoiceViewCell() <CAAnimationDelegate>

@property (nonatomic) UIView *containerView;
@property (nonatomic) UIImageView *textChoiceImageView;
@property (nonatomic) UIView *colorSwatchView;
@property (nonatomic) ORKSelectionTitleLabel *primaryLabel;
@property (nonatomic) ORKSelectionSubTitleLabel *detailLabel;
@property (nonatomic) ORKCheckmarkView *checkView;
@property (nonatomic) NSMutableArray<NSLayoutConstraint *> *containerConstraints;
@property (nonatomic, readonly) CGFloat leftRightMargin;
@property (nonatomic, readonly) CGFloat intraCellSpacing;

@end

@implementation ORKChoiceViewCell {
    
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
        _topBottomMargin = 0.0;
        [self setupContainerView];
        [self setupCheckView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (CGFloat)leftRightMargin {
    return self.useCardView ? ORKCardLeftRightMarginForWindow(self.window) : 0.0;
}

- (CGFloat)intraCellSpacing {
    return 0;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    _fillColor = [self __fillColor];
}

- (void)clearLayerIfNeeded:(CALayer *)layer {
    
    if (layer) {
        for (CALayer *sublayer in [layer.sublayers mutableCopy]) {
            [sublayer removeFromSuperlayer];
        }
        
        [layer removeFromSuperlayer];
        layer = nil;
    }
}

- (UIColor *)__fillColor {
    
    if (_shouldIgnoreDarkMode) {
        return [UIColor whiteColor];
    }
    
    UIColor *color = [UIColor secondarySystemGroupedBackgroundColor];;
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        color = [UIColor colorWithRed:0.173 green:0.173 blue:0.180 alpha:1.0];
    }
    
    return color;
}

- (UIColor *)__borderColor {
    return UIColor.separatorColor;
}

- (UIRectCorner)roundedCorners {
        
    if (_isLastItem && !_isFirstItemInSectionWithoutTitle) {
        
        return UIRectCornerBottomLeft | UIRectCornerBottomRight;
        
    } else if (!_isLastItem && _isFirstItemInSectionWithoutTitle) {
        
        return UIRectCornerTopLeft | UIRectCornerTopRight;
        
    } else {
        
        return UIRectCornerAllCorners;
    }
}

- (BOOL)shouldApplyMaskLayers {
    return _isLastItem || _isFirstItemInSectionWithoutTitle;
}

- (void)setMaskLayers {
    
    if (_useCardView && !_animationLayer) {
        
        UIColor *borderColor = [self __borderColor];
        _fillColor = [self __fillColor];
        
        [self clearLayerIfNeeded:_contentMaskLayer];
        _contentMaskLayer = [[CAShapeLayer alloc] init];
        [_contentMaskLayer setFillColor:[_fillColor CGColor]];
        
        [self clearLayerIfNeeded:_foreLayer];
        _foreLayer = [CAShapeLayer layer];
        [_foreLayer setFillColor:[_fillColor CGColor]];
        _foreLayer.zPosition = 0.0f;
        
        if ([self shouldApplyMaskLayers]) {
            
            UIRectCorner rectCorners = [self roundedCorners];
            
            _foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height - ORKCardDefaultBorderWidth);
            
            CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
            
            _foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: _foreLayerBounds
                                                   byRoundingCorners: rectCorners
                                                         cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
            
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.containerView.bounds
                                                           byRoundingCorners:rectCorners
                                                                 cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
        } else {
            
            _foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, self.containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, self.containerView.bounds.size.height);
            _foreLayer.path = [UIBezierPath bezierPathWithRect:_foreLayerBounds].CGPath;
            _contentMaskLayer.path = [UIBezierPath bezierPathWithRect:self.containerView.bounds].CGPath;
        }
        
        if (_cardViewStyle == ORKCardViewStyleBordered) {
            _contentMaskLayer.fillColor = borderColor.CGColor;
        }
        
        [_contentMaskLayer addSublayer:_foreLayer];
          
        [_contentMaskLayer addSublayer:[self lineLayer]];
        
        [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
    }
}

- (nullable CAShapeLayer *)lineLayer {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    if (!_isLastItem) {
        CGRect lineBounds = CGRectMake(ORKSurveyItemMargin, self.containerView.bounds.size.height - 1.0, self.containerView.bounds.size.width - ORKSurveyItemMargin, 0.5);
        lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
        lineLayer.zPosition = 0.0f;
    }
    lineLayer.fillColor = [self __borderColor].CGColor;
    
    return lineLayer;
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [self.contentView addSubview:_containerView];
}

- (void)addContainerViewToSelfConstraints {
    [_containerConstraints addObjectsFromArray:@[
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:self.leftRightMargin],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:-self.leftRightMargin],
        [NSLayoutConstraint constraintWithItem:_containerView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.contentView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:-self.intraCellSpacing],
    ]];
}

- (void)addLeftContentViewToContainerViewConstraints {
    UIView *leftContentView = [self getLeftContentView];
    
    if (leftContentView) {
        
        [_containerConstraints addObject:[leftContentView.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:ORKSurveyItemMargin]];
        
        [_containerConstraints addObject:[leftContentView.centerYAnchor constraintEqualToAnchor:_containerView.centerYAnchor]];
        [_containerConstraints addObject:[leftContentView.heightAnchor constraintEqualToConstant:ColorSwatchViewHeightWidth]];
        
        [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:leftContentView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:_containerView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:ColorSwatchViewTopBottomPadding]];
        
        if (!_primaryLabel && !_detailLabel) {
            [_containerConstraints addObject:[leftContentView.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:LabelTopBottomMargin]];
            [_containerConstraints addObject:[leftContentView.trailingAnchor constraintEqualToAnchor:_checkView.leadingAnchor constant:-ColorSwatchExpandedRightPadding]];
        } else if (leftContentView) {
            [_containerConstraints addObject:[leftContentView.widthAnchor constraintEqualToConstant:ColorSwatchViewHeightWidth]];
        }
     }
}

- (void)addPrimaryLabelToContainerViewConstraints {
    if (_primaryLabel) {
        UIView *leftContentView = [self getLeftContentView];
        
        if (leftContentView) {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
        } else {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:LabelTopBottomMargin]];
        }
        
        if (_colorSwatchView) {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
        } else {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:LabelTopBottomMargin]];
        }
        
        if (_colorSwatchView) {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
        } else {
            [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_primaryLabel
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:_containerView
                                                                          attribute:NSLayoutAttributeTop
                                                                         multiplier:1.0
                                                                           constant:LabelTopBottomMargin]];
        }
        
        [_containerConstraints addObjectsFromArray:@[
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
                                            toItem:leftContentView ?: _containerView
                                         attribute:leftContentView ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading
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
                                            toItem:_primaryLabel ?: _containerView
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
    UIView *bottomMostView = _detailLabel ?: _primaryLabel;
    UIView *leftContentView = [self getLeftContentView];
    
    // only use extra margin if the primary or detail label have been initialized
    CGFloat bottomMargin = (leftContentView && bottomMostView) ? LabelTopBottomMarginWithColorSwatch : LabelTopBottomMargin;
    
    if (leftContentView) {
        bottomMostView = leftContentView;
        bottomMargin = ColorSwatchViewTopBottomPadding;
    }
    
    [_containerConstraints addObject:[NSLayoutConstraint constraintWithItem:_containerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:bottomMostView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:bottomMargin]];
}

- (void)setupConstraints {
    if (!_primaryLabel && !_detailLabel && !_colorSwatchView) {
        return;
    }
    
    if (_containerConstraints) {
        [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    }
    
    _containerConstraints = [[NSMutableArray alloc] init];
    [self addContainerViewToSelfConstraints];
    [self addLeftContentViewToContainerViewConstraints];
    [self addPrimaryLabelToContainerViewConstraints];
    [self addDetailLabelConstraints];
    [self addCheckViewToContainerViewConstraints];
    [self addContainerViewBottomConstraint];
    
    [NSLayoutConstraint activateConstraints:_containerConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSelectedItem];
    [self setMaskLayers];
    [self setPrimaryLabelFont];
}

- (void)prepareForReuse {
    _primaryLabel.text = nil;
    _detailLabel.text = nil;
    
    if (_textChoiceImageView) {
        [_textChoiceImageView removeFromSuperview];
        _textChoiceImageView = nil;
    }
    
    if (_colorSwatchView) {
        [_colorSwatchView removeFromSuperview];
        _colorSwatchView = nil;
    }
    [NSLayoutConstraint deactivateConstraints:_containerConstraints];
    [_containerConstraints removeAllObjects];
    // [choiceViewCell setCellSelected:NO highlight:NO];
    [super prepareForReuse];
}

- (void)setUseCardView:(bool)useCardView {
    _useCardView = useCardView;
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

- (void)setCellSelected:(BOOL)cellSelected highlight:(BOOL)highlight {
    _cellSelected = cellSelected;    
    [self updateSelectedItem];
    
    if (highlight)
    {
        
        _animationLayer = [CAShapeLayer layer];
        [_animationLayer setOpaque:NO];
        _animationLayer.zPosition = 1.0f;
        
        if ([self shouldApplyMaskLayers]) {
            UIRectCorner rectCorners = [self roundedCorners];

            CGFloat animationLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
            
            _animationLayer.path = [UIBezierPath bezierPathWithRoundedRect: _foreLayerBounds
                                                         byRoundingCorners: rectCorners
                                                               cornerRadii: (CGSize){animationLayerCornerRadii, animationLayerCornerRadii}].CGPath;

            _animationLayer.fillColor = UIColor.clearColor.CGColor;
        }
        
        _animationLayer.frame = CGRectMake(_foreLayerBounds.origin.x, _foreLayerBounds.origin.y, _foreLayerBounds.size.width, _foreLayerBounds.size.height - 1.0);
        
        [_contentMaskLayer addSublayer:_animationLayer];
        
        NSString *animationKeyPath = [self shouldApplyMaskLayers] ? @"fillColor" : @"backgroundColor";
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationKeyPath];

        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight){
            animation.fromValue = (__bridge id _Nullable)(UIColor.systemGray5Color.CGColor);
        } else {
            animation.fromValue = (__bridge id _Nullable)(UIColor.systemGray3Color.CGColor);
        }

        animation.toValue = (__bridge id _Nullable)(_fillColor.CGColor);
        animation.beginTime = 0.0;
        animation.duration = 0.45;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = YES;
        animation.delegate = self;

        [_animationLayer addAnimation:animation forKey:animationKeyPath];
    }
}

- (void)setupTextChoiceImageView {
    if (!_textChoiceImageView) {
        _textChoiceImageView = [UIImageView new];
        _textChoiceImageView.contentMode = UIViewContentModeScaleToFill;
        _textChoiceImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_containerView addSubview:_textChoiceImageView];
    }
}

- (void)setupColorSwatchView {
    if (!_colorSwatchView) {
        _colorSwatchView = [UIView new];
        _colorSwatchView.clipsToBounds = YES;
        _colorSwatchView.layer.cornerRadius = 4.0;
        _colorSwatchView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_containerView addSubview:_colorSwatchView];
    }
}

- (nullable UIView *)getLeftContentView {
    if (_textChoiceImageView) {
        return _textChoiceImageView;
    } else if (_colorSwatchView) {
        return _colorSwatchView;
    }
    
    return nil;
}

- (void)setupPrimaryLabel {
    if (!_primaryLabel) {
        _primaryLabel = [ORKSelectionTitleLabel new];
        _primaryLabel.numberOfLines = 0;
        _primaryLabel.textColor = _shouldIgnoreDarkMode ? [UIColor blackColor] : [UIColor labelColor];
        
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

- (void)setShouldIgnoreDarkMode:(BOOL)shouldIgnoreDarkMode {
    _shouldIgnoreDarkMode = shouldIgnoreDarkMode;
    
    if (_checkView) {
        _checkView.shouldIgnoreDarkMode = shouldIgnoreDarkMode;
    }
}

- (void)setTextChoiceImage:(UIImage *)image {
    if (image && !_colorSwatchView) {
        [self setupTextChoiceImageView];
        
        [_textChoiceImageView setImage:image];
    }
}

- (void)setSwatchColor:(UIColor *)swatchColor {
    if (swatchColor && !_textChoiceImageView) {
        [self setupColorSwatchView];
        _colorSwatchView.backgroundColor = swatchColor;
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
    if (!_primaryLabel.attributedText) {
        UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
        [_primaryLabel setFont:[UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    }
}

- (void)updateCheckView {
    if (_checkView) {
        _checkView.tintColor = self.tintColor;
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
        [_foreLayer setFillColor:UIColor.systemGray5Color.CGColor];
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
        _textView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        [self.containerView addSubview:_textView];
        [self updateTextView];
    }
}

- (void)hideTextView:(BOOL)textViewHidden {
    _textViewHidden = textViewHidden;
    [self updateTextView];
    [self setupConstraints];
}

- (void)setupWithText:(NSString *)text
      placeholderText:(NSString *)placeholderText {
        self.textView.placeholder = placeholderText;
        self.textView.text = text;
        BOOL hideTextView = YES;
    
        if (self.isCellSelected) {
           hideTextView = NO;
        } else {
           hideTextView = self.textView.text.length == 0;
        }
    
        [self hideTextView:hideTextView];
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
                                        toItem:self.detailLabel ?: self.primaryLabel
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

- (void)textViewDidChange:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChoiceOtherCellDidChangeText:choiceOtherCell:)]) {
        [self.delegate textChoiceOtherCellDidChangeText:textView.text choiceOtherCell:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textChoiceOtherCellDidResignFirstResponder:)]) {
        [self.delegate textChoiceOtherCellDidResignFirstResponder:self];
    }
}

@end

#pragma mark - ORKChoiceViewPlatterCell

@implementation ORKChoiceViewPlatterCell

#pragma mark - ORKTextChoiceCell Overrides

- (BOOL)shouldApplyMaskLayers {
    return YES;
}

- (UIRectCorner)roundedCorners {
    return UIRectCornerAllCorners;
}

- (CGFloat)intraCellSpacing {
    return 10;
}

- (nullable CAShapeLayer *)lineLayer {
    return nil;
}

@end
