//
//  ORKVASSlider.h
//  ResearchKit
//
//  Created by Bill Byrom and Willie Muehlhausen, ICON Clinical Research.
//  Copyright (c) 2016 ICON Clinical Research.  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORKAnswerFormat.h"

@interface ORKVASSlider : UISlider

@property (nonatomic, assign) BOOL showThumb;
@property (nonatomic, assign) NSUInteger numberOfSteps;
@property (nonatomic, assign) ORKVASMarkerStyle markerStyle;

@end
