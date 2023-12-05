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

#import "ORKRequestPermissionButton.h"
#import "ORKHealthKitPermissionType.h"
#import "ORKHelpers_Internal.h"
#import "ORKRequestPermissionView.h"
#import <HealthKit/HealthKit.h>

static NSString *const Symbol = @"heart.fill";
static uint32_t const IconTintColor = 0xFF5E5E;

@implementation ORKHealthKitPermissionType

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

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

- (void)setupCardView {
    UIImage *image;
    
    if (@available(iOS 13.0, *)) {
        image = [UIImage systemImageNamed:Symbol];
    }
    
    self.cardView = [[ORKRequestPermissionView alloc] initWithIconImage:image
                                                                  title:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_TITLE", nil)
                                                             detailText:ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_DESCRIPTION", nil)];

    [self setState:ORKRequestPermissionsButtonStateDefault canContinue:NO];
    [self.cardView.requestPermissionButton addTarget:self action:@selector(requestPermissionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView updateIconTintColor:ORKRGB(IconTintColor)];
}

- (void)checkHealthKitAuthorizationStatus {
    if (![HKHealthStore isHealthDataAvailable]) {
        [self setState:ORKRequestPermissionsButtonStateNotSupported canContinue:YES];
        return;
    }

    if (@available(iOS 12.0, *)) {
        [[HKHealthStore new] getRequestStatusForAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(HKAuthorizationRequestStatus requestStatus, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{

                if (error) {
                    [self setState:ORKRequestPermissionsButtonStateDefault canContinue:NO];
                    return;
                }

                switch (requestStatus) {

                    case HKAuthorizationStatusSharingAuthorized:
                        [self setState:ORKRequestPermissionsButtonStateConnected canContinue:YES];
                        break;

                    case HKAuthorizationRequestStatusShouldRequest:
                    case HKAuthorizationRequestStatusUnknown:
                        [self setState:ORKRequestPermissionsButtonStateDefault canContinue:NO];
                        break;
                }
            });
        }];
    } else {
        [self setState:ORKRequestPermissionsButtonStateDefault canContinue:NO];
    }
}

- (void)requestPermissionButtonPressed {
    [[HKHealthStore new] requestAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{

            if (error) {
                [self setState:ORKRequestPermissionsButtonStateError canContinue:YES];
                return;
            }

            [self setState:ORKRequestPermissionsButtonStateConnected canContinue:YES];
        });
    }];
}

- (void)setState:(ORKRequestPermissionsButtonState)state canContinue:(BOOL)canContinue {
    [self.cardView setEnableContinueButton:canContinue];
    [self.cardView.requestPermissionButton setState:state];
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return
        ORKEqualObjects(self.objectTypesToRead, castObject.objectTypesToRead) &&
        ORKEqualObjects(self.sampleTypesToWrite, castObject.sampleTypesToWrite);
}

@end

