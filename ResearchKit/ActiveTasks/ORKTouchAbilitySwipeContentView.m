//
//  ORKTouchAbilitySwipeContentView.m
//  ResearchKit
//
//  Created by Tommy Lin on 2018/12/5.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKTouchAbilitySwipeContentView.h"
#import "ORKTouchAbilityArrowView.h"
#import "ORKTouchAbilitySwipeTrial.h"

@interface ORKTouchAbilitySwipeContentView ()

@property (nonatomic, assign) UISwipeGestureRecognizerDirection targetDirection;
@property (nonatomic, assign) UISwipeGestureRecognizerDirection resultDirection;
@property (nonatomic, assign) BOOL success;

@property (nonatomic, strong) ORKTouchAbilityArrowView *arrowView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGestureRecognizer;

@end

@implementation ORKTouchAbilitySwipeContentView

#pragma mark - Properties

- (ORKTouchAbilityArrowView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[ORKTouchAbilityArrowView alloc] initWithFrame:CGRectZero style:ORKTouchAbilityArrowViewStyleFill];
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
        
        NSMutableArray *constraintsArray = [NSMutableArray array];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.arrowView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.arrowView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];

        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.arrowView
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0.0];
        
        NSLayoutConstraint *bottomConstriant = [NSLayoutConstraint constraintWithItem:self.arrowView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                                               toItem:self.contentView
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0.0];
        
        topConstraint.priority = UILayoutPriorityFittingSizeLevel;
        bottomConstriant.priority = UILayoutPriorityFittingSizeLevel;
        
        [constraintsArray addObject:topConstraint];
        [constraintsArray addObject:bottomConstriant];
        
        [NSLayoutConstraint activateConstraints:constraintsArray];
        
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
    
    if ([self.dataSource respondsToSelector:@selector(targetDirectionInSwipeContentView:)]) {
        self.targetDirection = [self.dataSource targetDirectionInSwipeContentView:self];
    } else {
        self.targetDirection = UISwipeGestureRecognizerDirectionRight;
    }
    
    switch (self.targetDirection) {
            
        case UISwipeGestureRecognizerDirectionRight:
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            self.arrowView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
            
        case UISwipeGestureRecognizerDirectionUp:
            self.arrowView.transform = CGAffineTransformIdentity;
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
            break;
    }
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
