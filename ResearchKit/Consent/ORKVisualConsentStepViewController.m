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


#import "ORKVisualConsentStepViewController.h"
#import "ORKVisualConsentStep.h"
#import "ORKResult.h"
#import "ORKSignatureView.h"
#import "ORKHelpers.h"
#import "ORKObserver.h"
#import <MessageUI/MessageUI.h>
#import "ORKSkin.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKConsentSceneViewController.h"
#import "ORKConsentSceneViewController_Internal.h"
#import "ORKConsentDocument.h"
#import <QuartzCore/QuartzCore.h>
#import "ORKConsentSection+AssetLoading.h"
#import "ORKVisualConsentTransitionAnimator.h"
#import "ORKEAGLMoviePlayerView.h"
#import "UIBarButtonItem+ORKBarButtonItem.h"
#import "ORKContinueButton.h"
#import "ORKAccessibility.h"


@interface ORKVisualConsentStepViewController () <UIPageViewControllerDelegate, ORKScrollViewObserverDelegate> {
    BOOL _hasAppeared;
    ORKStepViewControllerNavigationDirection _navDirection;
    
    BOOL _transitioning;
    ORKVisualConsentTransitionAnimator *_animator;
    
    NSArray *_visualSections;
    
    ORKScrollViewObserver *_scrollViewObserver;
}

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableDictionary *viewControllers;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) ORKContinueButton *continueActionButton;

- (ORKConsentSceneViewController *)viewControllerForIndex:(NSUInteger)index;
- (NSUInteger)currentIndex ;
- (NSUInteger)indexOfViewController:(UIViewController *)viewController ;

@end


@interface ORKAnimationPlaceholderView : UIView

@property (nonatomic, strong) ORKEAGLMoviePlayerView *playerView;

- (void)scrollToTopAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end


@implementation ORKAnimationPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playerView = [ORKEAGLMoviePlayerView new];
        _playerView.hidden = YES;
        [self addSubview:_playerView];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    CGRect frame = self.frame;
    frame.size.height = ORKGetMetricForScreenType(ORKScreenMetricIllustrationHeight, ORKGetScreenTypeForWindow(newWindow));
    self.frame = frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _playerView.frame = self.bounds;
}

- (void)scrollToTopAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    CGRect targetFrame = self.frame;
    targetFrame.origin = CGPointZero;
    if (animated) {
        [UIView animateWithDuration:ORKScrollToTopAnimationDuration
                         animations:^{
            self.frame = targetFrame;
        }  completion:completion];
    } else {
        self.frame = targetFrame;
        if (completion) {
            completion(YES);
        }
    }
}

@end


@implementation ORKVisualConsentStepViewController

- (void)stepDidChange {
    [super stepDidChange];
    {
        NSMutableArray *visualSections = [NSMutableArray new];
        
        NSArray *sections = self.visualConsentStep.consentDocument.sections;
        for (ORKConsentSection *scene in sections) {
            if (scene.type != ORKConsentSectionTypeOnlyInDocument) {
                [visualSections addObject:scene];
            }
        }
        _visualSections = [visualSections copy];
    }
    
    if (self.step && [self pageCount] == 0) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Visual consent step has no visible scenes" userInfo:nil];
    }
    
    _viewControllers = nil;
    
    [self showViewController:[self viewControllerForIndex:0] forward:YES animated:NO];
}

- (ORKEAGLMoviePlayerView *)animationPlayerView {
    return [(ORKAnimationPlaceholderView *)_animationView playerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect viewBounds = self.view.bounds;
    
    self.view.backgroundColor = ORKColor(ORKBackgroundColorKey);
   
    // Prepare pageViewController
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    //_pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    
    [[self scrollView] setBounces:NO];
    
    if ([_pageViewController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        _pageViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pageViewController.view.frame = viewBounds;
    [self.view addSubview:_pageViewController.view];
    [self addChildViewController:_pageViewController];
    [_pageViewController didMoveToParentViewController:self];
    
    self.animationView = [[ORKAnimationPlaceholderView alloc] initWithFrame:
                          (CGRect){{0,0},{viewBounds.size.width,ORKGetMetricForScreenType(ORKScreenMetricIllustrationHeight, ORKScreenTypeiPhone4)}}];
    _animationView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _animationView.backgroundColor = [UIColor clearColor];
    _animationView.userInteractionEnabled = NO;
    [self.view addSubview:_animationView];
    
    [self updatePageIndex];
}

- (ORKVisualConsentStep *)visualConsentStep {
    assert(!self.step || [self.step isKindOfClass:[ORKVisualConsentStep class]]);
    return (ORKVisualConsentStep *)self.step;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_pageViewController.viewControllers.count == 0) {

        _hasAppeared = YES;
        
        // Add first viewController
        NSUInteger idx = 0;
        if (_navDirection == ORKStepViewControllerNavigationDirectionReverse) {
            idx = [self pageCount]-1;
        }
        
        [self showViewController:[self viewControllerForIndex:idx] forward:YES animated:NO];
    }
    [self updateBackButton];
    [self updatePageIndex];
}

- (void)willNavigateDirection:(ORKStepViewControllerNavigationDirection)direction {
    _navDirection = direction;
}

- (UIBarButtonItem *)goToPreviousPageButton {
    UIBarButtonItem *button = [UIBarButtonItem obk_backBarButtonItemWithTarget:self action:@selector(goToPreviousPage)];
    button.accessibilityLabel = ORKLocalizedString(@"AX_BUTTON_BACK", nil);
    return button;
}

- (void)ork_setBackButtonItem:(UIBarButtonItem *)backButton {
    [super ork_setBackButtonItem:backButton];
}

- (void)updateNavLeftBarButtonItem {
    if ([self currentIndex] == 0) {
        [super updateNavLeftBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self goToPreviousPageButton];
    }
}

- (void)updateBackButton {
    if (! _hasAppeared) {
        return;
    }
    
    [self updateNavLeftBarButtonItem];
}

#pragma mark - actions

- (IBAction)goToPreviousPage {
    [self showViewController:[self viewControllerForIndex:[self currentIndex]-1] forward:NO animated:YES];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (IBAction)next {
    ORKConsentSceneViewController *currentConsentSceneViewController = [self viewControllerForIndex:[self currentIndex]];
    [(ORKAnimationPlaceholderView *)_animationView scrollToTopAnimated:YES completion:nil];
    [currentConsentSceneViewController scrollToTopAnimated:YES completion:^(BOOL finished) {
        if (finished) {
            [self showNextViewController];
        }
    }];
}

- (void)showNextViewController {
    CGRect animationViewFrame = _animationView.frame;
    animationViewFrame.origin = CGPointZero;
    _animationView.frame = animationViewFrame;
    ORKConsentSceneViewController *nextConsentSceneViewController = [self viewControllerForIndex:[self currentIndex]+1];
    [(ORKAnimationPlaceholderView *)_animationView scrollToTopAnimated:NO completion:nil];
    [nextConsentSceneViewController scrollToTopAnimated:NO completion:^(BOOL finished) {
        // 'finished' is always YES when not animated
        [self showViewController:nextConsentSceneViewController forward:YES animated:YES];
        ORKAccessibilityPostNotificationAfterDelay(UIAccessibilityScreenChangedNotification, nil, 0.5);
    }];
}

#pragma mark - internal

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        for (UIView *view in self.pageViewController.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                _scrollView = (UIScrollView *)view;
            }
        }
    }
    return _scrollView;
}

- (void)updatePageIndex {
    NSUInteger currentIndex = [self currentIndex];
    if (currentIndex == NSNotFound) {
        return;
    }
    
    _currentPage = currentIndex;
    
    [self updateBackButton];

    ORKConsentSection *currentSection = (ORKConsentSection *)_visualSections[currentIndex];
    if (currentSection.type == ORKConsentSectionTypeOverview) {
        _animationView.isAccessibilityElement = NO;
    } else {
        _animationView.isAccessibilityElement = YES;
        _animationView.accessibilityLabel = [NSString stringWithFormat:ORKLocalizedString(@"AX_IMAGE_ILLUSTRATION", nil), currentSection.title];
        _animationView.accessibilityTraits |= UIAccessibilityTraitImage;
    }
}

- (void)setScrollEnabled:(BOOL)enabled {
    [[self scrollView] setScrollEnabled:enabled];
}

- (NSArray *)visualSections {
    return _visualSections;
}

- (NSUInteger)pageCount {
    return _visualSections.count;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)doShowViewController:(ORKConsentSceneViewController *)viewController direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated semaphore:(dispatch_semaphore_t)sem {
    
    UIView *pvcView = self.pageViewController.view;
    pvcView.userInteractionEnabled = NO;
    [self.pageViewController setViewControllers:@[viewController] direction:direction animated:animated completion:^(BOOL finished) {
        pvcView.userInteractionEnabled = YES;
        if (animated) {
            dispatch_semaphore_signal(sem);
        }
    }];
}

- (ORKVisualConsentTransitionAnimator *)doAnimateFromViewController:(ORKConsentSceneViewController *)fromController toController:(ORKConsentSceneViewController *)viewController direction:(UIPageViewControllerNavigationDirection)direction semaphore:(dispatch_semaphore_t)sem url:(NSURL *)url animateBeforeTransition:(BOOL)animateBeforeTransition transitionBeforeAnimate:(BOOL)transitionBeforeAnimate {
    
    __weak typeof(self) weakSelf = self;
    _animator = [[ORKVisualConsentTransitionAnimator alloc] initWithVisualConsentStepViewController:self movieURL:url];
    
    [_animator animateTransitionWithDirection:direction
                                          withLoadHandler:^(ORKVisualConsentTransitionAnimator *animator, UIPageViewControllerNavigationDirection direction) {
                                              fromController.imageHidden = YES;
                                              viewController.imageHidden = YES;
                                              
                                              if (!animateBeforeTransition && !transitionBeforeAnimate) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      __strong typeof(self) strongSelf = weakSelf;
                                                      [strongSelf doShowViewController:viewController direction:direction animated:YES semaphore:sem];                                         });
                                              }
                                          }
                                        completionHandler:^(ORKVisualConsentTransitionAnimator *animator, UIPageViewControllerNavigationDirection direction) {
                                            
                                            if (animateBeforeTransition && !transitionBeforeAnimate) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    __strong typeof(self) strongSelf = weakSelf;
                                                    [strongSelf doShowViewController:viewController direction:direction animated:YES semaphore:sem];                                         });
                                            } else {
                                                viewController.imageHidden = NO;
                                                fromController.imageHidden = NO;
                                            }
                                            
                                            __strong typeof(self) strongSelf = weakSelf;
                                            [strongSelf finishTransitioningAnimator:animator];

                                            dispatch_semaphore_signal(sem);
                                        }];
    return _animator;
}

- (void)finishTransitioningAnimator:(ORKVisualConsentTransitionAnimator *)animator {
    if (animator == nil) {
        animator = _animator;
    }
    
    [animator finish];
    if (_transitioning && animator == _animator) {
        _transitioning = NO;
        [[self animationPlayerView] setHidden:YES];
    }
    if (animator == _animator) {
        _animator = nil;
    }
}

- (void)observedScrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _scrollViewObserver.target) {
        CGRect animationViewFrame = _animationView.frame;
        CGPoint scrollViewBoundsOrigin = scrollView.bounds.origin;
        animationViewFrame.origin = (CGPoint){-scrollViewBoundsOrigin.x, -scrollViewBoundsOrigin.y};
        _animationView.frame = animationViewFrame;
    }
}

- (void)showViewController:(ORKConsentSceneViewController *)viewController forward:(BOOL)forward animated:(BOOL)animated {
    if (! viewController) {
        return;
    }
    
    // Stop old observer and start new one
    _scrollViewObserver = [[ORKScrollViewObserver alloc] initWithTargetView:viewController.scrollView delegate:self];
    [self.taskViewController setRegisteredScrollView:viewController.scrollView];

    ORKConsentSceneViewController *fromController = nil;
    NSUInteger currentIndex = [self currentIndex];
    if (currentIndex == NSNotFound) {
        animated = NO;
    } else {
        fromController = _viewControllers[@(currentIndex)];
    }
    
    if (_transitioning) {
        [self finishTransitioningAnimator:nil];
        
        fromController.imageHidden = NO;
    }
    
    NSUInteger toIndex = [self indexOfViewController:viewController];
    
    NSURL *url = nil;
    BOOL animateBeforeTransition = NO;
    BOOL transitionBeforeAnimate = NO;
    if (animated) {
        
        ORKConsentSectionType currentSection = [(ORKConsentSection *)_visualSections[currentIndex] type];
        ORKConsentSectionType destSection = (toIndex != NSNotFound) ? [(ORKConsentSection *)_visualSections[toIndex] type] : ORKConsentSectionTypeCustom;
        
        // Only animate when going forward
        if (toIndex > currentIndex) {
            
            // Use the custom animation URL, if there is one for the destination index.
            if (toIndex != NSNotFound && toIndex < [_visualSections count]) {
                url = [ORKDynamicCast(_visualSections[toIndex], ORKConsentSection) customAnimationURL];
            }
            BOOL isCustomURL = (url != nil);
            
            // If there's no custom URL, use an animation only if transitioning in the expected order.
            // Exception for datagathering, which does an arrival animation AFTER.
            if (!isCustomURL) {
                if (destSection == ORKConsentSectionTypeDataGathering) {
                    transitionBeforeAnimate = YES;
                    url = ORKMovieURLForConsentSectionType(ORKConsentSectionTypeOverview);
                } else if ( (destSection - currentSection) == 1) {
                    url = ORKMovieURLForConsentSectionType(currentSection);
                }
            }
        }
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    UIPageViewControllerNavigationDirection direction = forward?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
    
    if (! url) {
        [self doShowViewController:viewController direction:direction animated:animated semaphore:semaphore];
    }
    
    if (animated) {
        // Disable user interaction during the animated transition, and re-enable when finished
        _transitioning = YES;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Defensive timeouts
            typeof(self) strongSelf = weakSelf;
            
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5));
            
            __block ORKVisualConsentTransitionAnimator *animator = nil;
            
            if (url && transitionBeforeAnimate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    animator = [strongSelf doAnimateFromViewController:fromController
                                                           toController:viewController
                                                              direction:direction
                                                              semaphore:semaphore
                                                                    url:url
                                                animateBeforeTransition:animateBeforeTransition
                                                transitionBeforeAnimate:transitionBeforeAnimate];
                });
            }
            
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5));
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                
                viewController.imageHidden = NO;
                fromController.imageHidden = NO;
                
                if (animator) {
                    [strongSelf finishTransitioningAnimator:animator];
                }
                
                [strongSelf updatePageIndex];
            });
        });
        
        if (url) {
            if (transitionBeforeAnimate) {
                viewController.imageHidden = YES;
                [self doShowViewController:viewController direction:direction animated:YES semaphore:semaphore];
            } else {
                [self doAnimateFromViewController:fromController
                                      toController:viewController
                                         direction:direction
                                         semaphore:semaphore
                                               url:url
                           animateBeforeTransition:animateBeforeTransition
                           transitionBeforeAnimate:transitionBeforeAnimate];
            }
        } else {
            // No animation - complete now.
            viewController.imageHidden = NO;
            dispatch_semaphore_signal(semaphore);
        }
    }
}

- (ORKConsentSceneViewController *)viewControllerForIndex:(NSUInteger)index {
    if (_viewControllers == nil) {
        _viewControllers = [NSMutableDictionary new];
    }
    
    ORKConsentSceneViewController *consentViewController = nil;
    
    if (_viewControllers[@(index)]) {
        consentViewController = _viewControllers[@(index)];
    } else if (index>=[self pageCount]) {
        consentViewController = nil;
    } else {
        ORKConsentSceneViewController *sceneViewController = [[ORKConsentSceneViewController alloc] initWithSection:[self visualSections][index]];
        consentViewController = sceneViewController;
        
        if (index == [self pageCount]-1) {
            sceneViewController.continueButtonItem = self.continueButtonItem;
        } else {
            NSString *buttonTitle = ORKLocalizedString(@"BUTTON_NEXT", nil);
            if (sceneViewController.section.type == ORKConsentSectionTypeOverview) {
                buttonTitle = ORKLocalizedString(@"BUTTON_GET_STARTED", nil);
            }
            
            sceneViewController.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(next)];
        }
    }
    
    if (consentViewController) {
        _viewControllers[@(index)] = consentViewController;
    }
    
    return consentViewController;
}

- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    if (!viewController) {
        return NSNotFound;
    }
    
    NSUInteger index = NSNotFound;
    for (NSNumber *key in _viewControllers) {
        if (_viewControllers[key] == viewController) {
            index = [key unsignedIntegerValue];
        }
    }
    return index;
}

- (NSUInteger)currentIndex {
    return [self indexOfViewController:[_pageViewController.viewControllers firstObject]];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    return [self viewControllerForIndex:index-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    return [self viewControllerForIndex:index+1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (finished && completed) {
        [self updatePageIndex];
    }
}

static NSString * const _ORKCurrentPageRestoreKey = @"currentPage";
static NSString * const _ORKHasAppearedRestoreKey = @"hasAppeared";
static NSString * const _ORKInitialBackButtonRestoreKey = @"initialBackButton";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeInteger:_currentPage forKey:_ORKCurrentPageRestoreKey];
    [coder encodeBool:_hasAppeared forKey:_ORKHasAppearedRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.currentPage = [coder decodeIntegerForKey:_ORKCurrentPageRestoreKey];
    _hasAppeared = [coder decodeBoolForKey:_ORKHasAppearedRestoreKey];
    
    _viewControllers = nil;
    [self showViewController:[self viewControllerForIndex:_currentPage] forward:YES animated:NO];
}

@end
