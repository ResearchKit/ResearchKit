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
#import "ORKReviewStep.h"
#import "ORKStep_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKTableContainerView.h"
#import "ORKChoiceViewCell.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKResult.h"

@interface ORKReviewStepViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKStepHeaderView *headerView;
@property (nonatomic, strong) ORKNavigationContainerView *continueSkipView;

@end

@implementation ORKReviewStepViewController

- (instancetype)initWithStep:(nonnull ORKStep *)step result:(nonnull ORKResult *)result {
    self = [super initWithStep:step result:result];
    if (self) {
        if (!self.reviewStep) {
            //TODO: throw exception
        }
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (!self.reviewStep) {
            //TODO: throw exception
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.completed = NO;
    if (!self.hasBeenPresented && self.steps.count == 0) {
        //TODO: localize string
        _headerView.instructionLabel.text = @"No steps available for review";
    }
    [super viewWillAppear:animated];
    [self.taskViewController setRegisteredScrollView:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.leftBarButtonItem);
}

- (void)goForward {
    self.completed = YES;
    [super goForward];
}

//TODO: defaults

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
    [_tableContainer setNeedsLayout];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _headerView = nil;
    _continueSkipView = nil;
    
    if ([self reviewStep]) {
        _tableContainer = [[ORKTableContainerView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        ORKScreenType screenType = ORKGetScreenTypeForWindow(self.view.window);
        _tableView.estimatedRowHeight = ORKGetMetricForScreenType(ORKScreenMetricTableCellDefaultHeight, screenType);
        [_tableView registerClass:[ORKChoiceViewCell class] forCellReuseIdentifier:@"reviewCell"];
        
        _headerView = _tableContainer.stepHeaderView;
        _headerView.captionLabel.text = [[self reviewStep] title];
        _headerView.captionLabel.useSurveyMode = [[self reviewStep] useSurveyMode];
        _headerView.instructionLabel.text = [[self reviewStep] text];
        _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        
        _continueSkipView = _tableContainer.continueSkipContainerView;
        _continueSkipView.skipButtonItem = self.skipButtonItem;
        _continueSkipView.continueEnabled = YES;
        _continueSkipView.continueButtonItem = self.continueButtonItem;
        _continueSkipView.optional = self.step.optional;
        _continueSkipView.hidden = self.step.isBeingReviewed;
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _continueSkipView.continueButtonItem = continueButtonItem;
}

- (ORKReviewStep *)reviewStep {
    return [self.step isKindOfClass:[ORKReviewStep class]] ? (ORKReviewStep *) self.step : nil;
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    parentResult.endDate = self.completed ? [NSDate date] : nil;
    return parentResult;
}

//TODO: state restoration

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _steps.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //TODO: change cell appearance
    ORKChoiceViewCell *cell = (ORKChoiceViewCell *) [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
    cell.immediateNavigation = YES;
    cell.shortLabel.text = [_steps[indexPath.row] title];
    //TODO: process results
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self.reviewDelegate respondsToSelector:@selector(reviewStepViewController:reviewStep:)]) {
        [self.reviewDelegate reviewStepViewController:self reviewStep:_steps[indexPath.row]];
    }
}



@end

