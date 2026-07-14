/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKCoreSerializationEntryProvider.h"

#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ResearchKit_Private.h>


@implementation ORKCoreSerializationEntryProvider

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)serializationEncodingTable {
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        internalEncodingTable =
        [@{
            ENTRY(ORKResultSelector,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKResultSelector *selector = [[ORKResultSelector alloc] initWithTaskIdentifier:GETPROP(dict, taskIdentifier)
                                                                                 stepIdentifier:GETPROP(dict, stepIdentifier)
                                                                               resultIdentifier:GETPROP(dict, resultIdentifier)];
                return selector;
            },
            (@{
                PROPERTY(taskIdentifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(stepIdentifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(resultIdentifier, NSString, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKPredicateStepNavigationRule,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKPredicateStepNavigationRule *rule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:GETPROP(dict, resultPredicates)
                                                                                             destinationStepIdentifiers:GETPROP(dict, destinationStepIdentifiers)
                                                                                                  defaultStepIdentifier:GETPROP(dict, defaultStepIdentifier)
                                                                                                         validateArrays:NO];
                return rule;
            },
            (@{
                PROPERTY(resultPredicates, NSPredicate, NSArray, NO, nil, nil),
                PROPERTY(destinationStepIdentifiers, NSString, NSArray, NO, nil, nil),
                PROPERTY(defaultStepIdentifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(additionalTaskResults, ORKTaskResult, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKDirectStepNavigationRule,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKDirectStepNavigationRule *rule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)];
                return rule;
            },
            (@{
                PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKPredicateFormItemVisibilityRule,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSString* predicateFormat = GETPROP(dict, predicateFormat);
                ORKPredicateFormItemVisibilityRule *rule = [[ORKPredicateFormItemVisibilityRule alloc] initWithPredicateFormat:predicateFormat];
                return rule;
            },
            (@{
                PROPERTY(predicateFormat, NSString, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKOrderedTask,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                            steps:GETPROP(dict, steps)];
                return task;
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(steps, ORKStep, NSArray, NO, nil, nil),
            })),
            ENTRY(ORKNavigableOrderedTask,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                              steps:GETPROP(dict, steps)];
                return task;
            },
            (@{
                PROPERTY(stepNavigationRules, ORKStepNavigationRule, NSMutableDictionary, YES, nil, nil),
                PROPERTY(skipStepNavigationRules, ORKSkipStepNavigationRule, NSMutableDictionary, YES, nil, nil),
                PROPERTY(stepModifiers, ORKStepModifier, NSMutableDictionary, YES, nil, nil),
                PROPERTY(shouldReportProgress, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKStep *step = [[ORKStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                return step;
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(allowsBackNavigation, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(title, NSString, NSObject, YES, nil, nil),
                PROPERTY(text, NSString, NSObject, YES, nil, nil),
                PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                PROPERTY(headerTextAlignment, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                PROPERTY(shouldTintImages, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(useSurveyMode, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(bodyItems, ORKBodyItem, NSArray, YES, nil, nil),
                PROPERTY(imageContentMode, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(iconImage, UIImage, NSObject, YES,
                    ^id(id image, ORKESerializationContext *context) {
                        return context.imageProvider ? [context.imageProvider referenceBySavingImage:image] : nil;
                    },
                    ^id(id jsonObject, ORKESerializationContext *context) {
                        if (![jsonObject isKindOfClass:[NSDictionary class]]) {
                            return nil;
                        }
                        return [context.imageProvider imageForReference:jsonObject];
                    }),
                PROPERTY(iconImageTintColor, UIColor, NSObject, YES,
                ^id(id color, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromColor:color]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper colorFromDictionary:dict]; }),
                IMAGEPROPERTY(auxiliaryImage, NSObject, YES),
                IMAGEPROPERTY(image, NSObject, YES),
                PROPERTY(bodyItemTextAlignment, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(buildInBodyItems, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(useExtendedPadding, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(earlyTerminationConfiguration, ORKEarlyTerminationConfiguration, NSObject, YES, nil, nil),
                PROPERTY(shouldAutomaticallyAdjustImageTintColor, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(requiredStepIdentifiers, NSString, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKBodyItem,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                ORKBodyItem *bodyItem = [[ORKBodyItem alloc] initWithText:GETPROP(dict, text)
                                                               detailText:GETPROP(dict, detailText)
                                                                    image:nil
                                                            learnMoreItem:GETPROP(dict, learnMoreItem)
                                                            bodyItemStyle:[GETPROP(dict, bodyItemStyle) intValue]
                                                             useCardStyle:GETPROP(dict, useCardStyle)
                                                          alignImageToTop:GETPROP(dict, alignImageToTop)];
                return bodyItem;
            },
            (@{
                PROPERTY(text, NSString, NSObject, NO, nil, nil),
                PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                PROPERTY(bodyItemStyle, NSNumber, NSObject, NO, nil, nil),
                IMAGEPROPERTY(image, NSObject, YES),
                PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                PROPERTY(useCardStyle, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(useSecondaryColor, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(alignImageToTop, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKLearnMoreItem,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                ORKLearnMoreItem *learnMoreItem = [[ORKLearnMoreItem alloc] initWithText:GETPROP(dict, text) learnMoreInstructionStep:GETPROP(dict, learnMoreInstructionStep)];
                return learnMoreItem;
            },
            (@{
                PROPERTY(text, NSString, NSObject, YES, nil, nil),
                PROPERTY(learnMoreInstructionStep, ORKLearnMoreInstructionStep, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKEarlyTerminationConfiguration,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                ORKEarlyTerminationConfiguration *configuration = [[ORKEarlyTerminationConfiguration alloc] initWithButtonText:GETPROP(dict, buttonText)
                                                                                                          earlyTerminationStep:GETPROP(dict, earlyTerminationStep)];
                return configuration;
            },
            (@{
                PROPERTY(buttonText, NSString, NSObject, NO, nil, nil),
                PROPERTY(earlyTerminationStep, ORKStep, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKReviewStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKReviewStep *reviewStep = [ORKReviewStep standaloneReviewStepWithIdentifier:GETPROP(dict, identifier)
                                                                                        steps:GETPROP(dict, steps)
                                                                                 resultSource:GETPROP(dict, resultSource)];
                return reviewStep;
            },
            (@{
                PROPERTY(steps, ORKStep, NSArray, NO, nil, nil),
                PROPERTY(resultSource, ORKTaskResult, NSObject, NO, nil, nil),
                PROPERTY(excludeInstructionSteps, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKPDFViewerStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKPDFViewerStep alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                             pdfURL:GETPROP(dict, pdfURL)];
            },
            (@{
                PROPERTY(pdfURL, NSURL, NSObject, YES,
                ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                PROPERTY(actionBarOption, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKPasscodeStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKPasscodeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(passcodeType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(useBiometrics, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(passcodeFlow, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKWaitStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKWaitStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(indicatorType, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKRecorderConfiguration,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *rollingFileSizeThreshold = GETPROP(dict, rollingFileSizeThreshold);
                ORKRecorderConfiguration *recorderConfiguration = [[ORKRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                                       outputDirectory:GETPROP(dict, outputDirectory)
                                                                                              rollingFileSizeThreshold:rollingFileSizeThreshold.doubleValue];
                return recorderConfiguration;
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(outputDirectory, NSURL, NSObject, YES,
                ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                PROPERTY(rollingFileSizeThreshold, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKQuestionStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKQuestionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(answerFormat, ORKAnswerFormat, NSObject, YES, nil, nil),
                PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                PROPERTY(question, NSString, NSObject, YES, nil, nil),
                PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
                PROPERTY(presentationStyle, NSString, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKInstructionStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                PROPERTY(centerImageVertically, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKLearnMoreInstructionStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
            })),
            ENTRY(ORKSecondaryTaskStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKSecondaryTaskStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(secondaryTask, ORKOrderedTask, NSObject, YES, nil, nil),
                PROPERTY(secondaryTaskButtonTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(nextButtonTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(requiredAttempts, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKVideoInstructionStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKVideoInstructionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(videoURL, NSURL, NSObject, YES,
                ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                PROPERTY(thumbnailTime, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(bundleAsset, ORKBundleAsset, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKCompletionStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKCompletionStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(reasonForCompletion, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKWebViewStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKWebViewStep *step = [[ORKWebViewStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                return step;
            },
            (@{
                PROPERTY(html, NSString, NSObject, YES, nil, nil),
                PROPERTY(instructionSteps, ORKInstructionStep, NSArray, YES, nil, nil),
                PROPERTY(customCSS, NSString, NSObject, YES, nil, nil),
                PROPERTY(showSignatureAfterContent, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKWebViewStepResult,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKWebViewStepResult *result = [[ORKWebViewStepResult alloc] initWithIdentifier:GETPROP(dict, identifier)];
                return result;
            },
            (@{
                PROPERTY(result, NSString, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKActiveStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKActiveStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(stepDuration, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldShowDefaultTimer, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldSpeakCountDown, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldSpeakRemainingTimeAtHalfway, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldStartTimerAutomatically, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldPlaySoundOnStart, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldPlaySoundOnFinish, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldVibrateOnStart, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldVibrateOnFinish, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldUseNextAsSkipButton, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(shouldContinueOnFinish, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(spokenInstruction, NSString, NSObject, YES, nil, nil),
                PROPERTY(finishedSpokenInstruction, NSString, NSObject, YES, nil, nil),
                PROPERTY(recorderConfigurations, ORKRecorderConfiguration, NSArray, YES, nil, nil)
            })),
            ENTRY(ORKImageCaptureStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKImageCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                ^id(id value, __unused ORKESerializationContext *context) { return
                    value?[ORKESerializerHelper dictionaryFromUIEdgeInsets:((NSValue *)value).UIEdgeInsetsValue]:nil; },
                ^id(id dict, __unused ORKESerializationContext *context) { return
                    [NSValue valueWithUIEdgeInsets:[ORKESerializerHelper edgeInsetsFromDictionary:dict]]; }),
                PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
                PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
                PROPERTY(captureRaw, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(useFrontCamera, NSNumber, NSObject, YES, nil, nil),
                IMAGEPROPERTY(templateImage, NSObject, YES),
            })),
            ENTRY(ORKVideoCaptureStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKVideoCaptureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(templateImageInsets, NSValue, NSObject, YES,
                ^id(id value, __unused ORKESerializationContext *context) { return
                    value?[ORKESerializerHelper dictionaryFromUIEdgeInsets:((NSValue *)value).UIEdgeInsetsValue]:nil; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithUIEdgeInsets:[ORKESerializerHelper edgeInsetsFromDictionary:dict]]; }),
                PROPERTY(duration, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(audioMute, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(torchMode, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(devicePosition, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(accessibilityHint, NSString, NSObject, YES, nil, nil),
                PROPERTY(accessibilityInstructions, NSString, NSObject, YES, nil, nil),
                IMAGEPROPERTY(templateImage, NSObject, YES),
            })),
            ENTRY(ORKSignatureStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKSignatureStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
            })),
            ENTRY(ORKTableStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTableStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            ((@{
                PROPERTY(items, NSObject, NSArray, YES, nil, nil),
                PROPERTY(isBulleted, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(bulletIconNames, NSString, NSArray, YES, nil, nil),
                PROPERTY(allowsSelection, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(bulletType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(pinNavigationContainer, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(bottomPadding, NSNumber, NSObject, YES, nil, nil)
            }))),
            ENTRY(ORKConsentDocument,
            nil,
            (@{
                PROPERTY(title, NSString, NSObject, NO, nil, nil),
                PROPERTY(sections, ORKConsentSection, NSArray, NO, nil, nil),
                PROPERTY(signaturePageTitle, NSString, NSObject, NO, nil, nil),
                PROPERTY(signaturePageContent, NSString, NSObject, NO, nil, nil),
                PROPERTY(signatures, ORKConsentSignature, NSArray, NO, nil, nil),
                PROPERTY(htmlReviewContent, NSString, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKConsentSharingStep,
            ^(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKConsentSharingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(localizedLearnMoreHTMLContent, NSString, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKConsentReviewStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKConsentReviewStep alloc] initWithIdentifier:GETPROP(dict, identifier) signature:GETPROP(dict, signature) inDocument:GETPROP(dict,consentDocument)];
            },
            (@{
                PROPERTY(consentDocument, ORKConsentDocument, NSObject, NO, nil, nil),
                PROPERTY(reasonForConsent, NSString, NSObject, YES, nil, nil),
                PROPERTY(signature, ORKConsentSignature, NSObject, NO, nil, nil),
                PROPERTY(requiresScrollToBottom, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKBundleAsset,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKBundleAsset alloc] initWithName:GETPROP(dict, name)
                                           bundleIdentifier:GETPROP(dict, bundleIdentifier)
                                              fileExtension:GETPROP(dict, fileExtension)];
            },
            (@{
                PROPERTY(name, NSString, NSObject, NO, nil, nil),
                PROPERTY(bundleIdentifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(fileExtension, NSString, NSObject, NO, nil, nil),
            })
            ),
            ENTRY(ORKConsentSection,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKConsentSection alloc] initWithType:((NSNumber *)GETPROP(dict, type)).integerValue];
            },
            (@{
                PROPERTY(type, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(title, NSString, NSObject, YES, nil, nil),
                PROPERTY(formalTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(summary, NSString, NSObject, YES, nil, nil),
                PROPERTY(content, NSString, NSObject, YES, nil, nil),
                PROPERTY(htmlContent, NSString, NSObject, YES, nil, nil),
                PROPERTY(contentURL, NSURL, NSObject, YES,
                ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                PROPERTY(customLearnMoreButtonTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(customAnimationURL, NSURL, NSObject, YES,
                ^id(id url, __unused ORKESerializationContext *context) { return [(NSURL *)url absoluteString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSURL URLWithString:string]; }),
                PROPERTY(omitFromDocument, NSNumber, NSObject, YES, nil, nil),
                IMAGEPROPERTY(customImage, NSObject, YES),
            })),
            ENTRY(ORKConsentSignature,
            nil,
            (@{
                PROPERTY(identifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(title, NSString, NSObject, YES, nil, nil),
                PROPERTY(givenName, NSString, NSObject, YES, nil, nil),
                PROPERTY(familyName, NSString, NSObject, YES, nil, nil),
                PROPERTY(signatureDate, NSString, NSObject, YES, nil, nil),
                PROPERTY(requiresName, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(requiresSignatureImage, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(signatureDateFormatString, NSString, NSObject, YES, nil, nil),
                IMAGEPROPERTY(signatureImage, NSObject, YES),
            })),
            ENTRY(ORKRegistrationStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKRegistrationStep alloc] initWithIdentifier:GETPROP(dict, identifier) title:GETPROP(dict, title) text:GETPROP(dict, text) options:(NSUInteger)((NSNumber *)GETPROP(dict, options)).integerValue];
            },
            (@{
                PROPERTY(options, NSNumber, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKRequestPermissionsStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKRequestPermissionsStep alloc] initWithIdentifier:GETPROP(dict, identifier) permissionTypes:GETPROP(dict, permissionTypes)];
            },
            (@{
                PROPERTY(permissionTypes, ORKPermissionType, NSArray, YES, nil, nil)
            })),
            ENTRY(ORKVerificationStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKVerificationStep alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) verificationViewControllerClass:NSClassFromString(GETPROP(dict, verificationViewControllerString))];
            },
            (@{
                PROPERTY(verificationViewControllerString, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKLoginStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKLoginStep alloc] initWithIdentifier:GETPROP(dict, identifier) title:GETPROP(dict, title) text:GETPROP(dict, text) loginViewControllerClass:NSClassFromString(GETPROP(dict, loginViewControllerString))];
            },
            (@{
                PROPERTY(loginViewControllerString, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKFormStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKFormStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(formItems, ORKFormItem, NSArray, YES, nil, nil),
                PROPERTY(footnote, NSString, NSObject, YES, nil, nil),
                PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(autoScrollEnabled, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(footerText, NSString, NSObject, YES, nil, nil),
                PROPERTY(cardViewStyle, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKFormItem,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKFormItem* formItem = [[ORKFormItem alloc] initWithIdentifier:GETPROP(dict, identifier) text:GETPROP(dict, text) answerFormat:GETPROP(dict, answerFormat)];
                return formItem;
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(optional, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(showsProgress, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(text, NSString, NSObject, NO, nil, nil),
                PROPERTY(detailText, NSString, NSObject, YES, nil, nil),
                PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
                PROPERTY(answerFormat, ORKAnswerFormat, NSObject, NO, nil, nil),
                PROPERTY(learnMoreItem, ORKLearnMoreItem, NSObject, YES, nil, nil),
                PROPERTY(tagText, NSString, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKPageStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKPageStep *step = [[ORKPageStep alloc] initWithIdentifier:GETPROP(dict, identifier) pageTask:GETPROP(dict, pageTask)];
                return step;
            },
            (@{
                PROPERTY(pageTask, ORKOrderedTask, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKNavigablePageStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKNavigablePageStep *step = [[ORKNavigablePageStep alloc] initWithIdentifier:GETPROP(dict, identifier) pageTask:GETPROP(dict, pageTask)];
                return step;
            },
            (@{
                PROPERTY(pageTask, ORKOrderedTask, NSObject, NO, nil, nil),
            })),
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
            ENTRY(ORKHealthKitCharacteristicTypeAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKHealthKitCharacteristicTypeAnswerFormat alloc] initWithCharacteristicType:GETPROP(dict, characteristicType)];
            },
            (@{
                PROPERTY(characteristicType, HKCharacteristicType, NSObject, NO,
                ^id(id type, __unused ORKESerializationContext *context) { return [(HKCharacteristicType *)type identifier]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [HKCharacteristicType characteristicTypeForIdentifier:string]; }),
                PROPERTY(defaultDate, NSDate, NSObject, YES,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(minimumDate, NSDate, NSObject, YES,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(maximumDate, NSDate, NSObject, YES,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(calendar, NSCalendar, NSObject, YES,
                ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKHealthKitQuantityTypeAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKHealthKitQuantityTypeAnswerFormat alloc] initWithQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit) style:((NSNumber *)GETPROP(dict, numericAnswerStyle)).integerValue];
            },
            (@{
                PROPERTY(unit, HKUnit, NSObject, NO,
                ^id(id unit, __unused ORKESerializationContext *context) { return [(HKUnit *)unit unitString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [HKUnit unitFromString:string]; }),
                PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                ^id(id type, __unused ORKESerializationContext *context) { return [(HKQuantityType *)type identifier]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
                PROPERTY(numericAnswerStyle, NSNumber, NSObject, NO,
                ^id(id num, __unused ORKESerializationContext *context) { return
                    [ORKESerializerHelper ORKNumericAnswerStyleToStringWithStyle:((NSNumber *)num).integerValue]; },
                ^id(id string, __unused ORKESerializationContext *context) { return
                    @([ORKESerializerHelper ORKNumericAnswerStyleFromString:string]); }),
                PROPERTY(shouldRequestAuthorization, NSNumber, NSObject, YES, nil, nil),
            })),
#endif
            ENTRY(ORKAnswerFormat,
            nil,
            (@{
                PROPERTY(showDontKnowButton, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(customDontKnowButtonText, NSString, NSObject, YES, nil, nil),
                PROPERTY(dontKnowButtonStyle, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKDontKnowAnswer,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                return [ORKDontKnowAnswer answer];
            },
            (@{
            })),
            ENTRY(ORKValuePickerAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKValuePickerAnswerFormat alloc]
                        initWithTextChoices:GETPROP(dict, textChoices)
                        nullChoice:GETPROP(dict, nullTextChoice)
                ];
            },
            (@{
                PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
                PROPERTY(nullTextChoice, ORKTextChoice, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKMultipleValuePickerAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:GETPROP(dict, valuePickers) separator:GETPROP(dict, separator)];
            },
            (@{
                PROPERTY(valuePickers, ORKValuePickerAnswerFormat, NSArray, NO, nil, nil),
                PROPERTY(separator, NSString, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKImageChoiceAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKImageChoiceAnswerFormat alloc] initWithImageChoices:GETPROP(dict, imageChoices) style:((NSNumber *)GETPROP(dict, style)).integerValue vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue];
            },
            (@{
                PROPERTY(imageChoices, ORKImageChoice, NSArray, NO, nil, nil),
                PROPERTY(style, NSNumber, NSObject, NO,
                ^id(id number, __unused ORKESerializationContext *context) { return
                    [ORKESerializerHelper ORKImageChoiceAnswerStyleToString:((NSNumber *)number).integerValue]; },
                ^id(id string, __unused ORKESerializationContext *context) { return
                    @([ORKESerializerHelper ORKImageChoiceAnswerStyleFromString:string]); }),
                PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKTextChoiceAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTextChoiceAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue textChoices:GETPROP(dict, textChoices)];
            },
            (@{
                PROPERTY(style, NSNumber, NSObject, NO, NUMTOSTRINGBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable]), STRINGTONUMBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable])),
                PROPERTY(textChoices, ORKTextChoice, NSArray, NO, nil, nil),
                PROPERTY(warningStateMessage, NSString, NSObject, YES, nil, nil),
                PROPERTY(warningStateTriggerValues, NSObject, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKTextChoice,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTextChoice alloc] initWithText:GETPROP(dict, text) detailText:GETPROP(dict, detailText) value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue];
            },
            (@{
                PROPERTY(text, NSString, NSObject, NO, nil, nil),
                PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                PROPERTY(exclusive, NSNumber, NSObject, NO, nil, nil),
                IMAGEPROPERTY(image, NSObject, YES)
            })),
            ENTRY(ORKTextChoiceOther,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTextChoiceOther alloc] initWithText:GETPROP(dict, text) primaryTextAttributedString:nil detailText:GETPROP(dict, detailText) detailTextAttributedString:nil value:GETPROP(dict, value) exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue textViewPlaceholderText:GETPROP(dict, textViewPlaceholderText) textViewInputOptional:((NSNumber *)GETPROP(dict, textViewInputOptional)).boolValue textViewStartsHidden:((NSNumber *)GETPROP(dict, textViewStartsHidden)).boolValue];
            },
            (@{
                PROPERTY(textViewPlaceholderText, NSString, NSObject, NO, nil, nil),
                PROPERTY(textViewInputOptional, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(textViewStartsHidden, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKImageChoice,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKImageChoice alloc] initWithNormalImage:nil selectedImage:nil text:GETPROP(dict, text) value:GETPROP(dict, value)];
            },
            (@{
                PROPERTY(text, NSString, NSObject, NO, nil, nil),
                PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                IMAGEPROPERTY(normalStateImage, NSObject, YES),
                IMAGEPROPERTY(selectedStateImage, NSObject, YES),
            })),
            ENTRY(ORKTimeOfDayAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTimeOfDayAnswerFormat alloc] initWithDefaultComponents:GETPROP(dict, defaultComponents)];
            },
            (@{
                PROPERTY(defaultComponents, NSDateComponents, NSObject, NO,
                ^id(id components, __unused ORKESerializationContext *context) { return ORKTimeOfDayStringFromComponents(components);  },
                ^id(id string, __unused ORKESerializationContext *context) { return ORKTimeOfDayComponentsFromString(string); }),
                PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKDateAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKDateAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue defaultDate:GETPROP(dict, defaultDate) minimumDate:GETPROP(dict, minimumDate) maximumDate:GETPROP(dict, maximumDate) calendar:GETPROP(dict, calendar)];
            },
            (@{
                PROPERTY(style, NSNumber, NSObject, NO,
                NUMTOSTRINGBLOCK([ORKESerializerHelper ORKDateAnswerStyleTable]),
                STRINGTONUMBLOCK([ORKESerializerHelper ORKDateAnswerStyleTable])),
                PROPERTY(calendar, NSCalendar, NSObject, NO,
                ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                PROPERTY(minimumDate, NSDate, NSObject, NO,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(maximumDate, NSDate, NSObject, NO,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(defaultDate, NSDate, NSObject, NO,
                ^id(id date, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() stringFromDate:date]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [ORKResultDateTimeFormatter() dateFromString:string]; }),
                PROPERTY(minuteInterval, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(daysBeforeCurrentDateToSetMinimumDate, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(daysAfterCurrentDateToSetMinimumDate, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(isMaxDateCurrentTime, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKNumericAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                ORKNumericAnswerFormat *format = [[ORKNumericAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue
                                                                                          unit:GETPROP(dict, unit)
                                                                                   displayUnit:GETPROP(dict, displayUnit)
                                                                                       minimum:GETPROP(dict, minimum)
                                                                                       maximum:GETPROP(dict, maximum)
                                                                         maximumFractionDigits:GETPROP(dict, maximumFractionDigits)];
                format.defaultNumericAnswer = GETPROP(dict, defaultNumericAnswer);
                return format;
            },
            (@{
                PROPERTY(style, NSNumber, NSObject, NO,
                ^id(id num, __unused ORKESerializationContext *context) {
                    ORKNumericAnswerStyle answerStyle = (ORKNumericAnswerStyle)((NSNumber *)num).integerValue;
                    return [ORKESerializerHelper ORKNumericAnswerStyleToStringWithStyle:answerStyle]; },
                ^id(id string, __unused ORKESerializationContext *context) {
                    return @([ORKESerializerHelper ORKNumericAnswerStyleFromString:string]); }),
                PROPERTY(unit, NSString, NSObject, NO, nil, nil),
                PROPERTY(displayUnit, NSString, NSObject, NO, nil, nil),
                PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(defaultNumericAnswer, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(hideUnitWhenAnswerIsEmpty, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKScaleAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                if (defaultValue == nil) {
                    defaultValue = [[NSNumber alloc] initWithInt:INT_MAX];
                }
                return [[ORKScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).integerValue
                                                             minimumValue:((NSNumber *)GETPROP(dict, minimum)).integerValue
                                                             defaultValue:defaultValue.integerValue
                                                                     step:((NSNumber *)GETPROP(dict, step)).integerValue
                                                                 vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                  maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                  minimumValueDescription:GETPROP(dict, minimumValueDescription)];
            },
            (@{
                PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
                PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
                PROPERTY(gradientColors, UIColor, NSArray, YES,
                ^id(id color, __unused ORKESerializationContext *context) {
                    return [ORKESerializerHelper dictionaryFromColor:color];
                },
                ^id(id dict, __unused ORKESerializationContext *context) {
                    return [ORKESerializerHelper colorFromDictionary:dict];
                }),
                PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil),
                IMAGEPROPERTY(minimumImage, NSObject, YES),
                IMAGEPROPERTY(maximumImage, NSObject, YES),
            })),
            ENTRY(ORKContinuousScaleAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *defaultValue = (NSNumber *)GETPROP(dict, defaultValue);
                if (defaultValue == nil) {
                    defaultValue = [[NSNumber alloc] initWithDouble:DBL_MAX];
                }
                return [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:((NSNumber *)GETPROP(dict, maximum)).doubleValue
                                                                       minimumValue:((NSNumber *)GETPROP(dict, minimum)).doubleValue
                                                                       defaultValue:defaultValue.doubleValue
                                                              maximumFractionDigits:((NSNumber *)GETPROP(dict, maximumFractionDigits)).integerValue
                                                                           vertical:((NSNumber *)GETPROP(dict, vertical)).boolValue
                                                            maximumValueDescription:GETPROP(dict, maximumValueDescription)
                                                            minimumValueDescription:GETPROP(dict, minimumValueDescription)];
            },
            (@{
                PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximumFractionDigits, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(numberStyle, NSNumber, NSObject, YES,
                ^id(id numeric, __unused ORKESerializationContext *context) {
                    return [ORKESerializerHelper tableMapForwardWithIndex:((NSNumber *)numeric).integerValue table:[ORKESerializerHelper numberFormattingStyleTable]];
                },
                ^id(id string, __unused ORKESerializationContext *context) {
                    return @([ORKESerializerHelper tableMapReverseWithValue:string table:[ORKESerializerHelper numberFormattingStyleTable]]);
                }),
                PROPERTY(maximumValueDescription, NSString, NSObject, NO, nil, nil),
                PROPERTY(minimumValueDescription, NSString, NSObject, NO, nil, nil),
                PROPERTY(gradientColors, UIColor, NSArray, YES, nil, nil),
                PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                IMAGEPROPERTY(minimumImage, NSObject, YES),
                IMAGEPROPERTY(maximumImage, NSObject, YES),
            })),
            ENTRY(ORKTextScaleAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTextScaleAnswerFormat alloc] initWithTextChoices:GETPROP(dict, textChoices) defaultIndex:(NSInteger)[GETPROP(dict, defaultIndex) doubleValue] vertical:[GETPROP(dict, vertical) boolValue]];
            },
            (@{
                PROPERTY(textChoices, ORKTextChoice, NSArray<ORKTextChoice *>, NO, nil, nil),
                PROPERTY(defaultIndex, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(vertical, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(gradientColors, UIColor, NSArray, YES,
                ^id(id color, __unused ORKESerializationContext *context) {
                    return [ORKESerializerHelper dictionaryFromColor:color];
                },
                ^id(id dict, __unused ORKESerializationContext *context) {
                    return [ORKESerializerHelper colorFromDictionary:dict];
                }),
                PROPERTY(gradientLocations, NSNumber, NSArray, YES, nil, nil),
                PROPERTY(hideSelectedValue, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideRanges, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideLabels, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideValueMarkers, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKTextAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTextAnswerFormat alloc] initWithMaximumLength:((NSNumber *)GETPROP(dict, maximumLength)).integerValue];
            },
            (@{
                PROPERTY(maximumLength, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(validationRegularExpression, NSRegularExpression, NSObject, YES,
                ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromRegularExpression:(NSRegularExpression *)value]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper regularExpressionsFromDictionary:dict]; } ),
                PROPERTY(invalidMessage, NSString, NSObject, YES, nil, nil),
                PROPERTY(defaultTextAnswer, NSString, NSObject, YES, nil, nil),
                PROPERTY(autocapitalizationType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(autocorrectionType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(spellCheckingType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(keyboardType, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(multipleLines, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideClearButton, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(hideCharacterCountLabel, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(secureTextEntry, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(textContentType, NSString, NSObject, YES, nil, nil),
                PROPERTY(passwordRules, UITextInputPasswordRules, NSObject, YES,
                ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromPasswordRules:(UITextInputPasswordRules *)value]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper passwordRulesFromDictionary:dict]; } ),
                PROPERTY(placeholder, NSString, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKEmailAnswerFormat,
            nil,
            (@{
                PROPERTY(usernameField, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKConfirmTextAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKConfirmTextAnswerFormat alloc] initWithOriginalItemIdentifier:GETPROP(dict, originalItemIdentifier) errorMessage:GETPROP(dict, errorMessage)];
            },
            (@{
                PROPERTY(originalItemIdentifier, NSString, NSObject, NO, nil, nil),
                PROPERTY(errorMessage, NSString, NSObject, NO, nil, nil),
                PROPERTY(maximumLength, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKTimeIntervalAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTimeIntervalAnswerFormat alloc] initWithDefaultInterval:((NSNumber *)GETPROP(dict, defaultInterval)).doubleValue step:((NSNumber *)GETPROP(dict, step)).integerValue];
            },
            (@{
                PROPERTY(defaultInterval, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(step, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKBooleanAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKBooleanAnswerFormat alloc] initWithYesString:((NSString *)GETPROP(dict, yes)) noString:((NSString *)GETPROP(dict, no))];
            },
            (@{
                PROPERTY(yes, NSString, NSObject, NO, nil, nil),
                PROPERTY(no, NSString, NSObject, NO, nil, nil),
                PROPERTY(warningStateMessage, NSString, NSObject, YES, nil, nil),
                PROPERTY(warningStateTriggerValues, NSObject, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKHeightAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKHeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue];
            },
            (@{
                PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                ^id(id number, __unused ORKESerializationContext *context) { return [ORKESerializerHelper ORKMeasurementSystemToString:((NSNumber *)number).integerValue]; },
                ^id(id string, __unused ORKESerializationContext *context) { return @([ORKESerializerHelper ORKMeasurementSystemFromString:string]); }),
            })),
            ENTRY(ORKWeightAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKWeightAnswerFormat alloc] initWithMeasurementSystem:((NSNumber *)GETPROP(dict, measurementSystem)).integerValue
                                                               numericPrecision:((NSNumber *)GETPROP(dict, numericPrecision)).integerValue
                                                                   minimumValue:((NSNumber *)GETPROP(dict, minimumValue)).doubleValue
                                                                   maximumValue:((NSNumber *)GETPROP(dict, maximumValue)).doubleValue
                                                                   defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).doubleValue];
            },
            (@{
                PROPERTY(measurementSystem, NSNumber, NSObject, NO,
                ^id(id number, __unused ORKESerializationContext *context) { return [ORKESerializerHelper ORKMeasurementSystemToString:((NSNumber *)number).integerValue]; },
                ^id(id string, __unused ORKESerializationContext *context) { return @([ORKESerializerHelper ORKMeasurementSystemFromString:string]); }),
                PROPERTY(numericPrecision, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(minimumValue, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximumValue, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKSESAnswerFormat,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                return [[ORKSESAnswerFormat alloc] init];
            },
            (@{
                PROPERTY(topRungText, NSString, NSObject, YES, nil, nil),
                PROPERTY(bottomRungText, NSString, NSObject, YES, nil, nil)
            })),
            
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
            ENTRY(ORKLocationAnswerFormat,
            ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                return [[ORKLocationAnswerFormat alloc] init];
            },
            (@{
                PROPERTY(useCurrentLocation, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(placeholder, NSString, NSObject, YES, nil, nil)
            })),
#endif
            ENTRY(ORKResult,
            nil,
            (@{
                PROPERTY(identifier, NSString, NSObject, NO, nil, nil),
                PROPERTY_TIED_TO_OTHER_PROPERTY(
                    startDate, NSDate, NSObject,
                    timeZone, NSTimeZone, NSObject,
                    YES,
                    ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                    },
                    ^id(id string, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                  dateKey:@"startDate"
                                                                              timeZoneKey:@"timeZone"];
                    }
                ),
                PROPERTY_TIED_TO_OTHER_PROPERTY(
                    endDate, NSDate, NSObject,
                    timeZone, NSTimeZone, NSObject,
                    YES,
                    ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone:timeZone];
                    },
                    ^id(id string, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                  dateKey:@"endDate"
                                                                              timeZoneKey:@"timeZone"];
                    }
                ),
                PROPERTY(userInfo, NSDictionary, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKFileResult,
            nil,
            (@{
                PROPERTY(contentType, NSString, NSObject, NO, nil, nil),
                PROPERTY(fileName, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKPasscodeResult,
            nil,
            (@{
                PROPERTY(passcodeSaved, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(touchIdEnabled, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKQuestionResult,
            nil,
            (@{
                PROPERTY(questionType, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(noAnswerType, ORKNoAnswer, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKScaleQuestionResult,
            nil,
            (@{
                PROPERTY(scaleAnswer, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKChoiceQuestionResult,
            nil,
            (@{
                PROPERTY(choiceAnswers, NSObject, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKMultipleComponentQuestionResult,
            nil,
            (@{
                PROPERTY(componentsAnswer, NSObject, NSObject, NO, nil, nil),
                PROPERTY(separator, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKBooleanQuestionResult,
            nil,
            (@{
                PROPERTY(booleanAnswer, NSNumber, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKTextQuestionResult,
            nil,
            (@{
                PROPERTY(textAnswer, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKNumericQuestionResult,
            nil,
            (@{
                PROPERTY(numericAnswer, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(unit, NSString, NSObject, NO, nil, nil),
                PROPERTY(displayUnit, NSString, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKTimeOfDayQuestionResult,
            nil,
            (@{
                PROPERTY(dateComponentsAnswer, NSDateComponents, NSObject, NO,
                ^id(id dateComponents, __unused ORKESerializationContext *context) { return ORKTimeOfDayStringFromComponents(dateComponents); },
                ^id(id string, __unused ORKESerializationContext *context) { return ORKTimeOfDayComponentsFromString(string); })
            })),
            ENTRY(ORKTimeIntervalQuestionResult,
            nil,
            (@{
                PROPERTY(intervalAnswer, NSNumber, NSObject, NO, nil, nil)
                })),
       ENTRY(ORKDateQuestionResult,
             nil,
             (@{
                PROPERTY_TIED_TO_OTHER_PROPERTY(
                    dateAnswer, NSDate, NSObject,
                    timeZone, NSTimeZone, NSObject,
                    YES,
                    ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                    },
                    ^id(id string, __unused ORKESerializationContext *context) {
                        return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                  dateKey:@"dateAnswer"
                                                                              timeZoneKey:@"timeZone"];
                    }
                ),
                PROPERTY(calendar, NSCalendar, NSObject, NO,
                     ^id(id calendar, __unused ORKESerializationContext *context) { return [(NSCalendar *)calendar calendarIdentifier]; },
                     ^id(id string, __unused ORKESerializationContext *context) { return [NSCalendar calendarWithIdentifier:string]; }),
                PROPERTY(timeZone, NSTimeZone, NSObject, NO,
                     ^id(id timeZone, __unused ORKESerializationContext *context) { return @([timeZone secondsFromGMT]); },
                     ^id(id number, __unused ORKESerializationContext *context) { return [NSTimeZone timeZoneForSecondsFromGMT:(NSInteger)((NSNumber *)number).doubleValue]; })
                })),
#if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
            ENTRY(ORKLocation,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                CLLocationCoordinate2D coordinate =  [ORKESerializerHelper coordinateFromDictionary:dict[@ESTRINGIFY(coordinate)]];
                return [[ORKLocation alloc] initWithCoordinate:coordinate
                                                        region:GETPROP(dict, region)
                                                     userInput:GETPROP(dict, userInput)
                                                 postalAddress:GETPROP(dict, postalAddress)];
            },
            (@{
                PROPERTY(userInput, NSString, NSObject, NO, nil, nil),
                PROPERTY(postalAddress, CNPostalAddress, NSObject, NO,
                ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromPostalAddress:value]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper postalAddressFromDictionary:dict]; }),
                PROPERTY(coordinate, NSValue, NSObject, NO,
                ^id(id value, __unused ORKESerializationContext *context) { return value ? [ORKESerializerHelper dictionaryFromCoordinate:((NSValue *)value).MKCoordinateValue] : nil; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithMKCoordinate:[ORKESerializerHelper coordinateFromDictionary:dict]]; }),
                PROPERTY(region, CLCircularRegion, NSObject, NO,
                ^id(id value, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromCircularRegion:(CLCircularRegion *)value]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper circularRegionFromDictionary:dict]; }),
            })),
            ENTRY(ORKLocationQuestionResult,
            nil,
            (@{
                PROPERTY(locationAnswer, ORKLocation, NSObject, NO, nil, nil)
            })),
#endif
            ENTRY(ORKSESQuestionResult,
            nil,
            (@{
                PROPERTY(rungPicked, NSNumber, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKConsentSignatureResult,
            nil,
            (@{
                PROPERTY(signature, ORKConsentSignature, NSObject, YES, nil, nil),
                PROPERTY(consented, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKSignatureResult,
            nil,
            (@{
            })),
            ENTRY(ORKCollectionResult,
            nil,
            (@{
                PROPERTY(results, ORKResult, NSArray, YES, nil, nil)
            })),
            ENTRY(ORKTaskResult,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKTaskResult alloc] initWithTaskIdentifier:GETPROP(dict, identifier) taskRunUUID:GETPROP(dict, taskRunUUID) outputDirectory:nil device:GETPROP(dict, device)];
            },
            (@{
                PROPERTY(taskRunUUID, NSUUID, NSObject, NO,
                ^id(id uuid, __unused ORKESerializationContext *context) { return [uuid UUIDString]; },
                ^id(id string, __unused ORKESerializationContext *context) { return [[NSUUID alloc] initWithUUIDString:string]; }),
                PROPERTY(device, ORKDevice, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKStepResult,
            nil,
            (@{
                PROPERTY(enabledAssistiveTechnology, NSString, NSObject, YES, nil, nil),
                PROPERTY(isPreviousResult, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKPageResult,
            nil,
            (@{
            })),
            ENTRY(ORKVideoInstructionStepResult,
            nil,
            (@{
                PROPERTY(playbackStoppedTime, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(playbackCompleted, NSNumber, NSObject, YES, nil, nil),
            })),
            ENTRY(ORKFrontFacingCameraStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKFrontFacingCameraStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(maximumRecordingLimit, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(allowsReview, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(allowsRetry, NSNumber, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKFrontFacingCameraStepResult,
            nil,
            (@{
                PROPERTY(retryCount, NSNumber, NSObject, NO, nil, nil)
            })),
            ENTRY(ORKAgeAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKAgeAnswerFormat alloc] initWithMinimumAge:((NSNumber *)GETPROP(dict, minimumAge)).integerValue
                                                           maximumAge:((NSNumber *)GETPROP(dict, maximumAge)).integerValue
                                                 minimumAgeCustomText:GETPROP(dict, minimumAgeCustomText)
                                                 maximumAgeCustomText:GETPROP(dict, maximumAgeCustomText)
                                                             showYear:((NSNumber *)GETPROP(dict, showYear)).boolValue
                                                     useYearForResult:((NSNumber *)GETPROP(dict, useYearForResult)).boolValue
                                                   treatMinAgeAsRange:((NSNumber *)GETPROP(dict, treatMinAgeAsRange)).boolValue
                                                   treatMaxAgeAsRange:((NSNumber *)GETPROP(dict, treatMaxAgeAsRange)).boolValue
                                                         defaultValue:((NSNumber *)GETPROP(dict, defaultValue)).integerValue];
            },
            (@{
                PROPERTY(minimumAge, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(maximumAge, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(minimumAgeCustomText, NSString, NSObject, YES, nil, nil),
                PROPERTY(maximumAgeCustomText, NSString, NSObject, YES, nil, nil),
                PROPERTY(showYear, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(useYearForResult, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(treatMinAgeAsRange, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(treatMaxAgeAsRange, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(relativeYear, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(defaultValue, NSNumber, NSObject, NO, nil, nil),
            })),
            ENTRY(ORKColorChoiceAnswerFormat,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKColorChoiceAnswerFormat alloc] initWithStyle:((NSNumber *)GETPROP(dict, style)).integerValue colorChoices:GETPROP(dict, colorChoices)];
            },
            (@{
                PROPERTY(style, NSNumber, NSObject, NO, NUMTOSTRINGBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable]), STRINGTONUMBLOCK([ORKESerializerHelper ORKChoiceAnswerStyleTable])),
                PROPERTY(colorChoices, ORKColorChoice, NSArray, NO, nil, nil),
            })),
            ENTRY(ORKColorChoice,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKColorChoice alloc] initWithColor:GETPROP(dict, color)
                                                        text:GETPROP(dict, text)
                                                  detailText:GETPROP(dict, detailText)
                                                       value:GETPROP(dict, value)
                                                   exclusive:((NSNumber *)GETPROP(dict, exclusive)).boolValue];
            },
            (@{
                PROPERTY(text, NSString, NSObject, NO, nil, nil),
                PROPERTY(detailText, NSString, NSObject, NO, nil, nil),
                PROPERTY(value, NSObject, NSObject, NO, nil, nil),
                PROPERTY(exclusive, NSNumber, NSObject, NO, nil, nil),
                PROPERTY(color, UIColor, NSObject, YES,
                ^id(id color, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromColor:color]; },
                ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper colorFromDictionary:dict]; })
            })),
            ENTRY(ORKRelativeGroup,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKRelativeGroup alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                               name:GETPROP(dict, name)
                                                       sectionTitle:GETPROP(dict, sectionTitle)
                                                  sectionDetailText:GETPROP(dict, sectionDetailText)
                                             identifierForCellTitle:GETPROP(dict, identifierForCellTitle)
                                                         maxAllowed:[GETPROP(dict, maxAllowed) unsignedIntegerValue]
                                                          formSteps:GETPROP(dict, formSteps)
                                              detailTextIdentifiers:GETPROP(dict, detailTextIdentifiers)];
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(name, NSString, NSObject, YES, nil, nil),
                PROPERTY(sectionTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(sectionDetailText, NSString, NSObject, YES, nil, nil),
                PROPERTY(identifierForCellTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(maxAllowed, NSNumber, NSObject, YES, nil, nil),
                PROPERTY(formSteps, ORKFormStep, NSArray, YES, nil, nil),
                PROPERTY(detailTextIdentifiers, NSString, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKHealthCondition,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKHealthCondition alloc] initWithIdentifier:GETPROP(dict, identifier) displayName:GETPROP(dict, displayName) value:GETPROP(dict, value)];
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(displayName, NSString, NSObject, YES, nil, nil),
                PROPERTY(value, NSObject, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKRelatedPerson,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKRelatedPerson alloc] initWithIdentifier:GETPROP(dict, identifier) groupIdentifier:GETPROP(dict, groupIdentifier) identifierForCellTitle:GETPROP(dict, identifierForCellTitle) taskResult:GETPROP(dict, taskResult)];
            },
            (@{
                PROPERTY(identifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(groupIdentifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(identifierForCellTitle, NSString, NSObject, YES, nil, nil),
                PROPERTY(taskResult, ORKTaskResult, NSObject, YES, nil, nil)
            })),
            ENTRY(ORKFamilyHistoryResult,
            nil,
            (@{
                PROPERTY(relatedPersons, ORKRelatedPerson, NSArray, YES, nil, nil),
                PROPERTY(displayedConditions, NSString, NSArray, YES, nil, nil)
            })),
            ENTRY(ORKConditionStepConfiguration,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKConditionStepConfiguration alloc] initWithStepIdentifier:GETPROP(dict, stepIdentifier) conditionsFormItemIdentifier:GETPROP(dict, conditionsFormItemIdentifier) conditions:GETPROP(dict, conditions) formItems:GETPROP(dict, formItems)];
            },
            (@{
                PROPERTY(stepIdentifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(conditionsFormItemIdentifier, NSString, NSObject, YES, nil, nil),
                PROPERTY(conditions, ORKHealthCondition, NSArray, YES, nil, nil),
                PROPERTY(formItems, ORKFormItem, NSArray, YES, nil, nil)
            })),
            ENTRY(ORKFamilyHistoryStep,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKFamilyHistoryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
            (@{
                PROPERTY(conditionStepConfiguration, ORKConditionStepConfiguration, NSObject, YES, nil, nil),
                PROPERTY(relativeGroups, ORKRelativeGroup, NSArray, YES, nil, nil),
            })),
            ENTRY(ORKDevice, ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
            return [[ORKDevice alloc] initWithProduct:GETPROP(dict, product)
                                            osVersion:GETPROP(dict, osVersion)
                                              osBuild:GETPROP(dict, osBuild)
                                             platform:GETPROP(dict, platform)
                                   researchKitVersion:GETPROP(dict, researchKitVersion)
                             researchKitBundleVersion:GETPROP(dict, researchKitBundleVersion)];},
            (@{
                PROPERTY(product, NSString, NSObject, NO, nil, nil),
                PROPERTY(osVersion, NSString, NSObject, NO, nil, nil),
                PROPERTY(osBuild, NSString, NSObject, NO, nil, nil),
                PROPERTY(platform, NSString, NSObject, NO, nil, nil),
                PROPERTY(researchKitVersion, NSString, NSObject, NO, nil, nil),
                PROPERTY(researchKitBundleVersion, NSString, NSObject, NO, nil, nil)
            })),
        } mutableCopy];
    });
    
    return internalEncodingTable;
}

@end

