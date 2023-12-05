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

#import "ORKAudioFitnessStep.h"
#import "ORKAudioFitnessStepViewController.h"
#import "ORKBundleAsset.h"
#import "ORKHelpers_Internal.h"

@implementation ORKVocalCue

- (instancetype)initWithTime:(NSTimeInterval)time
                  spokenText:(NSString *)spokenText {
    self = [super init];
    if (self) {
        self.time = time;
        self.spokenText = [spokenText copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self) {
        ORK_DECODE_DOUBLE(coder, time);
        ORK_DECODE_OBJ_CLASS(coder, spokenText, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    ORK_ENCODE_DOUBLE(coder, time);
    ORK_ENCODE_OBJ(coder, spokenText);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[ORKVocalCue alloc] initWithTime:self.time spokenText:self.spokenText];
}

- (BOOL)isEqual:(id)other
{
    if ([self class] != [other class]) {
        return NO;
    }

    __typeof(self) castObject = other;
    return (self.time == castObject.time &&
            ORKEqualObjects(self.spokenText, castObject.spokenText));
}

@end

@implementation ORKAudioFitnessStep

- (Class)stepViewControllerClass {
    return [ORKAudioFitnessStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                        audioAsset:(ORKBundleAsset *)audioAsset
                         vocalCues:(nullable NSArray<ORKVocalCue *> *)vocalCues {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.stepDuration = 180;
        self.shouldShowDefaultTimer = NO;
        self.audioAsset = [audioAsset copy];
        self.vocalCues = vocalCues == nil ? [NSArray new] : [vocalCues copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(coder, audioAsset, ORKBundleAsset);
        ORK_DECODE_OBJ_ARRAY(coder, vocalCues, ORKVocalCue);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    ORK_ENCODE_OBJ(coder, audioAsset);
    ORK_ENCODE_OBJ(coder, vocalCues);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKAudioFitnessStep *step = [super copyWithZone:zone];
    step.audioAsset = [self.audioAsset copy];
    step.vocalCues = [self.vocalCues copy];
    return step;
}

- (BOOL)isEqual:(id)other
{
    BOOL superIsEqual = [super isEqual:other];

    __typeof(self) castObject = other;
    return (superIsEqual &&
            ORKEqualObjects(self.audioAsset, castObject.audioAsset) &&
            ORKEqualObjects(self.vocalCues, castObject.vocalCues));
}

- (NSUInteger)hash
{
    return super.hash ^ self.audioAsset.hash ^ self.vocalCues.hash;
}

@end
