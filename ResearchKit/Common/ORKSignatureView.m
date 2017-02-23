/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2016, Sam Falconer.
 
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


#import "ORKSignatureView.h"

#import "ORKSelectionTitleLabel.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#import <UIKit/UIGestureRecognizerSubclass.h>


@protocol ORKSignatureGestureRecognizerDelegate <NSObject>

- (void)gestureTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)gestureTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)gestureTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end


@interface ORKSignatureGestureRecognizer : UIGestureRecognizer

@property (nonatomic, weak) id<ORKSignatureGestureRecognizerDelegate> eventDelegate;

@end


static const CGFloat TopToSigningLineRatio = 0.7;


@implementation ORKSignatureGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count > 1 || self.numberOfTouches > 1) {
        for (UITouch *touch in touches) {
            [self ignoreTouch:touch forEvent:event];
        }
    } else {
        self.state = UIGestureRecognizerStateBegan;
        [self.eventDelegate gestureTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.eventDelegate gestureTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
    [self.eventDelegate gestureTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateFailed;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Prioritize over scrollView's pan gesture recognizer and swipe gesture recognizer
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
        || [otherGestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end


static const CGFloat PointMinDistance = 5;
static const CGFloat PointMinDistanceSquared = PointMinDistance * PointMinDistance;
static const CGFloat DefaultLineWidth = 1;
static const CGFloat DefaultLineWidthVariation = 3;
static const CGFloat MaxPressureForStrokeVelocity = 9;
static const CGFloat LineWidthStepValue = 0.25f;

@interface ORKSignatureView () <ORKSignatureGestureRecognizerDelegate> {
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
    // Pressure scale based on if using force or speed of stroke.
    CGFloat minPressure;
    CGFloat maxPressure;
    // Time used only to calculate speed when force isn't available on the device.
    NSTimeInterval previousTouchTime;
}

@property (nonatomic, strong) UIBezierPath *currentPath;
@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSArray *backgroundLines;

@end


@implementation ORKSignatureView {
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_widthConstraint;
}

+ (void)initialize {
    if (self == [ORKSignatureView class]) {
        if ([[ORKSignatureView appearance] backgroundColor] == nil) {
            [[ORKSignatureView appearance] setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
        }
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineWidth = DefaultLineWidth;
        _lineWidthVariation = DefaultLineWidthVariation;
        [self makeSignatureGestureRecognizer];
        [self setUpConstraints];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self updateConstraintConstantsForWindow:newWindow];
}

- (void)updateConstraintConstantsForWindow:(UIWindow *)window {
    _heightConstraint.constant = ORKGetMetricForWindow(ORKScreenMetricSignatureViewHeight, window);
    _widthConstraint.constant = ORKWidthForSignatureView(window);
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:0.0]; // constant set in updateConstraintConstantsForWindow:
    [constraints addObject:_heightConstraint];

    _widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                   multiplier:1.0
                                                     constant:0.0]; // constant set in updateConstraintConstantsForWindow:
    [constraints addObject:_widthConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [self updateConstraintConstantsForWindow:self.window];
}

- (void)updateConstraints {
    [self updateConstraintConstantsForWindow:self.window];
    [super updateConstraints];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (UIBezierPath *)pathWithRoundedStyle {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = self.lineWidth;
    path.lineJoinStyle = kCGLineJoinRound;
    
    return path;
}

- (void)makeSignatureGestureRecognizer {
    if (nil == _signatureGestureRecognizer) {
        _signatureGestureRecognizer = [ORKSignatureGestureRecognizer new];
        ((ORKSignatureGestureRecognizer *)_signatureGestureRecognizer).eventDelegate = self;
        [self addGestureRecognizer:_signatureGestureRecognizer];
    }
}

- (UIColor *)lineColor {
    if (_lineColor == nil) {
        _lineColor = ORKColor(ORKSignatureColorKey);
    }
    return _lineColor;
}

- (NSMutableArray *)pathArray {
    if (_pathArray == nil) {
        _pathArray = [NSMutableArray new];
    }
    return _pathArray;
}

- (CGPoint)placeholderPoint {
    CGFloat height = self.bounds.size.height;
    CGFloat x1 = 0;
    CGFloat y1 = height * TopToSigningLineRatio;
    UIFont *font = [ORKSelectionTitleLabel defaultFont];
    return (CGPoint){x1, y1 - 5 - font.pointSize + font.descender};
}

- (NSArray *)backgroundLines {
    if (_backgroundLines == nil) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        {
            CGFloat x1 = 0;
            CGFloat x2 = width;
            
            CGFloat y1 = height * TopToSigningLineRatio;
            CGFloat y2 = height * TopToSigningLineRatio;
            
            [path moveToPoint:CGPointMake(x1, y1)];
            [path addLineToPoint:CGPointMake(x2, y2)];
        }
        
        _backgroundLines = @[path];
    }
    return _backgroundLines;
}

#pragma mark Touch Event Handlers

- (BOOL)isForceTouchAvailable {
    static BOOL isAvailable;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        isAvailable = NO;
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && 
             self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            isAvailable = YES;
        }
    });
    
    return isAvailable;
}

- (BOOL)isTouchTypeStylus:(UITouch*)touch {
    BOOL isStylus = NO;
    
    if ([touch respondsToSelector:@selector(type)] && touch.type == UITouchTypeStylus) {
        isStylus = YES;
    }
    
    return isStylus;
}

- (void)gestureTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    self.currentPath = [self pathWithRoundedStyle];
    
    // Trigger full redraw - whether there's a path has changed
    [self setNeedsDisplay];
    
    previousPoint1 = [touch previousLocationInView:self];
    previousPoint2 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    if ([self isForceTouchAvailable] || [self isTouchTypeStylus:touch]) {
        // This is a scale based on true force on the screen.
        minPressure = 0.f;
        maxPressure = [touch maximumPossibleForce] / 2.f;
    }
    else {
        // This is a scale based on the speed of the stroke
        // (scaled down logarithmically).
        minPressure = 0.f;
        maxPressure = MaxPressureForStrokeVelocity;
        previousTouchTime = touch.timestamp;
    }
    
    [self.currentPath moveToPoint:currentPoint];
    [self.currentPath addArcWithCenter:currentPoint radius:0.1 startAngle:0.0 endAngle:2.0 * M_PI clockwise:YES];
    [self gestureTouchesMoved:touches withEvent:event];
}

static CGPoint mmid_Point(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)gestureTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    //check if the point is farther than min dist from previous
    CGFloat dx = point.x - currentPoint.x;
    CGFloat dy = point.y - currentPoint.y;
    
    CGFloat distanceSquared = (dx * dx + dy * dy);
    
    if (distanceSquared < PointMinDistanceSquared) {
        return;
    }
    
    // Default to the minimum. Will be assigned a real
    // value on all devices.
    CGFloat pressure = minPressure;
    
    if ([self isForceTouchAvailable] || [self isTouchTypeStylus:touch]) {
        // If the device supports Force Touch, or is using a stylus, use it.
        pressure = [touch force];
    }
    else {
        // If not, use a heuristic based on the speed of
        // the stroke. Scale this speed logarithmically to
        // require very slow touches to max out the line width.
        
        // This value can become negative because of how it is
        // inverted. It will be clamped right below.
        pressure = maxPressure - logf((sqrt(distanceSquared) /
                                            MAX(0.0001, event.timestamp - previousTouchTime)));
        previousTouchTime = event.timestamp;
    }
    
    // Clamp the pressure value to between the allowed min and max.
    pressure = MAX(minPressure, pressure);
    pressure = MIN(maxPressure, pressure);
    
    CGFloat previousLineWidth = self.currentPath.lineWidth;
    CGFloat proposedLineWidth = ((pressure - minPressure) *
                                 self.lineWidthVariation /
                                 (maxPressure - minPressure))
                                + self.lineWidth;
    
    // Only step the line width up and down by a set value.
    // This prevents the line looking jagged, and adding excessive
    // separate line segments.
    if (ABS(previousLineWidth - proposedLineWidth) >= LineWidthStepValue) {
        
        CGFloat lineWidth = previousLineWidth;
        
        if (proposedLineWidth > previousLineWidth) {
            lineWidth = previousLineWidth + LineWidthStepValue;
        }
        else if (proposedLineWidth < previousLineWidth) {
            lineWidth = previousLineWidth - LineWidthStepValue;
        }
        
        [self commitCurrentPath];
        
        self.currentPath = [self pathWithRoundedStyle];
        self.currentPath.lineWidth = lineWidth;
        
        CGPoint previousMid2 = mmid_Point(currentPoint, previousPoint1);
        [self.currentPath moveToPoint:previousMid2];
    }
    
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    CGPoint mid1 = mmid_Point(previousPoint1, previousPoint2);
    CGPoint mid2 = mmid_Point(currentPoint, previousPoint1);
    
    UIBezierPath *subPath = [UIBezierPath bezierPath];
    [subPath moveToPoint:mid1];
    [subPath addQuadCurveToPoint:mid2 controlPoint:previousPoint1];
    CGRect bounds = CGPathGetBoundingBox(subPath.CGPath);
    
    [self.currentPath addQuadCurveToPoint:mid2 controlPoint:previousPoint1];
    
    CGRect drawBox = bounds;
    drawBox.origin.x -= self.currentPath.lineWidth * 2.0;
    drawBox.origin.y -= self.currentPath.lineWidth * 2.0;
    drawBox.size.width += self.currentPath.lineWidth * 4.0;
    drawBox.size.height += self.currentPath.lineWidth * 4.0;
    
    [self setNeedsDisplayInRect:drawBox];
}

- (void)gestureTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self commitCurrentPath];
}

- (void)commitCurrentPath {
    CGRect rect = self.currentPath.bounds;
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return;
    }
    
    [self.pathArray addObject:self.currentPath];
    
    [self.delegate signatureViewDidEditImage:self];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    
    for (UIBezierPath *path in self.backgroundLines) {
        [[[UIColor blackColor] colorWithAlphaComponent:0.2] setStroke];
        [path stroke];
    }
    
    if (![self signatureExists] && (!self.currentPath || [self.currentPath isEmpty])) {
        [ORKLocalizedString(@"CONSENT_SIGNATURE_PLACEHOLDER", nil) drawAtPoint:[self placeholderPoint]
                                           withAttributes:@{ NSFontAttributeName: [ORKSelectionTitleLabel defaultFont],
                                                             NSForegroundColorAttributeName: [[UIColor blackColor] colorWithAlphaComponent:0.2]}];
    }
    
    for (UIBezierPath *path in self.pathArray) {
        [self.lineColor setStroke];
        [path stroke];
    }
    
    [self.lineColor setStroke];
    [self.currentPath stroke];
}

- (NSArray <UIBezierPath *> *)signaturePath {
    return [self.pathArray copy];
}

- (void)setSignaturePath:(NSArray<UIBezierPath *> *)signaturePath {
    if (signaturePath) {
        _pathArray = [signaturePath mutableCopy];
        [self setNeedsDisplay];
    }
}

- (UIImage *)signatureImage {
    CGSize imageContextSize;
    imageContextSize = (self.bounds.size.width == 0 || self.bounds.size.height == 0) ? CGSizeMake(200, 200) :
                        self.bounds.size;
    UIGraphicsBeginImageContext(imageContextSize);

    for (UIBezierPath *path in self.pathArray) {
        [self.lineColor setStroke];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)signatureExists {
    return self.pathArray.count > 0;
}

- (void)clear {
    if (self.pathArray.count > 0) {
        if (self.currentPath != nil) {
            self.currentPath = [self pathWithRoundedStyle];
        }
        
        [self.pathArray removeAllObjects];
        [self setNeedsDisplayInRect:self.bounds];
    }
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return ORKLocalizedString(@"AX_SIGNVIEW_LABEL", nil);
}

- (NSString *)accessibilityValue {
    return (self.signatureExists ? ORKLocalizedString(@"AX_SIGNVIEW_SIGNED", nil) : ORKLocalizedString(@"AX_SIGNVIEW_UNSIGNED", nil));
}

- (NSString *)accessibilityHint {
    return ORKLocalizedString(@"AX_SIGNVIEW_HINT", nil);
}

- (UIAccessibilityTraits)accessibilityTraits {
    return [super accessibilityTraits] | UIAccessibilityTraitAllowsDirectInteraction;
}

@end
