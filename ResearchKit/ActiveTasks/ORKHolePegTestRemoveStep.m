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


#import "ORKHolePegTestRemoveStep.h"
#import "ORKHolePegTestRemoveStepViewController.h"


@implementation ORKHolePegTestRemoveStep

+ (Class)stepViewControllerClass {
    return [ORKHolePegTestRemoveStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldShowDefaultTimer = NO;
        self.shouldContinueOnFinish = YES;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    int const ORKHolePegTestMinimumNumberOfPegs = 1;
    
    double const ORKHolePegTestMinimumThreshold = 0.0f;
    double const ORKHolePegTestMaximumThreshold = 1.0f;
    
    NSTimeInterval const ORKHolePegTestMinimumDuration = 1.0f;
    
    if (self.movingDirection != ORKBodySagittalLeft &&
        self.movingDirection != ORKBodySagittalRight) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"moving direction should be left or right."] userInfo:nil];
    }
    
    if (self.numberOfPegs < ORKHolePegTestMinimumNumberOfPegs) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"number of pegs must be greater than or equal to %@.", @(ORKHolePegTestMinimumNumberOfPegs)] userInfo:nil];
    }
    
    if (self.threshold < ORKHolePegTestMinimumThreshold ||
        self.threshold > ORKHolePegTestMaximumThreshold) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"threshold must be greater than or equal to %@ and lower or equal to %@.", @(ORKHolePegTestMinimumThreshold), @(ORKHolePegTestMaximumThreshold)] userInfo:nil];
    }
    
    if (self.stepDuration < ORKHolePegTestMinimumDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"duration can not be shorter than %@ seconds.", @(ORKHolePegTestMinimumDuration)] userInfo:nil];
    }
}

- (BOOL)allowsBackNavigation {
    return NO;
}

@end
