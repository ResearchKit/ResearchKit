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

#if !TARGET_OS_VISION


#import "ORKHealthKitPermissionType.h"
#import "ORKHelpers_Internal.h"

#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
#import <HealthKit/HealthKit.h>
#endif

static NSString *const Symbol = @"heart.fill";
static uint32_t const IconTintColor = 0xFF5E5E;

@implementation ORKHealthKitPermissionType {
    ORKRequestPermissionsState _permissionState;
}

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
        [self checkHealthKitAuthorizationStatus];
    }
    
    return self;
}

- (NSString *)localizedTitle {
    return ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_TITLE", nil);
}

- (NSString *)localizedDetailText {
    return ORKLocalizedString(@"REQUEST_HEALTH_DATA_STEP_VIEW_DESCRIPTION", nil);
}

- (UIImage * _Nullable)image {
    return [UIImage systemImageNamed:Symbol];
}

- (UIColor *)iconTintColor {
    return ORKRGB(IconTintColor);
}

- (ORKRequestPermissionsState) permissionState {
    return _permissionState;
}

- (void)checkHealthKitAuthorizationStatus {
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    if (![HKHealthStore isHealthDataAvailable]) {
        _permissionState = ORKRequestPermissionsStateNotSupported;
        if (self.permissionsStatusUpdateCallback != nil) {
            self.permissionsStatusUpdateCallback();
        }
        return;
    }
    
    [[HKHealthStore new] getRequestStatusForAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(HKAuthorizationRequestStatus requestStatus, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                _permissionState = ORKRequestPermissionsStateError;
            } else switch (requestStatus) {
                case HKAuthorizationStatusSharingAuthorized:
                    _permissionState = ORKRequestPermissionsStateConnected;
                    break;

                case HKAuthorizationRequestStatusShouldRequest:
                case HKAuthorizationRequestStatusUnknown:
                    _permissionState = ORKRequestPermissionsStateDefault;
                    break;
            }
            if (self.permissionsStatusUpdateCallback != nil) {
                self.permissionsStatusUpdateCallback();
            }

        });
    }];
#endif // ORK_FEATURE_HEALTHKIT_AUTHORIZATION

}

- (BOOL)canContinue {
    BOOL result = self.permissionState == ORKRequestPermissionsStateConnected
              || self.permissionState == ORKRequestPermissionsStateNotSupported
              || self.permissionState == ORKRequestPermissionsStateError;
    return result;
}

- (void)requestPermission {
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
    [[HKHealthStore new] requestAuthorizationToShareTypes:_sampleTypesToWrite readTypes:_objectTypesToRead completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                _permissionState = ORKRequestPermissionsStateError;
            } else {
                _permissionState = ORKRequestPermissionsStateConnected;
            }
            if (self.permissionsStatusUpdateCallback != nil) {
                self.permissionsStatusUpdateCallback();
            }
        });
    }];
#endif // ORK_FEATURE_HEALTHKIT_AUTHORIZATION
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


#endif
