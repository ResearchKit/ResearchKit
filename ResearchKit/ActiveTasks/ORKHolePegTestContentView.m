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


#import "ORKHolePegTestContentView.h"
#import "ORKHolePegTestPegView.h"
#import "ORKDirectionView.h"


static const CGFloat ORKPegViewDiameter = 148.0f;
static const CGFloat ORKPegViewSensibility = 4.0f;


// #define LAYOUT_DEBUG 1


@interface ORKHolePegTestContentView () <ORKHolePegTestPegViewDelegate>

@property (nonatomic, strong) ORKHolePegTestPegView *pegView;
@property (nonatomic, strong) ORKHolePegTestPegView *holeView;
@property (nonatomic, strong) ORKDirectionView *directionView;
@property (nonatomic, copy) NSArray *constraints;

@end


@implementation ORKHolePegTestContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _holeView = [[ORKHolePegTestPegView alloc] initWithType:ORKHolePegTypeHole];
        _holeView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_holeView];
        
        _pegView = [[ORKHolePegTestPegView alloc] initWithType:ORKHolePegTypePeg];
        _pegView.delegate = self;
        _pegView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pegView];
        
        _directionView = [[ORKDirectionView alloc] init];
        _directionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_directionView];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setNeedsUpdateConstraints];
        
#if LAYOUT_DEBUG
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
#endif
    }
    return self;
}

- (void)updateConstraints {
    if ([_constraints count]) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
        _constraints = nil;
    }
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_pegView, _holeView, _directionView);
    NSDictionary *metrics = @{@"diameter" : @(ORKPegViewDiameter)};
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_pegView(diameter)]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:metrics
                                               views:views]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_holeView(diameter)]-|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:metrics
                                               views:views]];

    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pegView(diameter)]->=0-[_holeView(diameter)]|"
                                             options:NSLayoutFormatAlignAllCenterY
                                             metrics:metrics
                                               views:views]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1
                                                         constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.directionView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1
                                                         constant:0]];
    
    _constraints = constraints;
    [self addConstraints:_constraints];
    
    [NSLayoutConstraint activateConstraints:constraints];
    [super updateConstraints];
}

#pragma mark - peg view delegate

- (void)pegViewDidMove:(ORKHolePegTestPegView *)pegView success:(void (^ __nonnull)(BOOL))success {
    CGRect holeFrame = CGRectMake(CGRectGetMidX(self.holeView.frame) - ORKPegViewSensibility,
                                  CGRectGetMidY(self.holeView.frame) - ORKPegViewSensibility,
                                  2 * ORKPegViewSensibility,
                                  2 * ORKPegViewSensibility);
    
    CGPoint pegCenter = CGPointMake(CGRectGetMaxX(pegView.frame) - CGRectGetMidX(pegView.bounds),
                                    CGRectGetMaxY(pegView.frame) - CGRectGetMidY(pegView.bounds));
    
    if (CGRectContainsPoint(holeFrame, pegCenter)) {
        pegView.alpha = 1.0f;
        success(YES);
    } else {
        pegView.alpha = 0.2f;
        success(NO);
    }
}

@end
