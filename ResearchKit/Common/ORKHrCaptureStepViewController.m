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
#import "ORKHrCaptureStepViewController.h"
#import "ORKHrCaptureView.h"
#import "ORKHrCaptureStep.h"
#import "ORKHelpers_Internal.h"
#import "ORKFFTUtils.h"
#import <AVFoundation/AVFoundation.h>


@interface ORKHrCaptureStepViewController () <ORKHrCaptureViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIApplicationDelegate>

@end


@implementation ORKHrCaptureStepViewController {
    ORKHrCaptureView *_hrCaptureView;
    ORKHrCaptureStep *_hrCaptureStep;
    ORKFFTUtils *_fftUtils; // Calculates HR from a signal using FFT approach
    dispatch_queue_t _sessionQueue; // Runs the capture session
    AVCaptureSession *_captureSession; // The capture session itself
    NSTimer *_hrTimer; // Definies the intervals on which the HR should be calculated
    NSMutableArray *_ppgSamples; // Holds the green values (RGB) that represents the ppg signal
    BOOL _recording; // Control variable to show/hide buttons
    UILabel *_hrLbl;
    NSMutableArray *_collectedHrValues;
    AVCaptureDevice *_device;
}

- (instancetype)initWithStep:(ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {
        _fftUtils = [[ORKFFTUtils alloc]init];
        _ppgSamples = [[NSMutableArray alloc] init];
        _hrCaptureView = [[ORKHrCaptureView alloc] initWithFrame:CGRectZero];
        _hrCaptureView.hrCaptureStep = (ORKHrCaptureStep *)step;
        _hrCaptureView.delegate = self;
        _collectedHrValues = [[NSMutableArray alloc] init];
        _hrCaptureView.capturedHr = NO;
        [self.view addSubview:_hrCaptureView]; // This is our step view. The step title and back buttons are from parent
        
        _hrCaptureStep = (ORKHrCaptureStep *)self.step;
        
        [self setUpConstraints];
    }
    
    return self;
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = @{ @"hrCaptureView": _hrCaptureView };
    _hrCaptureView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hrCaptureView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hrCaptureView]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

// My videCaptureView must have continue and skip buttons that follows parent's behavior
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _hrCaptureView.continueButtonItem = continueButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    [super setSkipButtonItem:skipButtonItem];
    _hrCaptureView.skipButtonItem = skipButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Capture actions should be performed off the main queue to keep the UI responsive
    _sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    
    // Setup the capture session
    dispatch_async(_sessionQueue, ^{
        [self queue_SetupCaptureSession]; // Prepares the captureSession information to be run in this queue
    });
    
    // Prepare notification for when the app enters to background and stop any timer
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationEnterFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)applicationEnterFromBackground:(NSNotification *)notification {
    
    // Restore session when entering from background
    if (!_captureSession.isRunning) {
        dispatch_async(_sessionQueue, ^{
            [_captureSession startRunning];
            [self setSamplingRate];
        });
    }
}

-(void)applicationEnterBackground:(NSNotification *)notification {
    [self stopSession];
}

// Securely stops the session taking care of the timers
-(void)stopSession {
    // Stop every timer before going background
    
    // If the capture session is running, stop it
    if (_captureSession.isRunning) {
        dispatch_async(_sessionQueue, ^{
            [_captureSession stopRunning];
        });
    }
    
    // Drop everything since the current HR will no longer be valid
    [self triggerHRCalculationTimer:NO];
    _hrCaptureView.capturedHr = NO;
    [_collectedHrValues removeAllObjects];
    [_ppgSamples removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(_sessionQueue, ^{
        [_captureSession startRunning]; // Start the capture session that has already been setted trough viewDidLoad
        [self setSamplingRate];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopSession];
}

-(void)setSamplingRate {
    // Make sure the sampling rate for the video recording is the one we want. Defaults to 30
    [_device lockForConfiguration:nil];
    _device.activeVideoMinFrameDuration = CMTimeMake(1, SamplingRate);
    _device.activeVideoMaxFrameDuration = CMTimeMake(1, SamplingRate);
    [_device unlockForConfiguration];
}

- (void)queue_SetupCaptureSession {
    // Create the session
    _captureSession = [AVCaptureSession new];
    [_captureSession beginConfiguration];
    
    // Get the camera
    AVCaptureDevice *device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *d in devices) {
        if (d.position == AVCaptureDevicePositionBack) { // Make sure we use the back camera
            device = d;
            break;
        }
    }
    
    if (device) {
        
        // Configure the input and output
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new] ;
        
        if ([_captureSession canAddInput:input] && [_captureSession canAddOutput:output]) {
            
            [_captureSession addInput:input];
            [_captureSession addOutput:output];
            
            [output setSampleBufferDelegate:self queue:_sessionQueue];
            
            // Specify the pixel format
            output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_NO_PERMISSIONS", nil)}]];
            });
            _captureSession = nil;
        }
        
        _device = device;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFeatureUnsupportedError userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"CAPTURE_ERROR_CAMERA_NOT_FOUND", nil)}]];
        });
        _captureSession = nil;
    }
    
    [_captureSession commitConfiguration];
    _hrCaptureView.session = _captureSession;
}

- (void)handleError:(NSError *)error {
    
    // Shut down the session, if running
    if (_captureSession.isRunning) {
        [self stopSession];
    }
    
    // Reset the state to before the capture session was setup.  Order here is important
    _captureSession = nil;
    _hrCaptureView.session = nil;
    
    // Show the error in the image capture view
    _hrCaptureView.error = error;
}

- (void)setRecording:(BOOL)recording {
    _recording = recording;
    _hrCaptureView.recording = recording;
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    ORKResult *result = [[ORKResult alloc] init];
    
    // Retrieve only the HR after the first 5 measurements (about 5 secs)
    // The first seconds are usually very noisy and are not accurate
    NSArray *hrValues = [_collectedHrValues copy];
    NSInteger hrNum = [_collectedHrValues count];
    
    if (hrNum > 5) {
        hrValues = [_collectedHrValues subarrayWithRange:NSMakeRange(5, hrNum - 5)];
    }
    
    NSDate *now = stepResult.endDate;
    NSMutableArray *results = [NSMutableArray arrayWithArray:stepResult.results];
    result.startDate = stepResult.startDate;
    result.endDate = now;
    result.userInfo = @{@"collectedHrValues": hrValues};
    result.identifier = @"hrResults";
    [results addObject:result];
    stepResult.results = [results copy];
    return stepResult;
}


#pragma mark - ORKHrCaptureViewDelegate

- (void)retakePressed:(void (^)())handler {
    dispatch_async(_sessionQueue, ^{
        
        if (!_recording) {// Init and start timer that applies fft and shows result in view
            
            [self triggerHRCalculationTimer:YES];
            
            // Drop previous PPG and HR
            [_collectedHrValues removeAllObjects];
            [_ppgSamples removeAllObjects];
            _hrCaptureView.capturedHr = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler();
            }
        });
    });
}

- (void)capturePressed:(void (^)())handler {
    // Capture the video via the output
    dispatch_async(_sessionQueue, ^{
        
        if (!_recording) {// Init and start timer that applies fft and shows result in view
            [self triggerHRCalculationTimer:YES];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler();
            }
        });
    });
}

- (void)setHrLbl:(UILabel *)hrLbl {
    _hrLbl = hrLbl;
}

- (void)stopCapturePressed:(void (^)())handler {
    
    dispatch_async(_sessionQueue, ^{
        [self stopHrEstimation];
        _hrCaptureView.capturedHr = NO;
        [_collectedHrValues removeAllObjects];
        [_ppgSamples removeAllObjects];
        
        // Use the main queue, as UI components may need to be updated
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler();
            }
        });
    });
}

- (void)stopHrEstimation {
    [self triggerHRCalculationTimer:NO];
}

- (void)getHR {
    
    int currentNumberSamples = (int) [_ppgSamples count];
    float currentHr = 0.0;
    
    // Start calculating as soon as we have enough samples
    if (currentNumberSamples >= FftMinSamplesN) {
        // Only attempt to get FFT if we have enough samples
        currentHr = [_fftUtils getHrFromPpg:_ppgSamples];
        _hrLbl.text = [NSString stringWithFormat:@"%d", (int) roundf(currentHr)];
        [_collectedHrValues addObject:@(roundf(currentHr))];
    }
    
}

-(void)triggerHRCalculationTimer:(BOOL) start {
    
    if (start) {// Init and start timer that gets HR every FftBpmEstimationFrequency seconds
        
        // Creating fft timer in the main thread
        
        // Turn LED on if present
        [self turnLedOn:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _hrTimer = [NSTimer scheduledTimerWithTimeInterval:FftCalculationFrequency
                                                        target:self
                                                      selector:@selector(getHR)
                                                      userInfo:nil
                                                       repeats:YES];
            
            self.recording = YES;
            _recording = YES;
            _hrCaptureView.capturedHr = NO;
            
        });
        
    } else {// Stop timer
        
        if (_hrTimer != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_hrTimer invalidate];
                _hrTimer = nil;
                self.recording = NO;
                _recording = NO;
                if ([_collectedHrValues count] > 0) {
                    _hrCaptureView.capturedHr = YES;
                }
                
            });
            
        }
        // Turn LED off if present
        [self turnLedOn:NO];
        
    }
    
}

- (void) turnLedOn: (BOOL) value {
    
    if (value) {
        if ([_device isTorchModeSupported:AVCaptureTorchModeOn]) {
            [_device lockForConfiguration:nil];
            _device.torchMode = AVCaptureTorchModeOn;
            [_device unlockForConfiguration];
        }
    } else {
        if ([_device isTorchModeSupported:AVCaptureTorchModeOff]) {
            [_device lockForConfiguration:nil];
            _device.torchMode = AVCaptureTorchModeOff;
            [_device unlockForConfiguration];
        }
    }
    
}

// Gets the PPG value (green mean on the center) per frame
- (float) getPpgSampleFromSampleBufferWith:(CMSampleBufferRef) sampleBuffer {
    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Getting center values
    int centerX, centerY, centerW, centerH;
    
    centerX = (int) (width / 3);
    centerY = (int) (height / 3);
    centerW = centerX;
    centerH = centerY;
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    float centerGreenMean = 0.0; // Holds the mean in the specified frame for green color
    float pixelsNum = 0.0;
    
    UInt32 * currentPixel = baseAddress;
    currentPixel += centerY * width + centerX; // x from starting point, considering a box from the top left corner;
    
    // Getting the center pixels
    for (NSUInteger j = centerY; j < centerY + centerH; j++) {// From left corner to the righ and then down
        for (NSUInteger i = centerX; i < centerX + centerW; i++) {
            UInt32 color = *currentPixel;
            pixelsNum++;
            centerGreenMean += [_fftUtils getGreen:color];
            currentPixel++;
        }
        currentPixel = currentPixel + (width - (centerX + centerW)) + centerX - 1;
    }
    centerGreenMean /= pixelsNum; // Center mean
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    float a = -1;// Apply inverse
    float b = 256;
    
    return centerGreenMean * a + b; // To get a proper PPG signal
}

- (void)videoOrientationDidChange:(AVCaptureVideoOrientation)videoOrientation {
    // No action required
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    // Getting the mean green color in a centered frame
    float ppgSample = [self getPpgSampleFromSampleBufferWith:sampleBuffer];
    
    dispatch_async(dispatch_get_main_queue(), ^{// Add the data on the main thread, so it follows an order
        
        if ((int) [_ppgSamples count] >= FftMaxSamplesN) {
            
            // Maintain the array small
            [_ppgSamples removeObjectAtIndex:0];
        }
        
        [_ppgSamples addObject:[NSNumber numberWithFloat:ppgSample]];
    });
    
}

@end
