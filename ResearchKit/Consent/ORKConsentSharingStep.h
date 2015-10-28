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

/**
 The `ORKConsentSharingStep` class represents a question step that includes prepopulated content that asks users about how much they're willing to allow
 data to be shared after collection.
 
 To use the consent sharing step, include it in a task and present that task
 with a task view controller. It's easy to incorporate a consent sharing step into the review flow, because it provides default content for its title, text, and answer format.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSharingStep : ORKQuestionStep

/**
 Returns an initialized consent sharing step using the specified title, text, and answer format.
 
 @param identifier                      The identifier of the step.
 @param investigatorShortDescription    A short description of the investigator in a localized string. For example, "Stanford Medicine" or "American Heart Association."
 @param investigatorLongDescription     An extended description of the investigator and partners in a localized string. For example, "Stanford and its partners."
 @param localizedLearnMoreHTMLContent   The HTML content to display when the user
                                        taps the Learn More button.
 
 @return An initialized consent sharing step.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
      investigatorShortDescription:(NSString *)investigatorShortDescription
       investigatorLongDescription:(NSString *)investigatorLongDescription
     localizedLearnMoreHTMLContent:(NSString *)localizedLearnMoreHTMLContent;

/// Localized HTML content to present in the Learn More section for the step.
@property (nonatomic, copy) NSString *localizedLearnMoreHTMLContent;

@end

NS_ASSUME_NONNULL_END
