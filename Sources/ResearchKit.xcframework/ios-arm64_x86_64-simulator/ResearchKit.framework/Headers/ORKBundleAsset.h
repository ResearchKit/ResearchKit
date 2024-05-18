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
#import <ResearchKit/ORKDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Describes an asset available in a bundle, locally on the device.
 */
ORK_CLASS_AVAILABLE
@interface ORKBundleAsset : NSObject<NSSecureCoding, NSCopying>

/// The file name of the resource, excluding the file extension.
@property (nonatomic, copy) NSString *name;

/// The bundle identifier for the bundle that contains the asset. If this is not set,
/// the main bundle identifier will be used.
@property (nonatomic, copy, nullable) NSString *bundleIdentifier;

/// An optional file extension that may be used for disambiguation.
@property (nonatomic, copy, nullable) NSString *fileExtension;

- (instancetype)initWithName:(NSString *) name
            bundleIdentifier:(nullable NSString *) bundleIdentifier
               fileExtension:(nullable NSString *) fileExtension;

- (nullable NSURL*)url;

@end
NS_ASSUME_NONNULL_END
