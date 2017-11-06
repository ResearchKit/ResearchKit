//
//  BRKPopover.m
//  Pods-KioskApp
//
//  Created by User on 11/2/17.
//

#import "BRKPopover.h"
#import "ORKTextFieldView.h"
#import <ResearchKit/ORKContinueButton.h>

@implementation BRKPopoverViewController

- (instancetype)initWithSourceView:(UIView *)sourceView {
    self = [super init];
    if (self && sourceView) {
        self.sourceView = sourceView;
        self.modalPresentationStyle = UIModalPresentationPopover;
        
        // Set default values
        self.popoverOffset = 20.0f;
        self.popoverWidth = sourceView.frame.size.width - 2 * self.popoverOffset;
        
        [self preparePopover];
    }
    return self;
}

- (void)viewDidLoad {
    [self viewInit];
}

- (void)preparePopover {
    UIPopoverPresentationController *popover = self.popoverPresentationController;
    popover.sourceView = self.sourceView;
    
    if (self.sourceView.superview.frame.size.height / 2 < self.sourceView.frame.origin.y) {
        popover.permittedArrowDirections = UIPopoverArrowDirectionDown;
        popover.sourceRect = CGRectMake(self.popoverOffset, 0.0f, self.popoverWidth, 0.0f);
    } else {
        popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        popover.sourceRect = CGRectMake(self.popoverOffset, self.sourceView.frame.size.height, self.popoverWidth, 0.0f);
    }
    
    popover.backgroundColor = [UIColor lightGrayColor];
    popover.delegate = self;
}

- (void)viewInit {
    // Subclasses should override this
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end

@implementation BRKTextFieldPopoverViewController

- (instancetype)initWithSourceView:(UIView *)sourceView {
    self = [super initWithSourceView:sourceView];
    return self;
}

- (instancetype)initWithSourceView:(UIView *)sourceView format:(ORKTextAnswerFormat *)format {
    self = [self initWithSourceView:sourceView];
    if (self) {
        _answerFormat = format;
    }
    return self;
}

- (void)viewInit {
    self.textFieldView = [[ORKTextFieldView alloc] init];
    self.textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
    
    ORKUnitTextField *textField = self.textFieldView.textField;
    textField.placeholder = self.answerFormat.textForSubAnswer;
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor whiteColor];
    textField.allowsSelection = YES;
    [self.view addSubview:self.textFieldView];
    
    self.continueButton = [[ORKContinueButton alloc] initWithTitle:@"Done" isDoneButton:NO];
    self.continueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueButton addTarget:self action:@selector(continueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.continueButton];
    
    [self setUpContentConstraint];
    [self updateConstraints];
}

- (IBAction) continueButtonClicked: (id)sender {
    [self.delegate popoverViewController:self didChangedResult:self.textFieldView.textField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setUpContentConstraint {
    NSLayoutConstraint *contentConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:0.0];
    contentConstraint.priority = UILayoutPriorityDefaultHigh;
    contentConstraint.active = YES;
}

- (void)updateConstraints {
    [NSLayoutConstraint deactivateConstraints:_variableConstraints];
    [_variableConstraints removeAllObjects];
    
    if (!_variableConstraints) {
        _variableConstraints = [NSMutableArray new];
    }
    
    CGFloat margin = self.popoverOffset;
    CGFloat spacer = 15.0f;
    
    NSDictionary *metrics = @{@"vMargin":@(margin),
                              @"hMargin":@(margin),
                              @"hSpacer":@(spacer), @"vSpacer":@(spacer)};
    
    id textFieldView = self.textFieldView;
    id continueButton = self.continueButton;
    NSDictionary *views = NSDictionaryOfVariableBindings(textFieldView, continueButton);
    
    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[textFieldView]-hMargin-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:metrics
                                               views:views]];
    
    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hMargin-[continueButton]-hMargin-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:metrics
                                               views:views]];
    
    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vMargin-[textFieldView]-vSpacer-[continueButton]-vMargin-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:metrics
                                               views:views]];
    
    // Layout subviews for get their height
    [self.view layoutSubviews];
    
    // Make textFieldView height equal continueButton
    CGFloat popoverHeight = self.continueButton.bounds.size.height * 2 + margin * 2 + spacer;
    
    NSLayoutConstraint *heightConstraint =
    [NSLayoutConstraint constraintWithItem:self.view
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:popoverHeight];
    
    // Lower the priority to avoid conflicts with system supplied UIView-Encapsulated-Layout-Height constraint.
    heightConstraint.priority = 999;
    [self.variableConstraints addObject:heightConstraint];
    
    [self.view addConstraints:self.variableConstraints];
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [self.view updateConstraints];
    
    self.preferredContentSize = CGSizeMake(self.popoverWidth, popoverHeight);
}

@end
