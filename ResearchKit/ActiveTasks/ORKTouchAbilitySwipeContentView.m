//
//  ORKTouchAbilitySwipeContentView.m
//  ResearchKit
//
//  Created by Tommy Lin on 2018/12/5.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKTouchAbilitySwipeContentView.h"
#import "ORKTouchAbilitySwipeArrowView.h"

@interface ORKTouchAbilitySwipeContentView ()

@property (nonatomic, assign) UISwipeGestureRecognizerDirection *targetDirection;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKTouchAbilitySwipeArrowView *arrowView;

@end

@implementation ORKTouchAbilitySwipeContentView

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
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        self.arrowView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.progressView];
        [self addSubview:self.arrowView];
        
        NSArray *progressConstraints = @[[self.progressView.topAnchor constraintEqualToAnchor:self.layoutMarginsGuide.topAnchor],
                                         [self.progressView.leftAnchor constraintEqualToAnchor:self.readableContentGuide.leftAnchor],
                                         [self.progressView.rightAnchor constraintEqualToAnchor:self.readableContentGuide.rightAnchor]];
        
        [NSLayoutConstraint activateConstraints:progressConstraints];
        
        NSLayoutConstraint *centerXConstraint = [self.arrowView.centerXAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerXAnchor];
        NSLayoutConstraint *centerYConstraint = [self.arrowView.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor];
        NSLayoutConstraint *topConstraint = [self.arrowView.topAnchor constraintGreaterThanOrEqualToAnchor:self.progressView.bottomAnchor];
        NSLayoutConstraint *bottomConstriant = [self.arrowView.bottomAnchor constraintLessThanOrEqualToAnchor:self.layoutMarginsGuide.bottomAnchor];
        
        topConstraint.priority = UILayoutPriorityFittingSizeLevel;
        bottomConstriant.priority = UILayoutPriorityFittingSizeLevel;
        
        [NSLayoutConstraint activateConstraints:@[centerXConstraint, centerYConstraint, topConstraint, bottomConstriant]];
        
        [self reloadData];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.arrowView.tintColor = self.tintColor;
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

- (void)setArrowViewHidden:(BOOL)hidden animated:(BOOL)animated {
    [self setArrowViewHidden:hidden animated:animated completion:nil];
}

- (void)setArrowViewHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    NSTimeInterval totalDuration = 1.0;
    NSTimeInterval hideDuration = 0.2;
    NSTimeInterval remainDuration = totalDuration - hideDuration;
    
    [UIView animateWithDuration:animated ? hideDuration : 0 delay:0.0 options:0 animations:^{
        [self.arrowView setAlpha:hidden ? 0 : 1];
    } completion:^(BOOL finished) {
        if (completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion(finished);
            });
        }
    }];
}

- (void)reloadData {
    
    if ([self.dataSource respondsToSelector:@selector(targetDirection:)]) {
        _arrowView.direction = [self.dataSource targetDirection:self];
    } else {
        _arrowView.direction = UISwipeGestureRecognizerDirectionRight;
    }
}

- (ORKTouchAbilitySwipeArrowView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[ORKTouchAbilitySwipeArrowView alloc] initWithFrame:CGRectZero];
        _arrowView.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _arrowView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    return _progressView;
}

@end
