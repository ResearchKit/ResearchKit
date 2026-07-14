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
#import "ORKColorChoiceCellGroup.h"
#import "ORKFormItemCell.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTableCellItem.h"
#import "ORKTableCellItemIdentifier.h"
#import "ORKTableContainerView.h"
#import "ORKStepContentView.h"
#import "ORKBodyItem.h"
#import "ORKLearnMoreView.h"

#import "ORKBodyItem.h"

#import "ORKLearnMoreStepViewController.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKTextChoiceCellGroup.h"
#import "ORKAnswerTextView.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKAnswerFormat+FormStepViewControllerAdditions.h"
#import "ORKCollectionResult_Private.h"
#import "ORKQuestionResult_Private.h"
#import "ORKFormItem_Internal.h"
#import "ORKFormStep_Internal.h"
#import "ORKFormStepViewController_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"

#import "ORKSESSelectionView.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKChoiceViewCell+ORKTextChoice.h"
#import "ORKAccessibilityFunctions.h"
#import "ORKTagLabel.h"

#import "ORKQuestionStep.h"

#import "ORKFormStepViewController+TextChoiceOtherAdditions.h"

#import <Researchkit/ORKFormItemVisibilityRule.h>
#import <ResearchKitUI/ResearchKitUI-Swift.h>
#import <ResearchKit/ResearchKit-Swift.h>


static const CGFloat TableViewYOffsetStandard = 30.0;
static const NSTimeInterval DelayBeforeAutoScroll = 0.25;

CGFloat TableViewHorizontalMargin(void);
CGFloat TableViewHorizontalMargin(void) {
    return 22;
}

static CGFloat ORKLabelWidth(NSString *text) {
    static ORKCaption1Label *sharedLabel;

    if (sharedLabel == nil) {
        sharedLabel = [ORKCaption1Label new];
    }

    sharedLabel.text = text;

    return ceil([sharedLabel textRectForBounds:CGRectInfinite limitedToNumberOfLines:1].size.width);
}

NSString * const ORKFormStepViewAccessibilityIdentifier = @"ORKFormStepView";
NSString * const ORKSurveyCardHeaderViewIdentifier = @"SurveyCardHeaderViewIdentifier";
NSString * const WarningStateFooterViewIdentifier =  @"WarningStateFooterViewIdentifier";
NSString * const ORKDontKnowChoiceViewCellReuseIdentifier = @"ORKDontKnowChoiceViewCell";


#pragma mark - ORKFormItem Category Interface

@interface ORKFormItem (FormStepViewControllerExtensions)

- (BOOL)requiresSingleSection;

@end


#pragma mark - ORKFormStepViewController Category Interfaces

@interface ORKFormStepViewController (UITableViewDelegate) <UITableViewDelegate>

@end

@interface ORKFormStepViewController (ORKFormItemCellDelegate) <ORKFormItemCellDelegate>

@end

@interface ORKFormStepViewController (ORKTableContainerViewDelegate) <ORKTableContainerViewDelegate>

@end

@interface ORKFormStepViewController (ORKChoiceOtherViewCellDelegate) <ORKChoiceOtherViewCellDelegate>

@end

@interface ORKFormStepViewController (ORKLearnMoreViewDelegate) <ORKLearnMoreViewDelegate>

@end


@interface ORKFormStepViewController ()

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableViewDiffableDataSource<NSString *, ORKTableCellItemIdentifier *> *diffableDataSource;
@property (nonatomic, strong) ORKStepContentView *headerView;

@property (nonatomic, strong) NSMutableDictionary *savedAnswers;
@property (nonatomic, strong) NSMutableDictionary *savedAnswerDates;
@property (nonatomic, strong) NSMutableDictionary *savedSystemCalendars;
@property (nonatomic, strong) NSMutableDictionary *savedSystemTimeZones;
@property (nonatomic, strong) NSDictionary *originalAnswers;

@property (nonatomic, strong) NSMutableDictionary *savedDefaults;

@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSNumber *> *tableCellHeightMapping;

@end


@implementation ORKFormStepViewController {
    ORKAnswerDefaultSource *_defaultSource;
    NSMutableSet *_formItemCells;

    NSMutableSet<NSString *> *_identifiersOfAnsweredSections;
    BOOL _skipped;
    BOOL _autoScrollCancelled;
    UITableViewCell *_currentFirstResponderCell;
    NSArray<NSLayoutConstraint *> *_constraints;
    CGFloat _maxLabelWidth;
}

#pragma mark - Initialization

- (instancetype)ORKFormStepViewController_initWithResult:(ORKResult *)result {
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
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


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.view.accessibilityIdentifier = ORKFormStepViewAccessibilityIdentifier;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAnsweredSections];
    
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    NSMutableSet *types = [NSMutableSet set];
    for (ORKFormItem *item in [self answerableFormItems]) {
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
                    ORK_Log_Debug("Authorization: %@",error);
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
#endif
    
    // Reset skipped flag - result can now be non-empty
    _skipped = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    _autoScrollCancelled = NO;
    [_tableContainer resizeFooterToFit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _autoScrollCancelled = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (BOOL)isContentSizeWithinFrame {
    return _tableView.contentSize.height <= _tableView.bounds.size.height;
}

- (BOOL)isContentSizeLargerThanFrame {
    BOOL isContentSizeLargerThanBounds = _tableView.contentSize.height > _tableView.bounds.size.height;
    BOOL multipleCells = [self visibleFormItems].count >= 2;
    return (isContentSizeLargerThanBounds && multipleCells);
}


#pragma mark - Constraints

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _tableContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _constraints = nil;

    _constraints = @[
        [_tableContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableContainer.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ];
    [NSLayoutConstraint activateConstraints:_constraints];
}


#pragma mark - Super Class Override

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
        _formItemCells = [NSMutableSet new];
        
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainer.tableContainerDelegate = self;
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        _tableView = _tableContainer.tableView;
        _tableView.delegate = self;
        
        // If a new cell is created, it must be accounted for within the _registerCellClassesInTableView method
        [self _registerCellClassesInTableView:_tableView];

        // Intantiate the diffable data source
        ORKWeakTypeOf(self) weakSelf = self;
        _diffableDataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:_tableView
                                                                          cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, ORKTableCellItemIdentifier *  _Nonnull itemIdentifier) {
            // The cellForIndexPath method below does the work to determine which cell to return for a specific indexPath
            return [weakSelf _tableView:tableView cellForIndexPath:indexPath itemIdentifier:itemIdentifier];
        }];
        
        // Create a new diffable snapshot
        [self _createDiffableSnapshot:_diffableDataSource withCompletion:nil];
        
        // Set the tableView's dataSource to the instantiated _diffableDataSource
        _tableView.dataSource = _diffableDataSource;

        _tableView.clipsToBounds = YES;
        _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.sectionFooterHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);

        if ([self formStep].useCardView) {
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (ORKNeedWideScreenDesign(self.view)) {
                [_tableView setBackgroundColor:[UIColor clearColor]];
                [self.taskViewController setNavigationBarColor:ORKColor(ORKBackgroundColorKey)];
                [self.view setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
            }
            else {
                [_tableView setBackgroundColor:[UIColor systemGroupedBackgroundColor]];
                [self.taskViewController setNavigationBarColor:[_tableView backgroundColor]];
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
        
        if (self.readOnlyMode) {
            _navigationFooterView.optional = YES;
            [_navigationFooterView setNeverHasContinueButton:YES];
            _navigationFooterView.skipEnabled = [self skipButtonEnabled];
            _navigationFooterView.skipButton.accessibilityTraits = UIAccessibilityTraitStaticText;
        }
        [self setupConstraints];
    }
}

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

- (BOOL)continueButtonEnabled {
    BOOL enabled = ([self allAnsweredFormItemsAreValid] && [self allNonOptionalFormItemsHaveAnswers]);
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

- (void)setShouldPresentInReview:(BOOL)shouldPresentInReview {
    [super setShouldPresentInReview:shouldPresentInReview];
    [_navigationFooterView setHidden:YES];
}

- (BOOL)showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (_skipped) {
        return NO;
    }
    
    return [super showValidityAlertWithMessage:text];
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


#pragma mark - Diffable Data Source

- (void)_createDiffableSnapshot:(UITableViewDiffableDataSource<NSString *, ORKTableCellItemIdentifier *> *)dataSource
                 withCompletion:(void (^ _Nullable)(void))completion {
    NSDiffableDataSourceSnapshot *snapshot = dataSource.snapshot;
    _maxLabelWidth = -1.0;
    
    // make a brand new snapshot that holds the section and item identifiers that result from analyzing the formItems
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *newSnapshot = [self _getNewSnapShotWithSectionAndItemIDsAdded];
    
    // remove stale sections and items
    [self _removeStaleSectionAndItemsFromSnapShot:snapshot newSnapshot:newSnapshot];
        
    // Now we can run through the original snapshot and update it based on our new snapshot
    [self _updateSectionAndItemPositionsWithinSnapshot:snapshot newSnapshot:newSnapshot];
    
    NSDiffableDataSourceSnapshot *originalSnapshot = dataSource.snapshot;
    if ([originalSnapshot isEqual:snapshot] == NO) {
        // update progress text of sections within the snapshot
        [self _updateProgressTextOfSurveyHeadersInSnapshot:snapshot];

        // don't bother animating if there was nothing in the original snapshot to start with
        BOOL shouldAnimateDifferences = (originalSnapshot.numberOfItems > 0);
        [dataSource applySnapshot:snapshot animatingDifferences:shouldAnimateDifferences completion:^{
            if (completion != nil) {
                completion();
            }
        }];

        // If the footer needs to go back to a larger size, we need to resize here after applying the snapshot so the layout calculations can be based on the new/updated content
        if (![self isContentSizeLargerThanFrame]) {
            [_tableContainer resizeFooterToFit];
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion();
            }
        });
    }
}

- (void)_removeStaleSectionAndItemsFromSnapShot:(NSDiffableDataSourceSnapshot *)snapshot
                                    newSnapshot:(NSDiffableDataSourceSnapshot *)newSnapshot {
    // remove stale sections
    {
        NSMutableSet<NSString *> *originalSectionIdentifiers = [NSMutableSet setWithArray:[snapshot sectionIdentifiers]];
        NSSet<NSString *> *newSectionIdentifiers = [NSSet setWithArray:[newSnapshot sectionIdentifiers]];
        [originalSectionIdentifiers minusSet:newSectionIdentifiers];
        [snapshot deleteSectionsWithIdentifiers:[originalSectionIdentifiers allObjects]];
    }

    // remove stale items
    {
        NSMutableSet<ORKTableCellItemIdentifier *> *originalItemIdentifiers = [NSMutableSet setWithArray:[snapshot itemIdentifiers]];
        NSSet<ORKTableCellItemIdentifier *> *newItemIdentifiers = [NSSet setWithArray:[newSnapshot itemIdentifiers]];
        [originalItemIdentifiers minusSet:newItemIdentifiers];
        [snapshot deleteItemsWithIdentifiers:[originalItemIdentifiers allObjects]];
    }
}

- (void)_updateSectionAndItemPositionsWithinSnapshot:(NSDiffableDataSourceSnapshot *)snapshot
                                         newSnapshot:(NSDiffableDataSourceSnapshot *)newSnapshot {
    for (NSString *eachSectionIdentifier in [newSnapshot sectionIdentifiers]) {
        
        // put the section in the right spot
        // yes, we could keep a counter outside the for loop. Computing index here so there's less state to manage
        NSInteger index = [newSnapshot indexOfSectionIdentifier:eachSectionIdentifier];
        
        NSUInteger originalCountOfSections = [snapshot numberOfSections];
        if (originalCountOfSections > index) {
            NSString *originalSectionIdentiferAtIndex = [[snapshot sectionIdentifiers] objectAtIndex:index];
            if ([originalSectionIdentiferAtIndex isEqual:eachSectionIdentifier]) {
                // the same section identifier lives at the same index, no-op
            } else if ([snapshot indexOfSectionIdentifier:eachSectionIdentifier] != NSNotFound) {
                // the same section identifier lives in both, but at different index in each: move
                [snapshot moveSectionWithIdentifier:eachSectionIdentifier beforeSectionWithIdentifier:originalSectionIdentiferAtIndex];
            } else {
                // the sectionIdentifer doesn't exist in the original snapshot, insert ahead of whatever's currently at this index
                [snapshot insertSectionsWithIdentifiers:@[eachSectionIdentifier] beforeSectionWithIdentifier:originalSectionIdentiferAtIndex];
            }
        } else {
            // More sections in the new snapshot than the old, just append
            [snapshot appendSectionsWithIdentifiers:@[eachSectionIdentifier]];
        }
        
        for (ORKTableCellItemIdentifier *eachItemIdentifier in [newSnapshot itemIdentifiersInSectionWithIdentifier:eachSectionIdentifier]) {
            
            // put the items in the right spot
            // yes, we could keep a counter outside this for loop. Computing this index so there's less state to manage
            NSInteger itemIndex = [newSnapshot indexOfItemIdentifier:eachItemIdentifier];

            NSUInteger originalCountOfItems = [snapshot numberOfItems];
            if (originalCountOfItems > itemIndex) {
                ORKTableCellItemIdentifier *originalItemIdentiferAtIndex = [[snapshot itemIdentifiers] objectAtIndex:itemIndex];
                if ([originalItemIdentiferAtIndex isEqual:eachItemIdentifier]) {
                    // the same itemIdentifier lives at the same index, no-op
                } else if ([snapshot indexOfItemIdentifier:eachItemIdentifier] != NSNotFound) {
                    // the same itemIdentifier lives in both, but at different index in each: move
                    [snapshot moveItemWithIdentifier:eachItemIdentifier beforeItemWithIdentifier:originalItemIdentiferAtIndex];
                } else if ([eachItemIdentifier.formItemIdentifier isEqual:originalItemIdentiferAtIndex.formItemIdentifier]) {
                    // the itemIdentifer doesn't exist in the original snapshot, insert ahead of whatever's currently at this index
                    [snapshot insertItemsWithIdentifiers:@[eachItemIdentifier] beforeItemWithIdentifier:originalItemIdentiferAtIndex];
                } else {
                    // the itemIdentifier doesn't exist in the original snapshot, append to current section
                    [snapshot appendItemsWithIdentifiers:@[eachItemIdentifier] intoSectionWithIdentifier:eachSectionIdentifier];
                }

                // There may be a case where we don't support items moving between sections, but that shouldn't happen since the only way formItems can move around like that is if you feed the stepViewController a new step. Resetting the step builds a brand new tableView and datasource, so you shouldn't hit that problem.
            } else {
                if ([snapshot indexOfItemIdentifier:eachItemIdentifier] != NSNotFound) {
                    // item was there in original snapshot, moved in new snapshot, beyond the range of old snapshot's last item
                    id lastItemIdentifier = [[snapshot itemIdentifiers] lastObject];
                    [snapshot moveItemWithIdentifier:eachItemIdentifier afterItemWithIdentifier:lastItemIdentifier];
                } else {
                    // the itemIdentifer doesn't exist in the original snapshot
                    [snapshot appendItemsWithIdentifiers:@[eachItemIdentifier] intoSectionWithIdentifier:eachSectionIdentifier];
                }
            }
        }

    }
}

- (void)_updateProgressTextOfSurveyHeadersInSnapshot:(NSDiffableDataSourceSnapshot *)snapshot {
    // update progress text of section header views
    NSUInteger totalSections = [snapshot numberOfSections];
    if (totalSections > 1) {
        for (int i = 0; i < totalSections; i++) {
            ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[_tableView headerViewForSection:i];
            
            NSString *sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(i + 1)), ORKLocalizedStringFromNumber(@(snapshot.numberOfSections))];
            
            [cardHeaderView setProgressText:sectionProgressText];
        }
    } else {
        ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[_tableView headerViewForSection:0];
        [cardHeaderView setProgressText:nil];
    }
}

- (NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *)_getNewSnapShotWithSectionAndItemIDsAdded {
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *newSnapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    
    NSArray<ORKFormItem *> *formItems = [[self visibleFormItems] copy];
    for (ORKFormItem *eachItem in formItems) {
        
        NSString *formItemIdentifier = eachItem.identifier;
        ORKAnswerFormat *answerFormat = eachItem.impliedAnswerFormat;

        if (formItemIdentifier == nil) {
            ORK_Log_Info("%@ Refusing to deal with formItem missing identifier", self);
        } else if (answerFormat == nil) {
            // has no answerFormat
            // treat these as sections
            [newSnapshot appendSectionsWithIdentifiers:@[formItemIdentifier]];
        } else {
            NSAssert((answerFormat != nil), @"building tableView data source: assumed answerFormat was nonnull");
            NSAssert((formItemIdentifier != nil), @"building tableView data source: assumed formItemIdentifier was nonnull");
            // if we're here, we expect to add at least one new itemIdentifier
            
            // Step 1/2: Do we need to make a section for this item to land in?
            if ((eachItem.requiresSingleSection) || ([newSnapshot numberOfSections] == 0)) {
                [newSnapshot appendSectionsWithIdentifiers:@[formItemIdentifier]];
            }
            
            // Step 2/2: Are we adding a single identifier for this formItem or exploding the formItem into an identifier per choice?
            if (ORKDynamicCast(answerFormat, ORKTextChoiceAnswerFormat) != nil || ORKDynamicCast(answerFormat, ORKColorChoiceAnswerFormat) != nil) {
                // Make one row per choice, we probably made a section already since formItems with choice answerFormats are requiresSingleSection==YES
                NSArray *choices = answerFormat.choices;
                [choices enumerateObjectsUsingBlock:^(id eachChoice, NSUInteger index, BOOL *stop) {
                    ORKTableCellItemIdentifier *itemIdentifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItemIdentifier choiceIndex:index];
                    [newSnapshot appendItemsWithIdentifiers:@[itemIdentifier]];
                }];
                // Add a Don't Know row after the choices if the original answer format requests it
                if ([eachItem.answerFormat shouldShowDontKnowButton]) {
                    ORKTableCellItemIdentifier *dontKnowIdentifier = [ORKTableCellItemIdentifier dontKnowIdentifierWithFormItemIdentifier:formItemIdentifier];
                    [newSnapshot appendItemsWithIdentifiers:@[dontKnowIdentifier]];
                }
            } else {
                // has answerFormat but no choices
                // Convert the formItem itself into a row
                ORKTableCellItemIdentifier *itemIdentifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItemIdentifier choiceIndex:NSNotFound];
                [newSnapshot appendItemsWithIdentifiers:@[itemIdentifier]];
                // Add a Don't Know row after the image choice or location cell if requested
                BOOL isLocationAnswerFormat = NO;
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
                isLocationAnswerFormat = ORKDynamicCast(answerFormat, ORKLocationAnswerFormat) != nil;
#endif
                if ((ORKDynamicCast(answerFormat, ORKImageChoiceAnswerFormat) != nil || isLocationAnswerFormat) && [eachItem.answerFormat shouldShowDontKnowButton]) {
                    ORKTableCellItemIdentifier *dontKnowIdentifier = [ORKTableCellItemIdentifier dontKnowIdentifierWithFormItemIdentifier:formItemIdentifier];
                    [newSnapshot appendItemsWithIdentifiers:@[dontKnowIdentifier]];
                }
            }
        }
    }
    
    return newSnapshot;
}

/// returns YES if the answeredSections changed
- (BOOL)updateAnsweredSections {
    NSSet *oldValue = [_identifiersOfAnsweredSections copy];
    NSMutableSet *newValue = [NSMutableSet new];
    
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> *snapshot = [_diffableDataSource snapshot];
    for (NSString *eachSectionIdentifier in [snapshot sectionIdentifiers]) {
        
        for (ORKTableCellItemIdentifier *itemIdentifier in [snapshot itemIdentifiersInSectionWithIdentifier:eachSectionIdentifier]) {
            id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
            if (ORKIsAnswerEmpty(answer) == NO) {
                
                [newValue addObject:eachSectionIdentifier];
            }
        }

    }
    
    _identifiersOfAnsweredSections = [newValue mutableCopy];
    
    BOOL answeredSectionsChanged = [oldValue isEqualToSet:newValue] ? NO : YES;
    return answeredSectionsChanged;
}

- (void)updateDefaults:(NSMutableDictionary *)defaults {
    _savedDefaults = defaults;
    
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSMutableArray<ORKTableCellItemIdentifier *> *itemIdentifiersToReload = [NSMutableArray array];

    for (ORKFormItemCell *cell in [_tableView visibleCells]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        ORKFormItem *formItem = [self _formItemForIndexPath:indexPath];
        NSString *formItemIdentifier = formItem.identifier;
        if ([cell isKindOfClass:[ORKChoiceViewCell class]]) {

            // Answers need to be saved.
            id answer = _savedAnswers[formItemIdentifier];
            answer = answer ? : _savedDefaults[formItemIdentifier];
            [self setAnswer:answer forIdentifier:formItemIdentifier];
            
        } else {
            cell.defaultAnswer = _savedDefaults[formItemIdentifier];
        }
        [itemIdentifiersToReload addObject:[_diffableDataSource itemIdentifierForIndexPath:indexPath]];
    }
    
    _skipped = NO;
    
    [snapshot reloadItemsWithIdentifiers:itemIdentifiersToReload];
    [_diffableDataSource applySnapshot:snapshot animatingDifferences:NO];
    
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];
}

- (void)refreshDefaults {
    // defaults only come from HealthKit
    
    NSArray *formItems = [self allFormItems];
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


#pragma mark - Form Item

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
    for (ORKFormItem *item in [self answerableFormItems]) {
        id answer = _savedAnswers[item.identifier];
        if (ORKIsAnswerEmpty(answer) == NO && ![item.impliedAnswerFormat isAnswerValid:answer]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allNonOptionalFormItemsHaveAnswers {
    for (ORKFormItem *item in [self answerableFormItems]) {
        if (!item.optional) {
            id answer = _savedAnswers[item.identifier];
            if (ORKIsAnswerEmpty(answer) || ![item.impliedAnswerFormat isAnswerValid:answer]) {
                return NO;
            }
        }
    }
    return YES;
}

- (nullable ORKFormItem *)fetchFirstUnansweredNonOptionalFormItem:(NSArray<ORKFormItem *> *)formItems {
    for (ORKFormItem *item in formItems) {
        if (!item.optional) {
            id answer = _savedAnswers[item.identifier];
            if (ORKIsAnswerEmpty(answer) || ![item.impliedAnswerFormat isAnswerValid:answer]) {
                return item;
            }
        }
    }

    return nil;
}

- (nullable NSString *)fetchSectionThatContainsFormItem:(ORKFormItem *)formItem {
    ORKTableCellItemIdentifier *identifier = [[ORKTableCellItemIdentifier alloc] initWithFormItemIdentifier:formItem.identifier choiceIndex:NSNotFound];
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *result = [snapshot sectionIdentifierForSectionContainingItemIdentifier:identifier];
    
    // in case the formItem turned into a section with choices instead, try looking for the formItemIdentifier as a sectionIdentifier
    result = result ? : formItem.identifier;
    
    return result;
}

- (NSArray<ORKFormItem *> *)allFormItems {
    return [[self formStep] formItems];
}

- (BOOL)isFormItemVisible:(ORKFormItem *)formItem withResult:(ORKTaskResult *)result {
    ORKFormItemVisibilityRule *rule = formItem.visibilityRule;
    BOOL shouldAllowVisibility = (rule == nil) || ([rule formItemVisibilityForTaskResult:result] == YES);
    return shouldAllowVisibility;
}

- (NSArray<ORKFormItem *> *)visibleFormItemsFromResult:(ORKTaskResult *)ongoingTaskResult {
    NSMutableArray<ORKFormItem *> *visibleItemsMutableArray = [NSMutableArray new];

    for (ORKFormItem *eachItem in [self allFormItems]) {
        if ([self isFormItemVisible:eachItem withResult:ongoingTaskResult] == YES) {
            [visibleItemsMutableArray addObject:eachItem];
        }
    }
    
    return [visibleItemsMutableArray copy];
}

- (NSArray<ORKFormItem *> *)visibleFormItems {
    ORKTaskResult *taskResult = [self _ongoingTaskResult];
    NSArray<ORKFormItem *> *visibileFormItems = [self visibleFormItemsFromResult:taskResult];
    return visibileFormItems;
}

- (NSArray *)answerableFormItems {
    NSMutableArray *array = [NSMutableArray new];
    for (ORKFormItem *item in [self visibleFormItems]) {
        if (item.answerFormat != nil) {
            [array addObject:item];
        }
    }
    
    return [array copy];
}

- (nullable ORKFormItem *)_formItemForIndexPath:(NSIndexPath *)indexPath {
    ORKFormItem *result;
    
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    result = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    
    return result;
}

- (nullable ORKFormItem *)_formItemForFormItemIdentifier:(NSString *)formItemIdentifier {
    ORKFormItem *result;

    NSArray<ORKFormItem *> *allFormItems = [self allFormItems];
    
    NSInteger formItemIndex = [allFormItems indexOfObjectPassingTest:^BOOL(ORKFormItem * testItem, NSUInteger testIndex, BOOL *stop) {
        BOOL foundIndex = [testItem.identifier isEqualToString:formItemIdentifier];
        return foundIndex;
    }];
    result = (formItemIndex != NSNotFound) ? [allFormItems objectAtIndex:formItemIndex] : nil;

    return result;
}

- (NSSet<NSString *> *)hiddenFormItemIdentifiersForTaskResult:(ORKTaskResult *)taskResult {
    // make a set of all the identifiers of formItems we want to hide
    NSMutableSet *mutableSet = [NSMutableSet new];
    
    // start with all the formItems
    [[self allFormItems] enumerateObjectsUsingBlock:^(ORKFormItem *eachItem, NSUInteger idx, BOOL *stop) {
        NSString *identifier = eachItem.identifier;
        if (identifier != nil) {
            [mutableSet addObject:identifier];
        }
    }];
    
    // Now remove the visible formItem identifiers. The remaining set are the hidden ones
    [[self visibleFormItemsFromResult:taskResult] enumerateObjectsUsingBlock:^(ORKFormItem *eachItem, NSUInteger idx, BOOL *stop) {
        NSString *identifier = eachItem.identifier;
        if (identifier != nil) {
            [mutableSet removeObject:identifier];
        }
    }];
    
    return [mutableSet copy];
}


#pragma mark - Answer and Results

- (ORKStepResult *)result {
    ORKTaskResult *taskResult = [self _ongoingTaskResult];
    
    // get the stepResult, which should be the last result in the taskResult.results array
    // this stepResult contains everything regardless of visibility rules
    ORKStepResult *stepResult = ORKDynamicCast(taskResult.results.lastObject, ORKStepResult);

    // Make a mutable copy of the stepResult's results array. We're going to remove items from this array
    // rather than build a new array from an empty one. This way we preserve the results that may
    // have been added through ORKStepViewController's `addResult:` API
    NSMutableArray<ORKResult *> *mutableResults = [stepResult.results mutableCopy];

    // walk through the array in reverse so we can use cheap removeObjectAtIndex: to remove results that should be hidden
    NSSet<NSString *> *hiddenFormItemIdentifiers = [self hiddenFormItemIdentifiersForTaskResult:taskResult];
    [stepResult.results enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ORKResult *eachResult, NSUInteger index, BOOL *stop) {
        NSString *identifier = eachResult.identifier;
        if ([hiddenFormItemIdentifiers containsObject:identifier]) {
            [mutableResults removeObjectAtIndex:index];
        }
    }];
    
    stepResult.results = [mutableResults copy];
    return stepResult;
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

- (nullable NSArray *)answersForFormItem:(nonnull ORKFormItem *)formItem {
    return _savedAnswers[formItem.identifier];
}

- (BOOL)hasAnswer {
    return (self.savedAnswers != nil);
}

/// Returns the combination of the delegate's stepViewControllerOngoingResult: ORKTaskResult and the full ORKStepResult for this stepViewController (regardless of formItem visibilityRules)
- (nonnull ORKTaskResult *)_ongoingTaskResult {
    ORKTaskResult *taskResult = nil;

    id <ORKStepViewControllerDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(stepViewControllerOngoingResult:)]) {
        // make a copy of the taskResult since we're going to change its results
        taskResult = [[delegate stepViewControllerOngoingResult:self] copy];
    }

    // in case no taskResult was returned, make one up
    if (taskResult == nil) {
        taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:@"" taskRunUUID:[NSUUID new] outputDirectory:nil];
    }
    
    // start with all the stepResults regardless of visibilityRules
    ORKStepResult *stepResult = [self _stepResultFromFormItems:[self allFormItems]];
    
    // merge the results with the current ongoing task result.
    taskResult.results = [taskResult.results arrayByAddingObject:stepResult];

    return taskResult;
}

- (ORKStepResult *)_stepResultFromFormItems:(NSArray<ORKFormItem *> *)formItems {
    ORKStepResult *parentResult = [super result];

    // "Now" is the end time of the result, which is either actually now,
    // or the last time we were in the responder chain.
    NSDate *now = parentResult.endDate;
    
    NSMutableArray *qResults = [NSMutableArray new];
    for (ORKFormItem *item in formItems) {

        // Only process formItems for which we would have an answerFormat
        if (item.answerFormat == nil) {
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
                nqr.displayUnit = [(ORKNumericAnswerFormat *)impliedAnswerFormat displayUnit];
            }
        }
        
        result.startDate = answerDate;
        result.endDate = answerDate;

        [qResults addObject:result];
    }
    
    parentResult.results = [parentResult.results arrayByAddingObjectsFromArray:qResults] ? : qResults;
    
    return parentResult;
}

- (void)saveAnswer:(id)answer forItemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    NSString *formItemIdentifier = [itemIdentifier formItemIdentifier];
    if (formItemIdentifier != nil) {
        if (answer != nil) {
            [self setAnswer:answer forIdentifier:formItemIdentifier];
        } else {
            [self removeAnswerForIdentifier:formItemIdentifier];
        }
    }
    
    NSIndexPath *indexPath = [_diffableDataSource indexPathForItemIdentifier:itemIdentifier];
    [self answerChangedForIndexPath:indexPath];
}


#pragma mark - Scrolling

// Return NO if we didn't autoscroll
- (BOOL)didAutoScrollToNextItem:(ORKFormItemCell *)cell {
    if (![self _isAutoScrollEnabled]) {
        return NO;
    }
    
    NSIndexPath *currentIndexPath = [self.tableView indexPathForCell:cell];
    
    if (cell.isLastItem) {
        return NO;
    } else {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:currentIndexPath.row + 1 inSection:currentIndexPath.section];
        ORKQuestionType type = [self _formItemForIndexPath:nextIndexPath].impliedAnswerFormat.questionType;

        if ([self doesTableCellTypeUseKeyboard:type]) {
            [_tableView deselectRowAtIndexPath:currentIndexPath animated:NO];
            return [self focusUnansweredCell:cell];
        } else {
            return NO;
        }
    }

    return YES;
}


/// The proposed destination index path for auto-scrolling to the nexr section.
/// @returns The destination index path that should be used when scrolling to the next question, or `nil` if no auto-scroll should occur.
- (NSIndexPath *_Nullable)indexPathForAutoScrollingToNextSectionAfter:(NSIndexPath *)indexPath {
    if (![self _isAutoScrollEnabled] || _autoScrollCancelled) {
        return nil;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)];
    
    ORKTableCellItemIdentifier *nextItemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:nextIndexPath];
    if (nextItemIdentifier) {
        // Technically, cellForRowAtIndexPath could return nil if the tableView hasn't decided to cache the cell
        // Guarantee ourselves a cell by using dequeueReusableCellWithIdentifier—the only reason we need the cell is to test
        // the cell's type, not for actual display, so using any cell paired with the reuseIdentifier should be fine
        // do *not* use dequeueReusableCellWithIdentifier:indexPath: since that method should only be called within the dataSource
        // tableView:cellForRowAtIndexPath: method
        ORKFormItem *nextFormItem = [self _formItemForIndexPath:nextIndexPath];
        if (!nextFormItem) {
            return nil;
        }
        NSString *nextReuseIdentifier = [self cellReuseIdentifierFromFormItem:nextFormItem cellItemIdentifier:nextItemIdentifier];
        // Can't autoscroll to something that doesn't exist
        UITableViewCell *nextCell = [_tableView dequeueReusableCellWithIdentifier:nextReuseIdentifier];
        if (!nextCell) {
            return nil;
        }
        // Don't autoscroll to a cell that already has an answer.
        if (self.savedAnswers[nextFormItem.identifier]) {
            return nil;
        }
        return nextIndexPath;
    } else {
        NSString *nextSectionIdentifier = [_diffableDataSource sectionIdentifierForIndex:nextIndexPath.section];
        ORKFormItem *formItem = [self _formItemForFormItemIdentifier:nextSectionIdentifier];
        if (!formItem) {
            return nil;
        } else {
            // We need to scroll to a zero-item section. This requires us to adjust the index path.
            return [NSIndexPath indexPathForRow:NSNotFound inSection:nextIndexPath.section];
        }
    }
}


/// Determines if we should auto-scroll to the next section
- (BOOL)shouldAutoScrollToNextSectionAfter:(NSIndexPath *)indexPath {
    return [self indexPathForAutoScrollingToNextSectionAfter:indexPath] != nil;
}


- (void)autoScrollToNextSectionAfter:(NSIndexPath *)indexPath {
    if (![self _isAutoScrollEnabled]) {
        return;
    }
    NSIndexPath *scrollDestinationIndexPath = [self indexPathForAutoScrollingToNextSectionAfter:indexPath];
    if (!scrollDestinationIndexPath) {
        // If the index path returned by -shouldAutoScrollToNextSection: is nil, we're not supposed to auto-scroll to the next section.
        return;
    }
    UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:scrollDestinationIndexPath];
    if (!(nextCell && [self focusUnansweredCell:nextCell])) {
        // if we didn't change focus, we need to scroll.
        // otherwise (if we did change focus), that'll take care of the scrolling for us.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // Ensure section destination index path is still valid since there is a delay, during which the index path can
            // become invalid.
            if (scrollDestinationIndexPath.section < _diffableDataSource.snapshot.numberOfSections) {
                [_tableView scrollToRowAtIndexPath:scrollDestinationIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        });
        // if we did change focus, then that will perform the scrolling
    }
}

- (void)scrollToFirstUnansweredSection {
    if (![self _isAutoScrollEnabled]) {
        return;
    }
    
    ORKFormItem *formItem = [self fetchFirstUnansweredNonOptionalFormItem:[self answerableFormItems]];
    [self scrollToFormItem:formItem];
}

- (void)scrollToFooter {
    if (![self _isAutoScrollEnabled]) {
        return;
    }
    
    CGRect tableFooterRect = [self.tableView convertRect:self.tableView.tableFooterView.bounds fromView:self.tableView.tableFooterView];
    [self.tableView scrollRectToVisible:tableFooterRect animated:YES];
}

- (void)scrollToFormItem:(ORKFormItem *)formItem {
    if (![self _isAutoScrollEnabled]) {
        return;
    }
    
    NSString *sectionIdentifier = [self fetchSectionThatContainsFormItem:formItem];
    NSInteger section = [[_diffableDataSource snapshot] indexOfSectionIdentifier:sectionIdentifier];
    if (section != NSNotFound) {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:section];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (BOOL)_isAutoScrollEnabled {
    ORKFormStep *formStep = [self formStep];
    return formStep.autoScrollEnabled;
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

/// returns NO if we couldn't make the cell become first responder, or the cell has an answer already
- (BOOL)focusUnansweredCell:(UITableViewCell *)cell {
    BOOL result = NO;
    
    ORKFormItemCell *formItemCell = ORKDynamicCast(cell, ORKFormItemCell);
    
    // don't try to make cell first responder if it already has an answer
    BOOL cellNeedsBecomeFirstResponder = (self.savedAnswers[formItemCell.formItem.identifier] == nil);
    if (cellNeedsBecomeFirstResponder == YES) {
        result = [formItemCell becomeFirstResponder];
    }
    
    return result;
}

- (nullable ORKTextChoiceAnswerFormat *)textChoiceAnswerFormatForIndexPath:(NSIndexPath *)indexPath {
    ORKFormItem *formItem = [self _formItemForIndexPath:indexPath];
    ORKTextChoiceAnswerFormat *result = ORKDynamicCast(formItem.impliedAnswerFormat, ORKTextChoiceAnswerFormat);
    return result;
}

- (nullable ORKColorChoiceAnswerFormat *)colorChoiceAnswerFormatForIndexPath:(NSIndexPath *)indexPath {
    ORKFormItem *formItem = [self _formItemForIndexPath:indexPath];
    ORKColorChoiceAnswerFormat *result = ORKDynamicCast(formItem.impliedAnswerFormat, ORKColorChoiceAnswerFormat);
    return result;
}

#pragma mark - TableView and FooterView

- (void)_registerCellClassesInTableView:(UITableView *)tableView {
    
    // Register all of the row cells for our formItems
    for (ORKFormItem *eachItem in [self allFormItems]) {
        
        // our cell choices are based on answerFormat
        ORKAnswerFormat *answerFormat = eachItem.impliedAnswerFormat;
        NSString *reuseIdentifier = eachItem.identifier;
        Class class = answerFormat.formStepViewControllerCellClass;

        if ((class != nil) && (reuseIdentifier != nil)) {
            [tableView registerClass:class forCellReuseIdentifier:reuseIdentifier];
            BOOL isLocationAnswerFormat = NO;
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
            isLocationAnswerFormat = ORKDynamicCast(answerFormat, ORKLocationAnswerFormat) != nil;
#endif
            if ((ORKDynamicCast(answerFormat, ORKImageChoiceAnswerFormat) != nil || isLocationAnswerFormat) && [eachItem.answerFormat shouldShowDontKnowButton]) {
                [tableView registerClass:[ORKChoiceViewCell class] forCellReuseIdentifier:ORKDontKnowChoiceViewCellReuseIdentifier];
            }
        } else if (answerFormat.choices.count > 0) {
            for (id eachChoice in answerFormat.choices) {
                if ([eachChoice isKindOfClass:[ORKColorChoice class]]) {
                    [tableView registerClass:[ORKColorChoiceCell class] forCellReuseIdentifier:NSStringFromClass([eachChoice class])];
                } else if ([eachChoice isKindOfClass:[ORKTextChoiceOther class]]) {
                    [tableView registerClass:[ORKChoiceOtherViewCell class] forCellReuseIdentifier:NSStringFromClass([eachChoice class])];
                } else {
                    [tableView registerClass:[ORKChoiceViewCell class] forCellReuseIdentifier:NSStringFromClass([eachChoice class])];
                }
            }
            if ([eachItem.answerFormat shouldShowDontKnowButton]) {
                [tableView registerClass:[ORKChoiceViewCell class] forCellReuseIdentifier:ORKDontKnowChoiceViewCellReuseIdentifier];
            }
        } else {
            ORK_Log_Debug("Not registering cell class '%@' for formItem with identifier '%@' answerFormat: %@", class, reuseIdentifier, answerFormat);
        }
    }
    
    // Now register the header cells
    [_tableView registerClass:[ORKSurveyCardHeaderView class] forHeaderFooterViewReuseIdentifier:ORKSurveyCardHeaderViewIdentifier];
    [_tableView registerClass:[WarningStateFooterView class] forHeaderFooterViewReuseIdentifier:WarningStateFooterViewIdentifier];
    
}

- (void)resizeORKChoiceOtherViewCell:(ORKChoiceOtherViewCell *)choiceOtherViewCell withTextChoice:(ORKTextChoiceOther *)textChoice {
    [_tableView beginUpdates];
    [choiceOtherViewCell setupWithText:textChoice.textViewText placeholderText:textChoice.textViewPlaceholderText];
    [_tableView endUpdates];
}

- (NSString *)cellReuseIdentifierFromFormItem:(ORKFormItem *)formItem cellItemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    NSString *result;

    if (itemIdentifier.isDontKnow) {
        return ORKDontKnowChoiceViewCellReuseIdentifier;
    }

    NSString *formItemIdentifier = itemIdentifier.formItemIdentifier;
    if (itemIdentifier.choiceIndex == NSNotFound) {
        result = formItemIdentifier;
    } else {
        ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
        id choice = [answerFormat.choices objectAtIndex:itemIdentifier.choiceIndex];
        result = NSStringFromClass([choice class]);
    }
    
    return result;
}

- (UITableViewCell *)_tableView:(UITableView *)tableView
               cellForIndexPath:(NSIndexPath *)indexPath
                 itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    NSString *formItemIdentifier = itemIdentifier.formItemIdentifier;
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:formItemIdentifier];
    
    NSString *reuseIdentifier = [self cellReuseIdentifierFromFormItem:formItem cellItemIdentifier:itemIdentifier];
    NSAssert((reuseIdentifier != nil), @"reuseIdentifier cannot be nil");

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.userInteractionEnabled = !self.readOnlyMode;
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"%@_%ld", formItemIdentifier, (long)indexPath.row];
    
    // Attempt to cast the tableViewCell to a ORKFormItemCell
    {
        ORKFormItemCell *formCell = [self _castTableViewCellToFormItemCell:cell
                                                            itemIdentifier:itemIdentifier
                                                                  formItem:formItem
                                                                 tableView:tableView
                                                                 indexPath:indexPath];
        
        if (formCell != nil) {
            return formCell;
        }
    }
    
    // Attempt to cast the tableViewCell to a ORKColorChoiceCell
    {
        ORKColorChoiceCell *colorChoiceCell = [self _castTableViewCellToColorChoiceCell:cell
                                                                         itemIdentifier:itemIdentifier
                                                                               formItem:formItem];

        if (colorChoiceCell != nil) {
            return colorChoiceCell;
        }
    }

    // Configure a Don't Know cell — must come before _castTableViewCellToChoiceViewCell, which
    // would otherwise claim the cell (it is an ORKChoiceViewCell) and return it unconfigured.
    if (itemIdentifier.isDontKnow) {
        ORKChoiceViewCell *dontKnowCell = ORKDynamicCast(cell, ORKChoiceViewCell);
        if (dontKnowCell != nil) {
            NSString *dontKnowText = formItem.answerFormat.customDontKnowButtonText
                ?: ORKLocalizedString(@"SLIDER_I_DONT_KNOW", nil);
            [dontKnowCell setPrimaryText:dontKnowText];

            id savedAnswer = _savedAnswers[formItem.identifier];
            BOOL isDontKnowSelected = [savedAnswer isKindOfClass:[ORKDontKnowAnswer class]];
            [dontKnowCell setCellSelected:isDontKnowSelected highlight:NO];

            dontKnowCell.isLastItem = YES;
            dontKnowCell.tintColor = ORKViewTintColor(self.view);
            dontKnowCell.useCardView = [self formStep].useCardView;
            dontKnowCell.cardViewStyle = [self formStep].cardViewStyle;
            return dontKnowCell;
        }
    }

    // Attempt to cast the tableViewCell to a ORKChoiceViewCell
    {
        ORKChoiceViewCell *choiceViewCell = [self _castTableViewCellToChoiceViewCell:cell
                                                                      itemIdentifier:itemIdentifier
                                                                            formItem:formItem
                                                                           tableView:tableView
                                                                           indexPath:indexPath];

        if (choiceViewCell != nil) {
            return choiceViewCell;
        }
    }

    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:indexPath.section];
    ORK_Log_Debug("[FORMSTEP] _tableView:CellForIndexPath: at index: %@ for section: '%@' cell type is '%@'", @(indexPath.row), sectionIdentifier, NSStringFromClass([cell class]));

    return cell;
}

- (nullable ORKFormItemCell *)_castTableViewCellToFormItemCell:(UITableViewCell *)tableViewCell
                                                itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier
                                                      formItem:(ORKFormItem *)formItem
                                                     tableView:(UITableView *)tableView
                                                     indexPath:(NSIndexPath *)indexPath {
    ORKFormItemCell *formCell = ORKDynamicCast(tableViewCell, ORKFormItemCell);
    
    if (formCell) {
        id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
        
        CGFloat maxLabelWidth = [self maxLabelWidth];
        [formCell configureWithFormItem:formItem answer:answer maxLabelWidth:maxLabelWidth delegate:self];

        [formCell setExpectedLayoutWidth:tableView.bounds.size.width];
        formCell.selectionStyle = UITableViewCellSelectionStyleNone;
        formCell.defaultAnswer = _savedDefaults[itemIdentifier.formItemIdentifier];
        if (!_savedAnswers) {
            _savedAnswers = [NSMutableDictionary new];
        }
        formCell.savedAnswers = _savedAnswers;
        formCell.useCardView = [self formStep].useCardView;
        formCell.cardViewStyle = [self formStep].cardViewStyle;
        
        formCell.isLastItem = ^{
            NSInteger section = indexPath.section;
            NSInteger rowCountInSection = [_diffableDataSource tableView:tableView numberOfRowsInSection:section];
            BOOL isLastItem = rowCountInSection == indexPath.row + 1;
            return isLastItem;
        }();

        formCell.isFirstItemInSectionWithoutTitle = ^{
            __auto_type snapshot = [_diffableDataSource snapshot];
            NSString *sectionFormItemIdentifier = [snapshot sectionIdentifierForSectionContainingItemIdentifier:itemIdentifier];
            ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionFormItemIdentifier];
            BOOL isFirstItemWithSectionWithoutTitle = (indexPath.row == 0) && (sectionFormItem.text == nil); // formItem.text is section.title
            return isFirstItemWithSectionWithoutTitle;
        }();
        
        return formCell;
    }
    
    return nil;
}

- (nullable ORKColorChoiceCell *)_castTableViewCellToColorChoiceCell:(UITableViewCell *)tableViewCell
                                                      itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier
                                                            formItem:(ORKFormItem *)formItem {
    ORKColorChoiceCell *colorChoiceCell = ORKDynamicCast(tableViewCell, ORKColorChoiceCell);
    
    if (colorChoiceCell != nil) {
        ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
        NSInteger choiceIndex = itemIdentifier.choiceIndex;
        
        if (choiceIndex != NSNotFound) {

            {
                
                if ([answerFormat isKindOfClass:[ORKColorChoiceAnswerFormat class]]) {
                    ORKColorChoice *colorChoice = [answerFormat.choices objectAtIndex:choiceIndex];
                    BOOL isLastItem = (choiceIndex + 1) == answerFormat.choices.count
                        && ![formItem.answerFormat shouldShowDontKnowButton];
                    [colorChoiceCell configureWithColorChoice:colorChoice isLastItem:isLastItem];
                }
            }
            
            // determine if the current cell should be selected
            {
                id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
                ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
                
                NSArray *selectedIndexes = [helper selectedIndexesForAnswer:answer];
                BOOL isCellSelected = [selectedIndexes containsObject:@(choiceIndex)];
                
                [colorChoiceCell setCellSelected:isCellSelected highlight:NO];
            }
            
            colorChoiceCell.tintColor = ORKViewTintColor(self.view);
            colorChoiceCell.useCardView = [self formStep].useCardView;
            colorChoiceCell.cardViewStyle = [self formStep].cardViewStyle;

            return colorChoiceCell;
        } else {
            ORK_Log_Debug("[FORMSTEP] choiceIndex was NSNotFound");
        }
        
    }
    
    return nil;
}

- (nullable ORKChoiceViewCell *)_castTableViewCellToChoiceViewCell:(UITableViewCell *)tableViewCell
                                                    itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier
                                                          formItem:(ORKFormItem *)formItem
                                                         tableView:(UITableView *)tableView
                                                         indexPath:(NSIndexPath *)indexPath {
    ORKChoiceViewCell *choiceViewCell = ORKDynamicCast(tableViewCell, ORKChoiceViewCell);
    
    if (choiceViewCell) {
        ORKAnswerFormat *answerFormat = formItem.impliedAnswerFormat;
        NSInteger choiceIndex = itemIdentifier.choiceIndex;
        
        if (choiceIndex != NSNotFound) {

            {
                BOOL isLastItem = (choiceIndex + 1) == answerFormat.choices.count
                    && ![formItem.answerFormat shouldShowDontKnowButton];
                
                if ([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
                    ORKTextChoice *textChoice = [answerFormat.choices objectAtIndex:choiceIndex];
                    [choiceViewCell configureWithTextChoice:textChoice isLastItem:isLastItem];
                    [choiceViewCell setShouldIgnoreCornerRadius:[self isWarningStateNeededForAnswerFormat:formItem.answerFormat]];
                }
            }
            
            // determine if the current cell should be selected
            {
                id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
                ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];

                NSArray *selectedIndexes = [helper selectedIndexesForAnswer:answer];
                BOOL isCellSelected = [selectedIndexes containsObject:@(choiceIndex)];

                [choiceViewCell setCellSelected:isCellSelected highlight:NO];
                
                if (answer != nil) {
                    [self updateWarningStateForSection:indexPath.section tableView:tableView answer:@[answer]];
                }
            }

        } else {
            ORK_Log_Debug("[FORMSTEP] choiceIndex was NSNotFound");
        }
        
        // Attempt to cast the choiceViewCell ot a ORKChoiceOtherViewCell
        [self _castChoiceViewCellToChoiceOtherCell:choiceViewCell
                                      answerFormat:answerFormat
                                       choiceIndex:choiceIndex];
        
        choiceViewCell.tintColor = ORKViewTintColor(self.view);
        choiceViewCell.useCardView = [self formStep].useCardView;
        choiceViewCell.cardViewStyle = [self formStep].cardViewStyle;
        
        return choiceViewCell;
    }
    
    return nil;
}

- (void)_castChoiceViewCellToChoiceOtherCell:(ORKChoiceViewCell *)choiceViewCell
                                answerFormat:(ORKAnswerFormat *)answerFormat
                                 choiceIndex:(NSInteger)choiceIndex {
    ORKChoiceOtherViewCell *choiceOtherViewCell = ORKDynamicCast(choiceViewCell, ORKChoiceOtherViewCell);
    
    if (choiceOtherViewCell != nil) {
        // This code used to be executed only once, when the cell was being created.
        // Now that we use dequeue to always create a cell, that logic doesn't apply anymore
        if (choiceOtherViewCell != nil) {
            ORKTextChoice *textChoice = [answerFormat.choices objectAtIndex:choiceIndex];
            ORKTextChoiceOther *textChoiceOther = ORKDynamicCast(textChoice, ORKTextChoiceOther);
            if (textChoiceOther != nil) {
                [choiceOtherViewCell setupWithText:textChoiceOther.textViewText placeholderText:textChoiceOther.textViewPlaceholderText];
            }
            
            choiceOtherViewCell.delegate = self;
        }
    }
}


- (CGFloat)maxLabelWidth {
    if (_maxLabelWidth < 0) {
        CGFloat labelWidth = 0;
        for (ORKFormItem* formItemForMaxWidth in [self allFormItems]) {
            labelWidth = MAX(labelWidth, ORKLabelWidth(formItemForMaxWidth.text));
        }
        _maxLabelWidth = labelWidth;
    }

    return _maxLabelWidth;
}

- (void)updateButtonStates {
    _navigationFooterView.continueEnabled = [self continueButtonEnabled];
    _navigationFooterView.skipEnabled = [self skipButtonEnabled];
    
    if (self.shouldPresentInReview && self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem.enabled = [self continueButtonEnabled];
    }
}


#pragma mark Helpers

- (ORKFormStep *)formStep { 
    NSAssert(!self.step || [self.step isKindOfClass:[ORKFormStep class]], nil);
    return (ORKFormStep *)self.step;
}


#pragma mark NSNotification methods

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (_currentFirstResponderCell) {
        if ([_currentFirstResponderCell isKindOfClass:[ORKChoiceOtherViewCell class]]) {
            CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
               CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
               
               if (CGRectGetMaxY(_currentFirstResponderCell.frame) >= CGRectGetMinY(convertedKeyboardFrame)) {
                   UITableView *tableView = self.tableView;

                   [tableView setContentInset:UIEdgeInsetsMake(0, 0, CGRectGetHeight(convertedKeyboardFrame), 0)];
                   
                   NSIndexPath *currentFirstResponderCellIndex = [tableView indexPathForCell:_currentFirstResponderCell];
                   
                   if (currentFirstResponderCellIndex && [self _isAutoScrollEnabled]) {
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                           [tableView scrollToRowAtIndexPath:currentFirstResponderCellIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                       });
                   }
               }
        } else {
            CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
            
            if ((_currentFirstResponderCell.frame.origin.y + CGRectGetHeight(_currentFirstResponderCell.frame)) >= (CGRectGetHeight(self.view.frame) - keyboardSize.height)) {
                _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height + TableViewYOffsetStandard, 0);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_tableContainer scrollCellVisible:_currentFirstResponderCell animated:YES];
                });
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark UITableViewDelegate Helpers

- (void)didSelectChoiceOtherViewCellWithItemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier
                    choiceOtherViewCell:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    if (choiceOtherViewCell.textView.text.length <= 0) {
        [self reloadItems:@[itemIdentifier]];
        [_tableContainer resizeFooterToFit];
    }
}

- (void)reloadItems:(NSArray<ORKTableCellItemIdentifier *> *)itemIdentifiers {
    NSDiffableDataSourceSnapshot<NSString *, ORKTableCellItemIdentifier *> * snapshot = [_diffableDataSource snapshot];
    [snapshot reloadItemsWithIdentifiers:itemIdentifiers];
    [_diffableDataSource applySnapshot:snapshot animatingDifferences:false];
}

- (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font withLearnMorePadding:(BOOL)useLearnMorePadding {
    CGFloat textPaddingMargin = 0;
    if (useLearnMorePadding) {
        // the learnmore button blocks off another (ORKSurveyItemMargin) padding
        textPaddingMargin = ((ORKSurveyTableContainerLeftRightPadding + (ORKSurveyItemMargin  * 3)) * 2);
    } else {
        textPaddingMargin = ((ORKSurveyTableContainerLeftRightPadding + ORKSurveyItemMargin) * 2);
    }
    CGFloat textScreenWidth = self.view.frame.size.width - textPaddingMargin;
    CGRect frame = [text boundingRectWithSize:CGSizeMake(textScreenWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    float height = frame.size.height;
    return height;
}

- (CGFloat)heightForFormItem:(ORKFormItem *)formItem {
    
    CGFloat headerHeight = 0.0;

    if (formItem.text) {
        headerHeight = headerHeight + [self heightForText:formItem.text withFont:[ORKSurveyCardHeaderView titleLabelFont] withLearnMorePadding:NO];
    }
    
    if (formItem.detailText) {
        headerHeight = headerHeight + [self heightForText:formItem.detailText withFont:[ORKSurveyCardHeaderView detailTextLabelFont] withLearnMorePadding:(formItem.learnMoreItem != nil)] + ORKStepContainerTitleToBodyTopPaddingStandard();
    }
    
    if (formItem.tagText) {
        headerHeight = headerHeight + [self heightForText:formItem.tagText withFont:[ORKTagLabel font] withLearnMorePadding:NO] + ORKStepContainerTitleToBodyTopPaddingStandard();
    }
            
    return headerHeight;
}

- (void)handleSelectionOfFormItemCell:(ORKFormItemCell *)formItemCell indexPath:(NSIndexPath *)indexPath {
    [formItemCell becomeFirstResponder];
    if ([self _isAutoScrollEnabled]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        });
    }
}

- (void)handleSelectionOfChoiceViewCell:(ORKChoiceViewCell *)choiceViewCell
                 textChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)textChoiceAnswerFormat
                               formItem:(ORKFormItem *)formItem
                         itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier
                              tableView:(UITableView *)tableView
                              indexPath:(NSIndexPath *)indexPath {
    // Dismiss other textField's keyboard
    [tableView endEditing:NO];
    
    ORKColorChoiceAnswerFormat *colorChoiceAnswerFormat = ORKDynamicCast(formItem.impliedAnswerFormat, ORKColorChoiceAnswerFormat);
    BOOL willUpdateCellHeight = (colorChoiceAnswerFormat != nil);
    
    if (textChoiceAnswerFormat != nil || colorChoiceAnswerFormat != nil) {
        ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:textChoiceAnswerFormat ? : colorChoiceAnswerFormat];
        
        // Determine inf multi selection should happen
        BOOL shouldAllowMultiSelection = [self shouldAllowMultiSelectionWithTextChoiceAnswerFormat:textChoiceAnswerFormat
                                                                           colorChoiceAnswerFormat:colorChoiceAnswerFormat
                                                                          choiceAnswerFormatHelper:helper
                                                                                    choiceViewCell:choiceViewCell
                                                                                    itemIdentifier:itemIdentifier];
        
        id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
        NSMutableSet* selectedIndexes = [[NSMutableSet alloc] initWithArray:[helper selectedIndexesForAnswer:answer]];
        
        // make setCellSelected calls to update cell UI
        {
            if (willUpdateCellHeight) {
                [tableView beginUpdates];
            }
            
            NSRange range = NSMakeRange(0, helper.choiceCount);
            NSIndexSet *relatedChoiceRows = [NSIndexSet indexSetWithIndexesInRange:range];
            NSInteger eachIndex = relatedChoiceRows.firstIndex;
            while (eachIndex != NSNotFound) {
                NSIndexPath *testIndexPath = [NSIndexPath indexPathForRow:eachIndex inSection:indexPath.section];
                ORKChoiceViewCell *testCell = [tableView cellForRowAtIndexPath:testIndexPath];
                
                // The selected cell should toggle regardless of the multi-choice
                // or single-choice style
                if (testCell == choiceViewCell) {
                    BOOL newSelectedState = !choiceViewCell.isCellSelected;
                    [testCell setCellSelected:newSelectedState highlight:YES];
                    
                    if (testCell.isCellSelected) {
                        ORK_Log_Debug("[SELECTION] adding index %@", @(eachIndex));
                        [selectedIndexes addObject:@(eachIndex)];
                        ORK_Log_Debug("[SELECTION] selected indexes are %@", selectedIndexes);
                    } else if (testCell && testCell.isCellSelected == NO) {
                        ORK_Log_Debug("[SELECTION] removing index %@", @(eachIndex));
                        [selectedIndexes removeObject:@(eachIndex)];
                    }
                } else if (!shouldAllowMultiSelection) {
                    // we're not allowing multi-selection, but this isn't the selected cell either, unhighlight
                    [testCell setCellSelected:NO highlight:NO];
                    [testCell updateHeightIfNeeded];
                    ORK_Log_Debug("[SELECTION] removing index %@", @(eachIndex));
                    [selectedIndexes removeObject:@(eachIndex)];
                }
                eachIndex = [relatedChoiceRows indexGreaterThanIndex:eachIndex];
            }
            
            // gather the selected indexes before collecting their answers
            NSArray *uniqueSelectedIndexes = [selectedIndexes allObjects];
            uniqueSelectedIndexes = [uniqueSelectedIndexes sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
                return [obj1 compare:obj2];
            }];
            
            answer = [helper answerForSelectedIndexes:uniqueSelectedIndexes];
            
            // update the warning state of the section if needed
            [self updateWarningStateForSection:indexPath.section tableView:tableView answer:answer];
            
            if (willUpdateCellHeight) {
                [choiceViewCell updateHeightIfNeeded];
                [tableView endUpdates];
            }
        }

        // If there is a Don't Know cell, deselect it since a regular choice was made
        if (formItem.answerFormat.shouldShowDontKnowButton) {
            NSIndexPath *dontKnowIndexPath = [NSIndexPath indexPathForRow:helper.choiceCount inSection:indexPath.section];
            ORKChoiceViewCell *dontKnowCell = ORKDynamicCast([tableView cellForRowAtIndexPath:dontKnowIndexPath], ORKChoiceViewCell);
            [dontKnowCell setCellSelected:NO highlight:NO];
        }

        // if a ORKChoiceOtherViewCell is selected, resize it
        {
            int textChoiceOtherIndex = 0;
            for (ORKTextChoice *textChoice in formItem.impliedAnswerFormat.choices) {
                ORKTextChoiceOther *textChoiceOther = ORKDynamicCast(textChoice, ORKTextChoiceOther);
                if (textChoiceOther != nil) {
                    ORKChoiceOtherViewCell *choiceOtherViewCell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textChoiceOtherIndex inSection:indexPath.section]];
                    [self resizeORKChoiceOtherViewCell:choiceOtherViewCell withTextChoice:textChoiceOther];
                }
                textChoiceOtherIndex = textChoiceOtherIndex + 1;
            }
        }
        
        // save the collected answer(s)
        [self saveAnswer:answer forItemIdentifier:itemIdentifier];
        ORK_Log_Debug("saved answers are now %@'",  [self savedAnswers]);
    } else {
        ORK_Log_Debug("[FORMSTEP] NOT textChoice: row for item %@ selected: answerFormat is '%@'", itemIdentifier, formItem.impliedAnswerFormat);
    }
}

- (BOOL)shouldAllowMultiSelectionWithTextChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)textChoiceAnswerFormat
                                    colorChoiceAnswerFormat:(ORKColorChoiceAnswerFormat *)colorChoiceAnswerFormat
                                   choiceAnswerFormatHelper:(ORKChoiceAnswerFormatHelper*)helper
                                             choiceViewCell:(ORKChoiceViewCell *)choiceViewCell
                                             itemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    BOOL shouldAllowMultiSelection = YES; // assume multiple selection by default
    
    // does the answerFormat want multiple selection?
    BOOL answerFormatAllowsMultiSelection = textChoiceAnswerFormat ? (textChoiceAnswerFormat.style == ORKChoiceAnswerStyleMultipleChoice) : (colorChoiceAnswerFormat.style == ORKChoiceAnswerStyleMultipleChoice);
    
    shouldAllowMultiSelection = shouldAllowMultiSelection && answerFormatAllowsMultiSelection;
    
    // does the selected cell allow multiple choice?
    shouldAllowMultiSelection = shouldAllowMultiSelection && (choiceViewCell.isExclusive == NO);
    
    // does the cell representing the current answer allow multiple choice?
    NSNumber *previousSingleSelectionValue = [helper selectedIndexForAnswer:_savedAnswers[itemIdentifier.formItemIdentifier]];
    NSInteger previousSingleSelection = previousSingleSelectionValue ? previousSingleSelectionValue.integerValue : NSNotFound;
    BOOL choiceIsExclusive = NO;
    if (textChoiceAnswerFormat) {
        ORKTextChoice *selectedChoice = (previousSingleSelection != NSNotFound) ? [helper textChoiceAtIndex:previousSingleSelection] : nil;
        choiceIsExclusive = selectedChoice.exclusive;
    } else if (colorChoiceAnswerFormat) {
        ORKColorChoice *selectedChoice = (previousSingleSelection != NSNotFound) ? [helper colorChoiceAtIndex:previousSingleSelection] : nil;
        choiceIsExclusive = selectedChoice.exclusive;
    }
    
    return shouldAllowMultiSelection && !choiceIsExclusive;
}

- (BOOL)isWarningStateNeededForAnswerFormat:(ORKAnswerFormat *)answerFormat {
    if ([answerFormat conformsToProtocol:@protocol(ORKWarningStateSupport)]) {
        id <ORKWarningStateSupport> warningStateConformingFormat = (id <ORKWarningStateSupport>)answerFormat;
        
        return warningStateConformingFormat.warningStateMessage != nil && warningStateConformingFormat.warningStateTriggerValues.count > 0;
    }
    
    return NO;
}

- (void)updateWarningStateForSection:(NSInteger *)section
                           tableView:(UITableView *)tableView
                              answer:(id)answer {
    WarningStateFooterView *footerView = (WarningStateFooterView *)[tableView footerViewForSection:section];
    NSArray<NSObject<NSCopying, NSSecureCoding> *> *warningStateTriggers = [self getWarningStateTriggersForSection:section];
    
    if (footerView != nil && warningStateTriggers!= nil) {
        
        [tableView performBatchUpdates:^{
            for (NSObject<NSCopying, NSSecureCoding> *triggerValue in warningStateTriggers) {
                if (answer != ORKNullAnswerValue()) {
                    NSArray *flattened = nil;
                    
                    // Text choice results can be passed back as an array. This check handles that edge case.
                    if ([answer isKindOfClass:[NSArray class]]) {
                        flattened = FlattenArray((NSArray *)answer);
                    } else {
                        flattened = @[answer];
                    }
                    
                    if ([flattened containsObject:triggerValue]) {
                        [footerView setShouldShowWarningMessage:YES];
                        return;
                    }
                }
                
                [footerView setShouldShowWarningMessage:NO];
            }
            
        } completion:nil];
        
    }
}

static NSArray *FlattenArray(NSArray *array) {
    NSMutableArray *result = [NSMutableArray array];
    
    for (id element in array) {
        if ([element isKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray:FlattenArray((NSArray *)element)];
        } else {
            [result addObject:element];
        }
    }
    
    return result;
}

- (nullable NSString *)getWarningStateMessageForSection:(NSInteger *)section {
    id <ORKWarningStateSupport> warningStateConformingObject = [self getWarningStateConformingObjectFromSection:section];
    
    if (warningStateConformingObject) {
        return warningStateConformingObject.warningStateMessage;
    }
    
    return nil;
}

- (nullable NSArray<NSObject<NSCopying, NSSecureCoding> *> *)getWarningStateTriggersForSection:(NSInteger *)section {
    id <ORKWarningStateSupport> warningStateConformingObject = [self getWarningStateConformingObjectFromSection:section];
    
    if (warningStateConformingObject) {
        return warningStateConformingObject.warningStateTriggerValues;
    }
    
    return nil;
}

- (nullable id <ORKWarningStateSupport>)getWarningStateConformingObjectFromSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    
    if (formItem) {
        ORKAnswerFormat *answerFormat = formItem.answerFormat;
        if ([answerFormat conformsToProtocol:@protocol(ORKWarningStateSupport)]) {
            id <ORKWarningStateSupport> warningStateConformingFormat = (id <ORKWarningStateSupport>)answerFormat;
            return warningStateConformingFormat;
        }
    }
    
    return nil;
}

- (BOOL)containsTriggerValuesForSection:(NSInteger)section {
    NSArray<NSObject<NSCopying, NSSecureCoding> *> *warningStateTriggers = [self getWarningStateTriggersForSection:section];
    
    if ( warningStateTriggers != nil) {
        NSInteger totalItemsInSection = [_tableView numberOfRowsInSection:section];
        
        for (int i = 0; i < totalItemsInSection - 1; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
            id answer = _savedAnswers[itemIdentifier.formItemIdentifier];
            
            if (answer != nil) {
                
                for (NSObject<NSCopying, NSSecureCoding> *triggerValue in warningStateTriggers) {
                    if (answer != ORKNullAnswerValue()) {
                        NSArray *flattened = nil;
                        
                        // Some text choice results can be grouped in an array. This checks handles that edge case.
                        if ([answer isKindOfClass:[NSArray class]]) {
                            flattened = (NSArray *)answer;
                        } else {
                            flattened = @[answer];
                        }
                        
                        if ([flattened containsObject:triggerValue]) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

#pragma mark ORKFormItemCellDelegate Helpers

- (void)finishHandlingAnswerChangedForItemIdentifier:(ORKTableCellItemIdentifier *)itemIdentifier {
    // find the new indexPath of the saved itemIdentifier (almost certainly the same indexPath as before)
    NSIndexPath *updatedIndexPath = [_diffableDataSource indexPathForItemIdentifier:itemIdentifier];
    ORKFormItemCell *cell = [self.tableView cellForRowAtIndexPath:updatedIndexPath];
    
    BOOL handled = NO;
    
    // avoid auto-scrolling when typing in the ORKChoiceOtherViewCell changes the answer
    handled = handled || [cell isKindOfClass:[ORKChoiceOtherViewCell class]];

    handled = handled || [self scrollNextSectionToVisibleFromIndexPath:updatedIndexPath];
    handled = handled || [self scrollFirstUnansweredSectionToVisibleFromIndexPath:updatedIndexPath];
    handled = handled || [self scrollFooterToVisibleFromIndexPath:updatedIndexPath];
    NSAssert(handled == YES, @"Answer change went unhandled");
    
    if (handled && [self isContentSizeLargerThanFrame]) {
        [_tableContainer resizeFooterToFit];
    }
    // Delay updating answered sections so our autoscroll logic can check for the case where a section is answered for the first time
    // This way we don't try to autoscroll if you've changed an answer in a section. Instead we only autoscroll the first time you put an answer in for a section.
    [self updateAnsweredSections];
}


#pragma mark UIStateRestoration

static NSString *const _ORKSavedAnswersRestoreKey = @"savedAnswers";
static NSString *const _ORKSavedAnswerDatesRestoreKey = @"savedAnswerDates";
static NSString *const _ORKSavedSystemCalendarsRestoreKey = @"savedSystemCalendars";
static NSString *const _ORKSavedSystemTimeZonesRestoreKey = @"savedSystemTimeZones";
static NSString *const _ORKOriginalAnswersRestoreKey = @"originalAnswers";
static NSString *const _ORKAnsweredSectionIdentifiersRestoreKey = @"answeredSectionIdentifiers";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_savedAnswers forKey:_ORKSavedAnswersRestoreKey];
    [coder encodeObject:_savedAnswerDates forKey:_ORKSavedAnswerDatesRestoreKey];
    [coder encodeObject:_savedSystemCalendars forKey:_ORKSavedSystemCalendarsRestoreKey];
    [coder encodeObject:_savedSystemTimeZones forKey:_ORKSavedSystemTimeZonesRestoreKey];
    [coder encodeObject:_originalAnswers forKey:_ORKOriginalAnswersRestoreKey];
    [coder encodeObject:_identifiersOfAnsweredSections forKey:_ORKAnsweredSectionIdentifiersRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    NSSet *decodableAnswerTypes = [NSSet setWithObjects:NSMutableDictionary.self, NSString.self, NSNumber.self, NSDate.self, nil];
    _savedAnswers = [coder decodeObjectOfClasses:decodableAnswerTypes forKey:_ORKSavedAnswersRestoreKey];
    [self removeInvalidSavedAnswers];
    
    _savedAnswerDates = [coder decodeObjectOfClasses:[NSSet setWithArray:@[NSMutableDictionary.self, NSString.self, NSDate.self]] forKey:_ORKSavedAnswerDatesRestoreKey];
    _savedSystemCalendars = [coder decodeObjectOfClasses:[NSSet setWithArray:@[NSMutableDictionary.self, NSString.self, NSCalendar.self]] forKey:_ORKSavedSystemCalendarsRestoreKey];
    _savedSystemTimeZones = [coder decodeObjectOfClasses:[NSSet setWithArray:@[NSMutableDictionary.self, NSString.self,  NSTimeZone.self]] forKey:_ORKSavedSystemTimeZonesRestoreKey];
    _originalAnswers = [coder decodeObjectOfClasses:decodableAnswerTypes forKey:_ORKOriginalAnswersRestoreKey];
    _identifiersOfAnsweredSections = [coder decodeObjectOfClasses:[NSSet setWithArray:@[NSMutableSet.self, NSString.self]] forKey:_ORKAnsweredSectionIdentifiersRestoreKey];
}

- (void)removeInvalidSavedAnswers {
    for (ORKFormItem *item in [self allFormItems]) {
        id answer = _savedAnswers[item.identifier];
        ORKAnswerFormat *answerFormat = item.impliedAnswerFormat;
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = ORKDynamicCast(answerFormat, ORKTextChoiceAnswerFormat);
        if ([textChoiceAnswerFormat isAnswerInvalid:answer]) {
            ORK_Log_Error("unexpected answer %@ on answerFormat of %@", answer, item.impliedAnswerFormat);
            _savedAnswers[item.identifier] = nil;
            _savedAnswerDates[item.identifier] = nil;
        }
    }
}

    
#pragma mark Rotate

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    for (ORKFormItemCell *cell in _formItemCells) {
        [cell setExpectedLayoutWidth:size.width];
    }
}


#pragma mark FormItemCell AnswerChanged Updates

- (void)answerChangedForIndexPath:(NSIndexPath *)indexPath {
    // stash the itemIdentifier before buildDataSource
    // We do not expect that editing a formItem would remove that same formItem from the dataSource
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.superview == nil) {
        return;
    }
    
    _skipped = NO;
    [self updateButtonStates];
    [self notifyDelegateOnResultChange];

    BOOL skipRebuildDataSource = NO;
    
    //For picker cells, wait for the "done" button to resign first responder before trying to rebuild
    skipRebuildDataSource = skipRebuildDataSource || [cell isKindOfClass:[ORKFormItemPickerCell class]];

    // For text cells, don't rebuild during typing
    skipRebuildDataSource = skipRebuildDataSource || [cell isKindOfClass:[ORKFormItemTextCell class]];
    
    // Only allow skipping if the answer was changed to something non-nil. The answer will be nullAnswer when users
    // hit the 'clear' button on the textCell. Normally, the answer changes multiple times to different non-nil values
    // before we're given the chance to process the new value through formItemCellDidResignFirstResponder
    skipRebuildDataSource = skipRebuildDataSource && (_savedAnswers[itemIdentifier.formItemIdentifier] != ORKNullAnswerValue());

    if (skipRebuildDataSource == YES) {
        [self finishHandlingAnswerChangedForItemIdentifier:itemIdentifier];
    } else {
        __weak typeof(self) weakSelf = self;
        [self _createDiffableSnapshot:_diffableDataSource withCompletion:^{
            [weakSelf finishHandlingAnswerChangedForItemIdentifier:itemIdentifier];
        }];
    }
}

- (void)finishHandlingFormItemCellDidResignFirstResponder:(ORKTableCellItemIdentifier *)cellItemIdentifier {
    //determines if the table should autoscroll to the next section
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSIndexPath *indexPath = [_diffableDataSource indexPathForItemIdentifier:cellItemIdentifier];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:indexPath.section];
    ORKFormItemCell *cell = ORKDynamicCast([self.tableView cellForRowAtIndexPath:indexPath], ORKFormItemCell);

    if (cell.isLastItem && [self shouldAutoScrollToNextSectionAfter:indexPath]) {
        [self autoScrollToNextSectionAfter:indexPath];
        return;
    } else if (cell.isLastItem && indexPath.section == (snapshot.numberOfSections - 1) && ![_identifiersOfAnsweredSections containsObject:sectionIdentifier]) {
        if (![self allNonOptionalFormItemsHaveAnswers]) {
            [self scrollToFirstUnansweredSection];
        } else {
            [self scrollToFooter];
        }
    }
    
    if (indexPath) {
        NSInteger numberOfItemsInSection = [snapshot numberOfItemsInSection:sectionIdentifier];
        if (indexPath.row < numberOfItemsInSection - 1) {
            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section];
            NSString *nextFormItemIdentifier = [[_diffableDataSource itemIdentifierForIndexPath:nextPath] formItemIdentifier];
            BOOL cellNeedsBecomeFirstResponder = (self.savedAnswers[nextFormItemIdentifier] == nil);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (_currentFirstResponderCell == nil) {
                    if (cellNeedsBecomeFirstResponder == YES) {
                        ORKFormItemCell *formItemCell = ORKDynamicCast([_tableView cellForRowAtIndexPath:nextPath], ORKFormItemCell);
                        [formItemCell becomeFirstResponder];
                    }
                    
                    if ([self _isAutoScrollEnabled]) {
                        [_tableView scrollToRowAtIndexPath:nextPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    }
                }
            });
        }
    }
}

- (BOOL)scrollNextSectionToVisibleFromIndexPath:(NSIndexPath *)indexPath {
    BOOL handledAutoScroll = NO;

    __auto_type snapshot = [_diffableDataSource snapshot];
    ORKTableCellItemIdentifier *cellItemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    NSString *formItemIdentifier = cellItemIdentifier.formItemIdentifier;
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:formItemIdentifier];
    id savedAnswer = self.savedAnswers[formItemIdentifier];

    BOOL allowAutoScrolling = NO;

    // allow autoscroll if you hit don't know
    allowAutoScrolling = allowAutoScrolling || [savedAnswer isKindOfClass:[ORKDontKnowAnswer class]];
    
    // allow autoscroll if the question is SES
    allowAutoScrolling = allowAutoScrolling || (formItem.impliedAnswerFormat.questionType == ORKQuestionTypeSES);
    
    // allow autoscroll if the question is a text choice
    ORKTextChoiceAnswerFormat *answerFormat = [self textChoiceAnswerFormatForIndexPath:indexPath];
    if (answerFormat != nil) {
        // allow scrolling for single-choice answer formats
        allowAutoScrolling = allowAutoScrolling || (answerFormat.style == ORKChoiceAnswerStyleSingleChoice);
        
        // allow scrolling after choosing an exclusive choice
        allowAutoScrolling = allowAutoScrolling || answerFormat.textChoices[cellItemIdentifier.choiceIndex].exclusive;
    }
    
    // allow autoscroll if the question is a color choice
    ORKColorChoiceAnswerFormat *colorChoiceAnswerFormat = [self colorChoiceAnswerFormatForIndexPath:indexPath];
    if (colorChoiceAnswerFormat != nil) {
        // allow scrolling for single-choice answer formats
        allowAutoScrolling = allowAutoScrolling || (colorChoiceAnswerFormat.style == ORKChoiceAnswerStyleSingleChoice);
        
        // allow scrolling after choosing an exclusive choice
        allowAutoScrolling = allowAutoScrolling || colorChoiceAnswerFormat.colorChoices[cellItemIdentifier.choiceIndex].exclusive;
    }
    
    if (allowAutoScrolling == YES) {

        // only allow autoscroll to the next section if this was the first time providing an answer in this section
        // this test works because we expect updateAnsweredSections runs *after* we do
        NSString *sectionIdentifier = [snapshot sectionIdentifierForSectionContainingItemIdentifier:cellItemIdentifier];
        allowAutoScrolling = allowAutoScrolling && ([_identifiersOfAnsweredSections containsObject:sectionIdentifier] == NO);

        ORKFormItem *nextUnansweredFormItem = nil;
        {
            NSArray<ORKTableCellItemIdentifier *> *sectionCellItemIdentifiers = [snapshot itemIdentifiersInSectionWithIdentifier:sectionIdentifier];

            // Get the index of the cell whose indexPath was just answered.
            NSUInteger index = [sectionCellItemIdentifiers indexOfObject:cellItemIdentifier];
            NSAssert(index != NSNotFound, @"Expected cellItemIdentifier to be present in section");

            // find the next answerable unanswered formItem in this section
            while (index < sectionCellItemIdentifiers.count) {
                // Find the formItemIdentifier. Check to see whether there is an answer for this identifier.
                NSString *testFormItemIdentifier = sectionCellItemIdentifiers[index].formItemIdentifier;
                id testAnswer = self.savedAnswers[testFormItemIdentifier];
                ORKFormItem *testFormItem = [self _formItemForFormItemIdentifier:testFormItemIdentifier];

                // Find formItems that are answerable, but not yet answered
                if ((testFormItem.impliedAnswerFormat != nil) && (testAnswer == nil)) {
                    nextUnansweredFormItem = testFormItem;
                    break;
                }

                index += 1;
            }
        }

        // only allow autoscrolling if this formItem is the last unanswered answerable formItem in this section
        allowAutoScrolling = allowAutoScrolling && (nextUnansweredFormItem == nil);
    }
                
    if (allowAutoScrolling == YES) {
        // only allow autoscrolling to the next section if the next section exists
        if ((indexPath.section + 1) < [snapshot numberOfSections]) {
            [self autoScrollToNextSectionAfter:indexPath];
            handledAutoScroll = YES;
        } else {
            // We would go to the next section, but we literally can't
            // Let the caller come up with a backup plan
        }
    } else {
        // allowAutoScrolling == NO means prevent autoscrolling completely
        // so we claim we handled autoscroll
        handledAutoScroll = YES;
    }
    
    return handledAutoScroll;
}

- (BOOL)scrollFirstUnansweredSectionToVisibleFromIndexPath:(NSIndexPath *)indexPath {
    BOOL handled = NO;
    
    BOOL shouldScroll = YES;
    
    // only allow scrolling if this is the last section in the tableView
    shouldScroll = shouldScroll && ((indexPath.section + 1) == [_tableView numberOfSections]);

    if (shouldScroll == YES) {
        if ([self allNonOptionalFormItemsHaveAnswers] == NO) {
            [self scrollToFirstUnansweredSection];
            handled = YES;
        } else {
            // we would scroll to the first unanswered section, but none exist
            // not handled
        }
    } else {
        // Decided we should not scroll at all
        handled = YES;
    }

    return handled;
}

- (BOOL)scrollFooterToVisibleFromIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldScroll = YES;
    
    // only allow scrolling if this is the last section in the tableView
    shouldScroll = shouldScroll && ((indexPath.section + 1) == [_tableView numberOfSections]);
    
    // only allow scrolling if all non-optional questions are answered
    shouldScroll = shouldScroll && ([self allNonOptionalFormItemsHaveAnswers] == YES);

    if (shouldScroll == YES) {
        [self scrollToFooter];
    }

    // nothing we can't handle
    return YES;
}


#pragma mark - ORKChoiceOtherViewCellDelegate Helpers

- (void)updateTextChoiceOtherWithText:(NSString *)text choiceOtherCell:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    if (_currentFirstResponderCell == choiceOtherViewCell) {
        _currentFirstResponderCell = nil;
    }
    
    // we need to use `indexPathForRowAtPoint` because `indexPathForCell`
    // will return nil if the cell is off the screen, which will happen if we are scrolling
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:choiceOtherViewCell.center];
            
    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    
    NSArray *currentAnswers = [self answersForFormItem:formItem];
    
    // Update the item within the set of current answers that corresponds to TextChoiceOther with
    // the new supplementary text the user has entered.
    NSArray *newAnswers;
    if (currentAnswers) {
        newAnswers = [self updatedAnswersForFormItem:formItem
                                             answers:currentAnswers
                                 otherTextChoiceText:text];
    } else {
        newAnswers = nil;
    }
    
    ORKTextChoiceOther *textChoice = [[[formItem answerFormat] choices] objectAtIndex:itemIdentifier.choiceIndex];
    
    ORK_Log_Debug("[FORMSTEP] textChoiceOtherCellDidResignFirstResponder found textChoice %@ with value of %@", textChoice, textChoice.textViewText);
    
    if (text.length > 0) {
        textChoice.textViewText = text;
        [self didSelectChoiceOtherViewCellWithItemIdentifier:itemIdentifier choiceOtherViewCell:choiceOtherViewCell];
    } else {
        textChoice.textViewText = nil;
        if (!textChoice.textViewInputOptional) {
            [choiceOtherViewCell setCellSelected:NO highlight:NO];
        }
    }
    
    if (newAnswers) {
        [self saveTextChoiceAnswer:newAnswers
                          formItem:formItem
                         indexPath:indexPath
                    itemIdentifier:itemIdentifier];
    }
    
    [self resizeORKChoiceOtherViewCell:choiceOtherViewCell withTextChoice:textChoice];
}

- (void)saveTextChoiceAnswer:(id)answer
          formItem:(ORKFormItem*)formItem
         indexPath:(NSIndexPath*)indexPath
    itemIdentifier:(ORKTableCellItemIdentifier*)itemIdentifier {
    ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = ORKDynamicCast(formItem.impliedAnswerFormat, ORKTextChoiceAnswerFormat);
    ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:textChoiceAnswerFormat];
    NSArray *selectedIndexes = [helper selectedIndexesForAnswer:answer];
    // regenerate answer to pick up the changed text from choiceOtherViewCell
    answer = [helper answerForSelectedIndexes:selectedIndexes];
    _savedAnswers[itemIdentifier.formItemIdentifier] = answer;
    [self answerChangedForIndexPath:indexPath];
}

@end

@implementation ORKFormItem (FormStepViewControllerExtensions)

- (BOOL)requiresSingleSection {
    ORKAnswerFormat *answerFormat = [self impliedAnswerFormat];

    ORKQuestionType questionType = answerFormat.questionType;
    NSArray *singleSectionTypes = @[@(ORKQuestionTypeBoolean),
                                    @(ORKQuestionTypeSingleChoice),
                                    @(ORKQuestionTypeMultipleChoice),
                                    @(ORKQuestionTypeLocation),
                                    @(ORKQuestionTypeSES)];
    
    BOOL multiCellChoices = ([singleSectionTypes containsObject:@(questionType)] &&
                             NO == [answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]);

    BOOL scale = (questionType == ORKQuestionTypeScale);
    
    // Items require individual section
    if (multiCellChoices || scale) {
        return YES;
    }
    
    return NO;
}

@end


#pragma mark UITableViewDelegate

@implementation ORKFormStepViewController (UITableViewDelegate)

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    ORKTableCellItemIdentifier *itemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    ORKFormItem *formItem = [self _formItemForFormItemIdentifier:itemIdentifier.formItemIdentifier];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    {
        // ORKFormItemCell selection
        ORKFormItemCell *formItemCell = ORKDynamicCast(cell, ORKFormItemCell);
        if (formItemCell != nil) {
            [self handleSelectionOfFormItemCell:formItemCell indexPath:indexPath];
            return;
        }
    }
    
    // ORKChoiceViewCell selection
    ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = ORKDynamicCast(formItem.impliedAnswerFormat, ORKTextChoiceAnswerFormat);
    ORKChoiceViewCell *choiceViewCell = ORKDynamicCast(cell, ORKChoiceViewCell);

    // Don't Know cell selection
    if (itemIdentifier.isDontKnow && choiceViewCell != nil) {
        // Deselect all regular choice cells in this section
        NSUInteger choiceCount = formItem.impliedAnswerFormat.choices.count;
        [tableView beginUpdates];
        for (NSUInteger i = 0; i < choiceCount; i++) {
            NSIndexPath *choiceIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            ORKChoiceViewCell *choiceCell = ORKDynamicCast([tableView cellForRowAtIndexPath:choiceIndexPath], ORKChoiceViewCell);
            [choiceCell setCellSelected:NO highlight:NO];
            [choiceCell updateHeightIfNeeded];
        }
        [tableView endUpdates];
        // Clear any single-row form item cell (e.g. ORKFormItemLocationCell, ORKFormItemImageSelectionCell).
        // For choice-per-row formats, the row before Don't Know is an ORKChoiceViewCell and the cast returns nil.
        if (indexPath.row > 0) {
            NSIndexPath *formItemIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            ORKFormItemCell *formItemCell = ORKDynamicCast([tableView cellForRowAtIndexPath:formItemIndexPath], ORKFormItemCell);
            [formItemCell setAnswer:[ORKDontKnowAnswer answer]];
        }
        [choiceViewCell setCellSelected:YES highlight:YES];
        [self saveAnswer:[ORKDontKnowAnswer answer] forItemIdentifier:itemIdentifier];
        return;
    }

    if (choiceViewCell != nil) {
        [self handleSelectionOfChoiceViewCell:choiceViewCell
                       textChoiceAnswerFormat:textChoiceAnswerFormat
                                     formItem:formItem
                               itemIdentifier:itemIdentifier
                                    tableView:tableView
                                    indexPath:indexPath];
    } else {
        ORK_Log_Debug("[FORMSTEP] NOT ORKChoiceViewCell: row for indexPath %@ selected. Cell: %@", indexPath, cell);
    }
    
    // ORKChoiceOtherViewCell selection
    ORKChoiceOtherViewCell *choiceOtherViewCell = ORKDynamicCast(cell, ORKChoiceOtherViewCell);
    if (choiceOtherViewCell != nil && textChoiceAnswerFormat != nil) {
        // we need to call this at the end of didSelect, because the cell will have `_selected` property to `YES`
        // calling this earlier, would cause us to
        // [reload tableView] -> which calls -> layoutSubviews on ORKChoiceViewCell -> which calls ->
        // updateSelectedItem, which has `_checked` as false, and sets the checkmark to grey
        // if we defer this call to the end, it works nice, and by using diffabledatasource to reload it animates nicely
        [self didSelectChoiceOtherViewCellWithItemIdentifier:itemIdentifier choiceOtherViewCell:choiceOtherViewCell];
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableCellHeightMapping == nil) {
        self.tableCellHeightMapping = [NSMutableDictionary new];
    }
    [self.tableCellHeightMapping setObject:[NSNumber numberWithFloat:cell.bounds.size.height] forKey:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:section];
    ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionIdentifier];
    NSString *title = sectionFormItem.text;

    // Make first section header view zero height when there is no title
    return [self formStep].useCardView ? UITableViewAutomaticDimension : (title.length > 0) ? UITableViewAutomaticDimension : ((section == 0) ? 0 : UITableViewAutomaticDimension);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSString *sectionIdentifier = [[snapshot sectionIdentifiers] objectAtIndex:section];
    ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionIdentifier];
    
    return [self heightForFormItem:sectionFormItem] + (ORKIsAccessibilityLargeTextEnabled() ? ORKFormStepLargeTextMinimumHeaderHeight : ORKFormStepMinimumHeaderHeight);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    __auto_type snapshot = [_diffableDataSource snapshot];
    NSArray<NSString *> *sectionIdentifiers = [snapshot sectionIdentifiers];
    NSString *sectionIdentifier = [sectionIdentifiers objectAtIndex:section];
    ORKFormItem *sectionFormItem = [self _formItemForFormItemIdentifier:sectionIdentifier];

    NSString *title = sectionFormItem.text;
    NSString *detailText = sectionFormItem.detailText;
    NSString *sectionProgressText = nil;
    ORKLearnMoreView *learnMoreView;
    NSString *tagText = sectionFormItem.tagText;
    BOOL hasMultipleChoiceFormItem = NO;
    
    if (sectionFormItem.showsProgress) {
        if ([self.delegate respondsToSelector:@selector(stepViewControllerTotalProgressInfoForStep:currentStep:)]) {
            ORKTaskTotalProgress progressInfo = [self.delegate stepViewControllerTotalProgressInfoForStep:self currentStep:self.step];
            if (progressInfo.stepShouldShowTotalProgress) {
                sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + progressInfo.currentStepStartingProgressPosition)), ORKLocalizedStringFromNumber(@(progressInfo.total))];
            }
        }
        
        if (!sectionProgressText) {
            // only display progress label if there are more than 1 sections in the form step
            if (snapshot.numberOfSections > 1) {
             sectionProgressText = [NSString localizedStringWithFormat:ORKLocalizedString(@"FORM_ITEM_PROGRESS", nil) ,ORKLocalizedStringFromNumber(@(section + 1)), ORKLocalizedStringFromNumber(@(snapshot.numberOfSections))];
            }
        }
    }
    
    if (sectionFormItem.learnMoreItem) {
        learnMoreView = [ORKLearnMoreView learnMoreViewWithItem:sectionFormItem.learnMoreItem];
        learnMoreView.delegate = self;
    }
    
    hasMultipleChoiceFormItem = (sectionFormItem.impliedAnswerFormat.questionType == ORKQuestionTypeMultipleChoice) ? YES : NO;
    
    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier: ORKSurveyCardHeaderViewIdentifier];
    
    [cardHeaderView configureWithTitle:title
                            detailText:detailText
                         learnMoreView:learnMoreView
                          progressText:sectionProgressText
                               tagText:tagText
                            showBorder:([self formStep].cardViewStyle == ORKCardViewStyleBordered)
                 hasMultipleChoiceItem:hasMultipleChoiceFormItem];

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
    NSString *warningStateMessage = [self getWarningStateMessageForSection:section];
    if (warningStateMessage) {
        WarningStateFooterView *footerView = (WarningStateFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:WarningStateFooterViewIdentifier];
        [footerView configureWith:warningStateMessage];
    
        BOOL shouldShowWarningMessage = [self containsTriggerValuesForSection:section];
        [footerView setShouldShowWarningMessage:shouldShowWarningMessage];
        
        return footerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *warningStateMessage = [self getWarningStateMessageForSection:section];
    if (warningStateMessage || section == tableView.numberOfSections - 1) {
        return UITableViewAutomaticDimension;
    }
    
    return 10.0 / self.safeDisplayScale;
}

@end


#pragma mark ORKFormItemCellDelegate

@implementation ORKFormStepViewController (ORKFormItemCellDelegate)

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
        ORKTableContainerView *tableContainer = _tableContainer;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [tableContainer scrollCellVisible:cell animated:YES];
        });
    }
}

- (void)formItemCellDidResignFirstResponder:(ORKFormItemCell *)cell {
    if (_currentFirstResponderCell == cell) {
        _currentFirstResponderCell = nil;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ORKTableCellItemIdentifier *cellItemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:indexPath];
    if ([cell isKindOfClass:[ORKFormItemPickerCell class]] || [cell isKindOfClass:[ORKFormItemTextCell class]]) {
        
        __weak typeof(self) weakSelf = self;
        [self _createDiffableSnapshot:_diffableDataSource withCompletion:^{
            [weakSelf finishHandlingFormItemCellDidResignFirstResponder:cellItemIdentifier];
        }];
    } else {
        [self finishHandlingFormItemCellDidResignFirstResponder:cellItemIdentifier];
    }
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithMessage:(NSString *)input {
    [self showValidityAlertWithMessage:input];
}

- (void)formItemCell:(ORKFormItemCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showValidityAlertWithTitle:title message:message];
}

- (void)formItemCell:(ORKFormItemCell *)cell answerDidChangeTo:(id)answer {
    if (cell.superview != nil) {
        ORKTableCellItemIdentifier *cellItemIdentifier = [_diffableDataSource itemIdentifierForIndexPath:[_tableView indexPathForCell:cell]];
        [self saveAnswer:answer forItemIdentifier:cellItemIdentifier];

        // If a real answer was provided, deselect the Don't Know cell if one exists
        if (![answer isKindOfClass:[ORKDontKnowAnswer class]] && [cell.formItem.answerFormat shouldShowDontKnowButton]) {
            ORKTableCellItemIdentifier *dontKnowIdentifier = [ORKTableCellItemIdentifier dontKnowIdentifierWithFormItemIdentifier:cellItemIdentifier.formItemIdentifier];
            NSIndexPath *dontKnowIndexPath = [_diffableDataSource indexPathForItemIdentifier:dontKnowIdentifier];
            ORKChoiceViewCell *dontKnowCell = ORKDynamicCast([_tableView cellForRowAtIndexPath:dontKnowIndexPath], ORKChoiceViewCell);
            [dontKnowCell setCellSelected:NO highlight:NO];
        }
    } else {
        // if the cell isn't in the view hierarchy, this change is coming from configuring the cell
        // ignore
    }
}

- (BOOL)formItemCellShouldDismissKeyboard:(ORKFormItemCell *)cell {
    if ([self didAutoScrollToNextItem:cell]) {
        return NO;
    }
    return YES;
}

@end


#pragma mark ORKTableContainerViewDelegate

@implementation ORKFormStepViewController (ORKTableContainerViewDelegate)

- (UITableViewCell *)currentFirstResponderCellForTableContainerView:(ORKTableContainerView *)tableContainerView {
    return _currentFirstResponderCell;
}

@end


#pragma mark - ORKChoiceOtherViewCellDelegate

@implementation ORKFormStepViewController (ORKChoiceOtherViewCellDelegate)

- (void)textChoiceOtherCellDidBecomeFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    _currentFirstResponderCell = choiceOtherViewCell;
    NSIndexPath *path = [_tableView indexPathForCell:choiceOtherViewCell];
    if (path) {
        ORKTableContainerView *tableContainer = _tableContainer;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DelayBeforeAutoScroll * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [tableContainer scrollCellVisible:choiceOtherViewCell animated:YES];
        });
    }
}

- (void)textChoiceOtherCellDidChangeText:(NSString *)text choiceOtherCell:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    [self updateTextChoiceOtherWithText:text choiceOtherCell:choiceOtherViewCell];
}

- (void)textChoiceOtherCellDidResignFirstResponder:(ORKChoiceOtherViewCell *)choiceOtherViewCell {
    [self updateTextChoiceOtherWithText:choiceOtherViewCell.textView.text choiceOtherCell:choiceOtherViewCell];
}

@end


#pragma mark - ORKlearnMoreStepViewControllerDelegate

@implementation ORKFormStepViewController (ORKLearnMoreViewDelegate)

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep {
    [self.taskViewController learnMoreButtonPressedWithStep:learnMoreStep fromStepViewController:self];
}

@end
