/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


#import "ORKSpeechInNoiseStep.h"
#import "ORKSpeechInNoiseStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKSpeechInNoiseDefaultNoiseFileName "Noise.wav"
#define ORKSpeechInNoiseDefaultFilterFileName "Window.wav"
#define ORKSpeechInNoiseDefaultSpeechFileName "Sentence1.wav"

@implementation ORKSpeechInNoiseStep

+ (Class)stepViewControllerClass {
    return [ORKSpeechInNoiseStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _willAudioLoop = NO;
    _noiseFileNameWithExtension = @ORKSpeechInNoiseDefaultNoiseFileName;
    _filterFileNameWithExtension = @ORKSpeechInNoiseDefaultFilterFileName;
    _speechFileNameWithExtension = @ORKSpeechInNoiseDefaultSpeechFileName;
}

- (void)validateParameters {
    [super validateParameters];
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpeechInNoiseStep *step = [super copyWithZone:zone];
    step.speechFileNameWithExtension = self.speechFileNameWithExtension;
    step.noiseFileNameWithExtension = self.noiseFileNameWithExtension;
    step.filterFileNameWithExtension = self.filterFileNameWithExtension;
    step.gainAppliedToNoise = self.gainAppliedToNoise;
    step.willAudioLoop = self.willAudioLoop;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, speechFileNameWithExtension);
        ORK_DECODE_OBJ(aDecoder, noiseFileNameWithExtension);
        ORK_DECODE_OBJ(aDecoder, filterFileNameWithExtension);
        ORK_DECODE_DOUBLE(aDecoder, gainAppliedToNoise);
        ORK_DECODE_BOOL(aDecoder, willAudioLoop);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, speechFileNameWithExtension);
    ORK_ENCODE_OBJ(aCoder, noiseFileNameWithExtension);
    ORK_ENCODE_OBJ(aCoder, filterFileNameWithExtension);
    ORK_ENCODE_DOUBLE(aCoder, gainAppliedToNoise);
    ORK_ENCODE_BOOL(aCoder, willAudioLoop);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.speechFileNameWithExtension, castObject.speechFileNameWithExtension)
            && ORKEqualObjects(self.noiseFileNameWithExtension, castObject.noiseFileNameWithExtension)
            && ORKEqualObjects(self.filterFileNameWithExtension, castObject.filterFileNameWithExtension)
            && (self.gainAppliedToNoise == castObject.gainAppliedToNoise)
            && (self.willAudioLoop == castObject.willAudioLoop));
}

@end

