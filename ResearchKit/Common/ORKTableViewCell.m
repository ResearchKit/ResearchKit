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


#import "ORKTableViewCell.h"
#import "ORKSkin.h"
#import "ORKSelectionTitleLabel.h"


@implementation ORKTableViewCell {
    UIView *_topSeparator;
    NSLayoutConstraint *_topSeparatorLeftMarginConstraint;
    UIView *_bottomSeparator;
    NSLayoutConstraint *_bottomSeparatorLeftMarginConstraint;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        static UIColor *defaultSeparatorColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            UITableView *tableView = [[UITableView alloc] init];
            defaultSeparatorColor = [tableView separatorColor];
        });
        if (!defaultSeparatorColor) {
            defaultSeparatorColor = [UIColor lightGrayColor];
        }
        
        _orkSeparatorColor = defaultSeparatorColor;
        _topSeparatorLeftInset = 0;
        _bottomSeparatorLeftInset = 0;

        
        [self init_ORKTableViewCell];
        
    }
    return self;
}

- (void)setShowBottomSeparator:(BOOL)showBottomSeparator {
    _showBottomSeparator = showBottomSeparator;
    if (showBottomSeparator && _bottomSeparator == nil) {
        _bottomSeparator = [UIView new];
        _bottomSeparator.backgroundColor = _orkSeparatorColor;
        
        [self addSubview:_bottomSeparator];
        _bottomSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_bottomSeparator
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_bottomSeparator
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:separatorHeight]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_bottomSeparator
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        _bottomSeparatorLeftMarginConstraint = [NSLayoutConstraint constraintWithItem:_bottomSeparator
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:_bottomSeparatorLeftInset];
        
        [constraints addObject:_bottomSeparatorLeftMarginConstraint];
        
        [NSLayoutConstraint activateConstraints:constraints];
    }
    _bottomSeparator.hidden = !showBottomSeparator;
}

- (void)setShowTopSeparator:(BOOL)showTopSeparator {
    _showTopSeparator = showTopSeparator;
    
    if (showTopSeparator && _topSeparator == nil) {
        _topSeparator = [UIView new];
        _topSeparator.backgroundColor = _orkSeparatorColor;
        
        [self addSubview:_topSeparator];
        _topSeparator.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_topSeparator
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_topSeparator
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:separatorHeight]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_topSeparator
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:0.0]];
        
        _topSeparatorLeftMarginConstraint = [NSLayoutConstraint constraintWithItem:_topSeparator
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:_topSeparatorLeftInset];
        
        [constraints addObject:_topSeparatorLeftMarginConstraint];
        
        [NSLayoutConstraint activateConstraints:constraints];
    }
    _topSeparator.hidden = !showTopSeparator;
}

- (void)setBottomSeparatorLeftInset:(CGFloat)bottomSeparatorLeftInset {
    _bottomSeparatorLeftInset = bottomSeparatorLeftInset;
    _bottomSeparatorLeftMarginConstraint.constant = _bottomSeparatorLeftInset;
}

- (void)setTopSeparatorLeftInset:(CGFloat)topSeparatorLeftInset {
    _topSeparatorLeftInset = topSeparatorLeftInset;
    _topSeparatorLeftMarginConstraint.constant = _topSeparatorLeftInset;
}

- (void)init_ORKTableViewCell {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppearance)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.font = [ORKSelectionTitleLabel defaultFont];
    [self invalidateIntrinsicContentSize];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
