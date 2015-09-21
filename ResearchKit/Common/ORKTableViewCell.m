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


@interface ORKTableViewCell ()

@property (nonatomic, strong) UIView *topSeparator;
@property (nonatomic, strong) UIView *bottomSeparator;

@end


@implementation ORKTableViewCell

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
        _topSeparatorLeftInset = ORKStandardLeftMarginForTableViewCell(self);
        _bottomSeparatorLeftInset = ORKStandardLeftMarginForTableViewCell(self);
        
        _topSeparator = [UIView new];
        _bottomSeparator = [UIView new];
        
        [self init_ORKTableViewCell];
        
    }
    return self;
}

- (void)updateSeparatorInsets {
    
    if (self.topSeparatorLeftInset > 0) {
        self.topSeparatorLeftInset = ORKStandardLeftMarginForTableViewCell(self);
    }
    if (self.bottomSeparatorLeftInset > 0) {
        self.bottomSeparatorLeftInset = ORKStandardLeftMarginForTableViewCell(self);
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateSeparatorInsets];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateSeparatorInsets];
}

- (void)setShowBottomSeparator:(BOOL)showBottomSeparator {
    _showBottomSeparator = showBottomSeparator;
    [self setNeedsLayout];
}

- (void)setShowTopSeparator:(BOOL)showTopSeparator {
    _showTopSeparator = showTopSeparator;
    [self setNeedsLayout];
}

- (void)setBottomSeparatorLeftInset:(CGFloat)bottomSeparatorLeftInset {
    _bottomSeparatorLeftInset = bottomSeparatorLeftInset;
    [self setNeedsLayout];
}

- (void)setTopSeparatorLeftInset:(CGFloat)topSeparatorLeftInset {
    _topSeparatorLeftInset = topSeparatorLeftInset;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = self.bounds.size.width;
    CGFloat cellHeight = self.bounds.size.height;
    CGFloat separatorHeight = 1.0 / [UIScreen mainScreen].scale;
    
    if (_showTopSeparator) {
        _topSeparator.backgroundColor = _orkSeparatorColor;
        _topSeparator.frame = CGRectMake(_topSeparatorLeftInset, 0.0, cellWidth, separatorHeight);
        [self addSubview:_topSeparator];
        
    } else {
        [_topSeparator removeFromSuperview];
    }
    
    if (_showBottomSeparator) {
        _bottomSeparator.backgroundColor = _orkSeparatorColor;
        _bottomSeparator.frame = CGRectMake(_bottomSeparatorLeftInset, cellHeight-separatorHeight, cellWidth, separatorHeight);
        [self addSubview:_bottomSeparator];
    } else {
        [_bottomSeparator removeFromSuperview];
    }
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
