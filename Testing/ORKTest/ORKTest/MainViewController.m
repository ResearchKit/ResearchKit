/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015 - 2016, Ricardo Sanchez-Saez.
 Copyright (c) 2016, Sage Bionetworks.
 Copyright (c) 2017, Macro Yau.

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


#import "MainViewController.h"

#import "AppDelegate.h"
#import "DynamicTask.h"
#import "TaskFactory.h"

#import "ORKTest-Swift.h"

@import ResearchKit;

@import AVFoundation;


NSArray<NSDictionary<NSString *, NSArray<NSString *> *> *> *TestButtonTable()
{
    return @[
             @{ @"Active Tasks":
                    @[
                        @"Active Step",
                        @"Audio",
                        @"Fitness",
                        @"GAIT",
                        @"Hand Tremor",
                        @"Hand (Right) Tremor",
                        @"Hole Peg Test",
                        @"Memory Game",
                        @"PSAT",
                        @"Reaction Time",
                        @"Stroop",
                        @"Timed Walk",
                        @"Tone Audiometry",
                        @"Tower Of Hanoi",
                        @"Trail Making",
                        @"Two Finger Tapping",
                        @"Walk And Turn",
                        ]},
             @{ @"Forms":
                    @[
                        @"Confirmation Form Item",
                        @"Mini Form",
                        @"Optional Form",
                        ]},
             @{ @"Onboarding":
                    @[
                        @"Consent",
                        @"Consent Review",
                        @"Eligibility Form",
                        @"Eligibility Survey",
                        @"Login",
                        @"Registration",
                        @"Verification",
                        ]},
             @{ @"Passcode Management":
                    @[
                        @"Authenticate Passcode",
                        @"Create Passcode",
                        @"Edit Passcode",
                        @"Remove Passcode",
                        ]},
             @{ @"Question Steps":
                    @[
                        @"Date Pickers",
                        @"Image Capture",
                        @"Image Choice",
                        @"Location",
                        @"Scale",
                        @"Scale (Color Gradient)",
                        @"Selection Survey",
                        @"Video Capture",
                        ]},
             @{ @"Task Customization":
                    @[
                        @"Custom View Controller",
                        @"Dynamic",
                        @"Interruptible",
                        @"Navigable Ordered",
                        @"Navigable Ordered Loop",
                        @"Step Will Appear",
                        @"Step Will Disappear",
                        ]},
             @{ @"Task Review":
                    @[
                        @"Embedded Review",
                        @"Standalone Review",
                        ]},
             @{ @"Utility Steps":
                    @[
                        @"Auxiliary Image Step",
                        @"Completion Step",
                        @"Footnote Step",
                        @"Icon Image Step",
                        @"Page Step",
                        @"Predicate Tests",
                        @"Signature Step",
                        @"Table Step",
                        @"Video Instruction Step",
                        @"Wait Step",
                        @"Web View Step"
                        ]},
             @{ @"Miscellaneous":
                    @[
                        @"Continue Button",
                        @"Test Charts",
                        @"Test Charts Performance",
                        @"Toggle Tint Color",
                        ]},
             ];
}


@interface SectionHeader: UICollectionReusableView

- (void)configureHeaderWithTitle:(NSString *)title;

@end


@implementation SectionHeader {
    UILabel *_title;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

static UIColor *HeaderColor() {
    return [UIColor colorWithWhite:0.97 alpha:1.0];
}

static const CGFloat HeaderSideLayoutMargin = 16.0;

- (void)sharedInit {
    self.layoutMargins = UIEdgeInsetsMake(0, HeaderSideLayoutMargin, 0, HeaderSideLayoutMargin);
    self.backgroundColor = HeaderColor();
    _title = [UILabel new];
    _title.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold]; // Table view header font
    [self addSubview:_title];
    
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"title": _title};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (void)configureHeaderWithTitle:(NSString *)title {
    _title.text = title;
}

@end


@interface ButtonCell: UICollectionViewCell

- (void)configureButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;

@end


@implementation ButtonCell {
    UIButton *_button;
}

- (void)setUpButton {
    [_button removeFromSuperview];
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.titleLabel.adjustsFontSizeToFitWidth = YES;
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _button.contentEdgeInsets = UIEdgeInsetsMake(0.0, HeaderSideLayoutMargin, 0.0, 0.0);
    [self.contentView addSubview:_button];
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"button": _button};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
}

- (void)configureButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    [self setUpButton];
    [_button setTitle:title forState:UIControlStateNormal];
    [_button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end


#define ORKTDefineStringKey(x) static NSString *const x = @#x

ORKTDefineStringKey(CollectionViewHeaderReuseIdentifier);
ORKTDefineStringKey(CollectionViewCellReuseIdentifier);

@interface MainViewController () <ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ORKPasscodeDelegate>

@end


@implementation MainViewController {
    ORKTaskViewController *_taskViewController;
    id<ORKTaskResultSource> _lastRouteResult;
    
    NSMutableDictionary<NSString *, NSData *> *_savedViewControllers;     // Maps task identifiers to task view controller restoration data
    
    UICollectionView *_collectionView;
    NSArray<NSDictionary<NSString *, NSArray<NSString *> *> *> *_buttonSections;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.restorationIdentifier = @"main";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _savedViewControllers = [NSMutableDictionary new];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SectionHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:CollectionViewHeaderReuseIdentifier];
    [_collectionView registerClass:[ButtonCell class]
        forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
    
    UIView *statusBarBackground = [UIView new];
    statusBarBackground.backgroundColor = HeaderColor();
    [self.view addSubview:statusBarBackground];

    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    statusBarBackground.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"collectionView": _collectionView,
                            @"statusBarBackground": statusBarBackground,
                            @"topLayoutGuide": self.topLayoutGuide};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBarBackground]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarBackground]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:statusBarBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    _buttonSections = TestButtonTable();
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 22.0);  // Table view header height
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat viewWidth = self.view.bounds.size.width;
    NSUInteger numberOfColums = 2;
    if (viewWidth >= 667.0) {
        numberOfColums = 3;
    }
    CGFloat width = viewWidth / numberOfColums;
    return CGSizeMake(width, 44.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _buttonSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _buttonSections[section].allValues[0].count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionViewHeaderReuseIdentifier forIndexPath:indexPath];
    NSString *title = _buttonSections[indexPath.section].allKeys[0];
    [sectionHeader configureHeaderWithTitle:title];
    return sectionHeader;
}

NSString *RemoveParenthesisAndCapitalizeString(NSString *string) {
    // "THIS (FOO) baR title" is converted to the "This Foo Bar Title"
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString replaceOccurrencesOfString:@"(" withString:@"" options:0 range:NSMakeRange(0, mutableString.length)];
    [mutableString replaceOccurrencesOfString:@")" withString:@"" options:0 range:NSMakeRange(0, mutableString.length)];
    return mutableString.capitalizedString;
}

- (SEL)selectorFromButtonTitle:(NSString *)buttonTitle {
    // "THIS (FOO) baR title" is converted to the "thisFooBarTitleButtonTapped:" selector
    buttonTitle = RemoveParenthesisAndCapitalizeString(buttonTitle);
    NSMutableArray *titleTokens = [[buttonTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    titleTokens[0] = ((NSString *)titleTokens[0]).lowercaseString;
    NSString *selectorString = [NSString stringWithFormat:@"%@ButtonTapped:", [titleTokens componentsJoinedByString:@""]];
    return NSSelectorFromString(selectorString);
}

- (NSString *)taskIdentifierFromButtonTitle:(NSString *)buttonTitle {
    // "THIS (FOO) baR title" is converted to the "ThisFooBarTitleTaskIdentifier" selector
    buttonTitle = RemoveParenthesisAndCapitalizeString(buttonTitle);
    NSMutableArray *titleTokens = [[buttonTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    NSString *taskIdentifier = [NSString stringWithFormat:@"%@TaskIdentifier", [titleTokens componentsJoinedByString:@""]];
    return taskIdentifier;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseIdentifier forIndexPath:indexPath];
    NSString *buttonTitle = _buttonSections[indexPath.section].allValues[0][indexPath.row];
    [buttonCell configureButtonWithTitle:buttonTitle target:self selector:@selector(buttonTapped:)];
    return buttonCell;
}

- (void)buttonTapped:(UIButton *)button {
    NSString *buttonTitle = button.titleLabel.text;
    SEL buttonSelector = [self selectorFromButtonTitle:buttonTitle];
    if ([self respondsToSelector:buttonSelector]) {
        // Equivalent to [self peformSelector:buttonSelector], but ARC safe
        IMP imp = [self methodForSelector:buttonSelector];
        void (*func)(id, SEL, UIButton *button) = (void *)imp;
        func(self, buttonSelector, button);
    } else {
        [self beginTaskWithIdentifier:[self taskIdentifierFromButtonTitle:buttonTitle]];
    }
}

/*
 Creates a task and presents it with a task view controller.
 */
- (void)beginTaskWithIdentifier:(NSString *)identifier {
    /*
     This is our implementation of restoration after saving during a task.
     If the user saved their work on a previous run of a task with the same
     identifier, we attempt to restore the view controller here.
     
     Since unarchiving can throw an exception, in a real application we would
     need to attempt to catch that exception here.
     */

    id<ORKTask> task = [[TaskFactory sharedInstance] makeTaskWithIdentifier:identifier];
    NSParameterAssert(task != nil);
    
    if (_savedViewControllers[identifier]) {
        NSData *data = _savedViewControllers[identifier];
        _taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:data delegate:self];
    } else {
        // No saved data, just create the task and the corresponding task view controller.
        _taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    }
    
    // If we have stored data then data will contain the stored data.
    // If we don't, data will be nil (and the task will be opened up as a 'new' task.
    NSData *data = _savedViewControllers[identifier];
    _taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:data delegate:self];
    
    [self beginTask];
}

/*
 Actually presents the task view controller.
 */
- (void)beginTask {
    NSObject<ORKTask> *task = _taskViewController.task;
    _taskViewController.delegate = self;
    
    if (_taskViewController.outputDirectory == nil) {
        // Sets an output directory in Documents, using the `taskRunUUID` in the path.
        NSURL *documents =  [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *outputDir = [documents URLByAppendingPathComponent:_taskViewController.taskRunUUID.UUIDString];
        [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
        _taskViewController.outputDirectory = outputDir;
    }
    
    /*
     For the dynamic task, we remember the last result and use it as a source
     of default values for any optional questions.
     */
    if ([task isKindOfClass:[DynamicTask class]]) {
        _taskViewController.defaultResultSource = _lastRouteResult;
    }
    
    /*
     We set a restoration identifier so that UI state restoration is enabled
     for the task view controller. We don't need to do anything else to prepare
     for state restoration of a ResearchKit framework task VC.
     */
    _taskViewController.restorationIdentifier = task.identifier;
    
    [self presentViewController:_taskViewController animated:YES completion:nil];
}

#pragma mark - Custom Button Actions

// Passcode management
- (void)authenticatePasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        ORKPasscodeViewController *viewController = [ORKPasscodeViewController
                                                     passcodeAuthenticationViewControllerWithText:@"Authenticate your passcode in order to proceed."
                                                     delegate:self];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:@"A passcode must be created before you can authenticate it."];
    }
}

- (void)editPasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        ORKPasscodeViewController *viewController = [ORKPasscodeViewController passcodeEditingViewControllerWithText:nil
                                                                                                            delegate:self
                                                                                                        passcodeType:ORKPasscodeType6Digit];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:@"A passcode must be created before you can edit it."];
    }
}

- (void)removePasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        if ([ORKPasscodeViewController removePasscodeFromKeychain]) {
            [self showAlertWithTitle:@"Success" message:@"Passcode removed."];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Passcode could not be removed."];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:@"There is no passcode stored in the keychain."];
    }
}

// Task Review
- (IBAction)standaloneReviewButtonTapped:(UIButton *)button {
    if ([TaskFactory sharedInstance].embeddedReviewTaskResult != nil) {
        NSString *buttonTitle = button.titleLabel.text;
        [self beginTaskWithIdentifier:[self taskIdentifierFromButtonTitle:buttonTitle]];
    } else {
        [self showAlertWithTitle:@"Alert" message:@"Please run embedded review task first"];
    }
}

// Miscellaneous
- (IBAction)continueButtonButtonTapped:(UIButton *)button {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContinueButtonExample" bundle:nil];
    UIViewController *viewcController = [storyboard instantiateInitialViewController];
    [self presentViewController:viewcController animated:YES completion:nil];
}

- (void)toggleTintColorButtonTapped:(UIButton *)button {
    static UIColor *defaultTintColor = nil;
    if (!defaultTintColor) {
        defaultTintColor = self.view.tintColor;
    }
    if ([[UIView appearance].tintColor isEqual:[UIColor redColor]]) {
        [UIView appearance].tintColor = defaultTintColor;
    } else {
        [UIView appearance].tintColor = [UIColor redColor];
    }
    // Update appearance
    UIView *superview = self.view.superview;
    [self.view removeFromSuperview];
    [superview addSubview:self.view];
}

#pragma mark - Passcode delegate

- (void)passcodeViewControllerDidFailAuthentication:(UIViewController *)viewController {
    NSLog(@"Passcode authentication failed.");
    [self showAlertWithTitle:@"Error" message:@"Passcode authentication failed"];
}

- (void)passcodeViewControllerDidFinishWithSuccess:(UIViewController *)viewController {
    NSLog(@"New passcode saved.");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)passcodeViewControllerDidCancel:(UIViewController *)viewController {
    NSLog(@"User tapped the cancel button.");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)passcodeViewControllerForgotPasscodeTapped:(UIViewController *)viewController {
    NSLog(@"Forgot Passcode tapped.");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forgot Passcode"
                                                                   message:@"Forgot Passcode tapped."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)testChartsButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

- (void)testChartsPerformanceButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartPerformanceListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

#pragma mark - Helpers

/*
 Shows an alert.
 
 Used to display an alert with the provided title and message.
 
 @param title       The title text for the alert.
 @param message     The message text for the alert.
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Managing the task view controller

/*
 Dismisses the task view controller.
 */
- (void)dismissTaskViewController:(ORKTaskViewController *)taskViewController removeOutputDirectory:(BOOL)removeOutputDirectory {
    [TaskFactory sharedInstance].currentConsentDocument = nil;
    
    NSURL *outputDirectoryURL = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (outputDirectoryURL && removeOutputDirectory)
        {
            /*
             We attempt to clean up the output directory.
             
             This is only useful for a test app, where we don't care about the
             data after the test is complete. In a real application, only
             delete your data when you've processed it or sent it to a server.
             */
            NSError *err = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:outputDirectoryURL error:&err]) {
                NSLog(@"Error removing %@: %@", outputDirectoryURL, err);
            }
        }
    }];
}

#pragma mark - ORKTaskViewControllerDelegate

/*
 Any step can have "Learn More" content.
 
 For testing, we return YES only for instruction steps, except on the active
 tasks.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step {
    NSObject<ORKTask> *task = taskViewController.task;

    return ([step isKindOfClass:[ORKInstructionStep class]]
            && !task.hidesLearnMoreButtonOnInstructionStep);
}

/*
 When the user taps on "Learn More" on a step, respond on this delegate callback.
 In this test app, we just print to the console.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    NSLog(@"Learn more tapped for step %@", stepViewController.step.identifier);
}

- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step {
    BOOL shouldPresentStep = YES;
    if (step.shouldPresentStepBlock) {
        shouldPresentStep = step.shouldPresentStepBlock(taskViewController, step);
    }
    return shouldPresentStep;
}

/*
 In `stepViewControllerWillAppear:`, it is possible to significantly customize
 the behavior of the step view controller. In this test app, we do a few funny
 things to push the limits of this customization.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController
stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    ORKStep *step = stepViewController.step;
    if (step.stepViewControllerWillAppearBlock) {
        step.stepViewControllerWillAppearBlock(taskViewController, stepViewController);
    }
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillDisappear:(ORKStepViewController *)stepViewController navigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    ORKStep *step = stepViewController.step;
    if (step.stepViewControllerWillDisappearBlock) {
        step.stepViewControllerWillDisappearBlock(taskViewController, stepViewController, direction);
    }
}

/*
 We support save and restore on all of the tasks in this test app.
 
 In a real app, not all tasks necessarily ought to support saving -- for example,
 active tasks that can't usefully be restarted after a significant time gap
 should not support save at all.
 */
- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController {
    return YES;
}

/*
 In almost all cases, we want to dismiss the task view controller.
 
 In this test app, we don't dismiss on a fail (we just log it).
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    switch (reason) {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = taskViewController.result;
            }
            [self taskViewControllerDidComplete:taskViewController];
        }
            break;
        case ORKTaskViewControllerFinishReasonFailed:
        {
            NSLog(@"Error on step %@: %@", taskViewController.currentStepViewController.step, error);
        }
            break;
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = nil;
            }
            [self dismissTaskViewController:taskViewController removeOutputDirectory:YES];
        }
            break;
        case ORKTaskViewControllerFinishReasonSaved:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = taskViewController.result;
            }
            /*
             Save the restoration data, dismiss the task VC, and do an early return
             so we don't clear the restoration data.
             */
            _savedViewControllers[task.identifier] = taskViewController.restorationData;
            [self dismissTaskViewController:taskViewController removeOutputDirectory:NO];
            return;
        }
            break;
            
        default:
            break;
    }
    
    [_savedViewControllers removeObjectForKey:taskViewController.task.identifier];
    _taskViewController = nil;
}

/*
 When a task completes, we pretty-print the result to the console.
 
 This is ok for testing, but if what you want to do is see the results of a task,
 the `ORKCatalog` Swift sample app might be a better choice, since it lets
 you navigate through the result structure.
 */
- (void)taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController {
    
    NSLog(@"[ORKTest] task results: %@", taskViewController.result);
    
    // Validate the results
    NSArray *results = taskViewController.result.results;
    if (results) {
        NSSet *uniqueResults = [NSSet setWithArray:results];
        BOOL allResultsUnique = (results.count == uniqueResults.count);
        NSAssert(allResultsUnique, @"The returned results have duplicates of the same object.");
    }
    
    if ([TaskFactory sharedInstance].currentConsentDocument) {
        /*
         This demonstrates how to take a signature result, apply it to a document,
         and then generate a PDF From the document that includes the signature.
         */
        
        // Search for the review step.
        NSArray *steps = [(ORKOrderedTask *)taskViewController.task steps];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [ORKConsentReviewStep class]];
        ORKStep *reviewStep = [[steps filteredArrayUsingPredicate:predicate] firstObject];
        ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:reviewStep.identifier] firstResult];
        
        [signatureResult applyToDocument:[TaskFactory sharedInstance].currentConsentDocument];
        
        [[TaskFactory sharedInstance].currentConsentDocument makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
            NSLog(@"Created PDF of size %lu (error = %@)", (unsigned long)pdfData.length, error);
            
            if (!error) {
                NSURL *documents = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
                NSURL *outputUrl = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", taskViewController.taskRunUUID.UUIDString]];
                
                [pdfData writeToURL:outputUrl atomically:YES];
                NSLog(@"Wrote PDF to %@", [outputUrl path]);
            }
        }];
        
        [TaskFactory sharedInstance].currentConsentDocument = nil;
    }
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            NSError *err = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
            }
        }
    }];
}

/**
  When a task has completed it calls this method to post the result of the task to the delegate.
*/
- (void)taskViewController:(ORKTaskViewController *)taskViewController didChangeResult:(ORKTaskResult *)result {
    /*
     Upon creation of a Passcode by a user, the results of their creation
     are returned by getting it from ORKPasscodeResult in this delegate call.
     This is triggered upon completion/failure/or cancel
     */
    ORKStepResult *stepResult = (ORKStepResult *)[[result results] firstObject];
    if ([[[stepResult results] firstObject] isKindOfClass:[ORKPasscodeResult class]]) {
        ORKPasscodeResult *passcodeResult = (ORKPasscodeResult *)[[stepResult results] firstObject];
        NSLog(@"passcode saved: %d , Touch ID Enabled: %d", passcodeResult.passcodeSaved, passcodeResult.touchIdEnabled);

    }
}

#pragma mark - UI state restoration

/*
 UI state restoration code for the MainViewController.
 
 The MainViewController needs to be able to re-create the exact task that
 was being done, in order for the task view controller to restore correctly.
 
 In a real app implementation, this might mean that you would also need to save
 and restore the actual task; here, since we know the tasks don't change during
 testing, we just re-create the task.
 */
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskViewController forKey:@"taskVC"];
    [coder encodeObject:_lastRouteResult forKey:@"lastRouteResult"];
    [coder encodeObject:[TaskFactory sharedInstance].embeddedReviewTaskResult forKey:@"embeddedReviewTaskResult"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _taskViewController = [coder decodeObjectOfClass:[UIViewController class] forKey:@"taskVC"];
    _lastRouteResult = [coder decodeObjectForKey:@"lastRouteResult"];
    
    // Need to give the task VC back a copy of its task, so it can restore itself.
    
    // Could save and restore the task's identifier separately, but the VC's
    // restoration identifier defaults to the task's identifier.
    id<ORKTask> taskForTaskViewController = [[TaskFactory sharedInstance] makeTaskWithIdentifier:_taskViewController.restorationIdentifier];
    
    _taskViewController.task = taskForTaskViewController;
    if ([_taskViewController.restorationIdentifier isEqualToString:@"DynamicTask01"])
    {
        _taskViewController.defaultResultSource = _lastRouteResult;
    }
    _taskViewController.delegate = self;
}

@end
