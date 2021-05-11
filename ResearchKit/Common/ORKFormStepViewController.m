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
#import "ORKFormStep_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"

#import "ORKSESSelectionView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

#if HEALTH
#import <HealthKit/HealthKit.h>
#endif

static const CGFloat TableViewYOffsetStandard = 30.0;
static const CGFloat DelayBeforeAutoScroll = 0.25;

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

@property (nonatomic, copy, nullable) NSString *tagText;

// ORKTableCellItem
@property (nonatomic, copy, readonly) NSArray *items;

@property (nonatomic, readonly) BOOL hasChoiceRows;

@property (nonatomic, strong) ORKTextChoiceCellGroup *textChoiceCellGroup;

- (void)addFormItem:(ORKFormItem *)item;

@property (nonatomic, readonly) CGFloat maxLabelWidth;

@end


@implementation ORKTableSection

- (instancetype)initWithSectionIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
        self.title = nil;
        _index = index;
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
    }
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
    NSMutableSet *_formItemCells;
    NSMutableArray<ORKTableSection *> *_sections;
    NSMutableSet *_answeredSections;
    BOOL _skipped;
    BOOL _autoScrollCancelled;
    UITableViewCell *_currentFirstResponderCell;
    NSArray<NSLayoutConstraint *> *_constraints;
}

- (instancetype)ORKFormStepViewController_initWithResult:(ORKResult *)result {
#if HEALTH
    _defaultSource = [ORKAnswerDefaultSource sourceWithHealthStore:[HKHealthStore new]];
#endif
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
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainer sizeHeaderToFit];
    [_tableContainer resizeFooterToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAnsweredSections];
    NSMutableSet *types = [NSMutableSet set];
#if HEALTH
    for (ORKFormItem *item in [self formItems]) {
         ORKAnswerFormat *format = [item answerFormat];
         HKObjectType *objType = [format healthKitObjectTypeForAuthorization];
        if (objType) {
            [types addObject:objType];
        }
    }
#endif
    BOOL refreshDefaultsPending = NO;
    if (types.count) {
#if HEALTH
        NSSet<HKObjectType *> *alreadyRequested = [[self taskViewController] requestedHealthTypesForRead];
        if (![types isSubsetOfSet:alreadyRequested]) {
            refreshDefaultsPending = YES;
            [_defaultSource.healthStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError *error) {
                if (!success) {
                    ORK_Log_Debug("Authorization: %@",error);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshDefaults];
                });
            }];
        }
#endif
    }
    if (!refreshDefaultsPending) {
        [self refreshDefaults];
    }
    
    // Reset skipped flag - result can now be non-empty
    _skipped = NO;
    
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
    _autoScrollCancelled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _autoScrollCancelled = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)updateAnsweredSections {
    _answeredSections = [NSMutableSet new];
    [_sections enumerateObjectsUsingBlock:^(ORKTableSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        for (ORKTableCellItem *cellItem in section.items) {
            id answer = _savedAnswers[cellItem.formItem.identifier];
            if (!ORKIsAnswerEmpty(answer)) {
                NSNumber *sectionNumber = [NSNumber numberWithUnsignedInteger:idx];
                [_answeredSections addObject:sectionNumber];
            }
        }
    }];
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
                    ORK_Log_Error("Error fetching default for %@: %@", formItem, error);
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

        _formItemCells = [NSMutableSet new];
        
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
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
                if (@available(iOS 13.0, *)) {
                    [_tableView setBackgroundColor:[UIColor systemGroupedBackgroundColor]];
                } else {
                    [_tableView setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
                }
                [self.taskViewController.navigationBar setBarTintColor:[_tableView backgroundColor]];
                [self.view setBackgroundColor:[_tableView backgroundColor]];
            }
        } else {
            [_tableView setBackgroundColor:[UIColor clearColor]];
        }
        _headerView = _tableContainer.stepContentView;
        _headerView.stepTopContentImage = self.step.image;
        _headerView.titleIconImage = self.step.iconImage;
        _headerView.stepTitle = self.step.title;
        _headerView.stepText = self.step.text;
        _headerView.stepDetailText = self.step.detailText;
        _headerView.stepHeaderTextAlignment = self.step.headerTextAlignment;
        _headerView.bodyItems = self.step.bodyItems;
        _tableContainer.stepTopContentImageContentMode = self.step.imageContentMode;
        
        _navigationFooterView = _tableContainer.navigationFooterView;
        _navigationFooterView.skipButtonItem = self.skipButtonItem;
        _navigationFooterView.continueEnabled = [self continueButtonEnabled];
        _navigationFooterView.continueButtonItem = self.continueButtonItem;
        _navigationFooterView.optional = self.step.optional;
        _navigationFooterView.footnoteLabel.text = [self formStep].footnote;
        
        // Form steps should always force the navigation controller to be scrollable
        // therefore we should always remove the styling.
        [_navigationFooterView removeStyling];
        
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
    _sections = [NSMutableArray new];
    ORKTableSection *section = nil;
    
    for (ORKFormItem *item in items) {
        BOOL itemRequiresSingleSection = [self doesItemRequireSingleSection:item];

        if (!item.answerFormat) {
            // Add new section
            section = [self createSectionWithItem:item];
            [_sections addObject:section];
            
        } else if (itemRequiresSingleSection || _sections.count == 0) {
            
            [self buildSingleSection:item];
            section = [_sections lastObject];
        } else {
            if (section) {
                [section addFormItem:item];
            }
        }
    }
}

- (void)buildSingleSection:(ORKFormItem *)item {
    ORKTableSection *section = nil;

    // Section header
    if ([item impliedAnswerFormat] == nil) {
        // Add new section
        section = [self createSectionWithItem:item];
        [_sections addObject:section];
        
    // Actual item
    } else {

        // Items require individual section
        if ([self doesItemRequireSingleSection:item]) {
            // Add new section
            section = [self createSectionWithItem:item];
            [_sections addObject:section];

            [section addFormItem:item];

        } else {
            // In case no section available, create new one.
            if (section == nil) {
                section = [self createSectionWithItem:item];
                [_sections addObject:section];
            }
            [section addFormItem:item];
        }
    }
}

- (ORKTableSection *)createSectionWithItem:(ORKFormItem *)item {
    ORKTableSection *section = [[ORKTableSection alloc]  initWithSectionIndex:_sections.count];
    section.title = item.text;
    section.detailText = item.detailText;
    section.learnMoreItem = item.learnMoreItem;
    section.showsProgress = item.showsProgress;
    section.tagText = item.tagText;
    
    return section;
}

- (BOOL)doesItemRequireSingleSection:(ORKFormItem *)item {
    if (item.impliedAnswerFormat == nil) {
        return NO;
    }
    
    ORKAnswerFormat *answerFormat = [item impliedAnswerFormat];
    
    NSArray *singleSectionTypes = @[@(ORKQuestionTypeBoolean),
                                    @(ORKQuestionTypeSingleChoice),
                                    @(ORKQuestionTypeMultipleChoice),
                                    @(ORKQuestionTypeLocation),
                                    @(ORKQuestionTypeSES)];
    
    BOOL multiCellChoices = ([singleSectionTypes containsObject:@(answerFormat.questionType)] &&
                             NO == [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]);

    BOOL scale = (answerFormat.questionType == ORKQuestionTypeScale);
    
    // Items require individual section
    if (multiCellChoices || scale) {
        return YES;
    }
    
    return NO;
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
    for (ORKFormItem *item in [self formItems]) {
        if (!item.optional) {
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

- (void)setShouldPresentInReview:(BOOL)shouldPresentInReview {
    [super setShouldPresentInReview:shouldPresentInReview];
    [_navigationFooterView setHidden:YES];
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

- (BOOL)hasAnswer {
    return (self.savedAnswers != nil);
}

// Not to use `ImmediateNavigation` when current step already has an answer.
// So user is able to review the answer when it is present.
- (BOOL)isStepImmediateNavigation {
    // FIXME: - add explicit property in FormStep to dictate this behavior
//    return [[self formStep] isFormatImmediateNavigation] && [self hasAnswer] == NO && !self.isBeingReviewed;
    return NO;
}

- (ORKStepResult *)result {
    ORKStepResult *parentResult = [super result];
    
    NSArray *items = [self formItems];
    
    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = parentResult.endDate;
    
    NSMutableArray *qResults = [NSMutableArray new];
    for (ORKFormItem *item in items) {

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

- (BOOL)didAutoScrollToNextItem:(ORKFormItemCell *)cell {
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:cell];
    
    if (cell.isLastItem) {
        return NO;
    } else {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:currentIndexPath.section];
        ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
        ORKQuestionType type = nextCell.formItem.impliedAnswerFormat.questionType;

        if ([self doesTableCellTypeUseKeyboard:type]) {
            [_tableView deselectRowAtIndexPath:currentIndexPath animated:NO];

            if ([nextCell isKindOfClass:[ORKFormItemCell class]]) {
                [nextCell becomeFirstResponder];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                });
            }

        } else {
            return NO;
        }
    }

    return YES;
}

- (BOOL)shouldAutoScrollToNextSection:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
    ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
    
    if ([nextCell respondsToSelector:@selector(formItem)] && !_autoScrollCancelled) {
        ORKQuestionType type = nextCell.formItem.impliedAnswerFormat.questionType;
        if ([self doesTableCellTypeUseKeyboard:type] && [nextCell isKindOfClass:[ORKFormItemCell class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)autoScrollToNextSection:(NSIndexPath *)indexPath {
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
    ORKFormItemCell *nextCell = [self.tableView cellForRowAtIndexPath:nextIndexPath];
    [nextCell becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    });
}

- (void)handleAutoScrollForNonKeyboardCell:(ORKFormItemCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ORKTableSection *section = _sections[indexPath.section];
    NSNumber *sectionIndex = [NSNumber numberWithLong:indexPath.section];
    
    if ([cell isKindOfClass:[ORKFormItemCell class]]) {
        if (cell.formItem.answerFormat.impliedAnswerFormat.questionType != ORKQuestionTypeSES) {
            return;
        }
    } else if (section.textChoiceCellGroup.answerFormat.style != ORKChoiceAnswerStyleSingleChoice) {
        return;
    }

    if ((indexPath.section < _sections.count - 1) && [self shouldAutoScrollToNextSection:indexPath] && ![_answeredSections containsObject:sectionIndex]) {
        [self autoScrollToNextSection:indexPath];
    } else if ((indexPath.section == (_sections.count - 1)) && ![_answeredSections containsObject:sectionIndex]) {
        [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:YES];
    } else if (indexPath.section < (_sections.count - 1) && ![_answeredSections containsObject:sectionIndex]) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (BOOL)doesTableCellTypeUseKeyboard:(ORKQuestionType)questionType {
    switch (questionType) {
        case ORKQuestionTypeDecimal:
        case ORKQuestionTypeInteger:
        case ORKQuestionTypeText:
            return YES;
            
        default:
            return NO;
    }
}

#pragma mark NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (_currentFirstResponderCell) {
        if ([_currentFirstResponderCell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
            CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
               CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
               
               if (CGRectGetMaxY(_currentFirstResponderCell.frame) >= CGRectGetMinY(convertedKeyboardFrame)) {
                   
                   [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(convertedKeyboardFrame), 0)];
                   
                   NSIndexPath *currentFirstResponderCellIndex = [self.tableView indexPathForCell:_currentFirstResponderCell];
                   
                   if (currentFirstResponderCellIndex) {
                       [self.tableView scrollToRowAtIndexPath:currentFirstResponderCellIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                   }
               }
        } else {
            CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            
            if ((_currentFirstResponderCell.frame.origin.y + _currentFirstResponderCell.frame.size.height) >= (self.view.frame.size.height - keyboardSize.height)) {
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + TableViewYOffsetStandard, 0);
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    ORKTableSection *sectionObject = (ORKTableSection *)_sections[section];
    return sectionObject.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section, (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        ORKTableSection *section = (ORKTableSection *)_sections[indexPath.section];
        ORKTableCellItem *cellItem = [section items][indexPath.row];
        bool isLastItem = [section items].count == indexPath.row + 1;
        bool isFirstItemWithSectionWithoutTitle = indexPath.row == 0 && !section.title;
        ORKFormItem *formItem = cellItem.formItem;
        id answer = _savedAnswers[formItem.identifier];
        
        if (section.textChoiceCellGroup && ([section.textChoiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier] != nil)) {
            [section.textChoiceCellGroup setAnswer:answer];
            section.textChoiceCellGroup.delegate = self;
            ORKChoiceViewCell *choiceViewCell = nil;
            choiceViewCell = [section.textChoiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier];
            if ([choiceViewCell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
                ORKChoiceOtherViewCell *choiceOtherViewCell = (ORKChoiceOtherViewCell *)choiceViewCell;
                choiceOtherViewCell.delegate = self;
            }
            choiceViewCell.useCardView = [self formStep].useCardView;
            choiceViewCell.cardViewStyle = [self formStep].cardViewStyle;
            choiceViewCell.isLastItem = isLastItem;
            choiceViewCell.isFirstItemInSectionWithoutTitle = isFirstItemWithSectionWithoutTitle;
            [choiceViewCell layoutSubviews];
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
                case ORKQuestionTypeSES: {
                    class = [ORKFormItemSESCell class];
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
                    formCell.cardViewStyle = [self formStep].cardViewStyle;
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    } else {
        // Dismiss other textField's keyboard
        [tableView endEditing:NO];
        
        ORKTableSection *section = _sections[indexPath.section];
        [section.textChoiceCellGroup didSelectCellAtIndexPath:indexPath];
    }
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
    NSString *tagText = _sections[section].tagText;
    BOOL hasMultipleChoiceFormItem = NO;
    
    if (_sections[section].showsProgress) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerTotalProgressInfoForStep:currentStep:)]) {
            ORKTaskTotalProgress progressInfo = [self.delegate stepViewControllerTotalProgressInfoForStep:self currentStep:self.step];
            if (progressInfo.stepShouldShowTotalProgress) {
                sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + progressInfo.currentStepStartingProgressPosition)), ORKLocalizedStringFromNumber(@(progressInfo.total))];
            }
        }
        
        if (!sectionProgressText) {
            // only display progress label if there are more than 1 sections in the form step
            if ([_sections count] > 1) {
             sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + 1)), ORKLocalizedStringFromNumber(@([_sections count]))];
            }
        }
    }
    
    if (_sections[section].learnMoreItem) {
        learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:_sections[section].learnMoreItem];
        learnMoreView.delegate = self;
    }
    
    if (_sections[section].items.count > 0) {
        ORKTableCellItem *tableCellItem = (ORKTableCellItem *)_sections[section].items.firstObject;
        ORKFormItem *firstFormItem = tableCellItem.formItem;
        
        if (firstFormItem.impliedAnswerFormat != nil) {
            if (firstFormItem.impliedAnswerFormat.questionType == ORKQuestionTypeMultipleChoice) {
                hasMultipleChoiceFormItem = YES;
            }
        }
    }
    
    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (cardHeaderView == nil && title) {
        cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:title
                                                             detailText:detailText
                                                          learnMoreView:learnMoreView
                                                           progressText:sectionProgressText
                                                                tagText:tagText
                                                             showBorder:([self formStep].cardViewStyle == ORKCardViewStyleBordered)
                                                  hasMultipleChoiceItem:hasMultipleChoiceFormItem];
    }
    
    return cardHeaderView;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    ORKFormStep *formStep = [self formStep];
    if (formStep.footerText != nil && (section == (tableView.numberOfSections - 1))) {
        return formStep.footerText;
    }

    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == tableView.numberOfSections - 1 ? UITableViewAutomaticDimension : 10;
}

#pragma mark ORKFormItemCellDelegate

- (void)formItemCellDidBecomeFirstResponder:(ORKFormItemCell *)cell {
    if (_currentFirstResponderCell) {
        ORKFormItemTextFieldBasedCell *previousSelectedCell = (ORKFormItemTextFieldBasedCell*)_currentFirstResponderCell;
        if (previousSelectedCell != nil && [previousSelectedCell respondsToSelector:@selector(removeEditingHighlight)]) {
            [previousSelectedCell removeEditingHighlight];
        }
    }
    
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
    
    //determines if the table should autoscroll to the next section
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSNumber *sectionIndex = [NSNumber numberWithLong:indexPath.section];
    if (cell.isLastItem && [self shouldAutoScrollToNextSection:indexPath]) {
        [self autoScrollToNextSection:indexPath];
        return;
    } else if (cell.isLastItem && indexPath.section == (_sections.count - 1) && ![_answeredSections containsObject:sectionIndex]) {
        [self.tableView scrollRectToVisible:[self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView] animated:YES];
    }
    
    NSIndexPath *path = [_tableView indexPathForCell:cell];
    
    if (path) {
        ORKTableSection *sectionObject = (ORKTableSection *)_sections[path.section];
        if (path.row < sectionObject.items.count - 1) {
            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_tableView scrollToRowAtIndexPath:nextPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
        }
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
    [self handleAutoScrollForNonKeyboardCell:cell];
    [self updateAnsweredSections];
}

- (BOOL)formItemCellShouldDismissKeyboard:(ORKFormItemCell *)cell {
    if ([self didAutoScrollToNextItem:cell]) {
        return NO;
    }
    return YES;
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
static NSString *const _ORKAnsweredSectionsRestoreKey = @"answeredSections";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_savedAnswers forKey:_ORKSavedAnswersRestoreKey];
    [coder encodeObject:_savedAnswerDates forKey:_ORKSavedAnswerDatesRestoreKey];
    [coder encodeObject:_savedSystemCalendars forKey:_ORKSavedSystemCalendarsRestoreKey];
    [coder encodeObject:_savedSystemTimeZones forKey:_ORKSavedSystemTimeZonesRestoreKey];
    [coder encodeObject:_originalAnswers forKey:_ORKOriginalAnswersRestoreKey];
    [coder encodeObject:_answeredSections forKey:_ORKAnsweredSectionsRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _savedAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswersRestoreKey];
    _savedAnswerDates = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedAnswerDatesRestoreKey];
    _savedSystemCalendars = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemCalendarsRestoreKey];
    _savedSystemTimeZones = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKSavedSystemTimeZonesRestoreKey];
    _originalAnswers = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKOriginalAnswersRestoreKey];
    _answeredSections = [coder decodeObjectOfClass:[NSMutableSet class] forKey:_ORKAnsweredSectionsRestoreKey];
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
    BOOL immediateNavigation = [self isStepImmediateNavigation];
    ORKTableSection *section = _sections[indexPath.section];
    ORKTableCellItem *cellItem = section.items[indexPath.row];
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
    
    ORKFormItemCell *cell = (ORKFormItemCell *)[_tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
        [self handleAutoScrollForNonKeyboardCell:cell];
    }
    [self updateAnsweredSections];

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
    [self.taskViewController learnMoreButtonPressedWithStep:learnMoreStep fromStepViewController:self];
}

@end
