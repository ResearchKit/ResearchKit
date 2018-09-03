/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKRangeOfMotionStepViewController.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"
#import "ORKRangeOfMotionResult.h"
#import "ORKSkin.h"


#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))
#define allOrientationsForRoll(x, w, y, z) (atan2(2.0 * (y*w - x*z), 1.0 - 2.0 * (y*y + z*z)))
#define allOrientationsForYaw(x, w, y, z) (asin(2.0 * (x*y - w*z)))


@interface ORKRangeOfMotionContentView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property (nonatomic, strong, readonly) ORKProgressView *progressView;

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
    //This function records the angle of the device when the screen is tapped
- (void)handleTap:(UIGestureRecognizer *)sender {
    [self calculateAndSetAngles];
    [self finish];
}

- (void)calculateAndSetAngles {
    _startAngle = ([self getDeviceAngleInDegreesFromAttitude:_referenceAttitude]);
    
    //This function calculates maximum and minimum angles recorded by the device
    if (_newAngle > _maxAngle) {
        _maxAngle = _newAngle;
    }
    if (_minAngle == 0.0 || _newAngle < _minAngle) {
        _minAngle = _newAngle;
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

    //This function shifts the range of angles reported by the device from +/-180 degrees to -90 to +270 degrees, which should be sufficient to cover all ahievable knee and shoulder ranges of motion
    BOOL shiftAngleRange = angle > 90 && angle <= 180;
    if (shiftAngleRange) {
        _newAngle = fabs(angle) - 360;
    } else {
        _newAngle = angle;
    }
    
    [self calculateAndSetAngles];
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
        double x = attitude.quaternion.x;
        double w = attitude.quaternion.w;
        double y = attitude.quaternion.y;
        double z = attitude.quaternion.z;
        angle = radiansToDegrees(allOrientationsForRoll(x, w, y, z));
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
    ORKStepResult *stepResult = [super result];
    
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    
    result.start = 90.0 - _startAngle;
    result.finish = result.start - _newAngle;
    //Because the task uses pitch in the direction opposite to the original CoreMotion device axes (i.e. right hand rule), maximum and minimum angles are reported the 'wrong' way around for the knee and shoulder tasks
    result.minimum = result.start - _maxAngle;
    result.maximum = result.start - _minAngle;
    result.range = fabs(result.maximum - result.minimum);
    
    stepResult.results = [self.addedResults arrayByAddingObject:result] ? : @[result];
    
    return stepResult;
}

@end
