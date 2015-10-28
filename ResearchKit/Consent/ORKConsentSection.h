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


#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>


NS_ASSUME_NONNULL_BEGIN

/**
 `ORKConsentSectionType` enumerates the predefined visual consent sections
 available in the ResearchKit framework.
 
 Although the visuals are predefined, and default localized titles and Learn
 More button titles are provided, you need to provide in `ORKConsentSection` the summary strapline on each visual consent
 page and the actual Learn More content, because these items are specific to each individual
 study.
 
 Not every section is applicable to every study, and most studies
 are likely to require additional sections.
 */
typedef NS_ENUM(NSInteger, ORKConsentSectionType) {
    /**
     Overview of the informed consent process.
     
     This content can inform the user of what to expect during the process,
     and provide general background information on the purpose of the study.
     */
    ORKConsentSectionTypeOverview,
    
    /**
     A section informing the user that sensor data will be collected.
     
     This content can identify which sensors will be used, for how long,
     and for what purpose.
     */
    ORKConsentSectionTypeDataGathering,
    
    /**
     A section describing the privacy policies for the study.
     
     This content can describe how data is protected, the processes used
     to sanitize the collected data or make it anonymous, and address the risks
     involved.
     */
    ORKConsentSectionTypePrivacy,
    
    /**
     A section describing how the collected data will be used.
     
     This content can include details about those who will have access to the data, the types of
     analysis that will be performed, and the degree of control the participant
     may have over the data after it is collected.
     */
    ORKConsentSectionTypeDataUse,
    
    /**
    A section describing how much time is required for the study.
     
     This content can help users understand what to expect as they participate in the study.
     */
    ORKConsentSectionTypeTimeCommitment,
    
    /**
     A section describing survey use in the study.
     
     This content can explain how survey data will be collected, for what purpose,
     and make it clear to what extent participation is optional.
     */
    ORKConsentSectionTypeStudySurvey,
    
    /**
     A section describing active task use in the study.
     
     This content can describe what types of tasks need to be performed, how
     often, and for what purpose. Any risks that are involved can
     also be communicated in this section.
     */
    ORKConsentSectionTypeStudyTasks,
    
    /**
     A section describing how to withdraw from the study.
     
     This section can describe the policies
     that govern the collected data if the user decides to withdraw.
     */
    ORKConsentSectionTypeWithdrawing,
    
    /**
     A custom section.
     
     Custom sections don't have a predefined title, summary, content, image,
     or animation. A consent document may have as many or as few custom sections
     as needed.
     */
    ORKConsentSectionTypeCustom,
    
    /**
     Document-only sections.
     
     Document-only sections are ignored for a visual consent step and are only
     displayed in a consent review step (assuming no value is provided for the  `htmlReviewContent` property).
     */
    ORKConsentSectionTypeOnlyInDocument
} ORK_ENUM_AVAILABLE;

/**
 The `ORKConsentSection` class represents one section in a consent document. Each
 `ORKConsentSection` object (apart from those of type `ORKConsentSectionTypeOnlyInDocument`)
 corresponds to a page in a visual consent step, or a section in the document
 reviewed in consent review step.
 
 If you initialize a consent section with one of the defined section types, you get a prepopulated title, a default image, and animation (when appropriate). You can override these properties or you can use the `ORKConsentSectionTypeCustom` type to
 avoid any prepopulation.
 
 If you provide content for the `ORKConsentSection` object, be sure to use localized content.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSection : NSObject <NSSecureCoding, NSCopying>

/**
 Returns an initialized consent section using the specified type.
 
 This method populates the title and summary for all types except for
 `ORKConsentSectionTypeCustom` and `ORKConsentSectionTypeOnlyInDocument`.
 
 @param type     The consent section type.
 */
- (instancetype)initWithType:(ORKConsentSectionType)type;

/**
 The type of section. (read-only)
 
 The value of this property indicates whether a predefined image, title, and animation are present.
 */
@property (nonatomic, readonly) ORKConsentSectionType type;

/**
 The title of the consent section in a localized string.
 
 The title is displayed as a scene title in the animated consent sequence and is also included in the PDF file, but it can be overridden by setting `formalTitle`.
 The title is prefilled unless the type is `ORKConsentSectionTypeCustom` or `ORKConsentSectionTypeOnlyInDocument`.
  */
@property (nonatomic, copy, nullable) NSString *title;

/**
 The formal title of the section in a localized string, for use in the legal document.
 
 If the value of this property is `nil`, the value of `title` is used in the legal document instead.
 */
@property (nonatomic, copy, nullable) NSString *formalTitle;

/**
 A short summary of the content in a localized string.
 
 The summary is displayed as description text in the animated consent sequence.
 The summary should be limited in length, so that the consent can be reliably
 displayed on smaller screens.
  */
@property (nonatomic, copy, nullable) NSString *summary;

/**
 The content of the section in a localized string.
 
 In a consent review step or in PDF file generation, the string is printed as the section's
 content. The string is also displayed as Learn More content in a visual consent step.
 
 This property is never prepopulated based on the value of `type`. If both `content` and `htmlContent` are non-nil, the value of the `htmlContent` property is used.
  */
@property (nonatomic, copy, nullable) NSString *content;

/**
 The HTML content used to override the `content` property if additional formatting is needed. The content should be localized.
 
 In cases where plain text content is not sufficient to convey important details
 during the consent process, you can provide HTML content in this property. When you do this, the `htmlContent` property takes precedence over the `content` property.
 
 In a consent review step or in PDF file generation, the value of this property is printed as the section's
 content; in a visual consent step, the content is displayed as Learn More content.
  */
@property (nonatomic, copy, nullable) NSString *htmlContent;

/**
 The NSURL used to override the 'htmlContent' and 'consent' property if a document should be required.
 
 This property is used to display a document when required by an authortity.
 
 */
@property (nonatomic, copy, nullable) NSURL *contentURL;

/**
 When set to YES, the section is omitted in a consent review step or in PDF file generation. This property is NO by default.
 */
@property (nonatomic) BOOL omitFromDocument;

/**
 A custom illustration for the consent.
 
 The custom image can override the image associated with any of the predefined
 section types for an `ORKVisualConsentStep` object. It is ignored for a consent review step and
 for PDF generation.
 
 The image is used in template rendering mode, and is tinted using the tint color.
 */
@property (nonatomic, copy, nullable) UIImage *customImage;

/**
 A custom Learn More button title in a localized string.
 
 The predefined section types have localized descriptive Learn More button
 titles for a visual consent step. When this property is not `nil`, it overrides that
 default text.
  */
@property (nonatomic, copy, nullable) NSString *customLearnMoreButtonTitle;

/**
 A file URL that specifies a custom transition animation video.
 
 Animations of the illustration between one screen and the next are provided
 by default for transitions between consecutive section `type` codes. Custom
 sections and out-of-order transitions may require custom animations.
 
 The animation loaded from the file URL is played aspect fill in the
 illustration area for forward transitions only. The video is rendered in
 template mode, with white treated as if it were transparent.
 */
@property (nonatomic, copy, nullable) NSURL *customAnimationURL;

@end

NS_ASSUME_NONNULL_END
