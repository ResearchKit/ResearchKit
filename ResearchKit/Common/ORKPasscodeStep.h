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


#import <ResearchKit/ResearchKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ORKPasscodeFlowCreate,
    ORKPasscodeFlowEdit,
    ORKPasscodeFlowAuthenticate
} ORKPasscodeFlow;

/**
 An `ORKPasscodeStep` object provides the participant an authentication step.
 
 You can use passcode step as part of the consent process to ensure that the
 participant signing the consent is the same participant completing other modules
 within that context.
 */
ORK_CLASS_AVAILABLE
@interface ORKPasscodeStep : ORKStep

- (instancetype)initWithIdentifier:(NSString *)identifier NS_UNAVAILABLE;

/**
 Returns an initialized passcode step using the specified passcode flow.
 
 @param identifier              The string that identifies the step (see `ORKStep`).
 @param passcodeFlow            The passcode flow determines how the passcode step is being used.
 @param text                    The text shown immediately below the title (see `ORKStep`).
 
 @return An initialized passcode step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                      passcodeFlow:(ORKPasscodeFlow)passcodeFlow
                              text:(nullable NSString *)text;

/**
 Returns an initialized passcode step using the specified passcode flow.
 
 @param identifier              The string that identifies the step (see `ORKStep`).
 @param passcodeFlow            The passcode flow determines how the passcode step is being used.
 
 @return An initialized passcode step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                      passcodeFlow:(ORKPasscodeFlow)passcodeFlow;

/**
 The passcode flow determines how the passcode step is being used.
 
 `ORKPasscodeFlowCreate` should be used to create a new passcode for a new user.
 An example usage would be at the end of the consent flow.
 
 `ORKPasscodeFlowAuthenticate` should be used to authenticate the user.
 An exmaple usage would be whenever the application comes into foreground.
 
 `ORKPasscodeFlowEdit` should be used to change the stored passcode.
 An exmaple usage would be inside a profile or settings page.
 */
@property (nonatomic) ORKPasscodeFlow passcodeFlow;


/**
 The original passcode entered by the user.
 
 This property must not set with a create passcode flow.
 This property is required with an edit passcode flow and authenticate passcode flow.
 The user passcode will be used to verify if the inputted passcode matches with it.
 Developer must provide the userPasscode that was stroed using a create passcode flow.
 */
@property (nonatomic, copy, nullable) NSString *userPasscode;

@end

NS_ASSUME_NONNULL_END
