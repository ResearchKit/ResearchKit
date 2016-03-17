//
//  ORKVASSlider.h
//  ResearchKit
//
//  Created by Janusz Bień on 16.03.2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORKAnswerFormat.h"

@interface ORKVASSlider : UISlider

@property (nonatomic, assign) BOOL showThumb;
@property (nonatomic, assign) NSUInteger numberOfSteps;
@property (nonatomic, assign) ORKVASMarkerStyle markerStyle;

@end
