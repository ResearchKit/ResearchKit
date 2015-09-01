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


#import <ResearchKit/ORKStepViewController.h>
#import <ResearchKit/ORKDefines.h>

NS_ASSUME_NONNULL_BEGIN


/**
 The passcode creation delegate protocol declares methods which forward the success of passcode 
 creation with or without Touch ID.
 */
ORK_AVAILABLE_DECL
@protocol ORKPasscodeCreationDelegate <NSObject>

@required
/**
 Notifies the delegate that the user has finished setting up passcode with or without Touch ID.
 
 @param viewController      The `ORKPasscodeStepViewController` object in which the gesture occurred.
 @param passcode            A string containing the passcode entered by the user.
 @param touchId             A boolean indicating whether Touch Id was enabled or not.
 */
- (void)passcodeViewController:(UIViewController *)viewController didFinishWithPasscode:(NSString *)passcode andTouchIdEnabled:(BOOL)touchId;

@end


/**
 The passcode authentication delegate protocol declares methods which forward the raw passcode input
 for validation and authentication of the passcode with or without Touch Id.
 */
ORK_AVAILABLE_DECL
@protocol ORKPasscodeAuthenticationDelegate <NSObject>

@required
/**
 Notifies the delegate that the user has finished entering their passcode.
 
 @param viewController      The `ORKPasscodeStepViewController` object in which the gesture occurred.
 @param passcode            A string containing the passcode entered by the user.
 */
- (BOOL)passcodeViewController:(UIViewController *)viewController isPasscodeValid:(NSString *)passcode;

/**
 Notifies the delegate that the user was authenticated.
 
 @param viewController      The `ORKPasscodeStepViewController` object in which the gesture occurred.
 @param touchId             A boolean indicating if the authentication was performed with Touch ID or not.
 */
- (void)passcodeViewController:(UIViewController *)viewController didAuthenticateUsingTouchID:(BOOL)touchId;

@end


/**
 The passcode editing delegate protocol declares methods which forward the raw passcode input for validation 
 and the success of passcode creation with or without Touch Id.
 */
ORK_AVAILABLE_DECL
@protocol ORKPasscodeEditingDelegate <NSObject>

@required
/**
 Notifies the delegate that the user has finished entering their passcode.
 
 @param viewController      The `ORKPasscodeStepViewController` object in which the gesture occurred.
 @param passcode            A string containing the passcode entered by the user.
 */
- (BOOL)passcodeViewController:(UIViewController *)viewController isPasscodeValid:(NSString *)passcode;

/**
 Notifies the delegate that the user has finished setting up passcode with or without Touch ID.
 
 @param viewController      The `ORKPasscodeStepViewController` object in which the gesture occurred.
 @param passcode            A string containing the passcode entered by the user.
 @param touchId             A boolean indicating whether Touch Id was enabled or not.
 */
- (void)passcodeViewController:(UIViewController *)viewController didFinishWithPasscode:(NSString *)passcode andTouchIdEnabled:(BOOL)touchId;

@end


/**
 An `ORKPasscodeStepViewController` object is the view controller for an `ORKPasscodeStep` object.
 
 A passcode view controller can be instanstiated indirectly by adding a passcode step to a consent task 
 and present the task using a task view controller. When appropriate, the task view controller instantiates the step
 view controller for the step.
 
 A passcode view controller can also be instantiated directly by using one of the factory methods below.
 Each factory method requires a delegate to be implemented.
 */
ORK_CLASS_AVAILABLE
@interface ORKPasscodeStepViewController : ORKStepViewController

+ (id)passcodeCreationViewControllerWithText:(NSString *)text
                                passcodeType:(ORKPasscodeType)passcodeType
                                    delegate:(id<ORKPasscodeCreationDelegate>)delegate
                        useTouchIdIfAvaiable:(BOOL)useTouchId;

+ (id)passcodeAuthenticationViewControllerWithText:(NSString *)text
                                      passcodeType:(ORKPasscodeType)passcodeType
                                          delegate:(id<ORKPasscodeAuthenticationDelegate>)delegate
                              useTouchIdIfAvaiable:(BOOL)useTouchId;

+ (id)passcodeEditingViewControllerWithText:(NSString *)text
                               passcodeType:(ORKPasscodeType)passcodeType
                                   delegate:(id<ORKPasscodeEditingDelegate>)delegate
                       useTouchIdIfAvaiable:(BOOL)useTouchId;

@end

NS_ASSUME_NONNULL_END
