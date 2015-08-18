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


#import "ORKStepViewController.h"
#import "ORKDefines_Private.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKStepViewController_Internal.h"
#import "ORKHelpers.h"
#import "UIBarButtonItem+ORKBarButtonItem.h"


@interface ORKStepViewController () {
    BOOL _hasBeenPresented;
    BOOL _dismissing;
    BOOL _presentingAlert;
}

@property (nonatomic, strong,readonly) UIBarButtonItem *flexSpace;
@property (nonatomic, strong,readonly) UIBarButtonItem *fixedSpace;

@end


@implementation ORKStepViewController

- (void)initializeInternalButtonItems {
    _internalBackButtonItem = [UIBarButtonItem obk_backBarButtonItemWithTarget:self action:@selector(goBackward)];
    _internalBackButtonItem.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    _internalContinueButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_NEXT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goForward)];
    _internalDoneButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_DONE", nil) style:UIBarButtonItemStyleDone target:self action:@selector(goForward)];
    _internalSkipButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_SKIP", nil) style:UIBarButtonItemStylePlain target:self action:@selector(skipForward)];
    _backButtonItem = _internalBackButtonItem;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeInternalButtonItems];
    }
    return self;
}
#pragma clang diagnostic pop

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeInternalButtonItems];
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [self init];
    if (self) {
        [self initializeInternalButtonItems];
        [self setStep:step];
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    // Default implementation ignores the previous result.
    return [self initWithStep:step];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = ORKColor(ORKBackgroundColorKey);
    
}

- (void)setupButtons {
    if (self.hasPreviousStep == YES) {
        [self ork_setBackButtonItem: _internalBackButtonItem];
    } else {
        [self ork_setBackButtonItem:nil];
    }
    
    if (self.hasNextStep == YES) {
        self.continueButtonItem = _internalContinueButtonItem;
    } else {
        self.continueButtonItem = _internalDoneButtonItem;
    }
    
    self.skipButtonItem = _internalSkipButtonItem;
}

- (void)setStep:(ORKStep *)step {
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot set step after presenting step view controller" userInfo:nil];
    }
    if ( step && nil == [step identifier]) {
        NSLog(@"%@ Step's identifier should not be nil.",  NSStringFromSelector(_cmd));
    }
    
    _step = step;
    
    [step validateParameters];
    
    [self setupButtons];
    [self stepDidChange];
}

- (void)stepDidChange {
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ORK_Log_Debug(@"%@", self);
    
    // Required here (instead of viewDidLoad) because any custom buttons are set once the delegate responds to the stepViewControllerWillAppear,
    // otherwise there is a minor visual glitch, where the original buttons are displayed on the UI for a short period. This is not placed after
    // the delegate responds to the stepViewControllerWillAppear, so that the target from the button's item can be used, if the intention is to
    // only modify the title of the button.
    [self setupButtons];
    
    if ([self.delegate respondsToSelector:@selector(stepViewControllerWillAppear:)]) {
        [self.delegate stepViewControllerWillAppear:self];
    }
        
    if (!_step) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot present step view controller without a step" userInfo:nil];
    }
    _hasBeenPresented = YES;
    
    // Set presentedDate on first time viewWillAppear
    if (!self.presentedDate) {
        self.presentedDate = [NSDate date];
    }
    
    // clear dismissedDate
    self.dismissedDate = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _dismissing = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];

    // Set endDate if current stepVC is dismissed
    // Because stepVC is embeded in a UIPageViewController,
    // when current stepVC is out of screen, it didn't belongs to UIPageViewController's viewControllers any more.
    // If stepVC is just covered by a modal view, dismissedDate should not be set.
    if (self.nextResponder == nil ||
        ([self.parentViewController isKindOfClass:[UIPageViewController class]]
            && NO == [[(UIPageViewController *)self.parentViewController viewControllers] containsObject:self])) {
        self.dismissedDate = [NSDate date];
    }
    _dismissing = NO;
}

- (void)willNavigateDirection:(ORKStepViewControllerNavigationDirection)direction {
}

- (void)setContinueButtonTitle:(NSString *)continueButtonTitle {
    self.internalContinueButtonItem.title = continueButtonTitle;
    self.internalDoneButtonItem.title = continueButtonTitle;
    
    self.continueButtonItem = self.internalContinueButtonItem;
}

- (NSString *)continueButtonTitle {
    return self.continueButtonItem.title;
}

- (void)setLearnMoreButtonTitle:(NSString *)learnMoreButtonTitle {
    self.learnMoreButtonItem.title = learnMoreButtonTitle;
    self.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (NSString *)learnMoreButtonTitle {
    return self.learnMoreButtonItem.title;
}

- (void)setSkipButtonTitle:(NSString *)skipButtonTitle {
    self.internalSkipButtonItem.title = skipButtonTitle;
    self.skipButtonItem = self.internalSkipButtonItem;
}

- (NSString *)skipButtonTitle {
    return self.skipButtonItem.title;
}

// internal use version to set backButton, without overriding "_internalBackButtonItem"
- (void)ork_setBackButtonItem:(UIBarButtonItem *)backButton {
    backButton.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    _backButtonItem = backButton;
    [self updateNavLeftBarButtonItem];
}

// Subclass should avoid using this method, which wound overide "_internalBackButtonItem"
- (void)setBackButtonItem:(UIBarButtonItem *)backButton {
    backButton.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    _backButtonItem = backButton;
    _internalBackButtonItem = backButton;
    [self updateNavLeftBarButtonItem];
}

- (void)updateNavRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = _cancelButtonItem;
}

- (void)updateNavLeftBarButtonItem {
    self.navigationItem.leftBarButtonItem = _backButtonItem;
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButton {
    _cancelButtonItem = cancelButton;
    [self updateNavRightBarButtonItem];
}

- (BOOL)hasPreviousStep {
    STRONGTYPE(self.delegate) delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(stepViewControllerHasPreviousStep:)]) {
        return [delegate stepViewControllerHasPreviousStep:self];
    }
    
    return NO;
}

- (BOOL)hasNextStep {
    STRONGTYPE(self.delegate) delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(stepViewControllerHasNextStep:)]) {
        return [delegate stepViewControllerHasNextStep:self];
    }
    
    return NO;
}

- (ORKStepResult *)result {
    
    ORKStepResult *sResult = [[ORKStepResult alloc] initWithStepIdentifier:self.step.identifier results:@[]];
    sResult.startDate = self.presentedDate;
    sResult.endDate = self.dismissedDate? :[NSDate date];
    
    return sResult;
}

- (void)notifyDelegateOnResultChange {
    
    STRONGTYPE(self.delegate) delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(stepViewControllerResultDidChange:)]) {
        [delegate stepViewControllerResultDidChange:self];
    }
}

- (BOOL)hasBeenPresented {
    return _hasBeenPresented;
}

- (BOOL)canChangeStepResult {
    if (!self.step || !self.taskViewController) {
        return NO;
    }
    BOOL isReviewStepStandalone = NO;
    ORKReviewStep *reviewStep = [self.taskViewController reviewStepForStep:self.step];
    if (reviewStep) {
        isReviewStepStandalone = reviewStep.isStandalone;
    }
    return self.step.isBeingReviewed ? !isReviewStepStandalone : YES;
}

#pragma mark - Action Handlers

- (void)goForward {
    
    STRONGTYPE(self.delegate) strongDelegate = self.delegate;
    [strongDelegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionForward];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)goBackward {
    
    STRONGTYPE(self.delegate) strongDelegate = self.delegate;
    [strongDelegate stepViewController:self didFinishWithNavigationDirection:ORKStepViewControllerNavigationDirectionReverse];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)skipForward {
    [self goForward];
}

- (ORKTaskViewController *)taskViewController {
    UIPageViewController *pageViewController = (UIPageViewController *)[self parentViewController];
    if (pageViewController && [pageViewController isKindOfClass:[UIPageViewController class]]) {
        UINavigationController *navigationController = (UINavigationController *)[pageViewController parentViewController];
        ORKTaskViewController *taskViewController = (ORKTaskViewController *)[navigationController parentViewController];
        if (taskViewController && [taskViewController isKindOfClass:[ORKTaskViewController class]]) {
            return taskViewController;
        }
    }
    return nil;
}

- (void)showValidityAlertWithMessage:(NSString *)text {
    
    if (! [text length]) {
        // No alert if the value is empty
        return;
    }
    if (_dismissing || ![self isViewLoaded] || ! [self.view window]) {
        // No alert if not in view chain.
        return;
    }
    
    if (_presentingAlert) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"RANGE_ALERT_TITLE", nil)
                                                                   message:text
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    
    _presentingAlert = YES;
    [self presentViewController:alert animated:YES completion:^{
        _presentingAlert = NO;
    }];
}

#pragma mark - UIStateRestoring
static NSString *const _ORKStepIdentifierRestoreKey = @"stepIdentifier";
static NSString *const _ORKPresentedDateRestoreKey = @"presentedDate";
static NSString *const _ORKOutputDirectoryKey = @"outputDirectory";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_step.identifier forKey:_ORKStepIdentifierRestoreKey];
    [coder encodeObject:_presentedDate forKey:_ORKPresentedDateRestoreKey];
    [coder encodeObject:ORKBookmarkDataFromURL(_outputDirectory) forKey:_ORKOutputDirectoryKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.outputDirectory = ORKURLFromBookmarkData([coder decodeObjectOfClass:[NSData class] forKey:_ORKOutputDirectoryKey]);
    
    if (! self.step) {
        // Just logging to the console in this case, since this can happen during a taskVC restoration of a dynamic task.
        // The step VC will get restored, but then never added back to the hierarchy.
        NSLog(@"%@",[NSString stringWithFormat:@"WARNING: No step provided while restoring %@", NSStringFromClass([self class])]);
    }
    
    self.presentedDate = [coder decodeObjectOfClass:[NSDate class] forKey:_ORKPresentedDateRestoreKey];
    self.restoredStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKStepIdentifierRestoreKey];
    
    if (self.step && _restoredStepIdentifier && ! [self.step.identifier isEqualToString:_restoredStepIdentifier]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Attempted to restore step with identifier %@ but got step identifier %@", _restoredStepIdentifier, self.step.identifier]
                                     userInfo:nil];
    }
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    ORKStepViewController *viewController = [[[self class] alloc] initWithStep:nil];
    viewController.restorationIdentifier = [identifierComponents lastObject];
    viewController.restorationClass = self;
    return viewController;
}

@end
