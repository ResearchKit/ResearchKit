/*
 Copyright (c) 2017, Ricardo Sanchez-Saez.
 
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
#import "ORKOrderedTask.h"
#import "ORKRegistrationStep.h"


NS_ASSUME_NONNULL_BEGIN


/**
 Deprecated in v1.4.0 (scheduled for removal in v1.6.0).
 */
#ifdef __IPHONE_10_0
/// Add a protocol defining the initializer for iOS 8 apps. This signature was deprecated in iOS 9
/// and deleted in iOS 10.
@interface HKAnchoredObjectQuery (iOS8)

- (instancetype)initWithType:(HKSampleType *)type
                   predicate:(NSPredicate *)predicate
                      anchor:(NSUInteger)anchor
                       limit:(NSUInteger)limit
           completionHandler:(void (^)(HKAnchoredObjectQuery *query,
                                       NSArray<__kindof HKSample *> *results,
                                       NSUInteger newAnchor,
                                       NSError *error))handler NS_DEPRECATED_IOS(8_0, 9_0);

@end
#endif


/**
 Deprecated in v1.4.0 (scheduled for removal in v1.6.0).
 */
@interface ORKOrderedTask (Deprecated)

/**
 Returns a predefined task that enables an audio recording WITH a check of the audio level.
 
 In an audio recording task, the participant is asked to make some kind of sound
 with their voice, and the audio data is collected.
 
 An audio task can be used to measure properties of the user's voice, such as
 frequency range, or the ability to pronounce certain sounds.
 
 If `checkAudioLevel == YES` then a navigation rule is added to do a simple check of the background
 noise level. If the background noise is too loud, then the participant is instructed to move to a 
 quieter location before trying again.
 
 Data collected in this task consists of audio information.
 
 @param identifier              The task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription  A localized string describing the intended use of the data
 collected. If the value of this parameter is `nil`, default
 localized text is used.
 @param speechInstruction       Instructional content describing what the user needs to do when
 recording begins. If the value of this parameter is `nil`,
 default localized text is used.
 @param shortSpeechInstruction  Instructional content shown during audio recording. If the value of
 this parameter is `nil`, default localized text is used.
 @param duration                The length of the count down timer that runs while audio data is
 collected.
 @param recordingSettings       See "AV Foundation Audio Settings Constants" for possible values.
 @param options                 Options that affect the features of the predefined task.
 
 @return An active audio task that can be presented with an `ORKTaskViewController` object.
 */
+ (ORKNavigableOrderedTask *)audioTaskWithIdentifier:(NSString *)identifier
                              intendedUseDescription:(nullable NSString *)intendedUseDescription
                                   speechInstruction:(nullable NSString *)speechInstruction
                              shortSpeechInstruction:(nullable NSString *)shortSpeechInstruction
                                            duration:(NSTimeInterval)duration
                                   recordingSettings:(nullable NSDictionary *)recordingSettings
                                             options:(ORKPredefinedTaskOption)options
__attribute__((deprecated("Use '-audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:checkAudioLevel:options:' instead.")));

/**
 Returns a predefined task that consists of two finger tapping (Optionally with a hand specified)
 
 In a two finger tapping task, the participant is asked to rhythmically and alternately tap two
 targets on the device screen.
 
 A two finger tapping task can be used to assess basic motor capabilities including speed, accuracy,
 and rhythm.
 
 Data collected in this task includes touch activity and accelerometer information.
 
 @param identifier              The task identifier to use for this task, appropriate to the study.
 @param intendedUseDescription  A localized string describing the intended use of the data
                                collected. If the value of this parameter is `nil`, the default
                                localized text will be displayed.
 @param duration                The length of the count down timer that runs while touch data is
                                collected.
 @param options                 Options that affect the features of the predefined task.
 
 @return An active two finger tapping task that can be presented with an `ORKTaskViewController` object.
 */
+ (ORKOrderedTask *)twoFingerTappingIntervalTaskWithIdentifier:(NSString *)identifier
                                        intendedUseDescription:(nullable NSString *)intendedUseDescription
                                                      duration:(NSTimeInterval)duration
                                                       options:(ORKPredefinedTaskOption)options
__attribute__((deprecated("Use '-twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:handOptions:options:' instead.")));


@end


/**
 Deprecated in v1.5.0 (scheduled for removal in v1.6.0).
 */
@interface ORKAnswerFormat (Deprecated)

+ (ORKTextAnswerFormat *)textAnswerFormatWithValidationRegex:(NSString *)validationRegex
                                              invalidMessage:(NSString *)invalidMessage
__attribute__((deprecated("Use '-textAnswerFormatWithValidationRegularExpression:invalidMessage:' instead.",
                          "textAnswerFormatWithValidationRegularExpression")));

@end


/**
 Deprecated in v1.5.0 (scheduled for removal in v1.6.0).
 */
@interface ORKTextAnswerFormat (Deprecated)

/**
 Returns an initialized text answer format using the regular expression.
 
 This method is one of the designated initializers.
 
 @param validationRegex           The regular expression pattern used to validate the text.
 @param invalidMessage            The text presented to the user when invalid input is received.
 
 @return An initialized validated text answer format.
 */

- (instancetype)initWithValidationRegex:(NSString *)validationRegex
                         invalidMessage:(NSString *)invalidMessage
__attribute__((deprecated("Use '-initValidationRegularExpression:invalidMessage:' instead.",
                          "initWithValidationRegularExpression")));

/*
 The regular expression pattern used to validate user's input.

 If The value is nil, no validation will be performed.
*/
@property (nonatomic, copy, nullable, readonly) NSString *validationRegex
__attribute__((deprecated("Use 'validationRegularExpression' instead.",
                          "validationRegularExpression")));

@end


/**
 Deprecated in v1.5.0 (scheduled for removal in v1.6.0).
 */
@interface ORKRegistrationStep (Deprecated)

/**
 Returns an initialized registration step using the specified identifier,
 title, text, options, passcodeValidationRegularExpressionPattern, and
 passcodeInvalidMessage.
 
 @param identifier                  The string that identifies the step (see `ORKStep`).
 @param title                       The title of the form (see `ORKStep`).
 @param text                        The text shown immediately below the title (see `ORKStep`).
 @param passcodeValidationRegex     The regular expression pattern used to validate the passcode form item (see `ORKTextAnswerFormat`).
 @param passcodeInvalidMessage      The invalid message displayed for invalid input (see `ORKTextAnswerFormat`).
 @param options                     The options used for the step (see `ORKRegistrationStepOption`).
  
 @return An initialized registration step object.
   */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text
           passcodeValidationRegex:(nullable NSString *)passcodeValidationRegularExpressionPattern
            passcodeInvalidMessage:(nullable NSString *)passcodeInvalidMessage
                           options:(ORKRegistrationStepOption)options
__attribute__((deprecated("Use '-initWithIdentifier:title:text:passcodeValidationRegularExpression:passcodeInvalidMessage:options:' instead.")));


/**
 The regular expression pattern used to validate the passcode form item.
 This is a transparent property pointing to its definition in `ORKTextAnswerFormat`.
   
 The passcode invalid message property must also be set along with this property.
 By default, there is no validation on the passcode.
   */
@property (nonatomic, copy, nullable, readonly) NSString *passcodeValidationRegex
__attribute__((deprecated("Use 'passcodeValidationRegularExpression' instead.",
"passcodeValidationRegularExpression")));

@end

NS_ASSUME_NONNULL_END
