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


#import "ORKReviewCompletionStepViewController.h"

#import "ORKCustomStepView_Internal.h"
#import "ORKInstructionStepView.h"
#import "ORKNavigationContainerView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKVerticalContainerView_Internal.h"

#import "ORKTaskViewController.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"

#import "ORKHelpers_Internal.h"

#import "ORKContinueButton.h"

@interface ORKReviewCompletionStepViewController ()
@property (nonatomic) ORKContinueButton* reviewButton;
@property (nonatomic) ORKContinueButton* continueButton;
@end

@implementation ORKReviewCompletionStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    ORKNavigationContainerView *container = self.stepView.continueSkipContainer;
//    self.stepView.continueSkipContainer.hidden = YES;
//    
//    [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    

    self.reviewButton = [[ORKContinueButton alloc] initWithTitle:@"Review" isDoneButton:NO];
    self.reviewButton.exclusiveTouch = YES;
    self.reviewButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.reviewButton addTarget:self
                          action:@selector(reviewButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];

    
    self.continueButton = [[ORKContinueButton alloc] initWithTitle:@"Done" isDoneButton:NO];
    self.continueButton.exclusiveTouch = YES;
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton addTarget:self
                            action:@selector(doneButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];
    

    [self.stepView.continueSkipContainer addSubview:self.reviewButton];
    [self.stepView.continueSkipContainer addSubview:self.continueButton];
}

- (void)reviewButtonAction:(id)sender {

    // TODO: remove this hack in leu of delegation patter.
    // very hacky - just for demo / iteration purpose only.
    // i don't think we will take this "review" / "done" button UI, since there is review step.
    if ([self.parentViewController.parentViewController.parentViewController isKindOfClass:[ORKTaskViewController class]]) {
        ORKTaskViewController *vc = (ORKTaskViewController *)self.parentViewController.parentViewController.parentViewController;
        [vc jumpToRoot:YES];
    }
}

- (void)doneButtonAction:(id)sender {
    [self goForward];
}


static const CGFloat ButtonHorizontalSpacing = 40;
static const CGFloat ButtonWidth = 120;
static const CGFloat ButtonHeight = 44;


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat centerX = self.stepView.continueSkipContainer.bounds.size.width / 2;
    CGFloat centerY = self.stepView.continueSkipContainer.bounds.size.height / 2;
    self.reviewButton.frame = CGRectMake(centerX - ButtonHorizontalSpacing / 2 - ButtonWidth,
                                         centerY - ButtonHeight / 2,
                                         ButtonWidth, ButtonHeight);
    self.continueButton.frame = CGRectMake(centerX + ButtonHorizontalSpacing / 2,
                                           centerY - ButtonHeight / 2,
                                           ButtonWidth, ButtonHeight);
}



@end
