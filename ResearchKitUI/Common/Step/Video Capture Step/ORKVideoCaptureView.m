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


#import "ORKVideoCaptureView.h"
#import "ORKVideoCaptureCameraPreviewView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKStepHeaderView_Internal.h"


@implementation ORKVideoCaptureView {
    ORKStepHeaderView *_headerView;
    ORKNavigationContainerView *_navigationFooterView;
    UIBarButtonItem *_captureButtonItem;
    UIBarButtonItem *_stopButtonItem;
    UIBarButtonItem *_recordingButtonItem;
    UIBarButtonItem *_recaptureButtonItem;
    NSMutableArray *_variableConstraints;
    NSTimer *_timer;
    CGFloat _recordTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    UIView *_recordingIndicatorView;
    UIView *_redDotView;
    UILabel *_timerLabel;

    BOOL _capturePressesIgnored;
    BOOL _stopCapturePressesIgnored;
    BOOL _retakePressesIgnored;
    BOOL _showSkipButtonItem;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _previewView = [ORKVideoCaptureCameraPreviewView new];
        [self addSubview:_previewView];
        
        _playerViewController = [AVPlayerViewController new];
        _playerViewController.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _playerViewController.allowsPictureInPicturePlayback = NO;
        _playerViewController.showsPlaybackControls = YES;
        [self addSubview:_playerViewController.view];
        
        _headerView = [ORKStepHeaderView new];
        _headerView.instructionLabel.text = @" ";
        [self addSubview:_headerView];
        
        _captureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_VIDEO", nil)
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(capturePressed)];
        
        _stopButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_STOP_CAPTURE_VIDEO", nil)
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(stopCapturePressed)];

        _recordingButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:nil];

        _recaptureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_RECAPTURE_VIDEO", nil)
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(retakePressed)];
        
        _navigationFooterView = [ORKNavigationContainerView new];
        _navigationFooterView.continueEnabled = YES;
        _navigationFooterView.optional = YES;
        _navigationFooterView.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.9];
        [_navigationFooterView.skipButton setContentHuggingPriority:UILayoutPriorityRequired - 1 forAxis:UILayoutConstraintAxisVertical];
        [self addSubview:_navigationFooterView];

        _recordingIndicatorView = [UIView new];
        _recordingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _recordingIndicatorView.hidden = YES;
        _recordingIndicatorView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        _recordingIndicatorView.layer.cornerRadius = 16.0;
        _recordingIndicatorView.clipsToBounds = YES;

        _redDotView = [UIView new];
        _redDotView.translatesAutoresizingMaskIntoConstraints = NO;
        _redDotView.backgroundColor = [UIColor systemRedColor];
        _redDotView.layer.cornerRadius = 5.0;
        [_recordingIndicatorView addSubview:_redDotView];

        _timerLabel = [UILabel new];
        _timerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:17.0 weight:UIFontWeightSemibold];
        _timerLabel.textColor = [UIColor whiteColor];
        _timerLabel.textAlignment = NSTextAlignmentCenter;
        [_recordingIndicatorView addSubview:_timerLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_redDotView.widthAnchor constraintEqualToConstant:10.0],
            [_redDotView.heightAnchor constraintEqualToConstant:10.0],
            [_redDotView.centerYAnchor constraintEqualToAnchor:_recordingIndicatorView.centerYAnchor],
            [_redDotView.leadingAnchor constraintEqualToAnchor:_recordingIndicatorView.leadingAnchor constant:12.0],
            [_timerLabel.leadingAnchor constraintEqualToAnchor:_redDotView.trailingAnchor constant:6.0],
            [_timerLabel.trailingAnchor constraintEqualToAnchor:_recordingIndicatorView.trailingAnchor constant:-12.0],
            [_timerLabel.topAnchor constraintEqualToAnchor:_recordingIndicatorView.topAnchor constant:6.0],
            [_timerLabel.bottomAnchor constraintEqualToAnchor:_recordingIndicatorView.bottomAnchor constant:-6.0],
        ]];

        [self addSubview:_recordingIndicatorView];
        
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

- (void)setVideoCaptureStep:(ORKVideoCaptureStep *)videoCaptureStep {
    _videoCaptureStep = videoCaptureStep;
    
    _previewView.templateImage = _videoCaptureStep.templateImage;
    _previewView.templateImageInsets = _videoCaptureStep.templateImageInsets;
    
    _captureButtonItem.accessibilityHint = _videoCaptureStep.accessibilityHint;
    
    _showSkipButtonItem = _videoCaptureStep.optional;
    
    [self updateAppearance];
}

- (void)updateAppearance {
    
    _headerView.alpha = (self.error) ? 1 : 0;
    _previewView.alpha = (self.error) ? 0 : 1;
    
    if (self.error) {
        // Display the error title and description.
        NSString *errorTitle = [self.error.userInfo valueForKey:NSLocalizedFailureReasonErrorKey];
        if (errorTitle) {
            _headerView.captionLabel.text = errorTitle;
        }
        _headerView.instructionLabel.text = [self.error.userInfo valueForKey:NSLocalizedDescriptionKey];
        
        // Hide the template image if there is an error
        _previewView.templateImageHidden = YES;
        _previewView.accessibilityHint = nil;
        _playerViewController.view.hidden = YES;
        _recordingIndicatorView.hidden = YES;

        // Show skip, if available, and hide the template and continue/capture button
        _navigationFooterView.continueButtonItem = nil;
        _navigationFooterView.skipButtonItem = _skipButtonItem;
        _navigationFooterView.skipEnabled = YES;
    } else if (self.videoFileURL) {
        // Hide the template image after capturing
        _previewView.templateImageHidden = YES;
        _previewView.accessibilityHint = nil;
        _previewView.userInteractionEnabled = NO;
        _playerViewController.view.hidden = NO;
        _recordingIndicatorView.hidden = YES;

        // Set the continue button to the one we've saved and configure the skip button as a recapture button
        _navigationFooterView.continueButtonItem = _continueButtonItem;
        _navigationFooterView.skipButtonItem = _recaptureButtonItem;
        _navigationFooterView.skipEnabled = YES;
    } else if (self.recording) {
        _previewView.templateImageHidden = (_videoCaptureStep.templateImage == nil);
        _previewView.userInteractionEnabled = YES;
        _previewView.accessibilityHint = _videoCaptureStep.accessibilityInstructions;
        _playerViewController.view.hidden = YES;

        _navigationFooterView.continueButtonItem = _stopButtonItem;
        _navigationFooterView.skipButtonItem = nil;
        _navigationFooterView.skipEnabled = NO;

        _recordingIndicatorView.hidden = NO;
        _timerLabel.text = [self formattedTimeFromSeconds:_videoCaptureStep.duration.floatValue];
        [self _startRedDotAnimation];

        _recordTime = 0.0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateRecordTime:)
                                                userInfo:nil
                                                 repeats:YES];
    } else {
        // Show the template image during capturing
        _previewView.templateImageHidden = NO;
        _previewView.accessibilityHint = _videoCaptureStep.accessibilityInstructions;
        _playerViewController.view.hidden = YES;
        _recordingIndicatorView.hidden = YES;

        // Change the continue button back to capture, and change the recapture button back to skip (if available)
        _navigationFooterView.continueButtonItem = _captureButtonItem;
        _navigationFooterView.skipButtonItem = _skipButtonItem;
        _navigationFooterView.skipEnabled = YES;
    }
}

- (void)setVideoFileURL:(NSURL *)videoFileURL {
    _videoFileURL = videoFileURL;
    _previewView.videoFileURL = videoFileURL;
    
    if (_videoFileURL != nil) {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:_videoFileURL];
        _playerViewController.player = [[AVPlayer alloc] initWithPlayerItem:item];
        [_playerViewController.player play];
    }
    
    [self updateAppearance];
}

- (void)setRecording:(BOOL)recording {
    _recording = recording;
    [self updateAppearance];
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
        _variableConstraints = [NSMutableArray new];
    }
    
    UIView *playerView = _playerViewController.view;
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _previewView.translatesAutoresizingMaskIntoConstraints = NO;
    _navigationFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_variableConstraints addObjectsFromArray:@[
                                                [NSLayoutConstraint constraintWithItem:_headerView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.safeAreaLayoutGuide
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_headerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.safeAreaLayoutGuide
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_headerView
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.safeAreaLayoutGuide
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:playerView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:_navigationFooterView
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_navigationFooterView
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                
                                                [NSLayoutConstraint constraintWithItem:_previewView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:playerView
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_previewView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:playerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_previewView
                                                                             attribute:NSLayoutAttributeRight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:playerView
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1.0
                                                                              constant:0.0],
                                                [NSLayoutConstraint constraintWithItem:_previewView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:playerView
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:0.0]
                                                
                                                
                                                ]];

    [_variableConstraints addObjectsFromArray:@[
                                                [_recordingIndicatorView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                                [_recordingIndicatorView.bottomAnchor constraintEqualToAnchor:_navigationFooterView.topAnchor constant:-12.0],
                                                ]];

    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (void)_startRedDotAnimation {
    [_redDotView.layer removeAnimationForKey:@"redDotPulse"];
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue = @(1.0);
    pulse.toValue = @(0.0);
    pulse.duration = 0.8;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_redDotView.layer addAnimation:pulse forKey:@"redDotPulse"];
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

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    _continueButtonItem = continueButtonItem;
    [self updateAppearance];
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    _cancelButtonItem = cancelButtonItem;
    [self updateAppearance];
}

- (void)capturePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_capturePressesIgnored)
        return;
    
    // Ignore futher presses until the delegate completes
    _capturePressesIgnored = YES;
    
    // Capture the video via the delegate
    [self.delegate capturePressed:^ {
        // Stop ignoring presses
        _capturePressesIgnored = NO;
    }];
}

- (void)stopCapturePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_stopCapturePressesIgnored)
        return;
    
    // Ignore futher presses until the delegate completes
    _stopCapturePressesIgnored = YES;
    
    // Invalidate timer.
    [_timer invalidate];
    [_redDotView.layer removeAnimationForKey:@"redDotPulse"];
    
    // Stop the video capture via the delegate
    [self.delegate stopCapturePressed:^ {
        // Stop ignoring presses
        _stopCapturePressesIgnored = NO;
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

- (void)updateRecordTime:(NSTimer *)timer {
    _recordTime += timer.timeInterval;

    if (_recordTime >= _videoCaptureStep.duration.floatValue || !self.recording) {
        [_timer invalidate];
        [_redDotView.layer removeAnimationForKey:@"redDotPulse"];
        [self updateAppearance];
    } else {
        CGFloat remainingTime = _videoCaptureStep.duration.floatValue - _recordTime;
        _timerLabel.text = [self formattedTimeFromSeconds:remainingTime];
    }
}

- (NSString *)formattedTimeFromSeconds:(CGFloat)seconds {
    if (!_dateComponentsFormatter) {
        _dateComponentsFormatter = [NSDateComponentsFormatter new];
        _dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        _dateComponentsFormatter.allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond;
    }
    return [_dateComponentsFormatter stringFromTimeInterval:seconds];
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
        [self setError:[[NSError alloc] initWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : ORKLocalizedString(@"CAMERA_UNAVAILABLE_MESSAGE", nil)}]];
    }
    [_previewView.session stopRunning];
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    [self setError:nil];
}

- (BOOL)accessibilityPerformMagicTap {
    if (self.error) {
        return NO;
    }
    if (self.videoFileURL) {
        [self retakePressed];
    } else {
        [self capturePressed];
    }
    return YES;
}

@end
