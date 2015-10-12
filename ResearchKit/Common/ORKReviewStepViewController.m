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
#import "ORKTextChoiceCellGroup.h"


typedef NS_ENUM(NSInteger, ORKReviewSection) {
    ORKReviewSectionSpace1 = 0,
    ORKReviewSectionAnswer = 1,
    ORKReviewSectionSpace2 = 2,
    ORKReviewSectionCount
};

@interface ORKReviewStepViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKStepHeaderView *headerView;

@end

@implementation ORKReviewStepViewController {
    ORKNavigationContainerView *_continueSkipView;
    ORKTextChoiceCellGroup *_choiceCellGroup;
    ORKTextChoiceAnswerFormat *_answerFormat;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}
#pragma clang diagnostic pop
 
- (instancetype)initWithReviewStep:(ORKReviewStep *)reviewStep steps:(nullable NSArray *)steps resultSource:(nullable id<ORKTaskResultSource>)resultSource {
    self = [self initWithStep:reviewStep];
    if (self && [self reviewStep]) {
        NSMutableArray *filteredSteps = [[NSMutableArray alloc] init];
        [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BOOL includeStep = [obj isKindOfClass:[ORKQuestionStep class]] || [obj isKindOfClass:[ORKFormStep class]] || [obj isKindOfClass:[ORKInstructionStep class]];
            if (includeStep) {
                [filteredSteps addObject:obj];
            }
        }];
        _steps = [filteredSteps copy];
        _resultSource = resultSource;
    }
    return self;
}

- (void)reviewDataDidChange {
    [_tableView reloadData];
    [_tableContainer setNeedsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reviewDataDidChange];
    [self.taskViewController setRegisteredScrollView:_tableView];
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
    _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _continueSkipView.skipButtonItem = self.skipButtonItem;
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
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;

        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _headerView = _tableContainer.stepHeaderView;
        _headerView.captionLabel.useSurveyMode = self.step.useSurveyMode;
        _headerView.captionLabel.text = [self reviewStep].title;
        _headerView.instructionLabel.text = [self reviewStep].text;
        _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        
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
    if (section == ORKReviewSectionSpace1 || section == ORKReviewSectionSpace2) {
        return 1;
    }
    NSMutableArray *textChoices = [[NSMutableArray alloc] init];
    [_steps enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        ORKStep *step = (ORKStep*) object;
        //TODO: process results
        if (step.title) {
            [textChoices addObject:@[step.title]];
        }
    }];
    _answerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices: textChoices];
    _choiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:_answerFormat answer:nil beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] immediateNavigation:YES];
    return _choiceCellGroup.size;
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
        cell = [_choiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier];
    }
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
    [_choiceCellGroup didSelectCellAtIndexPath:indexPath];
    if ([self.reviewDelegate respondsToSelector:@selector(reviewStepViewController:willReviewStep:)]) {
        [self.reviewDelegate reviewStepViewController:self willReviewStep:_steps[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ORKReviewSectionAnswer ? [self heightForChoiceItemOptionAtIndex:indexPath.row] : 1;
}

- (CGFloat)heightForChoiceItemOptionAtIndex:(NSInteger)index {
    ORKTextChoice *option = [(ORKTextChoiceAnswerFormat *)_answerFormat textChoices][index];
    CGFloat height = [ORKChoiceViewCell suggestedCellHeightForShortText:option.text LongText:option.detailText inTableView:_tableView];
    return height;
}

@end

