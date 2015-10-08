//
//  ORKWaitStepView.h
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/6/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//


#import "ORKVerticalContainerView.h"


@interface ORKWaitStepView : ORKVerticalContainerView

- (instancetype)initWithIndicatorType:(ORKProgressIndicatorType)type;

@property (nonatomic, readonly) UIProgressView *progressView;

@end
