/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

#import "ORKConsentDocument+ORKInstructionStep.h"
#import "ORKHelpers_Internal.h"

@implementation ORKConsentDocument (ORKInstructionStep)

/**
  Converts an ORKConsentDocument to ORKInstructionSteps
 -`consentDocument`         An existing ORKConsentDocument
 -`returns`: Array of ORKInstructionStep
 */

-(NSArray<ORKInstructionStep*>*)instructionSteps {
    NSMutableArray *instructionSteps = [[NSMutableArray alloc] init];
    for (ORKConsentSection* section in self.sections) {
        ORKInstructionStep* instructionStep = [[ORKInstructionStep alloc] initWithIdentifier: section.title];
        instructionStep.title = section.title;
        instructionStep.detailText = section.summary;
        instructionStep.text = section.content;
        NSString* convertedImageName = [NSString stringWithFormat:@"consent_%02ld", section.type + 1];
        instructionStep.type = section.type;
        instructionStep.image = [UIImage imageNamed:convertedImageName inBundle:ORKBundle() withConfiguration:nil];
        [instructionSteps addObject:instructionStep];
    }
    
    return [instructionSteps copy];
}

/**
  Converts ORKInstructionSteps to an ORKConsentReviewStep
 -`instructionSteps`  An array of instructionSteps
 -`identifier` an string identifier
 -`signatureStep` an optional signature step
 -`returns`: an ORKConsentReviewStep
 */
- (ORKConsentReviewStep *)consentReviewStepFromInstructionSteps:(NSArray<ORKInstructionStep *> *)steps withIdentifier:(NSString *)identifier signature:(ORKConsentSignature *)signature {
    NSMutableArray *contentSections = [[NSMutableArray alloc] init];

    for (ORKInstructionStep* instructionStep in steps) {
        ORKConsentSection* section = [[ORKConsentSection alloc] initWithType:instructionStep.type];
        section.summary = NSLocalizedString(instructionStep.title ?: @"", comment: "");
        section.content = NSLocalizedString(instructionStep.text ?: @"", comment: "");
        
        [contentSections addObject:section];
    }
    
    self.sections = contentSections;
    
    if (signature != nil) {
        [self addSignature:signature];
    }
    
    return [[ORKConsentReviewStep alloc] initWithIdentifier:identifier signature:signature inDocument:self];
}


@end
