/*
 Copyright (c) 2015, Oliver Schaefer.
 
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
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKChoiceViewCell.h"


typedef NS_ENUM(NSInteger, ORKReviewSection) {
    ORKReviewSectionSpace1 = 0,
    ORKReviewSectionAnswer = 1,
    ORKReviewSectionSpace2 = 2,
    ORKReviewSectionCount
};

@interface ORKReviewStepViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;

@end

@implementation ORKReviewStepViewController {
    ORKNavigationContainerView *_continueSkipView;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}
#pragma clang diagnostic pop
 
- (instancetype)initWithReviewStep:(ORKReviewStep *)reviewStep steps:(nullable NSArray<ORKStep *>*)steps resultSource:(nullable id<ORKTaskResultSource>)resultSource {
    self = [self initWithStep:reviewStep];
    if (self && [self reviewStep]) {
        NSArray<ORKStep *> *stepsToFilter = [self reviewStep].steps != nil ? [self reviewStep].steps : steps;
        NSMutableArray<ORKStep *> *filteredSteps = [[NSMutableArray alloc] init];
        [stepsToFilter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BOOL includeStep = [obj isKindOfClass:[ORKQuestionStep class]] || [obj isKindOfClass:[ORKFormStep class]] || [obj isKindOfClass:[ORKInstructionStep class]];
            if (includeStep) {
                [filteredSteps addObject:obj];
            }
        }];
        _steps = [filteredSteps copy];
        _resultSource = [self reviewStep].resultSource != nil ? [self reviewStep].resultSource : resultSource;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.taskViewController setRegisteredScrollView: _tableContainer.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.leftBarButtonItem);
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _continueSkipView.continueButtonItem = continueButtonItem;
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    _tableContainer.stepHeaderView.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _continueSkipView.skipButtonItem = self.skipButtonItem;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableContainer.tableView.delegate = nil;
    _tableContainer.tableView.dataSource = nil;
    _continueSkipView = nil;
    
    if ([self reviewStep]) {
        _tableContainer = [[ORKTableContainerView alloc] initWithFrame:self.view.bounds];
        _tableContainer.tableView.delegate = self;
        _tableContainer.tableView.dataSource = self;
        _tableContainer.tableView.clipsToBounds = YES;

        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableContainer.stepHeaderView.captionLabel.useSurveyMode = self.step.useSurveyMode;
        _tableContainer.stepHeaderView.captionLabel.text = [self reviewStep].title;
        _tableContainer.stepHeaderView.instructionLabel.text = [self reviewStep].text;
        _tableContainer.stepHeaderView.learnMoreButtonItem = self.learnMoreButtonItem;
        
        _continueSkipView = _tableContainer.continueSkipContainerView;
        _continueSkipView.skipButtonItem = self.skipButtonItem;
        _continueSkipView.continueEnabled = YES;
        _continueSkipView.continueButtonItem = self.continueButtonItem;
        _continueSkipView.optional = self.step.optional;
        [_tableContainer setNeedsLayout];
    }
}

- (ORKReviewStep *)reviewStep {
    return [self.step isKindOfClass:[ORKReviewStep class]] ? (ORKReviewStep *) self.step : nil;
}

//TODO: state restoration

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return _steps.count > 0 ? ORKReviewSectionCount : 0;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == ORKReviewSectionSpace1 || section == ORKReviewSectionSpace2) ? 1 : _steps.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    tableView.layoutMargins = UIEdgeInsetsZero;
    if (indexPath.section == ORKReviewSectionSpace1 || indexPath.section == ORKReviewSectionSpace2) {
        static NSString *SpaceIdentifier = @"Space";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SpaceIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SpaceIdentifier];
        }
        return cell;
    }
    static NSString *identifier = nil;
    identifier = [NSStringFromClass([self class]) stringByAppendingFormat:@"%@", @(indexPath.row)];
    ORKChoiceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ORKChoiceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.immediateNavigation = YES;
    cell.shortLabel.text = _steps[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.layoutMargins = UIEdgeInsetsZero;
    if (indexPath.section == ORKReviewSectionSpace2) {
        cell.separatorInset = (UIEdgeInsets){.left = ORKScreenMetricMaxDimension};
    } else {
        cell.separatorInset = (UIEdgeInsets){.left = ORKStandardLeftMarginForTableViewCell(tableView)};
    }
}

#pragma mark UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ORKReviewSectionAnswer ? indexPath : nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ORKReviewSectionAnswer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.reviewDelegate respondsToSelector:@selector(reviewStepViewController:willReviewStep:)]) {
        [self.reviewDelegate reviewStepViewController:self willReviewStep:_steps[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [ORKChoiceViewCell suggestedCellHeightForShortText:_steps[indexPath.row].title LongText:@"" inTableView:_tableContainer.tableView];
    return indexPath.section == ORKReviewSectionAnswer ? height : 1;
}

@end

