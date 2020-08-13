/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKSurveyCardHeaderView.h"
#import "ORKSkin.h"
#import "ORKLearnMoreView.h"
#import "ORKTagLabel.h"
#import "ORKHelpers_Internal.h"

static const CGFloat HeaderViewLabelTopBottomPadding = 6.0;
static const CGFloat TagBottomPadding = 4.0;
static const CGFloat TagTopPadding = 8.0;
static const CGFloat HeaderViewBottomPadding = 24.0;
static const CGFloat SelectAllThatApplyTopPadding = 24.0;
static const CGFloat SelectAllThatApplyBottomPadding = 6.0;

@implementation ORKSurveyCardHeaderView {
    
    UIView *_headlineView;
    NSString *_title;
    UILabel *_titleLabel;
    NSString *_detailText;
    UILabel *_detailTextLabel;
    ORKLearnMoreView *_learnMoreView;
    NSString *_progressText;
    UILabel *_progressLabel;
    UILabel *_tagLabel;
    UILabel *_selectAllThatApplyLabel;
    BOOL _showBorder;
    BOOL _hasMultipleChoiceItem;
    NSString *_tagText;
    CAShapeLayer *_headlineMaskLayer;
    NSArray<NSLayoutConstraint *> *_headerViewConstraints;
    NSArray<NSLayoutConstraint *> *_learnMoreViewConstraints;
}

- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super init];
    if (self) {
        _title = title;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupHeaderView];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(nullable NSString *)text learnMoreView:(nullable ORKLearnMoreView *)learnMoreView progressText:(nullable NSString *)progressText tagText:(nullable NSString *)tagText {
    
    self = [super init];
    if (self) {
        _title = title;
        _detailText = text;
        _learnMoreView = learnMoreView;
        _progressText = progressText;
        _showBorder = NO;
        _hasMultipleChoiceItem = NO;
        _tagText = tagText;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupHeaderView];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(NSString *)text learnMoreView:(ORKLearnMoreView *)learnMoreView progressText:(NSString *)progressText tagText:(nullable NSString *)tagText showBorder:(BOOL)showBorder hasMultipleChoiceItem:(BOOL)hasMultipleChoiceItem {
    
    self = [super init];
    if (self) {
        _title = title;
        _detailText = text;
        _learnMoreView = learnMoreView;
        _progressText = progressText;
        _showBorder = showBorder;
        _tagText = tagText;
        _hasMultipleChoiceItem = hasMultipleChoiceItem;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupHeaderView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupHeaderView {
    [self setupHeadlineView];
    [self addSubview:_headlineView];
    
    if (_tagText) {
        [self setupTagLabel];
        [_headlineView addSubview:_tagLabel];
    }
    
    if (_progressText) {
        [self setUpProgressLabel];
        [_headlineView addSubview:_progressLabel];
    }
   
    [self setupTitleLabel];
    [_headlineView addSubview:_titleLabel];
    
    if (_detailText) {
        [self setUpDetailTextLabel];
        [_headlineView addSubview:_detailTextLabel];
    }
    
    if (_learnMoreView) {
        [_headlineView addSubview:_learnMoreView];
    }
    
    if (_hasMultipleChoiceItem) {
        [self setupSelectAllThatApplyLabel];
        [_headlineView addSubview:_selectAllThatApplyLabel];
    }
}

- (void)setupHeadlineView {
    if (!_headlineView) {
        _headlineView = [UIView new];
    }
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    _titleLabel.text = _title;
    _titleLabel.numberOfLines = 0;
    if (@available(iOS 13.0, *)) {
        _titleLabel.textColor = [UIColor labelColor];
    } else {
        _titleLabel.textColor = [UIColor blackColor];
    }
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.textAlignment = NSTextAlignmentNatural;
    [_titleLabel setFont:[self titleLabelFont]];
}

- (void)setUpDetailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [UILabel new];
    }
    _detailTextLabel.text = _detailText;
    _detailTextLabel.numberOfLines = 0;
    _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailTextLabel.textAlignment = NSTextAlignmentNatural;
    [_detailTextLabel setFont:[self detailTextLabelFont]];
}

- (void)setUpProgressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
    }
    _progressLabel.text = _progressText;
    _progressLabel.numberOfLines = 0;
    if (@available(iOS 13.0, *)) {
        _progressLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        _progressLabel.textColor = [UIColor lightGrayColor];
    }
    _progressLabel.textAlignment = NSTextAlignmentNatural;
    [_progressLabel setFont:[self progressLabelFont]];
}

- (void)setupTagLabel {
    if (!_tagLabel) {
        _tagLabel = [ORKTagLabel new];
    }
    _tagLabel.text = _tagText;
}

- (void)setupSelectAllThatApplyLabel {
    if (!_selectAllThatApplyLabel) {
        _selectAllThatApplyLabel = [UILabel new];
    }
    
    _selectAllThatApplyLabel.text = ORKLocalizedString(@"AX_SELECT_ALL_THAT_APPLY", nil);
    _selectAllThatApplyLabel.numberOfLines = 0;
    if (@available(iOS 13.0, *)) {
        _selectAllThatApplyLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        _selectAllThatApplyLabel.textColor = [UIColor lightGrayColor];
    }
    _selectAllThatApplyLabel.textAlignment = NSTextAlignmentNatural;
    [_selectAllThatApplyLabel setFont:[self selectAllThatApplyFont]];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)detailTextLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)progressLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)selectAllThatApplyFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleFootnote];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_headlineView) {
        if (!_headlineMaskLayer) {
            _headlineMaskLayer = [CAShapeLayer layer];
        }
        for (CALayer *sublayer in [_headlineMaskLayer.sublayers mutableCopy]) {
            [sublayer removeFromSuperlayer];
        }
        [_headlineMaskLayer removeFromSuperlayer];
        
        _headlineMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _headlineView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
        
        CAShapeLayer *foreLayer = [CAShapeLayer layer];
        UIColor *fillColor;
        UIColor *borderColor;
        if (@available(iOS 13.0, *)) {
            fillColor = [UIColor secondarySystemGroupedBackgroundColor];
            borderColor = UIColor.separatorColor;
        } else {
            fillColor = [UIColor whiteColor];
            borderColor = [UIColor ork_midGrayTintColor];
        }
        
        [foreLayer setFillColor:[fillColor CGColor]];
        CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, _headlineView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, _headlineView.bounds.size.height - ORKCardDefaultBorderWidth);
        
        CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
        
        foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        foreLayer.zPosition = 0.0f;
        
        [_headlineMaskLayer addSublayer:foreLayer];
        
        if (_titleLabel.text) {
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            CGRect lineBounds = CGRectMake(0.0, _headlineView.bounds.size.height - 1.0, _headlineView.bounds.size.width, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
            [lineLayer setFillColor:[borderColor CGColor]];
            
            [_headlineMaskLayer addSublayer:lineLayer];
        }
        
        if (_showBorder) {
            [_headlineMaskLayer setFillColor:[borderColor CGColor]];
        } else {
            [_headlineMaskLayer setFillColor:[[UIColor clearColor] CGColor]];
        }
        
        [_headlineView.layer insertSublayer:_headlineMaskLayer atIndex:0];
    }
    
}

- (BOOL)useLearnMoreLeftAlignmentLayout {
    return ((_learnMoreView != nil) && ([_learnMoreView isTextLink] == NO));
}

- (void)setupConstraints {
    NSLayoutXAxisAnchor *trailingAnchor = [self useLearnMoreLeftAlignmentLayout] ? _learnMoreView.leadingAnchor : _headlineView.trailingAnchor;
    NSLayoutYAxisAnchor *lastYAxisAnchor = self.topAnchor;
    
    _headlineView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_progressLabel) {
        _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[_progressLabel.topAnchor constraintEqualToAnchor:lastYAxisAnchor constant:ORKSurveyItemMargin] setActive:YES];
        [[_progressLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor] setActive:YES];
        [[_progressLabel.trailingAnchor constraintEqualToAnchor:trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
        lastYAxisAnchor = _progressLabel.bottomAnchor;
    }
    
    if (_tagLabel) {
        CGFloat topPadding = _progressLabel ? TagTopPadding : ORKSurveyItemMargin;
        _tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_tagLabel.topAnchor constraintEqualToAnchor:lastYAxisAnchor constant:topPadding].active = YES;
        [_tagLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor].active = YES;
        // FIXME:- learnMoreView gets compressed if we use _learnMoreView.leadingAnchor
        [_tagLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_headlineView.trailingAnchor constant:-ORKSurveyItemMargin].active = YES;
        lastYAxisAnchor = _tagLabel.bottomAnchor;
    }
    
    CGFloat titlePadding;
    if (_tagLabel) {
        titlePadding = TagBottomPadding;
    } else if (_progressLabel) {
        titlePadding = HeaderViewLabelTopBottomPadding;
    } else {
        titlePadding = ORKSurveyItemMargin;
    }
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [[_titleLabel.topAnchor constraintEqualToAnchor:lastYAxisAnchor constant:titlePadding] setActive:YES];
    [[_titleLabel.leadingAnchor constraintEqualToAnchor:_headlineView.leadingAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_titleLabel.trailingAnchor constraintEqualToAnchor:[self useLearnMoreLeftAlignmentLayout] ? _learnMoreView.leadingAnchor : _headlineView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
    lastYAxisAnchor = _titleLabel.bottomAnchor;
    NSLayoutYAxisAnchor *headlineViewBottomAnchor = _titleLabel.bottomAnchor;
    
    if (_detailTextLabel) {
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [[_detailTextLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:HeaderViewLabelTopBottomPadding] setActive:YES];
        [[_detailTextLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor] setActive:YES];
        [[_detailTextLabel.trailingAnchor constraintEqualToAnchor:[self useLearnMoreLeftAlignmentLayout] ? _learnMoreView.leadingAnchor : _headlineView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
        lastYAxisAnchor = _detailTextLabel.bottomAnchor;
        headlineViewBottomAnchor = _detailTextLabel.bottomAnchor;
    }
    
    if (_learnMoreView) {
        [self setupLearnMoreViewConstraints];
        if ([_learnMoreView isTextLink] == YES) {
            [_learnMoreView setLearnMoreButtonFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
            [_learnMoreView setLearnMoreButtonTextAlignment:NSTextAlignmentLeft];
            
            [[_learnMoreView.topAnchor constraintEqualToAnchor:_detailTextLabel ? _detailTextLabel.bottomAnchor : _titleLabel.bottomAnchor constant:HeaderViewLabelTopBottomPadding] setActive:YES];
            [[_learnMoreView.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor] setActive:YES];
            [[_learnMoreView.trailingAnchor constraintEqualToAnchor:[self useLearnMoreLeftAlignmentLayout] ? _learnMoreView.leadingAnchor : _headlineView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
            
            lastYAxisAnchor = _learnMoreView.bottomAnchor;
            headlineViewBottomAnchor = _learnMoreView.bottomAnchor;
        }
    }
    
    if (_selectAllThatApplyLabel) {
        _selectAllThatApplyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[_selectAllThatApplyLabel.topAnchor constraintEqualToAnchor:lastYAxisAnchor constant:SelectAllThatApplyTopPadding] setActive:YES];
        [[_selectAllThatApplyLabel.leadingAnchor constraintEqualToAnchor:_titleLabel.leadingAnchor] setActive:YES];
        [[_selectAllThatApplyLabel.trailingAnchor constraintEqualToAnchor:_titleLabel.trailingAnchor] setActive:YES];
        
        headlineViewBottomAnchor = _selectAllThatApplyLabel.bottomAnchor;
    }
    
    [[_headlineView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0.0] setActive:YES];
    [[_headlineView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    [[_headlineView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    [[_headlineView.bottomAnchor constraintEqualToAnchor: headlineViewBottomAnchor constant: _selectAllThatApplyLabel ? SelectAllThatApplyBottomPadding : HeaderViewBottomPadding] setActive:YES];
    
    [[self.bottomAnchor constraintEqualToAnchor:_headlineView.bottomAnchor constant:0.0] setActive:YES];
}

- (void) setupLearnMoreViewConstraints {
    if (_learnMoreViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_learnMoreViewConstraints];
    }
    _learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;

    if ([_learnMoreView isTextLink] == NO) {
        _learnMoreViewConstraints = @[
            [NSLayoutConstraint constraintWithItem:_learnMoreView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem: _titleLabel ? : _headlineView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1.0
                                          constant:_titleLabel ? 0.0 : ORKSurveyItemMargin],
            [NSLayoutConstraint constraintWithItem:_learnMoreView
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                            toItem: _headlineView
                                         attribute:NSLayoutAttributeTrailing
                                        multiplier:1.0
                                          constant:-ORKSurveyItemMargin],
            [NSLayoutConstraint constraintWithItem:_learnMoreView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem: _learnMoreView
                                         attribute:NSLayoutAttributeHeight
                                        multiplier:1.0
                                          constant: 0.0]
        ];
    }
    
    [NSLayoutConstraint activateConstraints:_learnMoreViewConstraints];
}

@end
