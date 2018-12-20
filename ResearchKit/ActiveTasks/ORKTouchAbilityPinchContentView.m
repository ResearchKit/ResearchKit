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

@interface ORKTouchAbilityPinchContentView ()

@property (nonatomic, assign) CGFloat targetScale;

@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, strong) UIView *guideView;

@property (nonatomic, strong) NSLayoutConstraint *guideWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *guideHeightConstraint;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation ORKTouchAbilityPinchContentView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.targetView.backgroundColor = self.tintColor;
        self.targetView.translatesAutoresizingMaskIntoConstraints = NO;
        self.guideView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.targetView];
        [self.contentView addSubview:self.guideView];

        
        NSArray *targetConstraints = @[[self.targetView.centerXAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor],
                                       [self.targetView.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
                                       [self.targetView.widthAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.3],
                                       [self.targetView.heightAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor multiplier:0.3],
                                       [self.targetView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.heightAnchor multiplier:0.3],
                                       [self.targetView.heightAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.widthAnchor multiplier:0.3]];
        
        [NSLayoutConstraint activateConstraints:targetConstraints];
        
        NSLayoutConstraint *topConstraint = [self.targetView.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor];
        NSLayoutConstraint *bottomConstriant = [self.targetView.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor];
        
        topConstraint.priority = UILayoutPriorityFittingSizeLevel;
        bottomConstriant.priority = UILayoutPriorityFittingSizeLevel;
        
        [NSLayoutConstraint activateConstraints:@[topConstraint, bottomConstriant]];
        
        self.guideWidthConstraint = [self.guideView.widthAnchor constraintEqualToAnchor:self.targetView.widthAnchor];
        self.guideHeightConstraint = [self.guideView.heightAnchor constraintEqualToAnchor:self.targetView.heightAnchor];
        
        NSArray *guideConstraint = @[[self.guideView.centerXAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerXAnchor],
                                     [self.guideView.centerYAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.centerYAnchor],
                                     self.guideWidthConstraint,
                                     self.guideHeightConstraint];
        
        [NSLayoutConstraint activateConstraints:guideConstraint];
        
        [self.contentView addGestureRecognizer:self.pinchGestureRecognizer];
        self.pinchGestureRecognizer.enabled = NO;
    }
    return self;
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

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.targetView.backgroundColor = self.tintColor;
}

- (void)startTracking {
    [super startTracking];
    self.pinchGestureRecognizer.enabled = YES;
}

- (void)stopTracking {
    [super stopTracking];
    self.pinchGestureRecognizer.enabled = NO;
}

- (void)reloadData {
    [self resetTracks];
    
    self.targetView.transform = CGAffineTransformIdentity;

    self.targetScale = [self.dataSource targetScale:self] ?: 1.0;
    
    [NSLayoutConstraint deactivateConstraints:@[self.guideWidthConstraint, self.guideHeightConstraint]];
    
    self.guideWidthConstraint = [self.guideView.widthAnchor constraintEqualToAnchor:self.targetView.widthAnchor multiplier:self.targetScale];
    self.guideHeightConstraint = [self.guideView.heightAnchor constraintEqualToAnchor:self.targetView.heightAnchor multiplier:self.targetScale];
    
    [NSLayoutConstraint activateConstraints:@[self.guideWidthConstraint, self.guideHeightConstraint]];
    
}

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

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)sender {
    
    self.targetView.transform = CGAffineTransformScale(self.targetView.transform, sender.scale, sender.scale);
    sender.scale = 1.0;
}

@end
