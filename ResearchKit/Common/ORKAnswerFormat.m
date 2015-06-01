/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Scott Guelich.
 
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


#import "ORKAnswerFormat.h"
#import "ORKHelpers.h"
#import <HealthKit/HealthKit.h>
#import "ORKAnswerFormat_Internal.h"
#import "ORKHealthAnswerFormat.h"
#import "ORKResult_Private.h"


id ORKNullAnswerValue() {
    return [NSNull null];
}


NSString *ORKQuestionTypeString(ORKQuestionType questionType) {
#define SQT_CASE(x) case ORKQuestionType ## x : return @STRINGIFY(ORKQuestionType ## x);
    switch (questionType) {
            SQT_CASE(None);
            SQT_CASE(Scale);
            SQT_CASE(SingleChoice);
            SQT_CASE(MultipleChoice);
            SQT_CASE(Decimal);
            SQT_CASE(Integer);
            SQT_CASE(Boolean);
            SQT_CASE(Text);
            SQT_CASE(DateAndTime);
            SQT_CASE(TimeOfDay);
            SQT_CASE(Date);
            SQT_CASE(TimeInterval);
    }
#undef SQT_CASE
}

NSNumberFormatterStyle ORKNumberFormattingStyleConvert(ORKNumberFormattingStyle style) {
    return style == ORKNumberFormattingStylePercent ? NSNumberFormatterPercentStyle : NSNumberFormatterDecimalStyle;
}

@implementation ORKAnswerDefaultSource {
    NSMutableDictionary *_unitsTable;
}

@synthesize healthStore=_healthStore;

+ (instancetype)sourceWithHealthStore:(HKHealthStore *)healthStore {
    ORKAnswerDefaultSource *source = [[ORKAnswerDefaultSource alloc] initWithHealthStore:healthStore];
    return source;
}

- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore {
    self = [super init];
    if (self) {
        _healthStore = healthStore;
        
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8, 2, 0}]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(healthKitUserPreferencesDidChange:)
                                                         name:HKUserPreferencesDidChangeNotification
                                                       object:healthStore];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)healthKitUserPreferencesDidChange:(NSNotification *)notification {
    _unitsTable = nil;
}

- (id)defaultValueForCharacteristicType:(HKCharacteristicType *)characteristicType error:(NSError * __autoreleasing *)error {
    id result = nil;
    if ([[characteristicType identifier] isEqualToString:HKCharacteristicTypeIdentifierDateOfBirth]) {
        NSDate *dob = [_healthStore dateOfBirthWithError:error];
        if (dob) {
            result = dob;
        }
    }
    if ([[characteristicType identifier] isEqualToString:HKCharacteristicTypeIdentifierBloodType]) {
        HKBloodTypeObject *bloodType = [_healthStore bloodTypeWithError:error];
        if (bloodType && bloodType.bloodType != HKBloodTypeNotSet) {
            result = ORKHKBloodTypeString(bloodType.bloodType);
        }
        if (result) {
            result = @[result];
        }
    }
    if ([[characteristicType identifier] isEqualToString:HKCharacteristicTypeIdentifierBiologicalSex]) {
        HKBiologicalSexObject *biologicalSex = [_healthStore biologicalSexWithError:error];
        if (biologicalSex && biologicalSex.biologicalSex != HKBiologicalSexNotSet) {
            result = ORKHKBiologicalSexString(biologicalSex.biologicalSex);
        }
        if (result) {
            result = @[result];
        }
    }
    return result;
}

- (void)fetchDefaultValueForQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit handler:(void(^)(id defaultValue, NSError *error))handler {
    if (! unit) {
        handler(nil, nil);
        return;
    }
    
    HKHealthStore *healthStore = _healthStore;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            HKQuantitySample *sample = [results firstObject];
            id value = nil;
            if (sample) {
                value = @([sample.quantity doubleValueForUnit:unit]);
            }
            handler(value, error);
        }];
        [healthStore executeQuery:sampleQuery];
    });
}

- (void)fetchDefaultValueForAnswerFormat:(ORKAnswerFormat *)answerFormat handler:(void(^)(id defaultValue, NSError *error))handler {
    HKObjectType *objectType = [answerFormat healthKitObjectType];
    BOOL handled = NO;
    if (objectType) {
        if ([HKHealthStore isHealthDataAvailable]) {
            if ([answerFormat isKindOfClass:[ORKHealthKitCharacteristicTypeAnswerFormat class]]) {
                NSError *error = nil;
                id defaultValue = [self defaultValueForCharacteristicType:(HKCharacteristicType *)objectType error:&error];
                handler(defaultValue, error);
                handled = YES;
            } else if ([answerFormat isKindOfClass:[ORKHealthKitQuantityTypeAnswerFormat class]]) {
                [self updateHealthKitUnitForAnswerFormat:answerFormat force:NO];
                HKUnit *unit = [answerFormat healthKitUserUnit];
                [self fetchDefaultValueForQuantityType:(HKQuantityType *)objectType unit:unit handler:handler];
                handled = YES;
            }
        }
    }
    if (! handled) {
        handler(nil, nil);
    }
}

- (HKUnit *)defaultHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat {
    __block HKUnit *unit = [answerFormat healthKitUnit];
    HKObjectType *objectType = [answerFormat healthKitObjectType];
    if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8, 2, 0}]) {
        return unit;
    }
    
    if (unit == nil && [objectType isKindOfClass:[HKQuantityType class]] && [HKHealthStore isHealthDataAvailable]) {
        unit = _unitsTable[objectType];
        if (unit) {
            return unit;
        }
        if (! _unitsTable) {
            _unitsTable = [NSMutableDictionary dictionary];
        }
        
        HKQuantityType *quantityType = (HKQuantityType *)objectType;
        
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [_healthStore preferredUnitsForQuantityTypes:[NSSet setWithObject:quantityType] completion:^(NSDictionary *preferredUnits, NSError *error) {
            
            unit = preferredUnits[quantityType];
            
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        if (unit) {
            _unitsTable[objectType] = unit;
        }
    }
    return unit;
}

- (void)updateHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat force:(BOOL)force {
    HKUnit *unit = [answerFormat healthKitUserUnit];
    HKUnit *healthKitDefault = [self defaultHealthKitUnitForAnswerFormat:answerFormat];
    if (!ORKEqualObjects(unit,healthKitDefault) && (force || (unit == nil))) {
        [answerFormat setHealthKitUserUnit:healthKitDefault];
    }
}

@end

#pragma mark - ORKAnswerFormat

@implementation ORKAnswerFormat

+ (ORKScaleAnswerFormat *)scaleAnswerFormatWithMaximumValue:(NSInteger)scaleMaximum
                                               minimumValue:(NSInteger)scaleMinimum
                                               defaultValue:(NSInteger)defaultValue
                                                       step:(NSInteger)step
                                                   vertical:(BOOL)vertical
                                    maximumValueDescription:(nullable NSString *)maximumValueDescription
                                    minimumValueDescription:(nullable NSString *)minimumValueDescription {
    return [[ORKScaleAnswerFormat alloc] initWithMaximumValue:scaleMaximum
                                                 minimumValue:scaleMinimum
                                                 defaultValue:defaultValue
                                                         step:step
                                                     vertical:vertical
                                      maximumValueDescription:maximumValueDescription
                                      minimumValueDescription:minimumValueDescription];
}

+ (ORKContinuousScaleAnswerFormat *)continuousScaleAnswerFormatWithMaximumValue:(double)scaleMaximum
                                                                   minimumValue:(double)scaleMinimum
                                                                   defaultValue:(double)defaultValue
                                                          maximumFractionDigits:(NSInteger)maximumFractionDigits
                                                                       vertical:(BOOL)vertical
                                                        maximumValueDescription:(nullable NSString *)maximumValueDescription
                                                        minimumValueDescription:(nullable NSString *)minimumValueDescription {
    return [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:scaleMaximum
                                                           minimumValue:scaleMinimum
                                                           defaultValue:defaultValue
                                                  maximumFractionDigits:maximumFractionDigits
                                                               vertical:vertical
                                                maximumValueDescription:maximumValueDescription
                                                minimumValueDescription:minimumValueDescription];
}

+ (ORKBooleanAnswerFormat *)booleanAnswerFormat {
    return [ORKBooleanAnswerFormat new];
}

+ (ORKValuePickerAnswerFormat *)valuePickerAnswerFormatWithTextChoices:(NSArray *)textChoices {
    return [[ORKValuePickerAnswerFormat alloc] initWithTextChoices:textChoices];
}

+ (ORKImageChoiceAnswerFormat *)choiceAnswerFormatWithImageChoices:(NSArray *)imageChoices {
    return [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:imageChoices];
}

+ (ORKTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(ORKChoiceAnswerStyle)style
                                        textChoices:(NSArray *)textChoices {
    return [[ORKTextChoiceAnswerFormat alloc] initWithStyle:style textChoices:textChoices];
}

+ (ORKNumericAnswerFormat *)decimalAnswerFormatWithUnit:(NSString *)unit {
    return [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleDecimal unit:unit minimum:nil maximum:nil];
}
+ (ORKNumericAnswerFormat *)integerAnswerFormatWithUnit:(NSString *)unit {
    return [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger unit:unit minimum:nil maximum:nil];
}

+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormat {
    return [ORKTimeOfDayAnswerFormat new];
}
+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(NSDateComponents *)defaultComponents {
    return [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:defaultComponents];
}

+ (ORKDateAnswerFormat *)dateTimeAnswerFormat {
    return [[ORKDateAnswerFormat alloc] initWithStyle:ORKDateAnswerStyleDateAndTime];
}
+ (ORKDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                          minimumDate:(NSDate *)minimumDate
                                          maximumDate:(NSDate *)maximumDate
                                             calendar:(NSCalendar *)calendar {
    return [[ORKDateAnswerFormat alloc] initWithStyle:ORKDateAnswerStyleDateAndTime
                                         defaultDate:defaultDate
                                         minimumDate:minimumDate
                                         maximumDate:maximumDate
                                            calendar:calendar];
}

+ (ORKDateAnswerFormat *)dateAnswerFormat {
    return [[ORKDateAnswerFormat alloc] initWithStyle:ORKDateAnswerStyleDate];
}
+ (ORKDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(NSDate *)defaultDate
                                      minimumDate:(NSDate *)minimumDate
                                      maximumDate:(NSDate *)maximumDate
                                         calendar:(NSCalendar *)calendar  {
    return [[ORKDateAnswerFormat alloc] initWithStyle:ORKDateAnswerStyleDate
                                         defaultDate:defaultDate
                                         minimumDate:minimumDate
                                         maximumDate:maximumDate
                                            calendar:calendar];
}

+ (ORKTextAnswerFormat *)textAnswerFormat {
    return [ORKTextAnswerFormat new];
}
+ (ORKTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength {
    return [[ORKTextAnswerFormat alloc] initWithMaximumLength:maximumLength];
}

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat {
    return [ORKTimeIntervalAnswerFormat new];
}
+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval
                                                         step:(NSInteger)step {
    return [[ORKTimeIntervalAnswerFormat alloc] initWithDefaultInterval:defaultInterval step:step];
}

- (void)validateParameters {
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    return YES;
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step.
    return 0;
}

- (BOOL)isHealthKitAnswerFormat {
    return NO;
}

- (HKObjectType *)healthKitObjectType {
    return nil;
}

- (HKUnit *)healthKitUnit {
    return nil;
}

- (HKUnit *)healthKitUserUnit {
    return nil;
}

- (void)setHealthKitUserUnit:(HKUnit *)unit {
    
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeNone;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return self;
}

- (Class)questionResultClass {
    return [ORKQuestionResult class];
}

- (ORKQuestionResult *)resultWithIdentifier:(NSString *)identifier answer:(id)answer {
    ORKQuestionResult *questionResult = [[[self questionResultClass] alloc] initWithIdentifier:identifier];
    questionResult.answer = answer;
    questionResult.questionType = self.questionType;
    return questionResult;
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    if (impliedFormat == self) {
        return YES;
    } else {
        return [impliedFormat isAnswerValidWithString:text];
    }
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    return nil;
}

@end


#pragma mark - ORKValuePickerAnswerFormat

static void ork_validateChoices(NSArray *choices) {
    const NSInteger ORKAnswerFormatMinimumNumberOfChoices = 1;
    if (choices.count < ORKAnswerFormatMinimumNumberOfChoices) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"The number of choices can not be less than %@.", @(ORKAnswerFormatMinimumNumberOfChoices)]
                                     userInfo:nil];
    }
}

static NSArray *ork_processTextChoices(NSArray *textChoices) {
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    for (id object in textChoices) {
        if ([object isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)object;
            [choices addObject: [ORKTextChoice choiceWithText:string detailText: nil value:string]];
        } else if ([object isKindOfClass:[ORKTextChoice class]]) {
            [choices addObject:object];
            
        } else if ([object isKindOfClass:[NSArray class]]) {
            
            NSArray *array = (NSArray *)object;
            if ([array count] > 1 &&
                [array[0] isKindOfClass:[NSString class]] &&
                [array[1] isKindOfClass:[NSString class]]) {
                
                [choices addObject: [ORKTextChoice choiceWithText:array[0] detailText:array[1] value:array[0]]];
            } else if ([array count] == 1 &&
                       [array[0] isKindOfClass:[NSString class]]) {
                [choices addObject: [ORKTextChoice choiceWithText:array[0] detailText:@"" value:array[0]]];
            } else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Eligible array type Choice item should contain one or two NSString object." userInfo:@{@"choice" : object }];
            }
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Eligible choice item's type are ORKTextChoice, NSString, and NSArray" userInfo:@{@"choice" : object }];
        }
    }
    return choices;
}


@implementation ORKValuePickerAnswerFormat

- (instancetype)initWithTextChoices:(NSArray *)textChoices {
    
    self = [super init];
    if (self) {
        
        _textChoices = ork_processTextChoices(textChoices);
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    ork_validateChoices(_textChoices);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.textChoices, castObject.textChoices));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.textChoices hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, textChoices, ORKTextChoice);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, textChoices);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeSingleChoice;
}

@end


#pragma mark - ORKImageChoiceAnswerFormat

@implementation ORKImageChoiceAnswerFormat

- (instancetype)initWithImageChoices:(NSArray *)imageChoices {
    self = [super init];
    if (self) {
        NSMutableArray *choices = [[NSMutableArray alloc] init];
        
        for (NSObject *obj in imageChoices) {
            if ([obj isKindOfClass:[ORKImageChoice class]]) {
                
                [choices addObject:obj];
                
            } else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Options should be instances of ORKImageChoice" userInfo:@{ @"option" : obj }];
            }
        }
        _imageChoices = choices;
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    ork_validateChoices(_imageChoices);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.imageChoices, castObject.imageChoices));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.imageChoices hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, imageChoices, ORKImageChoice);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, imageChoices);
    
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeSingleChoice;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

@end


#pragma mark - ORKTextChoiceAnswerFormat

@implementation ORKTextChoiceAnswerFormat

- (instancetype)initWithStyle:(ORKChoiceAnswerStyle)style
                 textChoices:(NSArray *)textChoices {
    self = [super init];
    if (self) {
        _style = style;
        _textChoices = ork_processTextChoices(textChoices);
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    ork_validateChoices(_textChoices);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.textChoices, castObject.textChoices) &&
            (_style == castObject.style));
}

- (NSUInteger)hash {
    return [super hash] ^ [self.textChoices hash] ^ _style;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, textChoices, ORKTextChoice);
        ORK_DECODE_ENUM(aDecoder, style);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, textChoices);
    ORK_ENCODE_ENUM(aCoder, style);
    
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeSingleChoice + _style;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

@end


#pragma mark - ORKTextChoice

@implementation ORKTextChoice {
    NSString *_text;
    id<NSCopying, NSCoding, NSObject> _value;
}

+ (instancetype)choiceWithText:(NSString *)text detailText:(NSString *)detailText value:(id<NSCopying, NSCoding, NSObject>)value {
    ORKTextChoice *option = [[ORKTextChoice alloc] initWithText:text detailText:detailText value:value];
    return option;
}

+ (instancetype)choiceWithText:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value {
    return [ORKTextChoice choiceWithText:text detailText:nil value:value];
}

- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText value:(id<NSCopying,NSCoding,NSObject>)value {
    self = [super init];
    if (self) {
        _text = [text copy];
        _detailText = [detailText copy];
        _value = value;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    // Ignore the task reference - it's not part of the content of the step
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.detailText, castObject.detailText)
            && ORKEqualObjects(self.value, castObject.value));
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step
    return [_text hash] ^ [_detailText hash] ^ [_value hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, detailText, NSString);
        ORK_DECODE_OBJ(aDecoder, value);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, value);
    ORK_ENCODE_OBJ(aCoder, detailText);
}

@end


#pragma mark - ORKImageChoice

@implementation ORKImageChoice {
    NSString *_text;
    id<NSCopying, NSCoding, NSObject> _value;
}

+ (instancetype)choiceWithNormalImage:(UIImage *)normal selectedImage:(UIImage *)selected text:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value {
    return [[ORKImageChoice alloc] initWithNormalImage:normal selectedImage:selected text:text value:value];
}

- (instancetype)initWithNormalImage:(UIImage *)normal selectedImage:(UIImage *)selected text:(NSString *)text value:(id<NSCopying,NSCoding,NSObject>)value {
    self = [super init];
    if (self) {
        _text = [text copy];
        _value = value;
        _normalStateImage = normal;
        _selectedStateImage = selected;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)text {
    return _text;
}

- (id<NSCopying, NSCoding>)value {
    return _value;
}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    // Ignore the task reference - it's not part of the content of the step.
    
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.value, castObject.value)
            && ORKEqualObjects(self.normalStateImage, castObject.normalStateImage)
            && ORKEqualObjects(self.selectedStateImage, castObject.selectedStateImage));
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step.
    return [_text hash] ^ [_value hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ(aDecoder, value);
        ORK_DECODE_IMAGE(aDecoder, normalStateImage);
        ORK_DECODE_IMAGE(aDecoder, selectedStateImage);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, value);
    ORK_ENCODE_IMAGE(aCoder, normalStateImage);
    ORK_ENCODE_IMAGE(aCoder, selectedStateImage);
}

@end


#pragma mark - ORKBooleanAnswerFormat

@implementation ORKBooleanAnswerFormat

- (ORKQuestionType) questionType {
    return ORKQuestionTypeBoolean;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                            textChoices:@[[ORKTextChoice choiceWithText:ORKLocalizedString(@"BOOL_YES",nil) value:@(YES)],
                                                          [ORKTextChoice choiceWithText:ORKLocalizedString(@"BOOL_NO",nil) value:@(NO) ]]];
}

- (Class)questionResultClass {
    return [ORKBooleanQuestionResult class];
}

@end

#pragma mark - ORKTimeOfDayAnswerFormat

@implementation ORKTimeOfDayAnswerFormat

- (instancetype)init {
    self = [self initWithDefaultComponents:nil];
    return self;
}

- (instancetype)initWithDefaultComponents:(NSDateComponents *)defaultComponents {
    self = [super init];
    if (self) {
        _defaultComponents = [defaultComponents copy];
    }
    return self;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeTimeOfDay;
}

- (Class)questionResultClass {
    return [ORKTimeOfDayQuestionResult class];
}

- (NSDate *)pickerDefaultDate {
    
    if (self.defaultComponents) {
        return ORKTimeOfDayDateFromComponents(self.defaultComponents);
    }
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:[NSDate date]];
    NSDateComponents *newDateComponents = [[NSDateComponents alloc] init];
    newDateComponents.calendar = ORKTimeOfDayReferenceCalendar();
    newDateComponents.hour = dateComponents.hour;
    newDateComponents.minute = dateComponents.minute;
    
    return ORKTimeOfDayDateFromComponents(newDateComponents);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.defaultComponents, castObject.defaultComponents));
}

- (NSUInteger)hash {
    // Don't bother including everything
    return [super hash] & [self.defaultComponents hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, defaultComponents, NSDateComponents);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, defaultComponents);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


#pragma mark - ORKDateAnswerFormat

@implementation ORKDateAnswerFormat

- (Class)questionResultClass {
    return [ORKDateQuestionResult class];
}

- (instancetype)initWithStyle:(ORKDateAnswerStyle)style {
    self = [self initWithStyle:style defaultDate:nil minimumDate:nil maximumDate:nil calendar:nil];
    return self;
}

- (instancetype)initWithStyle:(ORKDateAnswerStyle)style
                  defaultDate:(NSDate *)defaultDate
                  minimumDate:(NSDate *)minimum
                  maximumDate:(NSDate *)maximum
                     calendar:(NSCalendar *)calendar {
    self = [super init];
    if (self) {
        _style = style;
        _defaultDate = [defaultDate copy];
        _minimumDate = [minimum copy];
        _maximumDate = [maximum copy];
        _calendar = [calendar copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.defaultDate, castObject.defaultDate) &&
            ORKEqualObjects(self.minimumDate, castObject.minimumDate) &&
            ORKEqualObjects(self.maximumDate, castObject.maximumDate) &&
            ORKEqualObjects(self.calendar, castObject.calendar) &&
            (_style == castObject.style));
}

- (NSUInteger)hash {
    // Don't bother including everything - style is the main item.
    return [super hash] & [self.defaultDate hash] ^ _style;
}

- (NSCalendar *)currentCalendar {
    return (_calendar ? : [NSCalendar currentCalendar]);
}

- (NSDateFormatter *)resultDateFormatter {
    NSDateFormatter *dfm = nil;
    switch (self.questionType) {
        case ORKQuestionTypeDate: {
            dfm = ORKResultDateFormatter();
            break;
        }
        case ORKQuestionTypeTimeOfDay: {
            dfm = ORKResultTimeFormatter();
            break;
        }
        case ORKQuestionTypeDateAndTime: {
            dfm = ORKResultDateTimeFormatter();
            break;
        }
        default:
            break;
    }
    
    dfm = [dfm copy];
    dfm.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return dfm;
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dfm = [self resultDateFormatter];
    return [dfm stringFromDate:date];
}

- (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dfm = [self resultDateFormatter];
    return [dfm dateFromString:string];
}

- (NSDate *)pickerDefaultDate {
    return (self.defaultDate ? : [NSDate date]);
   
}

- (NSDate *)pickerMinimumDate {
    return self.minimumDate;
}

- (NSDate *)pickerMaximumDate {
   return self.maximumDate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, style);
        ORK_DECODE_OBJ_CLASS(aDecoder, minimumDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, maximumDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, defaultDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, calendar, NSCalendar);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, style);
    ORK_ENCODE_OBJ(aCoder, minimumDate);
    ORK_ENCODE_OBJ(aCoder, maximumDate);
    ORK_ENCODE_OBJ(aCoder, defaultDate);
    ORK_ENCODE_OBJ(aCoder, calendar);
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeDateAndTime + _style;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


#pragma mark - ORKNumericAnswerFormat

@implementation ORKNumericAnswerFormat

- (Class)questionResultClass {
    return [ORKNumericQuestionResult class];
}

- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style {
    self = [self initWithStyle:style unit:nil minimum:nil maximum:nil];
    return self;
}

- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style unit:(NSString *)unit minimum:(NSNumber *)minimum maximum:(NSNumber *)maximum {
    self = [super init];
    if (self) {
        _style = style;
        _unit = [unit copy];
        self.minimum = minimum;
        self.maximum = maximum;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, style);
        ORK_DECODE_OBJ_CLASS(aDecoder, unit, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, minimum, NSNumber);
        ORK_DECODE_OBJ_CLASS(aDecoder, maximum, NSNumber);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, style);
    ORK_ENCODE_OBJ(aCoder, unit);
    ORK_ENCODE_OBJ(aCoder, minimum);
    ORK_ENCODE_OBJ(aCoder, maximum);
    
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKNumericAnswerFormat *fmt = [[[self class] allocWithZone:zone] init];
    fmt->_style = _style;
    fmt->_unit = [_unit copy];
    fmt->_minimum = [_minimum copy];
    fmt->_maximum = [_maximum copy];
    return fmt;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.unit, castObject.unit) &&
            ORKEqualObjects(self.minimum, castObject.minimum) &&
            ORKEqualObjects(self.maximum, castObject.maximum) &&
            (_style == castObject.style));
}

- (NSUInteger)hash {
    // Don't bother including everything - style is the main item
    return [super hash] ^ [self.unit hash] & _style;
}

- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style unit:(NSString *)unit {
    return [self initWithStyle:style unit:unit minimum:nil maximum:nil];
}

+ (instancetype)decimalAnswerFormatWithUnit:(NSString *)unit {
    return [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleDecimal unit:unit];
}

+ (instancetype)integerAnswerFormatWithUnit:(NSString *)unit {
    return [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger unit:unit];
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeDecimal + _style;
    
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    BOOL isValid = NO;
    if ([text length] > 0) {
        NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:text locale:[NSLocale currentLocale]];
        if (num) {
            isValid = YES;
            if (isnan([num doubleValue])) {
                isValid = NO;
            } else if (self.minimum && ([self.minimum doubleValue] > [num doubleValue])) {
                isValid = NO;
            } else if (self.maximum && ([self.maximum doubleValue] < [num doubleValue])) {
                isValid = NO;
            }
        }
    }
    return isValid;
}

- (NSNumberFormatter *)makeNumberFormatter {
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.usesGroupingSeparator = NO;
    return numberFormatter;
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    if (! [text length]) {
        return nil;
    }
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:text locale:[NSLocale currentLocale]];
    if (! num) {
        return nil;
    }
    NSString *string = nil;
    NSNumberFormatter *formatter = [self makeNumberFormatter];
    if (self.minimum && ([self.minimum doubleValue] > [num doubleValue])) {
        string = [NSString stringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_BELOW_MAXIMUM", nil), text, [formatter stringFromNumber:self.minimum]];
    } else if (self.maximum && ([self.maximum doubleValue] < [num doubleValue])) {
        string = [NSString stringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_ABOVE_MAXIMUM", nil), text, [formatter stringFromNumber:self.maximum]];
    } else {
        string = [NSString stringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_OTHER", nil), text];
    }
    return string;
}

#pragma mark - Text Sanitization

- (NSString *)removeDecimalSeparatorsFromText:(NSString *)text numAllowed:(NSInteger)numAllowed separator:(NSString *)decimalSeparator {
    NSMutableString *scanningText = [text mutableCopy];
    NSMutableString *sanitizedText = [[NSMutableString alloc] init];
    BOOL finished = NO;
    while (!finished) {
        NSRange range = [scanningText rangeOfString:decimalSeparator];
        if (range.length == 0) {
            // If our range's length is 0, there are no more decimal separators
            [sanitizedText appendString:scanningText];
            finished = YES;
        } else if (numAllowed <= 0) {
            // If we found a decimal separator and no more are allowed, remove the substring
            [scanningText deleteCharactersInRange:range];
        } else {
            NSInteger maxRange = NSMaxRange(range);
            NSString *processedString = [scanningText substringToIndex:maxRange];
            [sanitizedText appendString:processedString];
            [scanningText deleteCharactersInRange:NSMakeRange(0, maxRange)];
            --numAllowed;
        }
    }
    return sanitizedText;
}

- (NSString *)sanitizedTextFieldText:(NSString *)text decimalSeparator:(NSString *)separator {
    NSString *sanitizedText = text;
    if (_style == ORKNumericAnswerStyleDecimal) {
        sanitizedText = [self removeDecimalSeparatorsFromText:text numAllowed:1 separator:(NSString *)separator];
    } else if (_style == ORKNumericAnswerStyleInteger) {
        sanitizedText = [self removeDecimalSeparatorsFromText:text numAllowed:0 separator:(NSString *)separator];
    }
    return sanitizedText;
}

@end


#pragma mark - ORKScaleAnswerFormat

@implementation ORKScaleAnswerFormat {
    NSNumberFormatter *_numberFormatter;
}

- (Class)questionResultClass {
    return [ORKScaleQuestionResult class];
}

- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step
                            vertical:(BOOL)vertical
             maximumValueDescription:(nullable NSString *)maximumValueDescription
             minimumValueDescription:(nullable NSString *)minimumValueDescription {
    self = [super init];
    if (self) {
        _minimum = minimumValue;
        _maximum = maximumValue;
        _defaultValue = defaultValue;
        _step = step;
        _vertical = vertical;
        _maximumValueDescription = maximumValueDescription;
        _minimumValueDescription = minimumValueDescription;
        
        [self validateParameters];
    }
    return self;
}

- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step
                            vertical:(BOOL)vertical {
    return [self initWithMaximumValue:maximumValue
                         minimumValue:minimumValue
                         defaultValue:defaultValue
                                 step:step
                             vertical:vertical
              maximumValueDescription:nil
              minimumValueDescription:nil];
}

- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step {
    return [self initWithMaximumValue:maximumValue
                         minimumValue:minimumValue
                         defaultValue:defaultValue
                                 step:step
                             vertical:NO
              maximumValueDescription:nil
              minimumValueDescription:nil];
}

- (NSNumber *)minimumNumber {
    return @(_minimum);
}
- (NSNumber *)maximumNumber {
    return @(_maximum);
}
- (NSNumber *)defaultNumber {
    if ( _defaultValue > _maximum || _defaultValue < _minimum) {
        return nil;
    }
    
    NSInteger integer = round((double)(_defaultValue-_minimum)/(double)_step)*_step + _minimum;
    
    return @(integer);
}
- (NSString *)localizedStringForNumber:(NSNumber *)number {
    return [self.numberFormatter stringFromNumber:number];
}

- (NSNumberFormatter *)numberFormatter {
    if (! _numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.locale = [NSLocale autoupdatingCurrentLocale];
        _numberFormatter.maximumFractionDigits = 0;
    }
    return _numberFormatter;
}

- (NSInteger)numberOfSteps {
    return (_maximum - _minimum)/_step;
}

- (NSNumber *)normalizedValueForNumber:(NSNumber *)number {
    return @([number integerValue]);
}

- (void)validateParameters {
    [super validateParameters];
    
    const NSInteger ORKScaleAnswerFormatMinimumStepSize = 1;
    const NSInteger ORKScaleAnswerFormatMinimumStepCount = 1;
    const NSInteger ORKScaleAnswerFormatMaximumStepCount = 13;
    
    const NSInteger ORKScaleAnswerFormatValueLowerbound = -10000;
    const NSInteger ORKScaleAnswerFormatValueUpperbound = 10000;
    
    if (_maximum < _minimum) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Expect maximumValue larger than minimumValue"] userInfo:nil];
    }
    
    if (_step < ORKScaleAnswerFormatMinimumStepSize) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Expect step value not less than than %@.", @(ORKScaleAnswerFormatMinimumStepSize)]
                                     userInfo:nil];
    }
    
    NSInteger mod = (_maximum - _minimum) % _step;
    if (mod != 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Expect the difference between maximumValue and minimumValue is divisible by step value"] userInfo:nil];
    }
    
    NSInteger steps = (_maximum - _minimum)/_step;
    if (steps < ORKScaleAnswerFormatMinimumStepCount || steps > ORKScaleAnswerFormatMaximumStepCount) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Expect the total number of steps between minimumValue and maximumValue more than %@ and no more than %@.", @(ORKScaleAnswerFormatMinimumStepCount), @(ORKScaleAnswerFormatMaximumStepCount)]
                                     userInfo:nil];
    }
    
    if (_minimum < ORKScaleAnswerFormatValueLowerbound) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"minimumValue should not less than %@", @(ORKScaleAnswerFormatValueLowerbound)]
                                     userInfo:nil];
    }
    
    if (_maximum > ORKScaleAnswerFormatValueUpperbound) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maximumValue should not more than %@", @(ORKScaleAnswerFormatValueUpperbound)]
                                     userInfo:nil];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, maximum);
        ORK_DECODE_INTEGER(aDecoder, minimum);
        ORK_DECODE_INTEGER(aDecoder, step);
        ORK_DECODE_INTEGER(aDecoder, defaultValue);
        ORK_DECODE_BOOL(aDecoder, vertical);
        ORK_DECODE_OBJ(aDecoder, maximumValueDescription);
        ORK_DECODE_OBJ(aDecoder, minimumValueDescription);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, maximum);
    ORK_ENCODE_INTEGER(aCoder, minimum);
    ORK_ENCODE_INTEGER(aCoder, step);
    ORK_ENCODE_INTEGER(aCoder, defaultValue);
    ORK_ENCODE_BOOL(aCoder, vertical);
    ORK_ENCODE_OBJ(aCoder, maximumValueDescription);
    ORK_ENCODE_OBJ(aCoder, minimumValueDescription);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (_maximum == castObject.maximum) &&
            (_minimum == castObject.minimum) &&
            (_step == castObject.step) &&
            (_defaultValue == castObject.defaultValue) &&
            ORKEqualObjects(_maximumValueDescription, castObject.maximumValueDescription) &&
            ORKEqualObjects(_maximumValueDescription, castObject.maximumValueDescription));
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeScale;
}

@end


#pragma mark - ORKContinuousScaleAnswerFormat

@implementation ORKContinuousScaleAnswerFormat {
    NSNumberFormatter *_numberFormatter;
}

- (Class)questionResultClass {
    return [ORKScaleQuestionResult class];
}

- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits
                            vertical:(BOOL)vertical
             maximumValueDescription:(nullable NSString *)maximumValueDescription
             minimumValueDescription:(nullable NSString *)minimumValueDescription {
    self = [super init];
    if (self) {
        _minimum = minimumValue;
        _maximum = maximumValue;
        _defaultValue = defaultValue;
        _maximumFractionDigits = maximumFractionDigits;
        _vertical = vertical;
        _maximumValueDescription = maximumValueDescription;
        _minimumValueDescription = minimumValueDescription;
        
        [self validateParameters];
    }
    return self;
}

- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits
                            vertical:(BOOL)vertical {
    return [self initWithMaximumValue:maximumValue
                         minimumValue:minimumValue
                         defaultValue:defaultValue
                maximumFractionDigits:maximumFractionDigits
                             vertical:vertical
              maximumValueDescription:nil
              minimumValueDescription:nil];
}

- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits {
    return [self initWithMaximumValue:maximumValue
                         minimumValue:minimumValue
                         defaultValue:defaultValue
                maximumFractionDigits:maximumFractionDigits
                             vertical:NO
              maximumValueDescription:nil
              minimumValueDescription:nil];
}

- (NSNumber *)minimumNumber {
    return @(_minimum);
}
- (NSNumber *)maximumNumber {
    return @(_maximum);
}
- (NSNumber *)defaultNumber {
    if ( _defaultValue > _maximum || _defaultValue < _minimum) {
        return nil;
    }
    return @(_defaultValue);
}
- (NSString *)localizedStringForNumber:(NSNumber *)number {
    return [self.numberFormatter stringFromNumber:number];
}

- (NSNumberFormatter *)numberFormatter {
    if (! _numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = ORKNumberFormattingStyleConvert(_numberStyle);
        _numberFormatter.maximumFractionDigits = _maximumFractionDigits;
    }
    return _numberFormatter;
}

- (NSInteger)numberOfSteps {
    return 0;
}

- (NSNumber *)normalizedValueForNumber:(NSNumber *)number {
    return number;
}

- (void)validateParameters {
    [super validateParameters];
    
    const double ORKScaleAnswerFormatValueLowerbound = -10000;
    const double ORKScaleAnswerFormatValueUpperbound = 10000;
    
    // Just clamp maximumFractionDigits to be 0-4. This is all aimed at keeping the maximum
    // number of digits down to 6 or less.
    _maximumFractionDigits = MAX(_maximumFractionDigits, 0);
    _maximumFractionDigits = MIN(_maximumFractionDigits, 4);
    
    double effectiveUpperbound = ORKScaleAnswerFormatValueUpperbound * pow(0.1, _maximumFractionDigits);
    double effectiveLowerbound = ORKScaleAnswerFormatValueLowerbound * pow(0.1, _maximumFractionDigits);
    
    if (_maximum <= _minimum) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Expect maximumValue larger than minimumValue"] userInfo:nil];
    }
    
    if (_minimum < effectiveLowerbound) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"minimumValue should not less than %@ with %@ fractional digits", @(effectiveLowerbound), @(_maximumFractionDigits)]
                                     userInfo:nil];
    }
    
    if (_maximum > effectiveUpperbound) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"maximumValue should not more than %@ with %@ fractional digits", @(effectiveUpperbound), @(_maximumFractionDigits)]
                                     userInfo:nil];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, maximum);
        ORK_DECODE_DOUBLE(aDecoder, minimum);
        ORK_DECODE_DOUBLE(aDecoder, defaultValue);
        ORK_DECODE_INTEGER(aDecoder, maximumFractionDigits);
        ORK_DECODE_BOOL(aDecoder, vertical);
        ORK_DECODE_ENUM(aDecoder, numberStyle);
        ORK_DECODE_OBJ(aDecoder, maximumValueDescription);
        ORK_DECODE_OBJ(aDecoder, minimumValueDescription);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, maximum);
    ORK_ENCODE_DOUBLE(aCoder, minimum);
    ORK_ENCODE_DOUBLE(aCoder, defaultValue);
    ORK_ENCODE_INTEGER(aCoder, maximumFractionDigits);
    ORK_ENCODE_BOOL(aCoder, vertical);
    ORK_ENCODE_ENUM(aCoder, numberStyle);
    ORK_ENCODE_OBJ(aCoder, maximumValueDescription);
    ORK_ENCODE_OBJ(aCoder, minimumValueDescription);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (_maximum == castObject.maximum) &&
            (_minimum == castObject.minimum) &&
            (_defaultValue == castObject.defaultValue) &&
            (_maximumFractionDigits == castObject.maximumFractionDigits) &&
            (_numberStyle == castObject.numberStyle) &&
            ORKEqualObjects(_maximumValueDescription, castObject.maximumValueDescription) &&
            ORKEqualObjects(_maximumValueDescription, castObject.maximumValueDescription)) ;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeScale;
}

@end


#pragma mark - ORKTextAnswerFormat

@implementation ORKTextAnswerFormat

- (Class)questionResultClass {
    return [ORKTextQuestionResult class];
}

- (instancetype)initWithMaximumLength:(NSInteger)maximumLength {
    self = [super init];
    if (self) {
        _maximumLength = maximumLength;
        _autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _autocorrectionType = UITextAutocorrectionTypeDefault;
        _spellCheckingType = UITextSpellCheckingTypeDefault;
        _multipleLines = YES;
    }
    return self;
}

- (instancetype)init {
    self = [self initWithMaximumLength:0];
    return self;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeText;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTextAnswerFormat *fmt = [[[self class] allocWithZone:zone] init];
    fmt->_maximumLength = _maximumLength;
    fmt->_autocapitalizationType = _autocapitalizationType;
    fmt->_autocorrectionType = _autocorrectionType;
    fmt->_spellCheckingType = _spellCheckingType;
    fmt->_multipleLines = _multipleLines;
    return fmt;
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    return (_maximumLength == 0 || [text length] <= _maximumLength);
}

#pragma mark NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _multipleLines = YES;
        ORK_DECODE_INTEGER(aDecoder, maximumLength);
        ORK_DECODE_ENUM(aDecoder, autocapitalizationType);
        ORK_DECODE_ENUM(aDecoder, autocorrectionType);
        ORK_DECODE_ENUM(aDecoder, spellCheckingType);
        ORK_DECODE_BOOL(aDecoder, multipleLines);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, maximumLength);
    ORK_ENCODE_ENUM(aCoder, autocapitalizationType);
    ORK_ENCODE_ENUM(aCoder, autocorrectionType);
    ORK_ENCODE_ENUM(aCoder, spellCheckingType);
    ORK_ENCODE_BOOL(aCoder, multipleLines);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.maximumLength == castObject.maximumLength &&
             self.autocapitalizationType == castObject.autocapitalizationType &&
             self.autocorrectionType == castObject.autocorrectionType &&
             self.spellCheckingType == castObject.spellCheckingType &&
             self.multipleLines == castObject.multipleLines));
}

@end


#pragma mark - ORKTimeIntervalAnswerFormat

@implementation ORKTimeIntervalAnswerFormat

- (Class)questionResultClass {
    return [ORKTimeIntervalQuestionResult class];
}

- (instancetype)init {
    self = [self initWithDefaultInterval:0 step:1];
    return self;
}

- (instancetype)initWithDefaultInterval:(NSTimeInterval)defaultInterval step:(NSInteger)step {
    self = [super init];
    if (self) {
        _defaultInterval = defaultInterval;
        _step = step;
        [self validateParameters];
    }
    return self;
}

- (ORKQuestionType) questionType {
    return ORKQuestionTypeTimeInterval;
}

- (NSTimeInterval)pickerDefaultDuration {

    NSTimeInterval value = MAX([self defaultInterval], 0);
    
    // imitate UIDatePicker's behavior
    NSTimeInterval stepInSeconds = _step*60;
    value  = floor(value/stepInSeconds)*stepInSeconds;
    
    return value;
}

- (void)validateParameters {
    [super validateParameters];
    
    const NSInteger ORKTimeIntervalAnswerFormatStepLowerBound = 1;
    const NSInteger ORKTimeIntervalAnswerFormatStepUpperBound = 30;
    
    if (_step < ORKTimeIntervalAnswerFormatStepLowerBound || _step > ORKTimeIntervalAnswerFormatStepUpperBound) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Step should be between %@ and %@.", @(ORKTimeIntervalAnswerFormatStepLowerBound), @(ORKTimeIntervalAnswerFormatStepUpperBound)] userInfo:nil];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_DOUBLE(aDecoder, defaultInterval);
        ORK_DECODE_DOUBLE(aDecoder, step);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_DOUBLE(aCoder, defaultInterval);
    ORK_ENCODE_DOUBLE(aCoder, step);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (_defaultInterval == castObject.defaultInterval) &&
            (_step == castObject.step));
}

@end
