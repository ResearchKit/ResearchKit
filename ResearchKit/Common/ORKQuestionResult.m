/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 
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


#import "ORKQuestionResult_Private.h"

#import "ORKResult_Private.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKFormStep.h"
#import "ORKQuestionStep.h"

#import "ORKHelpers_Internal.h"


@implementation ORKQuestionResult {
    @protected
    NSObject<NSCopying, NSSecureCoding> *_typedAnswerOrNoAnswer;
}

- (BOOL)isSaveable {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, questionType);
    // New generic answer property
    ORK_ENCODE_OBJ(aCoder, typedAnswerOrNoAnswer);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, questionType);
        // New generic answer property (backward-compatible decoding provided by subclasses)
        ORK_DECODE_OBJ_CLASSES(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer]);
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
            _questionType == castObject.questionType &&
            ORKEqualObjects(_typedAnswerOrNoAnswer, castObject->_typedAnswerOrNoAnswer));
}

- (NSUInteger)hash {
    return super.hash ^ self.answer.hash ^ _questionType;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKQuestionResult *copy = [super copyWithZone:zone];
    copy.questionType = self.questionType;
    copy->_typedAnswerOrNoAnswer = [_typedAnswerOrNoAnswer copyWithZone:zone];
    return copy;
}

- (NSObject<NSCopying, NSSecureCoding> *)validateAnswer:(NSObject<NSCopying, NSSecureCoding> *)answer {
    if (answer == ORKNullAnswerValue()) {
        answer = nil;
    }

    NSParameterAssert(!answer || [answer isKindOfClass:[[self class] answerClass]] || [answer isKindOfClass:[ORKNoAnswer class]]);
    return answer;
}

+ (Class)answerClass {
    return nil;
}

+ (NSArray<Class> *)answerClassesIncludingNoAnswer {
    if (self == [ORKQuestionResult class]) {
        // [ORKQuestionResult answerClass] is nil
        return @[[ORKNoAnswer class]];
    } else {
        // Case for subclasses
        return @[[[self class] answerClass], [ORKNoAnswer class]];
    }
}

- (void)setAnswer:(NSObject<NSCopying, NSSecureCoding> *)answer {
    answer = [self validateAnswer:answer];
    _typedAnswerOrNoAnswer = [answer copy];
}

- (NSObject<NSCopying, NSSecureCoding> *)answer {
    return _typedAnswerOrNoAnswer;
}

- (void)setNoAnswerType:(ORKNoAnswer *)noAnswerType {
    if (noAnswerType != nil) {
        self.answer = noAnswerType;
    // Do not overwrite answer if the current value is not a `ORKNoAnswer` subclass instance
    } else if (noAnswerType == nil && [self.answer isKindOfClass:[ORKNoAnswer class]]) {
        self.answer = nil;
    }
}

- (ORKNoAnswer *)noAnswerType {
    id answer = self.answer;
    return [answer isKindOfClass:[ORKNoAnswer class]] ? answer : nil;
}

- (NSObject<NSCopying, NSSecureCoding> *)typedAnswer {
    id answer = self.answer;
    return [answer isKindOfClass:[[self class] answerClass]] ? answer : nil;
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


#pragma mark - ORKBooleanQuestionResult

@implementation ORKBooleanQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], booleanAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setAnswer:(NSObject<NSCopying,NSSecureCoding> *)answer {
    if ([answer isKindOfClass:[NSArray class]]) {
        // Because ORKBooleanAnswerFormat has ORKChoiceAnswerFormat as its implied format.
        NSArray *answerArray = (NSArray *)answer;
        NSAssert(answerArray.count <= 1, @"Should be no more than one answer");
        answer = answerArray.firstObject;
    }
    [super setAnswer:answer];
}

- (void)setBooleanAnswer:(NSNumber *)booleanAnswer {
    self.answer = booleanAnswer;
}

- (NSNumber *)booleanAnswer {
    return ORKDynamicCast(self.typedAnswer, NSNumber);
}

@end


#pragma mark - ORKChoiceQuestionResult

@implementation ORKChoiceQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], choiceAnswers);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSArray<NSObject<NSCopying, NSSecureCoding> *> class];
}

+ (NSArray<Class> *)answerClassesIncludingNoAnswer {
    NSArray *classes = [[super answerClassesIncludingNoAnswer] arrayByAddingObjectsFromArray:ORKAllowableValueClasses()];
    return classes;
}

- (void)setChoiceAnswers:(NSArray<NSObject<NSCopying, NSSecureCoding> *> *)choiceAnswers {
    self.answer = choiceAnswers;
}

- (NSArray<NSObject<NSCopying, NSSecureCoding> *> *)choiceAnswers {
    #define ORKChoiceQuestionResultAnswerClass NSArray<NSObject<NSCopying,NSSecureCoding> *>
    return ORKDynamicCast(self.typedAnswer, ORKChoiceQuestionResultAnswerClass);
    #undef ORKChoiceQuestionResultAnswerClass
}

@end


#pragma mark - ORKDateQuestionResult

@implementation ORKDateQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, calendar);
    ORK_ENCODE_OBJ(aCoder, timeZone);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, calendar, NSCalendar);
        ORK_DECODE_OBJ_CLASS(aDecoder, timeZone, NSTimeZone);
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], dateAnswer);
        }

        if (_typedAnswerOrNoAnswer != nil && ![_typedAnswerOrNoAnswer isKindOfClass:[NSDate class]] && ![_typedAnswerOrNoAnswer isKindOfClass:[ORKNoAnswer class]]) {
            ORK_Log_Fault("ORKDateQuestionResult: Discarding answer of wrong class: %{public}@ (%@, identifier: %{public}@)", [_typedAnswerOrNoAnswer class], _typedAnswerOrNoAnswer, self.identifier);
            _typedAnswerOrNoAnswer = nil;
        }
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
            ORKEqualObjects(self.calendar, castObject.calendar));
}

- (NSUInteger)hash {
    return super.hash ^ self.timeZone.hash ^ self.calendar.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKDateQuestionResult *result = [super copyWithZone:zone];
    result->_timeZone = [self.timeZone copyWithZone:zone];
    result->_calendar = [self.calendar copyWithZone:zone];
    return result;
}

+ (Class)answerClass {
    return [NSDate class];
}

// Date answer sometimes gets a wrong NSNumber value
+ (NSArray<Class> *)answerClassesIncludingNoAnswer {
    NSArray *classes = [[super answerClassesIncludingNoAnswer] arrayByAddingObjectsFromArray:ORKAllowableValueClasses()];
    return classes;
}

- (void)setDateAnswer:(NSDate *)dateAnswer {
    self.answer = dateAnswer;
}


- (NSDate *)dateAnswer {
    return ORKDynamicCast(self.typedAnswer, NSDate);
}

@end


#pragma mark - ORKLocationQuestionResult

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
                     postalAddress:(CNPostalAddress *)postalAddress{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _region = [region copy];
        _userInput = [userInput copy];
        _postalAddress = [postalAddress copy];
    }
    return self;
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark userInput:(NSString *)userInput {
    self = [super init];
    if (self) {
        _coordinate = placemark.location.coordinate;
        _userInput =  [userInput copy];
        _region = [placemark.region isKindOfClass:[CLCircularRegion class]] ? [placemark.region copy]  : nil;
        _postalAddress = [placemark.postalAddress copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithCoordinate:self.coordinate
                                             region:self.region
                                          userInput:self.userInput
                                      postalAddress:self.postalAddress];
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
    ORK_ENCODE_OBJ(aCoder, postalAddress);
    
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
        ORK_DECODE_OBJ_CLASS(aDecoder, postalAddress, CNPostalAddress);
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

- (NSUInteger)hash {
    NSUInteger regionHash = (NSUInteger)(self.region.center.latitude * 1000) ^ (NSUInteger)(self.region.center.longitude * 1000) ^ (NSUInteger)(self.region.radius * 1000);
    NSUInteger coordinateHash = (NSUInteger)(self.coordinate.latitude * 1000) ^ (NSUInteger)(self.coordinate.longitude * 1000);
    return coordinateHash ^ regionHash ^ self.userInput.hash ^ self.postalAddress.hash;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.userInput, castObject.userInput) &&
            ORKEqualObjects(self.postalAddress, castObject.postalAddress)&&
            // The region is not checking for equality properly so check the values
            (self.region.center.latitude == castObject.region.center.latitude) &&
            (self.region.center.longitude == castObject.region.center.longitude) &&
            (self.region.radius == castObject.region.radius) &&
            ORKEqualObjects([NSValue valueWithMKCoordinate:self.coordinate], [NSValue valueWithMKCoordinate:castObject.coordinate]));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ region:%@ userInput:%@ postalAddress:%@>", [super description], self.region, self.userInput, self.postalAddress];
}

@end


@implementation ORKLocationQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], locationAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [ORKLocation class];
}

- (void)setLocationAnswer:(ORKLocation *)locationAnswer {
    self.answer = locationAnswer;
}

- (ORKLocation *)locationAnswer {
    return ORKDynamicCast(self.typedAnswer, ORKLocation);
}

@end


#pragma mark - ORKSESQuestionResult

@implementation ORKSESQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], rungPicked);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSNumber class];
}


- (void)setRungPicked:(NSNumber *)rungPicked {
    self.answer = rungPicked;
}

- (NSNumber *)rungPicked {
    return ORKDynamicCast(self.typedAnswer, NSNumber);
}

@end


#pragma mark - ORKMultipleComponentQuestionResult

@implementation ORKMultipleComponentQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, separator);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, separator, NSString);
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], componentsAnswer);
        }
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
            ORKEqualObjects(self.separator, castObject.separator));
}

- (NSUInteger)hash {
    return super.hash ^ self.separator.hash;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [super copyWithZone:zone];
    copy.separator = self.separator;
    return copy;
}

+ (Class)answerClass {
    return [NSArray<NSObject<NSCopying, NSSecureCoding> *> class];
}

+ (NSArray<Class> *)answerClassesIncludingNoAnswer {
    NSArray *classes = [[super answerClassesIncludingNoAnswer] arrayByAddingObjectsFromArray:ORKAllowableValueClasses()];
    return classes;
}

- (void)setComponentsAnswer:(NSArray<NSObject<NSCopying, NSSecureCoding> *> *)componentsAnswer {
    self.answer = componentsAnswer;
}

- (NSArray<NSObject<NSCopying, NSSecureCoding> *> *)componentsAnswer {
    #define ORKMultipleComponentQuestionResultAnswerClass NSArray<NSObject<NSCopying,NSSecureCoding> *>
    return ORKDynamicCast(self.typedAnswer, ORKMultipleComponentQuestionResultAnswerClass);
    #undef ORKMultipleComponentQuestionResultAnswerClass
}

@end


#pragma mark - ORKNumericQuestionResult

@implementation ORKNumericQuestionResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, unit);
    ORK_ENCODE_OBJ(aCoder, displayUnit);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, unit, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, displayUnit, NSString);
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], numericAnswer);
        }
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
            ORKEqualObjects(self.unit, castObject.unit) &&
            ORKEqualObjects(self.displayUnit, castObject.displayUnit));
}

- (NSUInteger)hash {
    return super.hash ^ self.unit.hash ^ self.displayUnit.hash;
}


- (instancetype)copyWithZone:(NSZone *)zone {
    ORKNumericQuestionResult *copy = [super copyWithZone:zone];
    copy->_unit = [self.unit copyWithZone:zone];
    copy->_displayUnit = [self.displayUnit copyWithZone:zone];
    return copy;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (NSString *)descriptionSuffix {
    return [NSString stringWithFormat:@" %@> displayUnit: %@", _unit, _displayUnit];
}

- (void)setNumericAnswer:(NSNumber *)numericAnswer {
    self.answer = numericAnswer;
}

- (NSNumber *)numericAnswer {
    return ORKDynamicCast(self.typedAnswer, NSNumber);
}

@end


#pragma mark - ORKScaleQuestionResult

@implementation ORKScaleQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], scaleAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setScaleAnswer:(NSNumber *)scaleAnswer {
    self.answer = scaleAnswer;
}

- (NSNumber *)scaleAnswer {
    return ORKDynamicCast(self.typedAnswer, NSNumber);
}

@end


#pragma mark - ORKTextQuestionResult

@implementation ORKTextQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], textAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSString class];
}

- (void)setTextAnswer:(NSString *)textAnswer {
    self.answer = textAnswer;
}

- (NSString *)textAnswer {
    return ORKDynamicCast(self.typedAnswer, NSString);
}

@end


#pragma mark - ORKTimeIntervalQuestionResult

@implementation ORKTimeIntervalQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], intervalAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSNumber class];
}

- (void)setIntervalAnswer:(NSNumber *)intervalAnswer {
    self.answer = intervalAnswer;
}

- (NSNumber *)intervalAnswer {
    return ORKDynamicCast(self.typedAnswer, NSNumber);
}

@end


#pragma mark - ORKTimeOfDayQuestionResult

@implementation ORKTimeOfDayQuestionResult

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (_typedAnswerOrNoAnswer == nil) {
            // Backwards compatibility, do not change the key
            ORK_DECODE_OBJ_CLASSES_FOR_KEY(aDecoder, typedAnswerOrNoAnswer, [[self class] answerClassesIncludingNoAnswer], dateComponentsAnswer);
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (Class)answerClass {
    return [NSDateComponents class];
}

- (void)setAnswer:(NSObject<NSCopying, NSSecureCoding> *)answer {
    if ([answer isKindOfClass:[NSDateComponents class]]) {
        NSDateComponents *dateComponents = (NSDateComponents *)answer;
        // For time of day, the day, month and year should be zero
        dateComponents.day = 0;
        dateComponents.month = 0;
        dateComponents.year = 0;
    }
    [super setAnswer:answer];
}

- (void)setDateComponentsAnswer:(NSDateComponents *)dateComponentsAnswer {
    self.answer = dateComponentsAnswer;
}

- (NSDateComponents *)dateComponentsAnswer {
    return ORKDynamicCast(self.typedAnswer, NSDateComponents);
}

@end

