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


#import "ORKQuestionStepViewController.h"
#import "ORKDefines_Private.h"
#import "ORKResult.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKStepViewController_Internal.h"

#import "ORKChoiceViewCell.h"
#import "ORKSurveyAnswerCellForScale.h"
#import "ORKSurveyAnswerCellForNumber.h"
#import "ORKSurveyAnswerCellForText.h"
#import "ORKSurveyAnswerCellForPicker.h"
#import "ORKSurveyAnswerCellForImageSelection.h"
#import "ORKSurveyAnswerCellForLocation.h"
#import "ORKAnswerFormat.h"
#import "ORKHelpers.h"
#import "ORKCustomStepView.h"
#import "ORKVerticalContainerView.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStepViewController_Private.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKTableContainerView.h"
#import "ORKStep_Private.h"
#import "ORKTextChoiceCellGroup.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKQuestionStepView.h"


typedef NS_ENUM(NSInteger, ORKQuestionSection) {
    ORKQuestionSectionAnswer = 0,
    ORKQuestionSection_COUNT
};


@interface ORKQuestionStepViewController () <UITableViewDataSource,UITableViewDelegate, ORKSurveyAnswerCellDelegate> {
    id _answer;
    
    ORKTableContainerView *_tableContainer;
    ORKStepHeaderView *_headerView;
    ORKNavigationContainerView *_continueSkipView;
    ORKAnswerDefaultSource *_defaultSource;
    
    NSCalendar *_savedSystemCalendar;
    NSTimeZone *_savedSystemTimeZone;
    
    ORKTextChoiceCellGroup *_choiceCellGroup;
    
    id _defaultAnswer;
    
    BOOL _visible;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKQuestionStepView *questionView;

@property (nonatomic, strong) ORKAnswerFormat *answerFormat;
@property (nonatomic, copy) id<NSCopying, NSObject, NSCoding> answer;

@property (nonatomic, strong) ORKContinueButton *continueActionButton;

@property (nonatomic, strong) ORKSurveyAnswerCell *answerCell;

@property (nonatomic, readonly) UILabel *questionLabel;
@property (nonatomic, readonly) UILabel *promptLabel;

// If `hasChangedAnswer`, then a new `defaultAnswer` should not change the answer
@property (nonatomic, assign) BOOL hasChangedAnswer;

@end


@implementation ORKQuestionStepViewController

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    self.internalSkipButtonItem.title = ORKLocalizedString(@"BUTTON_SKIP_QUESTION", nil);
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [self initWithStep:step];
    if (self) {
		ORKStepResult *stepResult = (ORKStepResult *)result;
		if (stepResult && [stepResult results].count > 0) {
            ORKQuestionResult *questionResult = ORKDynamicCast([stepResult results].firstObject, ORKQuestionResult);
            id answer = [questionResult answer];
            if (questionResult != nil && answer == nil) {
                answer = ORKNullAnswerValue();
            }
			self.answer = answer;
		}
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        _defaultSource = [ORKAnswerDefaultSource sourceWithHealthStore:[HKHealthStore new]];
    }
    return self;
}

- (void)stepDidChange {
    [super stepDidChange];
    _answerFormat = [self.questionStep impliedAnswerFormat];
    
    self.hasChangedAnswer = NO;
    
    if ([self isViewLoaded]) {
        [_tableContainer removeFromSuperview];
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
        _tableView = nil;
        _headerView = nil;
        _continueSkipView = nil;
        
        [_questionView removeFromSuperview];
        _questionView = nil;
        
        if ([self.questionStep formatRequiresTableView] && !_customQuestionView) {
            _tableContainer = [[ORKTableContainerView alloc] initWithFrame:self.view.bounds];
            
            // Create a new one (with correct style)
            _tableView = _tableContainer.tableView;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.clipsToBounds = YES;
            
            [self.view addSubview:_tableContainer];
            _tableContainer.tapOffView = self.view;
            
            _headerView = _tableContainer.stepHeaderView;
            _headerView.captionLabel.useSurveyMode = self.step.useSurveyMode;
            _headerView.captionLabel.text = self.questionStep.title;
            _headerView.instructionLabel.text = self.questionStep.text;
            _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
            
            _continueSkipView = _tableContainer.continueSkipContainerView;
            _continueSkipView.skipButtonItem = self.skipButtonItem;
            _continueSkipView.continueEnabled = [self continueButtonEnabled];
            _continueSkipView.continueButtonItem = self.continueButtonItem;
            _continueSkipView.optional = self.step.optional;
            [_tableContainer setNeedsLayout];
        } else if (self.step) {
            _questionView = [ORKQuestionStepView new];
            _questionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
            _questionView.questionStep = [self questionStep];
            [self.view addSubview:_questionView];
            
            if (_customQuestionView) {
                _questionView.questionCustomView = _customQuestionView;
                _customQuestionView.delegate = self;
                _customQuestionView.answer = [self answer];
            } else {
                ORKQuestionStepCellHolderView *cellHolderView = [ORKQuestionStepCellHolderView new];
                cellHolderView.delegate = self;
                cellHolderView.cell = [self answerCellForTableView:nil];
                [NSLayoutConstraint activateConstraints:
                 [cellHolderView.cell suggestedCellHeightConstraintsForView:self.parentViewController.view]];
                cellHolderView.answer = [self answer];
                
                _questionView.questionCustomView = cellHolderView;
            }
            
            _questionView.translatesAutoresizingMaskIntoConstraints = NO;
            _questionView.continueSkipContainer.continueButtonItem = self.continueButtonItem;
            _questionView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
            _questionView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
            _questionView.continueSkipContainer.continueEnabled = [self continueButtonEnabled];
            
            NSMutableArray *constraints = [NSMutableArray new];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[questionView]|"
                                                                                     options:(NSLayoutFormatOptions)0
                                                                                     metrics:nil
                                                                                       views:@{@"questionView": _questionView}]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide][questionView][bottomGuide]"
                                                                                     options:(NSLayoutFormatOptions)0
                                                                                     metrics:nil
                                                                                       views:@{@"questionView": _questionView,
                                                                                               @"topGuide": self.topLayoutGuide,
                                                                                               @"bottomGuide": self.bottomLayoutGuide}]];
            for (NSLayoutConstraint *constraint in constraints) {
                constraint.priority = UILayoutPriorityRequired;
            }
            [NSLayoutConstraint activateConstraints:constraints];
        }
    }
    
    if ([self allowContinue] == NO) {
        self.continueButtonItem  = self.internalContinueButtonItem;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stepDidChange];
    
}

- (void)showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (self.answer == ORKNullAnswerValue()) {
        return;
    }
    
    [super showValidityAlertWithMessage:text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_tableView) {
        [self.taskViewController setRegisteredScrollView:_tableView];
    }
    if (_questionView) {
        [self.taskViewController setRegisteredScrollView:_questionView];
    }
    
    NSMutableSet *types = [NSMutableSet set];
    ORKAnswerFormat *format = [[self questionStep] answerFormat];
    HKObjectType *objType = [format healthKitObjectType];
    if (objType) {
        [types addObject:objType];
    }
    
    BOOL scheduledRefresh = NO;
    if (types.count) {
        NSSet<HKObjectType *> *alreadyRequested = [[self taskViewController] requestedHealthTypesForRead];
        if (![types isSubsetOfSet:alreadyRequested]) {
            scheduledRefresh = YES;
            [_defaultSource.healthStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self refreshDefaults];
                    });
                }
            }];
        }
    }
    if (!scheduledRefresh) {
        [self refreshDefaults];
    }
    
    [_tableContainer layoutIfNeeded];
}

- (void)answerDidChange {
    if ([self.questionStep formatRequiresTableView] && !_customQuestionView) {
        [self.tableView reloadData];
    } else {
        if (_customQuestionView) {
            _customQuestionView.answer = _answer;
        } else {
            ORKQuestionStepCellHolderView *holder = (ORKQuestionStepCellHolderView *)_questionView.questionCustomView;
            holder.answer = _answer;
            [self.answerCell setAnswer:_answer];
        }
    }
    [self updateButtonStates];
}

- (void)refreshDefaults {
    [_defaultSource fetchDefaultValueForAnswerFormat:[[self questionStep] answerFormat] handler:^(id defaultValue, NSError *error) {
        if (defaultValue != nil || error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _defaultAnswer = defaultValue;
                [self defaultAnswerDidChange];
            });
        } else {
            ORK_Log_Warning(@"Error fetching default: %@", error);
        }
    }];
}

- (void)defaultAnswerDidChange {
    id defaultAnswer = _defaultAnswer;
    if (![self hasAnswer] && defaultAnswer && !self.hasChangedAnswer) {
        _answer = defaultAnswer;
        
        [self answerDidChange];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Delay creating the date picker until the view has appeared (to avoid animation stutter)
    ORKSurveyAnswerCellForPicker *cell = (ORKSurveyAnswerCellForPicker *)[(ORKQuestionStepCellHolderView *)_questionView.questionCustomView cell];
    if ([cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]]) {
        [cell loadPicker];
    }
    
    _visible = YES;
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.leftBarButtonItem);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _visible = NO;
}

- (void)setCustomQuestionView:(ORKQuestionStepCustomView *)customQuestionView {
    [_customQuestionView removeFromSuperview];
    _customQuestionView = customQuestionView;
    if ([_customQuestionView constraints].count == 0) {
        _customQuestionView.translatesAutoresizingMaskIntoConstraints = NO;

        CGSize requiredSize = [_customQuestionView sizeThatFits:(CGSize){self.view.bounds.size.width, CGFLOAT_MAX}];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_customQuestionView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1.0
                                                                            constant:requiredSize.width];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_customQuestionView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:requiredSize.height];
        
        widthConstraint.priority = UILayoutPriorityDefaultLow;
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [NSLayoutConstraint activateConstraints:@[widthConstraint, heightConstraint]];
    }
    [self stepDidChange];
}

- (void)updateButtonStates {
    if ([self isStepImmediateNavigation]) {
        _continueSkipView.neverHasContinueButton = YES;
        _continueSkipView.continueButtonItem = nil;
    }
    _questionView.continueSkipContainer.continueEnabled = [self continueButtonEnabled];
    _continueSkipView.continueEnabled = [self continueButtonEnabled];
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _questionView.continueSkipContainer.continueButtonItem = continueButtonItem;
    _continueSkipView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem {
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
    _questionView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    _questionView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
    _continueSkipView.skipButtonItem = self.skipButtonItem;
    [self updateButtonStates];
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    ORKQuestionStep *questionStep = self.questionStep;
    
    if (self.answer) {
        ORKQuestionResult *result = [questionStep.answerFormat resultWithIdentifier:questionStep.identifier answer:self.answer];
        ORKAnswerFormat *impliedAnswerFormat = [questionStep impliedAnswerFormat];
        
        if ([impliedAnswerFormat isKindOfClass:[ORKDateAnswerFormat class]]) {
            ORKDateQuestionResult *dateQuestionResult = (ORKDateQuestionResult *)result;
            if (dateQuestionResult.dateAnswer) {
                NSCalendar *usedCalendar = [(ORKDateAnswerFormat *)impliedAnswerFormat calendar]? : _savedSystemCalendar;
                dateQuestionResult.calendar = [NSCalendar calendarWithIdentifier:usedCalendar.calendarIdentifier ? : [NSCalendar currentCalendar].calendarIdentifier];
                dateQuestionResult.timeZone = _savedSystemTimeZone? : [NSTimeZone systemTimeZone];
            }
        } else if ([impliedAnswerFormat isKindOfClass:[ORKNumericAnswerFormat class]]) {
            ORKNumericQuestionResult *nqr = (ORKNumericQuestionResult *)result;
            nqr.unit = [(ORKNumericAnswerFormat *)impliedAnswerFormat unit];
        }
        
        result.startDate = parentResult.startDate;
        result.endDate = parentResult.endDate;
        
        parentResult.results = @[result];
    }
    
    return parentResult;
}

#pragma mark - Internal

- (ORKQuestionStep *)questionStep {
    assert(!self.step || [self.step isKindOfClass:[ORKQuestionStep class]]);
    return (ORKQuestionStep *)self.step;
}

- (BOOL)hasAnswer {
    return !ORKIsAnswerEmpty(self.answer);
}

- (void)saveAnswer:(id)answer {
    self.answer = answer;
    _savedSystemCalendar = [NSCalendar currentCalendar];
    _savedSystemTimeZone = [NSTimeZone systemTimeZone];
    [self notifyDelegateOnResultChange];
}

- (void)skipForward {
    // Null out the answer before proceeding
    [self saveAnswer:ORKNullAnswerValue()];
    ORKSurveyAnswerCell *cell = self.answerCell;
    cell.answer = ORKNullAnswerValue();
    
    [super skipForward];
}

- (void)notifyDelegateOnResultChange {
    [super notifyDelegateOnResultChange];
    
    if (self.hasNextStep == NO) {
        self.continueButtonItem = self.internalDoneButtonItem;
    } else {
        self.continueButtonItem = self.internalContinueButtonItem;
    }
    
    self.skipButtonItem = self.internalSkipButtonItem;
    if (!self.questionStep.optional) {
        self.skipButtonItem = nil;
    }

    if ([self allowContinue] == NO) {
        self.continueButtonItem  = self.internalContinueButtonItem;
    }
    
    [self.tableView reloadData];
}

- (id<NSCopying, NSCoding, NSObject>)answer {
    if (self.questionStep.questionType == ORKQuestionTypeMultipleChoice && (_answer == nil || _answer == ORKNullAnswerValue())) {
        _answer = [NSMutableArray array];
    }
    return _answer;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
}

- (BOOL)continueButtonEnabled {
    return ([self hasAnswer] || (self.questionStep.optional && !self.skipButtonItem));
}

- (BOOL)allowContinue {
    return !(self.questionStep.optional == NO && [self hasAnswer] == NO);
}

// Not to use `ImmediateNavigation` when current step already has an answer.
// So user is able to review the answer when it is present.
- (BOOL)isStepImmediateNavigation {
    return [self.questionStep isFormatImmediateNavigation] && [self hasAnswer] == NO;
}

#pragma mark - ORKQuestionStepCustomViewDelegate

- (void)customQuestionStepView:(ORKQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(id)answer; {
    [self saveAnswer:answer];
    self.hasChangedAnswer = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ORKQuestionSection_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ORKAnswerFormat *impliedAnswerFormat = [_answerFormat impliedAnswerFormat];
    
    if (section == ORKQuestionSectionAnswer) {
        if (_choiceCellGroup == nil) {
            _choiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)impliedAnswerFormat
                                                                                       answer:self.answer
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                                          immediateNavigation:[self isStepImmediateNavigation]];
        }
        return _choiceCellGroup.size;
    }
    return 0;
}

- (ORKSurveyAnswerCell *)answerCellForTableView:(UITableView *)tableView {
    static NSDictionary *typeAndCellMapping = nil;
    static NSString *identifier = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeAndCellMapping = @{@(ORKQuestionTypeScale): [ORKSurveyAnswerCellForScale class],
                               @(ORKQuestionTypeDecimal) : [ORKSurveyAnswerCellForNumber class],
                               @(ORKQuestionTypeText) : [ORKSurveyAnswerCellForText class],
                               @(ORKQuestionTypeTimeOfDay) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDate) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDateAndTime) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeTimeInterval) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeInteger) : [ORKSurveyAnswerCellForNumber class],
                               @(ORKQuestionTypeLocation) : [ORKSurveyAnswerCellForLocation class]};
    });
    
    // SingleSelectionPicker Cell && Other Cells
    Class class = typeAndCellMapping[@(self.questionStep.questionType)];
    
    if ([self.questionStep isFormatChoiceWithImageOptions]) {
        class = [ORKSurveyAnswerCellForImageSelection class];
    } else if ([self.questionStep isFormatTextfield]) {
        // Override for single-line text entry
        class = [ORKSurveyAnswerCellForTextField class];
    } else if ([[self.questionStep impliedAnswerFormat] isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
        class = [ORKSurveyAnswerCellForPicker class];
    }
    
    identifier = NSStringFromClass(class);
    
    NSAssert(class != nil, @"class should not be nil");
    
    ORKSurveyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) { 
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier step:[self questionStep] answer:self.answer delegate:self];
    }
    
    self.answerCell = cell;
    
    if ([self.questionStep isFormatTextfield] ||
        [cell isKindOfClass:[ORKSurveyAnswerCellForScale class]] ||
        [cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]]) {
        cell.separatorInset = UIEdgeInsetsMake(0, ORKScreenMetricMaxDimension, 0, 0);
    }

    if ([cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]] && _visible) {
        [(ORKSurveyAnswerCellForPicker *)cell loadPicker];
    }
    
    return cell;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.layoutMargins = UIEdgeInsetsZero;
    
    //////////////////////////////////
    // Section for Answer Area
    //////////////////////////////////
    
    static NSString *identifier = nil;

    assert (self.questionStep.isFormatFitsChoiceCells);
    
    identifier = [NSStringFromClass([self class]) stringByAppendingFormat:@"%@", @(indexPath.row)];
    
    ORKChoiceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [_choiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = (UIEdgeInsets){.left = ORKStandardLeftMarginForTableViewCell(tableView)};
}

- (BOOL)shouldContinue {
    ORKSurveyAnswerCell *cell = self.answerCell;
    if (!cell) {
        return YES;
    }

    return [cell shouldContinue];
}

- (void)goForward {
    if (![self shouldContinue]) {
        return;
    }
    
    [self notifyDelegateOnResultChange];
    [super goForward];
}

- (void)goBackward {
    [self notifyDelegateOnResultChange];
    [super goBackward];
}

- (void)continueAction:(id)sender {
    if (self.continueActionButton.enabled) {
        if (![self shouldContinue]) {
            return;
        }
        
        ORKSuppressPerformSelectorWarning(
                                          [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
    }
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != ORKQuestionSectionAnswer) {
        return nil;
    }
    if (NO == self.questionStep.isFormatFitsChoiceCells) {
        return nil;
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ORKQuestionSectionAnswer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_choiceCellGroup didSelectCellAtIndexPath:indexPath];
    
    // Capture `isStepImmediateNavigation` before saving an answer.
    BOOL immediateNavigation = [self isStepImmediateNavigation];
    
    id answer = (self.questionStep.questionType == ORKQuestionTypeBoolean) ? [_choiceCellGroup answerForBoolean] :[_choiceCellGroup answer];
    
    [self saveAnswer:answer];
    self.hasChangedAnswer = YES;
    
    if (immediateNavigation) {
        // Proceed as continueButton tapped
        ORKSuppressPerformSelectorWarning(
                                         [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [ORKSurveyAnswerCell suggestedCellHeightForView:tableView];
    
    switch (self.questionStep.questionType) {
        case ORKQuestionTypeSingleChoice:
        case ORKQuestionTypeMultipleChoice:{
            if ([self.questionStep isFormatFitsChoiceCells]) {
                height = [self heightForChoiceItemOptionAtIndex:indexPath.row];
            } else {
                height = [ORKSurveyAnswerCellForPicker suggestedCellHeightForView:tableView];
            }
        }
            break;
        case ORKQuestionTypeInteger:
        case ORKQuestionTypeDecimal:{
            height = [ORKSurveyAnswerCellForNumber suggestedCellHeightForView:tableView];
        }
            break;
        case ORKQuestionTypeText:{
            height = [ORKSurveyAnswerCellForText suggestedCellHeightForView:tableView];
        }
            break;
        case ORKQuestionTypeTimeOfDay:
        case ORKQuestionTypeTimeInterval:
        case ORKQuestionTypeDate:
        case ORKQuestionTypeDateAndTime:{
            height = [ORKSurveyAnswerCellForPicker suggestedCellHeightForView:tableView];
        }
            break;
        default:{
        }
            break;
    }
    
    return height;
}

- (CGFloat)heightForChoiceItemOptionAtIndex:(NSInteger)index {
    ORKTextChoice *option = [(ORKTextChoiceAnswerFormat *)_answerFormat textChoices][index];
    CGFloat height = [ORKChoiceViewCell suggestedCellHeightForShortText:option.text LongText:option.detailText inTableView:_tableView];
    return height;
}

#pragma mark - ORKSurveyAnswerCellDelegate

- (void)answerCell:(ORKSurveyAnswerCell *)cell answerDidChangeTo:(id)answer dueUserAction:(BOOL)dueUserAction {
    [self saveAnswer:answer];
    
    if (self.hasChangedAnswer == NO && dueUserAction == YES) {
        self.hasChangedAnswer = YES;
    }
}

- (void)answerCell:(ORKSurveyAnswerCell *)cell invalidInputAlertWithMessage:(NSString *)input {
    [self showValidityAlertWithMessage:input];
}

- (void)answerCell:(ORKSurveyAnswerCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showValidityAlertWithTitle:title message:message];
}

static NSString *const _ORKAnswerRestoreKey = @"answer";
static NSString *const _ORKHasChangedAnswerRestoreKey = @"hasChangedAnswer";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_answer forKey:_ORKAnswerRestoreKey];
    [coder encodeBool:_hasChangedAnswer forKey:_ORKHasChangedAnswerRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.answer = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class],[NSString class],[NSDateComponents class],[NSArray class], nil] forKey:_ORKAnswerRestoreKey];
    self.hasChangedAnswer = [coder decodeBoolForKey:_ORKHasChangedAnswerRestoreKey];
    
    [self answerDidChange];
}

@end
