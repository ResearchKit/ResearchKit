/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKFitnessContentView.h"
#import "ORKHelpers.h"
#import <CoreMotion/CoreMotion.h>
#import "ORKSkin.h"
#import "ORKActiveStepQuantityView.h"
#import "ORKTintedImageView.h"


// #define LAYOUT_TEST 1
// #define LAYOUT_DEBUG 1

@interface ORKFitnessContentView () {
    ORKQuantityLabel *_timerLabel;
    ORKQuantityPairView *_quantityPairView;
    UIView *_imageSpacer1;
    UIView *_imageSpacer2;
    ORKTintedImageView *_imageView;
    NSLengthFormatter *_lengthFormatter;
    NSLayoutConstraint *_imageRatioConstraint;
    NSLayoutConstraint *_topConstraint;
}

@end


@implementation ORKFitnessContentView

- (ORKActiveStepQuantityView *)distanceView {
    return _quantityPairView.leftView;
}

- (ORKActiveStepQuantityView *)heartRateView {
    return _quantityPairView.rightView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _timerLabel = [ORKQuantityLabel new];
        _quantityPairView = [ORKQuantityPairView new];
        _imageSpacer1 = [UIView new];
        _imageSpacer1.translatesAutoresizingMaskIntoConstraints = NO;
        _imageSpacer2 = [UIView new];
        _imageSpacer2.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageSpacer1];
        [self addSubview:_imageSpacer2];
        [self heartRateView].image = [UIImage imageNamed:@"heart-fitness" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        [self updateLengthFormatter];
        _imageView = [ORKTintedImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.shouldApplyTint = YES;
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _quantityPairView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self updateKeylineVisible];
        
        _timerLabel.accessibilityTraits |= UIAccessibilityTraitUpdatesFrequently;
        _imageView.isAccessibilityElement = NO;
        
        self.hasHeartRate = _hasHeartRate;
        self.hasDistance = _hasDistance;
        
#if LAYOUT_TEST
        self.timeLeft = 60 * 5;
        self.hasHeartRate = YES;
        self.hasDistance = YES;
        self.distanceInMeters = 100;
        self.heartRate = @"22";
#endif
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
        _quantityPairView.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.2];
#endif
      
        [self setDistanceInMeters:0];
        [self heartRateView].title = ORKLocalizedString(@"FITNESS_HEARTRATE_TITLE", nil);

        [self addSubview:_quantityPairView];
        [self addSubview:_imageView];
        [self addSubview:_timerLabel];
        [self setUpConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
        
        [self tintColorDidChange];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateLengthFormatter {
    _lengthFormatter = [NSLengthFormatter new];
    _lengthFormatter.numberFormatter.maximumFractionDigits = 1;
    _lengthFormatter.numberFormatter.maximumSignificantDigits = 3;
}

- (void)localeDidChange:(NSNotification *)notification {
    [self updateLengthFormatter];
    [self setDistanceInMeters:_distanceInMeters];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    const CGFloat CaptionBaselineToTimerTop = ORKGetMetricForWindow(ORKScreenMetricCaptionBaselineToFitnessTimerTop, window);
    const CGFloat CaptionBaselineToStepViewTop = ORKGetMetricForWindow(ORKScreenMetricLearnMoreBaselineToStepViewTop, window);
    _topConstraint.constant = (CaptionBaselineToTimerTop - CaptionBaselineToStepViewTop);
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    NSDictionary *views = NSDictionaryOfVariableBindings(_timerLabel, _imageView, _quantityPairView, _imageSpacer1, _imageSpacer2);
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timerLabel][_imageSpacer1(>=0)][_imageView]"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    _topConstraint = [NSLayoutConstraint constraintWithItem:_timerLabel
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0];
    [constraints addObject:_topConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timerLabel
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_timerLabel
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:self attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageView
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:self attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageView][_imageSpacer2(>=0)][_quantityPairView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageSpacer1
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageSpacer2
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_imageSpacer1
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_imageSpacer2
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    NSLayoutConstraint *imageSpacerHeightConstraint = [NSLayoutConstraint constraintWithItem:_imageSpacer1
                                                                                   attribute:NSLayoutAttributeHeight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:nil
                                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                                  multiplier:1.0
                                                                                    constant:ORKScreenMetricMaxDimension];
    imageSpacerHeightConstraint.priority = UILayoutPriorityDefaultLow - 1;
    [constraints addObject:imageSpacerHeightConstraint];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_quantityPairView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    
    NSLayoutConstraint *maxWidthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeWidth 
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:ORKScreenMetricMaxDimension];
    maxWidthConstraint.priority = UILayoutPriorityRequired - 1;
    [constraints addObject:maxWidthConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [self updateConstraintConstantsForWindow:self.window];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
    
    _imageRatioConstraint.active = NO;
    
    CGSize size = image.size;
    if (size.width > 0 && size.height > 0) {
        _imageRatioConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_imageView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:size.height / size.width
                                                              constant:0.0];
        _imageRatioConstraint.active = YES;
    }
}

- (void)setHasDistance:(BOOL)hasDistance {
    _hasDistance = hasDistance;
    [self distanceView].enabled = _hasDistance;
    [self updateKeylineVisible];
}

- (void)setHasHeartRate:(BOOL)hasHeartRate {
    _hasHeartRate = hasHeartRate;
    [self heartRateView].enabled = _hasHeartRate;
    [self updateKeylineVisible];
}

- (void)setHeartRate:(NSString *)heartRate {
    _heartRate = heartRate;
    [self heartRateView].value = heartRate;
}

- (void)updateKeylineVisible {
    [_quantityPairView setKeylineHidden:!(_hasDistance && _hasHeartRate)];
}

- (void)setDistanceInMeters:(double)distanceInMeters {
    _distanceInMeters = distanceInMeters;
    double displayDistance = _distanceInMeters;
    NSString *distanceString = nil;
    NSLengthFormatterUnit unit;
    NSString *unitString = [_lengthFormatter unitStringFromMeters:displayDistance usedUnit:&unit];
    
    switch (unit) {
        case NSLengthFormatterUnitCentimeter:
        case NSLengthFormatterUnitMillimeter:
            unit = NSLengthFormatterUnitMeter;
            // Force showing 0 meters if the distance is sufficiently short to be displayed in cm or mm
            unitString = [_lengthFormatter unitStringFromValue:0 unit:NSLengthFormatterUnitMeter];
            displayDistance = 0;
            break;
        default:
            break;
    }
    
    // Use HealthKit to convert the unit, so we can use the number formatter directly.
    HKUnit *hkUnit = [HKUnit unitFromLengthFormatterUnit:unit];
    double conversionFactor = 1.0;
    if ([hkUnit isNull] && (unit == NSLengthFormatterUnitYard)) {
        hkUnit = [HKUnit footUnit];
        conversionFactor = 1.0 / 3.0;
    }
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:displayDistance];
    distanceString = [_lengthFormatter.numberFormatter stringFromNumber:@([quantity doubleValueForUnit:hkUnit]*conversionFactor)];
    
    [self distanceView].title = [NSString stringWithFormat:ORKLocalizedString(@"FITNESS_DISTANCE_TITLE_FORMAT", nil), unitString];
    [self distanceView].value = distanceString;
}

- (void)setTimeLeft:(NSTimeInterval)timeLeft {
    _timeLeft = timeLeft;
    [self updateTimerLabel];
}

- (void)updateTimerLabel {
    static NSDateComponentsFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateComponentsFormatter *formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    });
    
    NSString *labelString = [formatter stringFromTimeInterval:MAX(round(_timeLeft),0)];
    _timerLabel.text = labelString;
    _timerLabel.hidden = (labelString == nil);
}

@end
