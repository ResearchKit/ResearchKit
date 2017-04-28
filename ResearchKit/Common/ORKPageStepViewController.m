/*
 Copyright (c) 2016, Sage Bionetworks
 
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


#import "ORKPageStepViewController.h"
#import <ResearchKit/ResearchKit_Private.h>
#import "ORKStepViewController_Internal.h"
#import "UIBarButtonItem+ORKBarButtonItem.h"
#import "ORKHelpers_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStep_Private.h"

typedef NS_ENUM(NSInteger, ORKPageNavigationDirection) {
    ORKPageNavigationDirectionNone = 0,
    ORKPageNavigationDirectionForward = 1,
    ORKPageNavigationDirectionReverse = -1
} ORK_ENUM_AVAILABLE;

@interface  ORKPageStepViewController () <UIPageViewControllerDelegate, ORKStepViewControllerDelegate>

@property (nonatomic, readonly) ORKPageResult *initialResult;
@property (nonatomic, readonly) ORKPageResult *pageResult;
@property (nonatomic, readonly) UIPageViewController *pageViewController;
@property (nonatomic, copy, readonly, nullable) NSString *currentStepIdentifier;
@property (nonatomic, readonly) ORKStepViewController *currentStepViewController;

@end

@implementation ORKPageStepViewController

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [super initWithStep:step result:result];
    if (self && [step isKindOfClass:[ORKPageStep class]] && [result isKindOfClass:[ORKStepResult class]]) {
        _pageResult = [[ORKPageResult alloc] initWithPageStep:(ORKPageStep *)step stepResult:(ORKStepResult *)result];
        _initialResult = [_pageResult copy];
    }
    return self;
}

- (ORKPageStep *)pageStep {
    if ([self.step isKindOfClass:[ORKPageStep class]]) {
        return (ORKPageStep *)self.step;
    }
    return nil;
}

- (ORKStepViewController *)currentStepViewController {
    UIViewController *viewController = [self.pageViewController.viewControllers firstObject];
    if ([viewController isKindOfClass:[ORKStepViewController class]]) {
        return (ORKStepViewController *)viewController;
    }
    return nil;
}

@synthesize pageResult = _pageResult;
- (ORKPageResult *)pageResult {
    if (_pageResult == nil) {
        _pageResult = [[ORKPageResult alloc] initWithIdentifier:self.step.identifier];
    }
    if (!ORKEqualObjects(_pageResult.outputDirectory, self.outputDirectory)) {
        _pageResult = [_pageResult copyWithOutputDirectory:self.outputDirectory];
    }
    return _pageResult;
}

- (void)stepDidChange {
    if (![self isViewLoaded]) {
        return;
    }
    
    _currentStepIdentifier = nil;
    _pageResult = nil;
    [self navigateInDirection:ORKPageNavigationDirectionNone animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prepare pageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.delegate = self;
    
    if ([_pageViewController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        _pageViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pageViewController.view.frame = self.view.bounds;
    [self.view addSubview:_pageViewController.view];
    [self addChildViewController:_pageViewController];
    [_pageViewController didMoveToParentViewController:self];
    
    [self navigateInDirection:ORKPageNavigationDirectionNone animated:NO];
}

- (void)updateNavLeftBarButtonItem {
    if ((self.currentStepIdentifier == nil) || ([self stepInDirection:ORKPageNavigationDirectionReverse] == nil)) {
        [super updateNavLeftBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self goToPreviousPageButtonItem];
    }
}

- (UIBarButtonItem *)goToPreviousPageButtonItem {
    // Hide the back navigation item if not allowed
    if (!self.currentStepViewController.step.allowsBackNavigation) {
        return nil;
    }
    UIBarButtonItem *button = [UIBarButtonItem ork_backBarButtonItemWithTarget:self action:@selector(goToPreviousPage)];
    button.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    return button;
}

- (void)goToPreviousPage {
    [self navigateInDirection:ORKPageNavigationDirectionReverse animated:YES];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)willNavigateDirection:(ORKStepViewControllerNavigationDirection)direction {
    // update the current step based on the direction of navigation
    if (direction == ORKStepViewControllerNavigationDirectionForward) {
        _currentStepIdentifier = nil;
    }
    else {
        NSString *lastStepIdentifier = [[self.pageResult.results lastObject] identifier];
        if ([self.pageStep stepWithIdentifier:lastStepIdentifier] != nil) {
            _currentStepIdentifier = lastStepIdentifier;
        }
    }
    [super willNavigateDirection:direction];
}

#pragma mark - result handling

- (id <ORKTaskResultSource>)resultSource {
    return self.pageResult;
}

- (ORKStepResult *)result {
    ORKStepResult *result = [super result];
    NSArray *pageResults = [self.pageResult flattenResults];
    result.results = [result.results arrayByAddingObjectsFromArray:pageResults] ? : pageResults;
    return result;
}


#pragma mark ORKStepViewControllerDelegate

- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    NSInteger delta = (direction == ORKStepViewControllerNavigationDirectionForward) ? 1 : -1;
    if (direction == ORKStepViewControllerNavigationDirectionForward) {
        // If going forward, update the page result with the final stepResult
        ORKStepResult *stepResult = stepViewController.result;
        [self.pageResult addStepResult:stepResult];
    }
    [self navigateInDirection:delta animated:YES];
}

- (void)stepViewControllerResultDidChange:(ORKStepViewController *)stepViewController {
    [self.pageResult addStepResult:stepViewController.result];
    [self notifyDelegateOnResultChange];
}

- (void)stepViewControllerDidFail:(ORKStepViewController *)stepViewController withError:(NSError *)error {
    ORKStrongTypeOf(self.delegate) delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(stepViewControllerDidFail:withError:)]) {
        [delegate stepViewControllerDidFail:self withError:error];
    }
}

- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *)stepViewController {
    return [self hasNextStep] || ([self stepInDirection:ORKPageNavigationDirectionForward] != nil);
}

- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *)stepViewController {
    return [self hasPreviousStep] || ([self stepInDirection:ORKPageNavigationDirectionReverse] != nil);
}

- (void)stepViewController:(ORKStepViewController *)stepViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    ORKStrongTypeOf(self.delegate) delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(stepViewController:recorder:didFailWithError:)]) {
        [delegate stepViewController:self recorder:recorder didFailWithError:error];
    }
}

#pragma mark Navigation

- (ORKStep *)stepInDirection:(ORKPageNavigationDirection)delta {
    if ((delta == ORKPageNavigationDirectionNone) && (self.currentStepIdentifier != nil)) {
        return [self.pageStep stepWithIdentifier:self.currentStepIdentifier];
    } else if ((delta >= 0) || (self.currentStepIdentifier == nil)) {
        return [self.pageStep stepAfterStepWithIdentifier:self.currentStepIdentifier withResult:self.pageResult];
    } else {
        [self.pageResult removeStepResultWithIdentifier:self.currentStepIdentifier];
        return [self.pageStep stepBeforeStepWithIdentifier:self.currentStepIdentifier withResult:self.pageResult];
    }
}

- (void)navigateInDirection:(ORKPageNavigationDirection)delta animated:(BOOL)animated {
    ORKStep *step = [self stepInDirection:delta];
    if (step == nil) {
        if (delta < 0) {
            [self goBackward];
        }
        else {
            [self goForward];
        }
    } else {
        UIPageViewControllerNavigationDirection direction = (!animated || delta >= 0) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        [self goToStep:step direction:direction animated:animated];
    }
}

- (ORKStepViewController *)stepViewControllerForStep:(ORKStep *)step {
    ORKStepResult *stepResult = [self.pageResult stepResultForStepIdentifier:step.identifier];
    if (stepResult == nil) {
        // If the pageResult does not carry a step result, then check the initial result
        stepResult = [self.initialResult stepResultForStepIdentifier:step.identifier];
    }
    ORKStepViewController *viewController = [step instantiateStepViewControllerWithResult:stepResult];
    return viewController;
}

- (void)goToStep:(ORKStep *)step direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated {
    ORKStepViewController *stepViewController = [self stepViewControllerForStep:step];
    
    if (!stepViewController) {
        ORK_Log_Debug(@"No view controller!");
        [self goForward];
        return;
    }
    
    // Flush the page result
    [self.pageResult removeStepResultsAfterStepWithIdentifier: step.identifier];
    
    // Setup view controller
    stepViewController.delegate = self;
    stepViewController.outputDirectory = self.outputDirectory;
    
    // Setup page direction
    ORKAdjustPageViewControllerNavigationDirectionForRTL(&direction);
    
    _currentStepIdentifier = step.identifier;
    __weak typeof(self) weakSelf = self;
    
    // unregister ScrollView to clear hairline
    [self.taskViewController setRegisteredScrollView:nil];
    
    [self.pageViewController setViewControllers:@[stepViewController] direction:direction animated:animated completion:^(BOOL finished) {
        if (finished) {
            ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
            [strongSelf updateNavLeftBarButtonItem];
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, strongSelf.navigationItem.leftBarButtonItem);
        }
    }];
}

#pragma mark - UIStateRestoring

static NSString *const _ORKCurrentStepIdentifierRestoreKey = @"currentStepIdentifier";
static NSString *const _ORKPageResultRestoreKey = @"pageResult";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:_currentStepIdentifier forKey:_ORKCurrentStepIdentifierRestoreKey];
    [coder encodeObject:_pageResult forKey:_ORKPageResultRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _currentStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKCurrentStepIdentifierRestoreKey];
    _pageResult = [coder decodeObjectOfClass:[ORKPageResult class] forKey:_ORKPageResultRestoreKey];
}

@end
