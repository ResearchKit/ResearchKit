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


#import "ORKMotionActivityPermissionType.h"
#import "ORKHelpers_Internal.h"

@import CoreMotion;

static NSString *const Symbol = @"arrow.right.arrow.left.circle";
static const uint32_t IconLightTintColor = 0xEF72D8;
static const uint32_t IconDarkTintColor = 0xEF6FD8;

@interface ORKMotionActivityPermissionType()
@property (nonatomic) CMMotionActivityManager *activityManager;
@property (nonatomic, readonly, assign) ORKRequestPermissionsState permissionState;
@property (nonatomic, readonly, assign) BOOL canContinue;
@end

@implementation ORKMotionActivityPermissionType

+ (instancetype)new {
    return [[ORKMotionActivityPermissionType alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (CMMotionActivityManager *)activityManager {
    if (!_activityManager) {
        _activityManager = [[CMMotionActivityManager alloc] init];
    }
    return _activityManager;
}

- (NSString *)localizedTitle {
    return ORKLocalizedString(@"REQUEST_MOTION_ACTIVITY_STEP_VIEW_TITLE", nil);
}

- (NSString *)localizedDetailText {
    return ORKLocalizedString(@"REQUEST_MOTION_ACTIVITY_STEP_VIEW_DESCRIPTION", nil);
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
    switch (CMMotionActivityManager.authorizationStatus) {
        case CMAuthorizationStatusNotDetermined:
            return ORKRequestPermissionsStateDefault;

        case CMAuthorizationStatusDenied:
        case CMAuthorizationStatusAuthorized:
        case CMAuthorizationStatusRestricted:
            return ORKRequestPermissionsStateConnected;
    }
}

- (BOOL)canContinue {
    return self.permissionState == ORKRequestPermissionsStateConnected;
}

// There is no explicit API for requesting device motion permission.
// It is requested automatically when you try read data for the first time.
// This method tries to read data in order to trigger the permission dialogue.
- (void)requestPermission {
    [self.activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                          withHandler:^(CMMotionActivity * _Nullable activity) {}];
    [self.activityManager stopActivityUpdates];
    if (self.permissionsStatusUpdateCallback != nil) {
        self.permissionsStatusUpdateCallback();
    }
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

@end

#endif
