//
//  BuddyBackgroundView.m
//  ResearchKit
//
//  Created by Atte Keltanen on 23/06/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "BuddyBackgroundView.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation BuddyBackgroundView: UIView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor* startColor = [UIColor colorWithRed:57.0/255.0 green:159.0/255.0 blue:206.0/255.0 alpha:1.0];
    UIColor* endColor = [UIColor colorWithRed:27.0/255.0 green:79.0/255.0 blue:178.0/255.0 alpha:1.0];

    CGFloat colors[8] = {57.0/255.0, 159.0/255.0, 206.0/255.0, 1.0f,
        27.0/255.0, 79.0/255.0, 178.0/255.0, 1.0f
    };

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {1.0f, 0.0f};

    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
    CGPoint startPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 100.0f);
    CGPoint endPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - 100.0f);
    CGContextDrawRadialGradient(context, gradient, startPoint, 850.0f, endPoint, 0.0f, nil);
}

@end