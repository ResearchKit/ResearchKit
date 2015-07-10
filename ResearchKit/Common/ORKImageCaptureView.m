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


#import "ORKImageCaptureView.h"
#import "ORKImageCaptureCameraPreviewView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"
#import "ORKStepHeaderView_Internal.h"


@implementation ORKImageCaptureView {
    ORKStepHeaderView *_headerView;
    ORKImageCaptureCameraPreviewView *_previewView;
    ORKNavigationContainerView *_continueSkipContainer;
    UIBarButtonItem *_captureButtonItem;
    UIBarButtonItem *_recaptureButtonItem;
    NSMutableArray *_variableConstraints;
    
    BOOL _capturePressesIgnored;
    BOOL _retakePressesIgnored;
    BOOL _showSkipButtonItem;
}

- (instancetype)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        _previewView = [[ORKImageCaptureCameraPreviewView alloc] init];
        [self addSubview:_previewView];
        
        _headerView = [[ORKStepHeaderView alloc] init];
        _headerView.alpha = 0;
        [self addSubview:_headerView];
        
        _captureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_IMAGE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(capturePressed)];
        _recaptureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_RECAPTURE_IMAGE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(retakePressed)];
        
        _continueSkipContainer = [ORKNavigationContainerView new];
        _continueSkipContainer.continueEnabled = YES;
        _continueSkipContainer.topMargin = 5;
        _continueSkipContainer.bottomMargin = 15;
        _continueSkipContainer.optional = YES;
        _continueSkipContainer.backgroundColor = ORKColor(ORKBackgroundColorKey);
        [self addSubview:_continueSkipContainer];
        
        NSDictionary *dictionary = NSDictionaryOfVariableBindings(self, _previewView, _continueSkipContainer, _headerView);
        ORKEnableAutoLayoutForViews([dictionary allValues]);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queue_sessionRunning) name:AVCaptureSessionDidStartRunningNotification object:nil];
        
        [self updateAppearance];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)queue_sessionRunning {
    dispatch_async(dispatch_get_main_queue(), ^{
        _previewView.templateImageHidden = NO;
    });
}

- (void)orientationDidChange {
    AVCaptureVideoOrientation orientation;
    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
        case UIInterfaceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationUnknown:
            // Do nothing in these cases, since we don't need to change display orientation.
            return;
    }
    [_previewView setVideoOrientation:orientation];
    [self.delegate videoOrientationDidChange:orientation];
    [self setNeedsUpdateConstraints];
}

- (void)setImageCaptureStep:(ORKImageCaptureStep *)imageCaptureStep {
    _imageCaptureStep = imageCaptureStep;
    
    _previewView.templateImage = imageCaptureStep.templateImage;
    _previewView.templateImageInsets = imageCaptureStep.templateImageInsets;
    _showSkipButtonItem = imageCaptureStep.optional;
}

- (void)updateAppearance {
    if (self.error) {
        // Hide the template image if there is an error
        _previewView.templateImageHidden = YES;
        
        // Show skip, if available, and hide the template and continue/capture button
        _continueSkipContainer.continueButtonItem = nil;
        _continueSkipContainer.skipButtonItem = _skipButtonItem;
    } else if (self.capturedImage) {
        // Hide the template image after capturing
        _previewView.templateImageHidden = YES;

        // Set the continue button to the one we've saved and configure the skip button as a recapture button
        _continueSkipContainer.continueButtonItem = _continueButtonItem;
        _continueSkipContainer.skipButtonItem = _recaptureButtonItem;
    } else {
        // Show the template image during capturing
        _previewView.templateImageHidden = NO;
    
        // Change the continue button back to capture, and change the recapture button back to skip (if available)
        _continueSkipContainer.continueButtonItem = _captureButtonItem;
        _continueSkipContainer.skipButtonItem = _skipButtonItem;
    }
}

- (void)setCapturedImage:(UIImage * __nullable)capturedImage {
    _previewView.capturedImage = capturedImage;
    [self updateAppearance];
}

- (UIImage *)capturedImage {
    return _previewView.capturedImage;
}

- (void)setError:(NSError * __nullable)error {
    _error = error;
    _headerView.alpha = error==nil ? 0 : 1;
    _headerView.instructionLabel.text = error==nil ? nil : [error.userInfo valueForKey:NSLocalizedDescriptionKey];
    [self updateAppearance];
    [self setNeedsUpdateConstraints];
}

const CGFloat CONTINUE_ALPHA_TRANSLUCENT = 0.5;
const CGFloat CONTINUE_ALPHA_OPAQUE = 0;

- (void)updateConstraints {
    if (_variableConstraints) {
        [NSLayoutConstraint deactivateConstraints:_variableConstraints];
        [_variableConstraints removeAllObjects];
    }
    
    if (!_variableConstraints) {
        _variableConstraints = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self, _previewView, _continueSkipContainer, _headerView);
    ORKEnableAutoLayoutForViews([views allValues]);
    
    if (_error) {
        // If we have an error to show, do not display the previewView at all
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|"
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:views]];
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueSkipContainer]|"
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:views]];
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView]-[_continueSkipContainer]|"
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:views]];
    } else {
        // If we do not have an error to show, layout the previewView and continueSkipContainer
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|"
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:views]];
        [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueSkipContainer]|"
                                                                                          options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                          metrics:nil
                                                                                            views:views]];
        
        // Float the continue view over the previewView if in landscape to give more room for the preview
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]|"
                                                                                              options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil
                                                                                                views:views]];
            [_variableConstraints addObject:[NSLayoutConstraint constraintWithItem:_continueSkipContainer
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0.0]];
            _continueSkipContainer.backgroundColor = [_continueSkipContainer.backgroundColor colorWithAlphaComponent:CONTINUE_ALPHA_TRANSLUCENT];
        } else {
            [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]-[_continueSkipContainer]|"
                                                                                              options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                              metrics:nil
                                                                                                views:views]];
            _continueSkipContainer.backgroundColor = [_continueSkipContainer.backgroundColor colorWithAlphaComponent:CONTINUE_ALPHA_OPAQUE];
        }
    }
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (AVCaptureSession *)session {
    return _previewView.session;
}

- (void)setSession:(AVCaptureSession * __nullable)session {
    _previewView.session = session;
    // Set up the proper videoOrientation from the start
    [self orientationDidChange];
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    if (_showSkipButtonItem) {
        _skipButtonItem = skipButtonItem;
        [self updateAppearance];
    }
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    _continueButtonItem = continueButtonItem;
    [self updateAppearance];
}

- (void)capturePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_capturePressesIgnored)
        return;
    
    // Ignore futher presses until the delegate completes
    _capturePressesIgnored = YES;
        
    // Capture the image via the delegate
    [self.delegate capturePressed:^(BOOL captureSuccess){
        // Stop ignoring presses
        _capturePressesIgnored = NO;
    }];
}

- (void)retakePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_retakePressesIgnored)
        return;
    
    // Ignore futher presses until the delegate completes
    _retakePressesIgnored = YES;
    
    // Tell the delegate to start capturing again
    [self.delegate retakePressed:^{
        // Stop ignoring presses
        _retakePressesIgnored = NO;
    }];
}

@end
