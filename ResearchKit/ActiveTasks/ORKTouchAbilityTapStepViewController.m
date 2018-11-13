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


#import "ORKTouchAbilityTapStepViewController.h"

#import "ORKActiveStepView.h"
#import "ORKTouchAbilityTapContentView.h"

#import "ORKActiveStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKCollectionResult_Private.h"
#import "ORKTouchAbilityTapStep.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKHelpers_Internal.h"

@interface ORKTouchAbilityTapStepViewController ()

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, strong) ORKTouchAbilityTapContentView *touchAbilityTapContentView;
@property (nonatomic, assign) NSUInteger successes;
@property (nonatomic, assign) NSUInteger failures;

@end

@implementation ORKTouchAbilityTapStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    return self;
}

- (ORKTouchAbilityTapStep *)touchAbilityTapStep {
    return (ORKTouchAbilityTapStep *)self.step;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.touchAbilityTapContentView = [[ORKTouchAbilityTapContentView alloc] init];
    self.touchAbilityTapContentView.backgroundColor = [UIColor redColor];
    self.activeStepView.activeCustomView = self.touchAbilityTapContentView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    self.activeStepView.scrollContainerShouldCollapseNavbar = NO;
    
    UIView *fooView = [UIView new];
    fooView.backgroundColor = self.view.tintColor;
    fooView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.touchAbilityTapContentView addSubview:fooView];
    
    NSArray *constraints = @[[fooView.topAnchor constraintGreaterThanOrEqualToAnchor:self.touchAbilityTapContentView.topAnchor],
                             [fooView.bottomAnchor constraintLessThanOrEqualToAnchor:self.touchAbilityTapContentView.bottomAnchor],
                             [fooView.centerXAnchor constraintEqualToAnchor:self.touchAbilityTapContentView.centerXAnchor],
                             [fooView.centerYAnchor constraintEqualToAnchor:self.touchAbilityTapContentView.centerYAnchor],
                             [fooView.heightAnchor constraintEqualToConstant:100],
                             [fooView.widthAnchor constraintEqualToConstant:100]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.touchAbilityTapContentView startTracking];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
