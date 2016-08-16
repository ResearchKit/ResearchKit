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
#import <ResearchKit/ORKStep.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKVerificationStep` class represents a step that serves as placeholder
 step to use while the user attempts to verify their account.
 
 The verification step contains a text field and a resend email button. The button 
 actions must be overriden inside a subclassed verification view controller to provide
 navigation logic.
 
 The developer should redirect user back to the app once the verification is done 
 and move forward automatically.
 */
ORK_CLASS_AVAILABLE
@interface ORKVerificationStep : ORKStep

- (instancetype)initWithIdentifier:(NSString *)identifier NS_UNAVAILABLE;

/**
 Returns an initialized verification step using the specified identifier,
 title, text, and class.
  
 @param identifier                          The string that identifies the step (see `ORKStep`).
 @param text                                The text shown immediately below the title (see `ORKStep`).
 @param verificationViewControllerClass     The subclassed verification view controller class.
 
 @return An initialized verification step object.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                              text:(nullable NSString *)text
   verificationViewControllerClass:(Class)verificationViewControllerClass;

/**
 The view controller subclass used for the step.
 
 The subclass allows you to override button actions in order to provide navigation logic
 for the button items on the step.
 */
@property (nonatomic, readonly) Class verificationViewControllerClass;

@end

NS_ASSUME_NONNULL_END
