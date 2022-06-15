
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
#import "ORKTableContainerView.h"

#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKTableStep.h"
#import "ORKStepContentView.h"
#import "ORKBodyItem.h"
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
    
    if (_tableContainer) {
        [_tableContainer sizeHeaderToFit];
        [_tableContainer resizeFooterToFit];
        [_tableContainer layoutIfNeeded];
    }
    
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _navigationFooterView.skipButtonItem = skipButtonItem;
    [self updateButtonStates];
}
    
- (UITableViewStyle)tableViewStyle {
    if ([self.tableStep respondsToSelector:@selector(customTableViewStyle)]) {
        return [self.tableStep customTableViewStyle];
    }
    
    return [self numSections] > 1 ? UITableViewStyleGrouped : UITableViewStylePlain;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainer sizeHeaderToFit];
    
    // Recalculate the footer view size if needed.
    [_tableContainer layoutSubviews];
    [self updateEffectViewStylingAndAnimate:NO];
}

- (void)stepDidChange {
    [super stepDidChange];

    _tableViewColor = ORKNeedWideScreenDesign(self.view) ? [UIColor clearColor] : ORKColor(ORKBackgroundColorKey);
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;

    _headerView = nil;
    _navigationFooterView = nil;
    
    if (self.step) {
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:self.tableViewStyle pinNavigationContainer:self.tableStepRef.pinNavigationContainer];
        if ([self conformsToProtocol:@protocol(ORKTableContainerViewDelegate)]) {
            _tableContainer.tableContainerDelegate = (id)self;
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
        _tableView.allowsSelection = self.tableStepRef.allowsSelection;
        
        _tableView.separatorColor = self.tableStepRef.bulletType == ORKBulletTypeNone ? [UIColor clearColor] : nil;
        [_tableView setBackgroundColor:_tableViewColor];
        _tableView.alwaysBounceVertical = NO;
        _headerView = _tableContainer.stepContentView;
        [_tableContainer.stepContentView setUseExtendedPadding:[[self step] useExtendedPadding]];
        
        _headerView.stepTitle = [[self step] title];
        _headerView.stepText = [[self step] text];
        _headerView.bodyItems = [[self step] bodyItems];
        _headerView.stepTopContentImage = [[self step] image];
        _headerView.auxiliaryImage = [[self step] auxiliaryImage];
        _headerView.titleIconImage = [[self step] iconImage];
        _headerView.stepHeaderTextAlignment = [[self step] headerTextAlignment];
        _tableContainer.stepTopContentImageContentMode = [[self step] imageContentMode];
        _navigationFooterView = _tableContainer.navigationFooterView;
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.optional = self.step.optional;
        
        [_navigationFooterView setUseExtendedPadding:[[self step] useExtendedPadding]];
        
        [self setupConstraints];
        // Register the cells for the table view
        if ([self.tableStep respondsToSelector:@selector(registerCellsForTableView:)]) {
            [self.tableStep registerCellsForTableView:_tableView];
        } else {
            [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ORKBasicCellReuseIdentifier];
        }
        
        if (self.tableStepRef.pinNavigationContainer == NO) {
            [_navigationFooterView removeStyling];
        }
    }
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _tableContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;
    
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_tableContainer
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (BOOL)continueButtonEnabled {
    return YES;
}

- (void)updateButtonStates {
    _navigationFooterView.continueEnabled = [self continueButtonEnabled];
}

- (void)updateEffectViewStylingAndAnimate:(BOOL)animated {
    CGFloat currentOpacity = [_navigationFooterView effectViewOpacity];
    CGFloat startOfFooter = _navigationFooterView.frame.origin.y;
    CGFloat contentPosition = (_tableView.contentSize.height - _tableView.contentOffset.y);

    CGFloat newOpacity = (contentPosition < startOfFooter) ? ORKEffectViewOpacityHidden : ORKEffectViewOpacityVisible;
    if (newOpacity != currentOpacity) {
        // Don't animate transition from hidden to visible as text appears behind during animation
        if (currentOpacity == ORKEffectViewOpacityHidden) { animated = NO; }
        [_navigationFooterView setStylingOpactity:newOpacity animated:animated];
    }
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

    // Only set the background color if it is using the default cell type
    if ([reuseIdentifier isEqualToString:ORKBasicCellReuseIdentifier]) {
        if (@available(iOS 13.0, *)) {
            [cell setBackgroundColor:[UIColor clearColor]];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // FIXME:- temporary fix for estimating tableFooterView's height
    if (indexPath == tableView.indexPathsForVisibleRows.lastObject) {
        [self.view setNeedsLayout];
    }
}

// MARK: ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateEffectViewStylingAndAnimate:YES];
}

@end

