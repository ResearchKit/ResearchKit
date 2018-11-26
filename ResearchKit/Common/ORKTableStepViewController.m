
/*
 Copyright (c) 2016, Sage Bionetworks
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import "ORKTableStepViewController.h"
#import "ORKTableStepViewController_Internal.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTableContainerView.h"

#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKTableStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


ORKDefineStringKey(ORKBasicCellReuseIdentifier);


@implementation ORKTableStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    UIColor *_tableViewColor;
}

- (id <ORKTableStepSource>)tableStep {
    if ([self.step conformsToProtocol:@protocol(ORKTableStepSource)]) {
        return (id <ORKTableStepSource>)self.step;
    }
    return nil;
}

- (ORKTableStep *)tableStepRef {
    return (ORKTableStep *)self.step;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.taskViewController setRegisteredScrollView:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    self.navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    self.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
    [_tableContainer setNeedsLayout];
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    self.navigationFooterView.cancelButtonItem = self.cancelButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    self.navigationFooterView.skipButtonItem = skipButtonItem;
    [self updateButtonStates];
}
    
- (UITableViewStyle)tableViewStyle {
    return [self numSections] > 1 ? UITableViewStyleGrouped : UITableViewStylePlain;
}

- (void)stepDidChange {
    [super stepDidChange];
    _tableViewColor = ORKNeedWideScreenDesign(self.view) ? [UIColor clearColor] : (ORKColor(ORKBackgroundColorKey));
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _headerView = nil;
    [_navigationFooterView removeFromSuperview];
    _navigationFooterView = nil;
    
    if (self.step) {
        _tableContainer = [[ORKTableContainerView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
        if ([self conformsToProtocol:@protocol(ORKTableContainerViewDelegate)]) {
            _tableContainer.delegate = (id)self;
        }
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableView.estimatedSectionHeaderHeight = [self numSections] > 1 ? 30.0 : 0.0;
        _tableView.allowsSelection = NO;
        
        _tableView.separatorColor = self.tableStepRef.isBulleted ? [UIColor clearColor] : nil;
        [_tableView setBackgroundColor:_tableViewColor];
        _tableView.alwaysBounceVertical = NO;
        _headerView = _tableContainer.stepHeaderView;
        _headerView.instructionLabel.text = [[self step] text];
        _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        
        _navigationFooterView = [ORKNavigationContainerView new];
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.cancelButtonItem = self.cancelButtonItem;
        _navigationFooterView.optional = self.step.optional;
        [self.view addSubview:_navigationFooterView];
        
        [self setupConstraints];
        // Register the cells for the table view
        if ([self.tableStep respondsToSelector:@selector(registerCellsForTableView:)]) {
            [self.tableStep registerCellsForTableView:_tableView];
        } else {
            [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ORKBasicCellReuseIdentifier];
        }
    }
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _tableContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;
    
    UIView *viewForiPad = [self viewForiPadLayoutConstraints];

    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view.safeAreaLayoutGuide
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:viewForiPad ? : self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_navigationFooterView
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (BOOL)continueButtonEnabled {
    return YES;
}

- (void)updateButtonStates {
    self.navigationFooterView.continueEnabled = [self continueButtonEnabled];
}

#pragma mark UITableViewDataSource
    
- (NSInteger)numSections {
    if ([self.tableStep respondsToSelector:@selector(numberOfSections)]) {
        return [self.tableStep numberOfSections] ?: 1;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableStep numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ORKThrowInvalidArgumentExceptionIfNil(self.tableStep);
    
    NSString *reuseIdentifier;
    if ([self.tableStep respondsToSelector:@selector(reuseIdentifierForRowAtIndexPath:)]) {
        reuseIdentifier = [self.tableStep reuseIdentifierForRowAtIndexPath:indexPath];
    } else {
        reuseIdentifier = ORKBasicCellReuseIdentifier;
    }
    ORKThrowInvalidArgumentExceptionIfNil(reuseIdentifier);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self.tableStep configureCell:cell indexPath:indexPath tableView:tableView];
    
    [cell setBackgroundColor:_tableViewColor];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.tableStep respondsToSelector:@selector(titleForHeaderInSection:tableView:)]) {
        return [self.tableStep titleForHeaderInSection:section tableView:tableView];
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.tableStep respondsToSelector:@selector(viewForHeaderInSection:tableView:)]) {
        return [self.tableStep viewForHeaderInSection:section tableView:tableView];
    } else {
        return nil;
    }
}

@end

