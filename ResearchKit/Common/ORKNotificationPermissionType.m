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


#import <UserNotifications/UserNotifications.h>

#import "ORKNotificationPermissionType.h"
#import "ORKHelpers_Internal.h"

static NSString *const Symbol = @"app.badge";
static const uint32_t IconLightTintColor = 0xFBD00B;
static const uint32_t IconDarkTintColor = 0xFFD005;

@implementation ORKNotificationPermissionType {
    ORKRequestPermissionsState _permissionState;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithAuthorizationOptions:(UNAuthorizationOptions)options {
    NSAssert(options != 0, @"Authorization options must not be empty!");
    self = [super init];
    if (self) {
        _options = options;
        _permissionState = ORKRequestPermissionsStateDefault;
        [self getInitialStatus];
    }
    return self;
}

- (NSString *)localizedTitle {
    return ORKLocalizedString(@"REQUEST_NOTIFICATIONS_STEP_VIEW_TITLE", nil);
}

- (NSString *)localizedDetailText {
    return ORKLocalizedString(@"REQUEST_NOTIFICATIONS_STEP_VIEW_DESCRIPTION", nil);
}

- (UIImage * _Nullable)image {
    return [UIImage systemImageNamed:Symbol];
}

- (UIColor *)iconTintColor {
    return [[UIColor alloc] initWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        return traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? ORKRGB(IconDarkTintColor) : ORKRGB(IconLightTintColor);
    }];
}

- (ORKRequestPermissionsState)permissionState {
    return _permissionState;
}

- (BOOL)canContinue {
    return self.permissionState == ORKRequestPermissionsStateConnected || self.permissionState == ORKRequestPermissionsStateError;
}

- (void)getInitialStatus {
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        dispatch_async(dispatch_get_main_queue(), ^{

            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                    _permissionState = ORKRequestPermissionsStateDefault;
                    break;

                case UNAuthorizationStatusEphemeral:
                case UNAuthorizationStatusAuthorized:
                case UNAuthorizationStatusProvisional:
                case UNAuthorizationStatusDenied:
                    _permissionState = ORKRequestPermissionsStateConnected;
                    break;
            }
            
            if (self.permissionsStatusUpdateCallback != nil) {
                self.permissionsStatusUpdateCallback();
            }
        });
    }];
}

- (void)requestPermission {
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions: self.options
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
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
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return (self.options & castObject.options) == self.options;
}

@end

#endif
