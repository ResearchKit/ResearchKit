/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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


#import "ORKFamilyHistoryStepViewController.h"

#import "ORKAccessibilityFunctions.h"
#import "ORKFamilyHistoryRelatedPersonCell.h"
#import "ORKFamilyHistoryStepViewController_Private.h"
#import "ORKFamilyHistoryTableFooterView.h"
#import "ORKFamilyHistoryTableHeaderView.h"
#import "ORKLearnMoreStepViewController.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKReviewIncompleteCell.h"
#import "ORKStepContainerView.h"
#import "ORKStepContentView.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTableContainerView.h"
#import "ORKTaskViewController_Internal.h"

#import <ResearchKit/ORKAnswerFormat.h>
#import <ResearchKit/ORKAnswerFormat_Internal.h>
#import <ResearchKit/ORKCollectionResult_Private.h>
#import <ResearchKit/ORKConditionStepConfiguration.h>
#import <ResearchKit/ORKFamilyHistoryResult.h>
#import <ResearchKit/ORKFamilyHistoryStep.h>
#import <ResearchKit/ORKFormStep.h>
#import <ResearchKit/ORKHealthCondition.h>
#import <ResearchKit/ORKHelpers_Internal.h>
#import <ResearchKit/ORKNavigableOrderedTask.h>
#import <ResearchKit/ORKPredicateFormItemVisibilityRule.h>
#import <ResearchKit/ORKRelatedPerson.h>
#import <ResearchKit/ORKRelativeGroup.h>
#import <ResearchKit/ORKResultPredicate.h>
#import <ResearchKit/ORKResult_Private.h>
#import <ResearchKit/ORKSkin.h>
#import <ResearchKit/ORKStep_Private.h>
#import <ResearchKit/ORKQuestionResult.h>


@class ORKTaskViewController;


NSString * const ORKFamilyHistoryRelatedPersonCellIdentifier = @"ORKFamilyHistoryRelatedPersonCellIdentifier";

NSString * const ORKHealthConditionIDontKnowChoiceValue = @"do not know";
NSString * const ORKHealthConditionNoneOfTheAboveChoiceValue = @"none of the above";
NSString * const ORKHealthConditionPreferNotToAnswerChoiceValue = @"prefer not to answer";


@interface ORKFamilyHistoryStepViewController () <ORKTableContainerViewDelegate, ORKTaskViewControllerDelegate, ORKFamilyHistoryTableFooterViewDelegate, ORKFamilyHistoryRelatedPersonCellDelegate>

@property (nonatomic, strong) ORKTableContainerView *tableContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKStepContentView *headerView;

@end


@implementation ORKFamilyHistoryStepViewController {
    NSArray<NSLayoutConstraint *> *_constraints;
    
    NSArray<ORKRelativeGroup *> *_relativeGroups;
    NSArray<ORKNavigableOrderedTask *> *_relativeGroupOrderedTasks;
    
    NSMutableDictionary<NSString *, NSMutableArray<ORKRelatedPerson *> *> *_relatedPersons;
    NSMutableArray<NSString *> *_displayedConditions;
    NSArray<NSString *> *_conditionIdentifiersFromLastSession;
    
    NSMutableDictionary<NSString *, NSString *> *_conditionsTextAndValues;
    
    NSArray<NSString *> *_conditionsWithinCurrentTask;
    
    BOOL _editingPreviousTask;
    ORKRelatedPerson *_relativeForPresentedTask;
}


- (instancetype)ORKFamilyHistoryStepViewController_initWithResult:(ORKResult *)result {
    ORKStepResult *stepResult = (ORKStepResult *)result;
    if (stepResult && stepResult.results.count > 0) {
        ORKFamilyHistoryResult *familyHistoryResult = (ORKFamilyHistoryResult *)stepResult.firstResult;
        
        if (familyHistoryResult) {
            _relatedPersons = [NSMutableDictionary new];
            for (ORKRelatedPerson *relatedPerson in familyHistoryResult.relatedPersons) {
                [self saveRelatedPerson:[relatedPerson copy]];
            }
 
            _conditionIdentifiersFromLastSession = [familyHistoryResult.displayedConditions copy];
        }
        
    }
    
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step];
    return [self ORKFamilyHistoryStepViewController_initWithResult:result];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
    
    _relatedPersons = _relatedPersons ? : [NSMutableDictionary new];
    _displayedConditions = [NSMutableArray new];
    _conditionsTextAndValues = [NSMutableDictionary new];
    
    _relativeGroups = [[self familyHistoryStep].relativeGroups copy];
    
    [self configureOrderedTasks];

    [_tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [_tableContainer setNeedsLayout];
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_tableContainer removeFromSuperview];
    _tableContainer = nil;
    
    if (self.isViewLoaded && self.step) {
        _tableContainer = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainer.tableContainerDelegate = self;
        [self.view addSubview:_tableContainer];
        _tableContainer.tapOffView = self.view;
        
        [self setupViews];
    }
}

- (void)setupViews {
    [self setupTableView];
    [self setupHeaderView];
    [self setupFooterViewIfNeeded];
    [self updateViewColors];
    
    [self setupConstraints];
    [_tableContainer setNeedsLayout];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    [self setupViews];
    [self updateViewColors];
}

- (void)updateNavBarBackgroundColor:(UIColor *)color {
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = color;
    appearance.shadowImage = [UIImage new];
    appearance.shadowColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationController.navigationBar.compactAppearance = appearance;
    self.navigationController.navigationBar.standardAppearance = appearance;
    
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.compactScrollEdgeAppearance = appearance;
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

- (void)setupTableView {
    _tableView = _tableContainer.tableView;
    [_tableView registerClass:[ORKFamilyHistoryRelatedPersonCell class] forCellReuseIdentifier:ORKFamilyHistoryRelatedPersonCellIdentifier];
    _tableView.separatorColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.clipsToBounds = YES;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
    _tableView.estimatedSectionHeaderHeight = 30.0;
}

- (void)setupHeaderView {
    _headerView = _tableContainer.stepContentView;
    _headerView.stepTopContentImage = self.step.image;
    _headerView.titleIconImage = self.step.iconImage;
    _headerView.stepTitle = self.step.title;
    _headerView.stepText = self.step.text;
    _headerView.stepDetailText = self.step.detailText;
    _headerView.stepHeaderTextAlignment = self.step.headerTextAlignment;
    _headerView.bodyItems = self.step.bodyItems;
    _tableContainer.stepTopContentImageContentMode = self.step.imageContentMode;
}

- (ORKFamilyHistoryStep *)familyHistoryStep {
    ORKFamilyHistoryStep *step = ORKDynamicCast(self.step, ORKFamilyHistoryStep);
    
    if (step == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"the ORKFamilyHistoryStepViewController must be presented with a ORKFamilyHistoryStep"  userInfo:nil];
    }
    
    return step;
}

- (void)configureOrderedTasks {
    NSMutableArray<ORKNavigableOrderedTask *> *relativeGroupOrderedTasks = [NSMutableArray new];
    
    ORKFamilyHistoryStep *step = [self familyHistoryStep];
    
    for (ORKRelativeGroup *relativeGroup in step.relativeGroups) {
        NSMutableArray<ORKStep *> *steps = [NSMutableArray array];
        
        // add formSteps from ORKRelativeGroup to steps array
        
        for (ORKFormStep *formStep in relativeGroup.formSteps) {
            [steps addObject:[formStep copy]];
        }
        
        // configure and add health condition formStep to steps array
        
        NSMutableArray<ORKFormItem *> *formItems = [NSMutableArray new];
        
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = [self makeConditionsTextChoiceAnswerFormat:[step.conditionStepConfiguration.conditions copy]];
        ORKFormItem *healthConditionsFormItem = [[ORKFormItem alloc] initWithIdentifier:step.conditionStepConfiguration.conditionsFormItemIdentifier
                                                                                   text:ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_FORM_ITEM_TEXT", @"")
                                                                           answerFormat:textChoiceAnswerFormat];
        
        
        healthConditionsFormItem.showsProgress = YES;
        
        [formItems addObject:healthConditionsFormItem];
        [formItems addObjectsFromArray:step.conditionStepConfiguration.formItems];
        
        ORKFormStep *conditionFormStep = [[ORKFormStep alloc] initWithIdentifier:step.conditionStepConfiguration.stepIdentifier];
        conditionFormStep.title = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_STEP_TITLE", @"");
        conditionFormStep.detailText = ORKLocalizedString(@"FAMILY_HISTORY_CONDITIONS_STEP_DESCRIPTION_TEMP", @"");
        conditionFormStep.optional = NO;
        conditionFormStep.formItems = [formItems copy];
        
        [steps addObject:conditionFormStep];
        
        ORKNavigableOrderedTask *orderedTask = [[ORKNavigableOrderedTask alloc] initWithIdentifier:relativeGroup.identifier steps:steps];
        [relativeGroupOrderedTasks addObject:orderedTask];
    }
    
    _relativeGroupOrderedTasks = [relativeGroupOrderedTasks copy];
}

- (ORKTextChoiceAnswerFormat *)makeConditionsTextChoiceAnswerFormat:(NSArray<ORKHealthCondition *> *)healthConditions {
    NSMutableArray<NSString *> *conditionsWithinCurrentTask = _conditionsWithinCurrentTask ? [_conditionsWithinCurrentTask mutableCopy] : [NSMutableArray new];
    
    NSMutableArray<ORKTextChoice *> *textChoices = [NSMutableArray new];
    for (ORKHealthCondition *healthCondition in healthConditions) {
        
        if (![conditionsWithinCurrentTask containsObject:healthCondition.identifier]) {
            [conditionsWithinCurrentTask addObject:healthCondition.identifier];
        }
        
        ORKTextChoice *textChoice = [[ORKTextChoice alloc] initWithText:healthCondition.displayName
                                                             detailText:nil
                                                                  value:healthCondition.value
                                                              exclusive:NO];
        
        [textChoices addObject:textChoice];
        
        _conditionsTextAndValues[(NSString *)healthCondition.value] = healthCondition.displayName;
    }
    
    _conditionsWithinCurrentTask = [conditionsWithinCurrentTask copy];
    
    ORKTextChoice *noneOfTheAboveTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"FAMILY_HISTORY_NONE_OF_THE_ABOVE", @"")
                                                         detailText:nil
                                                              value:ORKHealthConditionNoneOfTheAboveChoiceValue
                                                          exclusive:YES];
    
    ORKTextChoice *idkTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"FAMILY_HISTORY_I_DONT_KNOW", @"")
                                                         detailText:nil
                                                              value:ORKHealthConditionIDontKnowChoiceValue
                                                          exclusive:YES];
    
    ORKTextChoice *preferNotToAnswerTextChoice = [[ORKTextChoice alloc] initWithText:ORKLocalizedString(@"FAMILY_HISTORY_PREFER_NOT_TO_ANSWER", @"")
                                                         detailText:nil
                                                              value:ORKHealthConditionPreferNotToAnswerChoiceValue
                                                          exclusive:YES];
    
    [textChoices addObject:noneOfTheAboveTextChoice];
    [textChoices addObject:idkTextChoice];
    [textChoices addObject:preferNotToAnswerTextChoice];
    
    _conditionsTextAndValues[(NSString *)noneOfTheAboveTextChoice.value] = noneOfTheAboveTextChoice.text;
    _conditionsTextAndValues[(NSString *)idkTextChoice.value] = idkTextChoice.text;
    _conditionsTextAndValues[(NSString *)preferNotToAnswerTextChoice.value] = preferNotToAnswerTextChoice.text;
    
    ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = [[ORKTextChoiceAnswerFormat alloc] initWithStyle:ORKChoiceAnswerStyleMultipleChoice
                                                                                             textChoices:textChoices];
    
    return textChoiceAnswerFormat;
}

- (void)presentNewOrderedTaskForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    ORKNavigableOrderedTask *taskToPresent = [self taskForRelativeGroup:relativeGroup];
    
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:taskToPresent taskRunUUID:nil];
    taskViewController.modalPresentationStyle = UIModalPresentationAutomatic;
    taskViewController.delegate = self;
    
    [self presentViewController:taskViewController animated:YES completion:nil];
}

- (ORKNavigableOrderedTask *)taskForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    ORKNavigableOrderedTask *task;
    
    for (ORKNavigableOrderedTask *orderedTask in _relativeGroupOrderedTasks) {
        if ([orderedTask.identifier isEqual:relativeGroup.identifier]) {
            task = orderedTask;
            break;
        }
    }
    
    if (task == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"An orderedTask was not found for relative group `%@`", relativeGroup.name]  userInfo:nil];
    }
    
    return [task copy];
}

- (ORKRelativeGroup *)relativeGroupForRelatedPerson:(ORKRelatedPerson *)relatedPerson {
    ORKRelativeGroup *relativeGroup;
    
    for (ORKRelativeGroup *group in _relativeGroups) {
        if ([group.identifier isEqual:relatedPerson.groupIdentifier]) {
            relativeGroup = group;
            break;
        }
    }
    
    if (relativeGroup == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"An relative group was not found for related person `%@`", relatedPerson.identifier]  userInfo:nil];
    }
    
    return [relativeGroup copy];
}

- (ORKRelatedPerson *)relatedPersonAtIndexPath:(NSIndexPath *)indexPath {
    ORKRelativeGroup *relativeGroup = _relativeGroups[indexPath.section];
    return _relatedPersons[relativeGroup.identifier][indexPath.row];
}

- (void)saveRelatedPerson:(ORKRelatedPerson *)relatedPerson {
    // check if array for relativeGroup is initialized
    if (!_relatedPersons[relatedPerson.groupIdentifier]) {
        _relatedPersons[relatedPerson.groupIdentifier] = [NSMutableArray new];
    }
    
    [_relatedPersons[relatedPerson.groupIdentifier] addObject:relatedPerson];
    
}



- (BOOL)didReachMaxForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    return _relatedPersons[relativeGroup.identifier].count >= relativeGroup.maxAllowed;
}

- (NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *)getDetailInfoTextAndValuesForRelativeGroup:(ORKRelativeGroup *)relativeGroup {
    NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> *detailInfoTextAndValues = [NSMutableDictionary new];
    
    // parse all formSteps of the relativeGroup and check if any of its formItems are a choice type. If yes, we'll need to grab the text values from the textChoices for presentation in the tableView as opposed to presenting the value of the formItem
    for (ORKFormStep *formStep in relativeGroup.formSteps) {
        
        for (ORKFormItem *formItem in formStep.formItems) {
            
            for (NSString *identifier in relativeGroup.detailTextIdentifiers) {
                if ([identifier isEqual:formItem.identifier]) {
                    
                    detailInfoTextAndValues[identifier] = [NSMutableDictionary new];
                    
                    // check if formItem.answerFormat is of type ORKTextChoiceAnswerFormat, ORKTextScaleAnswerFormat, or ORKValuePickerAnswerFormat
                    NSArray<ORKTextChoice *> *textChoices = [NSArray new];
                    
                    if ([formItem.answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
                        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)formItem.answerFormat;
                        textChoices = textChoiceAnswerFormat.textChoices;
                    } else if ([formItem.answerFormat isKindOfClass:[ORKTextScaleAnswerFormat class]]) {
                        ORKTextScaleAnswerFormat *textScaleAnswerFormat = (ORKTextScaleAnswerFormat *)formItem.answerFormat;
                        textChoices = textScaleAnswerFormat.textChoices;
                    } else if ([formItem.answerFormat isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
                        ORKValuePickerAnswerFormat *valuePickerAnswerFormat = (ORKValuePickerAnswerFormat *)formItem.answerFormat;
                        textChoices = valuePickerAnswerFormat.textChoices;
                    }
                    
                    for (ORKTextChoice *textChoice in textChoices) {
                        if ([textChoice.value isKindOfClass:[NSString class]]) {
                            NSString *stringValue = (NSString *)textChoice.value;
                            detailInfoTextAndValues[identifier][stringValue] = textChoice.text;
                        }
                    }
                }
            }
        }
    }
    
    return [detailInfoTextAndValues copy];
}

- (NSArray<ORKRelatedPerson *> *)flattenRelatedPersonArrays {
    NSMutableArray<ORKRelatedPerson *> *relatedPersons = [NSMutableArray new];
    
    for (NSString *key in _relatedPersons) {
        [relatedPersons addObjectsFromArray:_relatedPersons[key]];
    }
    
    return [relatedPersons copy];
}

- (void)notifyDelegateOnResultChange {
    [super notifyDelegateOnResultChange];
    
    if (self.hasNextStep == NO) {
        self.continueButtonItem = self.internalDoneButtonItem;
    } else {
        self.continueButtonItem = self.internalContinueButtonItem;
    }
    
    self.skipButtonItem = self.internalSkipButtonItem;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKFamilyHistoryResult *familyHistoryResult = [[ORKFamilyHistoryResult alloc] initWithIdentifier:[self step].identifier];
    familyHistoryResult.startDate = stepResult.startDate;
    familyHistoryResult.endDate = stepResult.endDate;
    familyHistoryResult.relatedPersons = [self flattenRelatedPersonArrays];
    familyHistoryResult.displayedConditions = [_displayedConditions copy];
    [results addObject:familyHistoryResult];

    stepResult.results = [results copy];
    
    return stepResult;
}

- (void)resultUpdated {
    // For subclasses
}

- (nonnull UITableViewCell *)currentFirstResponderCellForTableContainerView:(nonnull ORKTableContainerView *)tableContainerView {
    return [UITableViewCell new];
}

#pragma mark ORKTaskViewControllerDelegate

- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskFinishReason)reason error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (reason) {
            case ORKTaskFinishReasonFailed:
            case ORKTaskFinishReasonDiscarded:
                break;
            case ORKTaskFinishReasonSaved:
            case ORKTaskFinishReasonCompleted:
            case ORKTaskFinishReasonEarlyTermination:
                [self handleRelatedPersonTaskResult:taskViewController.result taskIdentifier:taskViewController.task.identifier];
                [self updateDisplayedConditionsFromTaskResult:taskViewController.result];
                break;
        }
        
        self->_editingPreviousTask = NO;
        self->_relativeForPresentedTask = nil;
    }];
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreStep forStepViewController:(ORKStepViewController *)stepViewController {
    ORKLearnMoreStepViewController *learnMoreStepViewController = [[ORKLearnMoreStepViewController alloc] initWithStep:learnMoreStep result:nil];
    [stepViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:learnMoreStepViewController] animated:YES completion:nil];
}

#pragma mark ORKFamilyHistoryRelatedPersonCellDelegate
    
- (void)familyHistoryRelatedPersonCell:(ORKFamilyHistoryRelatedPersonCell *)relatedPersonCell tappedOption:(ORKFamilyHistoryTooltipOption)option {
    NSIndexPath *indexPath = [_tableView indexPathForCell:relatedPersonCell];
    ORKRelatedPerson *currentRelatedPerson = [self relatedPersonAtIndexPath:indexPath];
  
    if (currentRelatedPerson) {
        switch (option) {
            case ORKFamilyHistoryTooltipOptionEdit: {
                // edit flow for ORKRelatedPerson
                ORKRelativeGroup *relativeGroup = [self relativeGroupForRelatedPerson:currentRelatedPerson];
                ORKNavigableOrderedTask *relatedPersonTask = [self  taskForRelativeGroup:relativeGroup];
                
                _editingPreviousTask = YES;
                _relativeForPresentedTask = [currentRelatedPerson copy];
                
                ORKTaskViewController *taskVC = [[ORKTaskViewController alloc] initWithTask:relatedPersonTask
                                                                              ongoingResult:currentRelatedPerson.taskResult
                                                                         restoreAtFirstStep:YES
                                                                        defaultResultSource:nil
                                                                                   delegate:self];
                
                
                [self presentViewController:taskVC animated:YES completion:nil];
                break;
            }
                
            case ORKFamilyHistoryTooltipOptionDelete: {
                // delete flow for ORKRelatedPerson
                UIAlertController *deleteAlert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY_TITLE", @"")
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction* unfollowAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_DELETE_ENTRY", @"")
                                                                         style:UIAlertActionStyleDestructive
                                                                       handler:^(UIAlertAction * action) {
                    [self->_relatedPersons[currentRelatedPerson.groupIdentifier] removeObject:currentRelatedPerson];
                    NSIndexSet *section = [NSIndexSet indexSetWithIndex:indexPath.section];
                    [self->_tableView reloadSections:section withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self resultUpdated];
                }];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:ORKLocalizedString(@"FAMILY_HISTORY_CANCEL", @"")
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                
                [deleteAlert addAction:unfollowAction];
                [deleteAlert addAction:cancelAction];
                [self presentViewController:deleteAlert animated:YES completion:nil];
                break;
            }
        }
    }
}

#pragma mark ORKFamilyHistoryTableFooterViewDelegate

- (void)ORKFamilyHistoryTableFooterView:(ORKFamilyHistoryTableFooterView *)footerView didSelectFooterForRelativeGroup:(NSString *)groupIdentifier {
    for (ORKRelativeGroup *relativeGroup in _relativeGroups) {
        if ([relativeGroup.identifier isEqual:groupIdentifier]) {
            if (![self didReachMaxForRelativeGroup:[relativeGroup copy]]) {
                [self presentNewOrderedTaskForRelativeGroup:[relativeGroup copy]];
            }
        }
    }
}

@end

@implementation ORKFamilyHistoryStepViewController (ORKFamilyHistoryReviewSupport)

- (void)updateViewColors {
    UIColor *updateColor =  self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor systemGray6Color] : [UIColor systemGroupedBackgroundColor];;
    self.view.backgroundColor = updateColor;
    self.tableView.backgroundColor = updateColor;
    [self updateNavBarBackgroundColor: updateColor];
}

- (void)setupFooterViewIfNeeded {
    _navigationFooterView = _tableContainer.navigationFooterView;
    _navigationFooterView.skipButtonItem = self.skipButtonItem;
    _navigationFooterView.continueEnabled = YES;
    _navigationFooterView.continueButtonItem = self.continueButtonItem;
    _navigationFooterView.optional = self.step.optional;
    
    [_navigationFooterView removeStyling];
}

- (void)handleRelatedPersonTaskResult:(ORKTaskResult *)taskResult taskIdentifier:(NSString *)identifier {
    ORKFamilyHistoryStep *familyHistoryStep = [self familyHistoryStep];

    // If the user is editing a previous task, just update the result of the relatedPerson
    if (_editingPreviousTask && _relativeForPresentedTask) {
        _relativeForPresentedTask.taskResult = taskResult;
        
        NSInteger index = 0;
        
        for (ORKRelatedPerson *relatedPerson in _relatedPersons[identifier]) {
            if ([relatedPerson.identifier isEqual:_relativeForPresentedTask.identifier]) {
                break;
            }
            
            index += 1;
        }
        
        _relatedPersons[identifier][index] = [_relativeForPresentedTask copy];
        
        
        [_tableView reloadData];
    } else {
        
        // create new relatedPerson object and attach taskResult
        for (ORKRelativeGroup *relativeGroup in familyHistoryStep.relativeGroups) {
            if ([relativeGroup.identifier isEqual:identifier]) {
                ORKRelatedPerson *relatedPerson = [[ORKRelatedPerson alloc] initWithIdentifier:[NSUUID new].UUIDString
                                                                               groupIdentifier:identifier
                                                                        identifierForCellTitle:relativeGroup.identifierForCellTitle
                                                                                    taskResult:taskResult];
                
                [self saveRelatedPerson:[relatedPerson copy]];
                [_tableView reloadData];
                break;
            }
        }
    }
    
    [self resultUpdated];
    
    [_tableContainer setNeedsLayout];
}

- (NSInteger)numberOfRowsForRelativeGroupInSection:(NSInteger)section {
    ORKRelativeGroup *relativeGroup = _relativeGroups[section];
    return _relatedPersons[relativeGroup.identifier].count;
}

- (void)updateDisplayedConditionsFromTaskResult:(ORKTaskResult *)taskResult {
    ORKFamilyHistoryStep *step = [self familyHistoryStep];
    
    ORKStepResult *stepResult = (ORKStepResult *)[taskResult resultForIdentifier:step.conditionStepConfiguration.stepIdentifier];
    
    // if stepResult is nil, then choiceQuestionResult will also be nil here
    ORKChoiceQuestionResult *choiceQuestionResult = (ORKChoiceQuestionResult *)[stepResult resultForIdentifier:step.conditionStepConfiguration.conditionsFormItemIdentifier];

    // if choiceQuestionResult is nil, then choiceQuestionResult.choiceAnswers is nil
    NSArray<NSString *> *conditionsIdentifiers = choiceQuestionResult.choiceAnswers != nil ? _conditionsWithinCurrentTask : [NSArray new];
    
    for (NSString *conditionIdentifier in conditionsIdentifiers) {
          if (![_displayedConditions containsObject:conditionIdentifier]) {
            [_displayedConditions addObject:conditionIdentifier];
        }
    }
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _relativeGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsForRelativeGroupInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ORKRelativeGroup *relativeGroup = _relativeGroups[indexPath.section];
    
    // present a related person cell
    ORKFamilyHistoryRelatedPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:ORKFamilyHistoryRelatedPersonCellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    ORKFamilyHistoryStep  *familyHistoryStep = [self familyHistoryStep];
    
    BOOL didReachMaxNumberOfRelatives = [self didReachMaxForRelativeGroup:relativeGroup];
    BOOL shouldAddExtraSpaceBelowCell = ([self numberOfRowsForRelativeGroupInSection:indexPath.section] == (indexPath.row + 1)) && !didReachMaxNumberOfRelatives;
    ORKRelatedPerson *relatedPerson = [self relatedPersonAtIndexPath:indexPath];
    
    
    NSString *title = [relatedPerson getTitleValueWithIdentifier:relativeGroup.identifierForCellTitle];
    
    cell.title = title != nil ? title : [NSString stringWithFormat:@"%@ %ld", relativeGroup.name, indexPath.row + 1];
    cell.relativeID = [relatedPerson.identifier copy];
    NSArray *detailValues = [relatedPerson getDetailListValuesWithIdentifiers:relativeGroup.detailTextIdentifiers
                                                      displayInfoKeyAndValues:[self getDetailInfoTextAndValuesForRelativeGroup:relativeGroup]];
    
    NSArray *conditionValues = [relatedPerson getConditionsListWithStepIdentifier:familyHistoryStep.conditionStepConfiguration.stepIdentifier
                                                               formItemIdentifier:familyHistoryStep.conditionStepConfiguration.conditionsFormItemIdentifier
                                                              conditionsKeyValues:[_conditionsTextAndValues copy]];
    [cell configureWithDetailValues:detailValues conditionsValues:conditionValues isLastItemBeforeAddRelativeButton:shouldAddExtraSpaceBelowCell];
    cell.delegate = self;
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ORKRelativeGroup *relativeGroup = _relativeGroups[section];
    
    ORKFamilyHistoryTableHeaderView *headerView = (ORKFamilyHistoryTableHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (headerView == nil) {
        headerView = [[ORKFamilyHistoryTableHeaderView alloc] initWithTitle:relativeGroup.sectionTitle detailText:relativeGroup.sectionDetailText];
    }
    
    BOOL isExpanded = _relatedPersons[relativeGroup.identifier].count > 0;
    [headerView setExpanded:isExpanded];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    ORKRelativeGroup *relativeGroup = _relativeGroups[section];
    
    if ([self didReachMaxForRelativeGroup:relativeGroup]) {
        return 0;
    }
    
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ORKFamilyHistoryTableFooterView *footerView = (ORKFamilyHistoryTableFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    ORKRelativeGroup *relativeGroup = _relativeGroups[section];

    if (footerView == nil) {
        footerView = [[ORKFamilyHistoryTableFooterView alloc] initWithTitle:[NSString stringWithFormat:ORKLocalizedString(@"FAMILY_HISTORY_ADD", @"") ,relativeGroup.name]
                                                    relativeGroupIdentifier:[relativeGroup.identifier copy]
                                                                   delegate:self];
    }
    
    BOOL isExpanded = _relatedPersons[relativeGroup.identifier].count > 0;
    [footerView setExpanded:isExpanded];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


@end
