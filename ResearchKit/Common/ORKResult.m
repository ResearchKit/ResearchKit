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
#import "ORKRecorder.h"
#import "ORKStep.h"
#import "ORKHelpers.h"
#import "ORKRecorder_Internal.h"
#import "ORKQuestionStep.h"
#import "ORKFormStep.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKConsentDocument.h"
#import "ORKConsentSignature.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>


const NSUInteger NumberOfPaddingSpacesForIndentationLevel = 4;

@interface ORKResult ()

- (NSString *)descriptionPrefixWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces;

@property (nonatomic) NSString *descriptionSuffix;

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces;

@end


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
    return _identifier.hash ^ _startDate.hash ^ _endDate.hash ^ _userInfo.hash;
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

- (NSString *)descriptionPrefixWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@<%@: %p; identifier: \"%@\"", ORKPaddingWithNumberOfSpaces(numberOfPaddingSpaces), self.class.description, self, self.identifier];
}

- (NSString *)descriptionSuffix {
    return @">";
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.descriptionSuffix];
}

- (NSString *)description {
    return [self descriptionWithNumberOfPaddingSpaces:0];
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
    return [NSString stringWithFormat:@"<%@: %p; button: %@; timestamp: %.03f; location: %@>", self.class.description, self, @(self.buttonIdentifier), self.timestamp, NSStringFromCGPoint(self.location)];
}

@end


@implementation ORKPasscodeResult

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_BOOL(aCoder, passcodeSaved);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_BOOL(aDecoder, passcodeSaved);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame &&
            self.isPasscodeSaved == castObject.isPasscodeSaved);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPasscodeResult *result = [super copyWithZone:zone];
    result.passcodeSaved = self.isPasscodeSaved;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; passcodeSaved: %d%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.isPasscodeSaved, self.descriptionSuffix];
}

@end


@implementation ORKTowerOfHanoiResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, moves);
    ORK_ENCODE_BOOL(aCoder, puzzleWasSolved);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, moves, ORKTowerOfHanoiMove);
        ORK_DECODE_BOOL(aDecoder, puzzleWasSolved);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    __typeof(self) castObject = object;
    return isParentSame &&
    self.puzzleWasSolved == castObject.puzzleWasSolved &&
    ORKEqualObjects(self.moves, castObject.moves);
}

- (NSUInteger)hash {
    return super.hash ^ self.puzzleWasSolved ^ self.moves.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTowerOfHanoiResult *result = [super copyWithZone:zone];
    result.puzzleWasSolved = self.puzzleWasSolved;
    result.moves = [self.moves copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; puzzleSolved: %d; moves: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.puzzleWasSolved, self.moves, self.descriptionSuffix];
}

@end


@implementation ORKTowerOfHanoiMove

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, timestamp);
    ORK_ENCODE_INTEGER(aCoder, donorTowerIndex);
    ORK_ENCODE_INTEGER(aCoder, recipientTowerIndex);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, timestamp);
        ORK_DECODE_INTEGER(aDecoder, donorTowerIndex);
        ORK_DECODE_INTEGER(aDecoder, recipientTowerIndex);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return self.timestamp == castObject.timestamp &&
            self.donorTowerIndex == castObject.donorTowerIndex &&
            self.recipientTowerIndex == castObject.recipientTowerIndex;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTowerOfHanoiMove *move = [[[self class] allocWithZone:zone] init];
    move.timestamp = self.timestamp;
    move.donorTowerIndex = self.donorTowerIndex;
    move.recipientTowerIndex = self.recipientTowerIndex;
    return move;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; timestamp: %@; donorTower: %@; recipientTower: %@>", self.class.description, self, @(self.timestamp), @(self.donorTowerIndex), @(self.recipientTowerIndex)];
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
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKToneAudiometryResult *result = [super copyWithZone:zone];
    result.outputVolume = [self.outputVolume copy];
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; outputvolume: %@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.outputVolume, self.samples, self.descriptionSuffix];
}

@end


@implementation ORKToneAudiometrySample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, frequency);
    ORK_ENCODE_ENUM(aCoder, channel);
    ORK_ENCODE_DOUBLE(aCoder, amplitude);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, frequency);
        ORK_DECODE_ENUM(aDecoder, channel);
        ORK_DECODE_DOUBLE(aDecoder, amplitude);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;

    return ((self.channel == castObject.channel) &&
            (ABS(self.frequency - castObject.frequency) < DBL_EPSILON) &&
            (ABS(self.amplitude - castObject.amplitude) < DBL_EPSILON)) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKToneAudiometrySample *sample = [[[self class] allocWithZone:zone] init];
    sample.frequency = self.frequency;
    sample.channel = self.channel;
    sample.amplitude = self.amplitude;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; frequency: %.1lf; channel %@; amplitude: %.4lf>", self.class.description, self, self.frequency, @(self.channel), self.amplitude];
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
    return super.hash ^ [self targetIndex] ^ [self isCorrect];
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
    return [NSString stringWithFormat:@"<%@: %p; timestamp: %@; targetIndex: %@; location: %@; correct: %@>", self.class.description, self, @(self.timestamp), @(self.targetIndex), NSStringFromCGPoint(self.location), @(self.isCorrect)];
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
    return super.hash ^ [self seed] ^ [self gameSize] ^ [self score] ^ [self gameStatus];
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
    return [NSString stringWithFormat:@"<%@: %p; seed: %@; sequence: %@; gameSize: %@; gameStatus: %@; score: %@>", self.class.description, self, @(self.seed), self.sequence, @(self.gameSize), @(self.gameStatus), @(self.score)];
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
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSpatialSpanMemoryResult *result = [super copyWithZone:zone];
    result.score = self.score;
    result.numberOfGames = self.numberOfGames;
    result.numberOfFailures = self.numberOfFailures;
    result.gameRecords = [self.gameRecords copyWithZone:zone];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; score: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.score), self.descriptionSuffix];
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
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTappingIntervalResult *result = [super copyWithZone:zone];
    result.samples = [self.samples copy];
    result.buttonRect1 = self.buttonRect1;
    result.buttonRect2 = self.buttonRect2;
    result.stepViewSize = self.stepViewSize;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.samples, self.descriptionSuffix];
}

@end


@implementation ORKFileResult

- (BOOL)isSaveable {
    return (_fileURL != nil);
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
    return super.hash ^ self.fileURL.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKFileResult *result = [super copyWithZone:zone];
    result.fileURL = [self.fileURL copy];
    result.contentType = [self.contentType copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; fileURL: %@ (%lld bytes)%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.fileURL, [[NSFileManager defaultManager] attributesOfItemAtPath:self.fileURL.path error:nil].fileSize, self.descriptionSuffix];
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
    return super.hash ^ [NSNumber numberWithDouble:self.timestamp].hash ^ self.fileResult.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKReactionTimeResult *result = [super copyWithZone:zone];
    result.fileResult = [self.fileResult copy];
    result.timestamp = self.timestamp;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; timestamp: %f; fileResult: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.timestamp, self.fileResult.description, self.descriptionSuffix];
}

@end


@implementation ORKTimedWalkResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, distanceInMeters);
    ORK_ENCODE_DOUBLE(aCoder, timeLimit);
    ORK_ENCODE_DOUBLE(aCoder, duration);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, distanceInMeters);
        ORK_DECODE_DOUBLE(aDecoder, timeLimit);
        ORK_DECODE_DOUBLE(aDecoder, duration);
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
            (self.duration == castObject.distanceInMeters) &&
            (self.duration == castObject.timeLimit) &&
            (self.duration == castObject.duration));
}

- (NSUInteger)hash {
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTimedWalkResult *result = [super copyWithZone:zone];
    result.duration = self.distanceInMeters;
    result.duration = self.timeLimit;
    result.duration = self.duration;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; distance: %@; timeLimit: %@; duration: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.distanceInMeters), @(self.timeLimit), @(self.duration), self.descriptionSuffix];
}

@end


@implementation ORKPSATSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_BOOL(aCoder, correct);
    ORK_ENCODE_INTEGER(aCoder, digit);
    ORK_ENCODE_INTEGER(aCoder, answer);
    ORK_ENCODE_DOUBLE(aCoder, time);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_BOOL(aDecoder, correct);
        ORK_DECODE_INTEGER(aDecoder, digit);
        ORK_DECODE_INTEGER(aDecoder, answer);
        ORK_DECODE_DOUBLE(aDecoder, time);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.isCorrect == castObject.isCorrect) &&
            (self.digit == castObject.digit) &&
            (self.answer == castObject.answer) &&
            (self.time == castObject.time)) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPSATSample *sample = [[[self class] allocWithZone:zone] init];
    sample.correct = self.isCorrect;
    sample.digit = self.digit;
    sample.answer = self.answer;
    sample.time = self.time;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; correct: %@; digit: %@; answer: %@; time: %@>", self.class.description, self, @(self.isCorrect), @(self.digit), @(self.answer), @(self.time)];
}

@end


@implementation ORKPSATResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, presentationMode);
    ORK_ENCODE_DOUBLE(aCoder, interStimulusInterval);
    ORK_ENCODE_DOUBLE(aCoder, stimulusDuration);
    ORK_ENCODE_INTEGER(aCoder, length);
    ORK_ENCODE_INTEGER(aCoder, totalCorrect);
    ORK_ENCODE_INTEGER(aCoder, totalDyad);
    ORK_ENCODE_DOUBLE(aCoder, totalTime);
    ORK_ENCODE_INTEGER(aCoder, initialDigit);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, presentationMode);
        ORK_DECODE_DOUBLE(aDecoder, interStimulusInterval);
        ORK_DECODE_DOUBLE(aDecoder, stimulusDuration);
        ORK_DECODE_INTEGER(aDecoder, length);
        ORK_DECODE_INTEGER(aDecoder, totalCorrect);
        ORK_DECODE_INTEGER(aDecoder, totalDyad);
        ORK_DECODE_DOUBLE(aDecoder, totalTime);
        ORK_DECODE_INTEGER(aDecoder, initialDigit);
        ORK_DECODE_OBJ_ARRAY(aDecoder, samples, ORKPSATSample);
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
            (self.presentationMode == castObject.presentationMode) &&
            (self.interStimulusInterval == castObject.interStimulusInterval) &&
            (self.stimulusDuration == castObject.stimulusDuration) &&
            (self.length == castObject.length) &&
            (self.totalCorrect == castObject.totalCorrect) &&
            (self.totalDyad == castObject.totalDyad) &&
            (self.totalTime == castObject.totalTime) &&
            (self.initialDigit == castObject.initialDigit) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPSATResult *result = [super copyWithZone:zone];
    result.presentationMode = self.presentationMode;
    result.interStimulusInterval = self.interStimulusInterval;
    result.stimulusDuration = self.stimulusDuration;
    result.length = self.length;
    result.totalCorrect = self.totalCorrect;
    result.totalDyad = self.totalDyad;
    result.totalTime = self.totalTime;
    result.initialDigit = self.initialDigit;
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; correct: %@/%@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.totalCorrect), @(self.length), self.samples, self.descriptionSuffix];
}

@end


@implementation ORKHolePegTestResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, movingDirection);
    ORK_ENCODE_BOOL(aCoder, dominantHandTested);
    ORK_ENCODE_INTEGER(aCoder, numberOfPegs);
    ORK_ENCODE_INTEGER(aCoder, threshold);
    ORK_ENCODE_BOOL(aCoder, rotated);
    ORK_ENCODE_INTEGER(aCoder, totalSuccesses);
    ORK_ENCODE_INTEGER(aCoder, totalFailures);
    ORK_ENCODE_DOUBLE(aCoder, totalTime);
    ORK_ENCODE_DOUBLE(aCoder, totalDistance);
    ORK_ENCODE_OBJ(aCoder, samples);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, movingDirection);
        ORK_DECODE_BOOL(aDecoder, dominantHandTested);
        ORK_DECODE_INTEGER(aDecoder, numberOfPegs);
        ORK_DECODE_INTEGER(aDecoder, threshold);
        ORK_DECODE_BOOL(aDecoder, rotated);
        ORK_DECODE_INTEGER(aDecoder, totalSuccesses);
        ORK_DECODE_INTEGER(aDecoder, totalFailures);
        ORK_DECODE_DOUBLE(aDecoder, totalTime);
        ORK_DECODE_DOUBLE(aDecoder, totalDistance);
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
            (self.movingDirection == castObject.movingDirection) &&
            (self.isDominantHandTested == castObject.isDominantHandTested) &&
            (self.numberOfPegs == castObject.numberOfPegs) &&
            (self.threshold == castObject.threshold) &&
            (self.isRotated == castObject.isRotated) &&
            (self.totalSuccesses == castObject.totalSuccesses) &&
            (self.totalFailures == castObject.totalFailures) &&
            (self.totalTime == castObject.totalTime) &&
            (self.totalDistance == castObject.totalDistance) &&
            ORKEqualObjects(self.samples, castObject.samples)) ;
}

- (NSUInteger)hash {
    return super.hash ^ self.samples.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHolePegTestResult *result = [super copyWithZone:zone];
    result.movingDirection = self.movingDirection;
    result.dominantHandTested = self.isDominantHandTested;
    result.numberOfPegs = self.numberOfPegs;
    result.threshold = self.threshold;
    result.rotated = self.isRotated;
    result.totalSuccesses = self.totalSuccesses;
    result.totalFailures = self.totalFailures;
    result.totalTime = self.totalTime;
    result.totalDistance = self.totalDistance;
    result.samples = [self.samples copy];
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; successes: %@; time: %@; samples: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], @(self.totalSuccesses), @(self.totalTime), self.samples, self.descriptionSuffix];
}

@end


@implementation ORKHolePegTestSample

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_DOUBLE(aCoder, time);
    ORK_ENCODE_DOUBLE(aCoder, distance);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, time);
        ORK_DECODE_DOUBLE(aDecoder, distance);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return ((self.time == castObject.time) &&
            (self.distance == castObject.distance)) ;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKHolePegTestSample *sample = [[[self class] allocWithZone:zone] init];
    sample.time = self.time;
    sample.distance = self.distance;
    return sample;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; time: %@; distance: %@>", self.class.description, self, @(self.time), @(self.distance)];
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
    return super.hash ^ self.filename.hash ^ self.contentType.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKDataResult *result = [super copyWithZone:zone];
    result.data = self.data;
    result.filename = self.filename;
    result.contentType = self.contentType;

    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; data: %@; filename: %@; contentType: %@%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.data, self.filename, self.contentType, self.descriptionSuffix];
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
    return super.hash ^ self.signature.hash;
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
    
    if (indexToBeReplaced != NSNotFound) {
        NSMutableArray *signatures = [[document signatures] mutableCopy];
        signatures[indexToBeReplaced] = [_signature copy];
        document.signatures = signatures;
    }
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; signature: %@; consented: %d%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.signature, self.consented, self.descriptionSuffix];
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
    return super.hash ^ ((id<NSObject>)self.answer).hash ^ _questionType;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKQuestionResult *result = [super copyWithZone:zone];
    result.questionType = self.questionType;
    return result;
}

- (NSObject *)validateAnswer:(id)answer {
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

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@; answer:", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces]];
    id answer = self.answer;
    if ([answer isKindOfClass:[NSArray class]]
        || [answer isKindOfClass:[NSDictionary class]]
        || [answer isKindOfClass:[NSSet class]]
        || [answer isKindOfClass:[NSOrderedSet class]]) {
        NSMutableString *indentatedAnswerDescription = [NSMutableString new];
        NSString *answerDescription = [answer description];
        NSArray *answerLines = [answerDescription componentsSeparatedByString:@"\n"];
        const NSUInteger numberOfAnswerLines = answerLines.count;
        [answerLines enumerateObjectsUsingBlock:^(NSString *answerLineString, NSUInteger idx, BOOL *stop) {
            [indentatedAnswerDescription appendFormat:@"%@%@", ORKPaddingWithNumberOfSpaces(numberOfPaddingSpaces + NumberOfPaddingSpacesForIndentationLevel), answerLineString];
            if (idx != numberOfAnswerLines - 1) {
                [indentatedAnswerDescription appendString:@"\n"];
            }
        }];
        
        [description appendFormat:@"\n%@>", indentatedAnswerDescription];
    } else {
        [description appendFormat:@" %@%@", answer, self.descriptionSuffix];
    }
    
    return [description copy];
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
            ORKEqualObjects(self.scaleAnswer, castObject.scaleAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
            ORKEqualObjects(self.choiceAnswers, castObject.choiceAnswers));
}

- (NSUInteger)hash {
    return super.hash;
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
            ORKEqualObjects(self.booleanAnswer, castObject.booleanAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
        NSArray *answerArray = answer;
        NSAssert(answerArray.count <= 1, @"Should be no more than one answer");
        answer = answerArray.firstObject;
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
            ORKEqualObjects(self.textAnswer, castObject.textAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
            ORKEqualObjects(self.numericAnswer, castObject.numericAnswer) &&
            ORKEqualObjects(self.unit, castObject.unit));
}

- (NSUInteger)hash {
    return super.hash;
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

- (NSString *)descriptionSuffix {
    return [NSString stringWithFormat:@" %@>", _unit];
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
            ORKEqualObjects(self.dateComponentsAnswer, castObject.dateComponentsAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
            ORKEqualObjects(self.intervalAnswer, castObject.intervalAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
            ORKEqualObjects(self.timeZone, castObject.timeZone) &&
            ORKEqualObjects(self.calendar, castObject.calendar) &&
            ORKEqualObjects(self.dateAnswer, castObject.dateAnswer));
}

- (NSUInteger)hash {
    return super.hash;
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
    return super.hash ^ self.results.hash;
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
    
    return self.results.firstObject;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@; results: (", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces]];
    
    NSUInteger numberOfResults = self.results.count;
    [self.results enumerateObjectsUsingBlock:^(ORKResult *result, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            [description appendString:@"\n"];
        }
        [description appendFormat:@"%@", [result descriptionWithNumberOfPaddingSpaces:numberOfPaddingSpaces + NumberOfPaddingSpacesForIndentationLevel]];
        if (idx != numberOfResults - 1) {
            [description appendString:@",\n"];
        } else {
            [description appendString:@"\n"];
        }
    }];
    
    [description appendFormat:@"%@)%@", ORKPaddingWithNumberOfSpaces((numberOfResults == 0) ? 0 : numberOfPaddingSpaces), self.descriptionSuffix];
    return [description copy];
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
    return super.hash ^ self.taskRunUUID.hash ^ self.outputDirectory.hash;
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


@implementation ORKLocation

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                            region:(CLCircularRegion *)region
                         userInput:(NSString *)userInput
                 addressDictionary:(NSDictionary *)addressDictionary {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _region = region;
        _userInput = [userInput copy];
        _addressDictionary = [addressDictionary copy];
    }
    return self;
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark userInput:(NSString *)userInput {
    self = [super init];
    if (self) {
        _coordinate = placemark.location.coordinate;
        _userInput =  [userInput copy];
        _region = (CLCircularRegion *)placemark.region;
        _addressDictionary = [placemark.addressDictionary copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    // This object is not mutable
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

static NSString *const RegionCenterLatitudeKey = @"region.center.latitude";
static NSString *const RegionCenterLongitudeKey = @"region.center.longitude";
static NSString *const RegionRadiusKey = @"region.radius";
static NSString *const RegionIdentifierKey = @"region.identifier";

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, userInput);
    ORK_ENCODE_COORDINATE(aCoder, coordinate);
    ORK_ENCODE_OBJ(aCoder, addressDictionary);

    [aCoder encodeObject:@(_region.center.latitude) forKey:RegionCenterLatitudeKey];
    [aCoder encodeObject:@(_region.center.longitude) forKey:RegionCenterLongitudeKey];
    [aCoder encodeObject:_region.identifier forKey:RegionIdentifierKey];
    [aCoder encodeObject:@(_region.radius) forKey:RegionRadiusKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, userInput, NSString);
        ORK_DECODE_COORDINATE(aDecoder, coordinate);
        ORK_DECODE_OBJ_CLASS(aDecoder, addressDictionary, NSDictionary);
        ORK_DECODE_OBJ_CLASS(aDecoder, region, CLCircularRegion);
        
        NSNumber *latitude = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:RegionCenterLatitudeKey];
        NSNumber *longitude = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:RegionCenterLongitudeKey];
        NSNumber *radius = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:RegionRadiusKey];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        _region = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                    radius:radius.doubleValue
                                                identifier:[aDecoder decodeObjectOfClass:[NSString class] forKey:RegionIdentifierKey]];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.userInput, castObject.userInput) &&
            ORKEqualObjects(self.addressDictionary, castObject.addressDictionary) &&
            ORKEqualObjects(self.region, castObject.region) &&
            ORKEqualObjects([NSValue valueWithMKCoordinate:self.coordinate], [NSValue valueWithMKCoordinate:castObject.coordinate]));
}

@end


@implementation ORKLocationQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, locationAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, locationAnswer, ORKLocation);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame && ORKEqualObjects(self.locationAnswer, castObject.locationAnswer));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKLocationQuestionResult *result = [super copyWithZone:zone];
    result->_locationAnswer = [self.locationAnswer copy];
    return result;
}

+ (Class)answerClass {
    return [ORKLocation class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.locationAnswer = [answer copy];
}

- (id)answer {
    return self.locationAnswer;
}

@end


@implementation ORKStepResult

- (instancetype)initWithStepIdentifier:(NSString *)stepIdentifier results:(NSArray *)results {
    self = [super initWithIdentifier:stepIdentifier];
    if (self) {
        [self setResultsCopyObjects:results];
        [self updateEnabledAssistiveTechnology];
    }
    return self;
}

- (void)updateEnabledAssistiveTechnology {
    if (UIAccessibilityIsVoiceOverRunning()) {
        _enabledAssistiveTechnology = [UIAccessibilityNotificationVoiceOverIdentifier copy];
    } else if (UIAccessibilityIsSwitchControlRunning()) {
        _enabledAssistiveTechnology = [UIAccessibilityNotificationSwitchControlIdentifier copy];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, enabledAssistiveTechnology);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, enabledAssistiveTechnology, NSString);
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
            ORKEqualObjects(self.enabledAssistiveTechnology, castObject.enabledAssistiveTechnology));
}

- (NSUInteger)hash {
    return super.hash ^ _enabledAssistiveTechnology.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKStepResult *result = [super copyWithZone:zone];
    result->_enabledAssistiveTechnology = [_enabledAssistiveTechnology copy];
    return result;
}

- (NSString *)descriptionPrefixWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; enabledAssistiveTechnology: %@", [super descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], _enabledAssistiveTechnology ? : @"None"];
}

@end

@implementation ORKSignatureResult

- (instancetype)initWithSignatureImage:(UIImage *)signatureImage
                         signaturePath:(NSArray <UIBezierPath *> *)signaturePath {
    self = [super init];
    if (self) {
        _signatureImage = [signatureImage copy];
        _signaturePath = ORKArrayCopyObjects(signaturePath);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_IMAGE(aCoder, signatureImage);
    ORK_ENCODE_OBJ(aCoder, signaturePath);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_IMAGE(aDecoder, signatureImage);
        ORK_DECODE_OBJ_ARRAY(aDecoder, signaturePath, UIBezierPath);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    return super.hash ^ self.signatureImage.hash ^ self.signaturePath.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.signatureImage, castObject.signatureImage) &&
            ORKEqualObjects(self.signaturePath, castObject.signaturePath));
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKSignatureResult *result = [super copyWithZone:zone];
    result->_signatureImage = [_signatureImage copy];
    result->_signaturePath = ORKArrayCopyObjects(_signaturePath);
    return result;
}

@end
