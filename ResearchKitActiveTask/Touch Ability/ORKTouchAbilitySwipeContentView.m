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

- (void)startTrial {
    [super startTrial];
    self.swipeUpGestureRecognizer.enabled    = YES;
    self.swipeDownGestureRecognizer.enabled  = YES;
    self.swipeLeftGestureRecognizer.enabled  = YES;
    self.swipeRightGestureRecognizer.enabled = YES;
}

- (void)endTrial {
    [super endTrial];
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
