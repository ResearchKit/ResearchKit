//
//  FooterView.m
//  ORKTest
//
//  Created by Shannon Young on 6/27/16.
//  Copyright © 2016 ResearchKit. All rights reserved.
//

#import "FooterView.h"
#import <ResearchKit/ResearchKit.h>

@implementation FooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    // Add continue button and constraints
    _continueButton = [[ORKContinueButton alloc] initWithTitle:NSLocalizedString(@"Done", @"") isDoneButton:NO];
    _continueButton.exclusiveTouch = YES;
    _continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_continueButton];
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:-20.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_continueButton
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

@end
