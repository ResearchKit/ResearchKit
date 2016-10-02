//
//  ORKRangeOfMotionStepViewController.m
//  ResearchKit
//
//  Created by Darren Levy on 8/20/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKRangeOfMotionStepViewController.h"
#import "ORKCustomStepView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"
#import "ORKSkin.h"

#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))

@interface ORKRangeOfMotionContentView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property  (nonatomic, strong, readonly) ORKProgressView *progressView;

@end


@implementation ORKRangeOfMotionContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _progressView = [ORKProgressView new];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_progressView];
        [self setUpConstraints];
        [self updateConstraintConstantsForWindow:self.window];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
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

- (void)updateConstraints {
    [self updateConstraintConstantsForWindow:self.window];
    [super updateConstraints];
}

@end

@interface ORKRangeOfMotionStepViewController () <ORKDeviceMotionRecorderDelegate> {
    ORKRangeOfMotionContentView *_contentView;
    UITapGestureRecognizer *_gestureRecognizer;
    CMAttitude *_referenceAttitude;
    UIInterfaceOrientation _orientation;
    double _highestAngle;
    double _lowestAngle;
    double _lastAngle;
}
@end


@implementation ORKRangeOfMotionStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _contentView = [ORKRangeOfMotionContentView new];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _contentView;
    _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.activeStepView addGestureRecognizer:_gestureRecognizer];
}

- (void)handleTap:(UIGestureRecognizer *)sender {
    [self calculateAndSetFlexedAndExtendedAngles];
    [self finish];
}

- (void)calculateAndSetFlexedAndExtendedAngles {
    _flexedAngle = fabs([self getDeviceAngleInDegreesFromAttitude:_referenceAttitude]);
    
    BOOL rangeOfMotionMoreThan180Degrees = _highestAngle > 175 && _lowestAngle < 175;
    if (rangeOfMotionMoreThan180Degrees) {
        _rangeOfMotionAngle = 360 - fabs(_lastAngle);
    } else {
        _rangeOfMotionAngle = fabs(_lastAngle);
    }
}

#pragma mark - ORKDeviceMotionRecorderDelegate

- (void)deviceMotionRecorderDidUpdateWithMotion:(CMDeviceMotion *)motion {
    if (!_referenceAttitude) {
        _referenceAttitude = motion.attitude;
    }
    CMAttitude *currentAttitude = [motion.attitude copy];

    [currentAttitude multiplyByInverseOfAttitude:_referenceAttitude];
    
    double angle = [self getDeviceAngleInDegreesFromAttitude:currentAttitude];

    if (angle > _highestAngle) {
        _highestAngle = angle;
    }
    if (angle < _lowestAngle) {
        _lowestAngle = angle;
    }
    _lastAngle = angle;
}

/*
 When the device is in Portrait mode, we need to get the attitude's pitch
 to determine the device's angle. attitude.pitch doesn't return all
 orientations, so we use the attitude's quaternion to calculate the
 angle.
 */
- (double)getDeviceAngleInDegreesFromAttitude:(CMAttitude *)attitude {
    if (!_orientation) {
        _orientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    double angle;
    if (UIInterfaceOrientationIsLandscape(_orientation)) {
        angle = radiansToDegrees(attitude.roll);
    } else {
        double x = attitude.quaternion.x;
        double w = attitude.quaternion.w;
        double y = attitude.quaternion.y;
        double z = attitude.quaternion.z;
        angle = radiansToDegrees(allOrientationsForPitch(x, w, y, z));
    }
    return angle;
}


#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    result.flexed = _flexedAngle;
    result.extended = result.flexed - _rangeOfMotionAngle;
    return result;
}

@end
