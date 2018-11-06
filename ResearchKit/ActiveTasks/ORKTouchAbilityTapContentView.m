/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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

#import "ORKTouchAbilityTapContentView.h"

#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityTrack_Internal.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@interface ORKTouchAbilityTapContentView ()
@property (nonatomic, copy) ORKTouchAbilityTrack *track;
@end

@implementation ORKTouchAbilityTapContentView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithFrame:(CGRect)frame {
    // ORKThrowMethodUnavailableException();
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = self.tintColor;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.backgroundColor = self.tintColor;
}

- (void)updateLayoutMargins {
    CGFloat margin = ORKStandardHorizontalMarginForView(self);
    self.layoutMargins = (UIEdgeInsets){.left = margin * 2, .right = margin * 2};
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateLayoutMargins];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateLayoutMargins];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        [self.track addTouch:[[ORKTouchAbilityTouch alloc] initWithTouch:touch]];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        [self.track addTouch:[[ORKTouchAbilityTouch alloc] initWithTouch:touch]];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    for (UITouch *touch in touches) {
        [self.track addTouch:[[ORKTouchAbilityTouch alloc] initWithTouch:touch]];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    for (UITouch *touch in touches) {
       [self.track addTouch:[[ORKTouchAbilityTouch alloc] initWithTouch:touch]];
    }
    
}

- (ORKTouchAbilityTrack *)track {
    if (!_track) {
        _track = [[ORKTouchAbilityTrack alloc] init];
    }
    return _track;
}

@end
