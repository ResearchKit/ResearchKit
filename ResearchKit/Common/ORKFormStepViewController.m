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


#import "ORKFormStepViewController.h"

#import "ORKCaption1Label.h"
#import "ORKChoiceViewCell_Internal.h"
#import "ORKFormItemCell.h"
#import "ORKFormSectionTitleLabel.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTableContainerView.h"
#import "ORKStepContentView.h"
#import "ORKBodyItem.h"
#import "ORKLearnMoreView.h"

#import "ORKSurveyCardHeaderView.h"
#import "ORKTextChoiceCellGroup.h"
#import "ORKLearnMoreStepViewController.h"
#import "ORKBodyItem.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKCollectionResult_Private.h"
#import "ORKQuestionResult_Private.h"
#import "ORKFormItem_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"
#import "ORKResultPredicate.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@interface ORKTableCellItem : NSObject

- (instancetype)initWithFormItem:(ORKFormItem *)formItem;
- (instancetype)initWithFormItem:(ORKFormItem *)formItem choiceIndex:(NSUInteger)index;

@property (nonatomic, copy) ORKFormItem *formItem;

@property (nonatomic, copy) ORKAnswerFormat *answerFormat;

@property (nonatomic, readonly) CGFloat labelWidth;

// For choice types only
@property (nonatomic, copy, readonly) ORKTextChoice *choice;

@end


@implementation ORKTableCellItem

- (instancetype)initWithFormItem:(ORKFormItem *)formItem {
    self = [super init];
    if (self) {
        self.formItem = formItem;
        _answerFormat = [[formItem impliedAnswerFormat] copy];
    }
    return self;
}

- (instancetype)initWithFormItem:(ORKFormItem *)formItem choiceIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        self.formItem = formItem;
        _answerFormat = [[formItem impliedAnswerFormat] copy];
        
        if ([self textChoiceAnswerFormat] != nil) {
            _choice = [self.textChoiceAnswerFormat.textChoices[index] copy];
        }
    }
    return self;
}

- (ORKTextChoiceAnswerFormat *)textChoiceAnswerFormat {
    if ([self.answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        return (ORKTextChoiceAnswerFormat *)self.answerFormat;
    }
    return nil;
}

- (CGFloat)labelWidth {
    static ORKCaption1Label *sharedLabel;
    
    if (sharedLabel == nil) {
        sharedLabel = [ORKCaption1Label new];
    }
    
    sharedLabel.text = _formItem.text;
    
    return [sharedLabel textRectForBounds:CGRectInfinite limitedToNumberOfLines:1].size.width;
}

@end


@interface ORKTableSection : NSObject

- (instancetype)initWithSectionIndex:(NSUInteger)index;

@property (nonatomic, assign, readonly) NSUInteger index;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy, nullable) NSString *detailText;

@property (nonatomic) BOOL showsProgress;

@property (nonatomic, nullable) ORKLearnMoreItem *learnMoreItem;

@property (nonatomic, copy, readonly) NSArray<ORKTableCellItem *> *items;
@property (nonatomic, copy, readonly) NSArray<ORKFormItem *> *formItems;

@property (nonatomic, readonly) BOOL hasChoiceRows;

@property (nonatomic, strong) ORKTextChoiceCellGroup *textChoiceCellGroup;

- (void)addFormItem:(ORKFormItem *)item;
- (ORKTableCellItem * _Nullable)cellItemForFormItem:(ORKFormItem *)formItem;

@property (nonatomic, readonly) CGFloat maxLabelWidth;

@end


@implementation ORKTableSection {
    NSMutableDictionary<ORKFormItem *, ORKTableCellItem*> *_cellItemForFormItem;
}

- (instancetype)initWithSectionIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        _formItems = [NSMutableArray new];
        self.title = nil;
        _index = index;
        _cellItemForFormItem = [NSMutableDictionary new];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)addFormItem:(ORKFormItem *)item {
    if ([[item impliedAnswerFormat] isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        _hasChoiceRows = YES;
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)[item impliedAnswerFormat];
        
        _textChoiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:textChoiceAnswerFormat
                                                                                       answer:nil
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:_index]
                                                                          immediateNavigation:NO];
        
        [textChoiceAnswerFormat.textChoices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item choiceIndex:idx];
            [(NSMutableArray *)self.items addObject:cellItem];
        }];
        
    } else {
        ORKTableCellItem *cellItem = [[ORKTableCellItem alloc] initWithFormItem:item];
        [(NSMutableArray *)self.items addObject:cellItem];
        _cellItemForFormItem[item] = cellItem;
    }
    [(NSMutableArray *)self.formItems addObject:item];
}

- (ORKTableCellItem * _Nullable)cellItemForFormItem:(ORKFormItem *)formItem {
    return _cellItemForFormItem[formItem];
}

- (CGFloat)maxLabelWidth {
    CGFloat max = 0;
    for (ORKTableCellItem *item in self.items) {
        if (item.labelWidth > max) {
            max = item.labelWidth;
        }
    }
    return max;
}

@end

@interface ORKFormSectionHeaderView : UIView

- (instancetype)initWithTitle:(NSString *)title tableView:(UITableView *)tableView firstSection:(BOOL)firstSection;

@property (nonatomic, strong) NSLayoutConstraint *leftMarginConstraint;

@property (nonatomic, weak) UITableView *tableView;

@end


@implementation ORKFormSectionHeaderView {
    ORKFormSectionTitleLabel *_label;
    BOOL _firstSection;
}

- (instancetype)initWithTitle:(NSString *)title tableView:(UITableView *)tableView firstSection:(BOOL)firstSection {
    self = [super init];
    if (self) {
        _tableView = tableView;
        _firstSection = firstSection;
        self.backgroundColor = [UIColor whiteColor];
        
        _label = [ORKFormSectionTitleLabel new];
        _label.text = title;
        _label.numberOfLines = 0;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_label];
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    
    const CGFloat LabelFirstBaselineToTop = _firstSection ? 20.0 : 40.0;
    const CGFloat LabelLastBaselineToBottom = -10.0;
    const CGFloat LabelRightMargin = -4.0;
    
    NSMutableArray *constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeFirstBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:LabelFirstBaselineToTop]];
    
    self.leftMarginConstraint = [NSLayoutConstraint constraintWithItem:_label
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0.0];
    
    [constraints addObject:self.leftMarginConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeLastBaseline
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:LabelLastBaselineToBottom]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_label
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:LabelRightMargin]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    self.leftMarginConstraint.constant = _tableView.layoutMargins.left;
}

@end


@interface ORKFormStepViewController () <UITableViewDataSource, UITableViewDelegate, ORKFormItemCellDelegate, ORKTableContainerViewDelegate, ORKTextChoiceCellGroupDelegate, ORKChoiceOtherViewCellDelegate, ORKLearnMoreViewDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKStepContentView *headerView;

@property (nonatomic, strong) NSMutableDictionary *savedAnswers;
@property (nonatomic, strong) NSMutableDictionary *savedAnswerDates;
@property (nonatomic, strong) NSMutableDictionary *savedSystemCalendars;
@property (nonatomic, strong) NSMutableDictionary *savedSystemTimeZones;
@property (nonatomic, strong) NSDictionary *originalAnswers;

@property (nonatomic, strong) NSMutableDictionary *savedDefaults;

@end


@implementation ORKFormStepViewController {
    ORKAnswerDefaultSource *_defaultSource;
    ORKNavigationContainerView *_navigationFooterView;
    NSMutableSet *_formItemCells;
    NSMutableArray<ORKTableSection *> *_sections;
    NSMutableArray<ORKTableSection *> *_allSections;
    NSMutableArray<ORKFormItem *> *_hiddenFormItems;
    NSMutableArray<ORKTableCellItem *> *_hiddenCellItems;
    BOOL _skipped;
    UITableViewCell *_currentFirstResponderCell;
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)ORKFormStepViewController_initWithResult:(ORKResult *)result {
    _defaultSource = [ORKAnswerDefaultSource sourceWithHealthStore:[HKHealthStore new]];
    if (result) {
        NSAssert([result isKindOfClass:[ORKStepResult class]], @"Expect a ORKStepResult instance");

        NSArray *resultsArray = [(ORKStepResult *)result results];
        for (ORKQuestionResult *currentResult in resultsArray) {
            id answer = currentResult.answer ? : ORKNullAnswerValue();
            [self setAnswer:answer forIdentifier:currentResult.identifier];
        }
        self.originalAnswers = [[NSDictionary alloc] initWithDictionary:self.savedAnswers];
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    return [self ORKFormStepViewController_initWithResult:nil];
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {

    self = [super initWithStep:step];
    return [self ORKFormStepViewController_initWithResult:result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainer sizeHeaderToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSMutableSet *types = [NSMutableSet set];
    for (ORKFormItem *item in [self formItems]) {
        ORKAnswerFormat *format = [item answerFormat];
        HKObjectType *objType = [format healthKitObjectTypeForAuthorization];
        if (objType) {
            [types addObject:objType];
        }
    }
    
    BOOL refreshDefaultsPending = NO;
    if (types.count) {
        NSSet<HKObjectType *> *alreadyRequested = [[self taskViewController] requestedHealthTypesForRead];
        if (![types isSubsetOfSet:alreadyRequested]) {
            refreshDefaultsPending = YES;
            [_defaultSource.healthStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError *error) {
                if (!success) {
                    ORK_Log_Debug(@"Authorization: %@",error);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDefaults];
                });
            }];
        }
    }
    if (!refreshDefaultsPending) {
        [self refreshDefaults];
    }
    
    // Reset skipped flag - result can now be non-empty
    _skipped = NO;
    [_tableContainer layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)updateDefaults:(NSMutableDictionary *)defaults {
    _savedDefaults = defaults;
    
    for (ORKFormItemCell *cell in [_tableView visibleCells]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        ORKTableSection *section = _sections[indexPath.section];
        ORKTableCellItem *cellItem = [section items][indexPath.row];
        ORKFormItem *formItem = cellItem.formItem;
        if ([cell isKindOfClass:[ORKChoiceViewCell class]]) {
            id answer = _savedAnswers[formItem.identifier];
            answer = answer ? : _savedDefaults[formItem.identifier];
            
            [section.textChoiceCellGroup setAnswer:answer];
            
            // Answers need to be saved.
            [self setAnswer:answer forIdentifier:formItem.identifier];
            
        } else {
            cell.defaultAnswer = _savedDefaults[formItem.identifier];
        }
    }
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

- (void)refreshDefaults {
    NSArray *formItems = [self formItems];
    ORKAnswerDefaultSource *source = _defaultSource;
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        for (ORKFormItem *formItem in formItems) {
            [source fetchDefaultValueForAnswerFormat:formItem.answerFormat handler:^(id defaultValue, NSError *error) {
                if (defaultValue != nil) {
                    defaults[formItem.identifier] = defaultValue;
                } else if (error != nil) {
                    ORK_Log_Warning(@"Error fetching default for %@: %@", formItem, error);
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
        for (__unused ORKFormItem *formItem in formItems) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        // All fetches have completed.
        dispatch_async(dispatch_get_main_queue(), ^{
            ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
            [strongSelf updateDefaults:defaults];
        });
        
    });
    
    
}

- (void)removeAnswerForIdentifier:(NSString *)identifier {
    if (identifier == nil) {
        return;
    }
    [_savedAnswers removeObjectForKey:identifier];
    _savedAnswerDates[identifier] = [NSDate date];
}

- (void)setAnswer:(id)answer forIdentifier:(NSString *)identifier {
    if (answer == nil || identifier == nil) {
        return;
    }
    if (_savedAnswers == nil) {
        _savedAnswers = [NSMutableDictionary new];
    }
    if (_savedAnswerDates == nil) {
        _savedAnswerDates = [NSMutableDictionary new];
    }
    if (_savedSystemCalendars == nil) {
        _savedSystemCalendars = [NSMutableDictionary new];
    }
    if (_savedSystemTimeZones == nil) {
        _savedSystemTimeZones = [NSMutableDictionary new];
    }
    _savedAnswers[identifier] = answer;
    _savedAnswerDates[identifier] = [NSDate date];
    _savedSystemCalendars[identifier] = [NSCalendar currentCalendar];
    _savedSystemTimeZones[identifier] = [NSTimeZone systemTimeZone];
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _navigationFooterView.continueButtonItem = continueButtonItem;
    [self updateButtonStates];
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    _navigationFooterView.cancelButtonItem = cancelButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    
    _navigationFooterView.skipButtonItem = skipButtonItem;
    [self updateButtonStates];
}

- (void)stepDidChange {
    [super stepDidChange];

    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _formItemCells = nil;
    _headerView = nil;
    _navigationFooterView = nil;
    
    if (self.isViewLoaded && self.step) {
        [self buildSections];
        [self hideSections];
        
        _formItemCells = [NSMutableSet new];
        
        _tableContainer = [ORKTableContainerView new];
        _tableContainer.tableContainerDelegate = self;
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableView.estimatedSectionHeaderHeight = 30.0;
        
        if ([self formStep].useCardView) {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (ORKNeedWideScreenDesign(self.view)) {
                [_tableView setBackgroundColor:[UIColor clearColor]];
                [self.taskViewController.navigationBar setBarTintColor:ORKColor(ORKBackgroundColorKey)];
                [self.view setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
            }
            else {
                [_tableView setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
                [self.taskViewController.navigationBar setBarTintColor:[_tableView backgroundColor]];
                [self.view setBackgroundColor:[_tableView backgroundColor]];
            }
        }
        _headerView = _tableContainer.stepContentView;
        _headerView.stepTopContentImage = self.step.image;
        _headerView.titleIconImage = self.step.iconImage;
        _headerView.stepTitle = self.step.title;
        _headerView.stepText = self.step.text;
        _headerView.stepDetailText = self.step.detailText;
        _headerView.bodyItems = self.step.bodyItems;
        _tableContainer.stepTopContentImageContentMode = self.step.imageContentMode;
        
        
        _navigationFooterView = _tableContainer.navigationFooterView;
        [_navigationFooterView removeStyling];
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.cancelButtonItem = self.cancelButtonItem;
        _navigationFooterView.optional = self.step.optional;
        _navigationFooterView.footnoteLabel.text = [self formStep].footnote;
        if (self.readOnlyMode) {
            _navigationFooterView.optional = YES;
            [_navigationFooterView setNeverHasContinueButton:YES];
            _navigationFooterView.skipEnabled = [self skipButtonEnabled];
            _navigationFooterView.skipButton.accessibilityTraits = UIAccessibilityTraitStaticText;
        }
        [self setupConstraints];
        [_tableContainer setNeedsLayout];
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

- (void)buildSections {
    NSArray *items = [self allFormItems];
    _allSections = [NSMutableArray new];
    ORKTableSection *section = nil;
    
    if (items.count > 0) {
        ORKFormItem *firstFormItem = items.firstObject;
        if (firstFormItem.answerFormat) {
            [self buildSectionsWithoutGrouping];
            return;
        }
    }
    
    for (ORKFormItem *item in items) {
        if (!item.answerFormat) {
            // Add new section
            section = [[ORKTableSection alloc] initWithSectionIndex:_sections.count];
            [_allSections addObject:section];
            
            // Save title
            section.title = item.text;
            section.detailText = item.detailText;
            section.learnMoreItem = item.learnMoreItem;
            section.showsProgress = item.showsProgress;
        } else {
            if (section) {
                [section addFormItem:item];
            }
        }
    }
}

- (void)buildSectionsWithoutGrouping {
    NSArray *items = [self allFormItems];

    _allSections = [NSMutableArray new];
    ORKTableSection *section = nil;

    NSArray *singleSectionTypes = @[@(ORKQuestionTypeBoolean),
                                    @(ORKQuestionTypeSingleChoice),
                                    @(ORKQuestionTypeMultipleChoice),
                                    @(ORKQuestionTypeLocation)];

    for (ORKFormItem *item in items) {
        // Section header
        if ([item impliedAnswerFormat] == nil) {
            // Add new section
            section = [[ORKTableSection alloc] initWithSectionIndex:_allSections.count];
            [_allSections addObject:section];
            // Save title
            section.title = item.text;
        // Actual item
        } else {
            ORKAnswerFormat *answerFormat = [item impliedAnswerFormat];

            BOOL multiCellChoices = ([singleSectionTypes containsObject:@(answerFormat.questionType)] &&
                                     NO == [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]);

            BOOL multilineTextEntry = (answerFormat.questionType == ORKQuestionTypeText && [(ORKTextAnswerFormat *)answerFormat multipleLines]);

            BOOL scale = (answerFormat.questionType == ORKQuestionTypeScale);

            // Items require individual section
            if (multiCellChoices || multilineTextEntry || scale) {
                // Add new section
                section = [[ORKTableSection alloc]  initWithSectionIndex:_allSections.count];
                [_allSections addObject:section];

                // Save title
                section.title = item.text;

                [section addFormItem:item];

                // following item should start a new section
                section = nil;
            } else {
                // In case no section available, create new one.
                if (section == nil) {
                    section = [[ORKTableSection alloc]  initWithSectionIndex:_allSections.count];
                    [_allSections addObject:section];
                }
                [section addFormItem:item];
            }
        }
    }
}

- (NSInteger)numberOfAnsweredFormItemsInDictionary:(NSDictionary *)dictionary {
    __block NSInteger nonNilCount = 0;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id answer, BOOL *stop) {
        if (ORKIsAnswerEmpty(answer) == NO) {
            nonNilCount ++;
        }
    }];
    return nonNilCount;
}

- (NSInteger)numberOfAnsweredFormItems {
    return [self numberOfAnsweredFormItemsInDictionary:self.savedAnswers];
}

- (BOOL)allAnsweredFormItemsAreValid {
    for (ORKFormItem *item in [self formItems]) {
        id answer = _savedAnswers[item.identifier];
        if (ORKIsAnswerEmpty(answer) == NO && ![item.impliedAnswerFormat isAnswerValid:answer]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allNonOptionalFormItemsHaveAnswers {
    ORKTaskResult *taskResult = self.taskViewController.result;
    for (ORKFormItem *item in [self formItems]) {
        BOOL hideFormItem = [item.hidePredicate evaluateWithObject:@[taskResult]
                                             substitutionVariables:@{ORKResultPredicateTaskIdentifierVariableName : taskResult.identifier}];
        if (!item.optional && !hideFormItem) {
            id answer = _savedAnswers[item.identifier];
            if (ORKIsAnswerEmpty(answer) || ![item.impliedAnswerFormat isAnswerValid:answer]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)continueButtonEnabled {
    BOOL enabled = ([self numberOfAnsweredFormItems] > 0
                    && [self allAnsweredFormItemsAreValid]
                    && [self allNonOptionalFormItemsHaveAnswers]);
    if (self.isBeingReviewed) {
        enabled = enabled && ![self.savedAnswers isEqualToDictionary:self.originalAnswers];
    }
    return enabled;
}

- (BOOL)skipButtonEnabled {
    BOOL enabled = self.formStep.optional;
    if (self.isBeingReviewed) {
        enabled = self.readOnlyMode ? NO : enabled && [self numberOfAnsweredFormItemsInDictionary:self.originalAnswers] > 0;
    }
    return enabled;
}

- (void)updateButtonStates {
    _navigationFooterView.continueEnabled = [self continueButtonEnabled];
    _navigationFooterView.skipEnabled = [self skipButtonEnabled];
}

- (void)hideSections {
    NSMutableArray<ORKTableSection *> *newSections = [NSMutableArray new];
    NSMutableArray<ORKTableCellItem *> *newHiddenCellItems = [NSMutableArray new];
    _hiddenFormItems = [NSMutableArray new];
    
    NSMutableArray *deleteRows = [NSMutableArray new];
    NSMutableArray *insertRows = [NSMutableArray new];
    NSMutableIndexSet *deleteSections = [NSMutableIndexSet new];
    NSMutableIndexSet *insertSections = [NSMutableIndexSet new];
    NSMutableIndexSet *sectionsToReload = [NSMutableIndexSet new];
    
    ORKTaskResult *taskResult = self.taskViewController.result;
    
    for (ORKTableSection *section in _allSections) {
        BOOL hideSection = YES;
        NSUInteger currentSectionIndex = [_sections indexOfObject:section];
        NSMutableArray *pendingRowInsertions = [NSMutableArray new];
        NSMutableArray *pendingRowDeletions = [NSMutableArray new];
        for (ORKFormItem *formItem in section.formItems) {
            BOOL formItemIsHidden = [formItem.hidePredicate evaluateWithObject:@[taskResult]
                                                         substitutionVariables:@{ORKResultPredicateTaskIdentifierVariableName : taskResult.identifier}];
            ORKTableCellItem *cellItem = [section cellItemForFormItem:formItem];
            NSArray *currentShowingCellItems = [self showingCellItemsForSection:section];
            NSUInteger currentRowIndex = [currentShowingCellItems indexOfObject:cellItem];
            NSMutableArray *newRows = [NSMutableArray new];
            if (formItemIsHidden) {
                if (currentRowIndex != NSNotFound && currentSectionIndex != NSNotFound) {
                    [pendingRowDeletions addObject:[NSIndexPath indexPathForRow:currentRowIndex inSection:currentSectionIndex]];
                }
                [_hiddenFormItems addObject:formItem];
                if (cellItem) {
                    [newHiddenCellItems addObject:cellItem];
                }
            } else {
                if (cellItem && currentRowIndex == NSNotFound) {
                    [pendingRowInsertions addObject:[NSIndexPath indexPathForRow:newRows.count inSection:newSections.count]];
                }
                if (cellItem) {
                    [newRows addObject:cellItem];
                }
                hideSection = NO;
            }
        }
        
        if (hideSection) {
            if (currentSectionIndex != NSNotFound) {
                [deleteSections addIndex:currentSectionIndex];
            }
            [deleteRows addObjectsFromArray:pendingRowDeletions];
            [insertRows addObjectsFromArray:pendingRowInsertions];
        } else {
            [newSections addObject:section];
            if (currentSectionIndex == NSNotFound) {
                [insertSections addIndex:newSections.count - 1];
                [deleteRows addObjectsFromArray:pendingRowDeletions];
                [insertRows addObjectsFromArray:pendingRowInsertions];
            } else if (section.formItems.count > 1) {
                [sectionsToReload addIndex:newSections.count - 1];
            }
        }
    }
    
    if (_tableView != nil) {
        if (insertSections.count > 0 || deleteSections.count > 0 || insertRows.count > 0 || deleteRows.count > 0) {
            [_tableView beginUpdates];
            _sections = newSections;
            _hiddenCellItems = newHiddenCellItems;
            if (deleteRows.count > 0) {
                [_tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if (deleteSections.count > 0) {
                [_tableView deleteSections:deleteSections withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if (insertSections.count > 0) {
                [_tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if (insertRows.count > 0) {
                [_tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [_tableView endUpdates];
        } else {
            _sections = newSections;
            _hiddenCellItems = newHiddenCellItems;
        }
        if (sectionsToReload.count > 0) {
            [_tableView reloadSections:sectionsToReload withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } else {
        _sections = newSections;
        _hiddenCellItems = newHiddenCellItems;
    }
}

- (NSArray *)showingCellItemsForSection:(ORKTableSection *)section {
    NSMutableArray *showingCells = [NSMutableArray new];
    for (ORKTableCellItem *cellItem in section.items) {
        if (![_hiddenCellItems containsObject:cellItem]) {
            [showingCells addObject:cellItem];
        }
    }
    return showingCells;
}

- (NSIndexPath *)unhiddenIndexPathForIndexPath:(NSIndexPath *)hiddenIndexPath {
    return [NSIndexPath indexPathForRow:hiddenIndexPath.row inSection:[_allSections indexOfObject:_sections[hiddenIndexPath.section]]];
}

- (NSIndexPath *)hiddenIndexPathForIndexPath:(NSIndexPath *)unhiddenIndexPath {
    return [NSIndexPath indexPathForRow:unhiddenIndexPath.row inSection:[_sections indexOfObject:_allSections[unhiddenIndexPath.section]]];
}

#pragma mark Helpers

- (ORKFormStep *)formStep {
    NSAssert(!self.step || [self.step isKindOfClass:[ORKFormStep class]], nil);
    return (ORKFormStep *)self.step;
}

- (NSArray *)allFormItems {
    return [[self formStep] formItems];
}

- (NSArray *)formItems {
    NSArray *formItems = [self allFormItems];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:formItems.count];
    for (ORKFormItem *item in formItems) {
        if (item.answerFormat != nil) {
            [array addObject:item];
        }
    }
    
    return [array copy];
}

- (BOOL)showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (_skipped) {
        return NO;
    }
    
    return [super showValidityAlertWithMessage:text];
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    NSArray *items = [self formItems];
    
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = parentResult.endDate;
    
    NSMutableArray *qResults = [NSMutableArray new];
    for (ORKFormItem *item in items) {
        
        if ([_hiddenFormItems containsObject:item]) {
            continue;
        }
        
        // Skipped forms report a "null" value for every item -- by skipping, the user has explicitly said they don't want
        // to report any values from this form.
        
        id answer = ORKNullAnswerValue();
        NSDate *answerDate = now;
        NSCalendar *systemCalendar = [NSCalendar currentCalendar];
        NSTimeZone *systemTimeZone = [NSTimeZone systemTimeZone];
        if (!_skipped) {
            answer = _savedAnswers[item.identifier];
            answerDate = _savedAnswerDates[item.identifier] ? : now;
            systemCalendar = _savedSystemCalendars[item.identifier];
            NSAssert(answer == nil || answer == ORKNullAnswerValue() || systemCalendar != nil, @"systemCalendar NOT saved");
            systemTimeZone = _savedSystemTimeZones[item.identifier];
            NSAssert(answer == nil || answer == ORKNullAnswerValue() || systemTimeZone != nil, @"systemTimeZone NOT saved");
        }
        
        ORKQuestionResult *result = [item.answerFormat resultWithIdentifier:item.identifier answer:answer];
        ORKAnswerFormat *impliedAnswerFormat = [item impliedAnswerFormat];
        
        if ([impliedAnswerFormat isKindOfClass:[ORKDateAnswerFormat class]]) {
            ORKDateQuestionResult *dqr = (ORKDateQuestionResult *)result;
            if (dqr.dateAnswer) {
                NSCalendar *usedCalendar = [(ORKDateAnswerFormat *)impliedAnswerFormat calendar] ? : systemCalendar;
                dqr.calendar = [NSCalendar calendarWithIdentifier:usedCalendar.calendarIdentifier];
                dqr.timeZone = systemTimeZone;
            }
        } else if ([impliedAnswerFormat isKindOfClass:[ORKNumericAnswerFormat class]]) {
            ORKNumericQuestionResult *nqr = (ORKNumericQuestionResult *)result;
            if (nqr.unit == nil) {
                nqr.unit = [(ORKNumericAnswerFormat *)impliedAnswerFormat unit];
            }
        }
        
        result.startDate = answerDate;
        result.endDate = answerDate;

        [qResults addObject:result];
    }
    
    parentResult.results = [parentResult.results arrayByAddingObjectsFromArray:qResults] ? : qResults;
    
    return parentResult;
}

- (void)skipForward {
    // This _skipped flag is a hack so that the -result method can return an empty
    // result after the skip action, without having to generate the result
    // in advance.
    _skipped = YES;
    [self notifyDelegateOnResultChange];
    
    [super skipForward];
}

- (void)goBackward {
    if (self.isBeingReviewed) {
        self.savedAnswers = [[NSMutableDictionary alloc] initWithDictionary:self.originalAnswers];
    }
    [super goBackward];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    ORKTableSection *sectionObject = (ORKTableSection *)_sections[section];
    return [self showingCellItemsForSection:sectionObject].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *unhiddenIndexPath = [self unhiddenIndexPathForIndexPath:indexPath];
    
    ORKTableSection *section = (ORKTableSection *)_sections[indexPath.section];
    NSArray <ORKTableCellItem *> *showingCellItems = [self showingCellItemsForSection:section];
    ORKTableCellItem *cellItem = showingCellItems[indexPath.row];
    
    NSString *identifier = [NSString stringWithFormat:@"%ld-%ld",(long)unhiddenIndexPath.section, (long)unhiddenIndexPath.row];
    
    UITableViewCell *cell;
    
    // if the state of the tableview changes due to dynamic hiding/showing via a hidePredicate, the
    // corner radius of the cells in the section may change based on which rows are first, middle, and
    // last. Forcing a reload of the cell ensures they are drawn correctly based on the new state.
    if (section.items.count < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    if (cell == nil) {
        bool isLastItem = showingCellItems.count == indexPath.row + 1;
        bool isFirstItemWithSectionWithoutTitle = indexPath.row == 0 && !section.title;
        ORKFormItem *formItem = cellItem.formItem;
        id answer = _savedAnswers[formItem.identifier];
        
        if (section.textChoiceCellGroup) {
            [section.textChoiceCellGroup setAnswer:answer];
            section.textChoiceCellGroup.delegate = self;
            ORKChoiceViewCell *choiceViewCell = nil;
            choiceViewCell = [section.textChoiceCellGroup cellAtIndexPath:unhiddenIndexPath withReuseIdentifier:identifier];
            if ([choiceViewCell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
                ORKChoiceOtherViewCell *choiceOtherViewCell = (ORKChoiceOtherViewCell *)choiceViewCell;
                choiceOtherViewCell.delegate = self;
            }
            choiceViewCell.useCardView = [self formStep].useCardView;
            choiceViewCell.isLastItem = isLastItem;
            choiceViewCell.isFirstItemInSectionWithoutTitle = isFirstItemWithSectionWithoutTitle;
            cell = choiceViewCell;

        } else {
            ORKAnswerFormat *answerFormat = [cellItem.formItem impliedAnswerFormat];
            ORKQuestionType type = answerFormat.questionType;
            
            Class class = nil;
            switch (type) {
                case ORKQuestionTypeSingleChoice:
                case ORKQuestionTypeMultipleChoice: {
                    if ([formItem.impliedAnswerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]]) {
                        class = [ORKFormItemImageSelectionCell class];
                    } else if ([formItem.impliedAnswerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
                        class = [ORKFormItemPickerCell class];
                    }
                    break;
                }
                    
                case ORKQuestionTypeDateAndTime:
                case ORKQuestionTypeDate:
                case ORKQuestionTypeTimeOfDay:
                case ORKQuestionTypeTimeInterval:
                case ORKQuestionTypeMultiplePicker:
                case ORKQuestionTypeHeight:
                case ORKQuestionTypeWeight: {
                    class = [ORKFormItemPickerCell class];
                    break;
                }
                    
                case ORKQuestionTypeDecimal:
                case ORKQuestionTypeInteger: {
                    class = [ORKFormItemNumericCell class];
                    break;
                }
                    
                case ORKQuestionTypeText: {
                    if ([formItem.answerFormat isKindOfClass:[ORKConfirmTextAnswerFormat class]]) {
                        class = [ORKFormItemConfirmTextCell class];
                    } else {
                        ORKTextAnswerFormat *textFormat = (ORKTextAnswerFormat *)answerFormat;
                        if (!textFormat.multipleLines) {
                            class = [ORKFormItemTextFieldCell class];
                        } else {
                            class = [ORKFormItemTextCell class];
                        }
                    }
                    break;
                }
                    
                case ORKQuestionTypeScale: {
                    class = [ORKFormItemScaleCell class];
                    break;
                }
                    
                case ORKQuestionTypeLocation: {
                    class = [ORKFormItemLocationCell class];
                    break;
                }
                    
                default:
                    NSAssert(NO, @"SHOULD NOT FALL IN HERE %@ %@", @(type), answerFormat);
                    break;
            }
            
            if (class) {
                if ([class isSubclassOfClass:[ORKChoiceViewCell class]]) {
                    NSAssert(NO, @"SHOULD NOT FALL IN HERE");
                } else {
                    ORKFormItemCell *formCell = nil;
                    formCell = [[class alloc] initWithReuseIdentifier:identifier formItem:formItem answer:answer maxLabelWidth:section.maxLabelWidth delegate:self];
                    [_formItemCells addObject:formCell];
                    [formCell setExpectedLayoutWidth:self.tableView.bounds.size.width];
                    formCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    formCell.defaultAnswer = _savedDefaults[formItem.identifier];
                    if (!_savedAnswers) {
                        _savedAnswers = [NSMutableDictionary new];
                    }
                    formCell.savedAnswers = _savedAnswers;
                    formCell.useCardView = [self formStep].useCardView;
                    formCell.isLastItem = isLastItem;
                    formCell.isFirstItemInSectionWithoutTitle = isFirstItemWithSectionWithoutTitle;
                    cell = formCell;
                }
            } else {
                NSAssert(NO, @"SHOULD NOT FALL IN HERE");
            }
        }
    }
    else {
        [cell setNeedsDisplay];
    }
    cell.userInteractionEnabled = !self.readOnlyMode;
    
    return cell;
}

- (BOOL)isChoiceSelected:(id)value atIndex:(NSUInteger)index answer:(id)answer {
    BOOL isSelected = NO;
    if (answer != nil && answer != ORKNullAnswerValue()) {
        if ([answer isKindOfClass:[NSArray class]]) {
            if (value) {
                isSelected = [(NSArray *)answer containsObject:value];
            } else {
                isSelected = [(NSArray *)answer containsObject:@(index)];
            }
        } else {
            if (value) {
                isSelected = ([answer isEqual:value]);
            } else {
                isSelected = (((NSNumber *)answer).integerValue == index);
            }
        }
    }
    return isSelected;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ORKFormItemCell *cell = (ORKFormItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ORKFormItemCell class]]) {
        [cell becomeFirstResponder];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        // Dismiss other textField's keyboard
        [tableView endEditing:NO];
        
        ORKTableSection *section = _sections[indexPath.section];
        [section.textChoiceCellGroup didSelectCellAtIndexPath:[self unhiddenIndexPathForIndexPath:indexPath]];
    }
    [self hideSections];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *title = _sections[section].title;

    // Make first section header view zero height when there is no title
    return [self formStep].useCardView ? UITableViewAutomaticDimension : (title.length > 0) ? UITableViewAutomaticDimension : ((section == 0) ? 0 : UITableViewAutomaticDimension);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = _sections[section].title;
    NSString *detailText = _sections[section].detailText;
    NSString *sectionProgressText = nil;
    ORKLearnMoreView *learnMoreView;
    
    if (_sections[section].showsProgress && (_sections.count > 1)) {
        sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + 1)), ORKLocalizedStringFromNumber(@([_sections count]))];
    }
    
    if (_sections[section].learnMoreItem) {
        learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:_sections[section].learnMoreItem];
        learnMoreView.delegate = self;
    }
    
    ORKFormStep *formStep = [self formStep];
    
    if (formStep.useCardView && _sections[section].items.count > 0) {
        
        ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
        
        if (cardHeaderView == nil && title) {
            cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:title detailText:detailText learnMoreView:learnMoreView progressText:sectionProgressText];
        }
        
        return cardHeaderView;
    }
    else {
        ORKFormSectionHeaderView *view = (ORKFormSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
        
        if (view == nil) {
            // Do not create a header view if first section header has no title
            if (title.length > 0 || section > 0) {
                view = [[ORKFormSectionHeaderView alloc] initWithTitle:title tableView:tableView firstSection:(section == 0)];
            }
        }
        
        return view;
    }
}

#pragma mark ORKFormItemCellDelegate

- (void)formItemCellDidBecomeFirstResponder:(ORKFormItemCell *)cell {
    _currentFirstResponderCell = cell;
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    if (path) {
        [_tableContainer scrollCellVisible:cell animated:YES];
    }
}

- (void)formItemCellDidResignFirstResponder:(ORKFormItemCell *)cell {
    if (_currentFirstResponderCell == cell) {
        _currentFirstResponderCell = nil;
    }
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithMessage:(NSString *)input {
    [self showValidityAlertWithMessage:input];
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showValidityAlertWithTitle:title message:message];
}

- (void)formItemCell:(ORKFormItemCell *)cell answerDidChangeTo:(id)answer {
    if (answer && cell.formItem.identifier) {
        [self setAnswer:answer forIdentifier:cell.formItem.identifier];
    } else if (answer == nil && cell.formItem.identifier) {
        [self removeAnswerForIdentifier:cell.formItem.identifier];
    }
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

#pragma mark ORKTableContainerViewDelegate

- (UITableViewCell *)currentFirstResponderCellForTableContainerView:(ORKTableContainerView *)tableContainerView {
    return _currentFirstResponderCell;
}

#pragma mark UIStateRestoration

static NSString *const _ORKSavedAnswersRestoreKey = @"savedAnswers";
static NSString *const _ORKSavedAnswerDatesRestoreKey = @"savedAnswerDates";
static NSString *const _ORKSavedSystemCalendarsRestoreKey = @"savedSystemCalendars";
static NSString *const _ORKSavedSystemTimeZonesRestoreKey = @"savedSystemTimeZones";
static NSString *const _ORKOriginalAnswersRestoreKey = @"originalAnswers";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_savedAnswers forKey:_ORKSavedAnswersRestoreKey];
    [coder encodeObject:_savedAnswerDates forKey:_ORKSavedAnswerDatesRestoreKey];
    [coder encodeObject:_savedSystemCalendars forKey:_ORKSavedSystemCalendarsRestoreKey];
    [coder encodeObject:_savedSystemTimeZones forKey:_ORKSavedSystemTimeZonesRestoreKey];
    [coder encodeObject:_originalAnswers forKey:_ORKOriginalAnswersRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _savedAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswersRestoreKey];
    _savedAnswerDates = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswerDatesRestoreKey];
    _savedSystemCalendars = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemCalendarsRestoreKey];
    _savedSystemTimeZones = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemTimeZonesRestoreKey];
    _originalAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKOriginalAnswersRestoreKey];
}

#pragma mark Rotate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    for (ORKFormItemCell *cell in _formItemCells) {
        [cell setExpectedLayoutWidth:size.width];
    }
}


#pragma mark ORKTextChoiceCellGroupDelegate

- (void)answerChangedForIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *hiddenIndexPath = [self hiddenIndexPathForIndexPath:indexPath];
    ORKTableSection *section = _sections[hiddenIndexPath.section];
    ORKTableCellItem *cellItem = section.items[hiddenIndexPath.row];
    id answer = ([cellItem.formItem.answerFormat isKindOfClass:[ORKBooleanAnswerFormat class]]) ? [section.textChoiceCellGroup answerForBoolean] : [section.textChoiceCellGroup answer];
    NSString *formItemIdentifier = cellItem.formItem.identifier;
    if (answer && formItemIdentifier) {
        [self setAnswer:answer forIdentifier:formItemIdentifier];
    } else if (answer == nil && formItemIdentifier) {
        [self removeAnswerForIdentifier:formItemIdentifier];
    }
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

- (void)tableViewCellHeightUpdated {
    [_tableView reloadData];
}

#pragma mark - ORKChoiceOtherViewCellDelegate

- (void)textChoiceOtherCellDidBecomeFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    _currentFirstResponderCell = choiceOtherViewCell;
    NSIndexPath *path = [_tableView indexPathForCell:choiceOtherViewCell];
    if (path) {
        [_tableContainer scrollCellVisible:choiceOtherViewCell animated:YES];
    }
}

- (void)textChoiceOtherCellDidResignFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    if (_currentFirstResponderCell == choiceOtherViewCell) {
        _currentFirstResponderCell = nil;
    }
    NSIndexPath *indexPath = [_tableView indexPathForCell:choiceOtherViewCell];
    ORKTableSection *section = _sections[indexPath.section];
    [section.textChoiceCellGroup textViewDidResignResponderForCellAtIndexPath:indexPath];
}

#pragma mark - ORKlearnMoreStepViewControllerDelegate

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    ORKLearnMoreStepViewController *learnMoreViewController = [[ORKLearnMoreStepViewController alloc] initWithStep:learnMoreStep];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:learnMoreViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
