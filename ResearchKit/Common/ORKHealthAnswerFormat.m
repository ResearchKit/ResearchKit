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


#import "ORKHealthAnswerFormat.h"

#import "ORKAnswerFormat_Internal.h"

#import "ORKHelpers_Internal.h"

#import "ORKResult.h"


#pragma mark - ORKHealthAnswerFormat

ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierFemale = @"HKBiologicalSexFemale";
ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierMale = @"HKBiologicalSexMale";
ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierOther = @"HKBiologicalSexOther";

NSString *ORKHKBiologicalSexString(HKBiologicalSex biologicalSex) {
    NSString *string = nil;
    switch (biologicalSex) {
        case HKBiologicalSexFemale: string = ORKBiologicalSexIdentifierFemale; break;
        case HKBiologicalSexMale:   string = ORKBiologicalSexIdentifierMale;   break;
        case HKBiologicalSexOther:  string = ORKBiologicalSexIdentifierOther;  break;
        case HKBiologicalSexNotSet: break;
    }
    return string;
}

ORKBloodTypeIdentifier const ORKBloodTypeIdentifierAPositive = @"HKBloodTypeAPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierANegative = @"HKBloodTypeANegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBPositive = @"HKBloodTypeBPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBNegative = @"HKBloodTypeBNegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABPositive = @"HKBloodTypeABPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABNegative = @"HKBloodTypeABNegative";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierOPositive = @"HKBloodTypeOPositive";
ORKBloodTypeIdentifier const ORKBloodTypeIdentifierONegative = @"HKBloodTypeONegative";

NSString *ORKHKBloodTypeString(HKBloodType bloodType) {
    NSString *string = nil;
    switch (bloodType) {
        case HKBloodTypeAPositive:  string = ORKBloodTypeIdentifierAPositive;   break;
        case HKBloodTypeANegative:  string = ORKBloodTypeIdentifierANegative;   break;
        case HKBloodTypeBPositive:  string = ORKBloodTypeIdentifierBPositive;   break;
        case HKBloodTypeBNegative:  string = ORKBloodTypeIdentifierBNegative;   break;
        case HKBloodTypeABPositive: string = ORKBloodTypeIdentifierABPositive;  break;
        case HKBloodTypeABNegative: string = ORKBloodTypeIdentifierABNegative;  break;
        case HKBloodTypeOPositive:  string = ORKBloodTypeIdentifierOPositive;   break;
        case HKBloodTypeONegative:  string = ORKBloodTypeIdentifierONegative;   break;
        case HKBloodTypeNotSet: break;
    }
    return string;
}

@interface ORKHealthKitCharacteristicTypeAnswerFormat ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


@implementation ORKHealthKitCharacteristicTypeAnswerFormat {
    ORKAnswerFormat *_impliedAnswerFormat;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (BOOL)isHealthKitAnswerFormat {
    return YES;
}

- (ORKQuestionType)questionType {
    return [[self impliedAnswerFormat] questionType];
}

- (HKObjectType *)healthKitObjectType {
    return _characteristicType;
}

- (HKObjectType *)healthKitObjectTypeForAuthorization {
    if (self.shouldRequestAuthorization) {
        return [self healthKitObjectType];
    }
    else {
        return nil;
    }
}

- (Class)questionResultClass {
    return [[self impliedAnswerFormat] questionResultClass];
}

+ (instancetype)answerFormatWithCharacteristicType:(HKCharacteristicType *)characteristicType {
    ORKHealthKitCharacteristicTypeAnswerFormat *format = [[ORKHealthKitCharacteristicTypeAnswerFormat alloc] initWithCharacteristicType:characteristicType];
    return format;
}

- (instancetype)initWithCharacteristicType:(HKCharacteristicType *)characteristicType {
    self = [super init];
    if (self) {
        // Characteristic types are immutable, so this should be equivalent to -copy
        _characteristicType = characteristicType;
        _shouldRequestAuthorization = YES;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.characteristicType, castObject.characteristicType) &&
            ORKEqualObjects(self.defaultDate, castObject.defaultDate) &&
            ORKEqualObjects(self.minimumDate, castObject.minimumDate) &&
            ORKEqualObjects(self.maximumDate, castObject.maximumDate) &&
            ORKEqualObjects(self.calendar, castObject.calendar));
}

- (NSUInteger)hash {
    return super.hash ^ self.characteristicType.hash ^ self.defaultDate.hash ^ self.minimumDate.hash ^ self.maximumDate.hash ^ self.calendar.hash;
}

// The bare answer format implied by the quantityType or characteristicType.
// This may be ORKTextChoiceAnswerFormat, ORKNumericAnswerFormat, or ORKDateAnswerFormat.
- (ORKAnswerFormat *)impliedAnswerFormat {
    if (_impliedAnswerFormat) {
        return _impliedAnswerFormat;
    }
    
    if (_characteristicType) {
        NSString *identifier = [_characteristicType identifier];
        if ([identifier isEqualToString:HKCharacteristicTypeIdentifierBiologicalSex]) {
            NSArray *options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_FEMALE", nil) value: ORKHKBiologicalSexString(HKBiologicalSexFemale)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_MALE", nil) value:ORKHKBiologicalSexString(HKBiologicalSexMale)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_OTHER", nil) value:ORKHKBiologicalSexString(HKBiologicalSexOther)]
                                 ];
            ORKTextChoiceAnswerFormat *format = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:options];
            _impliedAnswerFormat = format;
            
        } else if ([identifier isEqualToString:HKCharacteristicTypeIdentifierBloodType]) {
            NSArray *options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_A+", nil) value:ORKHKBloodTypeString(HKBloodTypeAPositive)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_A-", nil) value:ORKHKBloodTypeString(HKBloodTypeANegative)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_B+", nil) value:ORKHKBloodTypeString(HKBloodTypeBPositive)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_B-", nil) value:ORKHKBloodTypeString(HKBloodTypeBNegative)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_AB+", nil) value:ORKHKBloodTypeString(HKBloodTypeABPositive)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_AB-", nil) value:ORKHKBloodTypeString(HKBloodTypeABNegative)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_O+", nil) value:ORKHKBloodTypeString(HKBloodTypeOPositive)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_O-", nil) value:ORKHKBloodTypeString(HKBloodTypeONegative)]
                                 ];
            ORKValuePickerAnswerFormat *format = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:options];
            _impliedAnswerFormat = format;
            
        } else if ([identifier isEqualToString:HKCharacteristicTypeIdentifierDateOfBirth]) {
            NSCalendar *calendar = _calendar ? : [NSCalendar currentCalendar];
            NSDate *now = [NSDate date];
            NSDate *defaultDate = _defaultDate ? : [calendar dateByAddingUnit:NSCalendarUnitYear value:-35 toDate:now options:0];
            NSDate *minimumDate = _minimumDate ? : [calendar dateByAddingUnit:NSCalendarUnitYear value:-150 toDate:now options:0];
            NSDate *maximumDate = _maximumDate ? : [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:now options:0];
            
            ORKDateAnswerFormat *format = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                   minimumDate:minimumDate
                                                                                   maximumDate:maximumDate
                                                                                      calendar:calendar];
            _impliedAnswerFormat = format;
        } else if ([identifier isEqualToString:HKCharacteristicTypeIdentifierFitzpatrickSkinType]) {
            NSArray *options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_I", nil) value:@(HKFitzpatrickSkinTypeI)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_II", nil) value:@(HKFitzpatrickSkinTypeII)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_III", nil) value:@(HKFitzpatrickSkinTypeIII)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_IV", nil) value:@(HKFitzpatrickSkinTypeIV)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_V", nil) value:@(HKFitzpatrickSkinTypeV)],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_VI", nil) value:@(HKFitzpatrickSkinTypeVI)],
                                 ];
            ORKValuePickerAnswerFormat *format = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:options];
            _impliedAnswerFormat = format;
        } else if (ORK_IOS_10_WATCHOS_3_AVAILABLE && [identifier isEqualToString:HKCharacteristicTypeIdentifierWheelchairUse]) {
            ORKBooleanAnswerFormat *boolAnswerFormat = [ORKAnswerFormat booleanAnswerFormat];
            _impliedAnswerFormat = boolAnswerFormat.impliedAnswerFormat;
        }
    }
    return _impliedAnswerFormat;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, characteristicType, HKCharacteristicType);
        ORK_DECODE_OBJ_CLASS(aDecoder, defaultDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, minimumDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, maximumDate, NSDate);
        ORK_DECODE_OBJ_CLASS(aDecoder, calendar, NSCalendar);
        ORK_DECODE_BOOL(aDecoder, shouldRequestAuthorization);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, characteristicType);
    ORK_ENCODE_OBJ(aCoder, defaultDate);
    ORK_ENCODE_OBJ(aCoder, minimumDate);
    ORK_ENCODE_OBJ(aCoder, maximumDate);
    ORK_ENCODE_OBJ(aCoder, calendar);
    ORK_ENCODE_BOOL(aCoder, shouldRequestAuthorization);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end


@interface ORKHealthKitQuantityTypeAnswerFormat ()

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


@implementation ORKHealthKitQuantityTypeAnswerFormat {
    ORKAnswerFormat *_impliedAnswerFormat;
    HKUnit *_userUnit;
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (BOOL)isHealthKitAnswerFormat {
    return YES;
}

- (HKObjectType *)healthKitObjectType {
    return _quantityType;
}

- (HKObjectType *)healthKitObjectTypeForAuthorization {
    if (self.shouldRequestAuthorization) {
        return [self healthKitObjectType];
    }
    else {
        return nil;
    }
}

- (ORKQuestionType)questionType {
    return [[self impliedAnswerFormat] questionType];
}

- (Class)questionResultClass {
    return [[self impliedAnswerFormat] questionResultClass];
}

+ (instancetype)answerFormatWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit style:(ORKNumericAnswerStyle)style {
    ORKHealthKitQuantityTypeAnswerFormat *format = [[ORKHealthKitQuantityTypeAnswerFormat alloc] initWithQuantityType:quantityType unit:unit style:style];
    return format;
}

- (instancetype)initWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit style:(ORKNumericAnswerStyle)style {
    self = [super init];
    if (self) {
        // Quantity type and unit are immutable, so this should be equivalent to -copy
        _quantityType = quantityType;
        _unit = unit;
        _numericAnswerStyle = style;
        _shouldRequestAuthorization = YES;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.quantityType, castObject.quantityType) &&
            ORKEqualObjects(self.unit, castObject.unit) &&
            (_numericAnswerStyle == castObject.numericAnswerStyle));
}

- (NSUInteger)hash {
    return super.hash ^ self.quantityType.hash ^ self.unit.hash ^ _numericAnswerStyle;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    if (_impliedAnswerFormat) {
        return _impliedAnswerFormat;
    }
    
    if (_quantityType) {
        if ([_quantityType.identifier isEqualToString:HKQuantityTypeIdentifierHeight]) {
            ORKHeightAnswerFormat *format = [ORKDateAnswerFormat heightAnswerFormat];
            _impliedAnswerFormat = format;
        } else {
        ORKNumericAnswerFormat *format = nil;
            HKUnit *unit = [self healthKitUserUnit];
        if (_numericAnswerStyle == ORKNumericAnswerStyleDecimal) {
            format = [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:[unit localizedUnitString]];
        } else {
            format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:[unit localizedUnitString]];
            }
            _impliedAnswerFormat = format;
        }
    }
    return _impliedAnswerFormat;
}

- (HKUnit *)healthKitUnit {
    return _unit;
}

- (HKUnit *)healthKitUserUnit {
    return _unit ? : _userUnit;
}

- (void)setHealthKitUserUnit:(HKUnit *)unit {
    if (_unit == nil && _userUnit != unit) {
        _userUnit = unit;
     
        // Clear the implied answer format
        _impliedAnswerFormat = nil;
    }
}

- (id)resultWithIdentifier:(NSString *)identifier answer:(id)answer {
    id result = [super resultWithIdentifier:identifier answer:answer];
    if ([result isKindOfClass:[ORKNumericQuestionResult class]]) {
        ORKNumericQuestionResult *questionResult = (ORKNumericQuestionResult *)result;
        if (questionResult.unit == nil) {
            // The unit should *not* be localized.
            questionResult.unit = [self healthKitUserUnit].unitString;
        }
    }
    return result;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, quantityType, HKQuantityType);
        ORK_DECODE_OBJ_CLASS(aDecoder, unit, HKUnit);
        ORK_DECODE_ENUM(aDecoder, numericAnswerStyle);
        ORK_DECODE_BOOL(aDecoder, shouldRequestAuthorization);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, quantityType);
    ORK_ENCODE_ENUM(aCoder, numericAnswerStyle);
    ORK_ENCODE_OBJ(aCoder, unit);
    ORK_ENCODE_BOOL(aCoder, shouldRequestAuthorization);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end

@implementation HKUnit (ORKLocalized)

- (NSString *)localizedUnitString {
    NSUnit *unit = [[NSUnit alloc] initWithSymbol:self.unitString];
    if (unit != nil) {
        NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
        formatter.unitOptions = NSMeasurementFormatterUnitOptionsProvidedUnit;
        return [formatter stringFromUnit:unit];
    }
    return self.unitString;
}

@end
