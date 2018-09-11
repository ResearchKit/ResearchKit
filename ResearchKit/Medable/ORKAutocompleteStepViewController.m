//
//  ORKAutocompleteStepViewController.m
//  Medable Axon
//
//  Copyright (c) 2016 Medable Inc. All rights reserved.
//
//

#import "ORKAutocompleteStep.h"
#import "ORKAutocompleteStepViewController.h"
#import "ORKAutocompleteStepView.h"

#import "ORKStepViewController_Internal.h"
#import "ORKQuestionStepViewController_Private.h"

@interface ORKQuestionStepViewController () <ORKSurveyAnswerCellDelegate>
@end

@interface ORKAutocompleteStepViewController () <ORKSurveyAnswerCellDelegate>

@property (nonatomic) ORKAutocompleteStepView *autocompleteStepView;

@property (nonatomic) NSLayoutConstraint *autocompleteStepViewHeightConstraint;
@property (nonatomic) BOOL keyboardWasPresentedAtLeastOnce;
@property (nonatomic, readwrite) CGFloat lastValidAutocompleteViewHeight;

@end

@implementation ORKAutocompleteStepViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.bounds;
    self.autocompleteStepView = [[ORKAutocompleteStepView alloc] initWithFrame:frame];
    self.autocompleteStepView.answerDelegate = self;
    self.autocompleteStepView.autocompleteStep = [self autocompleteStep];
    
    self.autocompleteStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self setCustomQuestionView:(ORKQuestionStepCustomView *)self.autocompleteStepView];
    
    [self registerForKeyboardNotifications:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.autocompleteStepView.frame.size.height > 0)
    {
        self.lastValidAutocompleteViewHeight = self.autocompleteStepView.frame.size.height;
    }
}

- (void)dealloc
{
    [self registerForKeyboardNotifications:NO];
}

- (void)registerForKeyboardNotifications:(BOOL)shouldRegister
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    if (shouldRegister)
    {
        [notificationCenter addObserver:self
                               selector:@selector(keyboardWillShow:)
                                   name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(keyboardWillHide:)
                                   name:UIKeyboardWillHideNotification object:nil];
        
    }
    else
    {
        [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ( !self.keyboardWasPresentedAtLeastOnce )
    {
        if ( self.autocompleteStepViewHeightConstraint == nil )
        {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.autocompleteStepView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:self.autocompleteStepView.frame.size.height];
            [self.autocompleteStepView addConstraint:constraint];
            
            self.autocompleteStepViewHeightConstraint = constraint;
            
            [self.view layoutIfNeeded];
        }
        
        if (self.autocompleteStepView.frame.size.height == 0)
        {
            self.autocompleteStepViewHeightConstraint.constant = self.lastValidAutocompleteViewHeight;
            [self.view layoutIfNeeded];
        }
    }
    
    self.keyboardWasPresentedAtLeastOnce = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.autocompleteStepViewHeightConstraint.constant = self.lastValidAutocompleteViewHeight;
    [self.view layoutIfNeeded];
}

- (ORKAutocompleteStep *)autocompleteStep
{
    return (ORKAutocompleteStep *)self.step;
}

- (BOOL)continueButtonEnabled
{
    NSString *answer = [self performSelector:@selector(answer)];
    if ( ! [answer isKindOfClass:[NSString class] ] )
    {
        return NO;
    }
    
    if ( self.autocompleteStep.restrictValue )
    {
        for ( NSString *possibleAnswer in self.autocompleteStep.completionTextList )
        {
            if ( [possibleAnswer caseInsensitiveCompare:answer] == NSOrderedSame )
            {
                return YES;
            }
        }
        
        return NO;
    }

    BOOL enabled = ( answer.length > 0 || (self.autocompleteStep.optional && !self.skipButtonItem));
    
    return enabled;
}

@end
