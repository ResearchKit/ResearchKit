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
@property (nonatomic, strong) ORKTouchAbilitySwipeArrowView *arrowView;

@end

@implementation ORKTouchAbilitySwipeContentView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.arrowView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.arrowView];
        
        NSLayoutConstraint *centerXConstraint = [self.arrowView.centerXAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor];
        NSLayoutConstraint *centerYConstraint = [self.arrowView.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor];
        NSLayoutConstraint *topConstraint = [self.arrowView.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor];
        NSLayoutConstraint *bottomConstriant = [self.arrowView.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor];
        
        topConstraint.priority = UILayoutPriorityFittingSizeLevel;
        bottomConstriant.priority = UILayoutPriorityFittingSizeLevel;
        
        [NSLayoutConstraint activateConstraints:@[centerXConstraint, centerYConstraint, topConstraint, bottomConstriant]];
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

- (void)reloadData {
    [self resetTracks];
    
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

@end
