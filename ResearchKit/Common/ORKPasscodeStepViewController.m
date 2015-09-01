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


#import "ORKPasscodeStepViewController.h"
#import "ORKPasscodeStepView.h"
#import "ORKPasscodeStep.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKPasscodeStepViewController_Internal.h"
#import "ORKSkin.h"

#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>


typedef NS_ENUM(NSUInteger, ORKPasscodeState) {
    ORKPasscodeStateEntry,
    ORKPasscodeStateConfirm,
    ORKPasscodeStateSaved,
    ORKPasscodeStateOldEntry,
    ORKPasscodeStateNewEntry,
    ORKPasscodeStateConfirmNewEntry
};

@implementation ORKPasscodeStepViewController {
    ORKPasscodeStepView *_passcodeStepView;
    NSMutableString *_passcode;
    NSMutableString *_confirmPasscode;
    NSInteger _position;
    NSInteger _wrongAttemptsCount;
    ORKPasscodeState _passcodeState;
    BOOL _shouldResignFirstResponder;
    BOOL _isChangingState;
    BOOL _isTouchIDAuthenticated;
    LAContext *_touchContext;
}

+ (id)passcodeCreationViewControllerWithText:(NSString *)text
                                passcodeType:(ORKPasscodeType)passcodeType
                                    delegate:(id<ORKPasscodeCreationDelegate>)delegate
                        useTouchIdIfAvaiable:(BOOL)useTouchId {
    
    ORKPasscodeStep *step = [[ORKPasscodeStep alloc] initWithIdentifier:PasscodeStepIdentifier];
    step.text = text;
    
    ORKPasscodeStepViewController *passcodeStepViewController = [ORKPasscodeStepViewController new];
    passcodeStepViewController.passcodeFlow = ORKPasscodeFlowCreate;
    passcodeStepViewController.passcodeType = passcodeType;
    passcodeStepViewController.passcodeDelegate = delegate;
    passcodeStepViewController.useTouchId = useTouchId;
    passcodeStepViewController.step = step;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passcodeStepViewController];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = NO;
    
    return navigationController;
}

+ (id)passcodeAuthenticationViewControllerWithText:(NSString *)text
                                      passcodeType:(ORKPasscodeType)passcodeType
                                          delegate:(id<ORKPasscodeAuthenticationDelegate>)delegate
                              useTouchIdIfAvaiable:(BOOL)useTouchId {
    
    ORKPasscodeStep *step = [[ORKPasscodeStep alloc] initWithIdentifier:PasscodeStepIdentifier];
    step.text = text;
    
    ORKPasscodeStepViewController *passcodeStepViewController = [ORKPasscodeStepViewController new];
    passcodeStepViewController.passcodeFlow = ORKPasscodeFlowAuthenticate;
    passcodeStepViewController.passcodeType = passcodeType;
    passcodeStepViewController.passcodeDelegate = delegate;
    passcodeStepViewController.useTouchId = useTouchId;
    passcodeStepViewController.step = step;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passcodeStepViewController];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = NO;
    
    return navigationController;
}

+ (id)passcodeEditingViewControllerWithText:(NSString *)text
                               passcodeType:(ORKPasscodeType)passcodeType
                                   delegate:(id<ORKPasscodeEditingDelegate>)delegate
                        useTouchIdIfAvaiable:(BOOL)useTouchId {
    
    ORKPasscodeStep *step = [[ORKPasscodeStep alloc] initWithIdentifier:PasscodeStepIdentifier];
    step.text = text;
    
    ORKPasscodeStepViewController *passcodeStepViewController = [ORKPasscodeStepViewController new];
    passcodeStepViewController.passcodeFlow = ORKPasscodeFlowEdit;
    passcodeStepViewController.passcodeType = passcodeType;
    passcodeStepViewController.passcodeDelegate = delegate;
    passcodeStepViewController.useTouchId = useTouchId;
    passcodeStepViewController.step = step;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passcodeStepViewController];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = NO;
    
    return navigationController;
}

- (ORKPasscodeStep *)passcodeStep {
    return (ORKPasscodeStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_passcodeStepView removeFromSuperview];
    _passcodeStepView = nil;
    
    if (self.step && [self isViewLoaded]) {
        
        _passcode = [NSMutableString new];
        _confirmPasscode = [NSMutableString new];
        _position = 0;
        _wrongAttemptsCount = 1;
        _shouldResignFirstResponder = NO;
        _isChangingState = NO;
        _isTouchIDAuthenticated = NO;
        
        _passcodeStepView = [[ORKPasscodeStepView alloc] initWithFrame:self.view.bounds];
        _passcodeStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _passcodeStepView.textField.delegate = self;
        _passcodeStepView.headerView.instructionLabel.text = [self passcodeStep].text;
        _passcodeStepView.passcodeType = _passcodeType;
        [self.view addSubview:_passcodeStepView];
        
        // Set the starting state based on flow.
        if (_passcodeFlow == ORKPasscodeFlowEdit) {
            _passcodeState = ORKPasscodeStateOldEntry;
            [self updatePasscodeView];
        } else if (_passcodeFlow == ORKPasscodeFlowAuthenticate) {
            // Remove the cancel button.
            self.cancelButtonItem = nil;
            
            // Send the user a Touch ID prompt, if it is available.
            [self promptTouchId];
        }
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makePasscodeViewBecomeFirstResponder) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self makePasscodeViewBecomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self makePasscodeViewResignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)updatePasscodeView {
    
    switch (_passcodeState) {
        case ORKPasscodeStateEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_PROMPT_MESSAGE", nil);
            _position = 0;
            _wrongAttemptsCount = 1;
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateConfirm:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_CONFIRM_MESSAGE", nil);
            _position = 0;
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateSaved:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_SAVED_MESSAGE", nil);
            _passcodeStepView.textField.hidden = YES;
            _shouldResignFirstResponder = YES;
            [_passcodeStepView.textField resignFirstResponder];
            break;
            
        case ORKPasscodeStateOldEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_OLD_ENTRY_MESSAGE", nil);
            _position = 0;
            _wrongAttemptsCount = 1;
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateNewEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_NEW_ENTRY_MESSAGE", nil);
            _position = 0;
            _wrongAttemptsCount = 1;
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateConfirmNewEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_CONFIRM_NEW_ENTRY_MESSAGE", nil);
            _position = 0;
            _confirmPasscode = [NSMutableString new];
            break;
    }
    
    // Update the textField's text.
    NSString *text = (_passcodeStepView.passcodeType == ORKPasscodeType4Digit) ? k4DigitPin : k6DigitPin;
    _passcodeStepView.textField.text = text;
    
    // Enable input.
    _isChangingState = NO;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)makePasscodeViewBecomeFirstResponder{
    if (! _passcodeStepView.textField.isFirstResponder) {
        _shouldResignFirstResponder = NO;
        [_passcodeStepView.textField becomeFirstResponder];
    }
}

- (void)makePasscodeViewResignFirstResponder {
    if (_passcodeStepView.textField.isFirstResponder) {
        _shouldResignFirstResponder = YES;
        [_passcodeStepView.textField resignFirstResponder];
    }
}

- (void)showValidityAlertWithMessage:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_TITLE", nil)
                                                                   message:text
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OK", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)promptTouchId {
    NSError *authError = nil;
    _touchContext = [LAContext new];
    _touchContext.localizedFallbackTitle = @"";
    
    // Check to see if the device supports Touch ID.
    if (_useTouchId &&
        [_touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        
        NSString *localizedReason = ORKLocalizedString(@"PASSCODE_TOUCH_ID_MESSAGE", nil);
        [_touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:localizedReason
                                reply:^(BOOL success, NSError *error) {
                                        
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (success) {
                    // Store that user passed authentication.
                    _isTouchIDAuthenticated = YES;
                    
                    if (self.passcodeDelegate &&
                        [self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:didAuthenticateUsingTouchID:)]) {
                        [self.passcodeDelegate passcodeViewController:self
                                          didAuthenticateUsingTouchID:_isTouchIDAuthenticated];
                    }
                }
                
                if (error.code == kLAErrorUserCancel) {
                    [self makePasscodeViewBecomeFirstResponder];
                } else if (error) {
                    // Display the error message.
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                   message:error.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                 }
                
                if (self.passcodeDelegate &&
                    [self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:didFinishWithPasscode:andTouchIdEnabled:)]) {
                    [self.passcodeDelegate passcodeViewController:self
                                            didFinishWithPasscode:_passcode
                                                andTouchIdEnabled:_isTouchIDAuthenticated];
                }
            });
        }];
        
    } else {
        // Device does not support TouchID.
        if (self.passcodeDelegate &&
            [self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:didFinishWithPasscode:andTouchIdEnabled:)]) {
            [self.passcodeDelegate passcodeViewController:self
                                    didFinishWithPasscode:_passcode
                                        andTouchIdEnabled:_isTouchIDAuthenticated];
        }
    }
}

- (void)wrongAttempt {
    
    // Vibrate the device.
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // Shake animation.
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    shakeAnimation.keyPath = @"position.x";
    shakeAnimation.values = @[ @0, @15, @-15, @15, @-15, @0 ];
    shakeAnimation.keyTimes = @[ @0, @(1 / 8.0), @(3 / 8.0), @(5 / 8.0), @(7 / 8.0), @1 ];
    shakeAnimation.duration = 0.27;
    shakeAnimation.delegate = self;
    shakeAnimation.additive = YES;
    
    [_passcodeStepView.textField.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
    
    _wrongAttemptsCount++;
    
    // Update the passcode view after the shake animation has ended.
    double delayInSeconds = 0.27;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self updatePasscodeView];
    });
}

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    
    ORKPasscodeResult *passcodeResult = [[ORKPasscodeResult alloc] initWithIdentifier:[self passcodeStep].identifier];
    passcodeResult.passcode = _passcode;
    passcodeResult.touchIDAuthenticated = _isTouchIDAuthenticated;
    
    stepResult.results = @[passcodeResult];
    return stepResult;
}

#pragma mark - Passcode flows

- (void)passcodeFlowCreate {

    /* Passcode Flow Create
        1) ORKPasscodeStateEntry        - User enters a passcode.
        2) ORKPasscodeStateConfirm      - User re-enters the passcode.
        3) ORKSavedStateSaved           - User is shown a passcode saved message.
     */
    
    if (_passcodeState == ORKPasscodeStateEntry) {
        // Move to confirm state.
        _passcodeState = ORKPasscodeStateConfirm;
        [self updatePasscodeView];
    } else if (_passcodeState == ORKPasscodeStateConfirm) {
        // Check to see if the input matches the first passcode.
        if ([_passcode isEqualToString:_confirmPasscode]) {
            // Move to saved state.
            _passcodeState = ORKPasscodeStateSaved;
            [self updatePasscodeView];
            
            // Show Touch ID prompt after a short delay of showing passcode saved message.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self promptTouchId];
            });
            
        } else {
            // If the input does not match, notify the user.
            if (_wrongAttemptsCount < MaxAttempts) {
                [self wrongAttempt];
            } else {
                // Change back to entry state.
                _passcodeState = ORKPasscodeStateEntry;
                [self updatePasscodeView];
                
                // Show an alert to the user.
                [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_MESSAGE", nil)];
            }
        }
    }
}

- (void)passcodeFlowEdit {
    
    /* Passcode Flow Edit
        1) ORKPasscodeStateOldEntry                 - User enters their old passcode.
        2) ORKPasscodeStateNewEntry                 - User enters a new passcode.
        3) ORKPasscodeStateConfirmNewEntry          - User re-enters the new passcode.
        4) ORKPasscodeSaved                         - User is shown a passcode saved message.
     */
    
    if (_passcodeState == ORKPasscodeStateOldEntry) {
        // Check if the inputted passcode matches the old user passcode.
        if (self.passcodeDelegate &&
            [self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:isPasscodeValid:)]) {
            BOOL isValid = [self.passcodeDelegate passcodeViewController:self
                                                         isPasscodeValid:_passcode];
            
            if (isValid) {
                // Move to new entry step.
                _passcodeState = ORKPasscodeStateNewEntry;
                [self updatePasscodeView];
            } else {
                // Wrong attempt.
                [self wrongAttempt];
            }
        }
    } else if (_passcodeState == ORKPasscodeStateNewEntry) {
        // Move to confirm new entry state.
        _passcodeState = ORKPasscodeStateConfirmNewEntry;
        [self updatePasscodeView];
    } else if ( _passcodeState == ORKPasscodeStateConfirmNewEntry) {
        // Check to see if the input matches the first passcode.
        if ([_passcode isEqualToString:_confirmPasscode]) {
            // Move to saved state.
            _passcodeState = ORKPasscodeStateSaved;
            [self updatePasscodeView];
            
            // Show Touch ID prompt after a short delay of showing passcode saved message.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self promptTouchId];
            });
        } else {
            // If the input does not match, notify the user.
            if (_wrongAttemptsCount < MaxAttempts) {
                [self wrongAttempt];
            } else {
                // Change back to entry state.
                _passcodeState = ORKPasscodeStateNewEntry;
                [self updatePasscodeView];
                
                // Show an alert to the user.
                [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_MESSAGE", nil)];
            }
        }
    }
    
}

- (void)passcodeFlowAuthenticate {
    
    /* Passcode Flow Authenticate
        1) ORKPasscodeStateEntry                    - User enters their passcode.
     */
    
    if (_passcodeState == ORKPasscodeStateEntry) {
        if (self.passcodeDelegate &&
            [self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:isPasscodeValid:)]) {
            BOOL isValid = [self.passcodeDelegate passcodeViewController:self
                                                         isPasscodeValid:_passcode];
            if (isValid) {
                if ([self.passcodeDelegate respondsToSelector:@selector(passcodeViewController:didAuthenticateUsingTouchID:)]) {
                    [self.passcodeDelegate passcodeViewController:self
                                      didAuthenticateUsingTouchID:_isTouchIDAuthenticated];
                }
            } else {
                [self wrongAttempt];
            }

        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Disable input while changing states.
    if (_isChangingState) {
        return !_isChangingState;
    }
    
    // Store the typed input.
    if (_passcodeState == ORKPasscodeStateEntry ||
        _passcodeState == ORKPasscodeStateOldEntry ||
        _passcodeState == ORKPasscodeStateNewEntry) {
        [_passcode appendString:string];
    } else if (_passcodeState == ORKPasscodeStateConfirm ||
               _passcodeState == ORKPasscodeStateConfirmNewEntry) {
        [_confirmPasscode appendString:string];
    }
    
    // User entered a character.
    if (text.length < textField.text.length) {
        // User hit the backspace button.
        if (_position > 0) {
            _position--;
            textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(_position, 1) withString:kEmptyBullet];
        }

    } else if (_position < textField.text.length) {
        // User entered a new character.
        textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(_position, 1) withString:kFilledBullet];
        _position++;
    }
    
    // User entered all characters.
    if (_position == textField.text.length) {
        // Disable input.
        _isChangingState = YES;
    
        // Show the user the last digit was entered before continuing.
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            switch (_passcodeFlow) {
                case ORKPasscodeFlowCreate:
                    [self passcodeFlowCreate];
                    break;
                    
                case ORKPasscodeFlowEdit:
                    [self passcodeFlowEdit];
                    break;
                    
                case ORKPasscodeFlowAuthenticate:
                    [self passcodeFlowAuthenticate];
                    break;
            }
        });
    }
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return _shouldResignFirstResponder;
}

@end
