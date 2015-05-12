/*
  ORKDeviceMotionReactionTimeContentView.h
  ResearchKit

  Created by James Cox on 07/05/2015.
  Copyright (c) 2015 researchkit.org. All rights reserved.
*/


#import "ORKCustomStepView_Internal.h"


@interface ORKDeviceMotionReactionTimeContentView : ORKActiveStepCustomView

@property (nonatomic, strong, nonnull) UIBarButtonItem *buttonItem;

- (void)setStimulusHidden:(BOOL)hidden;

- (void)setReadyHidden:(BOOL)hidden;

- (void)startReadyAnimationWithDuration:(NSTimeInterval)duration completion: (nullable void (^)(void)) completion;

- (void)startSuccessAnimationWithDuration:(NSTimeInterval)duration completion: (nullable void (^)(void)) completion;

- (void)startFailureAnimationWithDuration:(NSTimeInterval)duration completion: (nullable void (^)(void)) completion;

@end
