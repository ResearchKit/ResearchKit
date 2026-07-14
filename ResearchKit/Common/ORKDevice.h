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

#import <Foundation/Foundation.h>
#if TARGET_OS_IOS
#import <ResearchKit/ORKDefines.h>
#endif


NS_ASSUME_NONNULL_BEGIN

/// A snapshot of the current device and framework version information.
///
/// Use ``ORKDevice`` to capture device metadata at a point in time. This information
/// is useful for debugging and for correlating results with the device and OS version
/// on which they were collected.
ORK_CLASS_AVAILABLE
@interface ORKDevice : NSObject<NSSecureCoding, NSCopying>

/// Returns a snapshot of the current device's information.
///
/// - Returns: An ``ORKDevice`` instance populated with the current device, OS, and
///   ResearchKit version information.
+ (instancetype)currentDevice;

/// The marketing name of the device.
@property (nonatomic, copy, readonly, nullable) NSString *product;

/// The operating system version string.
@property (nonatomic, copy, readonly, nullable) NSString *osVersion;

/// The operating system build identifier.
@property (nonatomic, copy, readonly, nullable) NSString *osBuild;

/// The hardware platform identifier.
@property (nonatomic, copy, readonly, nullable) NSString *platform;

/// The ResearchKit framework version string.
@property (nonatomic, copy, readonly, nullable) NSString *researchKitVersion;

/// The ResearchKit framework bundle version string.
@property (nonatomic, copy, readonly, nullable) NSString *researchKitBundleVersion;

@end

NS_ASSUME_NONNULL_END
