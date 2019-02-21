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


@import Foundation;
#import <ResearchKit/ORKDefines.h>


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
     In a multiple component choice picker, the participant can pick one choice from each component.
     */
    ORKQuestionTypeMultiplePicker,
    
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
     In a weight question, the participant can enter a weight by using a weight picker.
     */
    ORKQuestionTypeWeight,
    
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


/**
 You can use a permission mask to specify a set of permissions to acquire or
 that have been acquired for a task or step.
 */
typedef NS_OPTIONS(NSInteger, ORKPermissionMask) {
    /// No permissions.
    ORKPermissionNone                     = 0,
    
    /// Access to CoreMotion activity is required.
    ORKPermissionCoreMotionActivity       = (1 << 1),
    
    /// Access to CoreMotion accelerometer data.
    ORKPermissionCoreMotionAccelerometer  = (1 << 2),
    
    /// Access for audio recording.
    ORKPermissionAudioRecording           = (1 << 3),
    
    /// Access to location.
    ORKPermissionCoreLocation             = (1 << 4),
    
    /// Access to camera.
    ORKPermissionCamera                   = (1 << 5),
} ORK_ENUM_AVAILABLE;


/**
 File protection mode constants.
 
 The file protection mode constants correspond directly to `NSFileProtection` constants, but are
 more convenient to manipulate than strings. Complete file protection is
 highly recommended for files containing personal data that will be kept
 persistently.
 */
typedef NS_ENUM(NSInteger, ORKFileProtectionMode) {
    /// No file protection.
    ORKFileProtectionNone = 0,
    
    /// Complete file protection until first user authentication.
    ORKFileProtectionCompleteUntilFirstUserAuthentication,
    
    /// Complete file protection unless there was an open file handle before lock.
    ORKFileProtectionCompleteUnlessOpen,
    
    /// Complete file protection while the device is locked.
    ORKFileProtectionComplete
} ORK_ENUM_AVAILABLE;


/**
 Audio channel constants.
 */
typedef NS_ENUM(NSInteger, ORKAudioChannel) {
    /// The left audio channel.
    ORKAudioChannelLeft,
    
    /// The right audio channel.
    ORKAudioChannelRight
} ORK_ENUM_AVAILABLE;


/**
 Body side constants.
 */
typedef NS_ENUM(NSInteger, ORKBodySagittal) {
    /// The left side.
    ORKBodySagittalLeft,
    
    /// The right side.
    ORKBodySagittalRight
} ORK_ENUM_AVAILABLE;


/**
 Values that identify the left or right limb to be used in an active task.
 */
typedef NS_OPTIONS(NSUInteger, ORKPredefinedTaskLimbOption) {
    /// Which limb to use is undefined
    ORKPredefinedTaskLimbOptionUnspecified = 0,
    
    /// Task should test the left limb
    ORKPredefinedTaskLimbOptionLeft = 1 << 1,
    
    /// Task should test the right limb
    ORKPredefinedTaskLimbOptionRight = 1 << 2,
    
    /// Task should test the both limbs (random order)
    ORKPredefinedTaskLimbOptionBoth = ORKPredefinedTaskLimbOptionLeft | ORKPredefinedTaskLimbOptionRight,
} ORK_ENUM_AVAILABLE;


/**
 Values that identify the presentation mode of paced serial addition tests that are auditory and/or visual (PSAT).
 */
typedef NS_OPTIONS(NSInteger, ORKPSATPresentationMode) {
    /// The PASAT (Paced Auditory Serial Addition Test).
    ORKPSATPresentationModeAuditory = 1 << 0,
    
    /// The PVSAT (Paced Visual Serial Addition Test).
    ORKPSATPresentationModeVisual = 1 << 1
} ORK_ENUM_AVAILABLE;


/**
 Identify the type of passcode authentication for `ORKPasscodeStepViewController`.
 */
typedef NS_ENUM(NSInteger, ORKPasscodeType) {
    /// 4 digit pin entry
    ORKPasscodeType4Digit,
    
    /// 6 digit pin entry
    ORKPasscodeType6Digit
} ORK_ENUM_AVAILABLE;


/**
 Values that identify the hand(s) to be used in an active task.
 
 By default, the participant will be asked to use their most affected hand.
 */
typedef NS_OPTIONS(NSUInteger, ORKPredefinedTaskHandOption) {
    /// Which hand to use is undefined
    ORKPredefinedTaskHandOptionUnspecified = 0,
    
    /// Task should test the left hand
    ORKPredefinedTaskHandOptionLeft = 1 << 1,
    
    /// Task should test the right hand
    ORKPredefinedTaskHandOptionRight = 1 << 2,
    
    /// Task should test both hands (random order)
    ORKPredefinedTaskHandOptionBoth = ORKPredefinedTaskHandOptionLeft | ORKPredefinedTaskHandOptionRight,
} ORK_ENUM_AVAILABLE;


/**
 The `ORKPredefinedTaskOption` flags let you exclude particular behaviors from the predefined active
 tasks in the predefined category of `ORKOrderedTask`.
 
 By default, all predefined tasks include instructions and conclusion steps, and may also include
 one or more data collection recorder configurations. Although not all predefined tasks include all
 of these data collection types, the predefined task option flags can be used to explicitly specify
 that a task option not be included.
 */
typedef NS_OPTIONS(NSUInteger, ORKPredefinedTaskOption) {
    /// Default behavior.
    ORKPredefinedTaskOptionNone = 0,
    
    /// Exclude the initial instruction steps.
    ORKPredefinedTaskOptionExcludeInstructions = (1 << 0),
    
    /// Exclude the conclusion step.
    ORKPredefinedTaskOptionExcludeConclusion = (1 << 1),
    
    /// Exclude accelerometer data collection.
    ORKPredefinedTaskOptionExcludeAccelerometer = (1 << 2),
    
    /// Exclude device motion data collection.
    ORKPredefinedTaskOptionExcludeDeviceMotion = (1 << 3),
    
    /// Exclude pedometer data collection.
    ORKPredefinedTaskOptionExcludePedometer = (1 << 4),
    
    /// Exclude location data collection.
    ORKPredefinedTaskOptionExcludeLocation = (1 << 5),
    
    /// Exclude heart rate data collection.
    ORKPredefinedTaskOptionExcludeHeartRate = (1 << 6),
    
    /// Exclude audio data collection.
    ORKPredefinedTaskOptionExcludeAudio = (1 << 7)
} ORK_ENUM_AVAILABLE;


/**
 Progress indicator type for `ORKWaitStep`.
 */
typedef NS_ENUM(NSInteger, ORKProgressIndicatorType) {
    /// Spinner animation.
    ORKProgressIndicatorTypeIndeterminate = 0,
    
    /// Progressbar animation.
    ORKProgressIndicatorTypeProgressBar,
} ORK_ENUM_AVAILABLE;


/**
 Measurement system.
 
 Used by ORKHeightAnswerFormat and ORKWeightAnswerFormat.
 */
typedef NS_ENUM(NSInteger, ORKMeasurementSystem) {
    /// Measurement system in use by the current locale.
    ORKMeasurementSystemLocal = 0,
    
    /// Metric measurement system.
    ORKMeasurementSystemMetric,

    /// United States customary system.
    ORKMeasurementSystemUSC,
} ORK_ENUM_AVAILABLE;


/**
 Trailmaking Type Identifiers for supported trailmaking types.
 */
typedef NSString * ORKTrailMakingTypeIdentifier NS_STRING_ENUM;

/// Trail making for Type-A trail where the pattern is 1-2-3-4-5-6-7
ORK_EXTERN ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierA;

/// Trail making for Type-B trail where the pattern is 1-A-2-B-3-C-4-D-5-E-6-F-7
ORK_EXTERN ORKTrailMakingTypeIdentifier const ORKTrailMakingTypeIdentifierB;


/**
 The `ORKTremorActiveTaskOption` flags let you exclude particular steps from the predefined active
 tasks in the predefined Tremor `ORKOrderedTask`.
 
 By default, all predefined active tasks will be included. The tremor active task option flags can
 be used to explicitly specify that an active task is not to be included.
 */
typedef NS_OPTIONS(NSUInteger, ORKTremorActiveTaskOption) {
    /// Default behavior.
    ORKTremorActiveTaskOptionNone = 0,
    
    /// Exclude the hand-in-lap steps.
    ORKTremorActiveTaskOptionExcludeHandInLap = (1 << 0),
    
    /// Exclude the hand-extended-at-shoulder-height steps.
    ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight = (1 << 1),
    
    /// Exclude the elbow-bent-at-shoulder-height steps.
    ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent = (1 << 2),
    
    /// Exclude the elbow-bent-touch-nose steps.
    ORKTremorActiveTaskOptionExcludeHandToNose = (1 << 3),
    
    /// Exclude the queen-wave steps.
    ORKTremorActiveTaskOptionExcludeQueenWave = (1 << 4)
} ORK_ENUM_AVAILABLE;


/**
 Enums to exclude options from `ORKPDFViewerStep`.
 */
typedef NS_OPTIONS(NSUInteger, ORKPDFViewerActionBarOption) {
    ORKPDFViewerActionBarOptionExcludeThumbnail = 1 << 0,
    ORKPDFViewerActionBarOptionExcludeAnnotation = 1 << 1,
    ORKPDFViewerActionBarOptionExcludeSearch = 1 << 2,
    ORKPDFViewerActionBarOptionExcludeShare = 1 << 3,
}ORK_ENUM_AVAILABLE;


/**
 Numeric precision.
 
 Used by ORKWeightAnswerFormat.
 */
typedef NS_ENUM(NSInteger, ORKNumericPrecision) {
    /// Default numeric precision.
    ORKNumericPrecisionDefault = 0,
    
    /// Low numeric precision.
    ORKNumericPrecisionLow,
    
    /// High numeric preicision.
    ORKNumericPrecisionHigh,
} ORK_ENUM_AVAILABLE;

/**
 Eye side for amsler grid
 */
typedef NS_ENUM(NSInteger, ORKAmslerGridEyeSide) {
    /**
     Not Specified
     */
    ORKAmslerGridEyeSideNotSpecified = 0,
    
    /**
     Left Eye
     */
    ORKAmslerGridEyeSideLeft,
    
    /**
     Right Eye
     */
    ORKAmslerGridEyeSideRight
} ORK_ENUM_AVAILABLE;

/**
 An enumeration of the types of button styles for Navigation Containers.
 */
typedef NS_ENUM(NSInteger, ORKNavigationContainerButtonStyle) {
    /**
     A standard ORKText button.
     */
    ORKNavigationContainerButtonStyleTextStandard = 0,
    
    /**
     A text button with Bold title.
     */
    ORKNavigationContainerButtonStyleTextBold,
    
    /**
     A rounded rect button.
     */
    ORKNavigationContainerButtonStyleRoundedRect
} ORK_ENUM_AVAILABLE;

extern const double ORKDoubleDefaultValue ORK_AVAILABLE_DECL;

/**
 Identifiers for locales that support speech recognition.
 */
typedef NSString * ORKSpeechRecognizerLocale NS_STRING_ENUM;

/// Arabic (Saudi Arabia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleArabic;

/// Catalan (Spain)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCatalan;

/// Czech (Czechia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCzech;

/// Danish (Denmark)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDanish;

/// German (Austria)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanAT;

/// German (Switzerland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanCH;

/// German (Germany)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGermanDE;

/// Greek (Greece)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleGreek;

/// English (United Arab Emirates)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishAE;

/// English (Australia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishAU;

/// English (Canada)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishCA;

/// English (United Kingdom)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishGB;

/// English (Indonesia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishID;

/// English (Ireland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishIE;

/// English (India)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishIN;

/// English (New Zealand)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishNZ;

/// English (Philippines)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishPH;

/// English (Saudi Arabia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishSA;

/// English (Singapore)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishSG;

/// English (United States)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishUS;

/// English (South Africa)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleEnglishZA;

/// Spanish (Chile)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishCL;

/// Spanish (Colombia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishCO;

/// Spanish (Spain)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishES;

/// Spanish (Mexico)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishMX;

/// Spanish (United States)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSpanishUS;

/// Finnish (Finland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFinnish;

/// French (Belgium)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchBE;

/// French (Canada)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchCA;

/// French (Switzerland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchCH;

/// French (France)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleFrenchFR;

/// Hebrew (Israel)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHebrew;

/// Hindi (India)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindi;

/// Hindi (India, TRANSLIT)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindiINTRANSLIT;

/// Hindi (Latin)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHindiLATN;

/// Croatian (Croatia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCroatian;

/// Hungarian (Hungary)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleHungarian;

/// Indonesian (Indonesia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleIndonesian;

/// Italian (Switzerland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleItalianCH;

/// Italian (Italy)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleItalianIT;

/// Japanese (Japan)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleJapaneseJP;

/// Korean (South Korea)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleKorean;

/// Malay (Malaysia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleMalay;

/// Norwegian Bokmål (Norway)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleNorwegian;

/// Dutch (Belgium)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDutchBE;

/// Dutch (Netherlands)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleDutchNL;

/// Polish (Poland)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePolish;

/// Portuguese (Brazil)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePortugeseBR;

/// Portuguese (Portugal)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocalePortugesePT;

/// Romanian (Romania)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleRomanian;

/// Russian (Russia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleRussian;

/// Slovak (Slovakia)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSlovak;

/// Swedish (Sweden)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleSwedish;

/// Thai (Thailand)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleThai;

/// Turkish (Turkey)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleTurkish;

/// Ukrainian (Ukraine)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleUkranian;

/// Vietnamese (Vietnam)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleVietnamese;

/// Shanghainese (China)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleShanghainese;

/// Cantonese (China)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleCantonese;

/// Chinese (China)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseCN;

/// Chinese (Hong Kong [China])
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseHK;

/// Chinese (Taiwan)
ORK_EXTERN ORKSpeechRecognizerLocale const ORKSpeechRecognizerLocaleChineseTW;


NS_ASSUME_NONNULL_END
