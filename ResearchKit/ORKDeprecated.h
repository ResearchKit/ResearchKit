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
