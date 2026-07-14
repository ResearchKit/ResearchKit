/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKVideoCaptureStepViewController.h"
#import "ORKVideoCaptureView.h"
#import "ORKVideoCaptureStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKStep_Private.h"
#import "ORKNavigableOrderedTask.h"
#import "ORKCompletionStep.h"
#import "ORKCompletionStepViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "ORKCaptureAccessDeniedContext.h"
#import <ResearchKitUI/ResearchKitUI-Swift.h>


@interface ORKVideoCaptureStepViewController () <ORKVideoCaptureViewDelegate, AVCaptureFileOutputRecordingDelegate>

@end


@implementation ORKVideoCaptureStepViewController {
    ORKVideoCaptureView *_videoCaptureView;
    ORKVideoCaptureStep *_videoCaptureStep;
    dispatch_queue_t _sessionQueue;
    AVCaptureSession *_captureSession;
    AVCaptureMovieFileOutput *_movieFileOutput;
    NSURL *_fileURL;
    BOOL _recording;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [self initWithStep:step];
    if (self) {
        ORKStepResult *stepResult = (ORKStepResult *)result;
        if (stepResult && [stepResult results].count > 0) {
            
            ORKFileResult *fileResult = ORKDynamicCast([stepResult results].firstObject, ORKFileResult);
            
            if (fileResult.fileURL) {
                self.fileURL = fileResult.fileURL;
            }
        }
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        self.fileURL = nil;
        self.step.authDeniedContext = [[ORKCaptureAccessDeniedContext alloc]
                                       initWithTitle:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_TITLE", nil)
                                       text:ORKLocalizedString(@"CAPTURE_ERROR_NO_PERMISSIONS", nil)
                                       settingsLinkText:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_SETTINGS_LINK_TEXT", nil)
                                       completionStepIdentifier:@"ORKVideoCaptureStepIdentifierVideoAccessDeniedCompletion"
                                       learnMoreStepIdentifier:@"ORKVideoCaptureStepIdentifierInstructionStepPlaceHolderVideoAccessDenied"
                                       iconImage:[UIImage systemImageNamed:@"video.slash"]];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    _videoCaptureView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *iPadContentView = [self viewForiPadLayoutConstraints];
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:_videoCaptureView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:iPadContentView ? : self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:_videoCaptureView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:iPadContentView ? :  self.view
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:_videoCaptureView
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:iPadContentView ? : self.view
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:_videoCaptureView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:iPadContentView ? : self.view
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0.0]
                                       ]];

    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _videoCaptureView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _videoCaptureView.skipButtonItem = skipButtonItem;
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    [super setCancelButtonItem:cancelButtonItem];
    _videoCaptureView.cancelButtonItem = cancelButtonItem;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    if (self.step && [self isViewLoaded]) {
        [_videoCaptureView.playerViewController willMoveToParentViewController:nil];
        [_videoCaptureView.playerViewController removeFromParentViewController];
        [_videoCaptureView removeFromSuperview];
        _videoCaptureView = nil;
        _movieFileOutput = nil;
        _captureSession = nil;

        _videoCaptureView = [[ORKVideoCaptureView alloc] initWithFrame:CGRectZero];
        _videoCaptureView.videoCaptureStep = (ORKVideoCaptureStep *)self.step;
        _videoCaptureView.delegate = self;
        _videoCaptureView.cancelButtonItem = self.cancelButtonItem;
        _videoCaptureView.hidden = YES;
        [self.view addSubview:_videoCaptureView];

        [self addChildViewController:_videoCaptureView.playerViewController];
        [_videoCaptureView.playerViewController didMoveToParentViewController:self];
        
        
        _videoCaptureStep = (ORKVideoCaptureStep *)self.step;
        _movieFileOutput = [AVCaptureMovieFileOutput new];
        
        [self setUpConstraints];
        
        
        // Capture actions should be performed off the main queue to keep the UI responsive
        _sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_fileURL) {
        _videoCaptureView.hidden = NO;
        [self setFileURL:_fileURL];
    } else if (_captureSession) {
        _videoCaptureView.hidden = NO;
        dispatch_async(_sessionQueue, ^{
            [self->_captureSession startRunning];
        });
    } else {
        [self _checkCameraAuthorizationAndSetupSession];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // If the capture session is running, stop it
    if (_captureSession.isRunning) {
        dispatch_async(_sessionQueue, ^{
            [_captureSession stopRunning];
        });
    }
    
    [_videoCaptureView.playerViewController.player pause];
    
    [super viewWillDisappear:animated];
}

- (void)_checkCameraAuthorizationAndSetupSession {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self _checkMicrophoneAuthorizationAndStart];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self _handleDeniedCameraAccess];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self _checkMicrophoneAuthorizationAndStart];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        default: {
            [self _handleDeniedCameraAccess];
            break;
        }
    }
}

- (void)_checkMicrophoneAuthorizationAndStart {
    if (_videoCaptureStep.isAudioMute) {
        [self _startCaptureSession];
        return;
    }

    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (audioStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self _startCaptureSession];
                    } else {
                        [self _handleDeniedMicrophoneAccess];
                    }
                });
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self _startCaptureSession];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        default: {
            [self _handleDeniedMicrophoneAccess];
            break;
        }
    }
}

- (void)_startCaptureSession {
    _videoCaptureView.hidden = NO;
    dispatch_async(_sessionQueue, ^{
        [self queue_SetupCaptureSession];
        [self->_captureSession startRunning];
    });
}

- (void)_handleDeniedCameraAccess {
    BOOL microphoneDenied = NO;
    if (!_videoCaptureStep.isAudioMute) {
        AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        microphoneDenied = (audioStatus == AVAuthorizationStatusDenied || audioStatus == AVAuthorizationStatusRestricted);
    }

    if (microphoneDenied) {
        self.step.authDeniedContext = [[ORKCaptureAccessDeniedContext alloc]
                                       initWithTitle:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_TITLE_CAMERA_AND_MIC", nil)
                                       text:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_CAMERA_AND_MIC_TEXT", nil)
                                       settingsLinkText:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_SETTINGS_LINK_TEXT", nil)
                                       completionStepIdentifier:@"ORKVideoCaptureStepIdentifierVideoAccessDeniedCompletion"
                                       learnMoreStepIdentifier:@"ORKVideoCaptureStepIdentifierInstructionStepPlaceHolderVideoAccessDenied"
                                       iconImage:[UIImage systemImageNamed:@"video.slash"]];
    }

    ORKTaskViewController *taskVC = self.taskViewController;
    if (taskVC != nil &&
        [taskVC.task isKindOfClass:[ORKNavigableOrderedTask class]] &&
        self.step.authDeniedContext != nil) {
        [self _tearDownVideoCaptureView];
        [taskVC handleDeniedAuthForStep:self.step];
    } else {
        [self _showAccessDeniedCompletionStep];
    }
}

- (void)_handleDeniedMicrophoneAccess {
    self.step.authDeniedContext = [[ORKCaptureAccessDeniedContext alloc]
                                   initWithTitle:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_TITLE_MIC", nil)
                                   text:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_MIC_TEXT", nil)
                                   settingsLinkText:ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_SETTINGS_LINK_TEXT", nil)
                                   completionStepIdentifier:@"ORKVideoCaptureStepIdentifierVideoAccessDeniedCompletion"
                                   learnMoreStepIdentifier:@"ORKVideoCaptureStepIdentifierInstructionStepPlaceHolderVideoAccessDenied"
                                   iconImage:[UIImage systemImageNamed:@"mic.slash"]];

    ORKTaskViewController *taskVC = self.taskViewController;
    if (taskVC != nil &&
        [taskVC.task isKindOfClass:[ORKNavigableOrderedTask class]]) {
        [self _tearDownVideoCaptureView];
        [taskVC handleDeniedAuthForStep:self.step];
    } else {
        [self _showAccessDeniedCompletionStep];
    }
}

- (void)_tearDownVideoCaptureView {
    [_videoCaptureView.playerViewController willMoveToParentViewController:nil];
    [_videoCaptureView.playerViewController removeFromParentViewController];
    [_videoCaptureView removeFromSuperview];
    _videoCaptureView = nil;
}

- (void)_showAccessDeniedCompletionStep {
    [self _tearDownVideoCaptureView];
    ORKCompletionStep *completionStep;
    if (self.step.authDeniedContext != nil) {
        completionStep = [self.step.authDeniedContext authDeniedCompletionStep];
    } else {
        completionStep = [[ORKCompletionStep alloc] initWithIdentifier:@"ORKVideoCaptureAccessDeniedFallback"];
        completionStep.title = ORKLocalizedString(@"VIDEO_CAPTURE_ACCESS_DENIED_TITLE", nil);
        completionStep.text = ORKLocalizedString(@"CAPTURE_ERROR_NO_PERMISSIONS", nil);
        completionStep.reasonForCompletion = ORKTaskFinishReasonFailed;
        completionStep.iconImage = [UIImage systemImageNamed:@"video.slash"];
    }

    ORKCompletionStepViewController *completionVC = [[ORKCompletionStepViewController alloc] initWithStep:completionStep];
    [self addChildViewController:completionVC];
    completionVC.view.frame = self.view.bounds;
    completionVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:completionVC.view];
    [completionVC didMoveToParentViewController:self];
}

- (void)queue_SetupCaptureSession {
    // Create the session
    _captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];
        
    // Get the camera
    AVCaptureDevice *device;
    
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:_videoCaptureStep.devicePosition ? : AVCaptureDevicePositionBack];

    if (discoverySession.devices.count > 0) {
        device = discoverySession.devices[0];
    }
    
    if (device) {
        // Check if the device has the requested torchMode
        if([device isTorchModeSupported:_videoCaptureStep.torchMode]){
            [device lockForConfiguration:nil];
            device.torchMode = _videoCaptureStep.torchMode;
            [device unlockForConfiguration];
        }
        
        // Configure the input and output
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        AVCaptureMovieFileOutput *movieFileOutput = [AVCaptureMovieFileOutput new];
        movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(_videoCaptureStep.duration.floatValue, 30.0);
        
        if ([_captureSession canAddInput:input] && [_captureSession canAddOutput:movieFileOutput]) {
            [_captureSession addInput:input];
            [_captureSession addOutput:movieFileOutput];
            
            if (!_videoCaptureStep.audioMute) {
                AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
                AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
                if (audioInput && [_captureSession canAddInput:audioInput]) {
                    [_captureSession addInput:audioInput];
                }
            }
            _movieFileOutput = movieFileOutput;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_NO_PERMISSIONS", nil)}]];
            });
            _captureSession = nil;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_CAMERA_NOT_FOUND", nil)}]];
        });
        _captureSession = nil;
    }
    
    
    [_captureSession commitConfiguration];
    
    _videoCaptureView.session = _captureSession;
}

- (void)handleError:(NSError *)error {
    // Shut down the session, if running
    if (_captureSession.isRunning) {
        ORKStrongTypeOf(_captureSession) strongCaptureSession = _captureSession;
        dispatch_async(_sessionQueue, ^{
            [strongCaptureSession stopRunning];
        });
    }
    
    // Reset the state to before the capture session was setup.  Order here is important
    _captureSession = nil;
    _movieFileOutput = nil;
    _videoCaptureView.session = nil;
    _videoCaptureView.videoFileURL = nil;
    _fileURL = nil;

    [self _showAccessDeniedCompletionStep];
}

- (void)setFileURL:(NSURL *)fileURL {
    _fileURL = fileURL;
    _videoCaptureView.videoFileURL = fileURL;
    
    [self notifyDelegateOnResultChange];
}

- (void)setRecording:(BOOL)recording {
    _recording = recording;
    _videoCaptureView.recording = recording;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKFileResult *fileResult = [[ORKFileResult alloc] initWithIdentifier:self.step.identifier];
    fileResult.startDate = stepResult.startDate;
    fileResult.endDate = now;
    fileResult.contentType = @"video/mp4";
    fileResult.fileURL = _fileURL;
    fileResult.fileName = [_fileURL lastPathComponent];
    [results addObject:fileResult];
    stepResult.results = [results copy];
    return stepResult;
}


#pragma mark - ORKVideoCaptureViewDelegate

- (void)retakePressed:(void (^)(void))handler {
    dispatch_async(_sessionQueue, ^{
        [_captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fileURL = nil;
            if (handler) {
                handler();
            }
        });
    });
}

- (void)capturePressed:(void (^)(void))handler {
    // Capture the video via the output
    dispatch_async(_sessionQueue, ^{
        _fileURL = [self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.step.identifier]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_fileURL.path]) {
            [fileManager removeItemAtURL:_fileURL error:nil];
        }
        AVCaptureConnection *connection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if (connection.isActive) {
            [_movieFileOutput startRecordingToOutputFileURL:_fileURL
                                          recordingDelegate:self];
            
            // Use the main queue, as UI components may need to be updated
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler();
                }
            });
        }
        else {
            ORK_Log_Info("Connection not ready");
            // Use the main queue, as UI components may need to be updated
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler();
                }
                 [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_NO_PERMISSIONS", nil)}]];
                
            });
        }
    });
}

- (void)stopCapturePressed:(void (^)(void))handler {
    if (_movieFileOutput.recording) {
    dispatch_async(_sessionQueue, ^{
        [_movieFileOutput stopRecording];
        
        // Use the main queue, as UI components may need to be updated
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler();
            }
        });
    });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler();
            }
        });
    }
}


#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
    self.recording = YES;
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    if (error && !error.userInfo[AVErrorRecordingSuccessfullyFinishedKey]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:error];
        });
        return;
    }

    NSError *protectionError = nil;
    if (![[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: ORKFileProtectionFromMode(self.fileProtectionMode)}
                                          ofItemAtPath:[outputFileURL path]
                                                 error:&protectionError]) {
        ORK_Log_Error("Error setting file protection on %@: %@", outputFileURL, protectionError);
    }

    self.recording = NO;
    self.fileURL = outputFileURL;
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, ORKLocalizedString(@"AX_VIDEO_CAPTURE_COMPLETE", nil));
    }
}

@end
