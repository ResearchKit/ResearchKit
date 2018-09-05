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


#import "ORKSpeechRecognitionStep.h"

#import "ORKSpeechRecognitionStepViewController.h"

#import "ORKStep_Private.h"

#import "ORKHelpers_Internal.h"


@implementation ORKSpeechRecognitionStep {
    UIImage *_speechRecognitionImage;
    NSString *_text;
}

+ (Class)stepViewControllerClass {
    return [ORKSpeechRecognitionStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier image:(nullable UIImage *)image text:(nullable NSString *)text {
    self = [super initWithIdentifier:identifier];
    _speechRecognitionImage = image;
    _text = text;
    _speechRecognizerLocale = ORKSpeechRecognizerLocaleEnglishUS;
    return self;
}

- (void)validateParameters {
    [super validateParameters];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpeechRecognitionStep *step = [super copyWithZone:zone];
    step.speechRecognizerLocale = self.speechRecognizerLocale;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, speechRecognizerLocale);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, speechRecognizerLocale);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.speechRecognizerLocale == castObject.speechRecognizerLocale));
}

- (BOOL)allowsBackNavigation {
    return NO;
}

- (BOOL)startsFinished {
    return NO;
}

- (BOOL)shouldContinueOnFinish {
    return YES;
}

- (nullable UIImage *)speechRecognitionImage {
    return _speechRecognitionImage;
}

- (nullable NSString *)speechRecognitionText {
    return _text;
}

@end

