//
//  ORKTouchAnywhereStepViewController.m
//  ResearchKit
//
//  Created by Darren Levy on 8/8/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKTouchAnywhereStepViewController.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKLabel.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"
#import "ORKSkin.h"

@interface ORKTouchAnywhereView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property (nonatomic, strong) UIView *progressView;

@end

@implementation ORKTouchAnywhereView

- (instancetype)init {
    self = [super init];
    if (self) {
        _progressView = [ORKProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:_progressView];
        
        [self setUpConstraints];
        [self updateConstraintConstantsForWindow:self.window];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView);
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_progressView]-(>=0)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    _topConstraint = [NSLayoutConstraint constraintWithItem:_progressView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0]; // constant will be set in updateConstraintConstantsForWindow:
    [constraints addObject:_topConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_progressView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    const CGFloat CaptionBaselineToProgressTop = 100;
    const CGFloat CaptionBaselineToStepViewTop = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTop, window);
    _topConstraint.constant = CaptionBaselineToProgressTop - CaptionBaselineToStepViewTop;
}

@end


@interface ORKTouchAnywhereStepViewController ()

@property (nonatomic, strong) ORKTouchAnywhereView *touchAnywhereView;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;

@end


@implementation ORKTouchAnywhereStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _touchAnywhereView = [[ORKTouchAnywhereView alloc] init];
    _touchAnywhereView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _touchAnywhereView;
    self.cancelButtonItem = nil;
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.activeStepView addGestureRecognizer:_gestureRecognizer];
    self.internalContinueButtonItem = nil;
}

- (void)handleTap:(UIGestureRecognizer *)sender {
    [self goForward];
}

@end

