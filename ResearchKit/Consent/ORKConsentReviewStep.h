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

@class ORKConsentDocument;
@class ORKConsentSignature;

/**
 The `ORKConsentReviewStep` class is used to represent the consent review process.
 Typically, the consent review process consists of three main parts:
 
 1. Consent document review. In this part, you display the consent document for review. Users
 must explicitly agree to the consent document before they can proceed.
 
 2. Name entry (optional). Users are asked to enter their first and last name. To
 request name entry in your app, set the step's `signature` property, and ensure that the signature's
 `requiresName` property is set to `YES`.
 
 3. Signature (optional). Users are asked to draw their signature on the device screen.
 To request signature entry in your app, set the step's `signature` property, and ensure that the signature's
 `requiresName` property is set to `YES`.
 
 The content for the consent document review comes from a consent document (`ORKConsentDocument`)
 provided during initialization.
 
 To use a consent review step, configure it and include it in a task. Then
 present the task in a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentReviewStep : ORKStep

/// @name Initialization.

/**
 Returns an initialized consent review step using the specified identifier, signature, and consent document.

 @param identifier      The identifier for the step.
 @param signature       The signature to be collected, if any.
 @param consentDocument The consent document to be reviewed.
 
 @return An initialized consent review step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                         signature:(nullable ORKConsentSignature *)signature
                        inDocument:(ORKConsentDocument *)consentDocument;

/// @name Properties

/**
 The consent document to be reviewed by the user during the consent review process. (read-only)
 */
@property (nonatomic, strong, readonly) ORKConsentDocument *consentDocument;

/**
 The signature object from the document that should be collected. (read-only)
 
 When the value of `signature` is `nil`, neither the name nor the finger scrawl are collected.
 When the value of `signature` is not `nil`, the `requiresName` and `requiresSignatureImage` properties of
 `signature` determine the screens that get presented.
 
 The identifier of the signature is expected to match one of the signature objects in
 the consent document.
 */
@property (nonatomic, strong, readonly, nullable) ORKConsentSignature *signature;

/**
 When set to YES, the consent document must be scrolled to the bottom to enable the `Agree` button.
 */
@property (nonatomic) BOOL requiresScrollToBottom;

/**
 A user-visible description of the reason for agreeing to consent in a localized string.
 
 The reason for consent is presented in the confirmation dialog that users see when giving their consent.
  */
@property (nonatomic, copy, nullable) NSString *reasonForConsent;

@end

NS_ASSUME_NONNULL_END
