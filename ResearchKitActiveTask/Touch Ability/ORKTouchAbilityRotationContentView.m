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

#import "ORKTouchAbilityRotationContentView.h"
#import "ORKTouchAbilityArrowView.h"
#import "ORKTouchAbilityRotationTrial.h"

@interface ORKTouchAbilityRotationContentView ()

@property (nonatomic, assign) CGFloat targetRotation;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIView *guideView;

@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGestureRecognizer;

@end

@implementation ORKTouchAbilityRotationContentView

#pragma mark - Properties

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[ORKTouchAbilityArrowView alloc] initWithFrame:CGRectZero style:ORKTouchAbilityArrowViewStyleFill];
    }
    return _targetView;
}

- (UIView *)guideView {
    if (!_guideView) {
        _guideView = [[ORKTouchAbilityArrowView alloc] initWithFrame:CGRectZero style:ORKTouchAbilityArrowViewStyleStroke];
    }
    return _guideView;
}

- (UIRotationGestureRecognizer *)rotationGestureRecognizer {
    if (!_rotationGestureRecognizer) {
        _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGestureRecognizer:)];
    }
    return _rotationGestureRecognizer;
}

- (CGFloat)currentRotation {
    CGAffineTransform t = self.targetView.transform;
    return atan2(t.b, t.a);
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.targetView.translatesAutoresizingMaskIntoConstraints = NO;
        self.guideView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.targetView];
        [self.contentView addSubview:self.guideView];
        
        NSMutableArray *constraintsArray = [NSMutableArray array];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.guideView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.guideView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [NSLayoutConstraint activateConstraints:constraintsArray];
        
        [self.contentView addGestureRecognizer:self.rotationGestureRecognizer];
        self.rotationGestureRecognizer.enabled = NO;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.targetView.backgroundColor = self.tintColor;
}


#pragma mark - ORKTouchAbilityCustomView

+ (Class)trialClass {
    return [ORKTouchAbilityRotationTrial class];
}

- (ORKTouchAbilityTrial *)trial {
    ORKTouchAbilityRotationTrial *trial = (ORKTouchAbilityRotationTrial *)[super trial];
    trial.targetRotation = [self targetRotation];
    trial.resultRotation = [self currentRotation];
    return trial;
}

- (void)startTrial {
    [super startTrial];
    self.rotationGestureRecognizer.enabled = YES;
}

- (void)endTrial {
    [super endTrial];
    self.rotationGestureRecognizer.enabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.targetRotation = [self.dataSource targetRotationInRotationContentView:self] ?: 0.0;
    self.guideView.transform = CGAffineTransformMakeRotation(self.targetRotation);
    self.targetView.transform = CGAffineTransformIdentity;
}


#pragma mark - Gesture Recognizer Handler

- (void)handleRotationGestureRecognizer:(UIRotationGestureRecognizer *)sender {
    
    self.targetView.transform = CGAffineTransformRotate(self.targetView.transform, sender.rotation);
    sender.rotation = 0.0;
}

@end
