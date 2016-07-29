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
#import "ORKPasscodeStepViewController_Internal.h"
#import "ORKStepViewController_Internal.h"
#import "ORKPasscodeStepView.h"
#import "ORKPasscodeStep.h"
#import "ORKKeychainWrapper.h"
#import "ORKHelpers.h"

#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>

static CGFloat const kForgotPasscodeVerticalPadding     = 50.0f;
static CGFloat const kForgotPasscodeHorizontalPadding   = 30.0f;
static CGFloat const kForgotPasscodeHeight              = 100.0f;

@implementation ORKPasscodeStepViewController {
    ORKPasscodeStepView *_passcodeStepView;
    CGFloat _originalForgotPasscodeY;
    UIButton* _forgotPasscodeButton;
    UITextField *_accessibilityPasscodeField;
    NSMutableString *_passcode;
    NSMutableString *_confirmPasscode;
    NSInteger _numberOfFilledBullets;
    ORKPasscodeState _passcodeState;
    BOOL _shouldResignFirstResponder;
    BOOL _isChangingState;
    BOOL _isTouchIdAuthenticated;
    BOOL _isPasscodeSaved;
    LAContext *_touchContext;
    ORKPasscodeType _authenticationPasscodeType;
    BOOL _useTouchId;
}

- (ORKPasscodeStep *)passcodeStep {
    return (ORKPasscodeStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_accessibilityPasscodeField removeFromSuperview];
    _accessibilityPasscodeField = nil;
    
    [_passcodeStepView removeFromSuperview];
    _passcodeStepView = nil;
    
    if (self.step && [self isViewLoaded]) {
        
        _accessibilityPasscodeField = [UITextField new];
        _accessibilityPasscodeField.hidden = YES;
        _accessibilityPasscodeField.delegate = self;
        _accessibilityPasscodeField.secureTextEntry = YES;
        _accessibilityPasscodeField.keyboardType = UIKeyboardTypeNumberPad;
        [self.view addSubview:_accessibilityPasscodeField];
        
        _passcodeStepView = [[ORKPasscodeStepView alloc] initWithFrame:self.view.bounds];
        _passcodeStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _passcodeStepView.headerView.instructionLabel.text = [self passcodeStep].text;
        _passcodeStepView.textField.delegate = self;
        [self.view addSubview:_passcodeStepView];
        
        _passcode = [NSMutableString new];
        _confirmPasscode = [NSMutableString new];
        _numberOfFilledBullets = 0;
        _shouldResignFirstResponder = NO;
        _isChangingState = NO;
        _isTouchIdAuthenticated = NO;
        _isPasscodeSaved = NO;
        _useTouchId = YES;
        
        // If this has text, we should add the forgot passcode button with this title
        if ([self hasForgotPasscode]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
            
            CGFloat x = kForgotPasscodeHorizontalPadding;
            _originalForgotPasscodeY = self.view.bounds.size.height - kForgotPasscodeVerticalPadding - kForgotPasscodeHeight;
            CGFloat width = self.view.bounds.size.width - 2 * kForgotPasscodeHorizontalPadding;

            UIButton *forgotPasscodeButton = [ORKTextButton new];
            forgotPasscodeButton.contentEdgeInsets = (UIEdgeInsets){12, 10, 8, 10};
            forgotPasscodeButton.frame = CGRectMake(x, _originalForgotPasscodeY, width, kForgotPasscodeHeight);
            
            NSString *buttonTitle = [self forgotPasscodeButtonText];
            [forgotPasscodeButton setTitle:buttonTitle forState:UIControlStateNormal];
            [forgotPasscodeButton addTarget:self
                                     action:@selector(forgotPasscodeTapped)
                           forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:forgotPasscodeButton];            
            _forgotPasscodeButton = forgotPasscodeButton;
        }
        
        // Set the starting passcode state and textfield based on flow.
        switch (_passcodeFlow) {
            case ORKPasscodeFlowCreate:
                [self removePasscodeFromKeychain];
                _passcodeStepView.textField.numberOfDigits = [self numberOfDigitsForPasscodeType:[self passcodeStep].passcodeType];
                [self changeStateTo:ORKPasscodeStateEntry];
                break;
                
            case ORKPasscodeFlowAuthenticate:
                [self setValuesFromKeychain];
                _passcodeStepView.textField.numberOfDigits = [self numberOfDigitsForPasscodeType:_authenticationPasscodeType];
                [self changeStateTo:ORKPasscodeStateEntry];
                break;
                
            case ORKPasscodeFlowEdit:
                [self setValuesFromKeychain];
                _passcodeStepView.textField.numberOfDigits = [self numberOfDigitsForPasscodeType:_authenticationPasscodeType];
                [self changeStateTo:ORKPasscodeStateOldEntry];
                break;
        }
        
        // If Touch ID was enabled then present it for authentication flow.
        if (_useTouchId &&
            self.passcodeFlow == ORKPasscodeFlowAuthenticate) {
            [self promptTouchId];
        }
        
        // Check to see if cancel button should be set or not.
        if (self.passcodeDelegate &&
            [self.passcodeDelegate respondsToSelector:@selector(passcodeViewControllerDidCancel:)]) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_CANCEL", nil)
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(cancelButtonAction)];
        }
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(makePasscodeViewBecomeFirstResponder)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_shouldResignFirstResponder) {
        [self makePasscodeViewBecomeFirstResponder];
    }
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
            _numberOfFilledBullets = 0;
            _accessibilityPasscodeField.text = @"";
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateConfirm:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_CONFIRM_MESSAGE", nil);
            _numberOfFilledBullets = 0;
            _accessibilityPasscodeField.text = @"";
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateSaved:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_SAVED_MESSAGE", nil);
            _passcodeStepView.headerView.instructionLabel.text = @"";
            _passcodeStepView.textField.hidden = YES;
            [self makePasscodeViewResignFirstResponder];
            break;
            
        case ORKPasscodeStateOldEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_OLD_ENTRY_MESSAGE", nil);
            _numberOfFilledBullets = 0;
            _accessibilityPasscodeField.text = @"";
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateNewEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_NEW_ENTRY_MESSAGE", nil);
            _numberOfFilledBullets = 0;
            _accessibilityPasscodeField.text = @"";
            _passcode = [NSMutableString new];
            _confirmPasscode = [NSMutableString new];
            break;
            
        case ORKPasscodeStateConfirmNewEntry:
            _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_CONFIRM_NEW_ENTRY_MESSAGE", nil);
            _numberOfFilledBullets = 0;
            _accessibilityPasscodeField.text = @"";
            _confirmPasscode = [NSMutableString new];
            break;
    }
    
    // Regenerate the textField.
    [_passcodeStepView.textField updateTextWithNumberOfFilledBullets:_numberOfFilledBullets];
    
    // Enable input.
    _isChangingState = NO;
}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
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

- (ORKStepResult *)result {
    ORKStepResult *stepResult = [super result];
    NSDate *now = stepResult.endDate;
    
    ORKPasscodeResult *passcodeResult = [[ORKPasscodeResult alloc] initWithIdentifier:[self passcodeStep].identifier];
    passcodeResult.passcodeSaved = _isPasscodeSaved;
    passcodeResult.startDate = stepResult.startDate;
    passcodeResult.endDate = now;
    
    stepResult.results = @[passcodeResult];
    return stepResult;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[ORKPasscodeStepViewController class] supportedInterfaceOrientations];
}

+ (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Helpers

- (void)changeStateTo:(ORKPasscodeState)passcodeState {
    _passcodeState = passcodeState;
    [self updatePasscodeView];
}

- (NSInteger)numberOfDigitsForPasscodeType:(ORKPasscodeType)passcodeType {
    switch (passcodeType) {
        case ORKPasscodeType4Digit:
            return 4;
        case ORKPasscodeType6Digit:
            return 6;
    }
}

- (void)cancelButtonAction {
    if (self.passcodeDelegate &&
        [self.passcodeDelegate respondsToSelector:@selector(passcodeViewControllerDidCancel:)]) {
        [self.passcodeDelegate passcodeViewControllerDidCancel:self];
    }
}

- (void)makePasscodeViewBecomeFirstResponder {
    _shouldResignFirstResponder = NO;
    if (![_accessibilityPasscodeField isFirstResponder]) {
        [_accessibilityPasscodeField becomeFirstResponder];
    }
}

- (void)makePasscodeViewResignFirstResponder {
    _shouldResignFirstResponder = YES;
    if ([_accessibilityPasscodeField isFirstResponder]) {
        [_accessibilityPasscodeField resignFirstResponder];
    }
}

- (void)promptTouchId {
    _touchContext = [LAContext new];
    _touchContext.localizedFallbackTitle = @"";
    
    // Check to see if the device supports Touch ID.
    if (_useTouchId &&
        [_touchContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        /// Device does support Touch ID.
        
        // Resign the keyboard to allow the alert to be centered on the screen.
        [self makePasscodeViewResignFirstResponder];
        
        NSString *localizedReason = ORKLocalizedString(@"PASSCODE_TOUCH_ID_MESSAGE", nil);
        ORKWeakTypeOf(self) weakSelf = self;
        [_touchContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:localizedReason
                                reply:^(BOOL success, NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                ORKStrongTypeOf(self) strongSelf = weakSelf;
                
                if (success) {
                    // Store that user passed authentication.
                    _isTouchIdAuthenticated = YES;
                    
                    // Send a delegate callback for authentication flow.
                    if (strongSelf.passcodeFlow == ORKPasscodeFlowAuthenticate) {
                        [strongSelf.passcodeDelegate passcodeViewControllerDidFinishWithSuccess:strongSelf];
                    }
                } else if (error.code != LAErrorUserCancel) {
                    // Display the error message.
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ORKLocalizedString(@"PASSCODE_TOUCH_ID_ERROR_ALERT_TITLE", nil)
                                                                                   message:error.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:ORKLocalizedString(@"BUTTON_OK", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                ORKStrongTypeOf(self) strongSelf = weakSelf;
                                                                [strongSelf makePasscodeViewBecomeFirstResponder];
                                                            }]];
                    [strongSelf presentViewController:alert animated:YES completion:nil];
                } else if (error.code == LAErrorUserCancel) {
                    [strongSelf makePasscodeViewBecomeFirstResponder];
                }
                
                [strongSelf finishTouchId];
            });
        }];
        
    } else {
        /// Device does not support Touch ID.
        [self finishTouchId];
    }
}

- (void)promptTouchIdWithDelay {
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        [strongSelf promptTouchId];
    });
}

- (void)finishTouchId {
    // Only save to keychain if it is not in authenticate flow.
    if (!(self.passcodeFlow == ORKPasscodeFlowAuthenticate)) {
        [self savePasscodeToKeychain];
        
        if (self.passcodeFlow == ORKPasscodeFlowCreate) {
            // If it is in creation flow (consent step), go to the next step.
            [self goForward];
        } else if (self.passcodeFlow == ORKPasscodeFlowEdit) {
            // If it is in editing flow, send a delegate callback.
            [self.passcodeDelegate passcodeViewControllerDidFinishWithSuccess:self];
        }
    }
}

- (void)savePasscodeToKeychain {
    [[self class] savePasscode:_passcode withTouchIdEnabled:_isTouchIdAuthenticated];
    _isPasscodeSaved = YES;     // otherwise an exception would have been thrown
}

+ (void)savePasscode:(NSString *)passcode withTouchIdEnabled:(BOOL)touchIdEnabled {
    ORKThrowInvalidArgumentExceptionIfNil(passcode)
    NSDictionary *dictionary = @{
                                 KeychainDictionaryPasscodeKey: [passcode copy],
                                 KeychainDictionaryTouchIdKey: @(touchIdEnabled)
                                 };
    NSError *error;
    [ORKKeychainWrapper setObject:dictionary forKey:PasscodeKey error:&error];
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedDescription userInfo:nil];
    }
}

- (void)removePasscodeFromKeychain {
    NSError *error;
    [ORKKeychainWrapper objectForKey:PasscodeKey error:&error];
    
    if (!error) {
        [ORKKeychainWrapper removeObjectForKey:PasscodeKey error:&error];
    
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedDescription userInfo:nil];
        }
    }
}

- (BOOL)passcodeMatchesKeychain {
    NSError *error;
    NSDictionary *dictionary = (NSDictionary *) [ORKKeychainWrapper objectForKey:PasscodeKey error:&error];
    if (error) {
        [self throwExceptionWithKeychainError:error];
    }
    
    NSString *storedPasscode = dictionary[KeychainDictionaryPasscodeKey];
    return [storedPasscode isEqualToString:_passcode];
}

- (void)setValuesFromKeychain {
    NSError *error;
    NSDictionary *dictionary = (NSDictionary*) [ORKKeychainWrapper objectForKey:PasscodeKey error:&error];
    if (error) {
        [self throwExceptionWithKeychainError:error];
    }
    
    NSString *storedPasscode = dictionary[KeychainDictionaryPasscodeKey];
    _authenticationPasscodeType = (storedPasscode.length == 4) ? ORKPasscodeType4Digit : ORKPasscodeType6Digit;
    
    if (self.passcodeFlow == ORKPasscodeFlowAuthenticate) {
        _useTouchId = [dictionary[KeychainDictionaryTouchIdKey] boolValue];
    }
}

- (void)wrongAttempt {
    
    // Vibrate the device, if available.
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
    
    // Update the passcode view after the shake animation has ended.
    double delayInSeconds = 0.27;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    ORKWeakTypeOf(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ORKStrongTypeOf(self) strongSelf = weakSelf;
        [strongSelf updatePasscodeView];
    });
}

- (void)throwExceptionWithKeychainError:(NSError *)error {
    NSString *errorReason = error.localizedDescription;
    if (error.code == errSecItemNotFound) {
        errorReason = @"There is no passcode stored in the keychain.";
    }
    @throw [NSException exceptionWithName:NSGenericException reason:errorReason userInfo:nil];
}

#pragma mark - Passcode flows

- (void)passcodeFlowCreate {

    /* Passcode Flow Create
        1) ORKPasscodeStateEntry        - User enters a passcode.
        2) ORKPasscodeStateConfirm      - User re-enters the passcode.
        3) ORKSavedStateSaved           - User is shown a passcode saved message.
        4) TouchID                      - A Touch ID prompt is shown.
     */
    
    if (_passcodeState == ORKPasscodeStateEntry) {
        // Move to confirm state.
        [self changeStateTo:ORKPasscodeStateConfirm];
    } else if (_passcodeState == ORKPasscodeStateConfirm) {
        // Check to see if the input matches the first passcode.
        if ([_passcode isEqualToString:_confirmPasscode]) {
            // Move to saved state.
            [self changeStateTo:ORKPasscodeStateSaved];
            
            // Show Touch ID prompt after a short delay of showing passcode saved message.
            [self promptTouchIdWithDelay];
        } else {
            // Visual cue.
            [self wrongAttempt];
            
            // If the input does not match, change back to entry state.
            [self changeStateTo:ORKPasscodeStateEntry];
            
            // Show an alert to the user.
            [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_MESSAGE", nil)];
        }
    }
}

- (void)passcodeFlowEdit {
    
    /* Passcode Flow Edit
        1) ORKPasscodeStateOldEntry                 - User enters their old passcode.
        2) ORKPasscodeStateNewEntry                 - User enters a new passcode.
        3) ORKPasscodeStateConfirmNewEntry          - User re-enters the new passcode.
        4) ORKPasscodeSaved                         - User is shown a passcode saved message.
        5) TouchID                                  - A Touch ID prompt is shown.
     */
    
    if (_passcodeState == ORKPasscodeStateOldEntry) {
        // Check if the inputted passcode matches the old user passcode.
        if ([self passcodeMatchesKeychain]) {
            // Move to new entry step.
            _passcodeStepView.textField.numberOfDigits = [self numberOfDigitsForPasscodeType:[self passcodeStep].passcodeType];
            [self changeStateTo:ORKPasscodeStateNewEntry];
        } else {
            // Failed authentication, send delegate callback.
            [self.passcodeDelegate passcodeViewControllerDidFailAuthentication:self];
                
            // Visual cue.
            [self wrongAttempt];
        }
    } else if (_passcodeState == ORKPasscodeStateNewEntry) {
        // Move to confirm new entry state.
        [self changeStateTo:ORKPasscodeStateConfirmNewEntry];
    } else if ( _passcodeState == ORKPasscodeStateConfirmNewEntry) {
        // Check to see if the input matches the first passcode.
        if ([_passcode isEqualToString:_confirmPasscode]) {
            // Move to saved state.
            [self changeStateTo:ORKPasscodeStateSaved];
            
            // Show Touch ID prompt after a short delay of showing passcode saved message.
            [self promptTouchIdWithDelay];
        } else {
            // Visual cue.
            [self wrongAttempt];
            
            // If the input does not match, change back to entry state.
            [self changeStateTo:ORKPasscodeStateNewEntry];
            
            // Show an alert to the user.
            [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_MESSAGE", nil)];
        }
    }
    
}

- (void)passcodeFlowAuthenticate {
    
    /* Passcode Flow Authenticate
        1) TouchID                                  - A Touch ID prompt is shown.
        1) ORKPasscodeStateEntry                    - User enters their passcode.
     */
    
    if (_passcodeState == ORKPasscodeStateEntry) {
        if ([self passcodeMatchesKeychain]) {
            // Passed authentication, send delegate callback.
            [self.passcodeDelegate passcodeViewControllerDidFinishWithSuccess:self];
        } else {
            // Failed authentication, send delegate callback.
            [self.passcodeDelegate passcodeViewControllerDidFailAuthentication:self];
                
            // Visual cue.
            [self wrongAttempt];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    ORKPasscodeTextField *passcodeTextField = _passcodeStepView.textField;
    [passcodeTextField insertText:string];

    // Disable input while changing states.
    if (_isChangingState) {
        return !_isChangingState;
    }
    
    NSString *text = [passcodeTextField.text stringByReplacingCharactersInRange:range withString:string];
    
    // User entered a character.
    if (text.length < passcodeTextField.text.length) {
        // User hit the backspace button.
        if (_numberOfFilledBullets > 0) {
            _numberOfFilledBullets--;
            
            // Remove last character
            if (_passcodeState == ORKPasscodeStateEntry ||
                _passcodeState == ORKPasscodeStateOldEntry ||
                _passcodeState == ORKPasscodeStateNewEntry) {
                [_passcode deleteCharactersInRange:NSMakeRange([_passcode length]-1, 1)];
            } else if (_passcodeState == ORKPasscodeStateConfirm ||
                       _passcodeState == ORKPasscodeStateConfirmNewEntry) {
                [_confirmPasscode deleteCharactersInRange:NSMakeRange([_confirmPasscode length]-1, 1)];
            }
        }
    } else if (_numberOfFilledBullets < passcodeTextField.numberOfDigits) {
        // Only allow numeric characters besides backspace (covered by the previous if statement).
        if (![[NSScanner scannerWithString:string] scanFloat:NULL]) {
            [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_TEXTFIELD_INVALID_INPUT_MESSAGE", nil)];
            return NO;
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
        
        // User entered a new character.
        _numberOfFilledBullets++;
    }
    [passcodeTextField updateTextWithNumberOfFilledBullets:_numberOfFilledBullets];
    
    // User entered all characters.
    if (_numberOfFilledBullets == passcodeTextField.numberOfDigits) {
        // Disable input.
        _isChangingState = YES;
        
        // Show the user the last digit was entered before continuing.
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        ORKWeakTypeOf(self) weakSelf = self;
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            
            switch (_passcodeFlow) {
                case ORKPasscodeFlowCreate:
                    [strongSelf passcodeFlowCreate];
                    break;
                    
                case ORKPasscodeFlowAuthenticate:
                    [strongSelf passcodeFlowAuthenticate];
                    break;
                    
                case ORKPasscodeFlowEdit:
                    [strongSelf passcodeFlowEdit];
                    break;
            }
        });
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return _shouldResignFirstResponder;
}

- (void)forgotPasscodeTapped {
    if ([self.passcodeDelegate respondsToSelector:@selector(passcodeViewControllerForgotPasscodeTapped:)]) {
        [self.passcodeDelegate passcodeViewControllerForgotPasscodeTapped:self ];
    }
}

- (BOOL)hasForgotPasscode {
    if ((self.passcodeFlow == ORKPasscodeFlowAuthenticate) &&
        [self.passcodeDelegate respondsToSelector:@selector(passcodeViewControllerForgotPasscodeTapped:)]) {
        return YES;
    }
    return NO;
}

- (NSString *)forgotPasscodeButtonText {
    if ([self.passcodeDelegate respondsToSelector:@selector(passcodeViewControllerTextForForgotPasscode:)]) {
        return [self.passcodeDelegate passcodeViewControllerTextForForgotPasscode: self];
    }
    return ORKLocalizedString(@"PASSCODE_FORGOT_BUTTON_TITLE", @"Prompt for user forgetting their passcode");
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [_forgotPasscodeButton setFrame:CGRectMake(_forgotPasscodeButton.frame.origin.x, _originalForgotPasscodeY - keyboardHeight, _forgotPasscodeButton.frame.size.width, _forgotPasscodeButton.frame.size.height)];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    double animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:animationDuration animations:^{
         [_forgotPasscodeButton setFrame:CGRectMake(_forgotPasscodeButton.frame.origin.x, _originalForgotPasscodeY, _forgotPasscodeButton.frame.size.width, _forgotPasscodeButton.frame.size.height)];
     }];
}

@end
