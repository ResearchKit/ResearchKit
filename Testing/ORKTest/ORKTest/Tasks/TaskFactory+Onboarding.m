/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015-2017, Ricardo Sanchez-Saez.
 Copyright (c) 2016-2017, Sage Bionetworks
 
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


#import "TaskFactory+Onboarding.h"

@import ResearchKit;


/**
 A subclass is required for the login step.
 
 The implementation below demonstrates how to subclass and override button actions.
 */
@interface LoginViewController : ORKLoginStepViewController

@end


@implementation LoginViewController

- (void)forgotPasswordButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forgot password?"
                                                                   message:@"Button tapped"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end


/**
 A subclass is required for the verification step.
 
 The implementation below demonstrates how to subclass and override button actions.
 */
@interface VerificationViewController : ORKVerificationStepViewController

@end


@implementation VerificationViewController

- (void)resendEmailButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Resend Verification Email"
                                                                   message:@"Button tapped"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end


@implementation TaskFactory (Onboarding)

#pragma mark - Consent review task

/*
 This consent task demonstrates visual consent, followed by a consent review step.
 
 In a real consent process, you would substitute the text of your consent document
 for the various placeholders.
 */
- (id<ORKTask>)makeConsentTaskWithIdentifier:(NSString *)identifier {
    /*
     Most of the configuration of what pages will appear in the visual consent step,
     and what content will be displayed in the consent review step, it in the
     consent document itself.
     */
    ORKConsentDocument *consentDocument = [self buildConsentDocument];
    self.currentConsentDocument = [consentDocument copy];
    
    ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visualConsent" document:consentDocument];
    step.title = @"Consent Document";
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consentReview" signature:consentDocument.signatures[0] inDocument:consentDocument];
    reviewStep.title = @"Consent Review";
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[step, reviewStep]];
    
    return task;
}

/*
 The consent review task is used to quickly verify the layout of the consent
 sharing step and the consent review step.
 
 In a real consent process, you would substitute the text of your consent document
 for the various placeholders.
 */
- (id<ORKTask>)makeConsentReviewTaskWithIdentifier:(NSString *)identifier {
    /*
     Tests layout of the consent sharing step.
     
     This step is used when you want to obtain permission to share the data
     collected with other researchers for uses beyond the present study.
     */
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"consentSharing"
                         investigatorShortDescription:@"MyInstitution"
                          investigatorLongDescription:@"MyInstitution and its partners"
                        localizedLearnMoreHTMLContent:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    
    /*
     Tests layout of the consent review step.
     
     In the consent review step, the user reviews the consent document and
     optionally enters their name and/or draws a signature.
     */
    ORKConsentDocument *consentDocument = [self buildConsentDocument];
    ORKConsentSignature *participantSig = consentDocument.signatures[0];
    [participantSig setSignatureDateFormatString:@"yyyy-MM-dd 'at' HH:mm"];
    self.currentConsentDocument = [consentDocument copy];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consentReview" signature:participantSig inDocument:consentDocument];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:@[sharingStep,reviewStep]];
    return task;
}

/*
 The eligibility form task is used to demonstrate an eligibility form (`ORKFormStep`, `ORKFormItem`).
 */
- (id<ORKTask>)makeEligibilityFormTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"introStep"];
        step.title = @"Eligibility Form";
        [steps addObject:step];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"formStep"];
        step.optional = NO;
        step.title = @"Eligibility Form";
        step.text = @"Please answer the questions below.";
        
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"formItem1"
                                                                   text:@"Are you over 18 years of age?"
                                                           answerFormat:[ORKAnswerFormat booleanAnswerFormat]];
            item.optional = NO;
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"formItem2"
                                                                   text:@"Have you been diagnosed with pre-diabetes or type 2 diabetes?"
                                                           answerFormat:[ORKAnswerFormat booleanAnswerFormat]];
            item.optional = NO;
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"formItem3"
                                                                   text:@"Can you not read and understand English in order to provide informed consent and follow the instructions?"
                                                           answerFormat:[ORKAnswerFormat booleanAnswerFormat]];
            item.optional = NO;
            [items addObject:item];
        }
        
        {
            NSArray *textChoices = @[[ORKTextChoice choiceWithText:@"Yes" value:@1],
                                     [ORKTextChoice choiceWithText:@"No" value:@0],
                                     [ORKTextChoice choiceWithText:@"N/A" value:@2]];
            ORKTextChoiceAnswerFormat *answerFormat = (ORKTextChoiceAnswerFormat *)[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                                                                                    textChoices:textChoices];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"formItem4"
                                                                   text:@"Are you pregnant?"
                                                           answerFormat:answerFormat];
            item.optional = NO;
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"ineligibleStep"];
        step.title = @"Eligibility Form";
        step.text = @"You are ineligible to join the study.";
        [steps addObject:step];
    }
    
    {
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:@"eligibleStep"];
        step.title = @"Eligibility Form";
        step.text = @"You are eligible to join the study.";
        [steps addObject:step];
    }
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    // Build navigation rules.
    ORKPredicateStepNavigationRule *predicateRule = nil;
    ORKResultSelector *resultSelector = nil;
    
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"formStep" resultIdentifier:@"formItem1"];
    NSPredicate *predicateFormItem1 = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:YES];
    
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"formStep" resultIdentifier:@"formItem2"];
    NSPredicate *predicateFormItem2 = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:YES];
    
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"formStep" resultIdentifier:@"formItem3"];
    NSPredicate *predicateFormItem3 = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:NO];
    
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"formStep" resultIdentifier:@"formItem4"];
    NSPredicate *predicateFormItem4a = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:@0];
    NSPredicate *predicateFormItem4b = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector expectedAnswerValue:@2];
    
    NSPredicate *predicateEligible1 = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateFormItem1,predicateFormItem2, predicateFormItem3, predicateFormItem4a]];
    NSPredicate *predicateEligible2 = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateFormItem1,predicateFormItem2, predicateFormItem3, predicateFormItem4b]];
    
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateEligible1, predicateEligible2]
                                                          destinationStepIdentifiers:@[@"eligibleStep", @"eligibleStep"]];
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"formStep"];
    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule = nil;
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"ineligibleStep"];
    
    return task;
}

/*
 The eligibility survey task is used to demonstrate an eligibility survey.
 */
- (id<ORKTask>)makeEligibilitySurveyTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"introStep"];
        step.title = @"Eligibility Survey";
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"question1"
                                                                      title:@"Eligibility Survey"
                                                                   question:@"Are you over 18 years of age?"
                                                                     answer:[ORKAnswerFormat booleanAnswerFormat]];
        step.optional = NO;
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"ineligibleStep"];
        step.title = @"Eligibility Survey";
        step.text = @"You are ineligible to join the study.";
        [steps addObject:step];
    }
    
    {
        ORKCompletionStep *step = [[ORKCompletionStep alloc] initWithIdentifier:@"eligibleStep"];
        step.title = @"Eligibility Survey";
        step.text = @"You are eligible to join the study.";
        [steps addObject:step];
    }
    
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    
    // Build navigation rules.
    ORKResultSelector *resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"question1"];
    NSPredicate *predicateQuestion = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:YES];
    
    ORKPredicateStepNavigationRule *predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[predicateQuestion]
                                                                                          destinationStepIdentifiers:@[@"eligibleStep"]];
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"question1"];
    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule = nil;
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"ineligibleStep"];
    
    return task;
}

/*
 The login task is used to demonstrate a login step.
 */

- (id<ORKTask>)makeLoginTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKLoginStep *step = [[ORKLoginStep alloc] initWithIdentifier:@"loginStep"
                                                                title:@"Login"
                                                                 text:@"Enter your credentials"
                                             loginViewControllerClass:[LoginViewController class]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

/*
 The registration task is used to demonstrate a registration step.
 */
- (id<ORKTask>)makeRegistrationTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKRegistrationStepOption options = (ORKRegistrationStepIncludeFamilyName |
                                             ORKRegistrationStepIncludeGivenName |
                                             ORKRegistrationStepIncludeDOB |
                                             ORKRegistrationStepIncludeGender);
        ORKRegistrationStep *step = [[ORKRegistrationStep alloc] initWithIdentifier:@"registrationStep"
                                                                              title:@"Registration"
                                                                               text:@"Fill out the form below"
                                                                            options:options];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

/*
 The verification task is used to demonstrate a verification step.
 */
- (id<ORKTask>)makeVerificationTaskWithIdentifier:(NSString *)identifier {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKVerificationStep *step = [[ORKVerificationStep alloc] initWithIdentifier:@"verificationStep" text:@"Check your email and click on the link to verify your email address and start using the app."
                                                    verificationViewControllerClass:[VerificationViewController class]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:identifier steps:steps];
    return task;
}

@end
