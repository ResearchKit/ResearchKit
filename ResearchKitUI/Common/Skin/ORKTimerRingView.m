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


#import "ORKTimerRingView.h"


static const CGFloat ORKTimerRingIconDimension = 120.0;
static const CGFloat ORKTimerRingMinimumHeight = 250.0;
static const CGFloat ORKTimerRingStrokeWidth = 12.0;


static void validateDuration(NSTimeInterval duration) {
    if (!(isfinite(duration) && duration > 0)) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"duration must be a finite positive number, got %g", duration]
                                     userInfo:nil];
    }
}


@implementation ORKTimerRingView {
    UILabel *_timerLabel;
    UIImageView *_imageView;
}

- (instancetype)initWithDuration:(NSTimeInterval)duration {
    self = [super init];
    if (self) {
        validateDuration(duration);
        _duration = duration;
        _timeLeft = duration;

        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.hidden = YES;
        [self addSubview:_imageView];

        [NSLayoutConstraint activateConstraints:@[
            [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [_imageView.heightAnchor constraintEqualToConstant:ORKTimerRingIconDimension],
            [_imageView.widthAnchor constraintEqualToConstant:ORKTimerRingIconDimension],
        ]];

        _timerLabel = [[UILabel alloc] init];
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        _timerLabel.font = [self labelFont];
        _timerLabel.adjustsFontForContentSizeCategory = YES;
        _timerLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        [self addSubview:_timerLabel];
        [self tintColorDidChange];
        [self updateTimerLabel];

        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
    _imageView.hidden = (image == nil);
}

- (UIImage *)image {
    return _imageView.image;
}

- (void)tintColorDidChange {
    [self setNeedsDisplay];
    _timerLabel.textColor = self.tintColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    _timerLabel.font = [self labelFont];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _timerLabel.frame = self.bounds;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, ORKTimerRingMinimumHeight);
}

- (void)setDuration:(NSTimeInterval)duration {
    validateDuration(duration);
    _duration = duration;
    _timeLeft = MIN(_timeLeft, _duration);
    [self updateTimerLabel];
    [self setNeedsDisplay];
}

- (void)setTimeLeft:(NSTimeInterval)timeLeft {
    _timeLeft = MIN(MAX(timeLeft, 0), _duration);
    [self updateTimerLabel];
    [self setNeedsDisplay];
}

- (BOOL)labelHidden {
    return _timerLabel.isHidden;
}

- (void)setLabelHidden:(BOOL)labelHidden {
    [_timerLabel setHidden:labelHidden];
}

- (UIFont *)labelFont {
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle];
    UIFontMetrics *metrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleLargeTitle];

    UIFontDescriptor *round = [[font fontDescriptor] fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    UIFontDescriptor *weighted = [round fontDescriptorByAddingAttributes:@{
        UIFontDescriptorTraitsAttribute: @{
            UIFontWeightTrait: @1.5
        }
    }];
    font = [UIFont fontWithDescriptor:weighted size:44];

    return [metrics scaledFontForFont:font];
}

- (void)updateTimerLabel {
    static NSDateComponentsFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateComponentsFormatter new];
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDropLeading;
        formatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitSecond;
    });

    _timerLabel.text = [formatter stringFromTimeInterval:MAX(round(_timeLeft), 0)];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat xCenter = self.bounds.size.width / 2;
    CGFloat yCenter = self.bounds.size.height / 2;
    CGFloat dimension = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat radius = 0.5 * (dimension * 0.5);
    CGFloat percentFilled = _timeLeft / _duration;
    CGFloat startAngle = -M_PI_2 - (percentFilled * 2 * M_PI);
    CGFloat stopAngle = -M_PI_2;

    CGContextSetLineWidth(context, ORKTimerRingStrokeWidth);
    CGContextSetLineCap(context, kCGLineCapRound);

    [[UIColor systemGray5Color] setStroke];
    CGContextAddArc(context, xCenter, yCenter, radius, 0, 2 * M_PI, 0);
    CGContextStrokePath(context);

    [self.tintColor setStroke];
    CGContextAddArc(context, xCenter, yCenter, radius, startAngle, stopAngle, 0);
    CGContextStrokePath(context);
}

@end
