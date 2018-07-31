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

static const CGFloat HeadlineViewTitleLeftRightPadding = 10.0;

@implementation ORKSurveyCardHeaderView {
    
    UIView *_headlineView;
    NSString *_title;
    UILabel *_titleLabel;
    CAShapeLayer *_headlineMaskLayer;
    NSArray<NSLayoutConstraint *> *_headerViewConstraints;
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

- (void)setupHeaderView {
    [self setupHeadlineView];
    [self setupTitleLabel];
    
    [_headlineView addSubview:_titleLabel];
    [self addSubview:_headlineView];
}

- (void) setupHeadlineView {
    if (!_headlineView) {
        _headlineView = [UIView new];
    }
}

- (void) setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.text = _title;
    [_titleLabel setFont:[UIFont systemFontOfSize:ORKCardDefaultFontSize weight:UIFontWeightBold]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupConstraints];
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
        [foreLayer setFillColor:[[UIColor whiteColor] CGColor]];
        CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, _headlineView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, _headlineView.bounds.size.height - ORKCardDefaultBorderWidth);
        
        CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
        
        foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        foreLayer.zPosition = 0.0f;
        
        [_headlineMaskLayer addSublayer:foreLayer];
        
        if (_titleLabel.text) {
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            CGRect lineBounds = CGRectMake(ORKCardLeftRightMargin, _headlineView.bounds.size.height - 1.0, _headlineView.bounds.size.width - 2 * ORKCardLeftRightMargin, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
            [lineLayer setFillColor:[[UIColor ork_midGrayTintColor] CGColor]];
            
            [_headlineMaskLayer addSublayer:lineLayer];
        }
        
        [_headlineMaskLayer setFillColor:[[UIColor ork_borderGrayColor] CGColor]];
        [_headlineView.layer insertSublayer:_headlineMaskLayer atIndex:0];
    }
}

- (void)setupConstraints {
    if (_headerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_headerViewConstraints];
    }
    _headlineView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _headerViewConstraints = @[
                               [NSLayoutConstraint constraintWithItem:_headlineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:_headlineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ORKCardLeftRightMargin],
                               [NSLayoutConstraint constraintWithItem:_headlineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant: -ORKCardLeftRightMargin],
                               
                               [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_headlineView attribute:NSLayoutAttributeTop multiplier:1.0 constant:ORKCardTopBottomMargin],
                               [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_headlineView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:HeadlineViewTitleLeftRightPadding],
                               [NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_headlineView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-HeadlineViewTitleLeftRightPadding],
                               [NSLayoutConstraint constraintWithItem:_headlineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ORKCardTopBottomMargin],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_headlineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]
                               ];
    
    [NSLayoutConstraint activateConstraints:_headerViewConstraints];
}

@end
