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


#import "ORKHolePegTestPlaceContentView.h"
#import "ORKHolePegTestPlacePegView.h"
#import "ORKHolePegTestPlaceHoleView.h"
#import "ORKDirectionView.h"


#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)


@interface ORKHolePegTestPlaceContentView () <ORKHolePegTestPlacePegViewDelegate>

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ORKHolePegTestPlacePegView *pegView;
@property (nonatomic, strong) ORKHolePegTestPlaceHoleView *holeView;
@property (nonatomic, strong) ORKDirectionView *directionView;
@property (nonatomic, copy) NSArray *constraints;

@end


@implementation ORKHolePegTestPlaceContentView

- (instancetype)initWithOrientation:(ORKSide)orientation {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.orientation = orientation;

        self.progressView = [UIProgressView new];
        self.progressView.progressTintColor = [self tintColor];
        [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.progressView setAlpha:0];
        [self addSubview:self.progressView];
        
        self.holeView = [[ORKHolePegTestPlaceHoleView alloc] init];
        [self.holeView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.holeView];
        
        self.pegView = [[ORKHolePegTestPlacePegView alloc] init];
        self.pegView.delegate = self;
        [self.pegView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.pegView];
        
        self.directionView = [[ORKDirectionView alloc] initWithOrientation:self.orientation];
        [self.directionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.directionView];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressView.progressTintColor = [self tintColor];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        [self.progressView setAlpha:(progress == 0) ? 0 : 1];
    }];
}

- (void)updateConstraints {
    if ([self.constraints count]) {
        [NSLayoutConstraint deactivateConstraints:self.constraints];
        self.constraints = nil;
    }
    
    NSMutableArray *constraintsArray = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_progressView, _pegView, _holeView, _directionView);
    NSDictionary *metrics = @{@"pegViewDiameter" : @(_pegView.intrinsicContentSize.height)};
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_progressView]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:self.orientation == ORKSideLeft ? @"H:|[_holeView]->=0-[_pegView]|" : @"H:|[_pegView]->=0-[_holeView]|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_progressView]"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_pegView(pegViewDiameter)]->=0-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:metrics views:views]];
    
    [constraintsArray addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[_holeView]->=0-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil views:views]];

    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.pegView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1
                                                              constant:0]];
    
    [constraintsArray addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                              constant:0]];
    
    self.constraints = constraintsArray;
    [self addConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:self.constraints];
    [super updateConstraints];
}

#pragma mark - peg view delegate

- (void)pegViewDidMove:(ORKHolePegTestPlacePegView *)pegView {
    if ([self holeViewContainsPegView:pegView]) {
        pegView.alpha = 1.0f;
    } else {
        pegView.alpha = 0.2f;
    }
    
    self.directionView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidProgress:)]) {
        [self.delegate holePegTestPlaceDidProgress:self];
    }
}

- (void)pegViewMoveEnded:(ORKHolePegTestPlacePegView *)pegView success:(void (^)(BOOL succeded))success {
    if ([self holeViewContainsPegView:pegView]) {
        if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidSucceed:)]) {
            [self.delegate holePegTestPlaceDidSucceed:self];
        }
        self.holeView.success = YES;
        success(YES);
    } else {
        if ([self.delegate respondsToSelector:@selector(holePegTestPlaceDidFail:)]) {
            [self.delegate holePegTestPlaceDidFail:self];
        }
        self.holeView.success = NO;
        success(NO);
    }
    
    self.directionView.hidden = NO;
}

- (BOOL)holeViewContainsPegView:(ORKHolePegTestPlacePegView *)pegView {
    CGRect detectionFrame = CGRectMake(CGRectGetMidX(self.holeView.frame) - self.translationThreshold / 2,
                                       CGRectGetMidY(self.holeView.frame) - self.translationThreshold / 2,
                                       self.translationThreshold,
                                       self.translationThreshold);
    
    CGPoint pegCenter = CGPointMake(CGRectGetMaxX(pegView.frame) - CGRectGetWidth(pegView.frame) / 2,
                                    CGRectGetMaxY(pegView.frame) - CGRectGetHeight(pegView.frame) / 2);
    
    if (CGRectContainsPoint(detectionFrame, pegCenter)) {
        double rotation = atan2(pegView.transform.b, pegView.transform.a);
        double angle = fmod(fabs(rotation), M_PI_2);
        if (angle > M_PI_4 - degreesToRadians(self.rotationThreshold / 2) &&
            angle < M_PI_4 + degreesToRadians(self.rotationThreshold / 2)) {
            return YES;
        }
    }
    
    return NO;
}

@end
