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


@import HealthKit;
#import <ResearchKit/ORKAnswerFormat.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * ORKBiologicalSexIdentifier NS_STRING_ENUM;

ORK_EXTERN ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierFemale;
ORK_EXTERN ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierMale;
ORK_EXTERN ORKBiologicalSexIdentifier const ORKBiologicalSexIdentifierOther;

typedef NSString * ORKBloodTypeIdentifier NS_STRING_ENUM;

ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierAPositive;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierANegative;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBPositive;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierBNegative;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABPositive;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierABNegative;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierOPositive;
ORK_EXTERN ORKBloodTypeIdentifier const ORKBloodTypeIdentifierONegative;


/**
 The `ORKHealthKitCharacteristicTypeAnswerFormat` class represents an answer format that lets participants enter values that correspond to a HealthKit characteristic type.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value displayed in the UI is the most recent value received from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization is requested unless the property
 `shouldRequestAuthorization` is set to `NO`.
 
 You can use the HealthKit characteristic answer format to let users autofill information, such as their blood type or date of birth.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitCharacteristicTypeAnswerFormat : ORKAnswerFormat

/**
 Returns a new answer format for the specified HealthKit characteristic type.
 
 @param characteristicType   The characteristic type to collect.
 
 @return A new HealthKit characteristic type answer format instance.
 */
+ (instancetype)answerFormatWithCharacteristicType:(HKCharacteristicType *)characteristicType;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized HealthKit characteristic type answer format using the specified characteristic type.
 
 This method is the designated initializer.
 
 @param characteristicType   The characteristic type to collect.
 
 @return An initialized HealthKit characteristic type answer format.
 */
- (instancetype)initWithCharacteristicType:(HKCharacteristicType *)characteristicType NS_DESIGNATED_INITIALIZER;

/**
 Should authorization be requested for the associated HealthKit data type. Default = `YES`.
 */
@property (nonatomic) BOOL shouldRequestAuthorization;

/**
 The HealthKit characteristic type to be collected by this answer format. (read-only)
 */
@property (nonatomic, copy, readonly) HKCharacteristicType *characteristicType;

/**
 The default date shown by the date picker.
 
 Only used for the `HKCharacteristicTypeIdentifierDateOfBirth` characteristic type. The date is
 displayed in the user's time zone. If you set this property to `nil`, the date picker will default
 to the date representing 35 years before the current date.
 */
@property (nonatomic, strong, nullable) NSDate *defaultDate;

/**
 The minimum date that is allowed by the date picker.
 
 Only used for the `HKCharacteristicTypeIdentifierDateOfBirth` characteristic type. If you set this
 property to `nil`, the date picker will use the date representing 150 years before the curent date
 as its minimum date.
 */
@property (nonatomic, strong, nullable) NSDate *minimumDate;

/**
 The maximum date that is allowed by the date picker.
 
 Only used for the `HKCharacteristicTypeIdentifierDateOfBirth` characteristic type. If you set this
 property to `nil`, the date picker will use the date representing 1 day after curent date as its
 maximum date
 */

@property (nonatomic, strong, nullable) NSDate *maximumDate;

/**
 The calendar used by the date picker.
 
 Only used for the `HKCharacteristicTypeIdentifierDateOfBirth` characteristic type. If you set this
 property to `nil`, the date picker will use the default calendar for the current locale.
 */
@property (nonatomic, strong, nullable) NSCalendar *calendar;

@end


/**
 The `ORKHealthKitQuantityTypeAnswerFormat` class represents an answer format that lets participants enter values that correspond to a HealthKit quantity type, such as systolic blood pressure.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value in the UI is the most recent value received from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization is requested unless the property
 `shouldRequestAuthorization` is set to `NO`.
 
 You can use the HealthKit quantity type answer format to let users autofill values such as their weight with the most
 recent data from HealthKit.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthKitQuantityTypeAnswerFormat : ORKAnswerFormat


/**
 Returns a new HealthKit quantity answer format with the specified quantity type.
 
 @param quantityType    The HealthKit quantity type to collect.
 @param unit            The unit used to describe the quantity. If the value of this parameter is `nil`, the default HealthKit unit is used, when available.
 @param style           The numeric answer style to use when collecting this value.
 
 @return A HealthKit quantity answer format instance.
 */
+ (instancetype)answerFormatWithQuantityType:(HKQuantityType *)quantityType unit:(nullable HKUnit *)unit style:(ORKNumericAnswerStyle)style;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized HealthKit quantity answer format using the specified quantity type, unit, and numeric answer style.
 
 This method is the designated initializer.
 
 @param quantityType    The HealthKit quantity type to collect.
 @param unit            The unit used to describe the quantity. If the value of this parameter is `nil`, the default HealthKit unit is used, when available.
 @param style           The numeric answer style to use when collecting this value.
 
 @return An initialized HealthKit quantity answer format.
 */
- (instancetype)initWithQuantityType:(HKQuantityType *)quantityType unit:(nullable HKUnit *)unit style:(ORKNumericAnswerStyle)style NS_DESIGNATED_INITIALIZER;

/**
 Should authorization be requested for the associated HealthKit data type. Default = `YES`.
 */
@property (nonatomic) BOOL shouldRequestAuthorization;

/**
 The HealthKit quantity type to collect. (read-only)
 */
@property (nonatomic, copy, readonly) HKQuantityType *quantityType;

/**
 The HealthKit unit in which to collect the answer. (read-only)
 
 The unit is displayed when the user is entering data, and is also
included in the question result generated by form items or question steps
 that use this answer format.
 */
@property (nonatomic, strong, readonly, nullable) HKUnit *unit;

/**
 The numeric answer style. (read-only)
 */
@property (nonatomic, readonly) ORKNumericAnswerStyle numericAnswerStyle;

@end

@interface HKUnit (ORKLocalized)

/**
 Returns the localized string for the unit (if available)
 */
- (NSString *)localizedUnitString;

@end

NS_ASSUME_NONNULL_END

