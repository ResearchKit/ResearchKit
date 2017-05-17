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


#import "ORKHrCaptureView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKHelpers_Private.h"
#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"
#import "ORKStepHeaderView_Internal.h"


@implementation ORKHrCaptureView {
    ORKStepHeaderView *_headerView;
    ORKNavigationContainerView *_continueSkipContainer;
    UIBarButtonItem *_captureButtonItem;
    UIBarButtonItem *_stopButtonItem;
    UIBarButtonItem *_recordingButtonItem;
    UIBarButtonItem *_recaptureButtonItem;
    UILabel *_hrLabel;
    UILabel *_hrUnitLabel;
    NSMutableArray *_variableConstraints;
    NSTimer *_timer;
    CGFloat _recordTime;
    NSDateComponentsFormatter *_dateComponentsFormatter;
    AVCaptureSession *_session;
    BOOL _capturePressesIgnored;
    BOOL _stopCapturePressesIgnored;
    BOOL _retakePressesIgnored;
    BOOL _showSkipButtonItem;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _hrLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _hrLabel.text = @"0";
        _hrLabel.textAlignment = NSTextAlignmentCenter;
        _hrLabel.font=[_hrLabel.font fontWithSize:80];
        
        _hrUnitLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        _hrUnitLabel.text = ORKLocalizedString(@"HR_LBL_UNITS", nil);
        _hrUnitLabel.textAlignment = NSTextAlignmentCenter;
        _hrUnitLabel.font=[_hrUnitLabel.font fontWithSize:25];
        
        // Set labels for delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            // Delegate will update our label
            [self.delegate setHrLbl:_hrLabel];
        });
        
        [self addSubview:_hrLabel];
        [self addSubview:_hrUnitLabel];
        
        _headerView = [ORKStepHeaderView new];
        _headerView.instructionLabel.text = @" ";
        [self addSubview:_headerView];
        
        _captureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_CAPTURE_HR", nil)
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(capturePressed)];
        
        _stopButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_STOP_CAPTURE_HR", nil)
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(stopCapturePressed)];
        
        _recordingButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:nil];
        
        _recaptureButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"CAPTURE_BUTTON_RECAPTURE_HR", nil)
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(retakePressed)];
        
        _continueSkipContainer = [ORKNavigationContainerView new];
        _continueSkipContainer.continueEnabled = YES;
        _continueSkipContainer.topMargin = 5;
        _continueSkipContainer.bottomMargin = 15;
        _continueSkipContainer.optional = YES;
        _continueSkipContainer.backgroundColor = ORKColor(ORKBackgroundColorKey);
        [self addSubview:_continueSkipContainer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.session];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionInterruptionEndedNotification object:self.session];
        
        [self updateAppearance];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [self.delegate videoOrientationDidChange:orientation];
    [self setNeedsUpdateConstraints];
}

- (void)setHrCaptureStep:(ORKHrCaptureStep *)hrCaptureStep {
    
    _hrCaptureStep = hrCaptureStep;
    _captureButtonItem.accessibilityHint = _hrCaptureStep.accessibilityHint;
    _showSkipButtonItem = _hrCaptureStep.optional;
    
    [self updateAppearance];
}

- (void)updateAppearance {
    
    _headerView.alpha = (self.error) ? 1 : 0;
    
    if (self.error) {
        
        // Display the error instruction.
        _headerView.instructionLabel.text = [self.error.userInfo valueForKey:NSLocalizedDescriptionKey];
        
        // Show skip, if available, and continue/capture button
        _continueSkipContainer.continueButtonItem = nil;
        _continueSkipContainer.skipButtonItem = _skipButtonItem;
        _continueSkipContainer.skipEnabled = YES;
    } else if (self.recording) {
        
        // Change the continue button back to capture.
        _continueSkipContainer.continueButtonItem = _stopButtonItem;
        
        // Start a timer to show recording progress.
        _recordingButtonItem.title = [self formattedTimeFromSeconds:_hrCaptureStep.duration.floatValue];
        _continueSkipContainer.skipButtonItem = _recordingButtonItem;
        _continueSkipContainer.skipEnabled = NO;
        _recordTime = 0.0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(updateRecordTime:)
                                                userInfo:nil
                                                 repeats:YES];
    } else if (self.capturedHr) {
        
        // Set the continue button to the one we've saved and configure the skip button as a recapture button
        // only if we have collected HR
        _continueSkipContainer.continueButtonItem = _continueButtonItem;
        _continueSkipContainer.skipButtonItem = _recaptureButtonItem;
        _continueSkipContainer.skipEnabled = YES;
        if (UIAccessibilityIsVoiceOverRunning()) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, ORKLocalizedString(@"AX_HR_CAPTURE_COMPLETE", nil));
        }
    } else {
        
        // Change the continue button back to capture, and change the recapture button back to skip (if available)
        _continueSkipContainer.continueButtonItem = _captureButtonItem;
        _continueSkipContainer.skipButtonItem = _skipButtonItem;
        _continueSkipContainer.skipEnabled = YES;
    }
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
    
    NSDictionary *views = NSDictionaryOfVariableBindings(self, _headerView, _hrLabel,_hrUnitLabel, _continueSkipContainer);
    ORKEnableAutoLayoutForViews(views.allValues);
    
    [_variableConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|"
                                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                       metrics:nil
                                                                                         views:views]];
    [_variableConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView]"
                                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                       metrics:nil
                                                                                         views:views]];
    
    [_variableConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hrLabel]|"
                                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                       metrics:nil
                                                                                         views:views]];
    
    [_variableConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hrUnitLabel]|"
                                                                                       options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                       metrics:nil
                                                                                         views:views]];
    
    [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_continueSkipContainer]|"
                                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                      metrics:nil
                                                                                        views:views]];
    
    [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_headerView]-[_hrLabel]-[_hrUnitLabel]"
                                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                      metrics:nil
                                                                                        views:views]];
    
    [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hrLabel]-20-[_hrUnitLabel]"
                                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                      metrics:nil
                                                                                        views:views]];
    
    [_variableConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_continueSkipContainer]|"
                                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                      metrics:nil
                                                                                        views:views]];
    
    [NSLayoutConstraint activateConstraints:_variableConstraints];
    [super updateConstraints];
}

- (AVCaptureSession *)session {
    return _session;
}

- (void)setSession:(AVCaptureSession *)session {
    _session = session;
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
    
    // Stop the video capture via the delegate
    [self.delegate stopCapturePressed:^ {
        // Stop ignoring presses
        _stopCapturePressesIgnored = NO;
    }];
    
}

- (void)retakePressed {
    // If we are still waiting for the delegate to complete, ignore futher presses
    if (_retakePressesIgnored) {
        return;
    }
    
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
    
    if (_recordTime >= _hrCaptureStep.duration.floatValue || !self.recording) {
        [_timer invalidate];
        [self.delegate stopHrEstimation];
        [self updateAppearance];
    } else {
        CGFloat remainingTime = _hrCaptureStep.duration.floatValue - _recordTime;
        _recordingButtonItem.title = [self formattedTimeFromSeconds:remainingTime];
        _continueSkipContainer.skipButtonItem = _recordingButtonItem;
    }
}

-(NSString *)formattedTimeFromSeconds:(CGFloat)seconds {
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
    [self.delegate stopHrEstimation];
    [_session stopRunning];
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    [self setError:nil];
}

@end
