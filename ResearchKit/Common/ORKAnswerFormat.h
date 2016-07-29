/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2016, Ricardo Sánchez-Sáez.

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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKTypes.h>


NS_ASSUME_NONNULL_BEGIN

/**
 An enumeration of values that identify the different types of questions that the ResearchKit
 framework supports.
 */
typedef NS_ENUM(NSInteger, ORKQuestionType) {
    /**
     No question.
     */
     ORKQuestionTypeNone,
    
    /**
     The scale question type asks participants to place a mark at an appropriate position on a
     continuous or discrete line.
     */
    ORKQuestionTypeScale,

    /**
     In a single choice question, the participant can pick only one predefined option.
     */
    ORKQuestionTypeSingleChoice,
    
    /**
     In a multiple choice question, the participant can pick one or more predefined options.
     */
    ORKQuestionTypeMultipleChoice,
    
    /**
     The decimal question type asks the participant to enter a decimal number.
     */
    ORKQuestionTypeDecimal,
    
    /**
     The integer question type asks the participant to enter an integer number.
     */
    ORKQuestionTypeInteger,
    
    /**
     The Boolean question type asks the participant to enter Yes or No (or the appropriate
     equivalents).
     */
    ORKQuestionTypeBoolean,
    
    /**
     In a text question, the participant can enter multiple lines of text.
     */
    ORKQuestionTypeText,
    
    /**
     In a time of day question, the participant can enter a time of day by using a picker.
     */
    ORKQuestionTypeTimeOfDay,
    
    /**
     In a date and time question, the participant can enter a combination of date and time by using
     a picker.
     */
    ORKQuestionTypeDateAndTime,
    
    /**
     In a date question, the participant can enter a date by using a picker.
     */
    ORKQuestionTypeDate,
    
    /**
     In a time interval question, the participant can enter a time span by using a picker.
     */
    ORKQuestionTypeTimeInterval,

    /**
     In a height question, the participant can enter a height by using a height picker.
     */
    ORKQuestionTypeHeight,

    /**
     In a location question, the participant can enter a location using a map view.
     */
    ORKQuestionTypeLocation
} ORK_ENUM_AVAILABLE;

/**
 An enumeration of the types of answer choices available.
 */
typedef NS_ENUM(NSInteger, ORKChoiceAnswerStyle) {
    /**
     A single choice question lets the participant pick a single predefined answer option.
     */
    ORKChoiceAnswerStyleSingleChoice,
    
    /**
     A multiple choice question lets the participant pick one or more predefined answer options.
     */
    ORKChoiceAnswerStyleMultipleChoice
} ORK_ENUM_AVAILABLE;

/**
 An enumeration of the format styles available for scale answers.
 */
typedef NS_ENUM(NSInteger, ORKNumberFormattingStyle) {
    /**
     The default decimal style.
     */
    ORKNumberFormattingStyleDefault,
    
    /** 
     Percent style.
     */
    ORKNumberFormattingStylePercent
} ORK_ENUM_AVAILABLE;

@class ORKScaleAnswerFormat;
@class ORKContinuousScaleAnswerFormat;
@class ORKTextScaleAnswerFormat;
@class ORKValuePickerAnswerFormat;
@class ORKImageChoiceAnswerFormat;
@class ORKTextChoiceAnswerFormat;
@class ORKBooleanAnswerFormat;
@class ORKNumericAnswerFormat;
@class ORKTimeOfDayAnswerFormat;
@class ORKDateAnswerFormat;
@class ORKTextAnswerFormat;
@class ORKEmailAnswerFormat;
@class ORKTimeIntervalAnswerFormat;
@class ORKHeightAnswerFormat;
@class ORKLocationAnswerFormat;

@class ORKTextChoice;
@class ORKImageChoice;


/**
 The `ORKAnswerFormat` class is the abstract base class for classes that describe the
 format in which a survey question or form item should be answered. The ResearchKit framework uses
 `ORKQuestionStep` and `ORKFormItem` to represent questions to ask the user. Each
 question must have an associated answer format.
 
 To use an answer format, instantiate the appropriate answer format subclass and
 attach it to a question step or form item. Incorporate the resulting step
 into a task, and present the task with a task view controller.
 
 An answer format is validated when its owning step is validated.
 
 Some answer formats are constructed of other answer formats. When this is the
 case, the answer format can implement the internal method `_impliedAnswerFormat` to return
 the answer format that is implied. For example, a Boolean answer format
 is presented in the same way as a single-choice answer format with the
 choices Yes and No mapping to `@(YES)` and `@(NO)`, respectively.
 */
ORK_CLASS_AVAILABLE
@interface ORKAnswerFormat : NSObject <NSSecureCoding, NSCopying>

/// @name Properties

/**
 The type of question. (read-only)
 
 You can use this enumerated value in your Objective-C code to switch on
 a rough approximation of the type of question that is being asked.
 
 Note that answer format subclasses override the getter to return the appropriate question
 type.
 */
@property (readonly) ORKQuestionType questionType;

/// @name Factory methods

+ (ORKScaleAnswerFormat *)scaleAnswerFormatWithMaximumValue:(NSInteger)scaleMaximum
                                               minimumValue:(NSInteger)scaleMinimum
                                               defaultValue:(NSInteger)defaultValue
                                                       step:(NSInteger)step
                                                   vertical:(BOOL)vertical
                                    maximumValueDescription:(nullable NSString *)maximumValueDescription
                                    minimumValueDescription:(nullable NSString *)minimumValueDescription;

+ (ORKContinuousScaleAnswerFormat *)continuousScaleAnswerFormatWithMaximumValue:(double)scaleMaximum
                                                                   minimumValue:(double)scaleMinimum
                                                                   defaultValue:(double)defaultValue
                                                          maximumFractionDigits:(NSInteger)maximumFractionDigits
                                                                       vertical:(BOOL)vertical
                                                        maximumValueDescription:(nullable NSString *)maximumValueDescription
                                                        minimumValueDescription:(nullable NSString *)minimumValueDescription;

+ (ORKTextScaleAnswerFormat *)textScaleAnswerFormatWithTextChoices:(NSArray <ORKTextChoice *> *)textChoices
                                                      defaultIndex:(NSInteger)defaultIndex
                                                          vertical:(BOOL)vertical;

+ (ORKBooleanAnswerFormat *)booleanAnswerFormat;

+ (ORKValuePickerAnswerFormat *)valuePickerAnswerFormatWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices;

+ (ORKImageChoiceAnswerFormat *)choiceAnswerFormatWithImageChoices:(NSArray<ORKImageChoice *> *)imageChoices;

+ (ORKTextChoiceAnswerFormat *)choiceAnswerFormatWithStyle:(ORKChoiceAnswerStyle)style
                                               textChoices:(NSArray<ORKTextChoice *> *)textChoices;

+ (ORKNumericAnswerFormat *)decimalAnswerFormatWithUnit:(nullable NSString *)unit;
+ (ORKNumericAnswerFormat *)integerAnswerFormatWithUnit:(nullable NSString *)unit;

+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormat;
+ (ORKTimeOfDayAnswerFormat *)timeOfDayAnswerFormatWithDefaultComponents:(nullable NSDateComponents *)defaultComponents;

+ (ORKDateAnswerFormat *)dateTimeAnswerFormat;
+ (ORKDateAnswerFormat *)dateTimeAnswerFormatWithDefaultDate:(nullable NSDate *)defaultDate
                                                 minimumDate:(nullable NSDate *)minimumDate
                                                 maximumDate:(nullable NSDate *)maximumDate
                                                    calendar:(nullable NSCalendar *)calendar;

+ (ORKDateAnswerFormat *)dateAnswerFormat;
+ (ORKDateAnswerFormat *)dateAnswerFormatWithDefaultDate:(nullable NSDate *)defaultDate
                                             minimumDate:(nullable NSDate *)minimumDate
                                             maximumDate:(nullable NSDate *)maximumDate
                                                calendar:(nullable NSCalendar *)calendar;

+ (ORKTextAnswerFormat *)textAnswerFormat;

+ (ORKTextAnswerFormat *)textAnswerFormatWithMaximumLength:(NSInteger)maximumLength;

+ (ORKTextAnswerFormat *)textAnswerFormatWithValidationRegex:(NSString *)validationRegex
                                              invalidMessage:(NSString *)invalidMessage;

+ (ORKEmailAnswerFormat *)emailAnswerFormat;

+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormat;
+ (ORKTimeIntervalAnswerFormat *)timeIntervalAnswerFormatWithDefaultInterval:(NSTimeInterval)defaultInterval
                                                                        step:(NSInteger)step;

+ (ORKHeightAnswerFormat *)heightAnswerFormat;
+ (ORKHeightAnswerFormat *)heightAnswerFormatWithMeasurementSystem:(ORKMeasurementSystem)measurementSystem;

+ (ORKLocationAnswerFormat *)locationAnswerFormat;

/// @name Validation

/**
 Validates the parameters of the answer format to ensure that they can be displayed.
 
 Typically, this method is called by the validation methods of the owning objects, which are
 themselves called when a step view controller that contains this answer format is
 about to be displayed.
 */
- (void)validateParameters;

@end


/**
 The `ORKScaleAnswerFormat `class represents an answer format that includes a slider control.
 
 The scale answer format produces an `ORKScaleQuestionResult` object that contains an integer whose
 value is between the scale's minimum and maximum values, and represents one of the quantized step
 values.

 The following are the rules bound with scale answer format -
 
 * Minimum number of step in a task should not be less than 1.
 * Minimum number of section on a scale (step count) should not be less than 1.
 * Maximum number of section on a scale (step count) should not be more than 13.
 * The lower bound value in scale answer format cannot be lower than - 10000.
 * The upper bound value in scale answer format cannot be more than 10000.

 */
ORK_CLASS_AVAILABLE
@interface ORKScaleAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized scale answer format using the specified values.
 
 This method is the designated initializer.
 
 @param maximumValue                The upper bound of the scale.
 @param minimumValue                The lower bound of the scale.
 @param defaultValue                The default value of the scale. If this value is out of range,
                                        the slider is displayed without a default value.
 @param step                        The size of each discrete offset on the scale.
 @param vertical                    Pass `YES` to use a vertical scale; for the default horizontal
                                        scale, pass `NO`.
 @param maximumValueDescription     A localized label to describe the maximum value of the scale.
                                        For none, pass `nil`.
 @param minimumValueDescription     A localized label to describe the minimum value of the scale.
                                        For none, pass `nil`.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step
                            vertical:(BOOL)vertical
             maximumValueDescription:(nullable NSString *)maximumValueDescription
             minimumValueDescription:(nullable NSString *)minimumValueDescription NS_DESIGNATED_INITIALIZER;


/**
 Returns an initialized scale answer format using the specified values.
 
 This method is a convenience initializer.
 
 @param maximumValue    The upper bound of the scale.
 @param minimumValue    The lower bound of the scale.
 @param defaultValue    The default value of the scale. If this value is out of range, the slider is
                            displayed without a default value.
 @param step            The size of each discrete offset on the scale.
 @param vertical        Pass `YES` to use a vertical scale; for the default horizontal scale,
                            pass `NO`.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step
                            vertical:(BOOL)vertical;

/**
 Returns an initialized horizontal scale answer format using the specified values.
 
 This method is a convenience initializer.

 @param maximumValue    The upper bound of the scale.
 @param minimumValue    The lower bound of the scale.
 @param defaultValue    The default value of the scale. If this value is out of range, the slider is
                            displayed without a default value.
 @param step            The size of each discrete offset on the scale.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(NSInteger)maximumValue
                        minimumValue:(NSInteger)minimumValue
                        defaultValue:(NSInteger)defaultValue
                                step:(NSInteger)step;

/**
 The upper bound of the scale. (read-only)
 */
@property (readonly) NSInteger maximum;

/**
 The lower bound of the scale. (read-only)
 */
@property (readonly) NSInteger minimum;

/**
 The size of each discrete offset on the scale. (read-only)
 
 The value of this property should be greater than zero.
 The difference between `maximumValue` and `minimumValue` should be divisible
 by the step value.
 */
@property (readonly) NSInteger step;

/**
 The default value for the slider. (read-only)
 
 If the value of this property is less than `minimum` or greater than `maximum`, the slider has no
 default. Otherwise, the value is rounded to the nearest valid `step` value.
 */
@property (readonly) NSInteger defaultValue;

/**
 A Boolean value indicating whether the scale is oriented vertically. (read-only)
 */
@property (readonly, getter=isVertical) BOOL vertical;

/**
 Number formatter applied to the minimum, maximum, and slider values. Can be overridden by
 subclasses.
 */
@property (readonly) NSNumberFormatter *numberFormatter;

/**
 A localized label to describe the maximum value of the scale. (read-only)
 */
@property (readonly, nullable) NSString *maximumValueDescription;

/**
 A localized label to describe the minimum value of the scale. (read-only)
 */
@property (readonly, nullable) NSString *minimumValueDescription;

/**
 An image for the upper bound of the slider. The recommended image size is 30 x 30 points.
 The maximum range label will not be visible.
 */
@property (strong, nullable) UIImage *maximumImage;

/**
 An image for the lower bound of the slider. The recommended image size is 30 x 30 points.
 The minimum range label will not be visible.
 */
@property (strong, nullable) UIImage *minimumImage;

@end


/**
 The `ORKContinuousScaleAnswerFormat` class represents an answer format that lets participants
 select a value on a continuous scale.
 
 The continuous scale answer format produces an `ORKScaleQuestionResult` object that has a
 real-number value.
 */
ORK_CLASS_AVAILABLE
@interface ORKContinuousScaleAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized continuous scale answer format using the specified values.
 
 This method is the designated initializer.
 
 @param maximumValue                The upper bound of the scale.
 @param minimumValue                The lower bound of the scale.
 @param defaultValue                The default value of the scale. If this value is out of range,
                                        the slider is displayed without a default value.
 @param maximumFractionDigits       The maximum number of fractional digits to display.
 @param vertical                    Pass `YES` to use a vertical scale; for the default horizontal
                                        scale, pass `NO`.
 @param maximumValueDescription     A localized label to describe the maximum value of the scale.
                                        For none, pass `nil`.
 @param minimumValueDescription     A localized label to describe the minimum value of the scale.
                                        For none, pass `nil`.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits
                            vertical:(BOOL)vertical
             maximumValueDescription:(nullable NSString *)maximumValueDescription
             minimumValueDescription:(nullable NSString *)minimumValueDescription NS_DESIGNATED_INITIALIZER;

/**
 Returns an initialized continuous scale answer format using the specified values.
 
 @param maximumValue            The upper bound of the scale.
 @param minimumValue            The lower bound of the scale.
 @param defaultValue            The default value of the scale. If this value is out of range, the
                                    slider is displayed without a default value.
 @param maximumFractionDigits   The maximum number of fractional digits to display.
 @param vertical                Pass `YES` to use a vertical scale; for the default horizontal scale,
                                    pass `NO`.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits
                            vertical:(BOOL)vertical;

/**
 Returns an initialized horizontal continous scale answer format using the specified values.
 
 This method is a convenience initializer.
 
 @param maximumValue            The upper bound of the scale.
 @param minimumValue            The lower bound of the scale.
 @param defaultValue            The default value of the scale. If this value is out of range, the
                                    slider is displayed without a default value.
 @param maximumFractionDigits   The maximum number of fractional digits to display.
 
 @return An initialized scale answer format.
 */
- (instancetype)initWithMaximumValue:(double)maximumValue
                        minimumValue:(double)minimumValue
                        defaultValue:(double)defaultValue
               maximumFractionDigits:(NSInteger)maximumFractionDigits;

/**
 The upper bound of the scale. (read-only)
 */
@property (readonly) double maximum;

/**
 The lower bound of the scale. (read-only)
 */
@property (readonly) double minimum;

/**
 The default value for the slider. (read-only)
 
 If the value of this property is less than `minimum` or greater than `maximum`, the slider has no 
 default value.
 */
@property (readonly) double defaultValue;

/**
 The maximum number of fractional digits to display. (read-only)
 */
@property (readonly) NSInteger maximumFractionDigits;

/**
 A Boolean value indicating whether the scale is oriented vertically. (read-only)
 */
@property (readonly, getter=isVertical) BOOL vertical;

/**
 A formatting style applied to the minimum, maximum, and slider values.
 */
@property ORKNumberFormattingStyle numberStyle;

/**
 A number formatter applied to the minimum, maximum, and slider values. Can be overridden by
 subclasses.
 */
@property (readonly) NSNumberFormatter *numberFormatter;

/**
 A localized label to describe the maximum value of the scale. (read-only)
 */
@property (readonly, nullable) NSString *maximumValueDescription;

/**
 A localized label to describe the minimum value of the scale. (read-only)
 */
@property (readonly, nullable) NSString *minimumValueDescription;

/**
 An image for the upper bound of the slider. 
 @discussion The recommended image size is 30 x 30 points. The maximum range label will not be visible.
 */
@property (strong, nullable) UIImage *maximumImage;

/**
 An image for the lower bound of the slider. 
 @discussion The recommended image size is 30 x 30 points. The minimum range label will not be visible.
 */
@property (strong, nullable) UIImage *minimumImage;

@end


/**
 The `ORKTextScaleAnswerFormat` represents an answer format that includes a discrete slider control
 with a text label next to each step.
 
 The scale answer format produces an `ORKChoiceQuestionResult` object that contains the selected text 
 choice's value. */
ORK_CLASS_AVAILABLE
@interface ORKTextScaleAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized text scale answer format using the specified values.
 
 This method is the designated initializer.
 
 @param textChoices                 An array of text choices which will be used to determine the
                                        number of steps in the slider, and
                                    to fill the text label next to each of the steps. The array must
                                        contain between 2 and 8 text choices.
 @param defaultIndex                The default index of the scale. If this value is out of range,
                                        the slider is displayed without a default value.
 @param vertical                    Pass `YES` to use a vertical scale; for the default horizontal
                                        scale, pass `NO`.
 
 @return An initialized text scale answer format.
 */
- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices
                       defaultIndex:(NSInteger)defaultIndex
                           vertical:(BOOL)vertical NS_DESIGNATED_INITIALIZER;

/**
 Returns an initialized text scale answer format using the specified values.
 
 This method is a convenience initializer.
 
 @param textChoices                 An array of text choices which will be used to determine the
                                        number of steps in the slider, and
                                    to fill the text label next to each of the steps. The array must
                                        contain between 2 and 8 text choices.
 @param defaultIndex                The default index of the scale. If this value is out of range,
                                        the slider is displayed without a default value.
 
 @return An initialized text scale answer format.
 */
- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices
                       defaultIndex:(NSInteger)defaultIndex;

/**
 An array of text choices which provides the text to be shown next to each of the slider steps.
 (read-only)
 */
@property (copy, readonly) NSArray<ORKTextChoice *> *textChoices;

/**
 The default index for the slider. (read-only)
 
 If the value of this property is less than zero or greater than the number of text choices,
 the slider has no default value.
 */
@property (readonly) NSInteger defaultIndex;

/**
 A Boolean value indicating whether the scale is oriented vertically. (read-only)
 */
@property (readonly, getter=isVertical) BOOL vertical;

@end


/**
 The `ORKValuePickerAnswerFormat` class represents an answer format that lets participants use a
 value picker to choose from a fixed set of text choices.
 
 When the number of choices is relatively large and the text that describes each choice
 is short, you might want to use the value picker answer format instead of the text choice answer
 format (`ORKTextChoiceAnswerFormat`). When the text that describes each choice is long, or there
 are only a very small number of choices, it's usually better to use the text choice answer format.
 
 Note that the value picker answer format reports itself as being of the single choice question
 type. The value picker answer format produces an `ORKChoiceQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKValuePickerAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a value picker answer format using the specified array of text choices.
 
 Note that the `detailText` property of each choice is ignored. Be sure to create localized text for
 each choice that is short enough to fit in a `UIPickerView` object.
 
 @param textChoices     Array of `ORKTextChoice` objects.
 
 @return An initialized value picker answer format.
 */
- (instancetype)initWithTextChoices:(NSArray<ORKTextChoice *> *)textChoices NS_DESIGNATED_INITIALIZER;

/**
 An array of text choices that represent the options to display in the picker. (read-only)
 
 Note that the `detailText` property of each choice is ignored. Be sure to create localized text for
 each choice that is short enough to fit in a `UIPickerView` object.
 */
@property (copy, readonly) NSArray<ORKTextChoice *> *textChoices;

@end


/**
 The `ORKImageChoiceAnswerFormat` class represents an answer format that lets participants choose
 one image from a fixed set of images in a single choice question.
 
 For example, you might use the image choice answer format to represent a range of moods that range
 from very sad
 to very happy.
 
 The image choice answer format produces an `ORKChoiceQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoiceAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized image choice answer format using the specified array of images.
 
 @param imageChoices    Array of `ORKImageChoice` objects.
 
 @return An initialized image choice answer format.
 */
- (instancetype)initWithImageChoices:(NSArray<ORKImageChoice *> *)imageChoices NS_DESIGNATED_INITIALIZER;

/**
 An array of `ORKImageChoice` objects that represent the available choices. (read-only)
 
 The text of the currently selected choice is displayed on screen. The text for
 each choice is spoken by VoiceOver when an image is highlighted.
 */
@property (copy, readonly) NSArray<ORKImageChoice *> *imageChoices;

@end


/**
 The `ORKTextChoiceAnswerFormat` class represents an answer format that lets participants choose
 from a fixed set of text choices in a multiple or single choice question.
 
 The text choices are presented in a table view, using one row for each answer.
 The text for each answer is given more prominence than the `detailText` in the row, but
 both are shown.
 
 The text choice answer format produces an `ORKChoiceQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoiceAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized text choice answer format using the specified question style and array of
 text choices.
 
 @param style           The style of question, such as single or multiple choice.
 @param textChoices     An array of `ORKTextChoice` objects.
 
 @return An initialized text choice answer format.
 */
- (instancetype)initWithStyle:(ORKChoiceAnswerStyle)style
                  textChoices:(NSArray<ORKTextChoice *> *)textChoices NS_DESIGNATED_INITIALIZER;

/**
 The style of the question (that is, single or multiple choice).
 */
@property (readonly) ORKChoiceAnswerStyle style;

/**
 An array of `ORKTextChoice` objects that represent the choices that are displayed to participants.
 
 The choices are presented as a table view, using one row for each answer.
 The text for each answer is given more prominence than the `detailText` in the row, but
 both are shown.
 */
@property (copy, readonly) NSArray<ORKTextChoice *> *textChoices;

@end


/**
 The `ORKBooleanAnswerFormat` class behaves the same as the `ORKTextChoiceAnswerFormat` class,
 except that it is preconfigured to use only Yes and No answers.
 
 The Boolean answer format produces an `ORKBooleanQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKBooleanAnswerFormat : ORKAnswerFormat

@end


/**
 The `ORKTextChoice` class defines the text for a choice in answer formats such
 as `ORKTextChoiceAnswerFormat` and `ORKValuePickerAnswerFormat`.
 
 When a participant chooses a text choice item, the value recorded in a result
 is specified by the `value` property.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextChoice : NSObject <NSSecureCoding, NSCopying, NSObject>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a text choice object that includes the specified primary text, detail text,
 and exclusivity.
 
 @param text        The primary text that describes the choice in a localized string.
 @param detailText  The detail text to display below the primary text, in a localized string.
 @param value       The value to record in a result object when this item is selected.
 @param exclusive   Whether this choice is to be considered exclusive within the set of choices.
 
 @return A text choice instance.
 */
+ (instancetype)choiceWithText:(NSString *)text detailText:(nullable NSString *)detailText value:(id<NSCopying, NSCoding, NSObject>)value exclusive:(BOOL)exclusive;

/**
 Returns a choice object that includes the specified primary text.
 
 @param text        The primary text that describes the choice in a localized string.
 @param value       The value to record in a result object when this item is selected.
 
 @return A text choice instance.
 */
+ (instancetype)choiceWithText:(NSString *)text value:(id<NSCopying, NSCoding, NSObject>)value;

/**
 Returns an initialized text choice object using the specified primary text, detail text,
 and exclusivity.
 
 This method is the designated initializer.
 
 @param text        The primary text that describes the choice in a localized string.
 @param detailText  The detail text to display below the primary text, in a localized string.
 @param value       The value to record in a result object when this item is selected.
 @param exclusive   Whether this choice is to be considered exclusive within the set of choices.
 
 @return An initialized text choice.
 */
- (instancetype)initWithText:(NSString *)text
                  detailText:(nullable NSString *)detailText
                       value:(id<NSCopying, NSCoding, NSObject>)value
                    exclusive:(BOOL)exclusive NS_DESIGNATED_INITIALIZER;

/**
 The text that describes the choice in a localized string.
 
 In general, it's best when the text can fit on one line.
  */
@property (copy, readonly) NSString *text;

/**
 The value to return when this choice is selected.
 
 The value of this property is expected to be a scalar property list type, such as `NSNumber`
 or `NSString`. If no value is provided, the index of the option in the options list in the
 answer format is used.
 */
@property (copy, readonly) id<NSCopying, NSCoding, NSObject> value;

/**
 The text that provides additional details about the choice in a localized string.
 
 The detail text can span multiple lines. Note that `ORKValuePickerAnswerFormat` ignores detail
 text.
  */
@property (copy, readonly, nullable) NSString *detailText;

/**
 In a multiple choice format, this indicates whether this choice requires all other choices to be
 unselected.
 
 In general, this is used to indicate a "None of the above" choice.
 */
@property (readonly) BOOL exclusive;

@end


/**
 The `ORKImageChoice` class defines a choice that can
 be included in an `ORKImageChoiceAnswerFormat` object.
 
 Typically, image choices are displayed in a horizontal row, so you need to use appropriate sizes.
 For example, when five image choices are displayed in an `ORKImageChoiceAnswerFormat`, image sizes
 of about 45 to 60 points allow the images to look good in apps that run on all versions of iPhone.
 
 The text that describes an image choice should be reasonably short. However, only the text for the
 currently selected image choice is displayed, so text that wraps to more than one line
 is supported.
 */
ORK_CLASS_AVAILABLE
@interface ORKImageChoice : NSObject <NSSecureCoding, NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an image choice that includes the specified images and text.
 
 @param normal      The image to display in the unselected state.
 @param selected    The image to display in the selected state.
 @param text        The text to display when the image is selected.
 @param value       The value to record in a result object when the image is selected.
 
 @return An image choice instance.
 */
+ (instancetype)choiceWithNormalImage:(nullable UIImage *)normal
                        selectedImage:(nullable UIImage *)selected
                                 text:(nullable NSString *)text
                                value:(id<NSCopying, NSCoding, NSObject>)value;

/**
 Returns an initialized image choice using the specified images and text.
 
 This method is the designated initializer.
 
 @param normal      The image to display in the unselected state.
 @param selected    The image to display in the selected state.
 @param text        The text to display when the image is selected.
 @param value       The value to record in a result object when the image is selected.
 
 @return An initialized image choice.
 */
- (instancetype)initWithNormalImage:(nullable UIImage *)normal
                      selectedImage:(nullable UIImage *)selected
                               text:(nullable NSString *)text
                              value:(id<NSCopying, NSCoding, NSObject>)value NS_DESIGNATED_INITIALIZER;

/**
 The image to display when the choice is not selected. (read-only)
 
 The size of the unselected image depends on the number of choices you need to display. As a
 general rule, it's recommended that you start by creating an image that measures 44 x 44 points,
 and adjust it if necessary.
 */
@property (strong, readonly) UIImage *normalStateImage;

/**
 The image to display when the choice is selected. (read-only)
 
 For best results, the selected image should be the same size as the unselected image (that is,
 the value of the `normalStateImage` property).
 If you don't specify a selected image, the default `UIButton` behavior is used to
 indicate the selection state of the item.
 */
@property (strong, readonly, nullable) UIImage *selectedStateImage;

/**
 The text to display when the image is selected, in a localized string. (read-only)
 
 Note that the text you supply may be spoken by VoiceOver even when the item is not selected.
*/
@property (copy, readonly, nullable) NSString *text;

/**
 The value to return when the image is selected. (read-only)
 
 The value of this property is expected to be a scalar property list type, such as `NSNumber` or
 `NSString`. If no value is provided, the index of the option in the `ORKImageChoiceAnswerFormat`
 options list is used.
 */
@property (copy, readonly) id<NSCopying, NSCoding, NSObject> value;

@end


/**
 The style of answer for an `ORKNumericAnswerFormat` object, which controls the keyboard that is
 presented during numeric entry.
 */
typedef NS_ENUM(NSInteger, ORKNumericAnswerStyle) {

    /**
     A decimal question type asks the participant to enter a decimal number.
     */
    ORKNumericAnswerStyleDecimal,
    
    /**
     An integer question type asks the participant to enter an integer number.
     */
    ORKNumericAnswerStyleInteger
} ORK_ENUM_AVAILABLE;

/**
 The `ORKNumericAnswerFormat` class defines the attributes for a numeric
 answer format that participants enter using a numeric keyboard.
 
 If you specify maximum or minimum values and the user enters a value outside the
 specified range, the question step view controller does not allow navigation
 until the participant provides a value that is within the valid range.
 
 Questions and form items that use this answer format produce an
 `ORKNumericQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKNumericAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized numeric answer format using the specified style.
 
 @param style       The style of the numeric answer (decimal or integer).
 
 @return An initialized numeric answer format.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style;

/**
 Returns an initialized numeric answer format using the specified style and unit designation.
 
 @param style       The style of the numeric answer (decimal or integer).
 @param unit        A string that displays a localized version of the unit designation.
 
 @return An initialized numeric answer format.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(nullable NSString *)unit;

/**
Returns an initialized numeric answer format using the specified style, unit designation, and range
 values.
 
 This method is the designated initializer.
 
 @param style       The style of the numeric answer (decimal or integer).
 @param unit        A string that displays a localized version of the unit designation.
 @param minimum     The minimum value to apply, or `nil` if none is specified.
 @param maximum     The maximum value to apply, or `nil` if none is specified.
 
 @return An initialized numeric answer format.
 */
- (instancetype)initWithStyle:(ORKNumericAnswerStyle)style
                         unit:(nullable NSString *)unit
                      minimum:(nullable NSNumber *)minimum
                      maximum:(nullable NSNumber *)maximum NS_DESIGNATED_INITIALIZER;

/**
 The style of numeric entry (decimal or integer). (read-only)
 */
@property (readonly) ORKNumericAnswerStyle style;

/**
 A string that displays a localized version of the unit designation next to the numeric value.
 (read-only)
 
 Examples of unit designations are days, lbs, and liters.
 The unit string is included in the `ORKNumericQuestionResult` object.
  */
@property (copy, readonly, nullable) NSString *unit;

/**
 The minimum allowed value for the numeric answer.
 
 The default value of this property is `nil`, which means that no minimum value is displayed.
 */
@property (copy, nullable) NSNumber *minimum;

/**
 The maximum allowed value for the numeric answer.
 
 The default value of this property is `nil`, which means that no maximum value is displayed.
 */
@property (copy, nullable) NSNumber *maximum;

@end


/**
 The `ORKTimeOfDayAnswerFormat` class represents the answer format for questions that require users
 to enter a time of day.
 
 A time of day answer format produces an `ORKTimeOfDayQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeOfDayAnswerFormat : ORKAnswerFormat

/**
 Returns an initialized time of day answer format using the specified default value.
 
 This method is the designated initializer.
 
 @param defaultComponents   The default value with which to configure the picker.
 
 @return An initialized time of day answer format.
 */
- (instancetype)initWithDefaultComponents:(nullable NSDateComponents *)defaultComponents NS_DESIGNATED_INITIALIZER;

/**
 The default time of day to display in the picker. (read-only)
 
 Note that both the hour and minute components are observed. If the value of this property is `nil`,
 the picker displays the current time of day.
 */
@property (nonatomic, copy, readonly, nullable) NSDateComponents *defaultComponents;

@end


/**
 The style of date picker to use in an `ORKDateAnswerFormat` object.
 */
typedef NS_ENUM(NSInteger, ORKDateAnswerStyle) {

    /**
     The date and time question type asks participants to choose a time or a combination of date
     and time, from a picker.
     */
    ORKDateAnswerStyleDateAndTime,
    
    /**
     The date question type asks participants to choose a particular date from a picker.
     */
    ORKDateAnswerStyleDate
} ORK_ENUM_AVAILABLE;

/**
 The `ORKDateAnswerFormat` class represents the answer format for questions that require users
 to enter a date, or a date and time.
 
 A date answer format produces an `ORKDateQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKDateAnswerFormat : ORKAnswerFormat

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized date answer format using the specified date style.
 
 @param style           The style of date answer, such as date, or date and time.
 
 @return An initialized date answer format.
 */
- (instancetype)initWithStyle:(ORKDateAnswerStyle)style;

/**
 Returns an initialized date answer format using the specified answer style and default date values.
 
 This method is the designated initializer.
 
 @param style           The style of date answer, such as date, or date and time.
 @param defaultDate     The default date to display. When the value of this parameter is `nil`, the
                            picker displays the current time.
 @param minimumDate     The minimum date that is accessible in the picker. If the value of this
                            parameter is `nil`, there is no minimum.
 @param maximumDate     The maximum date that is accessible in the picker. If the value of this
                            parameter is `nil`, there is no maximum.
 @param calendar        The calendar to use. If the value of this parameter is `nil`, the picker
                            uses the default calendar for the current locale.
 
 @return An initialized date answer format.
 */
- (instancetype)initWithStyle:(ORKDateAnswerStyle)style
                  defaultDate:(nullable NSDate *)defaultDate
                  minimumDate:(nullable NSDate *)minimumDate
                  maximumDate:(nullable NSDate *)maximumDate
                     calendar:(nullable NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

/**
 The style of date entry.
 */
@property (readonly) ORKDateAnswerStyle style;

/**
 The date to use as the default.
 
 The date is displayed in the user's time zone.
 When the value of this property is `nil`, the current time is used as the default.
 */
@property (copy, readonly, nullable) NSDate *defaultDate;

/**
 The minimum allowed date.
 
When the value of this property is `nil`, there is no minimum.
 */
@property (copy, readonly, nullable) NSDate *minimumDate;

/**
 The maximum allowed date.
 
 When the value of this property is `nil`, there is no maximum.
 */
@property (copy, readonly, nullable) NSDate *maximumDate;

/**
 The calendar to use in the picker.
 
 When the value of this property is `nil`, the picker uses the default calendar for the current
 locale.
 */
@property (copy, readonly, nullable) NSCalendar *calendar;

@end


/**
 The `ORKTextAnswerFormat` class represents the answer format for questions that collect a text
 response
 from the user.
 
 An `ORKTextAnswerFormat` object produces an `ORKTextQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKTextAnswerFormat : ORKAnswerFormat

/**
 Returns an initialized text answer format using the regular expression.
 
 This method is one of the designated initializers.
 
 @param validationRegex           The regular expression used to validate the text.
 @param invalidMessage            The text presented to the user when invalid input is received.
 
 @return An initialized validated text answer format.
 */
- (instancetype)initWithValidationRegex:(NSString *)validationRegex
                         invalidMessage:(NSString *)invalidMessage NS_DESIGNATED_INITIALIZER;

/**
 Returns an initialized text answer format using the specified maximum string length.
 
 This method is one of the designated initializers.
 
 @param maximumLength   The maximum number of characters to accept. When the value of this parameter
                            is 0, there is no maximum.
 
 @return An initialized text answer format.
 */
- (instancetype)initWithMaximumLength:(NSInteger)maximumLength NS_DESIGNATED_INITIALIZER;

/**
 The regex used to validate user's input.
 
 The default value is nil. If set to nil, no validation will be performed.
 */
@property (nonatomic, copy, nullable) NSString *validationRegex;

/**
 The text presented to the user when invalid input is received.
 
 The default value is nil.
 */
@property (nonatomic, copy, nullable) NSString *invalidMessage;

/**
 The maximum length of the text users can enter.
 
 When the value of this property is 0, there is no maximum.
 */
@property NSInteger maximumLength;

/**
 A Boolean value indicating whether to expect more than one line of input.
 
 By default, the value of this property is `YES`.
 */
@property BOOL multipleLines;

/**
 The autocapitalization type that applies to the user's input.
 
 By default, the value of this property is `UITextAutocapitalizationTypeSentences`.
 */
@property UITextAutocapitalizationType autocapitalizationType;

/**
 The autocorrection type that applies to the user's input.
 
 By default, the value of this property is `UITextAutocorrectionTypeDefault`.
 */
@property UITextAutocorrectionType autocorrectionType;

/**
 The spell checking type that applies to the user's input.
 
 By default, the value of this property is `UITextSpellCheckingTypeDefault`.
 */
@property UITextSpellCheckingType spellCheckingType;

/**
 The keyboard type that applies to the user's input.
 
 By default, the value of this property is `UIKeyboardTypeDefault`.
 */
@property UIKeyboardType keyboardType;

/**
 Identifies whether the text object should hide the text being entered.
 
 By default, the value of this property is NO.
 */
@property(nonatomic,getter=isSecureTextEntry) BOOL secureTextEntry;

@end


/**
 The `ORKEmailAnswerFormat` class represents the answer format for questions that collect an email
 response from the user.
 
 An `ORKEmailAnswerFormat` object produces an `ORKTextQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKEmailAnswerFormat : ORKAnswerFormat

@end


/**
 The `ORKTimeIntervalAnswerFormat` class represents the answer format for questions that ask users
  to specify a time interval.
 
 The time interval answer format is suitable for time intervals up to 24 hours. If you need to track
 time intervals of longer duration, use a different answer format, such as
 `ORKValuePickerAnswerFormat`.
 
 Note that the time interval answer format does not support the selection of 0.
 
 A time interval answer format produces an `ORKTimeIntervalQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKTimeIntervalAnswerFormat : ORKAnswerFormat

/**
 Returns an initialized time interval answer format using the specified default interval and step 
 value.
 
 This method is the designated initializer.
 
 @param defaultInterval     The default value to display in the picker.
 @param step                The step in the interval, in minutes. The value of this parameter must
                                be between 1 and 30.
 
 @return An initialized time interval answer format.
 */
- (instancetype)initWithDefaultInterval:(NSTimeInterval)defaultInterval
                                   step:(NSInteger)step NS_DESIGNATED_INITIALIZER;

/**
 The initial time interval displayed in the picker.
 */
@property (readonly) NSTimeInterval defaultInterval;

/**
 The size of the allowed step in the interval, in minutes.
 
 By default, the value of this property is 1. The minimum value is 1, and the maximum value is 30.
 */
@property (readonly) NSInteger step;

@end


/**
 The `ORKHeightAnswerFormat` class represents the answer format for questions that require users
 to enter a height.
 
 A height answer format produces an `ORKNumericQuestionResult` object. The result is always reported
 in the metric system using the `cm` unit.
 */
ORK_CLASS_AVAILABLE
@interface ORKHeightAnswerFormat : ORKAnswerFormat

/**
 Returns an initialized height answer format using the measurement system specified in the current
 locale.
 
 @return An initialized height answer format.
 */
- (instancetype)init;

/**
 Returns an initialized height answer format using the specified measurement system.
 
 This method is the designated initializer.
 
 @param measurementSystem   The measurement system to use. See `ORKMeasurementSystem` for the
                                accepted values.
 
 @return An initialized height answer format.
 */
- (instancetype)initWithMeasurementSystem:(ORKMeasurementSystem)easurementSystem NS_DESIGNATED_INITIALIZER;

/**
 Indicates the measurement system used by the answer format.
 */
@property (readonly) ORKMeasurementSystem measurementSystem;

@end


/**
 The `ORKLocationAnswerFormat` class represents the answer format for questions that collect a location response
 from the user.
 
 An `ORKLocationAnswerFormat` object produces an `ORKLocationQuestionResult` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocationAnswerFormat : ORKAnswerFormat

/**
 Indicates whether or not the user's current location should be automatically entered the first time they tap on the input field.
 
 By default, this value is YES.
 */
@property (nonatomic, assign) BOOL useCurrentLocation;

@end


NS_ASSUME_NONNULL_END
