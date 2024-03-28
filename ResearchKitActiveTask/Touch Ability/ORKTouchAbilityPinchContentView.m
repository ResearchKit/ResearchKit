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


#import "ORKTouchAbilityPinchContentView.h"
#import "ORKTouchAbilityPinchGuideView.h"
#import "ORKTouchAbilityPinchTrial.h"

@interface ORKTouchAbilityPinchContentView ()

@property (nonatomic, assign) CGFloat targetScale;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIView *guideView;

@property (nonatomic, strong) NSLayoutConstraint *guideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *guideHeightConstraint;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@property (nonatomic, copy) NSArray *pinchTargetConstraints;

@end

@implementation ORKTouchAbilityPinchContentView

#pragma mark - Properties

- (UIView *)targetView {
    if (!_targetView) {
        _targetView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _targetView;
}

- (UIView *)guideView {
    if (!_guideView) {
        _guideView = [[ORKTouchAbilityPinchGuideView alloc] initWithFrame:CGRectZero];
    }
    return _guideView;
}

- (CGFloat)currentScale {
    CGAffineTransform t = self.targetView.transform;
    
    // x scale
    // CGFloat xScale = sqrt(t.a * t.a + t.c * t.c);
    
    // y scale
    // CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    
    return sqrt(t.a * t.a + t.c * t.c);
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    }
    return _pinchGestureRecognizer;
}


#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.targetView.backgroundColor = self.tintColor;
        self.targetView.translatesAutoresizingMaskIntoConstraints = NO;
        self.guideView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.targetView];
        [self.contentView addSubview:self.guideView];
        
        [self.contentView addGestureRecognizer:self.pinchGestureRecognizer];
        self.pinchGestureRecognizer.enabled = NO;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.targetView.backgroundColor = self.tintColor;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    if (self.pinchTargetConstraints != nil) {
        [NSLayoutConstraint deactivateConstraints:self.pinchTargetConstraints];
    }
    
    CGAffineTransform transform = self.targetView.transform;
    self.targetView.transform = CGAffineTransformIdentity;
    
    BOOL isWidthLessThanHeight = CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds);
    
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
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:isWidthLessThanHeight ? NSLayoutAttributeWidth : NSLayoutAttributeHeight
                                                            multiplier:1.0/3.0
                                                              constant:0.0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.targetView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.targetView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraintsArray];
    
    self.guideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.guideView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.targetView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0.0];
    
    self.guideHeightConstraint = [NSLayoutConstraint constraintWithItem:self.guideView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.targetView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0];
    
    [constraintsArray addObject:self.guideWidthConstraint];
    [constraintsArray addObject:self.guideHeightConstraint];
    
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
    self.pinchTargetConstraints = constraintsArray;
    
    self.targetView.transform = transform;
}

#pragma mark - ORKTouchAbilityCustomView

+ (Class)trialClass {
    return [ORKTouchAbilityPinchTrial class];
}

- (ORKTouchAbilityTrial *)trial {
    ORKTouchAbilityPinchTrial *trial = (ORKTouchAbilityPinchTrial *)[super trial];
    trial.targetScale = [self targetScale];
    trial.resultScale = [self currentScale];
    return trial;
}

- (void)startTrial {
    [super startTrial];
    self.pinchGestureRecognizer.enabled = YES;
}

- (void)endTrial {
    [super endTrial];
    self.pinchGestureRecognizer.enabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.targetView.transform = CGAffineTransformIdentity;

    self.targetScale = [self.dataSource targetScaleInPinchContentView:self] ?: 1.0;
    
    [NSLayoutConstraint deactivateConstraints:@[self.guideWidthConstraint, self.guideHeightConstraint]];
    
    self.guideWidthConstraint = [NSLayoutConstraint constraintWithItem:self.guideView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.targetView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:self.targetScale
                                                              constant:0.0];
    
    self.guideHeightConstraint = [NSLayoutConstraint constraintWithItem:self.guideView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.targetView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:self.targetScale
                                                               constant:0.0];
    
    [NSLayoutConstraint activateConstraints:@[self.guideWidthConstraint, self.guideHeightConstraint]];
    
}


#pragma mark - Gesture Recognizer Handler

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)sender {
    
    self.targetView.transform = CGAffineTransformScale(self.targetView.transform, sender.scale, sender.scale);
    sender.scale = 1.0;
}

@end
