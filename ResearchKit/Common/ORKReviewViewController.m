/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKReviewViewController.h"
#import "ORKTaskReviewViewController.h"
#import "ORKTaskViewController_Private.h"
#import "ORKStepView_Private.h"
#import "ORKTableContainerView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepContentView_Private.h"
#import "ORKStep.h"
#import "ORKOrderedTask_Private.h"
#import "ORKFormStep.h"
#import "ORKQuestionStep.h"
#import "ORKCollectionResult.h"
#import "ORKQuestionResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKChoiceViewCell_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKReviewIncompleteCell.h"
#import "ORKNavigableOrderedTask.h"

static const float FirstSectionHeaderPadding = 24.0;

@interface ORKReviewViewController () <UITableViewDataSource, UITableViewDelegate, ORKTaskViewControllerDelegate>

@property (nonatomic, nonnull) ORKTableContainerView *tableContainerView;
@property (nonatomic) NSMutableArray<ORKReviewSection *> *reviewSections;
@property (nonatomic) id<ORKTaskResultSource> resultSource;
@property (nonatomic, nonnull) NSArray<ORKStep *> *steps;
@property (nonatomic, strong) ORKNavigableOrderedTask *navigableOrderedTask;
@property (nonatomic, assign) BOOL isCompleted;
@property (nonatomic, strong) NSString *incompleteText;

@end

@implementation ORKReviewViewController {
    ORKStep *_reviewInstructionStep;
    NSString *_currentSectionTitle;
}

- (instancetype)initWithTask:(ORKOrderedTask *)task result:(ORKTaskResult *)result delegate:(nonnull id<ORKReviewViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _steps = task.steps;
        _resultSource = result;
        _delegate = delegate;
        _isCompleted = YES;
        [self createReviewSectionsWithDefaultResultSource:_resultSource];
    }
    return self;
}

- (instancetype)initWithTask:(ORKNavigableOrderedTask *)task delegate:(id<ORKReviewViewControllerDelegate>)delegate isCompleted:(BOOL)isCompleted incompleteText:(NSString *)incompleteText {
    self = [super init];
        if (self) {
            _steps = task.steps;
            _navigableOrderedTask = task;
            _isCompleted = isCompleted;
            _delegate = delegate;
            _incompleteText = incompleteText;
        }
        return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = ORKColor(ORKBackgroundColorKey);
    }

    [self setupTableContainerView];
    
    _tableContainerView.stepTitle = _reviewTitle;
    _tableContainerView.stepText = _text;
    _tableContainerView.stepDetailText = _detailText;
    _tableContainerView.stepTopContentImage = _image;
    _tableContainerView.bodyItems = _bodyItems;
    
    [_tableContainerView.navigationFooterView setHidden:YES];
    [_tableContainerView setNeedsLayout];
}

- (void)setReviewTitle:(NSString *)reviwTitle {
    _reviewTitle = reviwTitle;
    _tableContainerView.stepTitle = reviwTitle;
}

- (void)setText:(NSString *)text {
    _text = text;
    _tableContainerView.stepText = text;
    [_tableContainerView sizeHeaderToFit];
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    _tableContainerView.stepDetailText = detailText;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _tableContainerView.stepTopContentImage = image;
}

- (void)setBodyItems:(NSArray<ORKBodyItem *> *)bodyItems {
    _bodyItems = bodyItems;
    _tableContainerView.bodyItems = bodyItems;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainerView sizeHeaderToFit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableContainerView sizeHeaderToFit];
    [_tableContainerView.tableView reloadData];
    [self.view layoutSubviews];
}

- (void)setupTableContainerView {
    if (!_tableContainerView) {
        _tableContainerView = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        [_tableContainerView layoutIfNeeded];
        _tableContainerView.tableView.dataSource = self;
        _tableContainerView.tableView.delegate = self;
        _tableContainerView.tableView.clipsToBounds = YES;
        _tableContainerView.tableView.rowHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableContainerView.tableView.estimatedSectionHeaderHeight = 30.0;
        _tableContainerView.tableView.estimatedSectionFooterHeight = 30.0;
        _tableContainerView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 13.0, *)) {
            _tableContainerView.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
        } else {
            _tableContainerView.tableView.backgroundColor = ORKColor(ORKBackgroundColorKey);
        }
        
    }
    [self.view addSubview:_tableContainerView];
    _tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_tableContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[_tableContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[_tableContainerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_tableContainerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
}

- (void)createReviewSectionsWithDefaultResultSource:(id<ORKTaskResultSource>)defaultResultSource {
    _reviewSections = nil;
    _reviewSections = [[NSMutableArray alloc] init];
    for (ORKStep *step in _steps) {
        if ([step isKindOfClass:[ORKFormStep class]]) {
            ORKFormStep *formStep = (ORKFormStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:formStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForFormStep:formStep withResult:result]];
            }
        }
        else if ([step isKindOfClass:[ORKQuestionStep class]]) {
            ORKQuestionStep *questionStep = (ORKQuestionStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:questionStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForQuestionStep:questionStep withResult:result]];
            }
        }
    }
}

- (ORKReviewSection *)reviewSectionForFormStep:(ORKFormStep *)formStep withResult:(ORKStepResult *)result {
    if (formStep && formStep.formItems && result) {
        NSMutableArray <ORKReviewItem *> *formReviewItems = [[NSMutableArray alloc] init];
        for (ORKFormItem *formItem in formStep.formItems) {
            if (formItem.answerFormat) {
                ORKResult *formItemResult = [result resultForIdentifier:formItem.identifier];
                ORKReviewItem *formReviewItem = [[ORKReviewItem alloc] init];
                if (formItem.text) {
                    formReviewItem.question = formItem.text;
                } else {
                    // formItem.text will return nil if a question was constructed as follows
                    // - you create a section header with the ORKFormItem(sectionTitle: API
                    // - you then add a ORKFormItem with the relevant answer format and expect it to be grouped under the section title
                    formReviewItem.question = _currentSectionTitle;
                }
                formReviewItem.answer = [self answerStringForFormItem:formItem withFormItemResult:formItemResult];
                [formReviewItems addObject:formReviewItem];
            }
            else {
                // formItem.answerFormat will return nil if a question was constructed as follows
                // - you create a section header with the ORKFormItem(sectionTitle: API
                // - you then add a ORKFormItem with the relevant answer format and expect it to be grouped under the section title
                _currentSectionTitle = formItem.text;
            }
        }
        ORKReviewSection *section = [[ORKReviewSection alloc] init];
        section.title = formStep.title;
        section.text = formStep.text;
        section.stepIdentifier = formStep.identifier;
        section.items = [formReviewItems copy];
        
        return section;
    }
    return nil;
}

- (NSString *)answerStringForFormItem:(ORKFormItem *)formItem withFormItemResult:(ORKResult *)formItemResult {
    NSString *answerString = nil;
    if (formItem && formItemResult && [formItemResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)formItemResult;
        if (formItem.answerFormat && [questionResult isKindOfClass:formItem.answerFormat.questionResultClass] && questionResult.answer) {
            if ([questionResult.answer isKindOfClass:[ORKDontKnowAnswer class]]) {
                answerString = formItem.answerFormat.customDontKnowButtonText;
            } else {
                answerString = [formItem.answerFormat stringForAnswer:questionResult.answer];
            }
        }
    }
    return answerString;
}

- (ORKReviewSection *)reviewSectionForQuestionStep:(ORKQuestionStep *)questionStep withResult:(ORKStepResult *)result {
    ORKReviewItem *item = [[ORKReviewItem alloc] init];
    item.question = questionStep.question;
    if (result.firstResult && [result.firstResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)result.firstResult;
        item.answer = [self answerStringForQuestionStep:questionStep withQuestionResult:questionResult];
    }
    ORKReviewSection *section = [[ORKReviewSection alloc] init];
    section.title = questionStep.title;
    section.text = questionStep.text;
    section.stepIdentifier = questionStep.identifier;
    section.items = @[item];
    
    return section;
    
}

- (NSString *)answerStringForQuestionStep:(ORKQuestionStep *)questionStep withQuestionResult:(ORKQuestionResult *)questionResult {
    NSString *answerString = nil;
    if (questionStep && questionResult && questionStep.answerFormat && [questionResult isKindOfClass:questionStep.answerFormat.questionResultClass] && questionResult.answer) {
        if ([questionResult.answer isKindOfClass:[ORKDontKnowAnswer class]]) {
            answerString = questionStep.answerFormat.customDontKnowButtonText;
        } else {
            answerString = [questionStep.answerFormat stringForAnswer:questionResult.answer];
        }
    }
    return answerString;
}

- (void)updateResultSource:(ORKTaskResult *)result {
    _resultSource = nil;
    _reviewSections = nil;
    
    _resultSource = result;
    _isCompleted = YES;
    [self createReviewSectionsWithDefaultResultSource:_resultSource];
    [_tableContainerView.tableView reloadData];
}

- (void)updateResultSource:(ORKTaskResult *)result forTask:(ORKOrderedTask *)task {
    _steps = task.steps;
    _isCompleted = YES;
    [self updateResultSource:result];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isCompleted == NO) {
        return 1;
    }
    
    return _reviewSections ? _reviewSections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isCompleted == NO) {
        return 1;
    }
    
    return _reviewSections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (_isCompleted == NO) {
        if (cell == nil || ![cell isKindOfClass:ORKReviewIncompleteCell.class]) {
            ORKReviewIncompleteCell *reviewIncompleteCell = [[ORKReviewIncompleteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"incompleteCell"];
            reviewIncompleteCell.text = _incompleteText;
            reviewIncompleteCell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell = reviewIncompleteCell;
        }
    } else {
        if (cell == nil || ![cell isKindOfClass:ORKReviewCell.class]) {
            ORKReviewCell *reviewCell = [[ORKReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell = reviewCell;
        }
        ORKReviewCell *reviewCell = (ORKReviewCell *)cell;
        reviewCell.question = _reviewSections[indexPath.section].items[indexPath.row].question;
        reviewCell.answer = _reviewSections[indexPath.section].items[indexPath.row].answer;
        reviewCell.isLastCell = _reviewSections[indexPath.section].items.count - 1 == indexPath.row;
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_isCompleted == NO) {
        return nil;
    }
    
    UIView *headerView;
    
    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (cardHeaderView == nil) {
        ORKReviewSection *reviewSection = _reviewSections[section];
        cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:reviewSection.title detailText:reviewSection.text learnMoreView:nil progressText:[NSString stringWithFormat:@"%@ %@", ORKLocalizedString(@"REVIEW_STEP_PAGE", nil), ORKLocalizedStringFromNumber(@(section + 1))] tagText:nil showBorder:YES hasMultipleChoiceItem:NO];
    }
    
    // The first section needs extra padding at the top to account for space between the content in
    // the table header and the first review card.
    if (section == 0) {
        UIView *cardHeaderViewWithPadding = [[UIView alloc] init];
        cardHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [cardHeaderViewWithPadding addSubview:cardHeaderView];
        
        [cardHeaderView.leadingAnchor constraintEqualToAnchor:cardHeaderViewWithPadding.leadingAnchor].active = YES;
        [cardHeaderView.trailingAnchor constraintEqualToAnchor:cardHeaderViewWithPadding.trailingAnchor].active = YES;
        [cardHeaderView.bottomAnchor constraintEqualToAnchor:cardHeaderViewWithPadding.bottomAnchor].active = YES;
        [cardHeaderView.topAnchor constraintEqualToAnchor:cardHeaderViewWithPadding.topAnchor constant:FirstSectionHeaderPadding].active = YES;
        
        headerView = cardHeaderViewWithPadding;
    } else {
        headerView = cardHeaderView;
    }
    
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_isCompleted;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_isCompleted == NO) {
        return nil;
    }
    
    ORKReviewSectionFooter *sectionFooter = (ORKReviewSectionFooter *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[NSString stringWithFormat:@"Footer%@", @(section).stringValue]];
    if (!sectionFooter) {
        sectionFooter = [ORKReviewSectionFooter new];
        sectionFooter.button.tag = section;
        [sectionFooter.button addTarget:self action:@selector(footerButtonTappedForSection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return sectionFooter;
}

- (nullable ORKStep *)stepForIdentifier:(NSString *)identifier {
    for (ORKStep *step in _steps) {
        if ([step.identifier isEqualToString:identifier]) {
            return step;
        }
    }
    return nil;
}

- (void)footerButtonTappedForSection:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    ORKOrderedTask *subOrderedTask = [[ORKOrderedTask alloc] initWithIdentifier:[[NSUUID UUID] UUIDString] steps:@[[self stepForIdentifier:_reviewSections[button.tag].stepIdentifier]]];
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:subOrderedTask taskRunUUID:[NSUUID UUID]];
    taskViewController.delegate = self;
    [taskViewController.navigationBar setTranslucent:YES];
    taskViewController.navigationBar.prefersLargeTitles = NO;
    taskViewController.defaultResultSource = _resultSource;
    taskViewController.discardable = YES;
    taskViewController.showsProgressInNavigationBar = NO;
    [self presentViewController:taskViewController animated:YES completion:nil];
}

#pragma mark - UItableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((_isCompleted == NO) && (indexPath.row == 0)) {
        if (_delegate && [_delegate respondsToSelector:@selector(reviewViewControllerDidSelectIncompleteCell:)]) {
            [_delegate reviewViewControllerDidSelectIncompleteCell:self];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - ORKTaskViewControllerDelegate

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    if (reason == ORKTaskViewControllerFinishReasonCompleted) {
        if (_delegate && [_delegate respondsToSelector:@selector(reviewViewController:didUpdateResult:source:)]) {
            ORKTaskResult *taskResult = ORKDynamicCast(_resultSource, ORKTaskResult);
            [_delegate reviewViewController:self didUpdateResult:taskViewController.result source:taskResult];
        }
    }
    [taskViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    stepViewController.shouldPresentInReview = _isCompleted;
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep forStepViewController:(ORKStepViewController *)stepViewController {
    if (_delegate && [_delegate respondsToSelector:@selector(taskViewController:learnMoreButtonPressedWithStep:)]) {
        [_delegate taskViewController:taskViewController learnMoreButtonPressedWithStep:learnMoreStep];
    }
}

@end
