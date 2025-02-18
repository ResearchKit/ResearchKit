/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKFamilyHistoryTableHeaderView.h"

static const CGFloat HeaderViewLabelTopBottomPadding = 6.0;
static const CGFloat HeaderViewLeftRightLabelPadding = 11.0;
static const CGFloat HeaderViewCollapsedBottomPadding = 0.0;
static const CGFloat HeaderViewExpandedBottomPadding = 10.0;
static const CGFloat CellLeftRightPadding = 8.0;
static const CGFloat MaxDetailLabelFont = 40.0;

@implementation ORKFamilyHistoryTableHeaderView {
    NSString *_title;
    UILabel *_titleLabel;
    NSString *_detailText;
    UILabel *_detailTextLabel;

    NSMutableArray<NSLayoutConstraint *> *_viewConstraints;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(nullable NSString *)detailText {
    self = [super init];
    
    if (self) {
        _title = [title copy];
        _detailText = [detailText copy];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += CellLeftRightPadding;
    frame.size.width -= 2 * CellLeftRightPadding;
    
    [super setFrame:frame];
}

- (void)setupSubviews {
    if (_titleLabel != nil) {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    
    if (_detailTextLabel != nil) {
        [_detailTextLabel removeFromSuperview];
        _detailTextLabel = nil;
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = _title;

    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [self titleLabelFont];
    [self addSubview:_titleLabel];
    
    if (_detailText != nil) {
        _detailTextLabel = [[UILabel alloc] init];
        _detailTextLabel.numberOfLines = 0;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.text = _detailText;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.font = [self detailTextLabelFont];
        [self addSubview:_detailTextLabel];
    }
    [self updateViewColors];
}

- (void)updateViewColors {
    if (@available(iOS 12.0, *)) {
        _detailTextLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
        _titleLabel.textColor = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor] : [UIColor blackColor];

    } else {
        _detailTextLabel.textColor = [UIColor blackColor];
        _titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateViewColors];
}

- (void)setupConstraints {
    if (_viewConstraints != nil) {
        [NSLayoutConstraint deactivateConstraints:_viewConstraints];
    }
    
    _viewConstraints = [NSMutableArray new];
    
    // titleLabel constraints
    [_viewConstraints addObject:[_titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:HeaderViewLabelTopBottomPadding]];
    [_viewConstraints addObject:[_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:HeaderViewLeftRightLabelPadding]];
    [_viewConstraints addObject:[_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-HeaderViewLeftRightLabelPadding]];
    
    UIView *bottomElementToConstraintViewTo;

    // detailLabel constraints if detailText was provided
    if (_detailText != nil) {
        [_viewConstraints addObject:[_detailTextLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:HeaderViewLabelTopBottomPadding]];
        [_viewConstraints addObject:[_detailTextLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:HeaderViewLeftRightLabelPadding]];
        [_viewConstraints addObject:[_detailTextLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-HeaderViewLeftRightLabelPadding]];
        bottomElementToConstraintViewTo = _detailTextLabel;
    } else {
        bottomElementToConstraintViewTo = _titleLabel;
    }
    
    // ORKFamilyHistoryTableHeaderView bottom constraint
    [_viewConstraints addObject:[self.bottomAnchor constraintEqualToAnchor:bottomElementToConstraintViewTo.bottomAnchor constant:HeaderViewCollapsedBottomPadding]];
    
    [NSLayoutConstraint activateConstraints:_viewConstraints];
}

- (void)setExpanded:(BOOL)isExpanded {
    NSLayoutConstraint *bottomConstraint = [_viewConstraints lastObject];
    bottomConstraint.constant =  isExpanded ? HeaderViewExpandedBottomPadding : HeaderViewCollapsedBottomPadding;
    [self setNeedsUpdateConstraints];
}

- (UIFont *)titleLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptor *fontDescriptor = [descriptor fontDescriptorWithSymbolicTraits:(UIFontDescriptorTraitBold)];
    return [UIFont fontWithDescriptor:fontDescriptor size:[[fontDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (UIFont *)detailTextLabelFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    double fontSize = [[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue];
    double suggestedFontSize = MIN(fontSize, MaxDetailLabelFont);
    return [UIFont fontWithDescriptor:descriptor size: suggestedFontSize];
}

@end
