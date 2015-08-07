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


#import "ORKHolePegTestPlaceStep.h"
#import "ORKHolePegTestPlaceStepViewController.h"


@implementation ORKHolePegTestPlaceStep

+ (Class)stepViewControllerClass {
    return [ORKHolePegTestPlaceStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldStartTimerAutomatically = YES;
        self.shouldShowDefaultTimer = NO;
        self.shouldContinueOnFinish = YES;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    int const ORKHolePegTestMinimumNumberOfHoles = 1;
    
    double const ORKHolePegTestMinimumTranslationThreshold = 0.0f;
    double const ORKHolePegTestMaximumTranslationThreshold = 148.0f;
    
    double const ORKHolePegTestMinimumRotationThreshold = 0.0f;
    double const ORKHolePegTestMaximumRotationThreshold = 90.0f;
    
    NSTimeInterval const ORKHolePegTestMinimumDuration = 1.0f;
    
    if (self.numberOfHoles < ORKHolePegTestMinimumNumberOfHoles) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of holes must be greater than or equal to %@.", @(ORKHolePegTestMinimumNumberOfHoles)] userInfo:nil];
    }
    
    if (self.translationThreshold < ORKHolePegTestMinimumTranslationThreshold ||
        self.translationThreshold > ORKHolePegTestMaximumTranslationThreshold) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"translation threshold must be greater than or equal to %@ and lower or equal to %@.", @(ORKHolePegTestMinimumTranslationThreshold), @(ORKHolePegTestMaximumTranslationThreshold)] userInfo:nil];
    }
    
    if (self.rotationThreshold < ORKHolePegTestMinimumRotationThreshold ||
        self.rotationThreshold > ORKHolePegTestMaximumRotationThreshold) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"rotation threshold must be greater than or equal to %@ and lower or equal to %@.", @(ORKHolePegTestMinimumRotationThreshold), @(ORKHolePegTestMaximumRotationThreshold)] userInfo:nil];
    }
    
    if (self.stepDuration < ORKHolePegTestMinimumDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"duration can not be shorter than %@ seconds.", @(ORKHolePegTestMinimumDuration)] userInfo:nil];
    }
}

- (BOOL)allowsBackNavigation {
    return NO;
}

@end
