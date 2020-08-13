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


#import "ORKQuestionStepViewController_Private.h"

#import "ORKChoiceViewCell_Internal.h"
#import "ORKQuestionStepView.h"
#import "ORKLearnMoreView.h"
#import "ORKLearnMoreStepViewController.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKSurveyAnswerCellForScale.h"
#import "ORKSurveyAnswerCellForNumber.h"
#import "ORKSurveyAnswerCellForText.h"
#import "ORKSurveyAnswerCellForPicker.h"
#import "ORKSurveyAnswerCellForImageSelection.h"
#import "ORKSurveyAnswerCellForLocation.h"
#import "ORKSurveyAnswerCellForSES.h"
#import "ORKTableContainerView.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKTextChoiceCellGroup.h"
#import "ORKBodyItem.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKCollectionResult_Private.h"
#import "ORKQuestionResult_Private.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"
#import "ORKStepContentView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


typedef NS_ENUM(NSInteger, ORKQuestionSection) {
    ORKQuestionSectionAnswer = 0,
    ORKQuestionSection_COUNT
};

static const CGFloat DelayBeforeAutoScroll = 0.25;

@interface ORKQuestionStepViewController () <UITableViewDataSource, UITableViewDelegate, ORKSurveyAnswerCellDelegate, ORKTextChoiceCellGroupDelegate, ORKChoiceOtherViewCellDelegate, ORKTableContainerViewDelegate, ORKLearnMoreViewDelegate> {
    id _answer;
    
    ORKTableContainerView *_tableContainer;
    ORKStepContentView *_headerView;
    ORKAnswerDefaultSource *_defaultSource;
    
    NSCalendar *_savedSystemCalendar;
    NSTimeZone *_savedSystemTimeZone;
    
    ORKTextChoiceCellGroup *_choiceCellGroup;
    ORKQuestionStepCellHolderView *_cellHolderView;
    
    id _defaultAnswer;
    
    BOOL _visible;
    UITableViewCell *_currentFirstResponderCell;
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

@property (nonatomic, copy) id<NSCopying, NSObject, NSCoding> originalAnswer;

@end


@implementation ORKQuestionStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    self.internalSkipButtonItem.title = ORKLocalizedString(@"BUTTON_SKIP", nil);
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
            self.originalAnswer = answer;
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
        BOOL neediPadDesign = ORKNeedWideScreenDesign(self.view);
        [_tableContainer removeFromSuperview];
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
        _tableView = nil;
        _headerView = nil;
        _cellHolderView = nil;
        _navigationFooterView = nil;
        [_questionView removeFromSuperview];
        _questionView = nil;

        if ([self.questionStep formatRequiresTableView] && !_customQuestionView) {
            _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
            
            // Create a new one (with correct style)
            _tableView = _tableContainer.tableView;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.clipsToBounds = YES;
            
            _navigationFooterView = _tableContainer.navigationFooterView;
            [self setNavigationFooterButtonItems];
            
            [self.view addSubview:_tableContainer];
            _tableContainer.tapOffView = self.view;
            
            _headerView = _tableContainer.stepContentView;
            if (self.questionStep.useCardView) {
                _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                if (@available(iOS 13.0, *)) {
                    [_tableView setBackgroundColor:UIColor.systemGroupedBackgroundColor];
                } else {
                    [_tableView setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
                }
                [self.taskViewController.navigationBar setBarTintColor:[_tableView backgroundColor]];
                [self.view setBackgroundColor:[_tableView backgroundColor]];
            }
            
            _headerView.stepTopContentImage = self.step.image;
            _headerView.titleIconImage = self.step.iconImage;
            _headerView.stepTitle = self.step.title;
            _headerView.stepText = self.step.text;
            // TODO:- we are currently not setting detailText to _headerView because we are restricting detailText to be displayed only inside ORKSurveyCardHeaderView, might wanna rethink this later. Please use the text property on ORKQuestionStep for adding extra information.
            _headerView.stepHeaderTextAlignment = self.step.headerTextAlignment;
            _headerView.bodyItems = self.step.bodyItems;
            _tableContainer.stepTopContentImageContentMode = self.step.imageContentMode;
            _navigationFooterView.optional = self.step.optional;
            if (self.readOnlyMode) {
                _navigationFooterView.optional = YES;
                [_navigationFooterView setNeverHasContinueButton:YES];
                _navigationFooterView.skipEnabled = [self skipButtonEnabled];
                _navigationFooterView.skipButton.accessibilityTraits = UIAccessibilityTraitStaticText;
            }
            if (neediPadDesign) {
                [_tableContainer setBackgroundColor:[UIColor clearColor]];
                [_tableView setBackgroundColor:[UIColor clearColor]];
            }
            [self setupConstraints:_tableContainer];
            [_tableContainer setNeedsLayout];
            
            // Question steps should always force the navigation controller to be scrollable
            // therefore we should always remove the styling.
            [_navigationFooterView removeStyling];
        } else if (self.step) {
            _questionView = [ORKQuestionStepView new];
            ORKQuestionStep *questionStep = (ORKQuestionStep *)self.step;
            
            if (questionStep && questionStep.questionType == ORKQuestionTypeScale) {
                id<ORKScaleAnswerFormatProvider> formatProvider = (id<ORKScaleAnswerFormatProvider>)[questionStep impliedAnswerFormat];
                
                if (formatProvider && [formatProvider isVertical]) {
                   [_questionView placeNavigationContainerInsideScrollView];
                }
            }
            
            ORKQuestionStep *step = [self questionStep];
            _navigationFooterView = _questionView.navigationFooterView;
            [self setNavigationFooterButtonItems];
            _navigationFooterView.useNextForSkip = (step ? NO : YES);
            _questionView.questionStep = step;
            _navigationFooterView.optional = step.optional;
            [_navigationFooterView updateContinueAndSkipEnabled];
            
            [self.view addSubview:_questionView];
            if (_customQuestionView) {
                _questionView.questionCustomView = _customQuestionView;
                _customQuestionView.delegate = self;
                _customQuestionView.answer = [self answer];
                _customQuestionView.userInteractionEnabled = !self.readOnlyMode;
            } else {
                _cellHolderView = [ORKQuestionStepCellHolderView new];
                _cellHolderView.delegate = self;
                _cellHolderView.cell = [self answerCellForTableView:nil];
                [NSLayoutConstraint activateConstraints:
                 [_cellHolderView.cell suggestedCellHeightConstraintsForView:self.parentViewController.view]];
                _cellHolderView.answer = [self answer];
                _cellHolderView.userInteractionEnabled = !self.readOnlyMode;
                if (self.questionStep.useCardView) {
                    if (@available(iOS 13.0, *)) {
                        [_questionView setBackgroundColor:UIColor.systemGroupedBackgroundColor];
                    } else {
                        [_questionView setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
                    }
                    [self.taskViewController.navigationBar setBarTintColor:[_questionView backgroundColor]];
                    [self.view setBackgroundColor:[_questionView backgroundColor]];
                    ORKLearnMoreView *learnMoreView;
                    NSString *sectionProgressText = nil;
                    
                    if (self.step.showsProgress) {
                        if ([self.delegate respondsToSelector:@selector(stepViewControllerTotalProgressInfoForStep:currentStep:)]) {
                            ORKTaskTotalProgress progressInfo = [self.delegate stepViewControllerTotalProgressInfoForStep:self currentStep:self.step];
                            if (progressInfo.stepShouldShowTotalProgress) {
                                sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(progressInfo.currentStepStartingProgressPosition)), ORKLocalizedStringFromNumber(@(progressInfo.total))];
                            }
                        }
                    }
                    
                    if (self.questionStep.learnMoreItem) {
                        learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:self.questionStep.learnMoreItem];
                        learnMoreView.delegate = self;
                    }
                    
                    BOOL hasMultipleChoiceFormItem = NO;
                    if (self.questionStep.impliedAnswerFormat != nil && self.questionStep.impliedAnswerFormat.questionType == ORKQuestionTypeMultipleChoice) {
                        hasMultipleChoiceFormItem = YES;
                    }
                    
                    [_cellHolderView useCardViewWithTitle:self.questionStep.question detailText:self.step.detailText learnMoreView:learnMoreView progressText:sectionProgressText tagText:self.questionStep.tagText hasMultipleChoiceFormItem:hasMultipleChoiceFormItem];
                }
                _questionView.questionCustomView = _cellHolderView;
            }
            
            _questionView.translatesAutoresizingMaskIntoConstraints = NO;
            [_questionView removeCustomContentPadding];
            
            if (self.readOnlyMode) {
                _navigationFooterView.optional = YES;
                [_navigationFooterView setNeverHasContinueButton:YES];
                _navigationFooterView.skipEnabled = [self skipButtonEnabled];
                _navigationFooterView.skipButton.accessibilityTraits = UIAccessibilityTraitStaticText;
            }
            if (neediPadDesign) {
                [_questionView setBackgroundColor:[UIColor clearColor]];
            }
            [self setupConstraints:_questionView];
        }
    }
    
    if ([self allowContinue] == NO) {
        self.continueButtonItem  = self.internalContinueButtonItem;
    }
}

- (void)setNavigationFooterButtonItems {
    if (_navigationFooterView) {
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_tableContainer) {
        [_tableContainer sizeHeaderToFit];
        [_tableContainer resizeFooterToFit];
    }
}

- (void)setupConstraints:(UIView *)view {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }

    view.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;

    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:view
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:view
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:view
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:view
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self stepDidChange];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (self.answer == ORKNullAnswerValue()) {
        return NO;
    }
    
    return [super showValidityAlertWithMessage:text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_tableView) {
        [self.taskViewController setRegisteredScrollView:_tableView];
    }
    
    
    NSMutableSet *types = [NSMutableSet set];
    ORKAnswerFormat *format = [[self questionStep] answerFormat];
    HKObjectType *objType = [format healthKitObjectTypeForAuthorization];
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
    
    if (_tableContainer) {
        [_tableContainer sizeHeaderToFit];
        [_tableContainer resizeFooterToFit];
        [_tableContainer layoutIfNeeded];
    }
    
    if (_tableView) {
        [_tableView reloadData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
            ORK_Log_Error("Error fetching default: %@", error);
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
    
    _visible = YES;
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
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
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_customQuestionView
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1.0
                                                                             constant:requiredSize.height];
        
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [NSLayoutConstraint activateConstraints:@[heightConstraint]];
    }
    [self stepDidChange];
}

- (void)updateButtonStates {
    if ([self isStepImmediateNavigation]) {
//        _navigationFooterView.neverHasContinueButton = YES;
//        _navigationFooterView.continueButtonItem = nil;
    }
    _navigationFooterView.continueEnabled = [self continueButtonEnabled];
    _navigationFooterView.skipEnabled = [self skipButtonEnabled];
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}


- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    _navigationFooterView.skipButtonItem = self.skipButtonItem;
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
                NSCalendar *usedCalendar = [(ORKDateAnswerFormat *)impliedAnswerFormat calendar] ? : _savedSystemCalendar;
                dateQuestionResult.calendar = [NSCalendar calendarWithIdentifier:usedCalendar.calendarIdentifier ? : [NSCalendar currentCalendar].calendarIdentifier];
                dateQuestionResult.timeZone = _savedSystemTimeZone ? : [NSTimeZone systemTimeZone];
            }
        } else if ([impliedAnswerFormat isKindOfClass:[ORKNumericAnswerFormat class]]) {
            ORKNumericQuestionResult *nqr = (ORKNumericQuestionResult *)result;
            if (nqr.unit == nil) {
                nqr.unit = [(ORKNumericAnswerFormat *)impliedAnswerFormat unit];
            }
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
    if (!self.questionStep.optional && !self.readOnlyMode) {
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
    BOOL enabled = ([self hasAnswer] || (self.questionStep.optional && !self.skipButtonItem));
    if (self.isBeingReviewed) {
        enabled = enabled && (![self.answer isEqual:self.originalAnswer]);
    }
    return enabled;
}

- (BOOL)skipButtonEnabled {
    BOOL enabled = [self questionStep].optional;
    if (self.isBeingReviewed) {
        enabled = self.readOnlyMode ? NO : enabled && !ORKIsAnswerEmpty(self.originalAnswer);
    }
    return enabled;
}

- (BOOL)allowContinue {
    return !(self.questionStep.optional == NO && [self hasAnswer] == NO);
}

// Not to use `ImmediateNavigation` when current step already has an answer.
// So user is able to review the answer when it is present.
- (BOOL)isStepImmediateNavigation {
    // FIXME: - add explicit property in QuestionStep to dictate this behavior
//    return [self.questionStep isFormatImmediateNavigation] && [self hasAnswer] == NO && !self.isBeingReviewed;
    return NO;
}

#pragma mark NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    
    if (CGRectGetMaxY(_currentFirstResponderCell.frame) >= CGRectGetMinY(convertedKeyboardFrame)) {
        
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(convertedKeyboardFrame) - CGRectGetHeight(_currentFirstResponderCell.frame), 0)];
        
        NSIndexPath *currentFirstResponderCellIndex = [self.tableView indexPathForCell:_currentFirstResponderCell];
        
        if (currentFirstResponderCellIndex) {
            [self.tableView scrollToRowAtIndexPath:currentFirstResponderCellIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView setContentInset:UIEdgeInsetsZero];
}

#pragma mark - ORKQuestionStepCustomViewDelegate

- (void)customQuestionStepView:(ORKQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(id)answer {
    [self saveAnswer:answer];
    self.hasChangedAnswer = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ORKQuestionSection_COUNT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([self questionStep].useCardView && [self questionStep].question) {
        ORKLearnMoreView *learnMoreView;
        NSString *sectionProgressText = nil;
        BOOL hasMultipleChoiceFormItem = NO;
        
        if (self.step.showsProgress) {
            if ([self.delegate respondsToSelector:@selector(stepViewControllerTotalProgressInfoForStep:currentStep:)]) {
                ORKTaskTotalProgress progressInfo = [self.delegate stepViewControllerTotalProgressInfoForStep:self currentStep:self.step];
                if (progressInfo.stepShouldShowTotalProgress) {
                    sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + progressInfo.currentStepStartingProgressPosition)), ORKLocalizedStringFromNumber(@(progressInfo.total))];
                }
            }
        }
        
        if (self.questionStep.learnMoreItem) {
            learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:self.questionStep.learnMoreItem];
            learnMoreView.delegate = self;
        }
        
        if (self.questionStep.impliedAnswerFormat != nil && self.questionStep.impliedAnswerFormat.questionType == ORKQuestionTypeMultipleChoice) {
            hasMultipleChoiceFormItem = YES;
        }

        return [[ORKSurveyCardHeaderView alloc] initWithTitle:self.questionStep.question detailText:self.questionStep.detailText  learnMoreView:learnMoreView progressText:sectionProgressText tagText:self.questionStep.tagText showBorder:NO hasMultipleChoiceItem:hasMultipleChoiceFormItem];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ORKAnswerFormat *impliedAnswerFormat = [_answerFormat impliedAnswerFormat];
    
    if (section == ORKQuestionSectionAnswer) {
        if (!_choiceCellGroup) {
            _choiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)impliedAnswerFormat
                                                                                       answer:self.answer
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                                          immediateNavigation:[self isStepImmediateNavigation]];
            _choiceCellGroup.delegate = self;
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
                               @(ORKQuestionTypeDecimal): [ORKSurveyAnswerCellForNumber class],
                               @(ORKQuestionTypeText): [ORKSurveyAnswerCellForText class],
                               @(ORKQuestionTypeTimeOfDay): [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDate): [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDateAndTime): [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeTimeInterval): [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeHeight) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeWeight) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeMultiplePicker) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeInteger): [ORKSurveyAnswerCellForNumber class],
                               @(ORKQuestionTypeLocation): [ORKSurveyAnswerCellForLocation class],
                               @(ORKQuestionTypeSES): [ORKSurveyAnswerCellForSES class]};
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
    if (!cell) {
        cell = [_choiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier];
    }
    
    if ([cell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
        ORKChoiceOtherViewCell *otherCell = (ORKChoiceOtherViewCell *)cell;
        otherCell.delegate = self;
        cell = otherCell;
    }

    cell.useCardView = self.questionStep.useCardView;
    cell.userInteractionEnabled = !self.readOnlyMode;
    
    cell.isLastItem = indexPath.row == _choiceCellGroup.size - 1;
    cell.isFirstItemInSectionWithoutTitle = (indexPath.row == 0 && ![self questionStep].question);
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
    if (self.isBeingReviewed) {
        [self saveAnswer:self.originalAnswer];
    }
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

- (void)setShouldPresentInReview:(BOOL)shouldPresentInReview {
    [super setShouldPresentInReview:shouldPresentInReview];
    [_navigationFooterView setHidden:YES];
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
    
    if (_choiceCellGroup.answerFormat.style == ORKChoiceAnswerStyleSingleChoice && ![self hasAnswer]) {
         [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:YES];
     }
    
    [_choiceCellGroup didSelectCellAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = [ORKSurveyAnswerCell suggestedCellHeightForView:tableView];
    
    switch (self.questionStep.questionType) {
        case ORKQuestionTypeSingleChoice:
        case ORKQuestionTypeMultipleChoice:{
            if ([self.questionStep isFormatFitsChoiceCells]) {
                return UITableViewAutomaticDimension;
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
static NSString *const _ORKOriginalAnswerRestoreKey = @"originalAnswer";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_answer forKey:_ORKAnswerRestoreKey];
    [coder encodeBool:_hasChangedAnswer forKey:_ORKHasChangedAnswerRestoreKey];
    [coder encodeObject:_originalAnswer forKey:_ORKOriginalAnswerRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    NSSet *decodeableSet = [NSSet setWithObjects:[NSNumber class], [NSString class], [NSDateComponents class], [NSArray class], nil];
    self.answer = [coder decodeObjectOfClasses:decodeableSet forKey:_ORKAnswerRestoreKey];
    self.hasChangedAnswer = [coder decodeBoolForKey:_ORKHasChangedAnswerRestoreKey];
    self.originalAnswer = [coder decodeObjectOfClasses:decodeableSet forKey:_ORKOriginalAnswerRestoreKey];
    
    [self answerDidChange];
}

#pragma mark - ORKTableContainerViewDelegate;

- (nonnull UITableViewCell *)currentFirstResponderCellForTableContainerView:(nonnull ORKTableContainerView *)tableContainerView {
    return _currentFirstResponderCell;
}

#pragma mark - ORKTextChoiceCellGroupDelegate

- (void)answerChangedForIndexPath:(NSIndexPath *)indexPath {
    // Capture `isStepImmediateNavigation` before saving an answer.
    BOOL immediateNavigation = [self isStepImmediateNavigation];
    
    id answer = (self.questionStep.questionType == ORKQuestionTypeBoolean) ? [_choiceCellGroup answerForBoolean] :[_choiceCellGroup answer];
    
    [self saveAnswer:answer];
    self.hasChangedAnswer = YES;
    
    if (immediateNavigation) {
        // Proceed as continueButton tapped
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            ORKSuppressPerformSelectorWarning(
                                              [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
        });
    }
}

- (void)tableViewCellHeightUpdated {
    [_tableView reloadData];
}

#pragma mark - ORKChoiceOtherViewCellDelegate

- (void)textChoiceOtherCellDidBecomeFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    _currentFirstResponderCell = choiceOtherViewCell;
    NSIndexPath *indexPath = [_tableView indexPathForCell:choiceOtherViewCell];
    if (indexPath) {
        [_tableContainer scrollCellVisible:choiceOtherViewCell animated:YES];
    }
}

- (void)textChoiceOtherCellDidResignFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    if (_currentFirstResponderCell == choiceOtherViewCell) {
        _currentFirstResponderCell = nil;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:choiceOtherViewCell];
    [_choiceCellGroup textViewDidResignResponderForCellAtIndexPath:indexPath];
}

//FIXME: Need Accessibility for Continue and skip button. Lost support when moved navigationFooterViewView outside VerticalContainerView.

//    if (_navigationFooterView.continueButton != nil) {
//        [elements addObject:self.continueSkipContainer.continueButton];
//    }
//    if (_navigationFooterView.skipButton != nil) {
//        [elements addObject:self.continueSkipContainer.skipButton];
//    }

#pragma mark - ORKLearnViewDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [self.taskViewController learnMoreButtonPressedWithStep:learnMoreStep fromStepViewController:self];
}

@end
