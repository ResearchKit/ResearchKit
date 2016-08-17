/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 Copyright (c) 2015, Bruce Duncan.

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


#import "ORKScaleSlider.h"

#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleRangeImageView.h"
#import "ORKScaleSliderView.h"

#import "ORKAnswerFormat_Internal.h"

#import "ORKAccessibility.h"
#import "ORKSkin.h"

@interface ORKScaleSlider ()

@property (nonatomic, strong, nullable) CAGradientLayer *gradientLayer;

@end

@implementation ORKScaleSlider {
    CFAbsoluteTime _axLastOutputTime;
    BOOL _thumbImageNeedsTransformUpdate;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTouched:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTouched:)];
        [self addGestureRecognizer:panGesture];
        
        self.minimumTrackTintColor = [UIColor clearColor];
        self.maximumTrackTintColor = [UIColor clearColor];
        
        self.gradientLayer = [CAGradientLayer layer];
        
        _numberOfSteps = 2;
        
        self.showThumb = NO;
        
        _axLastOutputTime = 0;
        _thumbImageNeedsTransformUpdate = NO;
    }
    return self;
}

- (void)setShowThumb:(BOOL)showThumb {
    _showThumb = showThumb;
    [self setNeedsLayout];
}

- (void)setVertical:(BOOL)vertical {
    if (vertical != _vertical) {
        _vertical = vertical;
        self.transform = _vertical ? CGAffineTransformMakeRotation(-M_PI_2) : CGAffineTransformIdentity;
        _thumbImageNeedsTransformUpdate = YES;
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setGradientColors:(nullable NSArray<UIColor *> *)gradientColors {
    _gradientColors = [gradientColors copy];
    if (gradientColors) {
        NSMutableArray *cgGolors = [[NSMutableArray alloc] init];
        for (UIColor *uiColor in gradientColors) {
            [cgGolors addObject:(id)uiColor.CGColor];
        }
        _gradientLayer.colors = cgGolors;
        [self.layer insertSublayer:_gradientLayer atIndex:0];
    } else {
        [_gradientLayer removeFromSuperlayer];
    }
}

- (void)setGradientLocations:(nullable NSArray<NSNumber *> *)gradientLocations {
    _gradientLocations = [gradientLocations copy];
    _gradientLayer.locations = gradientLocations;
}

// Error prone: needs to be replaced by a custom thumb asset
// Details here: https://github.com/ResearchKit/ResearchKit/pull/33#discussion_r28804792
// Tracked here: https://github.com/ResearchKit/ResearchKit/issues/67
- (UIView *)thumbImageSubview {
    UIView *thumbImageSubview = nil;
    CGRect bounds = self.bounds;
    CGRect trackRect = [self trackRectForBounds:bounds];
    CGRect thumbRect = [self thumbRectForBounds:bounds trackRect:trackRect value:self.value];
    for (UIView *subview in self.subviews) {
        if (CGRectEqualToRect(thumbRect, subview.frame)) {
            thumbImageSubview = subview;
            break;
        }
    }
    return thumbImageSubview;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_thumbImageNeedsTransformUpdate) {
        _thumbImageNeedsTransformUpdate = NO;
        [self thumbImageSubview].transform = _vertical ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformIdentity;
    }
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    if (_vertical) {
        CGFloat verticalScaleHeight = ORKGetMetricForWindow(ORKScreenMetricVerticalScaleHeight, self.window);
        intrinsicContentSize = (CGSize){.width = verticalScaleHeight, .height = verticalScaleHeight};
    }
    return intrinsicContentSize;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    if (_vertical) {
        
        const CGFloat desiredSliderWidth = 44.0;
        
        if (_textChoices) {
            if (point.y > (self.bounds.size.width - desiredSliderWidth) / 2) {
                pointInside = [super pointInside:point withEvent:event];
            }
        } else {
            // In vertical mode, we need to ignore the touch area for the needed extra width
            const CGFloat actualWidth = self.bounds.size.width;
            const CGFloat centerX = actualWidth / 2;
            if (fabs(point.y - centerX) < desiredSliderWidth / 2) {
                pointInside = [super pointInside:point withEvent:event];
            }
        }
    } else {
        pointInside = [super pointInside:point withEvent:event];
    }
    return pointInside;
}

- (void)sliderTouched:(UIGestureRecognizer *)gesture {
    self.showThumb = YES;
    
    CGPoint touchPoint = [gesture locationInView:self];
    [self updateValueForTouchAtPoint:touchPoint];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self _announceNewValue];
}

- (void)updateValueForTouchAtPoint:(CGPoint)touchPoint {
    // Ignore negative (out of bounds) positions
    if (touchPoint.x < 0) {
        touchPoint.x = 0;
    }
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGFloat position = (touchPoint.x - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect);
    
    CGFloat newValue = position * (self.maximumValue - self.minimumValue) + self.minimumValue;
    if (_numberOfSteps > 0) {
        CGFloat stepSize = 1.0 / _numberOfSteps;
        NSUInteger steps = round(position / stepSize);
        
        newValue = stepSize*steps * (self.maximumValue - self.minimumValue) + self.minimumValue;
    }
    [self setValue:newValue animated:YES];
}

static CGFloat LineWidth = 1.0;
- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    CGRect trackRect = [self trackRectForBounds:bounds];
    CGFloat centerY = bounds.size.height / 2.0;
    
    [[UIColor blackColor] set];
    
    if (_numberOfSteps > 0) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:LineWidth];
        
        for (int discreteOffset = 0; discreteOffset <= _numberOfSteps; ++discreteOffset) {
            CGFloat x = trackRect.origin.x + (trackRect.size.width - LineWidth) * discreteOffset / _numberOfSteps;
            x += LineWidth / 2; // Draw in center of line (center of pixel on 1x devices)
            [path moveToPoint:CGPointMake(x, centerY - 3.5)];
            [path addLineToPoint:CGPointMake(x, centerY + 3.5)];
        }
        [path stroke];
    }
    [[UIBezierPath bezierPathWithRect:trackRect] fill];
}

static const CGFloat Padding = 2.0;
- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGFloat centerY = (bounds.size.height / 2.0) - (LineWidth / 2.0);
    CGRect rect = CGRectMake(bounds.origin.x + Padding, centerY, bounds.size.width - 2 * Padding, 1.0);
    return rect;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)trackRect value:(float)value {
    CGRect rect = [super thumbRectForBounds:bounds trackRect:trackRect value:value];
    
    // VO needs the thumb to be visible, so we don't hide it if VO is running.
    if (_showThumb == NO && !UIAccessibilityIsVoiceOverRunning()) {
        rect.origin.x = -1000;
        return rect;
    }
    
    CGFloat centerX = (value - self.minimumValue) / (self.maximumValue - self.minimumValue) * trackRect.size.width + trackRect.origin.x;
    rect.origin.x = centerX - rect.size.width / 2.0;
    
    return rect;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (_gradientColors) {
        const CGFloat maxGradientHeight = 5;
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        CGFloat gradientHeight = MIN(maxGradientHeight, CGRectGetMinY(trackRect) - CGRectGetMinY(self.bounds));
        
        if (_vertical) {
            _gradientLayer.frame = CGRectMake(CGRectGetMinX(trackRect),
                                              CGRectGetMidY(self.bounds) + 2 * gradientHeight,
                                              CGRectGetWidth(trackRect),
                                              gradientHeight);
        } else {
            _gradientLayer.frame = CGRectMake(CGRectGetMinX(trackRect),
                                              CGRectGetMinY(self.bounds),
                                              CGRectGetWidth(trackRect),
                                              gradientHeight);
        }
       
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (void)accessibilityIncrement {
    [self axBumpValue:YES];
}

- (void)accessibilityDecrement {
    [self axBumpValue:NO];
}

- (NSString *)accessibilityLabel {
    ORKScaleSliderView *sliderView = (ORKScaleSliderView *)[self ork_superviewOfType:[ORKScaleSliderView class]];
    NSString *minimumValue = [self _axFormattedValue:self.minimumValue];
    NSString *maximumValue = [self _axFormattedValue:self.maximumValue];
    
    // Include the range description labels if they are set.
    if (sliderView.leftRangeDescriptionLabel.text.length > 0 && sliderView.rightRangeDescriptionLabel.text.length > 0) {
        minimumValue = [minimumValue stringByAppendingFormat:@", %@, ", sliderView.leftRangeDescriptionLabel.text];
        maximumValue = [maximumValue stringByAppendingFormat:@", %@, ", sliderView.rightRangeDescriptionLabel.text];
    }
    
    // Include the range image accessibilty hints if they are set.
    if (sliderView.leftRangeImageView.image.accessibilityHint.length > 0) {
        minimumValue = [minimumValue stringByAppendingString:sliderView.leftRangeImageView.image.accessibilityHint];
    }
    if (sliderView.rightRangeImageView.image.accessibilityHint.length > 0) {
        maximumValue = [maximumValue stringByAppendingString:sliderView.rightRangeImageView.image.accessibilityHint];
    }
    
    
    return [NSString stringWithFormat:ORKLocalizedString(@"AX_SLIDER_LABEL", nil), minimumValue, maximumValue];
}

- (NSString *)accessibilityValue {
    // If thumb is hidden it means that the slider hasn't been touched yet. That is, there's currently
    // no value (nor a default value), hence we shouldn't return one to VO.
    if (!self.showThumb) {
        return nil;
    } else if (self.textChoices) {
        ORKTextChoice *textChoice = self.textChoices[(NSInteger)self.value - 1];
        return textChoice.text;
    }
    return [self _axFormattedValue:self.value];
}

- (CGRect)accessibilityFrame {
    UIView *containingCell = [self ork_superviewOfType:[UITableViewCell class]];
    
    // Let the accessibilityFrame be equal to that of the containing cell so it's easier for VO users to touch.
    if ([self isDescendantOfView:containingCell]) {
        return UIAccessibilityConvertFrameToScreenCoordinates(containingCell.bounds, containingCell);
    }
    return CGRectZero;
}

#pragma mark Accessibility Helpers

- (NSString *)_axFormattedValue:(CGFloat)value {
    if (_numberOfSteps == 0) {
        return ORKAccessibilityFormatContinuousScaleSliderValue(value, self);
    } else {
        return ORKAccessibilityFormatScaleSliderValue(value, self);
    }
}

- (void)axBumpValue:(BOOL)increment {
    self.showThumb = YES;
    
    // If there's no fixed number of steps, we rely on the default implementation.
    if (_numberOfSteps == 0) {
        (increment ? [super accessibilityIncrement] : [super accessibilityDecrement]);
        return;
    }
    
    // If there is a fixed number of steps, we must accommodate that, and don't allow VO users to set invalid values.
    CGFloat stepSize = (self.maximumValue - self.minimumValue) / _numberOfSteps;
    CGFloat newValue = self.value + (increment ? stepSize : -stepSize);
    self.value = newValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

static const NSTimeInterval TimeoutSpeakThreshold = 1.0;
- (void)_announceNewValue {
    if ( (CFAbsoluteTimeGetCurrent() - _axLastOutputTime) > TimeoutSpeakThreshold ) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.accessibilityValue);
        _axLastOutputTime = CFAbsoluteTimeGetCurrent();
    }
}

@end
