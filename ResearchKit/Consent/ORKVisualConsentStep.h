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


#import <ResearchKit/ORKStep.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKConsentDocument;

/**
 The `ORKVisualConsentStep` class represents a step in the visual consent sequence.
 
 To use a visual consent step, first create a consent document with at least one
 section (at least one section must not be of type `ORKConsentSectionTypeOnlyInDocument`) and attach the document to a visual consent step. Put the visual consent step
 into a ResearchKit task, and present it with a task view controller.
 
 In the ResearchKit framework, an `ORKVisualConsentStep` object is used to present a series of simple
 graphics to help study participants understand the content of an informed
 consent document. The default graphics include animated transitions.
 The textual content you need to provide in the `consentDocument` property should relate to the specific study being run and should be localized.
 
 An `ORKVisualConsentStep` object produces an `ORKStepResult` object, in which the dates indicate the total amount of time participants have spent in the consent process, and the route by which they can exit the consent process.
 */
ORK_CLASS_AVAILABLE
@interface ORKVisualConsentStep : ORKStep

/**
 Returns an initialized visual consent step using the specified identifier and consent document.
 
 @param identifier          The identifier of the visual consent step, unique within the document.
 @param consentDocument     The informed consent document.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier document:(nullable ORKConsentDocument *)consentDocument;

/**
 The consent document whose sections determine the order and appearance of scenes
 in the visual consent step.
 */
@property (nonatomic, strong, nullable) ORKConsentDocument *consentDocument;

@end

NS_ASSUME_NONNULL_END
