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
#import <ResearchKit/ORKFormStep.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKRegistrationStepOption` flags let you include particular fields in addition
 to the default fields (email and password) in the registration step.
 */
typedef NS_OPTIONS(NSUInteger, ORKRegistrationStepOption) {
    /// Default behavior.
    ORKRegistrationStepDefault = 0,
    
    /// Include the given name field.
    ORKRegistrationStepIncludeGivenName = (1 << 1),
    
    /// Include the family name field.
    ORKRegistrationStepIncludeFamilyName = (1 << 2),
    
    /// Include the gender field.
    ORKRegistrationStepIncludeGender = (1 << 3),
    
    /// Include the date of birth field.
    ORKRegistrationStepIncludeDOB = (1 << 4)
} ORK_ENUM_AVAILABLE;


/**
 Constants for the form items included in the registration step.
 These allow for convenient retrieval of user's inputted data from the result.
 */
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierEmail ORK_AVAILABLE_DECL;
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierPassword ORK_AVAILABLE_DECL;
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierGivenName ORK_AVAILABLE_DECL;
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierFamilyName ORK_AVAILABLE_DECL;
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierGender ORK_AVAILABLE_DECL;
ORK_EXTERN NSString *const ORKRegistrationFormItemIdentifierDOB ORK_AVAILABLE_DECL;


/**
 The `ORKRegistrationStep` class represents a form step that provides fields commonly used
 for account registration.
 
 The registration step contains email and password fields by default. Optionally, any 
 of the additional fields can be included based on context and requirements.
 */
ORK_CLASS_AVAILABLE
@interface ORKRegistrationStep : ORKFormStep

/**
 Returns an initialized registration step using the specified identifier,
 title, text, options, passcodeValidationRegularExpression, and passcodeInvalidMessage.
 
 @param identifier                              The string that identifies the step (see `ORKStep`).
 @param title                                   The title of the form (see `ORKStep`).
 @param text                                    The text shown immediately below the title (see `ORKStep`).
 @param passcodeValidationRegularExpression     The regular expression used to validate the passcode form item (see `ORKTextAnswerFormat`).
 @param passcodeInvalidMessage                  The invalid message displayed for invalid input (see `ORKTextAnswerFormat`).
 @param options                                 The options used for the step (see `ORKRegistrationStepOption`).
 
 @return An initialized registration step object.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text
passcodeValidationRegularExpression:(nullable NSRegularExpression *)passcodeValidationRegularExpression
            passcodeInvalidMessage:(nullable NSString *)passcodeInvalidMessage
                           options:(ORKRegistrationStepOption)options;

/**
 Returns an initialized registration step using the specified identifier,
 title, text, and options.
  
 @param identifier    The string that identifies the step (see `ORKStep`).
 @param title         The title of the form (see `ORKStep`).
 @param text          The text shown immediately below the title (see `ORKStep`).
 @param options       The options used for the step (see `ORKRegistrationStepOption`).
 
 @return An initialized registration step object.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text
                           options:(ORKRegistrationStepOption)options;

/**
 The options used for the step.
 
 These options allow one or more fields to be included in the registration step.
 */
@property (nonatomic, readonly) ORKRegistrationStepOption options;

/**
 The regular expression used to validate the passcode form item.
 This is a transparent property pointing to its definition in `ORKTextAnswerFormat`.
 
 The passcode invalid message property must also be set along with this property.
 By default, there is no validation on the passcode.
 */
@property (nonatomic, copy, nullable) NSRegularExpression *passcodeValidationRegularExpression;

/**
 The invalid message displayed if the passcode does not match the validation regular expression.
 This is a transparent property pointing to its definition in `ORKTextAnswerFormat`.
 
 The passcode validation regular expression property must also be set along with this property.
 By default, there is no invalid message.
 */
@property (nonatomic, copy, nullable) NSString *passcodeInvalidMessage;

@end

NS_ASSUME_NONNULL_END
