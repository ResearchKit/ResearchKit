//
//  ORKWaitStepView.h
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/6/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "ORKVerticalContainerView.h"
#import "ORKProgressView.h"
#import "ORKDefines.h"

@interface ORKWaitStepView : ORKVerticalContainerView

- (instancetype)initWithIndicatorMask:(ORKProgressIndicatorMask)mask heading:(NSString *)heading;

@property (nonatomic, strong) ORKSubheadlineLabel *textLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKProgressView *activityIndicatorView;
@property (nonatomic, assign) ORKProgressIndicatorMask indicatorMask;

@end
