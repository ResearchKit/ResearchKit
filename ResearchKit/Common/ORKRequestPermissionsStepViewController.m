/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKRequestPermissionsStepViewController.h"
#import "ORKRequestPermissionsStep.h"
#import "ORKRequestPermissionView.h"
#import "ORKPermissionType.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepView_Private.h"
#import "ORKRequestPermissionsStepContainerView.h"

#import "ORKResult_Private.h"
#import "ORKCollectionResult_Private.h"
#import "ORKStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@implementation ORKRequestPermissionsStepViewController {
    NSMutableArray<NSLayoutConstraint *> *_constraints;
    ORKRequestPermissionsStepContainerView *_requestPermissionsStepContainerView;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step result:result];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_requestPermissionsStepContainerView) {
        [_requestPermissionsStepContainerView layoutSubviews];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cardViewStatusDidChange:)
                                                 name:ORKRequestPermissionsNotificationCardViewStatusChanged
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORKRequestPermissionsNotificationCardViewStatusChanged object:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ORKRequestPermissionsNotificationCardViewStatusChanged object:nil];
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    return parentResult;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _navigationFooterView.skipButtonItem = skipButtonItem;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_requestPermissionsStepContainerView removeFromSuperview];
    
    NSMutableArray<ORKRequestPermissionView *> *cardViews = [self fetchCardViews];
    
    _requestPermissionsStepContainerView = [[ORKRequestPermissionsStepContainerView alloc] initWithCardViews:cardViews];
    [_requestPermissionsStepContainerView placeNavigationContainerInsideScrollView];
    _requestPermissionsStepContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _requestPermissionsStepContainerView.frame = self.view.bounds;
    _requestPermissionsStepContainerView.stepTitle = self.step.title;
    _requestPermissionsStepContainerView.stepText = self.step.text;
    _requestPermissionsStepContainerView.stepDetailText = self.step.detailText;
    _requestPermissionsStepContainerView.stepHeaderTextAlignment = self.step.headerTextAlignment;
    _requestPermissionsStepContainerView.stepTopContentImage = self.step.image;
    _requestPermissionsStepContainerView.stepTopContentImageContentMode = self.step.imageContentMode;
    _requestPermissionsStepContainerView.bodyItems = self.step.bodyItems;
    [self setupNavigationFooterView];
    
    [self.view addSubview:_requestPermissionsStepContainerView];
    [self setupConstraints];
}

- (void)setupNavigationFooterView {
    if (!_navigationFooterView && _requestPermissionsStepContainerView) {
        _navigationFooterView = _requestPermissionsStepContainerView.navigationFooterView;
    }
    _navigationFooterView.skipButtonItem = self.skipButtonItem;
    _navigationFooterView.continueButtonItem = self.continueButtonItem;

    _navigationFooterView.optional = NO;
    [_navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    
    _constraints = [NSMutableArray new];
    
    [_constraints addObject:[_requestPermissionsStepContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor]];
    [_constraints addObject:[_requestPermissionsStepContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]];
    [_constraints addObject:[_requestPermissionsStepContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor]];
    [_constraints addObject:[_requestPermissionsStepContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]];
    
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)cardViewStatusDidChange:(NSNotification *)notification {
    NSMutableArray *cardViews = [self fetchCardViews];
    
    for (ORKRequestPermissionView *cardView in cardViews) {
        if (!cardView.enableContinueButton) {
            _navigationFooterView.continueEnabled = NO;
            return;
        }
    }
    
    _navigationFooterView.continueEnabled = YES;
}

- (ORKRequestPermissionsStep *)requestPermissionsStep {
    return (ORKRequestPermissionsStep *)self.step;
}

- (NSMutableArray<ORKRequestPermissionView *> *)fetchCardViews {
    ORKRequestPermissionsStep *requestPermissionStep = [self requestPermissionsStep];
    NSMutableArray<ORKRequestPermissionView *> *cardViews = [NSMutableArray new];
    
    for (ORKPermissionType *permissionType in requestPermissionStep.permissionTypes) {
       
        [cardViews addObject:permissionType.cardView];
    }
    
    return cardViews;
}

@end
