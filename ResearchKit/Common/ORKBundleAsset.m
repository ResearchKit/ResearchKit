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

#import "ORKBundleAsset.h"
#import "ORKHelpers_Internal.h"

@implementation ORKBundleAsset

- (instancetype)initWithName:(NSString *)name
            bundleIdentifier:(NSString *)bundleIdentifier
               fileExtension:(NSString *)fileExtension {
    self = [super init];
    if (self) {
        self.name = name;
        self.bundleIdentifier = bundleIdentifier;
        self.fileExtension = fileExtension;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(coder, name, NSString);
        ORK_DECODE_OBJ_CLASS(coder, bundleIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(coder, fileExtension, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    ORK_ENCODE_OBJ(coder, name);
    ORK_ENCODE_OBJ(coder, bundleIdentifier);
    ORK_ENCODE_OBJ(coder, fileExtension);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[ORKBundleAsset alloc] initWithName:self.name bundleIdentifier:self.bundleIdentifier fileExtension:self.fileExtension];
}

- (BOOL)isEqual:(id)other {
    if ([self class] != [other class]) {
        return NO;
    }

    __typeof(self) castObject = other;
    return (ORKEqualObjects(self.name, castObject.name) &&
            ORKEqualObjects(self.bundleIdentifier, castObject.bundleIdentifier) &&
            ORKEqualObjects(self.fileExtension, castObject.fileExtension));
}

- (NSUInteger)hash {
    return self.name.hash ^ self.bundleIdentifier.hash ^ self.fileExtension.hash;
}

- (nullable NSURL *)url {
    NSBundle *bundle = (self.bundleIdentifier) ?
        [NSBundle bundleWithIdentifier:self.bundleIdentifier] :
        [NSBundle mainBundle];

    NSURL *url = [bundle URLForResource:self.name withExtension:self.fileExtension];
    return url;
}

@end
