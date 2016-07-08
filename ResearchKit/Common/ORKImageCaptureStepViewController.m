/*
 Copyright (c) 2015, Bruce Duncan. All rights reserved.
 
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
#import "ORKImageCaptureStepViewController.h"
#import "ORKImageCaptureView.h"
#import "ORKHelpers.h"
#import <AVFoundation/AVFoundation.h>


@interface ORKImageCaptureStepViewController () <ORKImageCaptureViewDelegate>

@end


@implementation ORKImageCaptureStepViewController {
    ORKImageCaptureView *_imageCaptureView;
    dispatch_queue_t _sessionQueue;
    AVCaptureSession *_captureSession;
    AVCaptureStillImageOutput *_stillImageOutput;
    NSData *_capturedImageData;
    NSURL *_fileURL;
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [self initWithStep:step];
    if (self) {
        ORKStepResult *stepResult = (ORKStepResult *)result;
        if (stepResult && [stepResult results].count > 0) {
            
            ORKFileResult *fileResult = ORKDynamicCast([stepResult results].firstObject, ORKFileResult);

            if (fileResult.fileURL) {
                // Setting these properties in this order allows us to reuse the existing file on disk
                self.capturedImageData = [NSData dataWithContentsOfURL:fileResult.fileURL];
                _fileURL = fileResult.fileURL;
            }
        }
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        _imageCaptureView = [[ORKImageCaptureView alloc] initWithFrame:CGRectZero];
        _imageCaptureView.imageCaptureStep = (ORKImageCaptureStep *)step;
        _imageCaptureView.delegate = self;
        [self.view addSubview:_imageCaptureView];
        
        _imageCaptureView.translatesAutoresizingMaskIntoConstraints = NO;
        [self setUpConstraints];
    }
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = @{ @"imageCaptureView": _imageCaptureView };
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageCaptureView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageCaptureView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _imageCaptureView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _imageCaptureView.skipButtonItem = skipButtonItem;
}

- (void)retakePressed:(void (^)())handler {
    // Start the capture session, and reset the captured image to nil
    dispatch_async(_sessionQueue, ^{
        [_captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.capturedImageData = nil;
            if (handler) {
                handler();
            }
        });
    });
}

- (void)capturePressed:(void (^)(BOOL))handler {
    // Capture the image via the output
    dispatch_async(_sessionQueue, ^{
    	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:[_stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            [self queue_CaptureImageFromData:imageDataSampleBuffer handler:handler];
    	}];
    });
}

- (void)videoOrientationDidChange:(AVCaptureVideoOrientation)videoOrientation {
    // Keep the output orientation in sync with the input orientation
    ((AVCaptureConnection *)_stillImageOutput.connections[0]).videoOrientation = videoOrientation;
}

- (void)queue_CaptureImageFromData:(CMSampleBufferRef)imageDataSampleBuffer handler:(void (^)(BOOL))handler {
    // Capture the JPEG image data, if available
    NSData *capturedImageData = !imageDataSampleBuffer ? nil : [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
    // If something was captured, stop the capture session
    if (capturedImageData) {
        [_captureSession stopRunning];
    }
    
    // Use the main queue, as UI components may need to be updated
    dispatch_async(dispatch_get_main_queue(), ^{
        // Set this, even if there was an error and we got a nil buffer
        self.capturedImageData = capturedImageData;
        if (handler) {
            handler(capturedImageData != nil);
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Capture actions should be performed off the main queue to keep the UI responsive
    _sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    // Setup the capture session
    dispatch_async(_sessionQueue, ^{
        [self queue_SetupCaptureSession];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // If we don't already have a captured image, then start the capture session running
    if (!_capturedImageData) {
        dispatch_async(_sessionQueue, ^{
            [_captureSession startRunning];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // If the capture session is running, stop it
    if (_captureSession.isRunning) {
        dispatch_async(_sessionQueue, ^{
            [_captureSession stopRunning];
        });
    }
    
    [super viewWillDisappear:animated];
}

- (void)queue_SetupCaptureSession {
    // Create the session
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession beginConfiguration];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Get the camera
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // Configure the input and output
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_captureSession canAddInput:input] && [_captureSession canAddOutput:stillImageOutput]) {
            [_captureSession addInput:input];
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey: AVVideoCodecJPEG}];
            [_captureSession addOutput:stillImageOutput];
            _stillImageOutput = stillImageOutput;
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
    
    _imageCaptureView.session = _captureSession;
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
    _stillImageOutput = nil;
    _imageCaptureView.session = nil;
    _imageCaptureView.capturedImage = nil;
    _capturedImageData = nil;
    _fileURL = nil;
    
    // Show the error in the image capture view
    _imageCaptureView.error = error;
}

- (void)setCapturedImageData:(NSData *)capturedImageData {
    _capturedImageData = capturedImageData;
    _imageCaptureView.capturedImage = capturedImageData ? [UIImage imageWithData:capturedImageData] : nil;
    
    // Remove the old file, if it exists, now that new data was acquired or reset
    if (_fileURL) {
        [[NSFileManager defaultManager] removeItemAtURL:_fileURL error:nil];
        // Force the file to be rewritten the next time the result is requested
        _fileURL = nil;
    }
    
    [self notifyDelegateOnResultChange];
}

- (NSURL *)writeCapturedDataWithError:(NSError **)error {
    NSURL *URL = [self.outputDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.step.identifier]];
    // Confirm the outputDirectory was set properly
    if (!URL) {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteInvalidFileNameError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_NO_OUTPUT_DIRECTORY", nil)}];
        }
        return nil;
    }
    
    // If set properly, the outputDirectory is already created, so write the file into it
    NSError *writeError = nil;
    if (![_capturedImageData writeToURL:URL options:NSDataWritingAtomic|NSDataWritingFileProtectionCompleteUnlessOpen error:&writeError]) {
        if (writeError) {
            ORK_Log_Warning(@"%@", writeError);
        }
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteInvalidFileNameError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_CANNOT_WRITE_FILE", nil)}];
        }
        return nil;
    }
    
    return URL;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    // If we have captured data, but have not yet written that data to a file, do it now
    if (!_fileURL && _capturedImageData) {
        NSError *error = nil;
        _fileURL = [self writeCapturedDataWithError:&error];
        if (error) {
            [self handleError:error];
        }
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    ORKFileResult *fileResult = [[ORKFileResult alloc] initWithIdentifier:self.step.identifier];
    fileResult.startDate = stepResult.startDate;
    fileResult.endDate = now;
    fileResult.contentType = @"image/jpeg";
    fileResult.fileURL = _fileURL;
    [results addObject:fileResult];
    stepResult.results = [results copy];
    return stepResult;
}

@end
