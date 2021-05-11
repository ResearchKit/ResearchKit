/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import "ORKHealthKitPermissionType.h"
#import "ORKHelpers_Internal.h"
#import "ORKRequestPermissionView.h"

typedef NS_CLOSED_ENUM(NSInteger, ORKRequestPermissionsButtonState) {
    ORKRequestPermissionsButtonStateDefault = 0,
    ORKRequestPermissionsButtonStateConnected,
    ORKRequestPermissionsButtonStateNotSupported,
    ORKRequestPermissionsButtonStateError,
} ORK_ENUM_AVAILABLE;

@implementation ORKHealthKitPermissionType {
    UIButton *_requestPermissionButton;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

#if HEALTH
- (instancetype)initWithSampleTypesToWrite:(NSSet<HKSampleType *> *)sampleTypesToWrite objectTypesToRead:(NSSet<HKObjectType *> *)objectTypesToRead {
    self = [super init];
    
    if (self) {
        self.sampleTypesToWrite = sampleTypesToWrite;
        self.objectTypesToRead = objectTypesToRead;
        [self setupCardView];
        [self checkHealthKitAuthorizationStatus];
    }
    
    return self;
}
#endif

- (void)setupCardView {
    UIImage *image;
    
    if (@available(iOS 13.0, *)) {
        image = [UIImage systemImageNamed:@"heart.fill"];
    }
    
    self.cardView = [[ORKRequestPermissionView alloc] initWithIconImage:image
                                                                  title:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_TITLE", nil)
                                                             detailText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_DESCRIPTION", nil)];
    
    _requestPermissionButton = self.cardView.requestPermissionButton;
    [_requestPermissionButton addTarget:self action:@selector(requestPermissionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cardView updateIconTintColor:[UIColor redColor]];
}

- (void)checkHealthKitAuthorizationStatus {
#if HEALTH
    if (![HKHealthStore isHealthDataAvailable]) {
        [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateNotSupported];
        return;
    }
    
    if (@available(iOS 12.0, *)) {
        [[HKHealthStore new] getRequestStatusForAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(HKAuthorizationRequestStatus requestStatus, NSError * _Nullable error) {
            if (error) {
                [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateError];
                return;
            }
            
            if (requestStatus == HKAuthorizationRequestStatusShouldRequest) {
                [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateDefault];
            } else if (requestStatus == HKAuthorizationRequestStatusUnnecessary) {
                [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateConnected];
            }
        }];
    } else {
        [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateDefault];
    }
#endif
}

- (void)setRequestPermissionsButtonState:(ORKRequestPermissionsButtonState)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case ORKRequestPermissionsButtonStateDefault:
                [self updateRequestButtonWithText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_BUTTON_STATE_DEFAULT", nil) backgroundColor:[UIColor systemBlueColor]];
                [self setEnableContinue:NO];
                break;
                
            case ORKRequestPermissionsButtonStateConnected:
                [self updateRequestButtonWithText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_BUTTON_STATE_CONNECTED", nil) backgroundColor:[UIColor grayColor]];
                [self setEnableContinue:YES];
                break;
                
            case ORKRequestPermissionsButtonStateNotSupported:
                [self updateRequestButtonWithText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_BUTTON_STATE_NOT_SUPPORTED", nil) backgroundColor:[UIColor redColor]];
                [self setEnableContinue:YES];
                break;
                
            case ORKRequestPermissionsButtonStateError:
                [self updateRequestButtonWithText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_BUTTON_STATE_ERROR", nil) backgroundColor:[UIColor redColor]];
                [self setEnableContinue:YES];
                break;
                
            default:
                break;
        }
    });
}

- (void)updateRequestButtonWithText:(NSString *)text backgroundColor:(UIColor *)backgroundColor {
    if (_requestPermissionButton) {
        [_requestPermissionButton setTitle:text forState:UIControlStateNormal];
        [_requestPermissionButton setBackgroundColor:backgroundColor];
    }
    
}

- (void)requestPermissionButtonPressed {
#if HEALTH
    [[HKHealthStore new] requestAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(BOOL success, NSError * _Nullable error) {
        
        if (error) {
            [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateError];
            return;
        }
        
        if (success) {
            [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateConnected];
        } else {
            [self setRequestPermissionsButtonState:ORKRequestPermissionsButtonStateError];
        }
    }];
#endif
}

- (void)setEnableContinue:(BOOL)enableContinue {
    if (self.cardView) {
        [self.cardView setEnableContinueButton:enableContinue];
    }
}

@end

