/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityTapContentView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@interface ORKTouchAbilityTapContentView ()

@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger targetColumn;
@property (nonatomic, assign) NSUInteger targetRow;
@property (nonatomic, assign) CGSize targetSize;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, copy) NSArray *targetConstraints;

@end

@implementation ORKTouchAbilityTapContentView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.progressView.progressTintColor = self.tintColor;
        self.progressView.isAccessibilityElement = YES;
        [self.progressView setAlpha:0.0];
        [self.progressView setProgress:0.0 animated:NO];
        
        self.targetView.backgroundColor = self.tintColor;

        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.targetView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.progressView];
        [self addSubview:self.targetView];
        
        NSArray *progressConstraints = @[[self.progressView.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
                                         [self.progressView.leftAnchor constraintEqualToAnchor:self.readableContentGuide.leftAnchor],
                                         [self.progressView.rightAnchor constraintEqualToAnchor:self.readableContentGuide.rightAnchor]];
        
        [NSLayoutConstraint activateConstraints:progressConstraints];
        
        NSLayoutConstraint *topConstraint = [self.targetView.topAnchor constraintGreaterThanOrEqualToAnchor:self.progressView.bottomAnchor];
        NSLayoutConstraint *bottomConstriant = [self.targetView.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor];
        
        topConstraint.priority = UILayoutPriorityFittingSizeLevel;
        bottomConstriant.priority = UILayoutPriorityFittingSizeLevel;
        
        [NSLayoutConstraint activateConstraints:@[topConstraint, bottomConstriant]];
        
        [self reloadData];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.targetView.backgroundColor = self.tintColor;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self reloadData];
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (self.superview != nil) {
        [self reloadData];
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
}

- (void)setTargetViewHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setTargetViewHidden:hidden animated:animated completion:nil];
}

- (void)setTargetViewHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    NSTimeInterval totalDuration = 1.0;
    NSTimeInterval hideDuration = 0.2;
    NSTimeInterval remainDuration = totalDuration - hideDuration;
    
    [UIView animateWithDuration:animated ? hideDuration : 0 delay:0.0 options:0 animations:^{
        [self.targetView setAlpha:hidden ? 0 : 1];
    } completion:^(BOOL finished) {
        if (completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(finished);
            });
        }
    }];
}

- (void)reloadData {
    [self resetTracks];
    
    self.numberOfColumns = [self.dataSource numberOfColumns:self] ?: 1;
    self.numberOfRows = [self.dataSource numberOfRows:self] ?: 1;
    self.targetColumn = [self.dataSource targetColumn:self] ?: 0;
    self.targetRow = [self.dataSource targetRow:self] ?: 0;
    
    NSAssert(self.targetColumn >= 0 && self.targetColumn < self.numberOfColumns, @"Target column out of bounds.");
    NSAssert(self.targetRow >= 0 && self.targetRow < self.numberOfRows, @"target row out of bounds.");
    
    if ([self.dataSource respondsToSelector:@selector(targetSize:)]) {
        self.targetSize = [self.dataSource targetSize:self];
    } else {
        self.targetSize = CGSizeMake(76, 76);
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints {
    [super updateConstraints];

    if (self.numberOfColumns == 0 || self.numberOfRows == 0 || self.targetView.superview == nil) {
        return;
    }
    
    CGFloat width = self.layoutMarginsGuide.layoutFrame.size.width / self.numberOfColumns;
    CGFloat height = self.layoutMarginsGuide.layoutFrame.size.height / self.numberOfRows;

    CGFloat columnMidX = width * (self.targetColumn + 1.0/2.0);
    CGFloat rowMidY = height * (self.targetRow + 1.0/2.0);

    if (self.targetConstraints != nil) {
        [NSLayoutConstraint deactivateConstraints:self.targetConstraints];
    }

    NSLayoutConstraint *widthConstraint = [self.targetView.widthAnchor constraintEqualToConstant:self.targetSize.width];
    NSLayoutConstraint *heightConstraint = [self.targetView.heightAnchor constraintEqualToConstant:self.targetSize.height];
    NSLayoutConstraint *centerXConstraint = [self.targetView.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leftAnchor constant:columnMidX];
    NSLayoutConstraint *centerYConstraint = [self.targetView.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor constant:rowMidY];

    NSArray *constraints = @[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint];
    [NSLayoutConstraint activateConstraints:constraints];

    self.targetConstraints = constraints;
}

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _targetView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    return _progressView;
}

@end
