/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <CoreImage/CoreImage.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ORKActiveStepView.h"
#import "ORKActiveStepViewController_Internal.h"
#import "ORKBorderedButton.h"
#import "ORKCollectionResult_Private.h"
#import "ORKFrontFacingCameraStep.h"
#import "ORKFrontFacingCameraStepContentView.h"
#import "ORKFrontFacingCameraStepResult.h"
#import "ORKFrontFacingCameraStepViewController.h"
#import "ORKHelpers_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKResult_Private.h"
#import "ORKStepContainerView_Private.h"
#import "ORKStepViewController_Internal.h"

@interface ORKFrontFacingCameraStepViewController () <AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) ORKFrontFacingCameraStepContentView *contentView;

@end

@implementation ORKFrontFacingCameraStepViewController {
    NSMutableArray *_results;
    
    ORKFrontFacingCameraStep *_frontFacingCameraStep;
    
    AVCaptureMovieFileOutput *_movieFileOutput;
    
    NSURL *_tempOutputURL;
    NSURL *_savedFileURL;
    
    NSString *_savedFileName;
    
    AVCaptureDevice *_frontCameraCaptureDevice;
    AVCaptureSession *_captureSession;
    
    NSInteger retryCount;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    
    if (self) {
        retryCount = 0;
        _frontFacingCameraStep = (ORKFrontFacingCameraStep *)step;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _results = [NSMutableArray new];
    
    [self setupContentView];
    [self setupConstraints];
    [self startSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_contentView layoutSubviews];
}

- (void)handleError:(NSError *)error {
    // Shut down the session, if running
    if (_captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    
    // Reset the state to before the capture session was setup.  Order here is important
    _captureSession = nil;
    _movieFileOutput = nil;
    _tempOutputURL = nil;
    _savedFileURL = nil;
    
    // Handle error in the UI.
    [_contentView handleError:error];
}

- (void)stepDidFinish {
    [super stepDidFinish];

    if (_tempOutputURL) {
        [self deleteTempVideoFile];
    }
   
    [self goForward];
}

- (void)setupContentView {
    _contentView = [[ORKFrontFacingCameraStepContentView alloc] initWithTitle:_frontFacingCameraStep.title text:_frontFacingCameraStep.text];
    _contentView.layer.cornerRadius = 10.0;
    _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    _contentView.clipsToBounds = YES;
    __weak typeof(self) weakSelf = self;
    [_contentView setViewEventHandler:^(ORKFrontFacingCameraStepContentViewEvent event) {
        [weakSelf handleContentViewEvent:event];
    }];
    
    [self.view addSubview:_contentView];
}

- (void)handleContentViewEvent:(ORKFrontFacingCameraStepContentViewEvent)event {
    
    switch (event)
    {
        case ORKFrontFacingCameraStepContentViewEventStartRecording:
            [self startVideoRecording];
            break;
            
        case ORKFrontFacingCameraStepContentViewEventStopRecording:
            [self stopVideoRecording];
            break;
            
        case ORKFrontFacingCameraStepContentViewEventReviewRecording:
        {
            AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:_tempOutputURL];
            AVPlayer *playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
            playerViewController.player = playVideo;
            playerViewController.player.volume = 1.0;
            [self presentViewController:playerViewController animated:YES completion:nil];
            [playVideo play];
            break;
        }
        case ORKFrontFacingCameraStepContentViewEventRetryRecording:
            [self deleteTempVideoFile];
            retryCount++;
            break;
            
        case ORKFrontFacingCameraStepContentViewEventSubmitRecording:
        {
            [self submitVideo];
            break;
        }
        case ORKFrontFacingCameraStepContentViewEventError:
            break;
    }
}

-(void)setupConstraints {
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_contentView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[_contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[_contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[_contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)startSession
{
    _captureSession = [AVCaptureSession new];
    
    _frontCameraCaptureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    if (_frontCameraCaptureDevice)
    {
        NSError *error = nil;
        
        AVCaptureDevice *captureAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontCameraCaptureDevice error:&error];
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:captureAudioDevice error:&error];
        [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeVideoRecording options:0 error:&error];
        
        if (error) {
            [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_CAMERA_NOT_FOUND", nil)}]];
            return;
        }
        
        [_captureSession beginConfiguration];
        
        if ([_captureSession canAddInput:deviceInput]) {
            [_captureSession addInput:deviceInput];
        }
        
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        }
        
        if ([_captureSession canAddInput:audioInput]) {
            [_captureSession addInput:audioInput];
        }
        
        _movieFileOutput = [AVCaptureMovieFileOutput new];
        if ([_captureSession canAddOutput:_movieFileOutput]) {
            [_captureSession addOutput:_movieFileOutput];
            AVCaptureConnection *captureConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            
            if (captureConnection && [captureConnection isVideoStabilizationSupported]) {
                captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
        
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [output setVideoSettings:videoSettings];
        output.alwaysDiscardsLateVideoFrames = YES;
        
        if ([_captureSession canAddOutput:output]) {
            [_captureSession addOutput:output];
        }
        
        AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }
        
        if ([connection isVideoMirroringSupported]) {
            [connection setVideoMirrored:NO];
        }
        
        [_captureSession commitConfiguration];
        
        dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
        dispatch_queue_t recordingQueue = dispatch_queue_create("output.queue", qos);
        
        [output setSampleBufferDelegate:self queue:recordingQueue];
        
        [_contentView setPreviewLayerWithSession:_captureSession];
        
        [_captureSession startRunning];
    }
    
    [_contentView layoutSubviews];
}

- (void)startVideoRecording {
    if (![_movieFileOutput isRecording]) {
         
        AVCaptureConnection *movieFileOutputConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        [movieFileOutputConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        NSArray<AVVideoCodecType> *availableVideoCodecTypes = _movieFileOutput.availableVideoCodecTypes;
        
        if (availableVideoCodecTypes && [availableVideoCodecTypes containsObject:AVVideoCodecTypeHEVC]) {
            NSString* key = (NSString*)AVVideoCodecKey;
            NSString* value = (NSString*)AVVideoCodecTypeHEVC;
            NSDictionary* outputSettings = [NSDictionary dictionaryWithObject:value forKey:key];
            [_movieFileOutput setOutputSettings:outputSettings forConnection:movieFileOutputConnection];
        }
        
        // Start recording to a temporary file.
        NSString *tempVideoFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID new].UUIDString] stringByAppendingPathExtension:@"mov"];
        [_movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:tempVideoFilePath] recordingDelegate:self];
    }
    
    [_contentView layoutSubviews];
}

- (void)stopVideoRecording {
    if (_movieFileOutput && [_movieFileOutput isRecording]) {
        [_movieFileOutput stopRecording];
    }
}

- (void)submitVideo {
    if ([self tempVideoFileExists])
    {
        //Save video to permanant file
        NSString *outputFileName = [NSUUID new].UUIDString;
        _savedFileName = [outputFileName stringByAppendingPathExtension:@"mov"];
        
        NSURL *docURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
        docURL = [docURL URLByAppendingPathComponent:_savedFileName];
        
        NSData *data = [NSData dataWithContentsOfURL:_tempOutputURL];
        BOOL wasDataSavedToURL = [data writeToURL:docURL atomically:YES];
        
        if (wasDataSavedToURL)
        {
            //remove video saved to temp directory if it was saved successfully in the document directory
            _savedFileURL = docURL;
            [self deleteTempVideoFile];
            [self finish];
        }
    }
}

- (BOOL)tempVideoFileExists {
    if (_tempOutputURL && [NSFileManager.defaultManager fileExistsAtPath:_tempOutputURL.relativePath]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)deleteTempVideoFile {
    if ([self tempVideoFileExists]) {
        NSError *error;
        
        [NSFileManager.defaultManager removeItemAtPath:_tempOutputURL.relativePath error:&error];
        
        if (!error) {
            _tempOutputURL = nil;
        } else {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"There was an error encountered while attempting to remove the saved video from the temp directory at path: %@", _tempOutputURL.path]  userInfo:nil];
        }
    } else if (_tempOutputURL) {
        _tempOutputURL = nil;
    }
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKFrontFacingCameraStepResult *frontFacingCameraResult = [[ORKFrontFacingCameraStepResult alloc] initWithIdentifier:self.step.identifier];
    frontFacingCameraResult.startDate = stepResult.startDate;
    frontFacingCameraResult.endDate = now;
    frontFacingCameraResult.contentType = @"video/quicktime";
    frontFacingCameraResult.fileURL = _savedFileURL;
    frontFacingCameraResult.retryCount = retryCount;

    [results addObject:frontFacingCameraResult];
    stepResult.results = [results copy];
    return stepResult;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate methods

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    
    [_contentView startTimerWithMaximumRecordingLimit:_frontFacingCameraStep.maximumRecordingLimit];
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if (!error)
    {
        _tempOutputURL = outputFileURL;
        [_contentView presentReviewOptionsAllowingReview:_frontFacingCameraStep.allowsReview
                                              allowRetry:_frontFacingCameraStep.allowsRetry];
        
        if (!_frontFacingCameraStep.allowsRetry && !_frontFacingCameraStep.allowsReview) {
            [self submitVideo];
        }
    }
}

@end
