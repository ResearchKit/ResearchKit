/*
  ORKDeviceMotionReactionTimeContentView.m
  ResearchKit

  Created by James Cox on 07/05/2015.
  Copyright (c) 2015 researchkit.org. All rights reserved.
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
