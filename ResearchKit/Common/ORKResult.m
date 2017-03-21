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

#import "ORKRecorder_Internal.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKConsentDocument.h"
#import "ORKConsentSignature.h"
#import "ORKFormStep.h"
#import "ORKQuestionStep.h"
#import "ORKPageStep.h"
#import "ORKResult_Private.h"
#import "ORKStep.h"
#import "ORKTask.h"

#import "ORKHelpers_Internal.h"

@import CoreMotion;
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




@implementation ORKPasscodeResult

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_BOOL(aCoder, passcodeSaved);
    ORK_ENCODE_BOOL(aCoder, touchIdEnabled);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_BOOL(aDecoder, passcodeSaved);
        ORK_DECODE_BOOL(aDecoder, touchIdEnabled);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];

    __typeof(self) castObject = object;
    return (isParentSame &&
            self.isPasscodeSaved == castObject.isPasscodeSaved &&
            self.isTouchIdEnabled == castObject.isTouchIdEnabled);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKPasscodeResult *result = [super copyWithZone:zone];
    result.passcodeSaved = self.isPasscodeSaved;
    result.touchIdEnabled = self.isTouchIdEnabled;
    return result;
}

- (NSString *)descriptionWithNumberOfPaddingSpaces:(NSUInteger)numberOfPaddingSpaces {
    return [NSString stringWithFormat:@"%@; passcodeSaved: %d touchIDEnabled: %d%@", [self descriptionPrefixWithNumberOfPaddingSpaces:numberOfPaddingSpaces], self.isPasscodeSaved, self.isTouchIdEnabled, self.descriptionSuffix];
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


@implementation ORKMultipleComponentQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, componentsAnswer);
    ORK_ENCODE_OBJ(aCoder, separator);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, componentsAnswer, NSObject);
        ORK_DECODE_OBJ_CLASS(aDecoder, separator, NSString);
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
            ORKEqualObjects(self.componentsAnswer, castObject.componentsAnswer) &&
            ORKEqualObjects(self.separator, castObject.separator));
}

- (NSUInteger)hash {
    return super.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [super copyWithZone:zone];
    copy.componentsAnswer = self.componentsAnswer;
    copy.separator = self.separator;
    return copy;
}

+ (Class)answerClass {
    return [NSArray class];
}

- (void)setAnswer:(id)answer {
    answer = [self validateAnswer:answer];
    self.componentsAnswer = answer;
}

- (id)answer {
    return self.componentsAnswer;
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
    NSDateComponents *dateComponents = (NSDateComponents *)[self validateAnswer:answer];
    // For time of day, the day, month and year should be zero
    dateComponents.day = 0;
    dateComponents.month = 0;
    dateComponents.year = 0;
    self.dateComponentsAnswer = dateComponents;
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
    
    // Look through the result set in reverse-order to account for the possibility of
    // multiple results with the same identifier (due to a navigation loop)
    NSEnumerator *enumerator = self.results.reverseObjectEnumerator;
    id obj = enumerator.nextObject;
    while ((result== nil) && (obj != nil)) {
        
        if (NO == [obj isKindOfClass:[ORKResult class]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat: @"Expected result object to be ORKResult type: %@", obj] userInfo:nil];
        }
        
        NSString *anIdentifier = [(ORKResult *)obj identifier];
        if ([anIdentifier isEqual:identifier]) {
            result = obj;
        }
        obj = enumerator.nextObject;
    }
    
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


@implementation ORKVideoInstructionStepResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:self.playbackStoppedTime forKey:@"playbackStoppedTime"];
    ORK_ENCODE_BOOL(aCoder, playbackCompleted);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.playbackStoppedTime = [aDecoder decodeFloatForKey:@"playbackStoppedTime"];
        ORK_DECODE_BOOL(aDecoder, playbackCompleted);
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSUInteger)hash {
    NSNumber *playbackStoppedTime = [NSNumber numberWithFloat:self.playbackStoppedTime];
    return super.hash ^ [playbackStoppedTime hash] ^ self.playbackCompleted;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            self.playbackStoppedTime == castObject.playbackStoppedTime &&
            self.playbackCompleted == castObject.playbackCompleted);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKVideoInstructionStepResult *result = [super copyWithZone:zone];
    result->_playbackStoppedTime = self.playbackStoppedTime;
    result->_playbackCompleted = self.playbackCompleted;
    return result;
}

@end


@implementation ORKPageResult

- (instancetype)initWithPageStep:(ORKPageStep *)step stepResult:(ORKStepResult*)result {
    self = [super initWithTaskIdentifier:step.identifier taskRunUUID:[NSUUID UUID] outputDirectory:nil];
    if (self) {
        NSArray <NSString *> *stepIdentifiers = [step.steps valueForKey:@"identifier"];
        NSMutableArray *results = [NSMutableArray new];
        for (NSString *identifier in stepIdentifiers) {
            NSString *prefix = [NSString stringWithFormat:@"%@.", identifier];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier BEGINSWITH %@", prefix];
            NSArray *filteredResults = [result.results filteredArrayUsingPredicate:predicate];
            if (filteredResults.count > 0) {
                NSMutableArray *subresults = [NSMutableArray new];
                for (ORKResult *subresult in filteredResults) {
                    ORKResult *copy = [subresult copy];
                    copy.identifier = [subresult.identifier substringFromIndex:prefix.length];
                    [subresults addObject:copy];
                }
                [results addObject:[[ORKStepResult alloc] initWithStepIdentifier:identifier results:subresults]];
            }
        }
        self.results = results;
    }
    return self;
}

- (void)addStepResult:(ORKStepResult *)stepResult {
    if (stepResult == nil) {
        return;
    }
    
    // Remove previous step result and add the new one
    NSMutableArray *results = [self.results mutableCopy] ?: [NSMutableArray new];
    ORKResult *previousResult = [self resultForIdentifier:stepResult.identifier];
    if (previousResult) {
        [results removeObject:previousResult];
    }
    [results addObject:stepResult];
    self.results = results;
}

- (void)removeStepResultWithIdentifier:(NSString *)identifier {
    ORKResult *result = [self resultForIdentifier:identifier];
    if (result != nil) {
        NSMutableArray *results = [self.results mutableCopy];
        [results removeObject:result];
        self.results = results;
    }
}

- (void)removeStepResultsAfterStepWithIdentifier:(NSString *)identifier {
    ORKResult *result = [self resultForIdentifier:identifier];
    if (result != nil) {
        NSUInteger idx = [self.results indexOfObject:result];
        if (idx != NSNotFound) {
            self.results = [self.results subarrayWithRange:NSMakeRange(0, idx)];
        }
    }
}

- (NSArray <ORKResult *> *)flattenResults {
    NSMutableArray *results = [NSMutableArray new];
    for (ORKResult *result in self.results) {
        if ([result isKindOfClass:[ORKStepResult class]]) {
            ORKStepResult *stepResult = (ORKStepResult *)result;
            if (stepResult.results.count > 0) {
                // For each subresult in this step, append the step identifier onto the result
                for (ORKResult *result in stepResult.results) {
                    ORKResult *copy = [result copy];
                    NSString *subIdentifier = result.identifier ?: [NSString stringWithFormat:@"%@", @(result.hash)];
                    copy.identifier = [NSString stringWithFormat:@"%@.%@", stepResult.identifier, subIdentifier];
                    [results addObject:copy];
                }
            } else {
                // If this is an empty step result then add a base class instance with this identifier
                [results addObject:[[ORKResult alloc] initWithIdentifier:stepResult.identifier]];
            }
        } else {
            // If this is *not* a step result then just add it as-is
            [results addObject:result];
        }
    }
    return [results copy];
}

- (instancetype)copyWithOutputDirectory:(NSURL *)outputDirectory {
    typeof(self) copy = [[[self class] alloc] initWithTaskIdentifier:self.identifier taskRunUUID:self.taskRunUUID outputDirectory:outputDirectory];
    copy.results = self.results;
    return copy;
}

@end


