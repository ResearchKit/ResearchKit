//
//  ORKAutocompleteStepView.m
//  Medable Axon
//
//  Copyright (c) 2016 Medable Inc. All rights reserved.
//
//

#import "ORKAutocompleteStepView.h"
#import "ORKAutocompleteStep.h"
#import "ORKSurveyAnswerCellForText.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKCustomStepView_Internal.h"

@interface ORKAutocompleteStepView()
    <UITableViewDelegate,
    UITableViewDataSource,
    ORKSurveyAnswerCellDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSString *searchTerm;
@property (nonatomic) NSArray<NSString *> *filteredTerms;

@property (nonatomic) NSString *answer;
@property (nonatomic) ORKSurveyAnswerCellForTextField *answerCell;

@end

@implementation ORKAutocompleteStepView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self != nil )
    {
        UIView *contentView = [[UIView alloc] initWithFrame:frame];
        
        _tableView = [UITableView new];
        _tableView.frame = frame;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [contentView addSubview:_tableView];
        
        _searchTerm = @"";
        
        self.stepView = contentView;
    }
    
    return self;
}

- (void)setAutocompleteStep:(ORKAutocompleteStep *)autocompleteStep
{
    _autocompleteStep = autocompleteStep;
    //TINCHO: [self.continueSkipContainer updateContinueAndSkipEnabled];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.stepViewFillsAvailableSpace = YES;
    self.verticalCenteringEnabled = YES;
    
    [self filterSearchTerms];
    
    [self setUpCellConstraints];
}

- (void)filterSearchTerms
{
    if ( self.searchTerm.length == 0 )
    {
        self.filteredTerms = self.autocompleteStep.completionTextList;
    }
    else
    {
        NSPredicate *matchPredicate = [NSPredicate predicateWithBlock:
                                       ^BOOL(NSString  *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings)
                                       {
                                           if ( self.autocompleteStep.matchAnywhere )
                                           {
                                               return [evaluatedObject localizedCaseInsensitiveContainsString:self.searchTerm];
                                           }
                                           else
                                           {
                                               NSRange range = [evaluatedObject rangeOfString:self.searchTerm options:NSCaseInsensitiveSearch];
                                               
                                               return range.location == 0;
                                           }
                                       }];
        
        self.filteredTerms = [self.autocompleteStep.completionTextList filteredArrayUsingPredicate:matchPredicate];
    }
}

- (UITableViewCell *)cell
{
    return nil;
}

- (void)setUpCellConstraints
{
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_tableView]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_tableView]-|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    // Get a full width layout
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:10000];
    
    widthConstraint.priority = UILayoutPriorityDefaultLow + 1;
    
    [constraints addObject:widthConstraint];
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - UITableViewDelegate

- (void)tapOffAction:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    UIView *view = [self hitTest:point withEvent:nil];
    
    while (view)
    {
        if ( [view isKindOfClass:[UITableViewCell class]] )
        {
            UITableViewCell *cell = (UITableViewCell *)view;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            if ( indexPath != nil )
            {
                [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                [self.answerCell endEditing:NO];
                break;
            }
        }
        view = [view superview];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( indexPath.section == 1 )
    {
        NSString *suggestion = self.filteredTerms[indexPath.row];
        self.answerCell.answer = suggestion;
        [self answerCell:self.answerCell answerDidChangeTo:suggestion dueUserAction:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == 1 )
    {
        return 30;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( section == 1 )
    {
        UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
        headerView.textLabel.text = @"Suggestions";
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        return 50.0;
    }
    
    return 45.0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == 0 )
    {
        return 1;
    }
    else
    {
        return self.filteredTerms.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 )
    {
        NSString *cellId = @"kAutocompleteTableViewInputFieldCellId";
        
        ORKSurveyAnswerCellForTextField *inputCell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if ( inputCell == nil )
        {
            self.answerCell = [[ORKSurveyAnswerCellForTextField alloc] initWithStyle:UITableViewCellStyleDefault
                                                                     reuseIdentifier:cellId
                                                                                step:[self autocompleteStep]
                                                                              answer:self.answer
                                                                            delegate:self];
            
            self.answerCell.showTopSeparator = YES;
            self.answerCell.showBottomSeparator = YES;
            
            inputCell = self.answerCell;
        }
        
        return inputCell;
    }
    else
    {
        NSString *cellId = @"kAutocompleteTableViewCellId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if ( cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        cell.textLabel.text = self.filteredTerms[indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

#pragma mark - ORKSurveyAnswerCellDelegate

- (void)answerCell:(ORKSurveyAnswerCell *)cell answerDidChangeTo:(id)answer dueUserAction:(BOOL)dueUserAction
{
    if ( answer != [NSNull null] )
    {
        self.searchTerm = answer;
    }
    else
    {
        self.searchTerm = @"";
    }
    self.answer = self.searchTerm;
    
    [self filterSearchTerms];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.answerDelegate answerCell:cell answerDidChangeTo:answer dueUserAction:dueUserAction];
}

- (void)answerCell:(ORKSurveyAnswerCell *)cell invalidInputAlertWithMessage:(NSString *)input
{
    
}

- (void)answerCell:(ORKSurveyAnswerCell *)cell invalidInputAlertWithTitle:(NSString *)title message:(NSString *)message
{
    
}

@end
