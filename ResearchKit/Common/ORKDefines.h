/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import <Foundation/Foundation.h>


#if defined(__cplusplus)
#define ORK_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define ORK_EXTERN extern __attribute__((visibility("default")))
#endif


#define ORK_CLASS_AVAILABLE __attribute__((visibility("default")))
#define ORK_ENUM_AVAILABLE
#define ORK_AVAILABLE_DECL


/**
 You can use a permission mask to specify a set of permissions to acquire or
 that have been acquired for a task or step.
 */
typedef NS_OPTIONS(NSInteger, ORKPermissionMask) {
    /// No permissions.
    ORKPermissionNone                     = 0,
    
    /// Access to CoreMotion activity is required.
    ORKPermissionCoreMotionActivity       = (1 << 1),
    
    /// Access to CoreMotion accelerometer data.
    ORKPermissionCoreMotionAccelerometer  = (1 << 2),
    
    /// Access for audio recording.
    ORKPermissionAudioRecording           = (1 << 3),
    
    /// Access to location.
    ORKPermissionCoreLocation             = (1 << 4),
    
    /// Access to camera.
    ORKPermissionCamera                   = (1 << 5),
} ORK_ENUM_AVAILABLE;


/**
 File protection mode constants.
 
 The file protection mode constants correspond directly to `NSFileProtection` constants, but are
 more convenient to manipulate than strings. Complete file protection is
 highly recommended for files containing personal data that will be kept
 persistently.
 */
typedef NS_ENUM(NSInteger, ORKFileProtectionMode) {
    /// No file protection.
    ORKFileProtectionNone = 0,
    
    /// Complete file protection until first user authentication.
    ORKFileProtectionCompleteUntilFirstUserAuthentication,
    
    /// Complete file protection unless there was an open file handle before lock.
    ORKFileProtectionCompleteUnlessOpen,
    
    /// Complete file protection while the device is locked.
    ORKFileProtectionComplete
} ORK_ENUM_AVAILABLE;


/**
 Audio channel constants.
 */
typedef NS_ENUM(NSInteger, ORKAudioChannel) {
    /// The left audio channel.
    ORKAudioChannelLeft,
    
    /// The right audio channel.
    ORKAudioChannelRight
} ORK_ENUM_AVAILABLE;


/**
 Body side constants.
 */
typedef NS_ENUM(NSInteger, ORKBodySagittal) {
    /// The left side.
    ORKBodySagittalLeft,
    
    /// The right side.
    ORKBodySagittalRight
} ORK_ENUM_AVAILABLE;

/**
 Values that identify the presentation mode of paced serial addition tests that are auditory and/or visual (PSAT).
 */
typedef NS_OPTIONS(NSInteger, ORKPSATPresentationMode) {
    /// The PASAT (Paced Auditory Serial Addition Test).
    ORKPSATPresentationModeAuditory = 1 << 0,
    
    /// The PVSAT (Paced Visual Serial Addition Test).
    ORKPSATPresentationModeVisual = 1 << 1
} ORK_ENUM_AVAILABLE;


/**
 Identify the type of passcode authentication for `ORKPasscodeStepViewController`.
 */
typedef NS_ENUM(NSInteger, ORKPasscodeType) {
    /// 4 digit pin entry
    ORKPasscodeType4Digit,
    
    /// 6 digit pin entry
    ORKPasscodeType6Digit
} ORK_ENUM_AVAILABLE;


/**
 Progress indicator type for `ORKWaitStep`.
 */
typedef NS_ENUM(NSInteger, ORKProgressIndicatorType) {
    /// Spinner animation.
    ORKProgressIndicatorTypeIndeterminate = 0,
    
    /// Progressbar animation.
    ORKProgressIndicatorTypeProgressBar,
} ORK_ENUM_AVAILABLE;
