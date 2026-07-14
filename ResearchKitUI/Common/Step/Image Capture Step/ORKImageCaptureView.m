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
#import "ORKStepHeaderView_Internal.h"

#import "ORKImageCaptureStep.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKTitleLabel.h"
#import "ORKBodyLabel.h"


@implementation ORKImageCaptureView {
    ORKStepHeaderView *_headerView;
    ORKImageCaptureCameraPreviewView *_previewView;
    ORKNavigationContainerView *_navigationFooterView;
    UIBarButtonItem *_captureButtonItem;
    UIBarButtonItem *_recaptureButtonItem;
    UIVisualEffectView *_instructionBlurView;
    UIVisualEffectView *_footerBlurView;
    ORKTitleLabel *_titleLabel;
    ORKBodyLabel *_detailTextLabel;
    NSMutableArray *_variableConstraints;
    
    BOOL _capturePressesIgnored;
    BOOL _retakePressesIgnored;
    BOOL _showSkipButtonItem;
    BOOL _hasInstructionContent;
}

- (instancetype)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        _previewView = [[ORKImageCaptureCameraPreviewView alloc] init];
        [self addSubview:_previewView];
        
        _headerView = [[ORKStepHeaderView alloc] init];
        _headerView.instructionLabel.text = @" "; // Need error placeholder string for constraints.
        [self addSubview:_headerView];
        
        _captureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_IMAGE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(capturePressed)];
        _recaptureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_RECAPTURE_IMAGE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(retakePressed)];
        
        _navigationFooterView = [ORKNavigationContainerView new];
        _navigationFooterView.continueEnabled = YES;
        _navigationFooterView.topMargin = 5;
        _navigationFooterView.bottomMargin = 15;
        _navigationFooterView.optional = YES;

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
        _footerBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _footerBlurView.translatesAutoresizingMaskIntoConstraints = NO;
        [_navigationFooterView insertSubview:_footerBlurView atIndex:0];
        [NSLayoutConstraint activateConstraints:@[
            [_footerBlurView.topAnchor constraintEqualToAnchor:_navigationFooterView.topAnchor],
            [_footerBlurView.bottomAnchor constraintEqualToAnchor:_navigationFooterView.bottomAnchor],
            [_footerBlurView.leadingAnchor constraintEqualToAnchor:_navigationFooterView.leadingAnchor],
            [_footerBlurView.trailingAnchor constraintEqualToAnchor:_navigationFooterView.trailingAnchor],
        ]];
        _navigationFooterView.backgroundColor = [UIColor clearColor];
        [self addSubview:_navigationFooterView];

        // Instruction panel - extends to bottom of screen behind footer for seamless blur
        _instructionBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial]];
        _instructionBlurView.translatesAutoresizingMaskIntoConstraints = NO;
        _instructionBlurView.hidden = YES;
        [self insertSubview:_instructionBlurView belowSubview:_navigationFooterView];

        CGFloat margin = 20.0;

        _titleLabel = [ORKTitleLabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        [_titleLabel setTextColor:[UIColor labelColor]];
        [self addSubview:_titleLabel];

        _detailTextLabel = [ORKBodyLabel new];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.textAlignment = NSTextAlignmentLeft;
        _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailTextLabel.numberOfLines = 0;
        [_detailTextLabel setTextColor:[UIColor secondaryLabelColor]];
        [self addSubview:_detailTextLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_detailTextLabel.bottomAnchor constraintEqualToAnchor:_navigationFooterView.topAnchor constant:-12.0],
            [_detailTextLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:margin],
            [_detailTextLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-margin],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:_detailTextLabel.topAnchor constant:-8.0],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:margin],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-margin],
        ]];

        NSDictionary *dictionary = NSDictionaryOfVariableBindings(self, _previewView, _navigationFooterView, _headerView);
        ORKEnableAutoLayoutForViews(dictionary.allValues);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queue_sessionRunning) name:AVCaptureSessionDidStartRunningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];

        [self updateAppearance];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)queue_sessionRunning {
    dispatch_async(dispatch_get_main_queue(), ^{
        _previewView.templateImageHidden = NO;
    });
}

- (void)setImageCaptureStep:(ORKImageCaptureStep *)imageCaptureStep {
    _imageCaptureStep = imageCaptureStep;
    
    _previewView.templateImage = imageCaptureStep.templateImage;
    _previewView.templateImageInsets = imageCaptureStep.templateImageInsets;
    
    _captureButtonItem.accessibilityHint = imageCaptureStep.accessibilityHint;
    
    _showSkipButtonItem = imageCaptureStep.optional;

    _hasInstructionContent = (imageCaptureStep.title.length > 0 || imageCaptureStep.text.length > 0);
    _titleLabel.text = imageCaptureStep.title;
    _detailTextLabel.text = imageCaptureStep.text;

    [self updateAppearance];
}

- (void)updateAppearance {
    
    _headerView.alpha = (self.error) ? 1 : 0;
    _previewView.alpha = (self.error) ? 0 : 1;
    
    if (self.error) {
        _instructionBlurView.hidden = YES;
        _titleLabel.hidden = YES;
        _detailTextLabel.hidden = YES;
        _footerBlurView.hidden = NO;

        // Display the error instruction.
        _headerView.instructionLabel.text = [self.error.userInfo valueForKey:NSLocalizedDescriptionKey];
        
        // Hide the template image if there is an error
        _previewView.templateImageHidden = YES;
        _previewView.accessibilityHint = nil;
        
        // Show skip, if available, and hide the template and continue/capture button
        _navigationFooterView.continueButtonItem = nil;
        _navigationFooterView.skipButtonItem = _skipButtonItem;
    } else if (self.capturedImage) {
        _instructionBlurView.hidden = YES;
        _titleLabel.hidden = YES;
        _detailTextLabel.hidden = YES;
        _footerBlurView.hidden = NO;

        // Hide the template image after capturing
        _previewView.templateImageHidden = YES;
        _previewView.accessibilityHint = nil;

        // Set the continue button to the one we've saved and configure the skip button as a recapture button
        _navigationFooterView.continueButtonItem = _continueButtonItem;
        _navigationFooterView.skipButtonItem = _recaptureButtonItem;
    } else {
        _instructionBlurView.hidden = !_hasInstructionContent;
        _titleLabel.hidden = !_hasInstructionContent;
        _detailTextLabel.hidden = !_hasInstructionContent;
        _footerBlurView.hidden = _hasInstructionContent;

        // Show the template image during capturing
        _previewView.templateImageHidden = NO;
        _previewView.accessibilityHint = _imageCaptureStep.accessibilityInstructions;
    
        // Change the continue button back to capture, and change the recapture button back to skip (if available)
        _navigationFooterView.continueButtonItem = _captureButtonItem;
        _navigationFooterView.skipButtonItem = _skipButtonItem;
    }
}

- (void)setCapturedImage:(UIImage *)capturedImage {
    _previewView.capturedImage = capturedImage;
    [self updateAppearance];
}

- (UIImage *)capturedImage {
    return _previewView.capturedImage;
}

- (void)setError:(NSError *)error {
    _error = error;
    [self updateAppearance];
}

- (void)updateConstraints {
    if (_variableConstraints) {
        [NSLayoutConstraint deactivateConstraints:_variableConstraints];
        [_variableConstraints removeAllObjects];
    }
    
    if (!_variableConstraints) {
        _variableConstraints = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self, _previewView, _navigationFooterView, _headerView);
    ORKEnableAutoLayoutForViews(views.allValues);
    
    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];

    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_previewView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];

    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView]-(>=0)-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navigationFooterView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];

    [_variableConstraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_previewView]|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                               views:views]];
    [_variableConstraints addObject:
     [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                  attribute:NSLayoutAttributeBottom
                                 multiplier:1.0
                                   constant:0.0]];

    [_variableConstraints addObject:[_instructionBlurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor]];
    [_variableConstraints addObject:[_instructionBlurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]];
    [_variableConstraints addObject:[_instructionBlurView.topAnchor constraintEqualToAnchor:_titleLabel.topAnchor constant:-20.0]];
    [_variableConstraints addObject:[_instructionBlurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]];

    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (AVCaptureSession *)session {
    return _previewView.session;
}

- (void)setSession:(AVCaptureSession *)session {
    _previewView.session = session;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem {
    if (_showSkipButtonItem) {
        _skipButtonItem = skipButtonItem;
        [self updateAppearance];
    }
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    _cancelButtonItem = cancelButtonItem;
    [self updateAppearance];
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
    [self.delegate capturePressed:^(BOOL captureSuccess) {
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

- (void)sessionWasInterrupted:(NSNotification *)notification {
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
        [self setError:[[NSError alloc] initWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"CAMERA_UNAVAILABLE_MESSAGE", nil)}]];
    }
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    [self setError:nil];
}

- (BOOL)accessibilityPerformMagicTap {
    if (self.error) {
        return NO;
    }
    if (self.capturedImage) {
        [self retakePressed];
    } else {
        [self capturePressed];
    }
    return YES;
}

@end
