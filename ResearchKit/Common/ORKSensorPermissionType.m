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

#ifndef USE_SENSOR_KIT
#define USE_SENSOR_KIT 0
#endif


#if USE_SENSOR_KIT
#import <SensorKit/SensorKit.h>
#endif

#import "ORKSensorPermissionType.h"
#import "ORKHelpers_Internal.h"

static NSString *const Symbol = @"gauge";
static const uint32_t IconLightTintColor = 0xA278FE;
static const uint32_t IconDarkTintColor = 0x9D71F7;

@interface ORKSensorPermissionType ()

@property NSSet<SRSensor> *sensors;

@end

@implementation ORKSensorPermissionType {
#if USE_SENSOR_KIT
    NSSet<SRSensorReader *> *_readers;
#endif
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithSensors:(nonnull NSSet<SRSensor> *)sensors {
    NSAssert(sensors.count != 0, @"Sensors set must not be empty!");
    self = [super init];
    if (self) {
        self.sensors = sensors;
#if USE_SENSOR_KIT
        NSMutableSet *readers = [[NSMutableSet alloc] init];
        for (SRSensor sensor in sensors) {
            SRSensorReader *reader = [[SRSensorReader alloc] initWithSensor:sensor];
            [readers addObject:reader];
        }
        _readers = [readers copy];
#endif
    }
    return self;
}

- (NSString *)localizedTitle {
    return ORKLocalizedString(@"REQUEST_SENSOR_STEP_VIEW_TITLE", nil);
}

- (NSString *)localizedDetailText {
    return ORKLocalizedString(@"REQUEST_SENSOR_STEP_VIEW_DESCRIPTION", nil);
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
#if USE_SENSOR_KIT
    if ([self hasRequestedAllSensors]) {
        return ORKRequestPermissionsStateConnected;
    }
#endif
    return ORKRequestPermissionsStateDefault;
}

- (BOOL)canContinue {
    return self.permissionState == ORKRequestPermissionsStateConnected;
}

- (BOOL)hasRequestedAllSensors {
#if USE_SENSOR_KIT
    for (SRSensorReader *reader in _readers) {
        if (reader.authorizationStatus == SRAuthorizationStatusNotDetermined) {
            return NO;
        }
    }
    return YES;
#else
    return NO;
#endif
}

- (void)requestPermission {
#if USE_SENSOR_KIT
    [SRSensorReader requestAuthorizationForSensors:self.sensors completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                ORK_Log_Error("Error requesting sensor permissions: %@", error);
            }

            if (self.permissionsStatusUpdateCallback != nil) {
                self.permissionsStatusUpdateCallback();
            }
        });
    }];
#endif
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return ORKEqualObjects(self.sensors, castObject.sensors);
}

@end

#endif
