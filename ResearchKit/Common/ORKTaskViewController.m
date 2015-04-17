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


#import "ORKTaskViewController.h"
#import <ResearchKit/ResearchKit_Private.h>

#import "ORKSkin.h"

#import "ORKStepViewController.h"
#import "ORKActiveStepViewController.h"
#import "ORKQuestionStepViewController.h"
#import "ORKVisualConsentStepViewController.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKFormStepViewController.h"

#import "ORKActiveStep.h"
#import "ORKQuestionStep.h"
#import "ORKVisualConsentStep.h"
#import "ORKInstructionStep.h"
#import "ORKFormStep.h"
#import "ORKStep_Private.h"
#import "ORKHelpers.h"
#import "ORKTaskViewController_Private.h"
#import "ORKTappingIntervalStep.h"
#import "ORKTappingIntervalStepViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^_ORKLocationAuthorizationRequestHandler)(BOOL success);

@interface ORKLocationAuthorizationRequester : NSObject <CLLocationManagerDelegate>

- (instancetype)initWithHandler:(_ORKLocationAuthorizationRequestHandler)handler;

- (void)resume;

@end

@implementation ORKLocationAuthorizationRequester {
    CLLocationManager *_manager;
    _ORKLocationAuthorizationRequestHandler _handler;
    BOOL _started;
    
}

- (instancetype)initWithHandler:(_ORKLocationAuthorizationRequestHandler)handler {
    self = [super init];
    if (self) {
        _handler = handler;
        _manager = [CLLocationManager new];
        _manager.delegate = self;
    }
    return self;
}

- (void)dealloc {
    _manager.delegate = nil;
}

- (void)resume {
    if (_started) {
        return;
    }
    
    _started = YES;
    NSString *whenInUseKey = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
    NSString *alwaysKey = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ((status == kCLAuthorizationStatusNotDetermined) && (whenInUseKey || alwaysKey)) {
        if (alwaysKey) {
            [_manager requestAlwaysAuthorization];
        } else {
            [_manager requestWhenInUseAuthorization];
        }
    } else {
        [self finishWithResult:(status != kCLAuthorizationStatusDenied)];
    }
}


- (void)finishWithResult:(BOOL)result {
    if (_handler) {
        _handler(result);
        _handler = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (_handler && _started && status != kCLAuthorizationStatusNotDetermined) {
        [self finishWithResult:(status != kCLAuthorizationStatusDenied)];
    }
}


@end

@interface ORKObserver : NSObject

@property (nonatomic, strong) NSArray *keyPaths;
@property (nonatomic, strong) id target;
@property (nonatomic) BOOL observing;
@property (nonatomic) void *context;

@property (nonatomic, weak) id responder;
@property (nonatomic) SEL action;

- (void)startObserving;

@end

@implementation ORKObserver

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSAssert(context == self.context, @"Unexpected KVO");
    ORKSuppressPerformSelectorWarning(
                                     (void)[self.responder performSelector:self.action withObject:self.target];);
}

- (void)startObserving {
    if (_observing == NO) {
        NSAssert(self.keyPaths, @"");
        NSAssert(self.target, @"");
        NSAssert(self.context, @"");
        NSAssert(self.responder, @"");
        NSAssert(self.action, @"");
        for (NSString *keyPath in self.keyPaths) {
            [self.target addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptions)0 context:self.context];
        }
        self.observing = YES;
    }
}

- (void)stopObserving {
    if (_observing) {
        for (NSString *keyPath in _keyPaths) {
            [self.target removeObserver:self forKeyPath:keyPath];
        }
        _observing = NO;
    }
}

- (void)dealloc {
    [self stopObserving];
}

@end

@interface ORKTaskViewControllerObserver : ORKObserver

- (instancetype)initWithTargetViewContoller:(NSObject *)target taskViewController:(ORKTaskViewController *)taskViewController;

@end

@implementation ORKTaskViewControllerObserver

static void *_ORKTaskViewControllerContext = &_ORKTaskViewControllerContext;

- (instancetype)initWithTargetViewContoller:(UIViewController *)target taskViewController:(ORKTaskViewController *)taskViewController {
    self = [super init];
    if (self) {
        self.keyPaths = @[@"navigationItem.leftBarButtonItem", @"navigationItem.rightBarButtonItem", @"toolbarItems"];
        self.target = target;
        self.responder = taskViewController;
        self.action = @selector(collectToolbarItemsFromViewController:);
        self.context = _ORKTaskViewControllerContext;
        [self startObserving];
    }
    return self;
}

@end

@interface ORKScrollViewObserver  : ORKObserver

- (instancetype)initWithTargetView:(UIScrollView *)scrollView taskViewController:(ORKTaskViewController *)taskViewController;

@end

@implementation ORKScrollViewObserver

static void *_ORKScrollViewObserverContext = &_ORKScrollViewObserverContext;

- (instancetype)initWithTargetView:(UIScrollView *)scrollView taskViewController:(ORKTaskViewController *)taskViewController
{
    self = [super init];
    if (self) {
        self.keyPaths = @[@"contentOffset"];
        self.target = scrollView;
        self.responder = taskViewController;
        self.action = @selector(registeredScrollViewDidScroll:);
        self.context = _ORKScrollViewObserverContext;
        [self startObserving];
    }
    return self;
}

@end

@interface ORKTaskViewController () {
    NSMutableDictionary *_managedResults;
    NSMutableArray *_managedStepIdentifiers;
    ORKTaskViewControllerObserver *_stepVCObserver;
    ORKScrollViewObserver *_scrollViewObserver;
    BOOL _haveSetProgressLabel;
    BOOL _hasBeenPresented;
    BOOL _hasRequestedHealthData;
    ORKPermissionMask _grantedPermissions;
    NSSet *_requestedHealthTypesForRead;
    NSSet *_requestedHealthTypesForWrite;
    NSURL *_outputDirectory;
    
    NSDate *_presentedDate;
    NSDate *_dismissedDate;
    
    NSString *_lastBeginningInstructionStepIdentifier;
    NSString *_lastRestorableStepIdentifier;
    
    BOOL _haveAudioSession; // does not need state restoration - temporary
    
    NSString *_restoredTaskIdentifier;
    NSString *_restoredStepIdentifier;
}

@property (nonatomic, strong) UIImageView *hairline;

@property (nonatomic, strong) UINavigationController *childNavigationController;
@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) ORKStepViewController *currentStepViewController;



@end

@implementation ORKTaskViewController
@synthesize taskRunUUID=_taskRunUUID;

+ (void)initialize {
    if (self == [ORKTaskViewController class]) {
        
        [[UINavigationBar appearanceWhenContainedIn:[ORKTaskViewController class], nil] setTranslucent:NO];
        if ([[UINavigationBar appearanceWhenContainedIn:[ORKTaskViewController class], nil] barTintColor] == nil) {
            [[UINavigationBar appearanceWhenContainedIn:[ORKTaskViewController class], nil] setBarTintColor:ORKColor(ORKToolBarTintColorKey)];
        }
        
        if ([[UIToolbar appearanceWhenContainedIn:[ORKTaskViewController class], nil] barTintColor] == nil) {
            [[UIToolbar appearanceWhenContainedIn:[ORKTaskViewController class], nil] setBarTintColor:ORKColor(ORKToolBarTintColorKey)];
        }
    }
}

static NSString * const _PageViewControllerRestorationKey = @"pageViewController";
static NSString * const _ChildNavigationControllerRestorationKey = @"childNavigationController";

+ (UIPageViewController *)pageVc
{
    
    UIPageViewController *pageVc = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                 options:nil];
    if ([pageVc respondsToSelector:@selector(edgesForExtendedLayout)]) {
        pageVc.edgesForExtendedLayout = UIRectEdgeNone;
    }
    pageVc.restorationIdentifier = _PageViewControllerRestorationKey;
    pageVc.restorationClass = self;
    
    
    // Disable swipe to scroll
    for (UIScrollView *view in pageVc.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            view.scrollEnabled = NO;
        }
    }
    return pageVc;
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
    UIPageViewController *pageVc = [[self class] pageVc];
    self.childNavigationController = [[UINavigationController alloc] initWithRootViewController:pageVc];
    
    
    _pageViewController = pageVc;
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

- (instancetype)initWithTask:(id<ORKTask>)task restorationData:(NSData *)data {
    
    self = [self initWithTask:task taskRunUUID:nil];
    
    if (self) {
        self.restorationClass = [self class];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [self decodeRestorableStateWithCoder:unarchiver];
        [self applicationFinishedRestoringState];
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
    
    if (task && ! [task conformsToProtocol:@protocol(ORKTask)]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Expected a task" userInfo:nil];
    }
    
    if (task && nil == [task identifier]) {
        NSLog(@"%@: Task's identifier should not be nil.", NSStringFromSelector(_cmd));
    }
    
    _hasRequestedHealthData = NO;
    _task = task;
}

- (UIBarButtonItem *)defaultCancelButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
}

- (UIBarButtonItem *)defaultLearnMoreButtonItem {
    return [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_LEARN_MORE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(learnMoreAction:)];
}

- (void)requestHealthStoreAccessWithReadTypes:(NSSet *)readTypes
                                   writeTypes:(NSSet *)writeTypes
                                      handler:(void (^)(void))handler {
    NSParameterAssert(handler != nil);
    if ((! [HKHealthStore isHealthDataAvailable]) || (! readTypes && ! writeTypes)) {
        _requestedHealthTypesForRead = nil;
        _requestedHealthTypesForWrite = nil;
        handler();
        return;
    }
    
    _requestedHealthTypesForRead = readTypes;
    _requestedHealthTypesForWrite = writeTypes;
    
    __block HKHealthStore *healthStore = [HKHealthStore new];
    [healthStore requestAuthorizationToShareTypes:writeTypes readTypes:readTypes completion:^(BOOL success, NSError *error) {
        ORK_Log_Debug(@"Health access: error=%@", error);
        dispatch_async(dispatch_get_main_queue(), handler);
        
        // Clear self-ref.
        healthStore = nil;
    }];
}

- (void)requestPedometerAccessWithHandler:(void (^)(BOOL success))handler {
    NSParameterAssert(handler != nil);
    if (! [CMPedometer isStepCountingAvailable]) {
        handler(NO);
        return;
    }
    
    __block CMPedometer *pedometer = [CMPedometer new];
    [pedometer queryPedometerDataFromDate:[NSDate dateWithTimeIntervalSinceNow:-100]
                                   toDate:[NSDate date]
                              withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                  ORK_Log_Debug(@"Pedometer access: error=%@", error);
                                  
                                  BOOL success = YES;
                                  if ([[error domain] isEqualToString:CMErrorDomain]) {
                                      switch (error.code) {
                                          case CMErrorMotionActivityNotAuthorized:
                                          case CMErrorNotAuthorized:
                                          case CMErrorNotAvailable:
                                          case CMErrorNotEntitled:
                                          case CMErrorMotionActivityNotAvailable:
                                          case CMErrorMotionActivityNotEntitled:
                                              success = NO;
                                              break;
                                          default:
                                              break;
                                      }
                                  }
                                  
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^(void) { handler(success); });
                                  
                                  // Clear self ref to release.
                                  pedometer = nil;
                              }];
}

- (void)requestAudioRecordingAccessWithHandler:(void (^)(BOOL success))handler {
    NSParameterAssert(handler != nil);
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(granted);
        });
    }];
}


- (void)requestLocationAccessWithHandler:(void (^)(BOOL success))handler {
    NSParameterAssert(handler != nil);
    
    // Self-retain; clear the retain cycle in the handler block.
    __block ORKLocationAuthorizationRequester *requester =
    [[ORKLocationAuthorizationRequester alloc]
     initWithHandler:^(BOOL success) {
         handler(success);
         
         requester = nil;
     }];
    
    [requester resume];
}

- (ORKPermissionMask)desiredPermissions {
    ORKPermissionMask permissions = ORKPermissionNone;
    if ([self.task respondsToSelector:@selector(requestedPermissions)]) {
        permissions = [self.task requestedPermissions];
    }
    return permissions;
}

- (void)requestHealthAuthorizationWithCompletion:(void (^)(void))completion {
  
    if (_hasRequestedHealthData) {
        if (completion) completion();
        return;
    }
    
    NSSet *readTypes = nil;
    if ([self.task respondsToSelector:@selector(requestedHealthKitTypesForReading)]) {
        readTypes = [self.task requestedHealthKitTypesForReading];
    }
    
    NSSet *writeTypes = nil;
    if ([self.task respondsToSelector:@selector(requestedHealthKitTypesForWriting)]) {
        writeTypes = [self.task requestedHealthKitTypesForWriting];
    }
    
    ORKPermissionMask permissions = [self desiredPermissions];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ORK_Log_Debug(@"Requesting health access");
            [self requestHealthStoreAccessWithReadTypes:readTypes
                                              writeTypes:writeTypes
                                                 handler:^{
                                                     dispatch_semaphore_signal(sem);
                                                 }];
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        if (permissions & ORKPermissionCoreMotionAccelerometer) {
            _grantedPermissions |= ORKPermissionCoreMotionAccelerometer;
        }
        if (permissions & ORKPermissionCoreMotionActivity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug(@"Requesting pedometer access");
                [self requestPedometerAccessWithHandler:^(BOOL success){
                    if (success) {
                        _grantedPermissions |= ORKPermissionCoreMotionActivity;
                    } else {
                        _grantedPermissions &= ~ORKPermissionCoreMotionActivity;
                    }
                    dispatch_semaphore_signal(sem);
                }];
            });
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        if (permissions & ORKPermissionAudioRecording) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug(@"Requesting audio access");
                [self requestAudioRecordingAccessWithHandler:^(BOOL success){
                    if (success) {
                        _grantedPermissions |= ORKPermissionAudioRecording;
                    } else {
                        _grantedPermissions &= ~ORKPermissionAudioRecording;
                    }
                    dispatch_semaphore_signal(sem);
                }];
            });
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        if (permissions & ORKPermissionCoreLocation) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug(@"Requesting location access");
                [self requestLocationAccessWithHandler:^(BOOL success){
                    if (success) {
                        _grantedPermissions |= ORKPermissionCoreLocation;
                    } else {
                        _grantedPermissions &= ~ORKPermissionCoreLocation;
                    }
                    dispatch_semaphore_signal(sem);
                }];
            });
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        
        _hasRequestedHealthData = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            _hasRequestedHealthData = YES;
            if (completion) completion();
        });
    });
}

- (void)startAudioPromptSessionIfNeeded {
    id<ORKTask> task = self.task;
    if ([task isKindOfClass:[ORKOrderedTask class]]) {
        if ([(ORKOrderedTask *)task providesBackgroundAudioPrompts]) {
            NSError *error = nil;
            if (! [self startAudioPromptSessionWithError:&error]) {
                // User-visible console log message
                ORK_Log_Oops(@"ResearchKit: failed to start audio prompt session: %@", error);
            }
        }
    }
}

- (BOOL)startAudioPromptSessionWithError:(NSError **)errorOut {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    BOOL success = YES;
    // Use PlayAndRecord to avoid overwriting the category being used by
    // recording configurations.
    if (! [session setCategory:AVAudioSessionCategoryPlayback
                   withOptions:0
                         error:&error]) {
        success = NO;
        ORK_Log_Debug(@"Could not start audio session: %@", error);
    }
    
    // We are setting the session active so that we can stay live to play audio
    // in the background.
    if (success && ! [session setActive:YES withOptions:0 error:&error]) {
        success = NO;
        ORK_Log_Debug(@"Could not set audio session active: %@", error);
    }
    
    if (errorOut) {
        *errorOut = error;
    }
    
    _haveAudioSession = _haveAudioSession || success;
    if (_haveAudioSession) {
        ORK_Log_Debug(@"*** Started audio session");
    }
    
    return success;
}

- (void)finishAudioPromptSession {
    if (_haveAudioSession) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        if (! [session setActive:NO withOptions:0 error:&error]) {
            ORK_Log_Debug(@"Could not deactivate audio session: %@", error);
        } else {
            ORK_Log_Debug(@"*** Finished audio session");
        }
    }
}

- (NSSet *)requestedHealthTypesForRead {
    return _requestedHealthTypesForRead;
}

- (NSSet *)requestedHealthTypesForWrite {
    return _requestedHealthTypesForWrite;
}

- (void)loadView {
    UIView *v = [[UIView alloc] initWithFrame:(CGRect){{0,0},{320,480}}];
    
    if (_childNavigationController) {
        UIView *childView = _childNavigationController.view;
        childView.frame = v.bounds;
        childView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [v addSubview:childView];
    }
    
    self.view = v;
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
            
            if (![step isKindOfClass:[ORKInstructionStep class]]) {
                [self startAudioPromptSessionIfNeeded];
                [self requestHealthAuthorizationWithCompletion:nil];
            }
            
            ORKStepViewController *firstVC = [self viewControllerForStep:step];
            [self showViewController:firstVC goForward:YES animated:animated];
            
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
    
    [_managedStepIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *identifier = obj;
        ORKResult *result = _managedResults[identifier];
        NSAssert(result, @"Not expect result to be nil for identifier %@", identifier);
        [results addObject:result];
    }];
    
    return [results copy];
}

- (void)setManagedResult:(id)result forKey:(id <NSCopying>)aKey {
    
    if (aKey == nil) {
        return;
    }
    
    if (result == nil || NO == [result isKindOfClass:[ORKResult class]]) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat: @"Expect result object to be ORKResult type and not nil: {%@ : %@}", aKey, result] userInfo:nil];
        return;
    }
    
    if (_managedResults == nil) {
        _managedResults = [NSMutableDictionary new];
    }

    _managedResults[aKey] = result;
}

- (NSUUID *)taskRunUUID {
    if (_taskRunUUID == nil) {
        _taskRunUUID = [NSUUID UUID];
    }
    return _taskRunUUID;
}

- (ORKTaskResult *)result {
    
    ORKTaskResult *result = [[ORKTaskResult alloc] initWithTaskIdentifier:(NSString *__nonnull)[self.task identifier] taskRunUUID:self.taskRunUUID outputDirectory:self.outputDirectory];
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

- (void)setOutputDirectory:(NSURL *)outputDirectory {
    
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot change outputDirectory after presenting task controller" userInfo:nil];
    }
    
    
    BOOL isDir;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:outputDirectory.path isDirectory:&isDir];
    
    if (! exist) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:outputDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"Could not create output directory and output directory does not exist" userInfo:@{@"error" : error}];
        }
        isDir = YES;
    } else if (! isDir) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Desired outputDirectory is not a directory or could not be created." userInfo:nil];
    }
    
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
            _scrollViewObserver = [[ORKScrollViewObserver alloc] initWithTargetView:_registeredScrollView taskViewController:self];
        }
    }
}

- (void)suspend {
    [self finishAudioPromptSession];
    [ORKDynamicCast(_currentStepViewController, ORKActiveStepViewController) suspend];
}

- (void)resume {
    [self startAudioPromptSessionIfNeeded];
    [ORKDynamicCast(_currentStepViewController, ORKActiveStepViewController) resume];
}

- (void)goForward {
    [_currentStepViewController goForward];
}

- (void)goBackward {
    [_currentStepViewController goBackward];
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
    
    
    ORKStep * nextStep = [self.task stepAfterStep:step withResult:[self result]];
    BOOL isNextStepInstructionStep = [nextStep isKindOfClass:[ORKInstructionStep class]];
    
    if (_lastBeginningInstructionStepIdentifier == nil &&
        nextStep && NO == isNextStepInstructionStep)
    {
        _lastBeginningInstructionStepIdentifier = step.identifier;
    }
}

- (BOOL)isStepLastBeginningInstructionStep:(ORKStep *)step {
    if (! step) {
        return NO;
    }
    return (_lastBeginningInstructionStepIdentifier != nil &&
            [step isKindOfClass:[ORKInstructionStep class]]&&
            [step.identifier isEqualToString:_lastBeginningInstructionStepIdentifier]);
}

- (BOOL)grantedAtLeastOnePermission {
    // Return YES, if no desired permission or granted at least one permission.
    ORKPermissionMask desiredMask = [self desiredPermissions];
    return (desiredMask == 0 || ((desiredMask & _grantedPermissions) != 0));
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
    if (fromController && animated && [self isStepLastBeginningInstructionStep:fromController.step]) {
        [self startAudioPromptSessionIfNeeded];
        
        if ( [self grantedAtLeastOnePermission] == NO) {
            // Do the health request and THEN proceed.
            [self requestHealthAuthorizationWithCompletion:^{
                
                // If we are able to collect any data, proceed.
                // An alternative rule would be to never proceed if any permission fails.
                // However, since iOS does not re-present requests for access, we
                // can easily fail even if the user does not see a dialog, which would
                // be highly unexpected.
                if ([self grantedAtLeastOnePermission] == NO) {
                    [self reportError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                           code:NSUserCancelledError userInfo:@{@"reason" : @"Required permissions not granted."}]
                                onStep:fromController.step];
                } else {
                    [self showViewController:viewController goForward:goForward animated:animated];
                }
            }];
            return;
        }
    }
    
    if (step.identifier && ![[_managedStepIdentifiers lastObject] isEqualToString:step.identifier])
    {
        [_managedStepIdentifiers addObject:step.identifier];
    }
    if ([step isRestorable]) {
        _lastRestorableStepIdentifier = step.identifier;
    }
    
    __weak typeof(self) weakSelf = self;
    
    UIPageViewControllerNavigationDirection direction = goForward?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
    
    ORKStepViewControllerNavigationDirection stepDirection = goForward?ORKStepViewControllerNavigationDirectionForward : ORKStepViewControllerNavigationDirectionReverse;
    
    NSString *progressLabel = nil;
    if (self.showsProgressInNavigationBar && [_task respondsToSelector:@selector(progressOfCurrentStep:withResult:)]) {
        ORKTaskProgress progress = [_task progressOfCurrentStep:(ORKStep *__nonnull)viewController.step withResult:[self result]];

        if (progress.total > 0)
        {
            progressLabel = [NSString stringWithFormat:ORKLocalizedString(@"STEP_PROGRESS_FORMAT", nil), (unsigned long)progress.current+1, (unsigned long)progress.total];
        }
    }
    
    [viewController willNavigateDirection:stepDirection];
    
    ORK_Log_Debug(@"%@ %@", self, viewController);
    

    // Stop monitor old scrollView, reset hairline's alpha to 0;
    self.registeredScrollView = nil;
    
    // Switch to non-animated transition if the application is not in the foreground.
    animated = animated && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive);
    
    // Update currentStepViewController now, so we don't accept additional transition requests
    // from the same VC.
    _currentStepViewController = viewController;
    
    [self.pageViewController setViewControllers:@[viewController] direction:direction animated:animated completion:^(BOOL finished) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        ORK_Log_Debug(@"%@ %@", strongSelf, viewController);
        
        // Set the progress label only if non-nil or if it is nil having previously set a progress label.
        if (progressLabel || strongSelf->_haveSetProgressLabel) {
            strongSelf.pageViewController.navigationItem.title = progressLabel;
        }
        
        strongSelf->_haveSetProgressLabel = (progressLabel != nil);
        
        // Collect toolbarItems
        [strongSelf collectToolbarItemsFromViewController:viewController];
    }];
    
}

- (BOOL)shouldPresentStep:(ORKStep *)step {
    BOOL shouldPresent = YES;
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:shouldPresentStep:)]) {
        shouldPresent = [self.delegate taskViewController:self shouldPresentStep:step];
    }
    
    return shouldPresent;
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

    _pageViewController.toolbarItems = viewController.toolbarItems;
    _pageViewController.navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem;
    _pageViewController.navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem;
}

- (void)registeredScrollViewDidScroll:(UIScrollView *)scrollView {
    
    // alpha's range [0.0, 1.0]
    float alpha = MAX( MIN(scrollView.contentOffset.y/64.0, 1.0), 0.0);
    self.hairline.alpha = alpha;
}

- (ORKStepViewController *)viewControllerForStep:(ORKStep *)step {
    
    if (step == nil) {
        return nil;
    }
    
    ORKStepViewController *stepVC = nil;
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:viewControllerForStep:)]) {
        stepVC = [self.delegate taskViewController:self viewControllerForStep:step];
    }
    
    if (! stepVC) {
        Class stepVCClass = [[step class] stepViewControllerClass];
        
        ORKStepResult *result = nil;
        result = _managedResults[step.identifier];
        if (! result ) {
            result = [_defaultResultSource stepResultForStepIdentifier:step.identifier];
        }
        
        if (! result) {
            result = [[ORKStepResult alloc] initWithIdentifier:step.identifier];
        }
        
        stepVC = [[stepVCClass alloc] initWithStep:step result:result];
        
        stepVC.restorationIdentifier = step.identifier;
        stepVC.restorationClass = stepVCClass;
        
    } else if (![stepVC isKindOfClass:[ORKStepViewController class]]) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"View controller should be of class %@", [ORKStepViewController class]] userInfo:@{@"viewController": stepVC}];
    }
    
    stepVC.outputDirectory = self.outputDirectory;
    [self setManagedResult:stepVC.result forKey:step.identifier];
    
    
    if (stepVC.cancelButtonItem == nil) {
        stepVC.cancelButtonItem = [self defaultCancelButtonItem];
    }
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:hasLearnMoreForStep:)] &&
        [self.delegate taskViewController:self hasLearnMoreForStep:step]) {
        
        stepVC.learnMoreButtonItem = [self defaultLearnMoreButtonItem];
    }

    stepVC.delegate = self;
    
    _stepVCObserver = [[ORKTaskViewControllerObserver alloc] initWithTargetViewContoller:stepVC taskViewController:self];
    return stepVC;
}

#pragma mark - internal action Handlers

- (void)finishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {

    STRONGTYPE(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
     
        [strongDelegate taskViewController:self didFinishWithReason:reason error:error];
    }
}

- (void)presentCancelOptions:(BOOL)saveable {
    BOOL supportSaving = NO;
    if ([self.delegate respondsToSelector:@selector(taskViewControllerSupportsSaveAndRestore:)]) {
        supportSaving = [self.delegate taskViewControllerSupportsSaveAndRestore:self];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (supportSaving && saveable) {
        [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OPTION_SAVE", nil)
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [self finishWithReason:ORKTaskViewControllerFinishReasonSaved error:nil];
                                                    });
                                                    
                                                }]];
    }
    
    NSString *discardTitle = saveable? ORKLocalizedString(@"BUTTON_OPTION_DISCARD", nil) : ORKLocalizedString(@"BUTTON_OPTION_STOP_TASK", nil);
    
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

- (IBAction)cancelAction:(id)sender {
    // Should we also include visualConsentStep here? Others?
    BOOL isCurrentInstructionStep = [self.currentStepViewController.step isKindOfClass:[ORKInstructionStep class]];
    
    // [self result] would not include any results beyond current step.
    // Use _managedResults to get the completed result set.
    NSArray *results = [_managedResults allValues];
    BOOL saveable = NO;
    for (ORKStepResult *result in results) {
        if ([result isSaveable]) {
            saveable = YES;
            break;
        }
    }
    
    if (isCurrentInstructionStep && saveable == NO) {
        [self finishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
    } else {
        [self presentCancelOptions:saveable];
    }
}

- (IBAction)learnMoreAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(taskViewController:learnMoreForStep:)]) {
        [self.delegate taskViewController:self learnMoreForStep:(ORKStepViewController *__nonnull)self.currentStepViewController];
    }
}

- (void)reportError:(NSError *)error onStep:(ORKStep *)step {
    
    [self finishWithReason:ORKTaskViewControllerFinishReasonFailed error:error];
}

- (IBAction)flipToNextPageFrom:(ORKStepViewController *)fromController {
    
    if (fromController != _currentStepViewController) {
        return;
    }
    
    ORKStep *step = [self nextStep];
    ORKStepViewController *stepVC = nil;
    
    if ([self shouldPresentStep:step]) {
        stepVC = [self viewControllerForStep:step];
        
        if (stepVC == nil) {
            
            if ([self.delegate respondsToSelector:@selector(taskViewController:didChangeResult:)]) {
                [self.delegate taskViewController:self didChangeResult:[self result]];
            }
            
            [self finishAudioPromptSession];
            
            [self finishWithReason:ORKTaskViewControllerFinishReasonCompleted error:nil];
            
        } else {
            [self showViewController:stepVC goForward:YES animated:YES];
        }
    }
}

- (IBAction)flipToPreviousPageFrom:(ORKStepViewController *)fromController {
    
    if (fromController != _currentStepViewController) {
        return;
    }
    
    ORKStep *step = [self prevStep];
    
    ORKStepViewController *stepVC = nil;
    
    if ([self shouldPresentStep:step]) {
        ORKStep *currentStep = _currentStepViewController.step;
        NSString *itemId = currentStep.identifier;
        
        stepVC = [self viewControllerForStep:step];
        
        if (stepVC) {
            // Remove the identifier from the list
            assert([itemId isEqualToString:[_managedStepIdentifiers lastObject]]);
            [_managedStepIdentifiers removeLastObject];

            [self showViewController:stepVC goForward:NO animated:YES];
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
    
    // Add step result object
    [self setManagedResult:[stepViewController result] forKey:stepViewController.step.identifier];
    
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
    
    [self setManagedResult:stepViewController.result forKey:stepViewController.step.identifier];
    
    STRONGTYPE(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didChangeResult:)]) {
        [strongDelegate taskViewController:self didChangeResult: [self result]];
    }
}

- (BOOL)stepViewControllerHasPreviousStep:(ORKStepViewController *)stepViewController {
    ORKStep *thisStep = stepViewController.step;
    if (! thisStep) {
        return NO;
    }
    ORKStep *previousStep = [self stepBeforeStep:thisStep];
    if ([previousStep isKindOfClass:[ORKActiveStep class]] || ([thisStep allowsBackNavigation] == NO)) {
        previousStep = nil; // Can't go back to an active step
    }
    return (previousStep != nil);
}

- (BOOL)stepViewControllerHasNextStep:(ORKStepViewController *)stepViewController {
    ORKStep *thisStep = stepViewController.step;
    if (! thisStep) {
        return NO;
    }
    ORKStep *nextStep = [self stepAfterStep:thisStep];
    return (nextStep != nil);
}

- (void)stepViewController:(ORKStepViewController *)stepViewController recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error {
    STRONGTYPE(self.delegate) strongDelegate = self.delegate;
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

#pragma mark - UIStateRestoring

static NSString * const _ORKTaskRunUUIDRestoreKey = @"taskRunUUID";
static NSString * const _ORKShowsProgressInNavigationBarRestoreKey = @"showsProgressInNavigationBar";
static NSString * const _ORKManagedResultsRestoreKey = @"managedResults";
static NSString * const _ORKManagedStepIdentifiersRestoreKey = @"managedStepIdentifiers";
static NSString * const _ORKHaveSetProgressLabelRestoreKey = @"haveSetProgressLabel";
static NSString * const _ORKHasRequestedHealthDataRestoreKey = @"hasRequestedHealthData";
static NSString * const _ORKRequestedHealthTypesForReadRestoreKey = @"requestedHealthTypesForRead";
static NSString * const _ORKRequestedHealthTypesForWriteRestoreKey = @"requestedHealthTypesForWrite";
static NSString * const _ORKOutputDirectoryRestoreKey = @"outputDirectory";
static NSString * const _ORKLastBeginningInstructionStepIdentifierKey = @"lastBeginningInstructionStepIdentifier";
static NSString * const _ORKTaskIdentifierRestoreKey = @"taskIdentifier";
static NSString * const _ORKStepIdentifierRestoreKey = @"stepIdentifier";
static NSString * const _ORKPresentedDate = @"presentedDate";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskRunUUID forKey:_ORKTaskRunUUIDRestoreKey];
    [coder encodeBool:self.showsProgressInNavigationBar forKey:_ORKShowsProgressInNavigationBarRestoreKey];
    [coder encodeObject:_managedResults forKey:_ORKManagedResultsRestoreKey];
    [coder encodeObject:_managedStepIdentifiers forKey:_ORKManagedStepIdentifiersRestoreKey];
    [coder encodeBool:_haveSetProgressLabel forKey:_ORKHaveSetProgressLabelRestoreKey];
    [coder encodeObject:_requestedHealthTypesForRead forKey:_ORKRequestedHealthTypesForReadRestoreKey];
    [coder encodeObject:_requestedHealthTypesForWrite forKey:_ORKRequestedHealthTypesForWriteRestoreKey];
    [coder encodeObject:_presentedDate forKey:_ORKPresentedDate];
    [coder encodeObject:_outputDirectory forKey:_ORKOutputDirectoryRestoreKey];
    [coder encodeObject:_lastBeginningInstructionStepIdentifier forKey:_ORKLastBeginningInstructionStepIdentifierKey];
    
    [coder encodeObject:_task.identifier forKey:_ORKTaskIdentifierRestoreKey];
    
    ORKStep *step = [_currentStepViewController step];
    if ([step isRestorable]) {
        [coder encodeObject:step.identifier forKey:_ORKStepIdentifierRestoreKey];
    } else if (_lastRestorableStepIdentifier) {
        [coder encodeObject:_lastRestorableStepIdentifier forKey:_ORKStepIdentifierRestoreKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _taskRunUUID = [coder decodeObjectOfClass:[NSUUID class] forKey:_ORKTaskRunUUIDRestoreKey];
    self.showsProgressInNavigationBar = [coder decodeBoolForKey:_ORKShowsProgressInNavigationBarRestoreKey];
    
    _outputDirectory = [coder decodeObjectOfClass:[NSURL class] forKey:_ORKOutputDirectoryRestoreKey];
    
    // Must have a task object already provided by this point in the restoration, in order to restore any other state.
    if (_task) {
        
        // Recover partially entered results, even if we may not be able to jump to the desired step.
        _managedResults = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:_ORKManagedResultsRestoreKey];
        _managedStepIdentifiers = [coder decodeObjectOfClass:[NSMutableArray class] forKey:_ORKManagedStepIdentifiersRestoreKey];
        
        _restoredTaskIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKTaskIdentifierRestoreKey];
        if (_restoredTaskIdentifier) {
            if (! [_task.identifier isEqualToString:_restoredTaskIdentifier]) {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                               reason:[NSString stringWithFormat:@"Restored task identifier %@ does not match task %@ provided",_restoredTaskIdentifier,_task.identifier]
                                             userInfo:nil];
            }
        }
        
        if ([_task respondsToSelector:@selector(stepWithIdentifier:)]) {
            _haveSetProgressLabel = [coder decodeBoolForKey:_ORKHaveSetProgressLabelRestoreKey];
            _requestedHealthTypesForRead = [coder decodeObjectOfClass:[NSSet class] forKey:_ORKRequestedHealthTypesForReadRestoreKey];
            _requestedHealthTypesForWrite = [coder decodeObjectOfClass:[NSSet class] forKey:_ORKRequestedHealthTypesForWriteRestoreKey];
            _presentedDate = [coder decodeObjectOfClass:[NSDate class] forKey:_ORKPresentedDate];
            _lastBeginningInstructionStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKLastBeginningInstructionStepIdentifierKey];
            
            _restoredStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKStepIdentifierRestoreKey];
    
        } else {
            ORK_Log_Debug(@"Not restoring current step of task %@ because it does not implement -stepWithIdentifier:", _task.identifier);
        }
    }
}


- (void) applicationFinishedRestoringState {
    [super applicationFinishedRestoringState];
    
    _pageViewController = (UIPageViewController *)[self.childNavigationController viewControllers][0];
    
    if (! _task) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Task must be provided to restore task view controller"
                                     userInfo:nil];
    }
    
    if (_restoredStepIdentifier) {
        
        ORKStepViewController *stepVC = _currentStepViewController;
        if (stepVC) {
            stepVC.delegate = self;
            
            if (stepVC.cancelButtonItem == nil) {
                stepVC.cancelButtonItem = [self defaultCancelButtonItem];
            }
            
            if ([self.delegate respondsToSelector:@selector(taskViewController:hasLearnMoreForStep:)] &&
                [self.delegate taskViewController:self hasLearnMoreForStep:(ORKStep *__nonnull)stepVC.step]) {
                
                stepVC.learnMoreButtonItem = [self defaultLearnMoreButtonItem];
            }
            
            _stepVCObserver = [[ORKTaskViewControllerObserver alloc] initWithTargetViewContoller:stepVC taskViewController:self];
            
        } else if ([_task respondsToSelector:@selector(stepWithIdentifier:)]) {
            stepVC = [self viewControllerForStep:[_task stepWithIdentifier:_restoredStepIdentifier]];
        } else {
            stepVC = [self viewControllerForStep:[_task stepAfterStep:nil withResult:[self result]]];
        }
        
        if (stepVC != nil) {
            [self showViewController:stepVC goForward:YES animated:NO];
            _hasBeenPresented = YES;
        }
    }
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    if ([[identifierComponents lastObject] isEqualToString:_PageViewControllerRestorationKey]) {
        UIPageViewController *pageVc = [self pageVc];
        pageVc.restorationIdentifier = [identifierComponents lastObject];
        pageVc.restorationClass = self;
        return pageVc;
    }
    else if ([[identifierComponents lastObject] isEqualToString:_ChildNavigationControllerRestorationKey]) {
        UINavigationController *nav = [UINavigationController new];
        nav.restorationIdentifier = [identifierComponents lastObject];
        nav.restorationClass = self;
        return nav;
    }
    
    ORKTaskViewController *taskVc = [[ORKTaskViewController alloc] initWithTask:nil taskRunUUID:nil];
    taskVc.restorationIdentifier = [identifierComponents lastObject];
    taskVc.restorationClass = self;
    return taskVc;
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
