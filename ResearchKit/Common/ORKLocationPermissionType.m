/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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


#import "ORKLocationPermissionType.h"
#import "ORKHelpers_Internal.h"

#import <CoreLocation/CLLocationManagerDelegate.h>
#import <ResearchKit/CLLocationManager+ResearchKit.h>

static NSString *const Symbol = @"location.circle";
static const uint32_t IconLightTintColor = 0x50C878;
static const uint32_t IconDarkTintColor = 0x00A36C;

@interface ORKLocationPermissionType()  <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@end

@implementation ORKLocationPermissionType

+ (instancetype)new {
    return [[ORKLocationPermissionType alloc] init];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
    }
    return _locationManager;
}

- (NSString *)localizedTitle {
    return ORKLocalizedString(@"REQUEST_LOCATION_DATA_STEP_VIEW_TITLE", nil);
}

- (NSString *)localizedDetailText {
    return ORKLocalizedString(@"REQUEST_LOCATION_DATA_STEP_VIEW_DESCRIPTION", nil);
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
    switch (CLLocationManager.authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            return ORKRequestPermissionsStateDefault;

        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return ORKRequestPermissionsStateConnected;
    }
}

- (BOOL)canContinue {
    return self.permissionState == ORKRequestPermissionsStateConnected;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.permissionsStatusUpdateCallback != nil) {
        self.permissionsStatusUpdateCallback();
    }
}

// Request for always permission.
- (void)requestPermission {
    [self.locationManager requestAlwaysAuthorization];
    
    BOOL requestWasDelivered = [self.locationManager ork_requestAlwaysAuthorization];
    
    // if the auth request was not delivered, that means ResearchKit was built with CoreLocation requests disabled
    // Presenting the location permission step in this case is probably programmer error
    NSAssert(requestWasDelivered, @"Tried to invoke -[CLLocationManager requestAlwaysAuthorization] but ResearchKit was compiled with CoreLocation authorization requests disabled. This is a programmer error. Check build settings for ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION");
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

@end

#endif
