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


#import "BRKTaskViewController.h"

#import "ORKActiveStepViewController.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKFormStepViewController.h"
#import "ORKQuestionStepViewController.h"
#import "ORKReviewStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTappingIntervalStepViewController.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKVisualConsentStepViewController.h"

#import "ORKActiveStep.h"
#import "ORKFormStep.h"
#import "ORKInstructionStep.h"
#import "ORKOrderedTask.h"
#import "ORKQuestionStep.h"
#import "ORKResult_Private.h"
#import "ORKReviewStep_Internal.h"
#import "ORKStep_Private.h"
#import "ORKTappingIntervalStep.h"
#import "ORKVisualConsentStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKObserver.h"
#import "ORKSkin.h"

@import AVFoundation;
@import CoreMotion;
#import <CoreLocation/CoreLocation.h>

@protocol BRKViewControllerToolbarObserverDelegate <NSObject>

@required
- (void)collectToolbarItemsFromViewController:(UIViewController *)viewController;

@end


@interface BRKViewControllerToolbarObserver : ORKObserver

- (instancetype)initWithTargetViewController:(UIViewController *)target delegate:(id <BRKViewControllerToolbarObserverDelegate>)delegate;

@end


@implementation BRKViewControllerToolbarObserver

static void *_ORKViewControllerToolbarObserverContext = &_ORKViewControllerToolbarObserverContext;

- (instancetype)initWithTargetViewController:(UIViewController *)target delegate:(id <BRKViewControllerToolbarObserverDelegate>)delegate {
    return [super initWithTarget:target
                        keyPaths:@[ @"navigationItem.leftBarButtonItem", @"navigationItem.rightBarButtonItem", @"toolbarItems", @"navigationItem.title", @"navigationItem.titleView" ]
                        delegate:delegate
                          action:@selector(collectToolbarItemsFromViewController:)
                         context:_ORKViewControllerToolbarObserverContext];
}

@end


@interface BRKTaskViewController () <BRKViewControllerToolbarObserverDelegate, ORKScrollViewObserverDelegate> {
    NSMutableDictionary *_managedResults;
    NSMutableArray *_managedStepIdentifiers;
    BRKViewControllerToolbarObserver *_stepViewControllerObserver;
    ORKScrollViewObserver *_scrollViewObserver;
    BOOL _hasSetProgressLabel;
    BOOL _hasBeenPresented;

    NSURL *_outputDirectory;
    
    NSDate *_presentedDate;
    NSDate *_dismissedDate;
    
    NSString *_lastBeginningInstructionStepIdentifier;
    NSString *_lastRestorableStepIdentifier;
    
    NSString *_restoredTaskIdentifier;
    NSString *_restoredStepIdentifier;
}

@property (nonatomic, strong) UIImageView *hairline;

@property (nonatomic, strong) UINavigationController *childNavigationController;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) ORKStepViewController *currentStepViewController;

@end


@implementation BRKTaskViewController

@synthesize taskRunUUID=_taskRunUUID;
//
//let steps = [SurveyUIFactory.getInsuranceForm(),
//             SurveyUIFactory.getPaymentOptions(),
//             SurveyUIFactory.getPaymentMethods(),
//             SurveyUIFactory.getReceiptSignature()]
//
////            let task = ORKDelegateNavigatableTask(identifier: "payment_section", steps: steps)
////            let taskViewController = ORKTaskViewController(task: task, taskRun: NSUUID() as UUID)
////            taskViewController.delegate = self
////            self.present(taskViewController, animated: true, completion: nil)
//
//let vc = BRKFormStepViewController(step: SurveyUIFactory.getInsuranceForm())
//
//self.init(rootViewController: vc)


+ (void)initialize {
    if (self == [ORKTaskViewController class]) {
        
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[ORKTaskViewController class]]] setTranslucent:NO];
        if ([[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[ORKTaskViewController class]]] barTintColor] == nil) {
            [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[ORKTaskViewController class]]] setBarTintColor:ORKColor(ORKToolBarTintColorKey)];
        }
        
        if ([[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[ORKTaskViewController class]]] barTintColor] == nil) {
            [[UIToolbar appearanceWhenContainedInInstancesOfClasses:@[[ORKTaskViewController class]]] setBarTintColor:ORKColor(ORKToolBarTintColorKey)];
        }
    }
}

static NSString *const _PageViewControllerRestorationKey = @"pageViewController";
static NSString *const _ChildNavigationControllerRestorationKey = @"childNavigationController";

+ (UIPageViewController *)pageViewController {
    UIPageViewController *pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                             options:nil];
    if ([pageViewController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        pageViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    pageViewController.restorationIdentifier = _PageViewControllerRestorationKey;
    pageViewController.restorationClass = self;
    
    
    // Disable swipe to scroll
    for (UIScrollView *view in pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
    return pageViewController;
}

- (void)setChildNavigationController:(UINavigationController *)childNavigationController {
    if (_childNavigationController) {
        [_childNavigationController.view removeFromSuperview];
        [_childNavigationController removeFromParentViewController];
        _childNavigationController = nil;
    }
    
    if ([self isViewLoaded]) {
        UIView *v = self.view;
        UIView *childView = childNavigationController.view;
        childView.frame = v.bounds;
        childView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [v addSubview:childView];
    }
    _childNavigationController = childNavigationController;
    [self addChildViewController:_childNavigationController];
    [_childNavigationController didMoveToParentViewController:self];
    _childNavigationController.restorationClass = [self class];
    _childNavigationController.restorationIdentifier = _ChildNavigationControllerRestorationKey;
}

- (instancetype)commonInitWithTask:(id<ORKTask>)task taskRunUUID:(NSUUID *)taskRunUUID {
    UIPageViewController *pageViewController = [[self class] pageViewController];
    self.childNavigationController = [[UINavigationController alloc] initWithRootViewController:pageViewController];
    
    _pageViewController = pageViewController;
    [self setTask: task];
    
    self.showsProgressInNavigationBar = YES;
    
    _managedResults = [NSMutableDictionary dictionary];
    _managedStepIdentifiers = [NSMutableArray array];
    
    self.taskRunUUID = taskRunUUID;
    
    [self.childNavigationController.navigationBar setShadowImage:[UIImage new]];
    self.hairline = [self findHairlineViewUnder:self.childNavigationController.navigationBar];
    self.hairline.alpha = 0.0f;
    self.childNavigationController.toolbar.clipsToBounds = YES;
    
    // Ensure taskRunUUID has non-nil valuetaskRunUUID
    (void)[self taskRunUUID];
    self.restorationClass = [ORKTaskViewController class];
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return [self commonInitWithTask:nil taskRunUUID:[NSUUID UUID]];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self commonInitWithTask:nil taskRunUUID:[NSUUID UUID]];
}
#pragma clang diagnostic pop

- (instancetype)initWithTask:(id<ORKTask>)task taskRunUUID:(NSUUID *)taskRunUUID {
    self = [super initWithNibName:nil bundle:nil];
    return [self commonInitWithTask:task taskRunUUID:taskRunUUID];
}

- (instancetype)initWithTask:(id<ORKTask>)task restorationData:(NSData *)data delegate:(id<ORKTaskViewControllerDelegate>)delegate {
    
    self = [self initWithTask:task taskRunUUID:nil];
    
    if (self) {
        self.delegate = delegate;
        if (data != nil) {
            self.restorationClass = [self class];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            [self decodeRestorableStateWithCoder:unarchiver];
            [self applicationFinishedRestoringState];
        }
    }
    return self;
}

- (void)setTaskRunUUID:(NSUUID *)taskRunUUID {
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot change task instance UUID after presenting task controller" userInfo:nil];
    }
    
    _taskRunUUID = [taskRunUUID copy];
}

- (void)setTask:(id<ORKTask>)task {
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot change task after presenting task controller" userInfo:nil];
    }
    
    if (task) {
        if (![task conformsToProtocol:@protocol(ORKTask)]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Expected a task" userInfo:nil];
        }
        if (task.identifier == nil) {
            ORK_Log_Warning(@"Task identifier should not be nil.");
        }
        if ([task respondsToSelector:@selector(validateParameters)]) {
            [task validateParameters];
        }
    }
    
    
    _task = task;
}

- (UIBarButtonItem *)defaultCancelButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
}

- (UIBarButtonItem *)defaultLearnMoreButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_LEARN_MORE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(learnMoreAction:)];
}


- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){{0,0},{320,480}}];
    
    if (_childNavigationController) {
        UIView *childView = _childNavigationController.view;
        childView.frame = view.bounds;
        childView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [view addSubview:childView];
    }
    
    self.view = view;
}

- (void)jumpToRoot:(BOOL)animated {
    ORKStep *step = [self firstStep];
    if ([self shouldPresentStep:step]) {
        ORKStepViewController *firstViewController = [self viewControllerForStep:step];
        [self showViewController:firstViewController goForward:YES animated:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_task) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Attempted to present task view controller without a task" userInfo:nil];
    }
    
    if (!_hasBeenPresented) {
        // Add first step viewController
        ORKStep *step = [self nextStep];
        if ([self shouldPresentStep:step]) {
            ORKStepViewController *firstViewController = [self viewControllerForStep:step];
            [self showViewController:firstViewController goForward:YES animated:animated];
            
        }
        _hasBeenPresented = YES;
    }
    
    // Record TaskVC's start time.
    // TaskVC is one time use only, no need to update _startDate later.
    if (!_presentedDate) {
        _presentedDate = [NSDate date];
    }
    
    // Clear endDate if current TaskVC got presented again
    _dismissedDate = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Set endDate on TaskVC is dismissed,
    // because nextResponder is not nil when current TaskVC is covered by another modal view
    if (self.nextResponder == nil) {
        _dismissedDate = [NSDate date];
    }
}

- (UIImageView *)findHairlineViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
}

- (NSArray *)managedResults {
    NSMutableArray *results = [NSMutableArray new];
    
    [_managedStepIdentifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger idx, BOOL *stop) {
        id <NSCopying> key = [self uniqueManagedKey:identifier index:idx];
        ORKResult *result = _managedResults[key];
        NSAssert2(result, @"Result should not be nil for identifier %@ with key %@", identifier, key);
        [results addObject:result];
    }];
    
    return [results copy];
}

- (void)setManagedResult:(ORKStepResult *)result forKey:(NSString *)aKey {
    if (aKey == nil) {
        return;
    }
    
    if (result == nil || NO == [result isKindOfClass:[ORKStepResult class]]) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat: @"Expect result object to be `ORKStepResult` type and not nil: {%@ : %@}", aKey, result] userInfo:nil];
        return;
    }
    
    // Manage last result tracking (used in predicate navigation)
    // If the previous result and the replacement result are the same result then `isPreviousResult`
    // will be set to `NO` otherwise it will be marked with `YES`.
    ORKStepResult *previousResult = _managedResults[aKey];
    previousResult.isPreviousResult = YES;
    result.isPreviousResult = NO;
    
    if (_managedResults == nil) {
        _managedResults = [NSMutableDictionary new];
    }
    _managedResults[aKey] = result;
    
    // Also point to the object using a unique key
    NSUInteger idx = _managedStepIdentifiers.count;
    if ([_managedStepIdentifiers.lastObject isEqualToString:aKey]) {
        idx--;
    }
    id <NSCopying> uniqueKey = [self uniqueManagedKey:aKey index:idx];
    _managedResults[uniqueKey] = result;
}

- (id <NSCopying>)uniqueManagedKey:(NSString*)stepIdentifier index:(NSUInteger)index {
    return [NSString stringWithFormat:@"%@:%@", stepIdentifier, @(index)];
}

- (NSUUID *)taskRunUUID {
    if (_taskRunUUID == nil) {
        _taskRunUUID = [NSUUID UUID];
    }
    return _taskRunUUID;
}

- (ORKTaskResult *)result {
    
    ORKTaskResult *result = [[ORKTaskResult alloc] initWithTaskIdentifier:[self.task identifier] taskRunUUID:self.taskRunUUID outputDirectory:self.outputDirectory];
    result.startDate = _presentedDate;
    result.endDate = _dismissedDate ? :[NSDate date];
    
    // Update current step result
    [self setManagedResult:[self.currentStepViewController result] forKey:self.currentStepViewController.step.identifier];
    
    result.results = [self managedResults];
    
    return result;
}

- (NSData *)restorationData {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [self encodeRestorableStateWithCoder:archiver];
    [archiver finishEncoding];
    
    return [data copy];
}

- (void)ensureDirectoryExists:(NSURL *)outputDirectory {
    // Only verify existence if the output directory is non-nil.
    // But, even if the output directory is nil, we still set it and forward to the step VC.
    if (outputDirectory != nil) {
        BOOL isDirectory = NO;
        BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:outputDirectory.path isDirectory:&isDirectory];
        
        if (!directoryExists) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtURL:outputDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
                @throw [NSException exceptionWithName:NSGenericException reason:@"Could not create output directory and output directory does not exist" userInfo:@{@"error": error}];
            }
            isDirectory = YES;
        } else if (!isDirectory) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"Desired outputDirectory is not a directory or could not be created." userInfo:nil];
        }
    }
}

- (void)setOutputDirectory:(NSURL *)outputDirectory {
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot change outputDirectory after presenting task controller" userInfo:nil];
    }
    [self ensureDirectoryExists:outputDirectory];
    
    _outputDirectory = [outputDirectory copy];
    
    [[self currentStepViewController] setOutputDirectory:_outputDirectory];
}

- (void)setRegisteredScrollView:(UIScrollView *)registeredScrollView {
    if (_registeredScrollView != registeredScrollView) {
        
        // Clear harline
        self.hairline.alpha = 0.0;
        
        _registeredScrollView = registeredScrollView;
        
        // Stop old observer
        _scrollViewObserver = nil;
        
        // Start new observer
        if (_registeredScrollView) {
            _scrollViewObserver = [[ORKScrollViewObserver alloc] initWithTargetView:_registeredScrollView delegate:self];
        }
    }
}

- (void)goForward {
    [_currentStepViewController goForward];
}

- (void)goBackward {
    [_currentStepViewController goBackward];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask supportedOrientations;
    if (self.currentStepViewController) {
        supportedOrientations = self.currentStepViewController.supportedInterfaceOrientations;
    } else {
        supportedOrientations = [[self nextStep].stepViewControllerClass supportedInterfaceOrientations];
    }
    return supportedOrientations;
}

#pragma mark - internal helpers

- (void)updateLastBeginningInstructionStepIdentifierForStep:(ORKStep *)step
                                                  goForward:(BOOL)goForward {
    if (NO == goForward) {
        // Going backward, check current step to nil saved state
        if (_lastBeginningInstructionStepIdentifier != nil &&
            [_currentStepViewController.step.identifier isEqualToString:_lastBeginningInstructionStepIdentifier]) {
            
            _lastBeginningInstructionStepIdentifier = nil;
        }
        // Don't return here, because the *next* step might NOT be an instruction step
        // the next time we look.
    }
    
    ORKStep *nextStep = [self.task stepAfterStep:step withResult:[self result]];
    BOOL isNextStepInstructionStep = [nextStep isKindOfClass:[ORKInstructionStep class]];
    
    if (_lastBeginningInstructionStepIdentifier == nil &&
        nextStep && NO == isNextStepInstructionStep) {
        _lastBeginningInstructionStepIdentifier = step.identifier;
    }
}

- (BOOL)isStepLastBeginningInstructionStep:(ORKStep *)step {
    if (!step) {
        return NO;
    }
    return (_lastBeginningInstructionStepIdentifier != nil &&
            [step isKindOfClass:[ORKInstructionStep class]]&&
            [step.identifier isEqualToString:_lastBeginningInstructionStepIdentifier]);
}

- (void)showViewController:(ORKStepViewController *)viewController goForward:(BOOL)goForward animated:(BOOL)animated {
    if (nil == viewController) {
        return;
    }
    
    ORKStep *step = viewController.step;
    [self updateLastBeginningInstructionStepIdentifierForStep:step goForward:goForward];
    
    
    if ([self isStepLastBeginningInstructionStep:step]) {
        // Check again, in case it's a user-supplied view controller for this step that's not an ORKInstructionStepViewController.
        if ([viewController isKindOfClass:[ORKInstructionStepViewController class]]) {
            [(ORKInstructionStepViewController *)viewController useAppropriateButtonTitleAsLastBeginningInstructionStep];
        }
    }
    
    ORKStepViewController *fromController = self.currentStepViewController;
    
    if (step.identifier && ![_managedStepIdentifiers.lastObject isEqualToString:step.identifier]) {
        [_managedStepIdentifiers addObject:step.identifier];
    }
    if ([step isRestorable] && !(viewController.isBeingReviewed && viewController.parentReviewStep.isStandalone)) {
        _lastRestorableStepIdentifier = step.identifier;
    }
    
    UIPageViewControllerNavigationDirection direction = goForward ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    ORKAdjustPageViewControllerNavigationDirectionForRTL(&direction);
    
    ORKStepViewControllerNavigationDirection stepDirection = goForward ? ORKStepViewControllerNavigationDirectionForward : ORKStepViewControllerNavigationDirectionReverse;
    
    [viewController willNavigateDirection:stepDirection];
    
    ORK_Log_Debug(@"%@ %@", self, viewController);
    
    // Stop monitor old scrollView, reset hairline's alpha to 0;
    self.registeredScrollView = nil;
    
    // Switch to non-animated transition if the application is not in the foreground.
    animated = animated && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);
    
    // Update currentStepViewController now, so we don't accept additional transition requests
    // from the same VC.
    _currentStepViewController = viewController;
    
    NSString *progressLabel = nil;
    if ([self shouldDisplayProgressLabel]) {
        ORKTaskProgress progress = [_task progressOfCurrentStep:viewController.step withResult:[self result]];
        if (progress.total > 0) {
            progressLabel = [NSString localizedStringWithFormat:ORKLocalizedString(@"STEP_PROGRESS_FORMAT", nil) ,ORKLocalizedStringFromNumber(@(progress.current+1)), ORKLocalizedStringFromNumber(@(progress.total))];
        }
    }
    
    ORKWeakTypeOf(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[viewController] direction:direction animated:animated completion:^(BOOL finished) {
        
        if (weakSelf == nil) {
            ORK_Log_Debug(@"Task VC has been dismissed, skipping block code");
            return;
        }
        
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        
        ORK_Log_Debug(@"%@ %@", strongSelf, viewController);
        
        // Set the progress label only if non-nil or if it is nil having previously set a progress label.
        if (progressLabel || strongSelf->_hasSetProgressLabel) {
            strongSelf.pageViewController.navigationItem.title = progressLabel;
        }
        
        strongSelf->_hasSetProgressLabel = (progressLabel != nil);
        
        // Collect toolbarItems
        [strongSelf collectToolbarItemsFromViewController:viewController];
    }];
}

- (BOOL)shouldPresentStep:(ORKStep *)step {
    BOOL shouldPresent = (step != nil);
    
    if (shouldPresent && [self.delegate respondsToSelector:@selector(taskViewController:shouldPresentStep:)]) {
        shouldPresent = [self.delegate taskViewController:self shouldPresentStep:step];
    }
    
    return shouldPresent;
}

- (ORKStep *)firstStep {
    ORKStep *step = nil;
    
    if ([self.task respondsToSelector:@selector(stepAfterStep:withResult:)]) {
        step = [self.task stepAfterStep:nil withResult:[self result]];
    }
    
    return step;
    
}


- (ORKStep *)nextStep {
    ORKStep *step = nil;
    
    if ([self.task respondsToSelector:@selector(stepAfterStep:withResult:)]) {
        step = [self.task stepAfterStep:self.currentStepViewController.step withResult:[self result]];
    }
    
    return step;
    
}

- (ORKStep *)prevStep {
    ORKStep *step = nil;
    
    if ([self.task respondsToSelector:@selector(stepBeforeStep:withResult:)]) {
        step = [self.task stepBeforeStep:self.currentStepViewController.step withResult:[self result]];
    }
    
    return step;
}

- (void)collectToolbarItemsFromViewController:(UIViewController *)viewController {
    if (_currentStepViewController == viewController) {
        _pageViewController.toolbarItems = viewController.toolbarItems;
        _pageViewController.navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem;
        _pageViewController.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
        if (![self shouldDisplayProgressLabel]) {
            _pageViewController.navigationItem.title = viewController.navigationItem.title;
            _pageViewController.navigationItem.titleView = viewController.navigationItem.titleView;
        }
    }
}

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView {
    // alpha's range [0.0, 1.0]
    float alpha = MAX( MIN(scrollView.contentOffset.y / 64.0, 1.0), 0.0);
    self.hairline.alpha = alpha;
}

- (NSArray<ORKStep *> *)stepsForReviewStep:(ORKReviewStep *)reviewStep {
    NSMutableArray<ORKStep *> *steps = [[NSMutableArray<ORKStep *> alloc] init];
    if (reviewStep.isStandalone) {
        steps = nil;
    } else {
        ORKWeakTypeOf(self) weakSelf = self;
        [_managedStepIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            ORKStep *nextStep = [strongSelf.task stepWithIdentifier:(NSString*) obj];
            if (nextStep && ![nextStep.identifier isEqualToString:reviewStep.identifier]) {
                [steps addObject:nextStep];
            } else {
                *stop = YES;
            }
        }];
    }
    return [steps copy];
}

- (ORKStepViewController *)viewControllerForStep:(ORKStep *)step {
    if (step == nil) {
        return nil;
    }
    
    ORKStepViewController *stepViewController = nil;
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:viewControllerForStep:)]) {
        // NOTE: While the delegate does not have direct access to the defaultResultSource,
        // it is assumed that it can set results as needed on the custom implementation of an
        // ORKStepViewController that it returns.
        stepViewController = [self.delegate taskViewController:self viewControllerForStep:step];
    }
    
    // If the delegate did not return a step view controller then instantiate one
    if (!stepViewController) {
        
        // Special-case the ORKReviewStep
        if ([step isKindOfClass:[ORKReviewStep class]]) {
            ORKReviewStep *reviewStep = (ORKReviewStep *)step;
            NSArray *steps = [self stepsForReviewStep:reviewStep];
            id<ORKTaskResultSource> resultSource = reviewStep.isStandalone ? reviewStep.resultSource : self.result;
            stepViewController = [[ORKReviewStepViewController alloc] initWithReviewStep:(ORKReviewStep *) step steps:steps resultSource:resultSource];
            ORKReviewStepViewController *reviewStepViewController = (ORKReviewStepViewController *) stepViewController;
            reviewStepViewController.reviewDelegate = self;
        }
        else {
            
            // Get the step result associated with this step
            ORKStepResult *result = nil;
            ORKStepResult *previousResult = _managedResults[step.identifier];
            
            // Check the default source first
            BOOL alwaysCheckForDefaultResult = ([self.defaultResultSource respondsToSelector:@selector(alwaysCheckForDefaultResult)] &&
                                                [self.defaultResultSource alwaysCheckForDefaultResult]);
            if ((previousResult == nil) || alwaysCheckForDefaultResult) {
                result = [self.defaultResultSource stepResultForStepIdentifier:step.identifier];
            }
            
            // If nil, assign to the previous result (if available) otherwise create new instance
            if (!result) {
                result = previousResult ? : [[ORKStepResult alloc] initWithIdentifier:step.identifier];
            }
            
            // Allow the step to instantiate the view controller. This will allow either the default
            // implementation using an override of the internal method `-stepViewControllerClass` or
            // allow for storyboard implementations.
            stepViewController = [step instantiateStepViewControllerWithResult:result];
        }
    }
    
    // Throw an exception if the created step view controller is not a subclass of ORKStepViewController
    ORKThrowInvalidArgumentExceptionIfNil(stepViewController);
    if (![stepViewController isKindOfClass:[ORKStepViewController class]]) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"View controller should be of class %@", [ORKStepViewController class]] userInfo:@{@"viewController": stepViewController}];
    }
    
    // If this is a restorable task view controller, check that the restoration identifier and class
    // are set on the step result. If not, do so here. This gives the instantiator the opportunity to
    // set this value, but ensures that it is set to the default if the instantiator does not do so.
    if ([self.delegate respondsToSelector:@selector(taskViewControllerSupportsSaveAndRestore:)] &&
        [self.delegate taskViewControllerSupportsSaveAndRestore:self]){
        if (stepViewController.restorationIdentifier == nil) {
            stepViewController.restorationIdentifier = step.identifier;
        }
        if (stepViewController.restorationClass == nil) {
            stepViewController.restorationClass = [stepViewController class];
        }
    }
    
    stepViewController.outputDirectory = self.outputDirectory;
    [self setManagedResult:stepViewController.result forKey:step.identifier];
    
    
    if (stepViewController.cancelButtonItem == nil) {
        stepViewController.cancelButtonItem = [self defaultCancelButtonItem];
    }
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:hasLearnMoreForStep:)] &&
        [self.delegate taskViewController:self hasLearnMoreForStep:step]) {
        
        stepViewController.learnMoreButtonItem = [self defaultLearnMoreButtonItem];
    }
    
    stepViewController.delegate = self;
    
    _stepViewControllerObserver = [[BRKViewControllerToolbarObserver alloc] initWithTargetViewController:stepViewController delegate:self];
    return stepViewController;
}

- (BOOL)shouldDisplayProgressLabel {
    return self.showsProgressInNavigationBar && [_task respondsToSelector:@selector(progressOfCurrentStep:withResult:)] && self.currentStepViewController.step.showsProgress && !(self.currentStepViewController.parentReviewStep.isStandalone);
}

#pragma mark - internal action Handlers

- (void)finishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
        [strongDelegate taskViewController:self didFinishWithReason:reason error:error];
    }
}

- (void)presentCancelOptions:(BOOL)saveable sender:(UIBarButtonItem *)sender {
    
    if ([self.delegate respondsToSelector:@selector(taskViewControllerShouldConfirmCancel:)] &&
        ![self.delegate taskViewControllerShouldConfirmCancel:self]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
        });
        return;
    }
    
    BOOL supportSaving = NO;
    if ([self.delegate respondsToSelector:@selector(taskViewControllerSupportsSaveAndRestore:)]) {
        supportSaving = [self.delegate taskViewControllerSupportsSaveAndRestore:self];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    alert.popoverPresentationController.barButtonItem = sender;
    
    if (supportSaving && saveable) {
        [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OPTION_SAVE", nil)
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self finishWithReason:ORKTaskViewControllerFinishReasonSaved error:nil];
                                                    });
                                                }]];
    }
    
    NSString *discardTitle = saveable ? ORKLocalizedString(@"BUTTON_OPTION_DISCARD", nil) : ORKLocalizedString(@"BUTTON_OPTION_STOP_TASK", nil);
    
    [alert addAction:[UIAlertAction actionWithTitle:discardTitle
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self finishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
                                                });
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    // Should we also include visualConsentStep here? Others?
    BOOL isCurrentInstructionStep = [self.currentStepViewController.step isKindOfClass:[ORKInstructionStep class]];
    
    // [self result] would not include any results beyond current step.
    // Use _managedResults to get the completed result set.
    NSArray *results = _managedResults.allValues;
    BOOL saveable = NO;
    for (ORKStepResult *result in results) {
        if ([result isSaveable]) {
            saveable = YES;
            break;
        }
    }
    
    BOOL isStandaloneReviewStep = NO;
    if ([self.currentStepViewController.step isKindOfClass:[ORKReviewStep class]]) {
        ORKReviewStep *reviewStep = (ORKReviewStep *)self.currentStepViewController.step;
        isStandaloneReviewStep = reviewStep.isStandalone;
    }
    
    if ((isCurrentInstructionStep && saveable == NO) || isStandaloneReviewStep || self.currentStepViewController.readOnlyMode) {
        [self finishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
    } else {
        [self presentCancelOptions:saveable sender:sender];
    }
}

- (IBAction)learnMoreAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(taskViewController:learnMoreForStep:)]) {
        [self.delegate taskViewController:self learnMoreForStep:self.currentStepViewController];
    }
}

- (void)reportError:(NSError *)error onStep:(ORKStep *)step {
    [self finishWithReason:ORKTaskViewControllerFinishReasonFailed error:error];
}

- (void)flipToNextPageFrom:(ORKStepViewController *)fromController {
    if (fromController != _currentStepViewController) {
        return;
    }
    
    ORKStep *step = fromController.parentReviewStep;
    if (!step) {
        step = [self nextStep];
    }
    
    if (step == nil) {
        if ([self.delegate respondsToSelector:@selector(taskViewController:didChangeResult:)]) {
            [self.delegate taskViewController:self didChangeResult:[self result]];
        }
        [self finishWithReason:ORKTaskViewControllerFinishReasonCompleted error:nil];
    } else if ([self shouldPresentStep:step]) {
        ORKStepViewController *stepViewController = [self viewControllerForStep:step];
        NSAssert(stepViewController != nil, @"A non-nil step should always generate a step view controller");
        if (fromController.isBeingReviewed) {
            [_managedStepIdentifiers removeLastObject];
        }
        [self showViewController:stepViewController goForward:YES animated:YES];
    }
    
}

- (void)flipToPreviousPageFrom:(ORKStepViewController *)fromController {
    if (fromController != _currentStepViewController) {
        return;
    }
    
    ORKStep *step = fromController.parentReviewStep;
    if (!step) {
        step = [self prevStep];
    }
    ORKStepViewController *stepViewController = nil;
    
    if ([self shouldPresentStep:step]) {
        ORKStep *currentStep = _currentStepViewController.step;
        NSString *itemId = currentStep.identifier;
        
        stepViewController = [self viewControllerForStep:step];
        if (stepViewController) {
            // Remove the identifier from the list
            assert([itemId isEqualToString:_managedStepIdentifiers.lastObject]);
            [_managedStepIdentifiers removeLastObject];
            
            [self showViewController:stepViewController goForward:NO animated:YES];
        }
    }
}

#pragma mark -  ORKStepViewControllerDelegate

- (void)stepViewControllerWillAppear:(ORKStepViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(taskViewController:stepViewControllerWillAppear:)]) {
        [self.delegate taskViewController:self stepViewControllerWillAppear:viewController];
    }
}

- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    
    if (!stepViewController.readOnlyMode) {
        // Add step result object
        [self setManagedResult:[stepViewController result] forKey:stepViewController.step.identifier];
    }
    
    // Alert the delegate that the step is finished 
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:stepViewControllerWillDisappear:navigationDirection:)]) {
        [strongDelegate taskViewController:self stepViewControllerWillDisappear:stepViewController navigationDirection:direction];
    }
    
    if (direction == ORKStepViewControllerNavigationDirectionForward) {
        [self flipToNextPageFrom:stepViewController];
    } else {
        [self flipToPreviousPageFrom:stepViewController];
    }
}

- (void)stepViewControllerDidFail:(ORKStepViewController *)stepViewController withError:(NSError *)error {
    [self finishWithReason:ORKTaskViewControllerFinishReasonFailed error:error];
}

- (void)stepViewControllerResultDidChange:(ORKStepViewController *)stepViewController {
    if (!stepViewController.readOnlyMode) {
        [self setManagedResult:stepViewController.result forKey:stepViewController.step.identifier];
    }
    
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didChangeResult:)]) {
        [strongDelegate taskViewController:self didChangeResult:[self result]];
    }
}

- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *)stepViewController {
    ORKStep *thisStep = stepViewController.step;
    if (!thisStep) {
        return NO;
    }
    ORKStep *previousStep = stepViewController.parentReviewStep;
    if (!previousStep) {
        previousStep = [self stepBeforeStep:thisStep];
    }
    if ([previousStep isKindOfClass:[ORKActiveStep class]] || ([thisStep allowsBackNavigation] == NO)) {
        previousStep = nil; // Can't go back to an active step
    }
    return (previousStep != nil);
}

- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *)stepViewController {
    ORKStep *thisStep = stepViewController.step;
    if (!thisStep) {
        return NO;
    }
    ORKStep *nextStep = [self stepAfterStep:thisStep];
    return (nextStep != nil);
}

- (void)stepViewController:(ORKStepViewController *)stepViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:recorder:didFailWithError:)]) {
        [strongDelegate taskViewController:self recorder:recorder didFailWithError:error];
    }
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step {
    return [self.task stepBeforeStep:step withResult:[self result]];
}

- (ORKStep *)stepAfterStep:(ORKStep *)step {
    return [self.task stepAfterStep:step withResult:[self result]];
}

#pragma mark - ORKReviewStepViewControllerDelegate

- (void)reviewStepViewController:(ORKReviewStepViewController *)reviewStepViewController
                  willReviewStep:(ORKStep *)step {
    id<ORKTaskResultSource> resultSource = _defaultResultSource;
    if (reviewStepViewController.reviewStep && reviewStepViewController.reviewStep.isStandalone) {
        _defaultResultSource = reviewStepViewController.reviewStep.resultSource;
    }
    ORKStepViewController *stepViewController = [self viewControllerForStep:step];
    _defaultResultSource = resultSource;
    NSAssert(stepViewController != nil, @"A non-nil step should always generate a step view controller");
    stepViewController.continueButtonTitle = ORKLocalizedString(@"BUTTON_SAVE", nil);
    stepViewController.parentReviewStep = (ORKReviewStep *) reviewStepViewController.step;
    stepViewController.skipButtonTitle = stepViewController.readOnlyMode ? ORKLocalizedString(@"BUTTON_READ_ONLY_MODE", nil) : ORKLocalizedString(@"BUTTON_CLEAR_ANSWER", nil);
    if (stepViewController.parentReviewStep.isStandalone) {
        stepViewController.navigationItem.title = stepViewController.parentReviewStep.title;
    }
    [self showViewController:stepViewController goForward:YES animated:YES];
}

#pragma mark - UIStateRestoring

static NSString *const _ORKTaskRunUUIDRestoreKey = @"taskRunUUID";
static NSString *const _ORKShowsProgressInNavigationBarRestoreKey = @"showsProgressInNavigationBar";
static NSString *const _ORKManagedResultsRestoreKey = @"managedResults";
static NSString *const _ORKManagedStepIdentifiersRestoreKey = @"managedStepIdentifiers";
static NSString *const _ORKHasSetProgressLabelRestoreKey = @"hasSetProgressLabel";
static NSString *const _ORKHasRequestedHealthDataRestoreKey = @"hasRequestedHealthData";
static NSString *const _ORKRequestedHealthTypesForReadRestoreKey = @"requestedHealthTypesForRead";
static NSString *const _ORKRequestedHealthTypesForWriteRestoreKey = @"requestedHealthTypesForWrite";
static NSString *const _ORKOutputDirectoryRestoreKey = @"outputDirectory";
static NSString *const _ORKLastBeginningInstructionStepIdentifierKey = @"lastBeginningInstructionStepIdentifier";
static NSString *const _ORKTaskIdentifierRestoreKey = @"taskIdentifier";
static NSString *const _ORKStepIdentifierRestoreKey = @"stepIdentifier";
static NSString *const _ORKPresentedDate = @"presentedDate";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskRunUUID forKey:_ORKTaskRunUUIDRestoreKey];
    [coder encodeBool:self.showsProgressInNavigationBar forKey:_ORKShowsProgressInNavigationBarRestoreKey];
    [coder encodeObject:_managedResults forKey:_ORKManagedResultsRestoreKey];
    [coder encodeObject:_managedStepIdentifiers forKey:_ORKManagedStepIdentifiersRestoreKey];
    [coder encodeBool:_hasSetProgressLabel forKey:_ORKHasSetProgressLabelRestoreKey];
    [coder encodeObject:_presentedDate forKey:_ORKPresentedDate];
    
    [coder encodeObject:ORKBookmarkDataFromURL(_outputDirectory) forKey:_ORKOutputDirectoryRestoreKey];
    [coder encodeObject:_lastBeginningInstructionStepIdentifier forKey:_ORKLastBeginningInstructionStepIdentifierKey];
    
    [coder encodeObject:_task.identifier forKey:_ORKTaskIdentifierRestoreKey];
    
    ORKStep *step = [_currentStepViewController step];
    if ([step isRestorable] && !(_currentStepViewController.isBeingReviewed && _currentStepViewController.parentReviewStep.isStandalone)) {
        [coder encodeObject:step.identifier forKey:_ORKStepIdentifierRestoreKey];
    } else if (_lastRestorableStepIdentifier) {
        [coder encodeObject:_lastRestorableStepIdentifier forKey:_ORKStepIdentifierRestoreKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _taskRunUUID = [coder decodeObjectOfClass:[NSUUID class] forKey:_ORKTaskRunUUIDRestoreKey];
    self.showsProgressInNavigationBar = [coder decodeBoolForKey:_ORKShowsProgressInNavigationBarRestoreKey];
    
    _outputDirectory = ORKURLFromBookmarkData([coder decodeObjectOfClass:[NSData class] forKey:_ORKOutputDirectoryRestoreKey]);
    [self ensureDirectoryExists:_outputDirectory];
    
    // Must have a task object already provided by this point in the restoration, in order to restore any other state.
    if (_task) {
        
        // Recover partially entered results, even if we may not be able to jump to the desired step.
        _managedResults = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKManagedResultsRestoreKey];
        _managedStepIdentifiers = [coder decodeObjectOfClass:[NSMutableArray class] forKey:_ORKManagedStepIdentifiersRestoreKey];
        
        _restoredTaskIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKTaskIdentifierRestoreKey];
        if (_restoredTaskIdentifier) {
            if (![_task.identifier isEqualToString:_restoredTaskIdentifier]) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Restored task identifier %@ does not match task %@ provided",_restoredTaskIdentifier,_task.identifier]
                                             userInfo:nil];
            }
        }
        
        if ([_task respondsToSelector:@selector(stepWithIdentifier:)]) {
            _hasSetProgressLabel = [coder decodeBoolForKey:_ORKHasSetProgressLabelRestoreKey];
            _presentedDate = [coder decodeObjectOfClass:[NSDate class] forKey:_ORKPresentedDate];
            _lastBeginningInstructionStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKLastBeginningInstructionStepIdentifierKey];
            
            _restoredStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKStepIdentifierRestoreKey];
        } else {
            ORK_Log_Warning(@"Not restoring current step of task %@ because it does not implement -stepWithIdentifier:", _task.identifier);
        }
    }
}


- (void)applicationFinishedRestoringState {
    [super applicationFinishedRestoringState];
    
    _pageViewController = (UIPageViewController *)[self.childNavigationController viewControllers][0];
    
    if (!_task) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Task must be provided to restore task view controller"
                                     userInfo:nil];
    }
    
    if (_restoredStepIdentifier) {
        ORKStepViewController *stepViewController = _currentStepViewController;
        if (stepViewController) {
            stepViewController.delegate = self;
            
            if (stepViewController.cancelButtonItem == nil) {
                stepViewController.cancelButtonItem = [self defaultCancelButtonItem];
            }
            
            if ([self.delegate respondsToSelector:@selector(taskViewController:hasLearnMoreForStep:)] &&
                [self.delegate taskViewController:self hasLearnMoreForStep:stepViewController.step]) {
                
                stepViewController.learnMoreButtonItem = [self defaultLearnMoreButtonItem];
            }
            
            _stepViewControllerObserver = [[BRKViewControllerToolbarObserver alloc] initWithTargetViewController:stepViewController delegate:self];
            
        } else if ([_task respondsToSelector:@selector(stepWithIdentifier:)]) {
            stepViewController = [self viewControllerForStep:[_task stepWithIdentifier:_restoredStepIdentifier]];
        } else {
            stepViewController = [self viewControllerForStep:[_task stepAfterStep:nil withResult:[self result]]];
        }
        
        if (stepViewController != nil) {
            [self showViewController:stepViewController goForward:YES animated:NO];
            _hasBeenPresented = YES;
        }
    }
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    if ([identifierComponents.lastObject isEqualToString:_PageViewControllerRestorationKey]) {
        UIPageViewController *pageViewController = [self pageViewController];
        pageViewController.restorationIdentifier = identifierComponents.lastObject;
        pageViewController.restorationClass = self;
        return pageViewController;
    } else if ([identifierComponents.lastObject isEqualToString:_ChildNavigationControllerRestorationKey]) {
        UINavigationController *navigationController = [UINavigationController new];
        navigationController.restorationIdentifier = identifierComponents.lastObject;
        navigationController.restorationClass = self;
        return navigationController;
    }
    
    ORKTaskViewController *taskViewController = [[ORKTaskViewController alloc] initWithTask:nil taskRunUUID:nil];
    taskViewController.restorationIdentifier = identifierComponents.lastObject;
    taskViewController.restorationClass = self;
    return taskViewController;
}

#pragma mark UINavigationController pass-throughs

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    self.childNavigationController.navigationBarHidden = navigationBarHidden;
}

- (BOOL)isNavigationBarHidden {
    return self.childNavigationController.navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.childNavigationController setNavigationBarHidden:hidden animated:YES];
}

- (UINavigationBar *)navigationBar {
    return self.childNavigationController.navigationBar;
}

@end
