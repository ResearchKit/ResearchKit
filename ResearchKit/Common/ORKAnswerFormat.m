/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Scott Guelich.
 Copyright (c) 2016, Ricardo Sánchez-Sáez.
 Copyright (c) 2017, Medable Inc. All rights reserved.
 Copyright (c) 2017, Macro Yau.
 Copyright (c) 2017, Sage Bionetworks.
 
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
#import "ORKAnswerFormat_Internal.h"

#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKHealthAnswerFormat.h"
#import "ORKResult_Private.h"

#import "ORKHelpers_Internal.h"

@import HealthKit;
@import MapKit;


NSString *const EmailValidationRegularExpressionPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";

id ORKNullAnswerValue() {
    return [NSNull null];
}

BOOL ORKIsAnswerEmpty(id answer) {
    return  (answer == nil) ||
    (answer == ORKNullAnswerValue()) ||
    ([answer isKindOfClass:[NSArray class]] && ((NSArray *)answer).count == 0);     // Empty answer of choice or value picker
}

NSString *ORKQuestionTypeString(ORKQuestionType questionType) {
#define SQT_CASE(x) case ORKQuestionType ## x : return @ORK_STRINGIFY(ORKQuestionType ## x);
    switch (questionType) {
            SQT_CASE(None);
            SQT_CASE(Scale);
            SQT_CASE(SingleChoice);
            SQT_CASE(MultipleChoice);
            SQT_CASE(MultiplePicker);
            SQT_CASE(Decimal);
            SQT_CASE(Integer);
            SQT_CASE(Boolean);
            SQT_CASE(Text);
            SQT_CASE(DateAndTime);
            SQT_CASE(TimeOfDay);
            SQT_CASE(Date);
            SQT_CASE(TimeInterval);
            SQT_CASE(Height);
            SQT_CASE(Location);
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init {
    ORKThrowMethodUnavailableException();
}
#pragma clang diagnostic pop

- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore {
    self = [super init];
    if (self) {
        _healthStore = healthStore;
        
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) {
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

- (id)defaultValueForCharacteristicType:(HKCharacteristicType *)characteristicType error:(NSError **)error {
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
    if ([[characteristicType identifier] isEqualToString:HKCharacteristicTypeIdentifierFitzpatrickSkinType]) {
        HKFitzpatrickSkinTypeObject *skinType = [_healthStore fitzpatrickSkinTypeWithError:error];
        if (skinType && skinType.skinType != HKFitzpatrickSkinTypeNotSet) {
            result = @(skinType.skinType);
        }
        if (result) {
            result = @[result];
        }
    }
    if (ORK_IOS_10_WATCHOS_3_AVAILABLE && [[characteristicType identifier] isEqualToString:HKCharacteristicTypeIdentifierWheelchairUse]) {
        HKWheelchairUseObject *wheelchairUse = [_healthStore wheelchairUseWithError:error];
        if (wheelchairUse && wheelchairUse.wheelchairUse != HKWheelchairUseNotSet) {
            result = (wheelchairUse.wheelchairUse == HKWheelchairUseYes) ? @YES : @NO;
        }
        if (result) {
            result = @[result];
        }
    }
    return result;
}

- (void)fetchDefaultValueForQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit handler:(void(^)(id defaultValue, NSError *error))handler {
    if (!unit) {
        handler(nil, nil);
        return;
    }
    
    HKHealthStore *healthStore = _healthStore;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:1 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            HKQuantitySample *sample = results.firstObject;
            id value = nil;
            if (sample) {
                if (unit == [HKUnit percentUnit]) {
                    value = @(100 * [sample.quantity doubleValueForUnit:unit]);
                } else {
                    value = @([sample.quantity doubleValueForUnit:unit]);
                }
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
    if (!handled) {
        handler(nil, nil);
    }
}

- (HKUnit *)defaultHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat {
    __block HKUnit *unit = [answerFormat healthKitUnit];
    HKObjectType *objectType = [answerFormat healthKitObjectType];
    if (![[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) {
        return unit;
    }
    
    if (unit == nil && [objectType isKindOfClass:[HKQuantityType class]] && [HKHealthStore isHealthDataAvailable]) {
        unit = _unitsTable[objectType];
        if (unit) {
            return unit;
        }
        if (!_unitsTable) {
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

+ (ORKTextScaleAnswerFormat *)textScaleAnswerFormatWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices
                                                      defaultIndex:(NSInteger)defaultIndex
                                                          vertical:(BOOL)vertical {
    return [[ORKTextScaleAnswerFormat alloc] initWithTextChoices:textChoices
                                                    defaultIndex:defaultIndex
                                                        vertical:vertical];
}

+ (ORKBooleanAnswerFormat *)booleanAnswerFormat {
    return [ORKBooleanAnswerFormat new];
}

+ (ORKBooleanAnswerFormat *)booleanAnswerFormatWithYesString:(NSString *)yes noString:(NSString *)no {
    return [[ORKBooleanAnswerFormat alloc] initWithYesString:yes noString:no];
}

+ (ORKValuePickerAnswerFormat *)valuePickerAnswerFormatWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices {
    return [[ORKValuePickerAnswerFormat alloc] initWithTextChoices:textChoices];
}

+ (ORKMultipleValuePickerAnswerFormat *)multipleValuePickerAnswerFormatWithValuePickers:(NSArray<ORKValuePickerAnswerFormat *> *)valuePickers {
    return [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:valuePickers];
}

+ (ORKImageChoiceAnswerFormat *)choiceAnswerFormatWithImageChoices:(NSArray<ORKImageChoice *> *)imageChoices {
    return [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:imageChoices];
}

+ (ORKTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(ORKChoiceAnswerStyle)style
                                               textChoices:(NSArray<ORKTextChoice *> *)textChoices {
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

+ (ORKTextAnswerFormat *)textAnswerFormatWithValidationRegularExpression:(NSRegularExpression *)validationRegularExpression
                                                          invalidMessage:(NSString *)invalidMessage {
    return [[ORKTextAnswerFormat alloc] initWithValidationRegularExpression:validationRegularExpression
                                                             invalidMessage:invalidMessage];
}

+ (ORKEmailAnswerFormat *)emailAnswerFormat {
    return [ORKEmailAnswerFormat new];
}

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat {
    return [ORKTimeIntervalAnswerFormat new];
}

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval
                                                                        step:(NSInteger)step {
    return [[ORKTimeIntervalAnswerFormat alloc] initWithDefaultInterval:defaultInterval step:step];
}

+ (ORKHeightAnswerFormat *)heightAnswerFormat {
    return [[ORKHeightAnswerFormat alloc] init];
}

+ (ORKHeightAnswerFormat *)heightAnswerFormatWithMeasurementSystem:(ORKMeasurementSystem)measurementSystem {
    return [[ORKHeightAnswerFormat alloc] initWithMeasurementSystem:measurementSystem];
}

+ (ORKLocationAnswerFormat *)locationAnswerFormat {
    return [ORKLocationAnswerFormat new];
}

- (void)validateParameters {
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    return [super init];
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

- (HKObjectType *)healthKitObjectTypeForAuthorization {
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

- (ORKQuestionType)questionType {
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
    
    /*
     ContinuousScale navigation rules always evaluate to false because the result is different from what is displayed in the UI.
     The fraction digits have to be taken into account in self.answer as well.
     */
    if ([self isKindOfClass:[ORKContinuousScaleAnswerFormat class]]) {
        NSNumberFormatter* formatter = [(ORKContinuousScaleAnswerFormat*)self numberFormatter];
        answer = [formatter numberFromString:[formatter stringFromNumber:answer]];
    }
    
    questionResult.answer = answer;
    questionResult.questionType = self.questionType;
    return questionResult;
}

- (BOOL)isAnswerValid:(id)answer {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    return impliedFormat == self ? YES : [impliedFormat isAnswerValid:answer];
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    return impliedFormat == self ? YES : [impliedFormat isAnswerValidWithString:text];
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    return nil;
}

- (NSString *)stringForAnswer:(id)answer {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    return impliedFormat == self ? nil : [impliedFormat stringForAnswer:answer];
}

@end


#pragma mark - ORKValuePickerAnswerFormat

static void ork_validateChoices(NSArray *choices) {
    const NSInteger ORKAnswerFormatMinimumNumberOfChoices = 1;
    if (choices.count < ORKAnswerFormatMinimumNumberOfChoices) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"The number of choices cannot be less than %@.", @(ORKAnswerFormatMinimumNumberOfChoices)]
                                     userInfo:nil];
    }
}

static NSArray *ork_processTextChoices(NSArray<ORKTextChoice *> *textChoices) {
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    for (id object in textChoices) {
        // TODO: Remove these first two cases, which we don't really support anymore.
        if ([object isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)object;
            [choices addObject:[ORKTextChoice choiceWithText:string value:string]];
        } else if ([object isKindOfClass:[ORKTextChoice class]]) {
            [choices addObject:object];
            
        } else if ([object isKindOfClass:[NSArray class]]) {
            
            NSArray *array = (NSArray *)object;
            if (array.count > 1 &&
                [array[0] isKindOfClass:[NSString class]] &&
                [array[1] isKindOfClass:[NSString class]]) {
                
                [choices addObject:[ORKTextChoice choiceWithText:array[0] detailText:array[1] value:array[0] exclusive:NO]];
            } else if (array.count == 1 &&
                       [array[0] isKindOfClass:[NSString class]]) {
                [choices addObject:[ORKTextChoice choiceWithText:array[0] detailText:@"" value:array[0] exclusive:NO]];
            } else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Eligible array type Choice item should contain one or two NSString object." userInfo:@{@"choice": object }];
            }
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Eligible choice item's type are ORKTextChoice, NSString, and NSArray" userInfo:@{@"choice": object }];
        }
    }
    return choices;
}


@implementation ORKValuePickerAnswerFormat {
    ORKChoiceAnswerFormatHelper *_helper;
    ORKTextChoice *_nullTextChoice;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices {
    self = [super init];
    if (self) {
        [self commonInitWithTextChoices:textChoices nullChoice:nil];
    }
    return self;
}

- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices nullChoice:(ORKTextChoice *)nullChoice {
    self = [super init];
    if (self) {
        [self commonInitWithTextChoices:textChoices nullChoice:nullChoice];
    }
    return self;
}

- (void)commonInitWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices nullChoice:(ORKTextChoice *)nullChoice {
    _textChoices = ork_processTextChoices(textChoices);
    _nullTextChoice = nullChoice;
    _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:self];
}


- (void)validateParameters {
    [super validateParameters];
    
    ork_validateChoices(_textChoices);
}

- (id)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [[[self class] alloc] initWithTextChoices:_textChoices nullChoice:_nullTextChoice];
    return copy;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.textChoices, castObject.textChoices));
}

- (NSUInteger)hash {
    return super.hash ^ _textChoices.hash;
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

- (ORKTextChoice *)nullTextChoice {
    return _nullTextChoice ?: [ORKTextChoice choiceWithText:ORKLocalizedString(@"NULL_ANSWER", nil) value:ORKNullAnswerValue()];
}

- (void)setNullTextChoice:(ORKTextChoice *)nullChoice {
    _nullTextChoice = nullChoice;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeSingleChoice;
}

- (NSString *)stringForAnswer:(id)answer {
    return [_helper stringForChoiceAnswer:answer];
}

@end


#pragma mark - ORKMultipleValuePickerAnswerFormat

@implementation ORKMultipleValuePickerAnswerFormat

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithValuePickers:(NSArray<ORKValuePickerAnswerFormat *> *)valuePickers {
    return [self initWithValuePickers:valuePickers separator:@" "];
}

- (instancetype)initWithValuePickers:(NSArray<ORKValuePickerAnswerFormat *> *)valuePickers separator:(NSString *)separator {
    self = [super init];
    if (self) {
        for (ORKValuePickerAnswerFormat *valuePicker in valuePickers) {
            // Do not show placeholder text for multiple component picker
            [valuePicker setNullTextChoice: [ORKTextChoice choiceWithText:@"" value:ORKNullAnswerValue()]];
        }
        _valuePickers = ORKArrayCopyObjects(valuePickers);
        _separator = [separator copy];
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    for (ORKValuePickerAnswerFormat *valuePicker in self.valuePickers) {
        [valuePicker validateParameters];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    __typeof(self) copy = [[[self class] alloc] initWithValuePickers:self.valuePickers separator:self.separator];
    return copy;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.valuePickers, castObject.valuePickers));
}

- (NSUInteger)hash {
    return super.hash ^ self.valuePickers.hash ^ self.separator.hash;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, valuePickers, ORKValuePickerAnswerFormat);
        ORK_DECODE_OBJ_CLASS(aDecoder, separator, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, valuePickers);
    ORK_ENCODE_OBJ(aCoder, separator);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (Class)questionResultClass {
    return [ORKMultipleComponentQuestionResult class];
}

- (ORKQuestionResult *)resultWithIdentifier:(NSString *)identifier answer:(id)answer {
    ORKQuestionResult *questionResult = [super resultWithIdentifier:identifier answer:answer];
    if ([questionResult isKindOfClass:[ORKMultipleComponentQuestionResult class]]) {
        ((ORKMultipleComponentQuestionResult*)questionResult).separator = self.separator;
    }
    return questionResult;
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeMultiplePicker;
}

- (NSString *)stringForAnswer:(id)answer {
    if (![answer isKindOfClass:[NSArray class]] || ([(NSArray*)answer count] != self.valuePickers.count)) {
        return nil;
    }
    
    NSArray *answers = (NSArray*)answer;
    __block NSMutableArray <NSString *> *answerTexts = [NSMutableArray new];
    [answers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *text = [self.valuePickers[idx] stringForAnswer:obj];
        if (text != nil) {
            [answerTexts addObject:text];
        } else {
            *stop = YES;
        }
    }];
    
    if (answerTexts.count != self.valuePickers.count) {
        return nil;
    }
    
    return [answerTexts componentsJoinedByString:self.separator];
}

@end


#pragma mark - ORKImageChoiceAnswerFormat

@interface ORKImageChoiceAnswerFormat () {
    ORKChoiceAnswerFormatHelper *_helper;
    
}

@end


@implementation ORKImageChoiceAnswerFormat

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithImageChoices:(NSArray<ORKImageChoice *> *)imageChoices {
    self = [super init];
    if (self) {
        NSMutableArray *choices = [[NSMutableArray alloc] init];
        
        for (NSObject *obj in imageChoices) {
            if ([obj isKindOfClass:[ORKImageChoice class]]) {
                
                [choices addObject:obj];
                
            } else {
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Options should be instances of ORKImageChoice" userInfo:@{ @"option": obj }];
            }
        }
        _imageChoices = choices;
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:self];
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
    return super.hash ^ self.imageChoices.hash;
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

- (ORKQuestionType)questionType {
    return ORKQuestionTypeSingleChoice;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

- (NSString *)stringForAnswer:(id)answer {
    return [_helper stringForChoiceAnswer:answer];
}

@end


#pragma mark - ORKTextChoiceAnswerFormat

@interface ORKTextChoiceAnswerFormat () {
    
    ORKChoiceAnswerFormatHelper *_helper;
}

@end


@implementation ORKTextChoiceAnswerFormat

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithStyle:(ORKChoiceAnswerStyle)style
                  textChoices:(NSArray<ORKTextChoice *> *)textChoices {
    self = [super init];
    if (self) {
        _style = style;
        _textChoices = ork_processTextChoices(textChoices);
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:self];
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
    return super.hash ^ _textChoices.hash ^ _style;
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

- (ORKQuestionType)questionType {
    return (_style == ORKChoiceAnswerStyleSingleChoice) ? ORKQuestionTypeSingleChoice : ORKQuestionTypeMultipleChoice;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

- (NSString *)stringForAnswer:(id)answer {
    return [_helper stringForChoiceAnswer:answer];
}

@end


#pragma mark - ORKTextChoice

@implementation ORKTextChoice {
    NSString *_text;
    id<NSCopying, NSCoding, NSObject> _value;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

+ (instancetype)choiceWithText:(NSString *)text detailText:(NSString *)detailText value:(id<NSCopying, NSCoding, NSObject>)value exclusive:(BOOL)exclusive {
    ORKTextChoice *option = [[ORKTextChoice alloc] initWithText:text detailText:detailText value:value exclusive:exclusive];
    return option;
}

+ (instancetype)choiceWithText:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value {
    return [ORKTextChoice choiceWithText:text detailText:nil value:value exclusive:NO];
}

- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText value:(id<NSCopying,NSCoding,NSObject>)value exclusive:(BOOL)exclusive {
    self = [super init];
    if (self) {
        _text = [text copy];
        _detailText = [detailText copy];
        _value = value;
        _exclusive = exclusive;
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
            && ORKEqualObjects(self.value, castObject.value)
            && self.exclusive == castObject.exclusive);
}

- (NSUInteger)hash {
    // Ignore the task reference - it's not part of the content of the step
    return _text.hash ^ _detailText.hash ^ _value.hash;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, detailText, NSString);
        ORK_DECODE_OBJ(aDecoder, value);
        ORK_DECODE_BOOL(aDecoder, exclusive);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, value);
    ORK_ENCODE_OBJ(aCoder, detailText);
    ORK_ENCODE_BOOL(aCoder, exclusive);
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

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
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
    return _text.hash ^ _value.hash;
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

- (instancetype)initWithYesString:(NSString *)yes noString:(NSString *)no {
    self = [super init];
    if (self) {
        _yes = [yes copy];
        _no = [no copy];
    }
    return self;
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeBoolean;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    if (!_yes.length) {
        _yes = ORKLocalizedString(@"BOOL_YES", nil);
    }
    if (!_no.length) {
        _no = ORKLocalizedString(@"BOOL_NO", nil);
    }
    
    return [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                            textChoices:@[[ORKTextChoice choiceWithText:_yes value:@(YES)],
                                                          [ORKTextChoice choiceWithText:_no value:@(NO)]]];
}

- (Class)questionResultClass {
    return [ORKBooleanQuestionResult class];
}

- (NSString *)stringForAnswer:(id)answer {
    return [self.impliedAnswerFormat stringForAnswer: @[answer]];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKBooleanAnswerFormat *answerFormat = [super copyWithZone:zone];
    answerFormat->_yes = [_yes copy];
    answerFormat->_no = [_no copy];
    return answerFormat;
}

- (NSUInteger)hash {
    return super.hash ^ _yes.hash ^ _no.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.yes, castObject.yes) &&
            ORKEqualObjects(self.no, castObject.no));
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, yes, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, no, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, yes);
    ORK_ENCODE_OBJ(aCoder, no);
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

- (ORKQuestionType)questionType {
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
    return super.hash & self.defaultComponents.hash;
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

- (NSString *)stringForAnswer:(id)answer {
    return ORKTimeOfDayStringFromComponents(answer);
}

@end


#pragma mark - ORKDateAnswerFormat

@implementation ORKDateAnswerFormat

- (Class)questionResultClass {
    return [ORKDateQuestionResult class];
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
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
    return ([super hash] & [self.defaultDate hash]) ^ _style;
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

- (ORKQuestionType)questionType {
    return (_style == ORKDateAnswerStyleDateAndTime) ? ORKQuestionTypeDateAndTime : ORKQuestionTypeDate;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)stringForAnswer:(id)answer {
    return [self stringFromDate:answer];
}

@end


#pragma mark - ORKNumericAnswerFormat

@implementation ORKNumericAnswerFormat

- (Class)questionResultClass {
    return [ORKNumericQuestionResult class];
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
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
    ORKNumericAnswerFormat *answerFormat = [[[self class] allocWithZone:zone] initWithStyle:_style
                                                                                       unit:[_unit copy]
                                                                                    minimum:[_minimum copy]
                                                                                    maximum:[_maximum copy]];
    return answerFormat;
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
    return [super hash] ^ ([self.unit hash] & _style);
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

- (ORKQuestionType)questionType {
    return _style == ORKNumericAnswerStyleDecimal ? ORKQuestionTypeDecimal : ORKQuestionTypeInteger;
    
}

- (BOOL)isAnswerValid:(id)answer {
    BOOL isValid = NO;
    if ([answer isKindOfClass:[NSNumber class]]) {
        return [self isAnswerValidWithNumber:(NSNumber *)answer];
    }
    return isValid;
}

- (BOOL)isAnswerValidWithNumber:(NSNumber *)number {
    BOOL isValid = NO;
    if (number) {
        isValid = YES;
        if (isnan(number.doubleValue)) {
            isValid = NO;
        } else if (self.minimum && (self.minimum.doubleValue > number.doubleValue)) {
            isValid = NO;
        } else if (self.maximum && (self.maximum.doubleValue < number.doubleValue)) {
            isValid = NO;
        }
    }
    return isValid;
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    BOOL isValid = NO;
    if (text.length > 0) {
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:text locale:[NSLocale currentLocale]];
        isValid = [self isAnswerValidWithNumber:number];
    }
    return isValid;
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    if (!text.length) {
        return nil;
    }
    NSDecimalNumber *num = [NSDecimalNumber decimalNumberWithString:text locale:[NSLocale currentLocale]];
    if (!num) {
        return nil;
    }
    NSString *string = nil;
    NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
    if (self.minimum && (self.minimum.doubleValue > num.doubleValue)) {
        string = [NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_BELOW_MAXIMUM", nil), text, [formatter stringFromNumber:self.minimum]];
    } else if (self.maximum && (self.maximum.doubleValue < num.doubleValue)) {
        string = [NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_ABOVE_MAXIMUM", nil), text, [formatter stringFromNumber:self.maximum]];
    } else {
        string = [NSString localizedStringWithFormat:ORKLocalizedString(@"RANGE_ALERT_MESSAGE_OTHER", nil), text];
    }
    return string;
}

- (NSString *)stringForAnswer:(id)answer {
    NSString *answerString = nil;
    if ([self isAnswerValid:answer]) {
        NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
        answerString = [formatter stringFromNumber:answer];
        if (self.unit && self.unit.length > 0) {
            answerString = [NSString stringWithFormat:@"%@ %@", answerString, self.unit];
        }
    }
    return answerString;
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

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
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
- (NSNumber *)defaultAnswer {
    if ( _defaultValue > _maximum || _defaultValue < _minimum) {
        return nil;
    }
    
    NSInteger integer = round( (double)( _defaultValue - _minimum ) / (double)_step ) * _step + _minimum;
    
    return @(integer);
}
- (NSString *)localizedStringForNumber:(NSNumber *)number {
    return [self.numberFormatter stringFromNumber:number];
}

- (NSArray<ORKTextChoice *> *)textChoices {
    return nil;
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.locale = [NSLocale autoupdatingCurrentLocale];
        _numberFormatter.maximumFractionDigits = 0;
    }
    return _numberFormatter;
}

- (NSInteger)numberOfSteps {
    return (_maximum - _minimum) / _step;
}

- (NSNumber *)normalizedValueForNumber:(NSNumber *)number {
    return @(number.integerValue);
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
    
    NSInteger steps = (_maximum - _minimum) / _step;
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
        ORK_DECODE_IMAGE(aDecoder, maximumImage);
        ORK_DECODE_IMAGE(aDecoder, minimumImage);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientColors, UIColor);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientLocations, NSNumber);
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
    ORK_ENCODE_IMAGE(aCoder, maximumImage);
    ORK_ENCODE_IMAGE(aCoder, minimumImage);
    ORK_ENCODE_OBJ(aCoder, gradientColors);
    ORK_ENCODE_OBJ(aCoder, gradientLocations);
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
            ORKEqualObjects(self.maximumValueDescription, castObject.maximumValueDescription) &&
            ORKEqualObjects(self.minimumValueDescription, castObject.minimumValueDescription) &&
            ORKEqualObjects(self.maximumImage, castObject.maximumImage) &&
            ORKEqualObjects(self.minimumImage, castObject.minimumImage) &&
            ORKEqualObjects(self.gradientColors, castObject.gradientColors) &&
            ORKEqualObjects(self.gradientLocations, castObject.gradientLocations));
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeScale;
}

- (NSString *)stringForAnswer:(id)answer {
    return [self localizedStringForNumber:answer];
}

@end


#pragma mark - ORKContinuousScaleAnswerFormat

@implementation ORKContinuousScaleAnswerFormat {
    NSNumberFormatter *_numberFormatter;
}

- (Class)questionResultClass {
    return [ORKScaleQuestionResult class];
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
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
- (NSNumber *)defaultAnswer {
    if ( _defaultValue > _maximum || _defaultValue < _minimum) {
        return nil;
    }
    return @(_defaultValue);
}
- (NSString *)localizedStringForNumber:(NSNumber *)number {
    return [self.numberFormatter stringFromNumber:number];
}

- (NSArray<ORKTextChoice *> *)textChoices {
    return nil;
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
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
        ORK_DECODE_IMAGE(aDecoder, maximumImage);
        ORK_DECODE_IMAGE(aDecoder, minimumImage);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientColors, UIColor);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientLocations, NSNumber);
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
    ORK_ENCODE_IMAGE(aCoder, maximumImage);
    ORK_ENCODE_IMAGE(aCoder, minimumImage);
    ORK_ENCODE_OBJ(aCoder, gradientColors);
    ORK_ENCODE_OBJ(aCoder, gradientLocations);
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
            ORKEqualObjects(self.maximumValueDescription, castObject.maximumValueDescription) &&
            ORKEqualObjects(self.minimumValueDescription, castObject.minimumValueDescription) &&
            ORKEqualObjects(self.maximumImage, castObject.maximumImage) &&
            ORKEqualObjects(self.minimumImage, castObject.minimumImage) &&
            ORKEqualObjects(self.gradientColors, castObject.gradientColors) &&
            ORKEqualObjects(self.gradientLocations, castObject.gradientLocations));
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeScale;
}

- (NSString *)stringForAnswer:(id)answer {
    return [self localizedStringForNumber:answer];
}

@end


#pragma mark - ORKTextScaleAnswerFormat

@interface ORKTextScaleAnswerFormat () {
    
    ORKChoiceAnswerFormatHelper *_helper;
}

@end


@implementation ORKTextScaleAnswerFormat {
    NSNumberFormatter *_numberFormatter;
}

- (Class)questionResultClass {
    return [ORKChoiceQuestionResult class];
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices
                       defaultIndex:(NSInteger)defaultIndex
                           vertical:(BOOL)vertical {
    self = [super init];
    if (self) {
        _textChoices = [textChoices copy];
        _defaultIndex = defaultIndex;
        _vertical = vertical;
        _helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:self];
        
        [self validateParameters];
    }
    return self;
}

- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices
                       defaultIndex:(NSInteger)defaultIndex{
    return [self initWithTextChoices:textChoices
                        defaultIndex:defaultIndex
                            vertical:NO];
}

- (NSNumber *)minimumNumber {
    return @(1);
}
- (NSNumber *)maximumNumber {
    return @(_textChoices.count);
}
- (id<NSObject, NSCopying, NSCoding>)defaultAnswer {
    if (_defaultIndex < 0 || _defaultIndex >= _textChoices.count) {
        return nil;
    }
    id<NSCopying, NSCoding, NSObject> value = [self textChoiceAtIndex:_defaultIndex].value;
    return value ? @[value] : nil;
}
- (NSString *)localizedStringForNumber:(NSNumber *)number {
    return [self.numberFormatter stringFromNumber:number];
}
- (NSString *)minimumValueDescription {
    return _textChoices.firstObject.text;
}
- (NSString *)maximumValueDescription {
    return _textChoices.lastObject.text;
}
- (UIImage *)minimumImage {
    return nil;
}
- (UIImage *)maximumImage {
    return nil;
}

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.locale = [NSLocale autoupdatingCurrentLocale];
        _numberFormatter.maximumFractionDigits = 0;
    }
    return _numberFormatter;
}

- (NSInteger)numberOfSteps {
    return _textChoices.count - 1;
}

- (NSNumber *)normalizedValueForNumber:(NSNumber *)number {
    return @([number integerValue]);
}

- (ORKTextChoice *)textChoiceAtIndex:(NSUInteger)index {
    
    if (index >= _textChoices.count) {
        return nil;
    }
    return _textChoices[index];
}

- (ORKTextChoice *)textChoiceForValue:(id<NSCopying, NSCoding, NSObject>)value {
    __block ORKTextChoice *choice = nil;
    
    [_textChoices enumerateObjectsUsingBlock:^(ORKTextChoice * _Nonnull textChoice, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([textChoice.value isEqual:value]) {
            choice = textChoice;
            *stop = YES;
        }
    }];
    
    return choice;
}

- (NSUInteger)textChoiceIndexForValue:(id<NSCopying, NSCoding, NSObject>)value {
    ORKTextChoice *choice = [self textChoiceForValue:value];
    return choice ? [_textChoices indexOfObject:choice] : NSNotFound;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (_textChoices.count < 2) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Must have a minimum of 2 text choices." userInfo:nil];
    } else if (_textChoices.count > 8) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot have more than 8 text choices." userInfo:nil];
    }
    
    ORKValidateArrayForObjectsOfClass(_textChoices, [ORKTextChoice class], @"Text choices must be of class ORKTextChoice.");
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, textChoices, ORKTextChoice);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientColors, UIColor);
        ORK_DECODE_OBJ_ARRAY(aDecoder, gradientLocations, NSNumber);
        ORK_DECODE_INTEGER(aDecoder, defaultIndex);
        ORK_DECODE_BOOL(aDecoder, vertical);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, textChoices);
    ORK_ENCODE_OBJ(aCoder, gradientColors);
    ORK_ENCODE_OBJ(aCoder, gradientLocations);
    ORK_ENCODE_INTEGER(aCoder, defaultIndex);
    ORK_ENCODE_BOOL(aCoder, vertical);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.textChoices, castObject.textChoices) &&
            (_defaultIndex == castObject.defaultIndex) &&
            (_vertical == castObject.vertical) &&
            ORKEqualObjects(self.gradientColors, castObject.gradientColors) &&
            ORKEqualObjects(self.gradientLocations, castObject.gradientLocations));
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeScale;
}

- (NSString *)stringForAnswer:(id)answer {
    return [_helper stringForChoiceAnswer:answer];
}

@end


#pragma mark - ORKTextAnswerFormat

@implementation ORKTextAnswerFormat

- (Class)questionResultClass {
    return [ORKTextQuestionResult class];
}

- (void)commonInit {
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _autocorrectionType = UITextAutocorrectionTypeDefault;
    _spellCheckingType = UITextSpellCheckingTypeDefault;
    _keyboardType = UIKeyboardTypeDefault;
    _multipleLines = YES;
}

- (instancetype)initWithMaximumLength:(NSInteger)maximumLength {
    self = [super init];
    if (self) {
        _maximumLength = maximumLength;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithValidationRegularExpression:(NSRegularExpression *)validationRegularExpression
                                     invalidMessage:(NSString *)invalidMessage {
    self = [super init];
    if (self) {
        _validationRegularExpression = [validationRegularExpression copy];
        _invalidMessage = [invalidMessage copy];
        _maximumLength = 0;
        [self commonInit];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithMaximumLength:0];
    return self;
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeText;
}

- (void)validateParameters {
    [super validateParameters];
    
    if ( (!self.validationRegularExpression && self.invalidMessage) ||
        (self.validationRegularExpression && !self.invalidMessage) ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Both regular expression and invalid message properties must be set."
                                     userInfo:nil];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTextAnswerFormat *answerFormat = [[[self class] allocWithZone:zone] init];
    answerFormat->_maximumLength = _maximumLength;
    answerFormat->_validationRegularExpression = [_validationRegularExpression copy];
    answerFormat->_invalidMessage = [_invalidMessage copy];
    answerFormat->_autocapitalizationType = _autocapitalizationType;
    answerFormat->_autocorrectionType = _autocorrectionType;
    answerFormat->_spellCheckingType = _spellCheckingType;
    answerFormat->_keyboardType = _keyboardType;
    answerFormat->_multipleLines = _multipleLines;
    answerFormat->_secureTextEntry = _secureTextEntry;
    return answerFormat;
}

- (BOOL)isAnswerValid:(id)answer {
    BOOL isValid = NO;
    if ([answer isKindOfClass:[NSString class]]) {
        isValid = [self isAnswerValidWithString:(NSString *)answer];
    }
    return isValid;
}

- (BOOL)isAnswerValidWithString:(NSString *)text {
    BOOL isValid = YES;
    if (text && text.length > 0) {
        isValid = ([self isTextLengthValidWithString:text] && [self isTextRegularExpressionValidWithString:text]);
    }
    return isValid;
}

- (BOOL)isTextLengthValidWithString:(NSString *)text {
    return (_maximumLength == 0 || text.length <= _maximumLength);
}

- (BOOL)isTextRegularExpressionValidWithString:(NSString *)text {
    BOOL isValid = YES;
    if (self.validationRegularExpression) {
        NSUInteger regularExpressionMatches = [_validationRegularExpression numberOfMatchesInString:text
                                                                                            options:(NSMatchingOptions)0
                                                                                              range:NSMakeRange(0, [text length])];
        isValid = (regularExpressionMatches != 0);
    }
    return isValid;
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    NSString *string = @"";
    if (![self isTextLengthValidWithString:text]) {
        string = [NSString localizedStringWithFormat:ORKLocalizedString(@"TEXT_ANSWER_EXCEEDING_MAX_LENGTH_ALERT_MESSAGE", nil), ORKLocalizedStringFromNumber(@(_maximumLength))];
    }
    if (![self isTextRegularExpressionValidWithString:text]) {
        if (string.length > 0) {
            string = [string stringByAppendingString:@"\n"];
        }
        string = [string stringByAppendingString:[NSString localizedStringWithFormat:ORKLocalizedString(_invalidMessage, nil), text]];
    }
    return string;
}


- (ORKAnswerFormat *)confirmationAnswerFormatWithOriginalItemIdentifier:(NSString *)originalItemIdentifier
                                                           errorMessage:(NSString *)errorMessage {
    
    NSAssert(!self.multipleLines, @"Confirmation Answer Format is not currently defined for ORKTextAnswerFormat with multiple lines.");
    
    ORKTextAnswerFormat *answerFormat = [[ORKConfirmTextAnswerFormat alloc] initWithOriginalItemIdentifier:originalItemIdentifier errorMessage:errorMessage];
    
    // Copy from ORKTextAnswerFormat being confirmed
    answerFormat->_maximumLength = _maximumLength;
    answerFormat->_keyboardType = _keyboardType;
    answerFormat->_multipleLines = _multipleLines;
    answerFormat->_secureTextEntry = _secureTextEntry;
    answerFormat->_autocapitalizationType = _autocapitalizationType;
    
    // Always set to no autocorrection or spell checking
    answerFormat->_autocorrectionType = UITextAutocorrectionTypeNo;
    answerFormat->_spellCheckingType = UITextSpellCheckingTypeNo;
    
    return answerFormat;
}

#pragma mark NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _multipleLines = YES;
        ORK_DECODE_INTEGER(aDecoder, maximumLength);
        ORK_DECODE_OBJ_CLASS(aDecoder, validationRegularExpression, NSRegularExpression);
        ORK_DECODE_OBJ_CLASS(aDecoder, invalidMessage, NSString);
        ORK_DECODE_ENUM(aDecoder, autocapitalizationType);
        ORK_DECODE_ENUM(aDecoder, autocorrectionType);
        ORK_DECODE_ENUM(aDecoder, spellCheckingType);
        ORK_DECODE_ENUM(aDecoder, keyboardType);
        ORK_DECODE_BOOL(aDecoder, multipleLines);
        ORK_DECODE_BOOL(aDecoder, secureTextEntry);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, maximumLength);
    ORK_ENCODE_OBJ(aCoder, validationRegularExpression);
    ORK_ENCODE_OBJ(aCoder, invalidMessage);
    ORK_ENCODE_ENUM(aCoder, autocapitalizationType);
    ORK_ENCODE_ENUM(aCoder, autocorrectionType);
    ORK_ENCODE_ENUM(aCoder, spellCheckingType);
    ORK_ENCODE_ENUM(aCoder, keyboardType);
    ORK_ENCODE_BOOL(aCoder, multipleLines);
    ORK_ENCODE_BOOL(aCoder, secureTextEntry);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.maximumLength == castObject.maximumLength &&
             ORKEqualObjects(self.validationRegularExpression, castObject.validationRegularExpression) &&
             ORKEqualObjects(self.invalidMessage, castObject.invalidMessage) &&
             self.autocapitalizationType == castObject.autocapitalizationType &&
             self.autocorrectionType == castObject.autocorrectionType &&
             self.spellCheckingType == castObject.spellCheckingType &&
             self.keyboardType == castObject.keyboardType &&
             self.multipleLines == castObject.multipleLines) &&
            self.secureTextEntry == castObject.secureTextEntry);
}

static NSString *const kSecureTextEntryEscapeString = @"*";

- (NSString *)stringForAnswer:(id)answer {
    NSString *answerString = nil;
    if ([self isAnswerValid:answer]) {
        answerString = _secureTextEntry ? [@"" stringByPaddingToLength:((NSString *)answer).length withString:kSecureTextEntryEscapeString startingAtIndex:0] : answer;
    }
    return answerString;
}

@end


#pragma mark - ORKEmailAnswerFormat

@implementation ORKEmailAnswerFormat {
    ORKTextAnswerFormat *_impliedAnswerFormat;
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeText;
}

- (Class)questionResultClass {
    return [ORKTextQuestionResult class];
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    if (!_impliedAnswerFormat) {
        NSRegularExpression *validationRegularExpression =
        [NSRegularExpression regularExpressionWithPattern:EmailValidationRegularExpressionPattern
                                                  options:(NSRegularExpressionOptions)0
                                                    error:nil];
        NSString *invalidMessage = ORKLocalizedString(@"INVALID_EMAIL_ALERT_MESSAGE", nil);
        _impliedAnswerFormat = [ORKTextAnswerFormat textAnswerFormatWithValidationRegularExpression:validationRegularExpression
                                                                                     invalidMessage:invalidMessage];
        _impliedAnswerFormat.keyboardType = UIKeyboardTypeEmailAddress;
        _impliedAnswerFormat.multipleLines = NO;
        _impliedAnswerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        _impliedAnswerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _impliedAnswerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _impliedAnswerFormat;
}

- (NSString *)stringForAnswer:(id)answer {
    return [self.impliedAnswerFormat stringForAnswer:answer];
}

@end


#pragma mark - ORKConfirmTextAnswerFormat

@implementation ORKConfirmTextAnswerFormat

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

// Don't throw on -init nor -initWithMaximumLength: because they're internally used by -copyWithZone:

- (instancetype)initWithValidationRegularExpression:(NSRegularExpression *)validationRegularExpression
                                     invalidMessage:(NSString *)invalidMessage {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithOriginalItemIdentifier:(NSString *)originalItemIdentifier
                                  errorMessage:(NSString *)errorMessage {
    
    NSParameterAssert(originalItemIdentifier);
    NSParameterAssert(errorMessage);
    
    self = [super init];
    if (self) {
        _originalItemIdentifier = [originalItemIdentifier copy];
        _errorMessage = [errorMessage copy];
    }
    return self;
}

- (BOOL)isAnswerValid:(id)answer {
    BOOL isValid = NO;
    if ([answer isKindOfClass:[NSString class]]) {
        NSString *stringAnswer = (NSString *)answer;
        isValid = (stringAnswer.length > 0);
    }
    return isValid;
}

- (NSString *)localizedInvalidValueStringWithAnswerString:(NSString *)text {
    return self.errorMessage;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKConfirmTextAnswerFormat *answerFormat = [super copyWithZone:zone];
    answerFormat->_originalItemIdentifier = [_originalItemIdentifier copy];
    answerFormat->_errorMessage = [_errorMessage copy];
    return answerFormat;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, originalItemIdentifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, errorMessage, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, originalItemIdentifier);
    ORK_ENCODE_OBJ(aCoder, errorMessage);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.originalItemIdentifier, castObject.originalItemIdentifier) &&
            ORKEqualObjects(self.errorMessage, castObject.errorMessage));
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

- (ORKQuestionType)questionType {
    return ORKQuestionTypeTimeInterval;
}

- (NSTimeInterval)pickerDefaultDuration {
    
    NSTimeInterval value = MAX([self defaultInterval], 0);
    
    // imitate UIDatePicker's behavior
    NSTimeInterval stepInSeconds = _step * 60;
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

- (NSString *)stringForAnswer:(id)answer {
    return [ORKTimeIntervalLabelFormatter() stringFromTimeInterval:((NSNumber *)answer).floatValue];
}

@end


#pragma mark - ORKHeightAnswerFormat

@implementation ORKHeightAnswerFormat

- (Class)questionResultClass {
    return [ORKNumericQuestionResult class];
}

- (NSString *)canonicalUnitString {
    return @"cm";
}

- (ORKNumericQuestionResult *)resultWithIdentifier:(NSString *)identifier answer:(NSNumber *)answer {
    ORKNumericQuestionResult *questionResult = (ORKNumericQuestionResult *)[super resultWithIdentifier:identifier answer:answer];
    // Use canonical unit because we expect results to be consistent regardless of the user locale
    questionResult.unit = [self canonicalUnitString];
    return questionResult;
}

- (instancetype)init {
    self = [self initWithMeasurementSystem:ORKMeasurementSystemLocal];
    return self;
}

- (instancetype)initWithMeasurementSystem:(ORKMeasurementSystem)measurementSystem {
    self = [super init];
    if (self) {
        _measurementSystem = measurementSystem;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (self.measurementSystem == castObject.measurementSystem));
}

- (NSUInteger)hash {
    return super.hash ^ _measurementSystem;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_ENUM(aDecoder, measurementSystem);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_ENUM(aCoder, measurementSystem);
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeHeight;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)useMetricSystem {
    return _measurementSystem == ORKMeasurementSystemMetric
    || (_measurementSystem == ORKMeasurementSystemLocal && ((NSNumber *)[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem]).boolValue);
}

- (NSString *)stringForAnswer:(id)answer {
    NSString *answerString = nil;
    
    if (!ORKIsAnswerEmpty(answer)) {
        NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
        if (self.useMetricSystem) {
            answerString = [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:answer], ORKLocalizedString(@"MEASURING_UNIT_CM", nil)];
        } else {
            double feet, inches;
            ORKCentimetersToFeetAndInches(((NSNumber *)answer).doubleValue, &feet, &inches);
            NSString *feetString = [formatter stringFromNumber:@(feet)];
            NSString *inchesString = [formatter stringFromNumber:@(inches)];
            answerString = [NSString stringWithFormat:@"%@ %@, %@ %@",
                            feetString, ORKLocalizedString(@"MEASURING_UNIT_FT", nil), inchesString, ORKLocalizedString(@"MEASURING_UNIT_IN", nil)];
        }
    }
    return answerString;
}

@end


#pragma mark - ORKLocationAnswerFormat

@implementation ORKLocationAnswerFormat

- (instancetype)init {
    self = [super init];
    if (self) {
        _useCurrentLocation = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_BOOL(aDecoder, useCurrentLocation);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_BOOL(aCoder, useCurrentLocation);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (ORKQuestionType)questionType {
    return ORKQuestionTypeLocation;
}

- (Class)questionResultClass {
    return [ORKLocationQuestionResult class];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKLocationAnswerFormat *locationAnswerFormat = [[[self class] allocWithZone:zone] init];
    locationAnswerFormat->_useCurrentLocation = _useCurrentLocation;
    return locationAnswerFormat;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            _useCurrentLocation == castObject.useCurrentLocation);
}

static NSString *const formattedAddressLinesKey = @"FormattedAddressLines";

- (NSString *)stringForAnswer:(id)answer {
    NSString *answerString = nil;
    if ([answer isKindOfClass:[ORKLocation class]]) {
        ORKLocation *location = answer;
        // access address dictionary directly since 'ABCreateStringWithAddressDictionary:' is deprecated in iOS9
        NSArray<NSString *> *addressLines = [location.addressDictionary valueForKey:formattedAddressLinesKey];
        answerString = addressLines ? [addressLines componentsJoinedByString:@"\n"] :
        MKStringFromMapPoint(MKMapPointForCoordinate(location.coordinate));
    }
    return answerString;
}

@end
