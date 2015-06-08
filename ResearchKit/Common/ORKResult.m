/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKResult.h"
#import "ORKTask.h"
#import "ORKResult_Private.h"
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "ORKRecorder.h"
#import "ORKStep.h"
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKQuestionStep.h"
#import "ORKFormStep.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKConsentDocument.h"
#import "ORKConsentSignature.h"


@implementation ORKResult

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
    }
    return self;
}

- (BOOL)isSaveable {
    return NO;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_OBJ(aCoder, startDate);
    ORK_ENCODE_OBJ(aCoder, endDate);
    ORK_ENCODE_OBJ(aCoder, userInfo);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, startDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, endDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, userInfo, NSDictionary);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && ORKEqualObjects(self.startDate, castObject.startDate)
            && ORKEqualObjects(self.endDate, castObject.endDate)
            && ORKEqualObjects(self.userInfo, castObject.userInfo));
}

- (NSUInteger)hash {
    return [_identifier hash] ^ [_startDate hash] ^ [_endDate hash] ^ [_userInfo hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKResult *result = [[[self class] allocWithZone:zone] init];
    result.startDate = [self.startDate copy];
    result.endDate = [self.endDate copy];
    result.userInfo = [self.userInfo copy];
    result.identifier = [self.identifier copy];
    return result;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.startDate = [NSDate date];
        self.endDate = [NSDate date];
    }
    return self;
}

@end


@implementation ORKTappingSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_CGPOINT(aCoder, location);
    ORK_ENCODE_ENUM(aCoder, buttonIdentifier);

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_CGPOINT(aDecoder, location);
        ORK_DECODE_ENUM(aDecoder, buttonIdentifier);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    
    return ((self.timestamp == castObject.timestamp) &&
            CGPointEqualToPoint(self.location, castObject.location) &&
            (self.buttonIdentifier == castObject.buttonIdentifier));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTappingSample *sample = [[[self class] allocWithZone:zone] init];
    sample.timestamp = self.timestamp;
    sample.location = self.location;
    sample.buttonIdentifier = self.buttonIdentifier;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %.03f %@", [super description], @(self.buttonIdentifier), self.timestamp, NSStringFromCGPoint(self.location)];
}

@end


@implementation ORKToneAudiometryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, outputVolume);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, outputVolume);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKToneAudiometrySample);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.outputVolume, castObject.outputVolume) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return [super hash] ^ [self.samples hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKToneAudiometryResult *result = [super copyWithZone:zone];
    result.outputVolume = [self.outputVolume copy];
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@", [super description], self.outputVolume, self.samples];
}

@end


@implementation ORKToneAudiometrySample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, frequency);
    ORK_ENCODE_ENUM(aCoder, channel);
    ORK_ENCODE_OBJ(aCoder, amplitude);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, frequency);
        ORK_DECODE_ENUM(aDecoder, channel);
        ORK_DECODE_OBJ(aDecoder, amplitude);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;

    return ((self.channel == castObject.channel) &&
            ([self.frequency isEqualToNumber:castObject.frequency]) &&
            ([self.amplitude isEqualToNumber:castObject.amplitude])) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKToneAudiometrySample *sample = [[[self class] allocWithZone:zone] init];
    sample.frequency = self.frequency;
    sample.channel = self.channel;
    sample.amplitude = self.amplitude;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@", [super description], self.frequency, @(self.channel), self.amplitude];
}

@end


@implementation ORKSpatialSpanMemoryGameTouchSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_INTEGER(aCoder, targetIndex);
    ORK_ENCODE_CGPOINT(aCoder, location);
    ORK_ENCODE_BOOL(aCoder, correct);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_INTEGER(aDecoder, targetIndex);
        ORK_DECODE_CGPOINT(aDecoder, location);
        ORK_DECODE_BOOL(aDecoder, correct);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return ((self.timestamp == castObject.timestamp) &&
            (self.targetIndex == castObject.targetIndex) &&
            (CGPointEqualToPoint(self.location, castObject.location)) &&
            (self.isCorrect == castObject.isCorrect));
}

- (NSUInteger)hash {
    return [super hash] ^ [self targetIndex] ^ [self isCorrect];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryGameTouchSample *sample = [[[self class] allocWithZone:zone] init];
    sample.timestamp = self.timestamp;
    sample.targetIndex = self.targetIndex;
    sample.location = self.location;
    sample.correct = self.isCorrect;
    
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@", [super description], @(self.timestamp), @(self.targetIndex), NSStringFromCGPoint(self.location), @(self.isCorrect)];
}

@end


@implementation ORKSpatialSpanMemoryGameRecord

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_UINT32(aCoder, seed);
    ORK_ENCODE_OBJ(aCoder, sequence);
    ORK_ENCODE_INTEGER(aCoder, gameSize);
    ORK_ENCODE_OBJ(aCoder, touchSamples);
    ORK_ENCODE_INTEGER(aCoder, gameStatus);
    ORK_ENCODE_INTEGER(aCoder, score);
    ORK_ENCODE_OBJ(aCoder, targetRects);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_UINT32(aDecoder, seed);
        ORK_DECODE_OBJ_ARRAY(aDecoder, sequence, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, gameSize);
        ORK_DECODE_OBJ_ARRAY(aDecoder, touchSamples, ORKSpatialSpanMemoryGameTouchSample);
        ORK_DECODE_INTEGER(aDecoder, gameStatus);
        ORK_DECODE_INTEGER(aDecoder, score);
        ORK_DECODE_OBJ_ARRAY(aDecoder, targetRects, NSValue);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return ((self.seed == castObject.seed) &&
            (ORKEqualObjects(self.sequence, castObject.sequence)) &&
            (ORKEqualObjects(self.touchSamples, castObject.touchSamples)) &&
            (self.gameSize == castObject.gameSize) &&
            (self.gameStatus == castObject.gameStatus) &&
            (self.score == castObject.score) &&
            (ORKEqualObjects(self.targetRects, castObject.targetRects)));
}

- (NSUInteger)hash {
    return [super hash] ^ [self seed] ^ [self gameSize] ^ [self score] ^ [self gameStatus];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryGameRecord *record = [[[self class] allocWithZone:zone] init];
    record.seed = self.seed;
    record.sequence = [self.sequence copyWithZone:zone];
    record.touchSamples = [self.touchSamples copyWithZone:zone];
    record.gameSize = self.gameSize;
    record.gameStatus = self.gameStatus;
    record.score = self.score;
    record.targetRects = [self.targetRects copyWithZone:zone];
    return record;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@", [super description], @(self.seed), self.sequence, @(self.gameSize), @(self.gameStatus), @(self.score)];
}

@end


@implementation ORKSpatialSpanMemoryResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, score);
    ORK_ENCODE_INTEGER(aCoder, numberOfGames);
    ORK_ENCODE_INTEGER(aCoder, numberOfFailures);
    ORK_ENCODE_OBJ(aCoder, gameRecords);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, score);
        ORK_DECODE_INTEGER(aDecoder, numberOfGames);
        ORK_DECODE_INTEGER(aDecoder, numberOfFailures);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gameRecords, ORKSpatialSpanMemoryGameRecord);
        
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.score == castObject.score) &&
            (self.numberOfGames == castObject.numberOfGames) &&
            (self.numberOfFailures == castObject.numberOfFailures) &&
            (ORKEqualObjects(self.gameRecords, castObject.gameRecords)));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryResult *result = [super copyWithZone:zone];
    result.score = self.score;
    result.numberOfGames = self.numberOfGames;
    result.numberOfFailures = self.numberOfFailures;
    result.gameRecords = [self.gameRecords copyWithZone:zone];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ score=%@", [super description], @(self.score)];
}

@end


@implementation ORKTappingIntervalResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, samples);
    ORK_ENCODE_CGRECT(aCoder, buttonRect1);
    ORK_ENCODE_CGRECT(aCoder, buttonRect2);
    ORK_ENCODE_CGSIZE(aCoder, stepViewSize);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKTappingSample);
        ORK_DECODE_CGRECT(aDecoder, buttonRect1);
        ORK_DECODE_CGRECT(aDecoder, buttonRect2);
        ORK_DECODE_CGSIZE(aDecoder, stepViewSize);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.samples, castObject.samples) &&
            CGRectEqualToRect(self.buttonRect1, castObject.buttonRect1) &&
            CGRectEqualToRect(self.buttonRect2, castObject.buttonRect2) &&
            CGSizeEqualToSize(self.stepViewSize, castObject.stepViewSize));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.samples hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTappingIntervalResult *result = [super copyWithZone:zone];
    result.samples = [self.samples copy];
    result.buttonRect1 = self.buttonRect1;
    result.buttonRect2 = self.buttonRect2;
    result.stepViewSize = self.stepViewSize;
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", [super description], self.samples];
}

@end


@implementation ORKFileResult

- (BOOL)isSaveable {
    return (_fileURL!=nil);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_URL(aCoder, fileURL);
    ORK_ENCODE_OBJ(aCoder, contentType);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_URL(aDecoder, fileURL);
        ORK_DECODE_OBJ_CLASS(aDecoder, contentType, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualFileURLs(self.fileURL, castObject.fileURL) &&
            ORKEqualObjects(self.contentType, castObject.contentType));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.fileURL hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKFileResult *result = [super copyWithZone:zone];
    result.fileURL = [self.fileURL copy];
    result.contentType = [self.contentType copy];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ (%lld bytes)", [super description], self.fileURL, [[[NSFileManager defaultManager] attributesOfItemAtPath:[self.fileURL path] error:nil] fileSize]];
}

@end


@implementation ORKReactionTimeResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_OBJ(aCoder, fileResult);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_OBJ_CLASS(aDecoder, fileResult, ORKFileResult);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.timestamp == castObject.timestamp) &&
            ORKEqualObjects(self.fileResult, castObject.fileResult)) ;
}

- (NSUInteger)hash {
    return [super hash] ^ [[NSNumber numberWithDouble:self.timestamp] hash] ^ [self.fileResult hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKReactionTimeResult *result = [super copyWithZone:zone];
    result.fileResult = [self.fileResult copy];
    result.timestamp = self.timestamp;
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %f %@", [super description], self.timestamp, self.fileResult.description];
}

@end


@implementation ORKDataResult

- (BOOL)isSaveable {
    return (_data != nil);
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, data);
    ORK_ENCODE_OBJ(aCoder, filename);
    ORK_ENCODE_OBJ(aCoder, contentType);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, data, NSData);
        ORK_DECODE_OBJ_CLASS(aDecoder, filename, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, contentType, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.data, castObject.data) &&
            ORKEqualObjects(self.filename, castObject.filename) &&
            ORKEqualObjects(self.contentType, castObject.contentType));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.filename hash] ^ [self.contentType hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKDataResult *result = [super copyWithZone:zone];
    result.data = self.data;
    result.filename = self.filename;
    result.contentType = self.contentType;

    return result;
}
                                
@end


@implementation ORKConsentSignatureResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, signature);
    ORK_ENCODE_BOOL(aCoder, consented);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, signature, ORKConsentSignature);
        ORK_DECODE_BOOL(aDecoder, consented);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKConsentSignatureResult *result = [super copyWithZone:zone];
    result.signature = _signature;
    result.consented = _consented;
    return result;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.signature, castObject.signature) &&
            (self.consented == castObject.consented));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.signature hash];
}

- (void)applyToDocument:(ORKConsentDocument *)document {
    __block NSUInteger indexToBeReplaced = NSNotFound;
    [[document signatures] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ORKConsentSignature *signature = obj;
        if ([signature.identifier isEqualToString:self.signature.identifier]) {
            indexToBeReplaced = idx;
            *stop = YES;
        }
    }];
    
    if(indexToBeReplaced != NSNotFound) {
        NSMutableArray *signatures = [[document signatures] mutableCopy];
        signatures[indexToBeReplaced] = [_signature copy];
        document.signatures = signatures;
    }
}

@end


@implementation ORKQuestionResult

- (BOOL)isSaveable {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, questionType);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, questionType);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (_questionType == castObject.questionType));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.answer hash] ^ _questionType;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKQuestionResult *result = [super copyWithZone:zone];
    result.questionType = self.questionType;
    return result;
}

- (id)validateAnswer:(id)answer {
    if (answer == ORKNullAnswerValue()) {
        answer = nil;
    }
    NSParameterAssert(!answer || [answer isKindOfClass:[[self class] answerClass]]);
    return answer;
}

+ (Class)answerClass {
    return nil;
}

- (void)setAnswer:(id)answer {
}

- (id)answer {
    return nil;
}

@end


@implementation ORKScaleQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, scaleAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, scaleAnswer, NSNumber);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_scaleAnswer, castObject.scaleAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKScaleQuestionResult *result = [super copyWithZone:zone];
    result->_scaleAnswer = [self.scaleAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.scaleAnswer = answer;
}

- (id)answer {
    return self.scaleAnswer;
}

@end


@implementation ORKChoiceQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, choiceAnswers);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, choiceAnswers, NSObject);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_choiceAnswers, castObject.choiceAnswers));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKChoiceQuestionResult *result = [super copyWithZone:zone];
    result->_choiceAnswers = [self.choiceAnswers copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSArray class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.choiceAnswers = answer;
}

- (id)answer {
    return self.choiceAnswers;
}

@end


@implementation ORKBooleanQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, booleanAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, booleanAnswer, NSNumber);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_booleanAnswer, castObject.booleanAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKBooleanQuestionResult *result = [super copyWithZone:zone];
    result->_booleanAnswer = [self.booleanAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setAnswer:(id)answer {
    if ([answer isKindOfClass:[NSArray class]]) {
        // Because ORKBooleanAnswerFormat has ORKChoiceAnswerFormat as its implied format.
        NSAssert([answer count] <= 1, @"Should be no more than one answer");
        answer = [answer firstObject];
    }
    answer = [self validateAnswer:answer];
    self.booleanAnswer = answer;
}

- (id)answer {
    return self.booleanAnswer;
}

@end


@implementation ORKTextQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, textAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, textAnswer, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_textAnswer, castObject.textAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTextQuestionResult *result = [super copyWithZone:zone];
    result->_textAnswer = [self.textAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSString class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.textAnswer = answer;
}

- (id)answer {
    return self.textAnswer;
}

@end


@implementation ORKNumericQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, numericAnswer);
    ORK_ENCODE_OBJ(aCoder, unit);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, numericAnswer, NSNumber);
        ORK_DECODE_OBJ_CLASS(aDecoder, unit, NSString);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_numericAnswer, castObject.numericAnswer) &&
            ORKEqualObjects(_unit, castObject.unit));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKNumericQuestionResult *result = [super copyWithZone:zone];
    result->_unit = [self.unit copyWithZone:zone];
    result->_numericAnswer = [self.numericAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setAnswer:(id)answer {
    if (answer == ORKNullAnswerValue()) {
        answer = nil;
    }
    NSAssert(!answer || [answer isKindOfClass:[[self class] answerClass]], @"Answer should be of class %@", NSStringFromClass([[self class] answerClass]));
    self.numericAnswer = answer;
}

- (id)answer {
    return self.numericAnswer;
}

@end


@implementation ORKTimeOfDayQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, dateComponentsAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, dateComponentsAnswer, NSDateComponents);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_dateComponentsAnswer, castObject.dateComponentsAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTimeOfDayQuestionResult *result = [super copyWithZone:zone];
    result->_dateComponentsAnswer = [self.dateComponentsAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSDateComponents class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.dateComponentsAnswer = answer;
}

- (id)answer {
    return self.dateComponentsAnswer;
}

@end


@implementation ORKTimeIntervalQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, intervalAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, intervalAnswer, NSNumber);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_intervalAnswer, castObject.intervalAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTimeIntervalQuestionResult *result = [super copyWithZone:zone];
    result->_intervalAnswer = [self.intervalAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.intervalAnswer = answer;
}

- (id)answer {
    return self.intervalAnswer;
}

@end


@implementation ORKDateQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, calendar);
    ORK_ENCODE_OBJ(aCoder, timeZone);
    ORK_ENCODE_OBJ(aCoder, dateAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, calendar, NSCalendar);
        ORK_DECODE_OBJ_CLASS(aDecoder, timeZone, NSTimeZone);
        ORK_DECODE_OBJ_CLASS(aDecoder, dateAnswer, NSDate);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}


- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(_timeZone, castObject.timeZone) &&
            ORKEqualObjects(_calendar, castObject.calendar) &&
            ORKEqualObjects(_dateAnswer, castObject.dateAnswer));
}

- (NSUInteger)hash {
    return [super hash];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKDateQuestionResult *result = [super copyWithZone:zone];
    result->_calendar = [self.calendar copyWithZone:zone];
    result->_timeZone = [self.timeZone copyWithZone:zone];
    result->_dateAnswer = [self.dateAnswer copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSDate class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.dateAnswer = answer;
}

- (id)answer {
    return self.dateAnswer;
}

@end


@interface ORKCollectionResult ()

- (void)setResultsCopyObjects:(NSArray *)results;

@end


@implementation ORKCollectionResult

- (BOOL)isSaveable {
    BOOL saveable = NO;
    
    for (ORKResult *result in _results) {
        if ([result isSaveable]) {
            saveable = YES;
            break;
        }
    }
    return saveable;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    ORK_ENCODE_OBJ(aCoder, results);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, results, ORKResult);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.results, castObject.results));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.results hash];
}

- (void)setResultsCopyObjects:(NSArray *)results {
    _results = ORKArrayCopyObjects(results);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKCollectionResult *result = [super copyWithZone:zone];
    [result setResultsCopyObjects: self.results];
    return result;
}

- (NSArray *)results {
    if (_results == nil) {
        _results = [NSArray new];
    }
    return _results;
}

- (ORKResult *)resultForIdentifier:(NSString *)identifier {
    
    if (identifier == nil) {
        return nil;
    }
    
    __block ORKQuestionResult *result = nil;
    
    [self.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (NO == [obj isKindOfClass:[ORKResult class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat: @"Expected result object to be ORKResult type: %@", obj] userInfo:nil];
        }
        
        NSString *anIdentifier = [(ORKResult *)obj identifier];
        if ([anIdentifier isEqual:identifier]) {
            result = obj;
            *stop = YES;
        }
    
    }];
    
    return result;
}

- (ORKResult *)firstResult {
    
    return [self.results firstObject];
}

@end


@implementation ORKTaskResult

- (instancetype)initWithTaskIdentifier:(NSString *)identifier
                       taskRunUUID:(NSUUID *)taskRunUUID
                   outputDirectory:(NSURL *)outputDirectory {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self->_taskRunUUID = [taskRunUUID copy];
        self->_outputDirectory = [outputDirectory copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, taskRunUUID);
    ORK_ENCODE_URL(aCoder, outputDirectory);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, taskRunUUID, NSUUID);
        ORK_DECODE_URL(aDecoder, outputDirectory);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.taskRunUUID, castObject.taskRunUUID) &&
            ORKEqualFileURLs(self.outputDirectory, castObject.outputDirectory));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.taskRunUUID hash] ^ [self.outputDirectory hash];
}


- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTaskResult *result = [super copyWithZone:zone];
    result->_taskRunUUID = [self.taskRunUUID copy];
    result->_outputDirectory =  [self.outputDirectory copy];
    return result;
}

- (ORKStepResult *)stepResultForStepIdentifier:(NSString *)stepIdentifier {
    return (ORKStepResult *)[self resultForIdentifier:stepIdentifier];
}

@end


@implementation ORKStepResult

- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results {
    self = [super initWithIdentifier:stepIdentifier];
    if (self) {
        [self setResultsCopyObjects:results];
    }
    return self;
}

@end
