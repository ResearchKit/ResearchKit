/*
 Copyright (c) 2015, Shazino SAS. All rights reserved.
 
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


#import "ORKHolePegTestPegView.h"


static const UIEdgeInsets _ORKFlowerMargins = (UIEdgeInsets){12,12,12,12};
static const CGSize ORKFlowerBezierPathSize = (CGSize){90,90};
static UIBezierPath *ORKFlowerBezierPath() {
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(58.8, 45)];
    [bezierPath addCurveToPoint: CGPointMake(51.9, 33.2) controlPoint1: CGPointMake(107.8, 41.8) controlPoint2: CGPointMake(79.3, -7.2)];
    [bezierPath addCurveToPoint: CGPointMake(38.1, 33.2) controlPoint1: CGPointMake(73.6, -10.4) controlPoint2: CGPointMake(16.5, -10.4)];
    [bezierPath addCurveToPoint: CGPointMake(31.2, 45) controlPoint1: CGPointMake(10.8, -7.2) controlPoint2: CGPointMake(-17.8, 41.8)];
    [bezierPath addCurveToPoint: CGPointMake(38.1, 56.8) controlPoint1: CGPointMake(-17.8, 48.2) controlPoint2: CGPointMake(10.7, 97.2)];
    [bezierPath addCurveToPoint: CGPointMake(51.9, 56.8) controlPoint1: CGPointMake(16.4, 100.4) controlPoint2: CGPointMake(73.5, 100.4)];
    [bezierPath addCurveToPoint: CGPointMake(58.8, 45) controlPoint1: CGPointMake(79.2, 97.2) controlPoint2: CGPointMake(107.8, 48.2)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(45, 53.1)];
    [bezierPath addCurveToPoint: CGPointMake(36.7, 45) controlPoint1: CGPointMake(40.4, 53.1) controlPoint2: CGPointMake(36.7, 49.5)];
    [bezierPath addCurveToPoint: CGPointMake(45, 36.9) controlPoint1: CGPointMake(36.7, 40.5) controlPoint2: CGPointMake(40.4, 36.9)];
    [bezierPath addCurveToPoint: CGPointMake(53.3, 45) controlPoint1: CGPointMake(49.6, 36.9) controlPoint2: CGPointMake(53.3, 40.5)];
    [bezierPath addCurveToPoint: CGPointMake(45, 53.1) controlPoint1: CGPointMake(53.3, 49.5) controlPoint2: CGPointMake(49.6, 53.1)];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    return bezierPath;
}


@implementation ORKHolePegTestPegView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
