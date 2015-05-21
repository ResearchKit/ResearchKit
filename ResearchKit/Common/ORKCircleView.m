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

 
#import "ORKCircleView.h"


@implementation ORKCircleView

@synthesize tintColor = _tintColor;

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 2.0f;
    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

- (UIBezierPath *)layoutPath {
    return [UIBezierPath bezierPathWithOvalInRect:self.bounds];
}

#pragma mark - Custom Methods

+ (Class)layerClass {
    return CAShapeLayer.class;
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

#pragma mark - View Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shapeLayer.cornerRadius = self.frame.size.width / 2.0f;
    self.shapeLayer.path = [self layoutPath].CGPath;
}

#pragma mark - Setter methods

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.borderColor = _tintColor.CGColor;
}

@end
