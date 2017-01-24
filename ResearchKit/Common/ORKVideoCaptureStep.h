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


#import <ResearchKit/ResearchKit.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKVideoCaptureStep` class represents a step that captures a video through the device
 camera.  A template image can optionally be laid over the camera preview to assist in properly
 capturing the video.
 
 To use the video capture step, optionally set the `templateImage` and `templateImageInsets`
 properties, incorporate the step into a task, and present the task with a task view controller.
 
 If implementing a video capture task like this one, remember that people will
 take your instructions literally. So be cautious. Make sure your template image
 is high contrast and very visible against a variety of backgrounds.
 
 The recording length can be a max of 20 minutes. It defaults to 2 minutes.
 */
ORK_CLASS_AVAILABLE
@interface ORKVideoCaptureStep : ORKStep

/**
 An image to be displayed over the camera preview.
 
 The image is stretched to fit the available space while retaining its aspect ratio.
 When choosing a size for this asset, be sure to take into account the variations in device
 form factors.
 */
@property (nonatomic, strong) UIImage *templateImage;

/**
 Insets to be used in positioning and sizing the `templateImage`.
 
 The insets are interpreted as percentages relative to the preview frame size.  The left
 and right insets are relative to the width of the preview frame.  The top and bottom
 insets are relative to the height of the preview frame.
 */
@property (nonatomic) UIEdgeInsets templateImageInsets;

/**
 The duration, in seconds, for the recording.
 
 The maximum that this can be set to is 20.0 minutes (60*20 seconds).
 The minimum that this can be set to is 0.01 minutes (1 second).
 
 The default value is 2.0 minutes (60*2 seconds).
 */
@property (nonatomic) NSNumber *duration;

/**
 A Boolean indicating whether the audio is recorded or not.
 
 The default value is NO.
 */
@property (nonatomic, getter=isAudioMute) BOOL audioMute;

/**
 Constants indicating the mode of the flash on the receiver's device, if it has one.
 
 The default value is `AVCaptureFlashModeOff` (see `AVCaptureFlashMode`).
 */
@property (nonatomic) AVCaptureFlashMode flashMode;

/**
 Constants indicating the physical position of an AVCaptureDevice's hardware on the system.
 
 The default value is `AVCaptureDevicePositionBack` (see `AVCaptureDevicePosition`).
 If `AVCaptureDevicePositionUnspecified` is set, then it defaults to `AVCaptureDevicePositionBack`.
 */
@property (nonatomic) AVCaptureDevicePosition devicePosition;

/**
 An accessibility hint of the capture preview.
 
 This property can be used to specify accessible instructions for capturing the video.  The
 use of this property can assist when the `templateImage` may not be visible
 to the user.
 
 For example, if you want to capture a video of the user's right hand, you may use a template
 image that displays the outline of the right hand.  You may also want to set this property
 to a string such as @"Extend your right hand, palm side down, one foot from your device.
 Tap the Capture Video button, or two finger tap on the preview, to capture a video of your
 extended right hand."
 */
@property (nonatomic, copy) NSString *accessibilityInstructions;

/**
 An accessibility hint of the capture button.
 */
@property (nonatomic, copy) NSString *accessibilityHint;

@end

NS_ASSUME_NONNULL_END
