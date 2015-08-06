/*
 Copyright (c) 2015, Oliver Schaefer. All rights reserved.
 
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


#import "ORKReviewStepViewController.h"
#import "ORKStepViewController_Internal.h"
#import "ORKReviewStep.h"
#import "ORKTask.h"


@interface ORKReviewStepViewController ()

@end

@implementation ORKReviewStepViewController

- (nonnull instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        _reviewDirection = ORKReviewStepViewControllerReviewDirectionReverse;
    }
    return self;
}

- (nonnull instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _reviewDirection = ORKReviewStepViewControllerReviewDirectionReverse;
    }
    return self;
}

- (void)discoverStepsWithResult:(ORKTaskResult *)result {
    ORKReviewStep *reviewStep = (ORKReviewStep*) self.step;
    if (reviewStep && result) {
        NSMutableArray *steps = [NSMutableArray alloc];
        ORKStep *nextStep = self.step;
        do {
            switch (_reviewDirection) {
                case ORKReviewStepViewControllerReviewDirectionForward:
                    nextStep = [[reviewStep task] stepAfterStep:nextStep withResult:result];
                    break;
                case ORKReviewStepViewControllerReviewDirectionReverse:
                    nextStep = [[reviewStep task] stepBeforeStep:nextStep withResult:result];
                    break;
            }
            if (nextStep != nil && ![nextStep isKindOfClass:[ORKReviewStep class]]) {
                [steps addObject:nextStep];
            }
        } while (nextStep != nil && ![nextStep isKindOfClass:[ORKReviewStep class]]);
        _steps = [steps copy];
    }
}

//TODO: state restoration

@end
