/*
 Copyright (c) 2016, Darren Levy. All rights reserved.
 Copyright (c) 2018, David Evans, University of Birmingham. All rights reserved.
 
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


#import "ORKSideBendingRangeOfMotionStepViewController.h"

#import "ORKRangeOfMotionResult.h"
#import "ORKStepViewController_Internal.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKDeviceMotionRecorder.h"
#import "ORKActiveStepView.h"
#import "ORKProgressView.h"


#define radiansToDegrees(radians) ((radians) * 180.0 / M_PI)
#define allOrientationsForPitch(x, w, y, z) (atan2(2.0 * (x*w + y*z), 1.0 - 2.0 * (x*x + z*z)))
#define allOrientationsForRoll(x, w, y, z) (atan2(2.0 * (y*w - x*z), 1.0 - 2.0 * (y*y + z*z)))
#define allOrientationsForYaw(x, w, y, z) (asin(2.0 * (x*y - w*z)))

@interface ORKRangeOfMotionContentView : ORKActiveStepCustomView {
    NSLayoutConstraint *_topConstraint;
}

@property (nonatomic, strong, readonly) ORKProgressView *progressView;

@end


@interface ORKSideBendingRangeOfMotionStepViewController () <ORKDeviceMotionRecorderDelegate> {
    ORKRangeOfMotionContentView *_contentView;
    UITapGestureRecognizer *_gestureRecognizer;
    CMAttitude *_referenceAttitude;
    UIInterfaceOrientation _orientation;
}

@end


@implementation ORKSideBendingRangeOfMotionStepViewController

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
    
    [(currentAttitude)multiplyByInverseOfAttitude:(CMAttitude *)_referenceAttitude];
    
    double angle = [self getDeviceAngleInDegreesFromAttitude:currentAttitude];
    
    _newAngle = angle;
    
    [self calculateAndSetAngles];
}

/*
 When recording rotation in the frontal plane and the device is
 in either Portrait or Landscape mode, we need to get the attitude's yaw
 to determine the device's angle. attitude.yaw doesn't return all
 orientations, so we use the attitude's quaternion to calculate the angle.
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
        angle = radiansToDegrees(allOrientationsForYaw(x, w, y, z));
    } else {
        double x = attitude.quaternion.x;
        double w = attitude.quaternion.w;
        double y = attitude.quaternion.y;
        double z = attitude.quaternion.z;
        angle = radiansToDegrees(allOrientationsForYaw(x, w, y, z));
    }
    return angle;
}

#pragma mark - ORKActiveTaskViewController

- (ORKResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKRangeOfMotionResult *result = [[ORKRangeOfMotionResult alloc] initWithIdentifier:self.step.identifier];
    result.start = _startAngle;
    result.finish = result.start + _newAngle;
    result.minimum = result.start + _minAngle;
    result.maximum = result.start + _maxAngle;
    result.range = fabs(result.maximum - result.minimum);
    
    stepResult.results = [self.addedResults arrayByAddingObject:result] ? : @[result];
    
    return stepResult;
}

@end
