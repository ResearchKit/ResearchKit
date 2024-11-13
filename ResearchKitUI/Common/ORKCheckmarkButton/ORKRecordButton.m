/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKRecordButton.h"
#import "ORKHelpers_Internal.h"

static NSString * ORKRecordButtonLabelForType(ORKRecordButtonType type)
{
    switch (type)
    {
        case ORKRecordButtonTypePlay:
            return ORKLocalizedString(@"PLAY", nil);
            
        case ORKRecordButtonTypeStop:
            return ORKLocalizedString(@"STOP", nil);
            
        case ORKRecordButtonTypeRecord:
            return ORKLocalizedString(@"RECORD", nil);
    }
}

@interface ORKRecordButtonInternalControl : UIControl

@property (nonatomic, readonly) ORKRecordButtonType buttonType;

- (void)setButtonType:(ORKRecordButtonType)type;

- (void)setButtonType:(ORKRecordButtonType)type animated:(BOOL)animated;

@end

@implementation ORKRecordButtonInternalControl
{
    ORKRecordButtonState _state;
    CAShapeLayer *_ringLayer;
    CAShapeLayer *_shapeLayer;
    CGPathRef _ringPath;
    CGPathRef _recordPath;
    CGPathRef _playPath;
    CGPathRef _stopPath;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _buttonType = ORKRecordButtonTypeRecord;
        _state = ORKRecordButtonStateEnabled;
        
    }
    return self;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return ORKRecordButtonLabelForType(_buttonType);
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}

- (void)setButtonType:(ORKRecordButtonType)type
{
    [self setButtonType:type animated:NO];
}

- (void)setButtonType:(ORKRecordButtonType)type animated:(BOOL)animated
{
    CGPathRef path = [self pathForType:type];
    
    if (animated)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = (__bridge id _Nullable)(_shapeLayer.path);
        animation.toValue = (__bridge id _Nullable)(path);
        animation.duration = 0.2;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [_shapeLayer addAnimation:animation forKey:@"animatePath"];
    }
    
    _buttonType = type;
    _shapeLayer.path = path;
}

- (void)setButtonState:(ORKRecordButtonState)state
{
    _state = state;
    
    self.userInteractionEnabled = state == ORKRecordButtonStateEnabled;
    
    [self setAppearanceForState:state];
}

- (UIColor *)enabledColor
{
    return [UIColor systemRedColor];
}

- (UIColor *)disabledColor
{
    return [UIColor systemGrayColor];
}

- (UIColor *)appearanceColorForState:(ORKRecordButtonState)state
{
    return state == ORKRecordButtonStateDisabled ? [self disabledColor] : [self enabledColor];
}

- (void)setAppearanceForState:(ORKRecordButtonState)state
{
    UIColor *color = [self appearanceColorForState:state];
    
    _ringLayer.strokeColor = color.CGColor;
    _shapeLayer.fillColor = color.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [_ringLayer removeFromSuperlayer];
    _ringLayer = nil;
    [_shapeLayer removeFromSuperlayer];
    _shapeLayer = nil;
    
    [self setupRingLayer];
    [self setupShapeLayer];
    
    _ringLayer.position = [self.superview convertPoint:self.center toView:self];
    _shapeLayer.position = [self.superview convertPoint:self.center toView:self];
}

- (void)setupRingLayer
{
    _ringLayer = [CAShapeLayer layer];
    _ringLayer.path = [self ringPath];
    _ringLayer.fillColor = [[UIColor clearColor] CGColor];
    _ringLayer.strokeColor = [[self appearanceColorForState:_state] CGColor];
    _ringLayer.lineWidth = 2.0;
    [self.layer addSublayer:_ringLayer];
}

- (void)setupShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    [self setButtonType:_buttonType];
    _shapeLayer.fillColor = [[self appearanceColorForState:_state] CGColor];
    [self.layer addSublayer:_shapeLayer];
}

- (CGFloat)minimumSizeMetric
{
    return MIN(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (CGPathRef)ringPath
{
    _ringPath = [self newCirclePathWithRadius:[self minimumSizeMetric]/2];
    return _ringPath;
}

- (CGPathRef)recordPath
{
    CGFloat minimumSizeMetric = [self minimumSizeMetric]/2;
    _recordPath = [self newCirclePathWithRadius:0.9 * minimumSizeMetric];
    return _recordPath;
}

- (CGPathRef)playPath
{
    CGFloat minimumSizeMetric = [self minimumSizeMetric]/2;
    _playPath = [self newTrianglePathWithSize:0.8 * minimumSizeMetric radius:1];
    return _playPath;
}

- (CGPathRef)stopPath
{
    CGFloat minimumSizeMetric = [self minimumSizeMetric]/2;
    _stopPath = [self newSquirclePathWithLength:0.8 * minimumSizeMetric cornerRadius:3];
    return _stopPath;
}

- (CGPathRef)pathForType:(ORKRecordButtonType)type
{
    switch (type)
    {
        case ORKRecordButtonTypePlay:
            return [self playPath];
            
        case ORKRecordButtonTypeStop:
            return [self stopPath];
            
        case ORKRecordButtonTypeRecord:
            return [self recordPath];
    }
}

- (CGPathRef)newCirclePathWithRadius:(CGFloat)radius
{
    CGPoint A = CGPointMake(-radius, 0);
    CGPoint B = CGPointMake(-radius, -radius);
    CGPoint C = CGPointMake(radius, -radius);
    CGPoint D = CGPointMake(radius, radius);
    CGPoint E = CGPointMake(-radius, radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x,B.y, radius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, radius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, radius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, E.x, E.y, radius);
    CGPathAddArcToPoint(path, NULL, E.x, E.y, A.x, A.y, radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)newSquirclePathWithLength:(CGFloat)length cornerRadius:(CGFloat)cornerRadius
{
    CGFloat minX = -0.5 * length;
    CGFloat maxX =  0.5 * length;
    CGFloat minY = -0.5 * length;
    CGFloat midY =  0.0;
    CGFloat maxY =  0.5 * length;
    
    CGPoint A = CGPointMake(minX, midY);
    CGPoint B = CGPointMake(minX, minY);
    CGPoint C = CGPointMake(maxX, minY);
    CGPoint D = CGPointMake(maxX, maxY);
    CGPoint E = CGPointMake(minX, maxY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x,B.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, E.x, E.y, cornerRadius);
    CGPathAddArcToPoint(path, NULL, E.x, E.y, A.x, A.y, cornerRadius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGPathRef)newTrianglePathWithSize:(CGFloat)size radius:(CGFloat)radius
{
    CGFloat translation = 0.1 * size;
    CGFloat minX = -(size / 2) + translation;
    CGFloat maxX =  (size / 2) + translation;
    CGFloat minY = -(size / 2);
    CGFloat midY =  0.0;
    CGFloat maxY =  (size / 2);
    
    CGPoint A = CGPointMake(minX, midY);
    CGPoint B = CGPointMake(minX, minY);
    CGPoint C = CGPointMake(maxX, midY);
    CGPoint D = CGPointMake(minX, maxY);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, A.x, A.y);
    CGPathAddArcToPoint(path, NULL, A.x, A.y, B.x, B.y, radius);
    CGPathAddArcToPoint(path, NULL, B.x, B.y, C.x, C.y, radius);
    CGPathAddArcToPoint(path, NULL, C.x, C.y, D.x, D.y, radius);
    CGPathAddArcToPoint(path, NULL, D.x, D.y, A.x, A.y, radius);
    CGPathCloseSubpath(path);

    return path;
}

@end

@implementation ORKRecordButton
{
    ORKRecordButtonType _currentType;
    UIStackView *_stackView;
    ORKRecordButtonInternalControl *_recordControl;
    UILabel *_textLabel;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _buttonType = ORKRecordButtonTypeRecord;
        [self setupStackView];
        [self setupControl];
        [self setupTextLabel];
    }
    return self;
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSArray *)accessibilityElements {
    return @[_recordControl];
}

- (void)buttonPressed:(id)sender
{
    if ([self.delegate conformsToProtocol:@protocol(ORKRecordButtonDelegate)] && [self.delegate respondsToSelector:@selector(buttonPressed:)])
    {
        [self.delegate buttonPressed:self];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    
    _textLabel.font = [self bodyTextFont];
}

- (void)setupStackView
{
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.spacing = 15.0;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.backgroundColor = [UIColor clearColor];
    [self addSubview:_stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (void)setupControl
{
    _recordControl = [[ORKRecordButtonInternalControl alloc] init];
    _recordControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_recordControl];
    
    [NSLayoutConstraint activateConstraints:@[
        [_recordControl.heightAnchor constraintEqualToConstant:57],
        [_recordControl.widthAnchor constraintEqualToConstant:57]
    ]];
    
    [_recordControl addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTextLabel
{
    _textLabel = [[UILabel alloc] init];
    _textLabel.text = [self localizedTitleForType:_buttonType];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [self bodyTextFont];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_stackView addArrangedSubview:_textLabel];
}

- (UIFont *)bodyTextFont
{
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithDescriptor:descriptor size:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]];
}

- (NSString *)localizedTitleForType:(ORKRecordButtonType)type
{
    return ORKRecordButtonLabelForType(type);
}

- (void)setButtonType:(ORKRecordButtonType)type
{
    [self setButtonType:type animated:NO];
}

- (void)setButtonType:(ORKRecordButtonType)type animated:(BOOL)animated
{
    [_recordControl setButtonType:type animated:animated];
    _buttonType = type;
    _textLabel.text = [self localizedTitleForType:type];
}

- (void)setButtonState:(ORKRecordButtonState)state
{
    [_recordControl setButtonState:state];
}

@end
