//
//  ORKVASSlider.m
//  ResearchKit
//
//  Created by Janusz Bień on 16.03.2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKVASSlider.h"


#import "ORKScaleSlider.h"
#import "ORKAccessibility.h"
#import "ORKDefines_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKSkin.h"
#import "ORKVASSliderView.h"
#import "ORKScaleRangeDescriptionLabel.h"
#import "ORKScaleRangeImageView.h"


@implementation ORKVASSlider {
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
        _numberOfSteps = 100;
        self.showThumb = NO;
        _axLastOutputTime = 0;
        _thumbImageNeedsTransformUpdate = NO;
        
        [self setThumbImage:[self thumbImage] forState:UIControlStateNormal];
    }
    return self;
}

- (void)setShowThumb:(BOOL)showThumb {
    _showThumb = showThumb;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_thumbImageNeedsTransformUpdate) {
        _thumbImageNeedsTransformUpdate = NO;
        //[self thumbImageSubview].transform = CGAffineTransformIdentity;
    }
}

- (void) setMarkerStyle:(ORKVASMarkerStyle)markerStyle {
    _markerStyle = markerStyle;
    [self setThumbImage:[self thumbImage] forState:UIControlStateNormal];
}

- (CGSize)intrinsicContentSize {
    CGSize intrinsicContentSize = [super intrinsicContentSize];
    return intrinsicContentSize;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    pointInside = [super pointInside:point withEvent:event];
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
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth:LineWidth];
        
    for (int discreteOffset = 0; discreteOffset <= 1; ++discreteOffset) {
        CGFloat x = trackRect.origin.x + (trackRect.size.width - LineWidth) * discreteOffset;
        x += LineWidth / 2; // Draw in center of line (center of pixel on 1x devices)
        [path moveToPoint:CGPointMake(x, centerY - 3.5)];
        [path addLineToPoint:CGPointMake(x, centerY + 3.5)];
    }
    [path stroke];
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
    return ORKAccessibilityFormatVASSliderValue(value, self);
}

- (void)axBumpValue:(BOOL)increment {
    self.showThumb = YES;
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

#pragma mark Drawings

-(UIImage *)thumbImage {
    CGRect rect = CGRectMake(0.0f, 0.0f, 21.0f, 80.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, rect);
    UIColor *markerColor = [UIColor colorWithRed:100.0f/255.0f green:150.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
    CGContextSetStrokeColorWithColor(context, [markerColor CGColor]);
    CGContextSetFillColorWithColor(context, [markerColor CGColor]);
    CGContextSetLineWidth(context, 1.0f);
    CGContextMoveToPoint(context, 11.0f, 10.0f);
    CGContextAddLineToPoint(context, 11.0f, 70.0f);
    CGContextStrokePath(context);
    switch (_markerStyle) {
        case ORKVASMerkerStyleBoth:
            CGContextMoveToPoint(context, 0.0f, 00.0f);
            CGContextAddLineToPoint(context, 21.0f, 0.0f);
            CGContextAddLineToPoint(context, 11.0f, 20.0f);
            CGContextClosePath(context);
            CGContextFillPath(context);
        case ORKVASMerkerStyleLowerOnly:
            CGContextMoveToPoint(context, 0.0f, 80.0f);
            CGContextAddLineToPoint(context, 21.0f, 80.0f);
            CGContextAddLineToPoint(context, 11.0f, 60.0f);
            CGContextClosePath(context);
            CGContextFillPath(context);
            break;
        default:
            break;
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
