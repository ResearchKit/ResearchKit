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


@import UIKit;
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKConsentSignature` class represents a signature in as `ORKConsentDocument` object.
 The signature can be that of an investigator, possibly prefilled with
 an image, date, and first and last name; or you might need to collect the details of a signature.
 
 Signatures can be collected in a consent review step (`ORKConsentReviewStep`). After a signature has
 been obtained (which produces an `ORKConsentSignatureResult` object), the resulting signature
 can be substituted into a copy of the document, and used when generating a PDF.
 
 Alternatively, the details of a signature can be uploaded to a server
 for PDF generation elsewhere or simply as a record of having obtained consent.
 
 The signature object has no concept of a cryptographic signature -- it is merely
 a record of any input the user made during a consent review step. Also, an `ORKConsentSignature` object
 does not verify or vouch for user identity.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSignature : NSObject <NSSecureCoding, NSCopying>

/// @name Factory methods

/**
 Returns a fully populated signature.
 
 Use this factory method when you need to prepopulate the investigator's signature in a generated consent document.
 
 @param title               The title of the signatory.
 @param dateFormatString    The format string to use when formatting the date of signature.
 @param identifier          The identifier of the signature, unique within this document.
 @param givenName           The given name of the signatory.
 @param familyName          The family name of the signatory.
 @param signatureImage      An image of the signature.
 @param signatureDate       The date on which the signature was obtained, represented as a string.
 */
+ (ORKConsentSignature *)signatureForPersonWithTitle:(nullable NSString *)title
                                    dateFormatString:(nullable NSString *)dateFormatString
                                          identifier:(NSString *)identifier
                                           givenName:(nullable NSString *)givenName
                                          familyName:(nullable NSString *)familyName
                                      signatureImage:(nullable UIImage *)signatureImage
                                          dateString:(nullable NSString *)signatureDate;

/**
 Returns a signature to be collected.
 
 Use this factory method when representing a request to collect a signature for a consent review step.
 
 @param title               The title of the signatory.
 @param dateFormatString    The format string to use when formatting the date of signature.
 @param identifier          The identifier of the signature, unique within this document.
 */
+ (ORKConsentSignature *)signatureForPersonWithTitle:(nullable NSString *)title
                                    dateFormatString:(nullable NSString *)dateFormatString
                                          identifier:(NSString *)identifier;

/// @name Consent review configuration

/**
 A Boolean value indicating whether the user needs to enter their name during consent review.
 
 The default value of this property is `YES`. In a consent review step, the name entry screen is not displayed when the value of this property is `NO`.
 */
@property (nonatomic, assign) BOOL requiresName;

/**
 A Boolean value indicating whether the user needs to draw a signature during consent review.
 
 The default value of this property is `YES`. In a consent review step, the signature entry
 screen is not shown when this property is `NO`.
 */
@property (nonatomic, assign) BOOL requiresSignatureImage;

/// @name Identifying signatories

/**
 The identifier for this signature.
 
 The identifier should be unique in the document. It can be used to find or
 replace a specific signature in an `ORKConsentDocument` object. The identifier is also reproduced in
 the `ORKConsentSignatureResult` object produced by an `ORKConsentReviewStep` object.
 */
@property (nonatomic, copy) NSString *identifier;

/// @name Personal information.

/// The title of the signatory.
@property (nonatomic, copy, nullable) NSString *title;

/// The given name (first name in Western languages)
@property (nonatomic, copy, nullable) NSString *givenName;

/// The family name (last name in Western languages)
@property (nonatomic, copy, nullable) NSString *familyName;

/// The image of the signature, if any.
@property (nonatomic, copy, nullable) UIImage *signatureImage;

/// The date associated with the signature.
@property (nonatomic, copy, nullable) NSString *signatureDate;

/**
 The date format string to be used when producing a date string for the PDF
 or consent review.
 
 For example, @"yyyy-MM-dd 'at' HH:mm". When the value of this property is `nil`,
 the current date and time for the current locale is used.
 */
@property (nonatomic, copy, nullable) NSString *signatureDateFormatString;

@end

NS_ASSUME_NONNULL_END
