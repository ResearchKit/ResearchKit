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
#import "ORKPasscodeStep.h"
#import "ORKPasscodeStepView.h"
#import "ORKStepViewController_Internal.h"
#import "ORKTaskViewController_Internal.h"
#import <AudioToolbox/AudioToolbox.h>

typedef enum : NSUInteger {
    ORKPasscodeStateEntry,
    ORKPasscodeStateConfirm,
    ORKPasscodeStateSaved
} ORKPasscodeState;

@implementation ORKPasscodeStepViewController {
    ORKPasscodeStepView *_passcodeStepView;
    NSString *_passcode;
    NSInteger _position;
    NSInteger _wrongAttemptsCount;
    ORKPasscodeState _passcodeState;
    BOOL _shouldResignFirstResponder;
    BOOL _isChangingState;
}

- (ORKPasscodeStep *)passcodeStep {
    return (ORKPasscodeStep *)self.step;
}

- (void)stepDidChange {
    [super stepDidChange];
    
    [_passcodeStepView removeFromSuperview];
    _passcodeStepView = nil;
    
    if (self.step && [self isViewLoaded]) {
        
        _position = 0;
        _wrongAttemptsCount = 1;
        _shouldResignFirstResponder = NO;
        _isChangingState = NO;
        
        _passcodeStepView = [[ORKPasscodeStepView alloc] initWithFrame:self.view.bounds];
        _passcodeStepView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _passcodeStepView.passcodeType = ORKPasscodeType4Digit;
        _passcodeStepView.textField.delegate = self;
        [self.view addSubview:_passcodeStepView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makePasscodeViewBecomeFirstResponder) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self makePasscodeViewBecomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _shouldResignFirstResponder = YES;
    [_passcodeStepView.textField endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepDidChange];
}

- (void)updatePasscodeView {
    
    if (_passcodeState == ORKPasscodeStateEntry) {
        
        // Show an enter message.
        _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_PROMPT_MESSAGE", nil);
        _position = 0;
        _wrongAttemptsCount = 1;
        _passcode = nil;

    } else if (_passcodeState == ORKPasscodeStateConfirm) {

        // Show a confirm passcode message.
        _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_CONFIRM_MESSAGE", nil);
        _position = 0;
        
    } else if (_passcodeState == ORKPasscodeStateSaved) {
        
        // Show a saved message.
        _passcodeStepView.textField.hidden = YES;
        _passcodeStepView.headerView.captionLabel.text = ORKLocalizedString(@"PASSCODE_SAVED_MESSAGE", nil);
     
        // Resign the first responder.
        _shouldResignFirstResponder = YES;
        [_passcodeStepView.textField resignFirstResponder];
    }
    
    // Update the textField's text.
    NSString *text = (_passcodeStepView.passcodeType == ORKPasscodeType4Digit) ? k4DigitPin : k6DigitPin;
    _passcodeStepView.textField.text = text;

}

- (void)initializeInternalButtonItems {
    [super initializeInternalButtonItems];
    
    self.internalContinueButtonItem = nil;
    self.internalDoneButtonItem = nil;
}

- (void)makePasscodeViewBecomeFirstResponder{
    [_passcodeStepView.textField becomeFirstResponder];
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

# pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // Disable input while changing states.
    if (_isChangingState) {
        return !_isChangingState;
    }
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range
                                                             withString:string];
    
    // User entered a character.
    if (text.length < textField.text.length) {
        // User hit the backspace button.
 
        if (_position > 0) {
            _position--;
        }

        NSString *string = [textField.text stringByReplacingCharactersInRange:NSMakeRange(_position, 1) withString:kEmptyBullet];
        textField.text = string;

    } else if (_position < textField.text.length) {
        // User entered a new character.
    
        NSString *string = [textField.text stringByReplacingCharactersInRange:NSMakeRange(_position, 1) withString:kFilledBullet];
        textField.text = string;

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
            
            if (_passcodeState == ORKPasscodeStateEntry) {
                
                // Store the passcode and move to confirm state.
                _passcodeState = ORKPasscodeStateConfirm;
                _passcode = text;
                [self updatePasscodeView];
                
            } else {
            
                // Check to see if the input matches the first passcode.
                if ([_passcode isEqualToString:text]) {
                    
                    // Since the input matches, store the answer.
                    [[self passcodeStep] setPasscode:_passcode];
                
                    // Move to saved state.
                    _passcodeState = ORKPasscodeStateSaved;
                    [self updatePasscodeView];
                    
                    // Navigate to the next step after a short delay of showing passcode saved message.
                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self goForward];
                    });
                    
                } else {
                    
                    // Vibrate the phone.
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    
                    // If the input does not match, notify the user.
                    if (_wrongAttemptsCount < 5) {
                        CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
                        shakeAnimation.keyPath = @"position.x";
                        shakeAnimation.values = @[ @0, @15, @-15, @15, @-15, @0 ];
                        shakeAnimation.keyTimes = @[ @0, @(1 / 8.0), @(3 / 8.0), @(5 / 8.0), @(7 / 8.0), @1 ];
                        shakeAnimation.duration = 0.27;
                        shakeAnimation.delegate = self;
                        shakeAnimation.additive = YES;
                        
                        [textField.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
                        
                        [self updatePasscodeView];
                        
                        _wrongAttemptsCount++;
                        
                    } else {
                        
                        // Change back to entry state.
                        _passcodeState = ORKPasscodeStateEntry;
                        [self updatePasscodeView];
                        
                        // Show an alert to the user.
                        [self showValidityAlertWithMessage:ORKLocalizedString(@"PASSCODE_INVALID_ALERT_MESSAGE", nil)];

                    }
                    
                }
            }
            
            // Enable input.
            _isChangingState = NO;
        });
    }
    
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return _shouldResignFirstResponder;
}

@end
