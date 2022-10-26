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
#import "ORKAnswerFormat_Private.h"
#import "ORKChoiceAnswerFormatHelper.h"

NS_ASSUME_NONNULL_BEGIN

BOOL ORKIsAnswerEmpty(_Nullable id answer);

#if TARGET_OS_IOS
NSString *ORKHKBiologicalSexString(HKBiologicalSex biologicalSex);
NSString *ORKHKBloodTypeString(HKBloodType bloodType);
#endif
NSString *ORKQuestionTypeString(ORKQuestionType questionType);

// Need to mark these as designated initializers to avoid warnings once we designate the others.
#define ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(C) \
@interface C () \
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER; \
@end

ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKAnswerFormat)
#if TARGET_OS_IOS
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKImageChoiceAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKValuePickerAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKMultipleValuePickerAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKImageChoice)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeOfDayAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKDateAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeOfDayAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKNumericAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKScaleAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKContinuousScaleAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextScaleAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTimeIntervalAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKHeightAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKWeightAnswerFormat)
#endif
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextChoiceAnswerFormat)
ORK_DESIGNATE_CODING_AND_SERIALIZATION_INITIALIZERS(ORKTextChoice)


@class ORKQuestionResult;

@interface ORKAnswerFormat ()

- (instancetype)init NS_DESIGNATED_INITIALIZER;

#if TARGET_OS_IOS
- (BOOL)isHealthKitAnswerFormat;

- (nullable HKObjectType *)healthKitObjectType;
- (nullable HKObjectType *)healthKitObjectTypeForAuthorization;

@property (nonatomic, strong, readonly, nullable) HKUnit *healthKitUnit;

@property (nonatomic, strong, nullable) HKUnit *healthKitUserUnit;
#endif

- (nullable NSString *)localizedInvalidValueStringWithAnswerString:(nullable NSString *)text;

- (nullable NSString *)stringForAnswer:(id)answer;

@end


#if TARGET_OS_IOS
@interface ORKNumericAnswerFormat ()

- (nullable NSString *)sanitizedTextFieldText:(nullable NSString *)text decimalSeparator:(nullable NSString *)separator;

@end
#endif


/**
 The `ORKAnswerOption` protocol defines brief option text for a option which can be included within `ORK*ChoiceAnswerFormat`.
 */
@protocol ORKAnswerOption <NSObject>

/**
 Brief option text.
 */
- (NSString *)text;

/**
 The value to be returned if this option is selected.

 Expected to be a`NSNumber`, `NSString` or `NSDate` (a JSON-serializable value).
 If no value is provided, the index of the option in the `ORK*ChoiceAnswerFormat` options list will be used.
 */
- (nullable NSObject<NSCopying, NSSecureCoding> *)value;

@end

#if TARGET_OS_IOS
@protocol ORKScaleAnswerFormatProvider <NSObject>

- (nullable NSNumber *)minimumNumber;
- (nullable NSNumber *)maximumNumber;
- (nullable id)defaultAnswer;
- (nullable NSString *)localizedStringForNumber:(nullable NSNumber *)number;
- (NSInteger)numberOfSteps;
- (nullable NSNumber *)normalizedValueForNumber:(nullable NSNumber *)number;
- (BOOL)isVertical;
- (BOOL)shouldHideSelectedValueLabel;
- (BOOL)shouldHideRanges;
- (BOOL)shouldHideLabels;
- (BOOL)shouldHideValueMarkers;
- (BOOL)shouldShowDontKnowButton;
- (NSString *)maximumValueDescription;
- (NSString *)minimumValueDescription;
- (nullable NSString *)customDontKnowButtonText;
- (nullable UIImage *)maximumImage;
- (nullable UIImage *)minimumImage;
- (nullable NSArray<UIColor *> *)gradientColors;
- (nullable NSArray<NSNumber *> *)gradientLocations;

@end


@protocol ORKTextScaleAnswerFormatProvider <ORKScaleAnswerFormatProvider>

- (NSArray<ORKTextChoice *> *)textChoices;
- (nullable ORKTextChoice *)textChoiceAtIndex:(NSUInteger)index;
- (NSUInteger)textChoiceIndexForValue:(NSObject<NSCopying, NSSecureCoding> *)value;

@end

@protocol ORKConfirmAnswerFormatProvider <NSObject>

- (ORKAnswerFormat *)confirmationAnswerFormatWithOriginalItemIdentifier:(NSString *)originalItemIdentifier
                                                           errorMessage:(NSString *)errorMessage;

@end


@interface ORKScaleAnswerFormat () <ORKScaleAnswerFormatProvider>

@end


@interface ORKContinuousScaleAnswerFormat () <ORKScaleAnswerFormatProvider>

@end


@interface ORKTextScaleAnswerFormat () <ORKTextScaleAnswerFormatProvider>

@end
#endif

NSArray<Class> *ORKAllowableValueClasses(void);

@interface ORKTextChoice () <ORKAnswerOption>

@end

#if TARGET_OS_IOS
@interface ORKValuePickerAnswerFormat ()

- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices nullChoice:(ORKTextChoice *)nullChoice NS_DESIGNATED_INITIALIZER;

- (ORKTextChoice *)nullTextChoice;

@end


@interface ORKImageChoice () <ORKAnswerOption>

@end


@interface ORKTimeOfDayAnswerFormat ()

- (NSDate *)pickerDefaultDate;

@end


@interface ORKDateAnswerFormat ()

- (NSDate *)pickerDefaultDate;
- (nullable NSDate *)pickerMinimumDate;
- (nullable NSDate *)pickerMaximumDate;

- (NSCalendar *)currentCalendar;

@end


@interface ORKTimeIntervalAnswerFormat ()

- (NSTimeInterval)pickerDefaultDuration;

@end


@interface ORKTextAnswerFormat () <ORKConfirmAnswerFormatProvider>

@end


@interface ORKHeightAnswerFormat ()

@property (nonatomic, readonly) BOOL useMetricSystem;

@end


@interface ORKWeightAnswerFormat ()

@property (nonatomic, readonly) BOOL useMetricSystem;

@end


@interface ORKAnswerDefaultSource : NSObject

+ (instancetype)sourceWithHealthStore:(HKHealthStore *)healthStore;
- (instancetype)initWithHealthStore:(HKHealthStore *)healthStore NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly, nullable) HKHealthStore *healthStore;

- (void)fetchDefaultValueForAnswerFormat:(nullable ORKAnswerFormat *)answerFormat handler:(void(^)(id defaultValue, NSError *error))handler;

- (nullable HKUnit *)defaultHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat;
- (void)updateHealthKitUnitForAnswerFormat:(ORKAnswerFormat *)answerFormat force:(BOOL)force;

@end

@interface ORKTextChoiceOther()

@property (nonatomic, nullable) NSString *textViewText;

@end
#endif

@interface ORKAnswerFormat () <ORKChoiceAnswerFormatHelper>

@end

NS_ASSUME_NONNULL_END

