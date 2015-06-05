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


@interface ORKImageCaptureView ()

@property (nonatomic, strong) ORKStepHeaderView *headerView;
@property (nonatomic, strong) ORKImageCaptureCameraPreviewView *previewView;
@property (nonatomic, strong) ORKNavigationContainerView *continueSkipContainer;
@property (nonatomic, strong) UIBarButtonItem *skipButtonItem;
@property (nonatomic, strong) NSMutableArray *mconstraints;

@property (nonatomic) SEL continueAction;
@property (nonatomic, assign) id continueTarget;
@property (nonatomic, strong) NSString* continueTitle;

@property (nonatomic) BOOL capturePressesIgnored;
@property (nonatomic) BOOL retakePressesIgnored;

@end


@implementation ORKImageCaptureView

- (instancetype)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        _mconstraints = [[NSMutableArray alloc] init];
        
        _previewView = [[ORKImageCaptureCameraPreviewView alloc] init];
        [self addSubview:_previewView];
        
        _headerView = [[ORKStepHeaderView alloc] init];
        _headerView.alpha = 0;
        [self addSubview:_headerView];
        
        _continueSkipContainer = [ORKNavigationContainerView new];
        _continueSkipContainer.continueEnabled = YES;
        _continueSkipContainer.topMargin = 5;
        _continueSkipContainer.bottomMargin = 15;
        _continueSkipContainer.optional = YES;
        _continueSkipContainer.backgroundColor = ORKColor(ORKBackgroundColorKey);
        [self addSubview:_continueSkipContainer];
        
        NSDictionary *dictionary = NSDictionaryOfVariableBindings(self, _previewView, _continueSkipContainer, _headerView);
        ORKEnableAutoLayoutForViews([dictionary allValues]);
        
        _skipButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_RECAPTURE_IMAGE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(retakePressed)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queue_sessionRunning) name:AVCaptureSessionDidStartRunningNotification object:nil];
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
}

- (void)setCapturedImage:(UIImage * __nullable)capturedImage {
    _previewView.capturedImage = capturedImage;
}

- (UIImage *)capturedImage {
    return _previewView.capturedImage;
}

- (void)setError:(NSError * __nullable)error {
    _error = error;
    _headerView.alpha = error==nil ? 0 : 1;
    _headerView.instructionLabel.text = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
    if (error) {
        _continueSkipContainer.continueButtonItem = nil;
        _continueSkipContainer.skipButtonItem = nil;
    }
    
    [self setNeedsUpdateConstraints];
}

const CGFloat CONTINUE_ALPHA_TRANSLUCENT = 0.5;
const CGFloat CONTINUE_ALPHA_OPAQUE = 0;

- (void)updateConstraints {
    if (_mconstraints) {
        [NSLayoutConstraint deactivateConstraints:_mconstraints];
        [_mconstraints removeAllObjects];
    }
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(self, _previewView, _continueSkipContainer, _headerView);
    ORKEnableAutoLayoutForViews([dictionary allValues]);
    
    if (_error) {
        // If we have an error to show, do not display the previewView at all
        [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
        [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueSkipContainer]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
        [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView]-[_continueSkipContainer]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
    } else {
        // If we do not have an error to show, layout the previewView and continueSkipContainer
        [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
        [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueSkipContainer]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
        
        // Float the continue view over the previewView if in landscape to give more room for the preview
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
            [self.mconstraints addObject:[NSLayoutConstraint constraintWithItem:_continueSkipContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            _continueSkipContainer.backgroundColor = [_continueSkipContainer.backgroundColor colorWithAlphaComponent:CONTINUE_ALPHA_TRANSLUCENT];
        } else {
            [self.mconstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]-[_continueSkipContainer]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:dictionary]];
            _continueSkipContainer.backgroundColor = [_continueSkipContainer.backgroundColor colorWithAlphaComponent:CONTINUE_ALPHA_OPAQUE];
        }
        
        [NSLayoutConstraint activateConstraints:_mconstraints];
    }
    
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

- (UIBarButtonItem *)continueButtonItem {
    return _continueSkipContainer.continueButtonItem;
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    // If we are in an error state, then do not configure the continue button
    if (self.error) {
        return;
    }

    // Intercept the continue button press.  This can be called multiple
    // times with the same UIBarButtonItem, or with different UIBarButtonItems,
    // so capture it whenever the button does not point to our selector
    if (continueButtonItem.action != @selector(capturePressed)) {
        self.continueAction = continueButtonItem.action;
        self.continueTarget = continueButtonItem.target;
        self.continueTitle = continueButtonItem.title;
        continueButtonItem.action = @selector(capturePressed);
        continueButtonItem.target = self;
    }
    
    // If we haven't already gotten a captured image, then change the title
    // of the button to be appropriate for the capture action
    if (!self.capturedImage) {
        continueButtonItem.title = ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_IMAGE", nil);
    } else if(self.capturedImage) {
        _continueSkipContainer.skipButtonItem = _skipButtonItem;
    }
    
    _continueSkipContainer.continueButtonItem = continueButtonItem;
}

- (void)capturePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_capturePressesIgnored)
        return;
    
    // If we don't have an error to show, and we have not yet captured an image, then do so
    if (!self.capturedImage && !self.error) {
        // Ignore futher presses until the delegate completes
        _capturePressesIgnored = YES;
        
        // Capture the image via the delegate
        [self.delegate capturePressed:^(BOOL captureSuccess){
            if(captureSuccess) {
                // Hide the template image after capturing
                _previewView.templateImageHidden = YES;
        
                // If we experienced an error during the capture (likely writing the file to disk)
                // then do not reconfigure the buttons
                if (!self.error) {
                    // Reset the continue button title and configure the skip button as a recapture button
                    _continueSkipContainer.continueButtonItem.title = self.continueTitle;
                    _continueSkipContainer.skipButtonItem = _skipButtonItem;
                }
            }
            // Stop ignoring presses
            _capturePressesIgnored = NO;
        }];
    } else {
        // Perform the original action of the Continue button
        [self.continueTarget performSelector:self.continueAction withObject:_continueSkipContainer.continueButtonItem afterDelay:0];
    }
}

- (void)retakePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_retakePressesIgnored)
        return;
    
    // Ignore futher presses until the delegate completes
    _retakePressesIgnored = YES;
    
    // Tell the delegate to start capturing again
    [self.delegate retakePressed:^{
        // Show the template image
        _previewView.templateImageHidden = NO;
    
        // Change the continue button title back to capture, and hide the recapture button
        _continueSkipContainer.continueButtonItem.title = ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_IMAGE", nil);
        _continueSkipContainer.skipButtonItem = nil;
        
        // Stop ignoring presses
        _retakePressesIgnored = NO;
    }];
}

@end
