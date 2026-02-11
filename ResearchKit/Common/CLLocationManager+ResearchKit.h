/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
#import <CoreLocation/CLLocationManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocationManager (ResearchKit)

/**
 These categories on CLLocationManager provide ResearchKit code with a common way of requesting authorization that can be disabled by
 an Xcode build setting. Callers don't have to add compile-time conditional #if blocks. Instead callers should interpret return value of YES to mean
 the authorization request was made, and NO to mean the ResearchKit binary was built with CLLocationManager authorization request calls
 compiled out.
 
 The impetus for this approach was to prevent apps using ResearchKit, but not ResearchKit's CoreLocation-powered features, from needlessly
 defining an NSLocationWhenInUseUsageDescription Info.plist entry to silence build errors.
 */
- (BOOL)ork_requestWhenInUseAuthorization;
- (BOOL)ork_requestAlwaysAuthorization;

- (void)ork_startUpdatingLocation;
- (void)ork_stopUpdatingLocation;

@end

NS_ASSUME_NONNULL_END
#endif
