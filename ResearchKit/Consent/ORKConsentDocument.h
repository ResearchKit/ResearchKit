/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Alex Basson. All rights reserved.

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

@class ORKHTMLPDFPageRenderer;

NS_ASSUME_NONNULL_BEGIN

@class ORKConsentSection;
@class ORKConsentSectionFormatter;
@class ORKConsentSignature;
@class ORKConsentSignatureFormatter;
@class ORKHTMLPDFWriter;

/**
 The `ORKConsentDocument` class represents the content of an informed consent
 document, which is a document that's used to obtain informed consent from participants
 in a medical or other research study. The ResearchKit framework uses an `ORKConsentDocument` object
 to provide content for visual consent steps (`ORKVisualConsentStep`) and for consent review steps (`ORKConsentReviewStep`).
 
 The `sections` of an `ORKConsentDocument` object are instances of `ORKConsentSection`.
 When an `ORKConsentDocument` object is attached to an visual consent step, these
 sections provide the content for the visual consent screens, and for the
 Learn More pages that are accessible from them. When attached to an consent review step,
 the sections can provide the content for the consent document to
 be reviewed.
 
 If the consent document is simple, each section may be able to map to a visual consent screen. And in some cases, the formatting of the consent document may
 be sufficiently simple that it can be presented using only section headers and
 simple formatting. If your consent document uses simple formatting, you might be able to generate a document to sign by specifying the sections and the signatures.
 In a case like this, you don't need to provide a value for the `htmlReviewContent` property,
 and when the consent review step is completed, the signatures can be
 placed into a copy of the document and a PDF can be generated.
 
 In more complex cases, the visual consent sections may bear little
 relation to the formal consent document. In a situation like this, place the formal consent
 document content in the `htmlReviewContent` property. Doing this overrides all content that would otherwise be generated from the consent
 sections.
 
 The document should be in the user's language, and all the content of
 the document should be appropriately localized.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentDocument : NSObject <NSSecureCoding, NSCopying>

/// @name Properties

/**
 The document's title in a localized string.
 
 The title appears only in the generated PDF for review; it is not used in the
 visual consent process.
  */
@property (nonatomic, copy, nullable) NSString *title;

/// @name Visual consent sections

/**
 The sections to be in printed in the PDF file and or presented in the
 visual consent sequence.
 
 All sections appear in the animated process, except for those sections of the
 type `ORKConsentSectionTypeOnlyInDocument`.
 
 If the `htmlReviewContent` property is not set, this content is also used to
 populate the document for review in the consent review step.
 
 The PDF file contains all sections.
 */
@property (nonatomic, copy, nullable) NSArray<ORKConsentSection *> *sections;

/// @name Signatures for consent review

/**
 The title to be rendered on the signature page of the generated PDF in a localized string.
 
 The title is ignored for visual consent. The title is also ignored if you supply a value for the `htmlReviewContent` property.
  */
@property (nonatomic, copy, nullable) NSString *signaturePageTitle;

/**
 The content to be rendered below the title on the signature page of the generated PDF in a localized string.
 
 The content is ignored for visual consent. The content is also ignored if you supply a value for the `htmlReviewContent` property.
  */
@property (nonatomic, copy, nullable) NSString *signaturePageContent;

/**
 The set of signatures that are required or prepopulated in the document.
 
 To add a signature to the document after consent review, the `signatures` array
 needs to be modified to incorporate the new signature content prior to PDF
 generation. For more information, see `[ORKConsentSignatureResult applyToDocument:]`.
 */
@property (nonatomic, copy, nullable) NSArray<ORKConsentSignature *> *signatures;

/**
 Adds a signature to the array of signatures.
 
 @param signature    The signature object to add to the document.
 */
- (void)addSignature:(ORKConsentSignature *)signature;

/// @name Alternative content provision

/**
 Override HTML content for review.
 
 Typically, the review content is generated from the values of the `sections` and `signatures`
 properties.
 
 When this property is set, the review content is reproduced exactly as provided in the property
 in the consent review step, and the `sections` and `signatures` properties
 are ignored.
 */
@property (nonatomic, copy, nullable) NSString *htmlReviewContent;

/// @name PDF generation

/**
 Writes the document's content into a PDF file.
 
 The PDF is generated in a form suitable for printing. This is done asynchronously,
 so the PDF data is returned through a completion block.
 
 @param handler     The handler block for generated PDF data. When successful, the returned
    data represents a complete PDF document that represents the consent.
 */
- (void)makePDFWithCompletionHandler:(void (^)(NSData * _Nullable PDFData, NSError * _Nullable error))handler;

/**
 Writes the document's content into a PDF file using the specified renderer.
 
 The PDF is generated in a form suitable for printing. This is done asynchronously,
 so the PDF data is returned through a completion block.
 
 @param render      The PDF renderer.
 @param handler     The handler block for generated PDF data. When successful, the returned
    data represents a complete PDF document that represents the consent.
 */
- (void)makeCustomPDFWithRenderer:(ORKHTMLPDFPageRenderer *)renderer
                completionHandler:(void (^)(NSData * _Nullable PDFData, NSError * _Nullable error))handler;
@end

NS_ASSUME_NONNULL_END
