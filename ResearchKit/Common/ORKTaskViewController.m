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

#import "ORKActiveStepViewController.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "ORKFormStepViewController.h"
#import "ORKQuestionStepViewController.h"
#import "ORKReviewStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTappingIntervalStepViewController.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKVisualConsentStepViewController.h"
#import "ORKLearnMoreStepViewController.h"

#import "ORKActiveStep.h"
#import "ORKCollectionResult_Private.h"
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
#import "ORKBorderedButton.h"
#import "ORKTaskReviewViewController.h"

@import AVFoundation;
@import CoreMotion;
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


@interface ORKTaskViewController () <ORKTaskReviewViewControllerDelegate, UINavigationControllerDelegate> {
    NSMutableDictionary *_managedResults;
    NSMutableArray *_managedStepIdentifiers;
    ORKScrollViewObserver *_scrollViewObserver;
    BOOL _hasBeenPresented;
    BOOL _hasRequestedHealthData;
    BOOL _saveable;
    ORKPermissionMask _grantedPermissions;
#if HEALTH
     NSSet<HKObjectType *> *_requestedHealthTypesForRead;
     NSSet<HKObjectType *> *_requestedHealthTypesForWrite;
#endif
    NSURL *_outputDirectory;
    
    NSDate *_presentedDate;
    NSDate *_dismissedDate;
    
    NSString *_lastBeginningInstructionStepIdentifier;
    NSString *_lastRestorableStepIdentifier;
    
    BOOL _hasAudioSession; // does not need state restoration - temporary
    
    NSString *_restoredTaskIdentifier;
    NSString *_restoredStepIdentifier;
    BOOL _hasLockedVolume;
    float _savedVolume;
    float _lockedVolume;
    
    UINavigationController *_childNavigationController;
    UIViewController *_previousToTopControllerInNavigationStack;
}

@property (nonatomic, strong) ORKStepViewController *currentStepViewController;
@property (nonatomic) ORKTaskReviewViewController *taskReviewViewController;

@end


@implementation ORKTaskViewController

@synthesize taskRunUUID=_taskRunUUID;

static NSString *const _ChildNavigationControllerRestorationKey = @"childNavigationController";

- (void)setUpChildNavigationController  {
    _previousToTopControllerInNavigationStack = nil;
    UIViewController *emptyViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    _childNavigationController = [[UINavigationController alloc] initWithRootViewController:emptyViewController];
    _childNavigationController.delegate = self;
    
    [_childNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [_childNavigationController.navigationBar setShadowImage:[UIImage new]];
    [_childNavigationController.navigationBar setTranslucent:NO];
    [_childNavigationController.navigationBar setBarTintColor:ORKColor(ORKBackgroundColorKey)];
    
    if (@available(iOS 13.0, *)) {
        [_childNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor secondaryLabelColor]}];
        _childNavigationController.navigationBar.prefersLargeTitles = NO;
    } else {
        [_childNavigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor systemGrayColor]}];
    }
    [_childNavigationController.view setBackgroundColor:UIColor.clearColor];
    
    [self addChildViewController:_childNavigationController];
    _childNavigationController.view.frame = self.view.frame;
    _childNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_childNavigationController.view];
    [_childNavigationController didMoveToParentViewController:self];
    _childNavigationController.restorationClass = [self class];
    _childNavigationController.restorationIdentifier = _ChildNavigationControllerRestorationKey;
}

- (instancetype)commonInitWithTask:(id<ORKTask>)task taskRunUUID:(NSUUID *)taskRunUUID {
    [self setTask: task];
    
    self.showsProgressInNavigationBar = YES;
    self.discardable = NO;
    self.progressMode = ORKTaskViewControllerProgressModeQuestionsPerStep;
    _saveable = NO;
    
    _managedResults = [NSMutableDictionary dictionary];
    _managedStepIdentifiers = [NSMutableArray array];
    
    self.taskRunUUID = taskRunUUID ?: [NSUUID UUID];
    
    // Ensure taskRunUUID has non-nil valuetaskRunUUID
    (void)[self taskRunUUID];
    self.restorationClass = [ORKTaskViewController class];
    
    _hasLockedVolume = NO;
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return [self commonInitWithTask:nil taskRunUUID:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return [self commonInitWithTask:nil taskRunUUID:nil];
}
#pragma clang diagnostic pop

- (instancetype)initWithTask:(id<ORKTask>)task taskRunUUID:(NSUUID *)taskRunUUID {
    self = [super initWithNibName:nil bundle:nil];
    return [self commonInitWithTask:task taskRunUUID:taskRunUUID];
}

- (instancetype)initWithTask:(id<ORKTask>)task restorationData:(NSData *)data delegate:(id<ORKTaskViewControllerDelegate>)delegate error:(NSError* __autoreleasing *)errorOut {
    
    self = [self initWithTask:task taskRunUUID:nil];
    
    if (self) {
        self.delegate = delegate;
        if (data != nil) {
            self.restorationClass = [self class];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            [self decodeRestorableStateWithCoder:unarchiver];
            [self applicationFinishedRestoringState];
            
            if (unarchiver == nil) {
                *errorOut = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"RESTORE_ERROR_CANNOT_DECODE", nil)}];
            }
        }
    }
    return self;
}

- (instancetype)initWithTask:(id<ORKTask>)task
               ongoingResult:(nullable ORKTaskResult *)ongoingResult
         defaultResultSource:(nullable id<ORKTaskResultSource>)defaultResultSource
                    delegate:(id<ORKTaskViewControllerDelegate>)delegate {
    
    self = [self initWithTask:task taskRunUUID:nil];
    
    if (self) {
        _delegate = delegate;
        _defaultResultSource = defaultResultSource;
        if (ongoingResult != nil) {
            for (ORKResult *stepResult in ongoingResult.results) {
                NSString *stepResultIdentifier = stepResult.identifier;
                if ([task stepWithIdentifier:stepResultIdentifier] == nil) {
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"ongoingResults has results for identifiers not found within the task steps" userInfo:nil];
                }
                [_managedStepIdentifiers addObject:stepResultIdentifier];
                _managedResults[stepResultIdentifier] = stepResult;
            }
            _restoredStepIdentifier = ongoingResult.results.lastObject.identifier;
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
            ORK_Log_Debug("Task identifier should not be nil.");
        }
        if ([task respondsToSelector:@selector(validateParameters)]) {
            [task validateParameters];
        }
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
#if HEALTH
    if ((![HKHealthStore isHealthDataAvailable]) || (!readTypes && !writeTypes)) {
        _requestedHealthTypesForRead = nil;
        _requestedHealthTypesForWrite = nil;
        handler();
        return;
    }
    
    _requestedHealthTypesForRead = readTypes;
    _requestedHealthTypesForWrite = writeTypes;

    __block HKHealthStore *healthStore = [HKHealthStore new];
    [healthStore requestAuthorizationToShareTypes:writeTypes readTypes:readTypes completion:^(BOOL success, NSError *error) {
        ORK_Log_Error("Health access: error=%@", error);
        dispatch_async(dispatch_get_main_queue(), handler);
        
        // Clear self-ref.
        healthStore = nil;
    }];
#endif
}

- (void)requestPedometerAccessWithHandler:(void (^)(BOOL success))handler {
    NSParameterAssert(handler != nil);
    if (![CMPedometer isStepCountingAvailable]) {
        handler(NO);
        return;
    }
    
    __block CMPedometer *pedometer = [CMPedometer new];
    [pedometer queryPedometerDataFromDate:[NSDate dateWithTimeIntervalSinceNow:-100]
                                   toDate:[NSDate date]
                              withHandler:^(CMPedometerData *pedometerData, NSError *error) {
                                  ORK_Log_Error("Pedometer access: error=%@", error);
                                  
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

- (void)requestCameraAccessWithHandler:(void (^)(BOOL success))handler {
    NSParameterAssert(handler != nil);
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
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
#if HEALTH
    if ([self.task respondsToSelector:@selector(requestedHealthKitTypesForReading)]) {
        readTypes = [self.task requestedHealthKitTypesForReading];
    }
#endif
    NSSet *writeTypes = nil;
#if HEALTH
    if ([self.task respondsToSelector:@selector(requestedHealthKitTypesForWriting)]) {
        writeTypes = [self.task requestedHealthKitTypesForWriting];
    }
#endif
    ORKPermissionMask permissions = [self desiredPermissions];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ORK_Log_Debug("Requesting health access");
            [self requestHealthStoreAccessWithReadTypes:readTypes
                                             writeTypes:writeTypes
                                                handler:^{
                                                    dispatch_semaphore_signal(semaphore);
                                                }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (permissions & ORKPermissionCoreMotionAccelerometer) {
            _grantedPermissions |= ORKPermissionCoreMotionAccelerometer;
        }
        if (permissions & ORKPermissionCoreMotionActivity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug("Requesting pedometer access");
                [self requestPedometerAccessWithHandler:^(BOOL success) {
                    if (success) {
                        _grantedPermissions |= ORKPermissionCoreMotionActivity;
                    } else {
                        _grantedPermissions &= ~ORKPermissionCoreMotionActivity;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (permissions & ORKPermissionAudioRecording) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug("Requesting audio access");
                [self requestAudioRecordingAccessWithHandler:^(BOOL success) {
                    if (success) {
                        _grantedPermissions |= ORKPermissionAudioRecording;
                    } else {
                        _grantedPermissions &= ~ORKPermissionAudioRecording;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (permissions & ORKPermissionCoreLocation) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug("Requesting location access");
                [self requestLocationAccessWithHandler:^(BOOL success) {
                    if (success) {
                        _grantedPermissions |= ORKPermissionCoreLocation;
                    } else {
                        _grantedPermissions &= ~ORKPermissionCoreLocation;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (permissions & ORKPermissionCamera) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ORK_Log_Debug("Requesting camera access");
                [self requestCameraAccessWithHandler:^(BOOL success) {
                    if (success) {
                        _grantedPermissions |= ORKPermissionCamera;
                    } else {
                        _grantedPermissions &= ~ORKPermissionCamera;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            });
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
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
            if (![self startAudioPromptSessionWithError:&error]) {
                // User-visible console log message
                ORK_Log_Error("Failed to start audio prompt session: %@", error);
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
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:0
                        error:&error]) {
        success = NO;
        ORK_Log_Error("Could not start audio session: %@", error);
    }
    
    // We are setting the session active so that we can stay live to play audio
    // in the background.
    if (success && ![session setActive:YES withOptions:0 error:&error]) {
        success = NO;
        ORK_Log_Error("Could not set audio session active: %@", error);
    }
    
    if (errorOut != NULL) {
        *errorOut = error;
    }
    
    _hasAudioSession = _hasAudioSession || success;
    if (_hasAudioSession) {
        ORK_Log_Debug("*** Started audio session");
    }
    return success;
}

- (void)finishAudioPromptSession {
    if (_hasAudioSession) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        if (![session setActive:NO withOptions:0 error:&error]) {
            ORK_Log_Error("Could not deactivate audio session: %@", error);
        } else {
            ORK_Log_Debug("*** Finished audio session");
        }
    }
}

#if HEALTH
- (NSSet<HKObjectType *> *)requestedHealthTypesForRead {
    return _requestedHealthTypesForRead;
}

- (NSSet<HKObjectType *> *)requestedHealthTypesForWrite {
    return _requestedHealthTypesForWrite;
}
#endif

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpChildNavigationController];
    
    if (_restoredStepIdentifier) {
        [self applicationFinishedRestoringState];
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
            
            if (![step isKindOfClass:[ORKInstructionStep class]]) {
                [self startAudioPromptSessionIfNeeded];
                [self requestHealthAuthorizationWithCompletion:nil];
            }
            
            ORKStepViewController *firstViewController = [self viewControllerForStep:step];
            [self showStepViewController:firstViewController goForward:YES animated:NO];
            
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

    #if defined(__IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        if ([self shouldDismissWithSwipe] == NO) {
            self.modalInPresentation = YES;
        }
    }
    #endif

    if (_taskReviewViewController) {
        [_childNavigationController setViewControllers:@[_taskReviewViewController] animated:NO];
        [self setTaskReviewViewControllerNavbar];
    }
    
    if (_currentStepViewController) {
        [self setUpProgressLabelForStepViewController:_currentStepViewController];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    // Set endDate on TaskVC is dismissed,
    // because nextResponder is not nil when current TaskVC is covered by another modal view
    if (self.nextResponder == nil) {
        _dismissedDate = [NSDate date];
    }
}

- (NSArray *)managedResults {
    NSMutableArray *results = [NSMutableArray new];
    
    [_managedStepIdentifiers enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger idx, BOOL *stop) {
        id <NSCopying> key = identifier;
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
    _managedResults[aKey] = result;
}

- (ORKTaskResult *)result {
    //    TODO: update current implementation.
    //    setManagedResult for currentStepViewController should not be called every single time this method is called.
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
        
        _registeredScrollView = registeredScrollView;
        
        // Stop old observer
        _scrollViewObserver = nil;
    }
}

- (void)learnMoreButtonPressedWithStep:(ORKLearnMoreInstructionStep *)learnMoreInstructionStep fromStepViewController:(nonnull ORKStepViewController *)stepViewController {
    if ([self.delegate respondsToSelector:@selector(taskViewController:learnMoreButtonPressedWithStep:forStepViewController:)]) {
        [self.delegate taskViewController:self learnMoreButtonPressedWithStep:learnMoreInstructionStep forStepViewController:stepViewController];
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
    [_childNavigationController popViewControllerAnimated:YES];
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

- (BOOL)grantedAtLeastOnePermission {
    // Return YES, if no desired permission or granted at least one permission.
    ORKPermissionMask desiredMask = [self desiredPermissions];
    return (desiredMask == 0 || ((desiredMask & _grantedPermissions) != 0));
}

- (void)showStepViewController:(ORKStepViewController *)stepViewController goForward:(BOOL)goForward animated:(BOOL)animated {
    if (nil == stepViewController) {
        return;
    }
    
    ORKStep *step = stepViewController.step;
    [self updateLastBeginningInstructionStepIdentifierForStep:step goForward:goForward];
    
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
                                                          code:NSUserCancelledError
                                                      userInfo:@{@"reason": @"Required permissions not granted."}]
                               onStep:fromController.step];
                } else {
                    [self showStepViewController:stepViewController goForward:goForward animated:animated];
                }
            }];
            return;
        }
    }
    
    if (step.identifier && ![_managedStepIdentifiers.lastObject isEqualToString:step.identifier]) {
        [_managedStepIdentifiers addObject:step.identifier];
    }
    if ([step isRestorable] && !(stepViewController.isBeingReviewed && stepViewController.parentReviewStep.isStandalone)) {
        _lastRestorableStepIdentifier = step.identifier;
    }
        
    ORKStepViewControllerNavigationDirection stepDirection = goForward ? ORKStepViewControllerNavigationDirectionForward : ORKStepViewControllerNavigationDirectionReverse;
    
    [stepViewController willNavigateDirection:stepDirection];
    
    ORK_Log_Debug("%@ %@", self, stepViewController);
    
    self.registeredScrollView = nil;
    
    // Switch to non-animated transition if the application is not in the foreground.
    animated = animated && ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground);
    
    // Update currentStepViewController now, so we don't accept additional transition requests
    // from the same VC.
    _currentStepViewController = stepViewController;
    [self setUpProgressLabelForStepViewController:stepViewController];
    
    NSMutableArray<UIViewController *> *newViewControllers = [NSMutableArray new];
    // Add at most two previous step view controllers to support the back action on the navigation controller stack
    _previousToTopControllerInNavigationStack = nil;
    if (stepViewController.hasPreviousStep) {
        ORKStep *previousStep = [self.task stepBeforeStep:step withResult:self.result];
        if (previousStep) {
            ORKStepViewController *previousStepViewController = [self viewControllerForStep:previousStep isPreviousViewController:YES];
            previousStepViewController.navigationItem.title = nil; // Make sure the back button shows "Back"
            if (previousStepViewController.hasPreviousStep) {
                ORKStep *previousToPreviousStep = [self.task stepBeforeStep:previousStep withResult:self.result];
                if (previousToPreviousStep) {
                    ORKStepViewController *previousToPreviousStepViewController = [self viewControllerForStep:previousToPreviousStep isPreviousViewController:YES];
                    previousToPreviousStepViewController.navigationItem.title = nil; // Make sure the back button shows "Back"
                    [newViewControllers addObject:previousToPreviousStepViewController];
                }
            }
            _previousToTopControllerInNavigationStack = previousStepViewController;
            [newViewControllers addObject:previousStepViewController];
        }
    }
    [newViewControllers addObject:stepViewController];
    if (newViewControllers != _childNavigationController.viewControllers) {
        [_childNavigationController setViewControllers:newViewControllers animated:animated];
    }
}

- (BOOL)shouldPresentStep:(ORKStep *)step {
    BOOL shouldPresent = (step != nil);
    
    if (shouldPresent && [self.delegate respondsToSelector:@selector(taskViewController:shouldPresentStep:)]) {
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

-(ORKLearnMoreStepViewController *)learnMoreViewControllerForStep:(ORKLearnMoreInstructionStep *)step {
    if (step == nil) {
        return nil;
    }
    
    ORKLearnMoreStepViewController *learnMoreViewController = nil;
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:learnMoreViewControllerForStep:)]) {
        learnMoreViewController = [self.delegate taskViewController:self learnMoreViewControllerForStep:step];
    }
    
    if (!learnMoreViewController) {
        learnMoreViewController = [[ORKLearnMoreStepViewController alloc] initWithStep:step];
    }
    
    return learnMoreViewController;
}

- (ORKStepViewController *)viewControllerForStep:(ORKStep *)step isPreviousViewController:(BOOL)isPreviousViewController {
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
    if (!isPreviousViewController) {
        // Do not update the task's managed result if we are instantiating a previous view controllers for the
        // navigation stack. Some active view controllers don't feature
        // a result retoration path on init and we don't want to overwrite the most current result stored by the task
        [self setManagedResult:stepViewController.result forKey:step.identifier];
    }
    
    
    if (stepViewController.cancelButtonItem == nil) {
        stepViewController.cancelButtonItem = [self defaultCancelButtonItem];
    }
    
    if ([self.delegate respondsToSelector:@selector(taskViewController:hasLearnMoreForStep:)] &&
        [self.delegate taskViewController:self hasLearnMoreForStep:step]) {
        
        stepViewController.learnMoreButtonItem = [self defaultLearnMoreButtonItem];
    }
    
    stepViewController.delegate = self;
    return stepViewController;
}

- (ORKStepViewController *)viewControllerForStep:(ORKStep *)step {
    return [self viewControllerForStep:step isPreviousViewController:NO];
}

- (BOOL)shouldDisplayProgressLabelWithStepViewController:(ORKStepViewController *)stepViewController {
    return self.showsProgressInNavigationBar && [_task respondsToSelector:@selector(progressOfCurrentStep:withResult:)] && stepViewController.step.showsProgress && !(stepViewController.parentReviewStep.isStandalone);
}

- (void)setUpProgressLabelForStepViewController:(ORKStepViewController *)stepViewController {
    NSString *progressLabel = nil;
    if ([self shouldDisplayProgressLabelWithStepViewController:stepViewController]) {
        ORKTaskProgress progress = [_task progressOfCurrentStep:stepViewController.step withResult:[self result]];
        if (progress.shouldBePresented) {
            progressLabel = [NSString localizedStringWithFormat:ORKLocalizedString(@"STEP_PROGRESS_FORMAT", nil), ORKLocalizedStringFromNumber(@(progress.current+1)), ORKLocalizedStringFromNumber(@(progress.total))];
        }
    }
    stepViewController.navigationItem.title = progressLabel;
}

#pragma mark - internal action Handlers

- (void)finishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    ORKStrongTypeOf(self.delegate) strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(taskViewController:didFinishWithReason:error:)]) {
        [strongDelegate taskViewController:self didFinishWithReason:reason error:error];
    }
}

- (void)presentCancelOptions:(BOOL)saveable sender:(id)sender {
    
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
    
    if ([sender isKindOfClass:[ORKBorderedButton class]]) {
        UIView *cancelButtonView = (UIView *)sender;
        alert.popoverPresentationController.sourceView = cancelButtonView;
        alert.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(cancelButtonView.bounds), CGRectGetMidY(cancelButtonView.bounds),0,0);
    }
    else if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        alert.popoverPresentationController.barButtonItem = sender;
    }
    
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
    if (self.discardable) {
        [self finishWithReason:ORKTaskViewControllerFinishReasonDiscarded error:nil];
    } else {
        [self presentCancelOptions:_saveable sender:sender];
    }
}

- (BOOL)shouldDismissWithSwipe {
    // Should we also include visualConsentStep here? Others?
    BOOL isCurrentInstructionStep = [self.currentStepViewController.step isKindOfClass:[ORKInstructionStep class]];
    
    // [self result] would not include any results beyond current step.
    // Use _managedResults to get the completed result set.
    NSArray *results = _managedResults.allValues;
    _saveable = NO;
    for (ORKStepResult *result in results) {
        if ([result isSaveable]) {
            _saveable = YES;
            break;
        }
    }
    
    BOOL isStandaloneReviewStep = NO;
    if ([self.currentStepViewController.step isKindOfClass:[ORKReviewStep class]]) {
        ORKReviewStep *reviewStep = (ORKReviewStep *)self.currentStepViewController.step;
        isStandaloneReviewStep = reviewStep.isStandalone;
    }
    
    if ((isCurrentInstructionStep && _saveable == NO) || isStandaloneReviewStep || self.currentStepViewController.readOnlyMode) {
        return YES;
    } else {
        return NO;
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

- (void)flipToNextPageFrom:(ORKStepViewController *)fromController animated:(BOOL)animated {
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
        [self finishAudioPromptSession];
        if (self.reviewMode == ORKTaskViewControllerReviewModeStandalone) {
            [_taskReviewViewController removeFromParentViewController];
            _taskReviewViewController = nil;
            if ([self.task isKindOfClass:[ORKOrderedTask class]]) {
                ORKOrderedTask *orderedTask = (ORKOrderedTask *)self.task;
                if (!_taskReviewViewController) {
                    _taskReviewViewController = [[ORKTaskReviewViewController alloc] initWithResultSource:self.result forSteps:orderedTask.steps withContentFrom:_reviewInstructionStep];
                    _taskReviewViewController.delegate = self;
                    
                    [_childNavigationController setViewControllers:@[_taskReviewViewController] animated:YES];
                    [self setTaskReviewViewControllerNavbar];
                    
                }
            }
        }
        else {
            [self finishWithReason:ORKTaskViewControllerFinishReasonCompleted error:nil];
        }
    } else if ([self shouldPresentStep:step]) {
        ORKStepViewController *stepViewController = [self viewControllerForStep:step];
        NSAssert(stepViewController != nil, @"A non-nil step should always generate a step view controller");
        if (fromController.isBeingReviewed) {
            [_managedStepIdentifiers removeLastObject];
        }
        [self showStepViewController:stepViewController goForward:YES animated:animated];
    }
    
}

- (void)setTaskReviewViewControllerNavbar {
    if (_taskReviewViewController && _taskReviewViewController.navigationController) {
        _taskReviewViewController.navigationController.navigationBar.topItem.title = @"";
        [_taskReviewViewController.navigationController.navigationBar setBackgroundColor:ORKColor(ORKBackgroundColorKey)];
    }
}

- (void)flipToFirstPage {
    ORKStep *firstStep = [_task stepAfterStep:nil withResult:[self result]];
    if (firstStep) {
        [self showStepViewController:[self viewControllerForStep:firstStep] goForward:YES animated:NO];
    }
}

- (void)flipToLastPage {
    ORKStep *initialCurrentStep = _currentStepViewController.step;
    ORKStep *lastStep = nil;
    ORKStep *nextStep = _currentStepViewController.step;
    do {
        lastStep = nextStep;
        nextStep = [_task stepAfterStep:lastStep withResult:[self result]];
    } while (nextStep != nil);
    if (lastStep != initialCurrentStep) {
        [self showStepViewController:[self viewControllerForStep:lastStep] goForward:YES animated:YES];
    }
}

- (void)flipToPreviousPageFrom:(ORKStepViewController *)fromController animated:(BOOL)animated {
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
            
            [self showStepViewController:stepViewController goForward:NO animated:animated];
        }
    }
}

- (void)flipToPageWithIdentifier:(NSString *)identifier forward:(BOOL)forward animated:(BOOL)animated
{
    NSUInteger index =
    [[(ORKOrderedTask *)self.task steps] indexOfObjectPassingTest:^BOOL(ORKStep * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
            if ([obj.identifier isEqualToString:identifier])
            {
                *stop = YES;
                return YES;
            }
            
            return NO;
    }];
        
        if (index == NSNotFound) { return; }
        
        ORKStep *step = [[(ORKOrderedTask *)self.task steps] objectAtIndex:index];
        if (step)
        {
            [self showStepViewController:[self viewControllerForStep:step] goForward:forward animated:animated];
        }
}

#pragma mark -  ORKStepViewControllerDelegate

- (void)stepViewControllerWillAppear:(ORKStepViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(taskViewController:stepViewControllerWillAppear:)]) {
        [self.delegate taskViewController:self stepViewControllerWillAppear:viewController];
    }
}

- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction
                  animated:(BOOL)animated {
    
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
        [self flipToNextPageFrom:stepViewController animated:animated];
    } else {
        [self flipToPreviousPageFrom:stepViewController animated:animated];
    }
}

- (void)stepViewController:(ORKStepViewController *)stepViewController didFinishWithNavigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    [self stepViewController:stepViewController didFinishWithNavigationDirection:direction animated:(direction == ORKStepViewControllerNavigationDirectionForward)];
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

- (ORKTaskTotalProgress)stepViewControllerTotalProgressInfoForStep:(ORKStepViewController *)stepViewController currentStep:(ORKStep *)currentStep {
    
    ORKTaskTotalProgress progressData = [self.task totalProgressOfCurrentStep:currentStep];
    
    if (self.progressMode != ORKTaskViewControllerProgressModeTotalQuestions) {
        progressData.stepShouldShowTotalProgress = NO;
    } else {
        progressData.stepShouldShowTotalProgress = YES;
    }
    
    return progressData;
}

- (ORKStep *)stepBeforeStep:(ORKStep *)step {
    return [self.task stepBeforeStep:step withResult:[self result]];
}

- (nullable ORKStep *)stepAfterStep:(ORKStep *)step {
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
    [self showStepViewController:stepViewController goForward:YES animated:YES];
}

#pragma mark - UIStateRestoring

static NSString *const _ORKTaskRunUUIDRestoreKey = @"taskRunUUID";
static NSString *const _ORKShowsProgressInNavigationBarRestoreKey = @"showsProgressInNavigationBar";
static NSString *const _ORKDiscardableTaskRestoreKey = @"discardableTask";
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
static NSString *const _ORKProgressMode = @"progressMode";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskRunUUID forKey:_ORKTaskRunUUIDRestoreKey];
    [coder encodeBool:self.showsProgressInNavigationBar forKey:_ORKShowsProgressInNavigationBarRestoreKey];
    [coder encodeBool:self.discardable forKey:_ORKDiscardableTaskRestoreKey];
    [coder encodeObject:_managedResults forKey:_ORKManagedResultsRestoreKey];
    [coder encodeObject:_managedStepIdentifiers forKey:_ORKManagedStepIdentifiersRestoreKey];
#if HEALTH
    [coder encodeObject:_requestedHealthTypesForRead forKey:_ORKRequestedHealthTypesForReadRestoreKey];
    [coder encodeObject:_requestedHealthTypesForWrite forKey:_ORKRequestedHealthTypesForWriteRestoreKey];
#endif
    [coder encodeObject:_presentedDate forKey:_ORKPresentedDate];
    [coder encodeInteger:_progressMode forKey:_ORKProgressMode];
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
    self.discardable = [coder decodeBoolForKey:_ORKDiscardableTaskRestoreKey];
    self.progressMode = [coder decodeIntegerForKey:_ORKProgressMode];
    
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
#if HEALTH
            _requestedHealthTypesForRead = [coder decodeObjectOfClass:[NSSet class] forKey:_ORKRequestedHealthTypesForReadRestoreKey];
            _requestedHealthTypesForWrite = [coder decodeObjectOfClass:[NSSet class] forKey:_ORKRequestedHealthTypesForWriteRestoreKey];
#endif
            _presentedDate = [coder decodeObjectOfClass:[NSDate class] forKey:_ORKPresentedDate];
            _lastBeginningInstructionStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKLastBeginningInstructionStepIdentifierKey];
            
            _restoredStepIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:_ORKStepIdentifierRestoreKey];
        } else {
            ORK_Log_Info("Not restoring current step of task %@ because it does not implement -stepWithIdentifier:", _task.identifier);
        }
    }
}

- (void)applicationFinishedRestoringState {
    [super applicationFinishedRestoringState];

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
            
        } else if ([_task respondsToSelector:@selector(stepWithIdentifier:)]) {
            stepViewController = [self viewControllerForStep:[_task stepWithIdentifier:_restoredStepIdentifier]];
        } else {
            stepViewController = [self viewControllerForStep:[_task stepAfterStep:nil withResult:[self result]]];
        }
        
        if (stepViewController != nil) {
            [self showStepViewController:stepViewController goForward:YES animated:NO];
            _hasBeenPresented = YES;
        }
    }
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
    if ([identifierComponents.lastObject isEqualToString:_ChildNavigationControllerRestorationKey]) {
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
    _childNavigationController.navigationBarHidden = navigationBarHidden;
}

- (BOOL)isNavigationBarHidden {
    return _childNavigationController.navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [_childNavigationController setNavigationBarHidden:hidden animated:YES];
}

- (UINavigationBar *)navigationBar {
    return _childNavigationController.navigationBar;
}

#pragma mark Review mode

- (void)addStepResultsUntilStepWithIdentifier:(NSString *)stepIdentifier {
    ORKTaskResult * taskResult = (ORKTaskResult *) _defaultResultSource;
    for (ORKStepResult * stepResult in taskResult.results) {
        if (![stepIdentifier isEqualToString: stepResult.identifier]) {
            if (![_managedStepIdentifiers containsObject:stepResult.identifier]) {
                [_managedStepIdentifiers addObject:stepResult.identifier];
            }
            _managedResults[stepResult.identifier] = stepResult;
        }
        else {
            break;
        }
    }
}

- (void)updateResultWithSource:(id<ORKTaskResultSource>)resultSource {
    ORKTaskResult * taskResult = (ORKTaskResult *) resultSource;
    for (ORKStepResult * stepResult in taskResult.results) {
        if (![_managedStepIdentifiers containsObject:stepResult.identifier]) {
            [_managedStepIdentifiers addObject:stepResult.identifier];
        }
        _managedResults[stepResult.identifier] = stepResult;
    }
}

- (void)setDefaultResultSource:(id<ORKTaskResultSource>)defaultResultSource {
    _defaultResultSource = defaultResultSource;
    [self setReviewMode:_reviewMode];
}

- (void)setReviewMode:(ORKTaskViewControllerReviewMode)reviewMode {
    if (_hasBeenPresented) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Cannot change review mode after presenting the task controller for now." userInfo:nil];
    }
    _reviewMode = reviewMode;
    [self setupTaskReviewViewController];
}

- (void)setupTaskReviewViewController {
    if (_reviewMode == ORKTaskViewControllerReviewModeNever) {
        _taskReviewViewController = nil;
        return;
    }
    
    _taskReviewViewController = nil;
    
    if ([self.task isKindOfClass:[ORKOrderedTask class]]) {
        ORKOrderedTask *orderedTask = (ORKOrderedTask *)self.task;
        
        _taskReviewViewController = [[ORKTaskReviewViewController alloc] initWithResultSource:_defaultResultSource forSteps:orderedTask.steps withContentFrom:_reviewInstructionStep];
        _taskReviewViewController.delegate = self;
    }
}

- (void)setReviewInstructionStep:(ORKInstructionStep *)reviewInstructionStep {
    _reviewInstructionStep = reviewInstructionStep;
    if (_taskReviewViewController) {
        _taskReviewViewController = nil;
    }
    [self setupTaskReviewViewController];
}

#pragma mark ORKTaskReviewViewControllerDelegate

- (void)doneButtonTappedWithResultSource:(id<ORKTaskResultSource>)resultSource {
    //    FIXME: might need to queue the operations if the number of steps are too many. open to debate.
    [self updateResultWithSource:resultSource];
    [self finishWithReason:ORKTaskViewControllerFinishReasonCompleted error:nil];
}

- (void)editAnswerTappedForStepWithIdentifier:(NSString *)stepIdentifier {
    [self addStepResultsUntilStepWithIdentifier:stepIdentifier];
    [self showStepViewController:[self viewControllerForStep:[self.task stepWithIdentifier:stepIdentifier]] goForward:YES animated:YES];
}

#pragma mark - UINavigationController delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == _previousToTopControllerInNavigationStack && [viewController isKindOfClass:[ORKStepViewController class]]) {
        // Make sure that the previous step view controller that will shows during an (interactive or non-interactive)
        // pop action shows the progress in the navigation bar when appropriate
        [self setUpProgressLabelForStepViewController:(ORKStepViewController *)viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == _previousToTopControllerInNavigationStack && [viewController isKindOfClass:[ORKStepViewController class]]) {
        // _childNavigationController has completed either: a non-interactive animated pop transition by tapping on the
        // back button; or an interactive animated pop transition by completing a drag-from-the-edge action. Update view
        // controller stack and task view controller state.
        [_currentStepViewController goBackward];
    }
}

@end
