/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKAmslerGridStepViewController.h"
#import "ORKAmslerGridContentView.h"
#import "ORKAmslerGridStep.h"
#import "ORKFreehandDrawingView.h"
#import "ORKActiveStepTimer.h"
#import "ORKActiveStepView.h"
#import "ORKStepViewController_Internal.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKNavigationContainerView.h"
#import "ORKStep_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKAmslerGridResult.h"
#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKBorderedButton.h"


@interface ORKAmslerGridStepViewController () {
    ORKFreehandDrawingView *_freehandDrawingView;
    ORKAmslerGridContentView *_amslerGridView;
}

@end

@implementation ORKAmslerGridStepViewController

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.suspendIfInactive = YES;
    }
    self.shouldIgnoreiPadDesign = YES;
    return self;
}

- (ORKAmslerGridStep *)amslerGridStep {
    return (ORKAmslerGridStep *)self.step;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationFooterView setHidden:YES];
    _amslerGridView = [ORKAmslerGridContentView new];
    _amslerGridView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activeStepView.activeCustomView = _amslerGridView;
    self.activeStepView.stepViewFillsAvailableSpace = YES;
    
    _freehandDrawingView = [ORKFreehandDrawingView new];

    _freehandDrawingView.translatesAutoresizingMaskIntoConstraints = NO;
    _freehandDrawingView.backgroundColor = [UIColor clearColor];
    _freehandDrawingView.opaque = NO;

    [_amslerGridView addSubview:_freehandDrawingView];
   
    UISwipeGestureRecognizer *r = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    r.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.activeStepView addGestureRecognizer:r];
    
    self.activeStepView.isAccessibilityElement = YES;
    self.activeStepView.accessibilityLabel = ORKLocalizedString(@"AX_AMSLER_GRID_LABEL", nil);
    self.activeStepView.accessibilityHint = ORKLocalizedString(@"AX_AMSLER_GRID_HINT", nil);
    self.activeStepView.accessibilityTraits = UIAccessibilityTraitImage | UIAccessibilityTraitAllowsDirectInteraction;
    [self setupContraints];
}

- (void)handleSingleTap:(UISwipeGestureRecognizer *)recognizer {
    [self finish];
}

- (void)setupContraints {
    CGFloat width = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    NSArray *constraints = @[
                             
                             [NSLayoutConstraint constraintWithItem:_amslerGridView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:width],
                             [NSLayoutConstraint constraintWithItem:_amslerGridView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:width],
                             [NSLayoutConstraint constraintWithItem:_amslerGridView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_amslerGridView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:width],
                             [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:width],
                             [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_amslerGridView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0],
                             [NSLayoutConstraint constraintWithItem:_freehandDrawingView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_amslerGridView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]
                             ];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)stepDidFinish {
    [super stepDidFinish];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (ORKStepResult *)result {
    
    ORKStepResult *parentResult = [super result];
    
    if (_freehandDrawingView.freehandDrawingExists) {
        UIImage *image = [self getImage];
        ORKAmslerGridResult *amslerGridResult = [[ORKAmslerGridResult alloc] initWithIdentifier:self.step.identifier image:image path:_freehandDrawingView.freehandDrawingPath eyeSide: [self amslerGridStep].eyeSide];
        parentResult.results = @[amslerGridResult];
    }

    return parentResult;
}

- (UIImage *)getImage {
    CGSize imageContextSize;
    imageContextSize = _amslerGridView.bounds.size;
    UIGraphicsBeginImageContext(imageContextSize);
    
    UIGraphicsBeginImageContextWithOptions(imageContextSize, _amslerGridView.isOpaque, 0.0f);
    
    CGRect rec = CGRectMake(0, 0, _amslerGridView.bounds.size.width, _amslerGridView.bounds.size.height);
    [_amslerGridView drawViewHierarchyInRect:rec afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
