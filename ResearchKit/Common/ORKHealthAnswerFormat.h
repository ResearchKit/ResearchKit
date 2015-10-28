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


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKAnswerFormat.h>
#import <HealthKit/HealthKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKHealthKitCharacteristicTypeAnswerFormat` class represents an answer format that lets participants enter values that correspond to a HealthKit characteristic type.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value displayed in the UI is the most recent value received from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization is requested.
 
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

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized HealthKit characteristic type answer format using the specified characteristic type.
 
 This method is the designated initializer.
 
 @param characteristicType   The characteristic type to collect.
 
 @return An initialized HealthKit characteristic type answer format.
 */
- (instancetype)initWithCharacteristicType:(HKCharacteristicType *)characteristicType NS_DESIGNATED_INITIALIZER;

/**
 The HealthKit characteristic type to be collected by this answer format. (read-only)
 */
@property (nonatomic, copy, readonly) HKCharacteristicType *characteristicType;

@end


/**
 The `ORKHealthKitQuantityTypeAnswerFormat` class represents an answer format that lets participants enter values that correspond to a HealthKit quantity type, such as systolic blood pressure.
 
 The actual UI used for collecting data with this answer format depends on the HealthKit type being collected.
 The default value in the UI is the most recent value received from HealthKit, if such a value exists.
 When a step or item is presented using this answer format, authorization is requested.
 
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

NS_ASSUME_NONNULL_END

