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

@property (nonatomic,strong) ORKNavigationContainerView *continueView;

@end

@implementation ORKDeviceMotionReactionTimeContentView {
    
    NSArray *_constraints;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.stimulusView = [ORKDeviceMotionReactionTimeStimulusView new];
        self.continueView = [ORKNavigationContainerView new];
        
        self.stimulusView.translatesAutoresizingMaskIntoConstraints = NO;
        self.continueView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.stimulusView.backgroundColor = self.tintColor;
        
        [self addSubview:_stimulusView];
        [self addSubview:_continueView];
        
        _continueView.continueEnabled = YES;
        _continueView.bottomMargin = 20;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setNeedsUpdateConstraints];
    }
    return  self;
}

- (void)startReadyAnimationWithDuration:(NSTimeInterval)duration completion: (void(^)(void)) completion {
    [_stimulusView startReadyAnimationWithDuration:duration completion:completion];
}

- (void)startSuccessAnimationWithDuration:(NSTimeInterval)duration completion: (void (^)(void)) completion {
    [_stimulusView startSuccessAnimationWithDuration:duration completion:completion];
}

- (void)startFailureAnimationWithDuration:(NSTimeInterval)duration completion: (void (^ __nullable)(void)) completion {
    [_stimulusView startFailureAnimationWithDuration:duration completion:completion];
}

- (void)setButtonItem:(UIBarButtonItem *)buttonItem {
    _continueView.continueButtonItem = buttonItem;
}

- (void)setStimulusHidden:(BOOL)hidden {
    [_stimulusView hideStimulus:hidden];
}

- (void)setReadyHidden:(BOOL)hidden {
    _continueView.hidden = hidden;
}

- (void)updateConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_continueView, _stimulusView);
    
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
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[_stimulusView]-(>=8)-[_continueView]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];
    
    _constraints = constraints;
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

@end
