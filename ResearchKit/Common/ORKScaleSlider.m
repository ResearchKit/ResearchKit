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


#import "ORKScaleSlider.h"
#import "ORKAccessibility.h"
#import "ORKDefines_Private.h"
#import "ORKAnswerFormat_Internal.h"

@interface ORKScaleSlider ()

@end

@implementation ORKScaleSlider {
    CFAbsoluteTime _axLastOutputTime;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTouched:)];
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTouched:)];
        [self addGestureRecognizer:panGesture];
        
        self.minimumTrackTintColor = [UIColor clearColor];
        self.maximumTrackTintColor = [UIColor clearColor];
        
        _numberOfSteps = 2;
        
        self.showThumb = NO;
        
        _axLastOutputTime = 0;
    }
    return self;
}

- (void)setShowThumb:(BOOL)showThumb
{
    _showThumb = showThumb;
}

- (void)sliderTouched:(UIGestureRecognizer *)gesture
{
    self.showThumb = YES;
    
    CGPoint touchPoint = [gesture locationInView:self];
    [self updateValueForTouchAtPoint:touchPoint];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self _announceNewValue];
}

- (void)updateValueForTouchAtPoint:(CGPoint)touchPoint {
    CGRect trackRect = [self trackRectForBounds:[self bounds]];
    CGFloat position = (touchPoint.x - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect);
    
    CGFloat newValue = position * ([self maximumValue] - [self minimumValue]) + [self minimumValue];
    if (_numberOfSteps > 0) {
        CGFloat stepSize = 1.0/_numberOfSteps;
        NSUInteger steps = round(position/stepSize);
        
        newValue = stepSize*steps * ([self maximumValue] - [self minimumValue]) + [self minimumValue];
    }
    
    [self setValue:newValue animated:YES];
}

static CGFloat kLineWidth = 1.0;
- (void)drawRect:(CGRect)rect
{
    CGRect trackRect = [self trackRectForBounds:[self bounds]];
    CGFloat centerY = [self bounds].size.height / 2.0;
    
    [[UIColor blackColor] set];
    
    if (_numberOfSteps > 0) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path setLineWidth:kLineWidth];
        
        for (int discreteOffset = 0; discreteOffset <= _numberOfSteps; ++discreteOffset) {
            CGFloat x = trackRect.origin.x + (trackRect.size.width-kLineWidth)*discreteOffset/_numberOfSteps;
            x += kLineWidth/2; // Draw in center of line (center of pixel on 1x devices)
            [path moveToPoint:CGPointMake(x, centerY - 3.5)];
            [path addLineToPoint:CGPointMake(x, centerY + 3.5)];
        }
        [path stroke];
        
    }
    
    [[UIBezierPath bezierPathWithRect:trackRect] fill];
}
static CGFloat kPadding = 2.0;
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    
    CGFloat centerY = bounds.size.height / 2.0 - kLineWidth/2;
    CGRect rect = CGRectMake(bounds.origin.x + kPadding, centerY, bounds.size.width - 2 * kPadding, 1.0);
    
    return rect;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)trackRect value:(float)value {
    
    CGRect rect = [super thumbRectForBounds:bounds trackRect:trackRect value:value];
    
    // VO needs the thumb to be visible, so we don't hide it if VO is running.
    if (_showThumb == NO && !UIAccessibilityIsVoiceOverRunning()) {
        rect.origin.x = -1000;
        return rect;
    }
    
    CGFloat centerX = (value - [self minimumValue]) / ([self maximumValue] - [self minimumValue]) * trackRect.size.width + trackRect.origin.x;
    rect.origin.x = centerX - rect.size.width / 2.0;
    
    return rect;
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
    return [NSString stringWithFormat:ORKLocalizedString(@"AX_SLIDER_LABEL", nil), [self _axFormattedValue:self.minimumValue], [self _axFormattedValue:self.maximumValue]];
}

- (NSString *)accessibilityValue {
    // If thumb is hidden it means that the slider hasn't been touched yet. That is, there's currently
    // no value (nor a default value), hence we shouldn't return one to VO.
    if (!self.showThumb) {
        return nil;
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
    }
    else {
        return ORKAccessibilityFormatScaleSliderValue(value, self);
    }
}

- (void)axBumpValue:(BOOL)increment {
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

static const NSTimeInterval kTimeoutSpeakThreshold = 1.0;
- (void)_announceNewValue {
    if ( (CFAbsoluteTimeGetCurrent() - _axLastOutputTime) > kTimeoutSpeakThreshold )
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [self accessibilityValue]);
        _axLastOutputTime = CFAbsoluteTimeGetCurrent();
    }
}

@end