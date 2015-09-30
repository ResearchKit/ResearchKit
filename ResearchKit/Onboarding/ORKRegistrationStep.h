/*
 Copyright (c) 2015, Bruce Duncan. All rights reserved.
 
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


#import <ResearchKit/ResearchKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKRegistrationStepOption` flags let you exclude particular fields from the default fields
 in the registration step.
 */

typedef NS_OPTIONS(NSUInteger, ORKRegistrationStepOption) {
    /// Default behavior.
    ORKRegistrationStepDefault = 0,
    
    /// Exclude the first name field.
    ORKRegistrationStepExcludeFirstName = (1 << 0),
    
    /// Exclude the last name field.
    ORKRegistrationStepExcludeLastName = (1 << 1),
    
    /// Exclude the email field.
    ORKRegistrationStepExcludeEmail = (1 << 2),
    
    /// Exclude the password field.
    ORKRegistrationStepExcludePassword = (1 << 3),
    
    /// Exclude the gender field.
    ORKRegistrationStepExcludeGender = (1 << 4),
} ORK_ENUM_AVAILABLE;


/**
 The `ORKRegistrationStep` class represents a form step that provides fields commonly used
 for account registration.
 
 The registration step contains all the fields by default. Optionally, any of the fields
 can be excluded based on context and requirements.
 */
ORK_CLASS_AVAILABLE
@interface ORKRegistrationStep : ORKFormStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text NS_UNAVAILABLE;

/**
 Returns an initialized registrationg step using the specified identifier, 
 message, and options.
 
 @param identifier    The string that identifies the step (see `ORKStep`).
 @param message       The message to be dislayed below the fields.
 @param options       The options used for the step.
 
 @return As initialized form step object.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                           message:(nullable NSString *)message
                           options:(ORKRegistrationStepOption)options;

/**
 The message displayed below the fields.
 
 This text provides information about where the data will be stored
 and how it will be used.
 */
@property (nonatomic, readonly) NSString *message;


/**
 The options used for the step.
 
 These options allow one or more fields to be excluded from the registation step.
 */
@property (nonatomic, readonly) ORKRegistrationStepOption options;

@end

NS_ASSUME_NONNULL_END
