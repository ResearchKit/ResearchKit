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


#import <ResearchKit/ORKRecorder.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKStep;

/**
 The `ORKTouchRecorderConfiguration` is a recorder configuration class for
 generating an `ORKTouchRecorder`.
 
 It is currently considered private, and is not used in any of the active tasks.
 */
ORK_CLASS_AVAILABLE
@interface ORKTouchRecorderConfiguration : ORKRecorderConfiguration

/**
 Returns an initialized touch recorder configuration.
 
 This method is the designated initializer.
 
 @param identifier   The unique identifier of the recorder configuration.
 
 @return An initialized touch recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new touch recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the touch recorder configuration.
 
 @return A new touch recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


@interface ORKRecorder ()

/**
 Returns an initialized recorder.
 
 This method is the designated initializer.
 
 @param identifier          The unique identifier of the recorder.
 @param step                The step for which this recorder is being created.
 @param outputDirectory     The directory in which all output file data should be written (if producing `ORKFileResult` instances).
 
 @return An initialized recorder.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier step:(nullable ORKStep *)step outputDirectory:(nullable NSURL *)outputDirectory;

/**
 A preparation step to provide viewController and view before record starting.
 
 The step view controller should call this method before starting the recorder,
 so that recorders that need a view or gesture recognizer in order to function
 can attach themselves.
 
 @param viewController  The view controller that is about to 'start'
 @param view            Primary active view for the step.
 */
- (void)viewController:(UIViewController *)viewController willStartStepWithView:(nullable UIView *)view;

/**
 Indicates that recording has failed; stop recording and report the error to the
 delegate
 
 @param error       Error that occurred.
 */
- (void)finishRecordingWithError:(nullable NSError *)error;

/**
 Helper for subclasses to request that file protection be applied to a file on disk.
 
 This method is exposed to facilitate unit testing.
 
 @param fileProtection  Level of file protection desired
 @param url             URL of file to protect.
 */
- (void)applyFileProtection:(ORKFileProtectionMode)fileProtection toFileAtURL:(NSURL *)url;

@end


@interface ORKRecorderConfiguration ()

/**
 Returns an initialized recorder configuration.
 
 This method is the designated initializer.
 
 @param identifier   The unique identifier of the recorder configuration.
 
 @return An initialized recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the recorder configuration.
 
 @return A new recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 Returns the permission mask indicating the permissions required for this configuration.
 
 This method is typically overridden in new recorder configuration subclasses.
 */
- (ORKPermissionMask)requestedPermissionMask;

@end

NS_ASSUME_NONNULL_END
