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


#import "ORKStepViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface ORKStepViewController () <UIViewControllerRestoration>

- (void)stepDidChange;

@property (nonatomic, copy, nullable) NSURL *outputDirectory;

@property (nonatomic, strong, nullable) UIBarButtonItem *internalContinueButtonItem;
@property (nonatomic, strong, nullable) UIBarButtonItem *internalBackButtonItem;
@property (nonatomic, strong, nullable) UIBarButtonItem *internalDoneButtonItem;

@property (nonatomic, strong, nullable) UIBarButtonItem *internalSkipButtonItem;

@property (nonatomic, strong, nullable) UIBarButtonItem *continueButtonItem;
@property (nonatomic, strong, nullable) UIBarButtonItem *learnMoreButtonItem;
@property (nonatomic, strong, nullable) UIBarButtonItem *skipButtonItem;

@property (nonatomic, copy, nullable) NSDate *presentedDate;
@property (nonatomic, copy, nullable) NSDate *dismissedDate;

@property (nonatomic, copy, nullable) NSString *restoredStepIdentifier;

+ (UIInterfaceOrientationMask)supportedInterfaceOrientations;

// this property is set to `YES` when the step is part of a standalone review step. If set to `YES it will prevent any user input that might change the step result.
@property (nonatomic, readonly) BOOL readOnlyMode;

@property (nonatomic, readonly) BOOL isBeingReviewed;

@property (nonatomic, nullable) ORKReviewStep* parentReviewStep;

- (void)willNavigateDirection:(ORKStepViewControllerNavigationDirection)direction;

- (void)notifyDelegateOnResultChange;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

- (void)showValidityAlertWithMessage:(NSString *)text;

- (void)showValidityAlertWithTitle:(NSString *)title message:(NSString *)message;

- (void)skipForward;

- (void)initializeInternalButtonItems;

// internal use version to set backButton, without override "_internalBackButtonItem"
- (void)ork_setBackButtonItem:(nullable UIBarButtonItem *)backButton;

// internal method for updating the right bar button item.
- (void)updateNavRightBarButtonItem;
- (void)updateNavLeftBarButtonItem;

@end

NS_ASSUME_NONNULL_END
