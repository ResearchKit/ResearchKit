/*
 Copyright (c) 2015, James Cox. All rights reserved.
 
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


#import "ORKDeviceMotionReactionTimeContentView.h"
#import "ORKDeviceMotionReactionTimeStimulusView.h"
#import "ORKNavigationContainerView.h"


@interface ORKDeviceMotionReactionTimeContentView ()

@property (nonatomic, strong) ORKDeviceMotionReactionTimeStimulusView *stimulusView;

@end

@implementation ORKDeviceMotionReactionTimeContentView {
    
    NSArray *_constraints;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addStimulusView];
    }
    return  self;
}

- (void)startSuccessAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [_stimulusView startSuccessAnimationWithDuration:duration completion:completion];
}

- (void)startFailureAnimationWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion {
    [_stimulusView startFailureAnimationWithDuration:duration completion:completion];
}

- (void)resetAfterDelay:(NSTimeInterval)delay completion: (nullable void (^)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeConstraints];
        [_stimulusView removeFromSuperview];
        [self addStimulusView];
        [_stimulusView setStimulusHidden:true];
        completion();
    });
}

- (void)addStimulusView {
    _stimulusView = [ORKDeviceMotionReactionTimeStimulusView new];
    _stimulusView.translatesAutoresizingMaskIntoConstraints = NO;
    _stimulusView.backgroundColor = self.tintColor;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stimulusView];
    [self setNeedsUpdateConstraints];
}

- (void)setStimulusHidden:(BOOL)hidden {
    [_stimulusView setStimulusHidden:hidden];
}

- (void)removeConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
}

- (void)updateConstraints {
    [self removeConstraints];
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_stimulusView);
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_stimulusView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_stimulusView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1 constant: 8]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_stimulusView]-(>=0)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    
    _constraints = constraints;
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

@end
