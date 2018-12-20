//
//  ORKTouchAbilitySwipeContentView.m
//  ResearchKit
//
//  Created by Tommy Lin on 2018/12/5.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKTouchAbilitySwipeContentView.h"
#import "ORKTouchAbilitySwipeArrowView.h"
#import "ORKTouchAbilitySwipeTrial.h"

@interface ORKTouchAbilitySwipeContentView ()

@property (nonatomic, assign) UISwipeGestureRecognizerDirection targetDirection;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection resultDirection;
@property (nonatomic, assign) BOOL success;

@property (nonatomic, strong) ORKTouchAbilitySwipeArrowView *arrowView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGestureRecognizer;

@end

@implementation ORKTouchAbilitySwipeContentView

#pragma mark - Properties

- (ORKTouchAbilitySwipeArrowView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[ORKTouchAbilitySwipeArrowView alloc] initWithFrame:CGRectZero];
        _arrowView.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _arrowView;
}

- (UISwipeGestureRecognizer *)swipeUpGestureRecognizer {
    if (!_swipeUpGestureRecognizer) {
        _swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecoginzer:)];
        _swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    }
    return _swipeUpGestureRecognizer;
}

- (UISwipeGestureRecognizer *)swipeDownGestureRecognizer {
    if (!_swipeDownGestureRecognizer) {
        _swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecoginzer:)];
        _swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _swipeDownGestureRecognizer;
}

- (UISwipeGestureRecognizer *)swipeLeftGestureRecognizer {
    if (!_swipeLeftGestureRecognizer) {
        _swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecoginzer:)];
        _swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _swipeLeftGestureRecognizer;
}

- (UISwipeGestureRecognizer *)swipeRightGestureRecognizer {
    if (!_swipeRightGestureRecognizer) {
        _swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRecoginzer:)];
        _swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _swipeRightGestureRecognizer;
}


#pragma mark - UIView

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
        
        self.swipeUpGestureRecognizer.enabled    = NO;
        self.swipeDownGestureRecognizer.enabled  = NO;
        self.swipeLeftGestureRecognizer.enabled  = NO;
        self.swipeRightGestureRecognizer.enabled = NO;
        
        [self.contentView addGestureRecognizer:self.swipeUpGestureRecognizer];
        [self.contentView addGestureRecognizer:self.swipeDownGestureRecognizer];
        [self.contentView addGestureRecognizer:self.swipeLeftGestureRecognizer];
        [self.contentView addGestureRecognizer:self.swipeRightGestureRecognizer];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.arrowView.tintColor = self.tintColor;
}


#pragma mark - ORKTouchAbilityCustomView

+ (Class)trialClass {
    return [ORKTouchAbilitySwipeTrial class];
}

- (ORKTouchAbilityTrial *)trial {
    
    ORKTouchAbilitySwipeTrial *trial = (ORKTouchAbilitySwipeTrial *)[super trial];
    trial.targetDirection = self.targetDirection;
    trial.resultDirection = self.resultDirection;
    trial.success = self.success;
    
    return trial;
}

- (void)startTracking {
    [super startTracking];
    self.swipeUpGestureRecognizer.enabled    = YES;
    self.swipeDownGestureRecognizer.enabled  = YES;
    self.swipeLeftGestureRecognizer.enabled  = YES;
    self.swipeRightGestureRecognizer.enabled = YES;
}

- (void)stopTracking {
    [super stopTracking];
    self.swipeUpGestureRecognizer.enabled    = NO;
    self.swipeDownGestureRecognizer.enabled  = NO;
    self.swipeLeftGestureRecognizer.enabled  = NO;
    self.swipeRightGestureRecognizer.enabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.success = NO;
    self.resultDirection = UISwipeGestureRecognizerDirectionRight;
    
    if ([self.dataSource respondsToSelector:@selector(targetDirection:)]) {
        self.targetDirection = [self.dataSource targetDirection:self];
    } else {
        self.targetDirection = UISwipeGestureRecognizerDirectionRight;
    }
    _arrowView.direction = self.targetDirection;
}


#pragma mark - Gesture Recognizer Handler

- (void)handleSwipeGestureRecoginzer:(UISwipeGestureRecognizer *)sender {
    self.resultDirection = sender.direction;
    [self checkSuccess];
}

- (void)checkSuccess {
    if (self.resultDirection == self.targetDirection) {
        self.success = YES;
    } else {
        self.success = NO;
    }
}

@end
