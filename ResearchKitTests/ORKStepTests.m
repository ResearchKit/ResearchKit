/*
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
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


@import XCTest;
@import ResearchKit;
@import ResearchKit.Private;
@import UIKit;

@interface ORKStepTests : XCTestCase

@end

@implementation ORKStepTests

- (void)testAttributes {
    ORKStep *step = [[ORKStep alloc] initWithIdentifier:@"STEP"];
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:@"TASK" steps:NULL];
    ORKResult *result = [[ORKResult alloc] initWithIdentifier:@"RESULT"];
    
    [step setTitle:@"Title"];
    [step setText:@"Text"];
    [step setTask:task];
    step.showsProgress = NO;
    [step setDetailText:@"DETAIL"];
    [step setFootnote:@"FOOTNOTE"];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.researchkit.ResearchKit"];
    UIImage *imageOne = [UIImage imageNamed:@"heart-fitness" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *imageTwo = [UIImage imageNamed:@"phoneshake" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *imageThree = [UIImage imageNamed:@"heartbeat" inBundle:bundle compatibleWithTraitCollection:nil];
    [step setImage:imageOne];
    [step setAuxiliaryImage:imageTwo];
    [step setIconImage:imageThree];
    
    ORKStepViewController *controller = [step instantiateStepViewControllerWithResult:result];
    
    XCTAssertEqual([step title], @"Title");
    XCTAssertEqual([step text], @"Text");
    XCTAssertEqual([step task], task);
    XCTAssertEqual([controller restorationIdentifier], [step identifier]);
    XCTAssertEqual([controller restorationClass], [step stepViewControllerClass]);
    XCTAssertEqual([controller step], step);
    XCTAssertEqual([step stepViewControllerClass], [ORKStepViewController class]);
    XCTAssertEqual([step isRestorable], YES);
    XCTAssertEqual([step showsProgress], NO);
    XCTAssert([step.identifier isEqualToString:@"STEP"]);
    XCTAssert([step isEqual:step]);
    XCTAssertFalse([step isEqual:@"TEST"]);
    XCTAssertEqual([step requestedPermissions], ORKPermissionNone);
    XCTAssertEqualObjects([step requestedHealthKitTypesForReading], nil);
}

- (void)testCopyWithIdentifier {
    NSString *firstIdentifier = @"STEP";
    ORKStep *step = [[ORKStep alloc] initWithIdentifier:firstIdentifier];
    step.title = @"TITLE";
    step.text = @"TEXT";
    
    XCTAssertEqual(step.identifier, firstIdentifier);
    
    NSString *newIdentifier = @"NEW STEP";
    ORKStep *newStep = [step copyWithIdentifier:newIdentifier];
    
    XCTAssertEqual(newStep.identifier, newIdentifier);
    XCTAssertEqual(newStep.title, @"TITLE");
    XCTAssertEqual(newStep.text, @"TEXT");
}

- (void) testCopyWithZone {
    ORKStep *step = [[ORKStep alloc] initWithIdentifier:@"STEP"];
    ORKStep *newStep = [step copyWithZone:nil];
    XCTAssert([newStep isEqual:step]);
}

@end

@interface ORKInstructionStepTests : XCTestCase

@end

@implementation ORKInstructionStepTests

- (void)testAttributes {
    ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"step"];
    
    [step setDetailText:@"DETAILS"];
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:@"ATTRIBUTE"];
    [step setAttributedDetailText:attributeString];
    [step setFootnote:@"FOOTNOTE"];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.researchkit.ResearchKit"];
    UIImage *image = [UIImage imageNamed:@"heartbeat" inBundle:bundle compatibleWithTraitCollection:nil];
    [step setImage:image];
    [step setAuxiliaryImage:image];
    [step setIconImage:image];
    
    XCTAssert([step.detailText isEqualToString:@"DETAILS"]);
    XCTAssertEqual(step.attributedDetailText, attributeString);
    XCTAssert([step.footnote isEqualToString:@"FOOTNOTE"]);
    XCTAssertEqual([step image], image);
    XCTAssertEqual([step auxiliaryImage], image);
    XCTAssertEqual([step iconImage], image);
}

@end


@interface ORKFormStepTests : XCTestCase

@end

@implementation ORKFormStepTests

- (void)testAttributes {
    // Test duplicate form step identifier validation
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"form" title:@"Form" text:@"Form test"];
    NSMutableArray *items = [NSMutableArray new];
    
    ORKFormItem *item = nil;
    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem1"
                                              text:@"formItem1"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];
    
    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem2"
                                              text:@"formItem2"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];
    
    [formStep setFormItems:items];
    XCTAssertNoThrow([formStep validateParameters]);
    
    item = [[ORKFormItem alloc] initWithIdentifier:@"formItem2"
                                              text:@"formItem2"
                                      answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
    [items addObject:item];
    
    item = [[ORKFormItem alloc] initWithSectionTitle:@"formItem3"
                                          detailText:@"formItem3"
                                       learnMoreItem:[ORKLearnMoreItem learnMoreItemWithText:@"learnMoreItemText" learnMoreInstructionStep:[[ORKLearnMoreInstructionStep alloc] initWithIdentifier:@"instructionStepIdentifier"]]
                                       showsProgress:YES];
    [items addObject:item];
    
    XCTAssertEqual(item.text, @"formItem3");
    XCTAssertEqual(item.detailText, @"formItem3");
    XCTAssertNotNil(item.detailText);
    XCTAssertNotNil(item.learnMoreItem);
    XCTAssertTrue(item.showsProgress);
    
    item = [[ORKFormItem alloc] initWithSectionTitle:nil
                                          detailText:nil
                                       learnMoreItem:nil
                                       showsProgress:NO];
    [items addObject:item];
    
    XCTAssertNil(item.text);
    XCTAssertNil(item.detailText);
    XCTAssertNil(item.learnMoreItem);
    XCTAssertFalse(item.showsProgress);
    
    [formStep setFormItems:items];
    XCTAssertThrows([formStep validateParameters]);
}

@end

@interface ORKReactionTimeStepTests : XCTestCase

@end

@implementation ORKReactionTimeStepTests

- (void)testAttributes {
    ORKReactionTimeStep *validReactionTimeStep = [[ORKReactionTimeStep alloc] initWithIdentifier:@"ReactionTimeStep"];
    
    validReactionTimeStep.maximumStimulusInterval = 8;
    validReactionTimeStep.minimumStimulusInterval = 4;
    validReactionTimeStep.thresholdAcceleration = 0.5;
    validReactionTimeStep.numberOfAttempts = 3;
    validReactionTimeStep.timeout = 10;
    
    XCTAssertNoThrow([validReactionTimeStep validateParameters]);
    
    ORKReactionTimeStep *reactionTimeStep = [validReactionTimeStep copy];
    XCTAssertEqualObjects(reactionTimeStep, validReactionTimeStep);
    
    // minimumStimulusInterval cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.minimumStimulusInterval = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
    
    // minimumStimulusInterval cannot be higher than maximumStimulusInterval
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.maximumStimulusInterval = 8;
    validReactionTimeStep.minimumStimulusInterval = 10;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
    
    // thresholdAcceleration cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.thresholdAcceleration = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
    
    // timeout cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.timeout = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
    
    // numberOfAttempts cannot be zero or less
    reactionTimeStep = [validReactionTimeStep copy];
    validReactionTimeStep.numberOfAttempts = 0;
    XCTAssertThrows([validReactionTimeStep validateParameters]);
}

@end

@interface ORKPageStepTests : XCTestCase

@end

@implementation ORKPageStepTests

- (void)testAttributes {
    
    NSArray *steps = @[[[ORKStep alloc] initWithIdentifier:@"step1"],
                       [[ORKStep alloc] initWithIdentifier:@"step2"],
                       [[ORKStep alloc] initWithIdentifier:@"step3"],
                       ];
    ORKPageStep *pageStep = [[ORKPageStep alloc] initWithIdentifier:@"pageStep" steps:steps];
    
    ORKChoiceQuestionResult *step1Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result1"];
    step1Result1.choiceAnswers = @[ @(1) ];
    ORKChoiceQuestionResult *step1Result2 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step1.result2"];
    step1Result2.choiceAnswers = @[ @(2) ];
    ORKChoiceQuestionResult *step2Result1 = [[ORKChoiceQuestionResult alloc] initWithIdentifier:@"step2.result1"];
    step2Result1.choiceAnswers = @[ @(3) ];
    
    ORKStepResult *inputResult = [[ORKStepResult alloc] initWithStepIdentifier:@"pageStep"
                                                                       results:@[step1Result1, step1Result2, step2Result1]];
    
    ORKPageResult *pageResult = [[ORKPageResult alloc] initWithPageStep:pageStep stepResult:inputResult];
    
    // Check steps going forward
    ORKStep *step1 = [pageStep stepAfterStepWithIdentifier:nil withResult:pageResult];
    XCTAssertNotNil(step1);
    XCTAssertEqualObjects(step1.identifier, @"step1");
    
    ORKStep *step2 = [pageStep stepAfterStepWithIdentifier:@"step1" withResult:pageResult];
    XCTAssertNotNil(step2);
    XCTAssertEqualObjects(step2.identifier, @"step2");
    
    ORKStep *step3 = [pageStep stepAfterStepWithIdentifier:@"step2" withResult:pageResult];
    XCTAssertNotNil(step3);
    XCTAssertEqualObjects(step3.identifier, @"step3");
    
    ORKStep *step4 = [pageStep stepAfterStepWithIdentifier:@"step3" withResult:pageResult];
    XCTAssertNil(step4);
    
    // Check steps going backward
    ORKStep *backStep2 = [pageStep stepBeforeStepWithIdentifier:@"step3" withResult:pageResult];
    XCTAssertEqualObjects(backStep2, step2);
    
    ORKStep *backStep1 = [pageStep stepBeforeStepWithIdentifier:@"step2" withResult:pageResult];
    XCTAssertEqualObjects(backStep1, step1);
    
    ORKStep *backStepNil = [pageStep stepBeforeStepWithIdentifier:@"step1" withResult:pageResult];
    XCTAssertNil(backStepNil);
    
    // Check identifier
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step1"], step1);
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step2"], step2);
    XCTAssertEqualObjects([pageStep stepWithIdentifier:@"step3"], step3);
}
@end

@interface ORKNavigablePageStepTests : XCTestCase

@end

@implementation ORKNavigablePageStepTests

- (void)testAttributes {
    ORKQuestionStep *stepOne = [ORKQuestionStep questionStepWithIdentifier:@"stepOne"
                                                                     title:@"QUESTION"
                                                                  question:@"Which step do we go to?"
                                                                    answer:[ORKAnswerFormat booleanAnswerFormat]];
    
    ORKStep *stepTwo = [[ORKStep alloc] initWithIdentifier:@"stepTwo"];
    ORKStep *stepThree = [[ORKStep alloc] initWithIdentifier:@"stepThree"];
    ORKStep *stepFour = [[ORKStep alloc] initWithIdentifier:@"stepFour"];
    
    NSArray *steps = [NSArray arrayWithObjects:stepOne, stepTwo, stepThree, stepFour, nil];
    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:@"task" steps:steps];
    
    ORKBooleanQuestionResult *result = [[ORKBooleanQuestionResult alloc] initWithIdentifier:@"stepOne.result"];
    result.booleanAnswer = @(YES);
    
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"stepOne" results:@[result]];
    
    ORKTaskResult *taskResult = [[ORKTaskResult alloc] initWithTaskIdentifier:@"task" taskRunUUID:[NSUUID UUID] outputDirectory:nil];
    taskResult.results = @[stepResult];
    
    // Creating predicates
    ORKResultSelector *resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"stepOne" resultIdentifier:@"stepOne.result"];
    NSPredicate *stepOneYes = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:YES];
    NSPredicate *stepOneNo = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector expectedAnswer:NO];
    
    // Creating navigation rule and setting it to task
    ORKStepNavigationRule *navigationRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[stepOneYes, stepOneNo]
                                                                                  destinationStepIdentifiers:@[@"stepTwo", @"stepThree"]
                                                                                       defaultStepIdentifier:@"stepFour"];
    [task setNavigationRule:navigationRule forTriggerStepIdentifier:@"stepOne"];
    ORKNavigablePageStep *pageStep = [[ORKNavigablePageStep alloc] initWithIdentifier:@"pageStep" pageTask:task];
    
    // Check step if answer is YES
    ORKStep *nextStep = [pageStep stepAfterStepWithIdentifier:@"stepOne" withResult:taskResult];
    XCTAssert([nextStep.identifier isEqualToString:@"stepTwo"]);
    
    // Check step if answer is NO
    result.booleanAnswer = @(NO);
    stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"stepOne" results:@[result]];
    taskResult.results = @[stepResult];
    nextStep = [pageStep stepAfterStepWithIdentifier:@"stepOne" withResult:taskResult];
    XCTAssert([nextStep.identifier isEqualToString:@"stepThree"]);
    
    // Check step if answer is NULL
    result.booleanAnswer = NULL;
    stepResult = [[ORKStepResult alloc] initWithStepIdentifier:@"stepOne" results:@[result]];
    taskResult.results = @[stepResult];
    nextStep = [pageStep stepAfterStepWithIdentifier:@"stepOne" withResult:taskResult];
    XCTAssert([nextStep.identifier isEqualToString:@"stepFour"]);
    
}

@end

@interface ORKPasscodeStepTests : XCTestCase

@end

@implementation ORKPasscodeStepTests

- (void)testAttributes {
    
    ORKPasscodeStep *step = [ORKPasscodeStep passcodeStepWithIdentifier:@"STEP" passcodeFlow:ORKPasscodeFlowAuthenticate];
    XCTAssert([step.identifier isEqualToString:@"STEP"]);
    XCTAssertEqual(step.passcodeFlow, ORKPasscodeFlowAuthenticate);
    XCTAssertEqual(step.passcodeType, ORKPasscodeType4Digit);
}

@end

@interface ORKQuestionStepTests : XCTestCase

@end

@implementation ORKQuestionStepTests

- (void)testAttributes {
    NSString *identifier = @"Identifier";
    NSString *title = @"Title";
    NSString *question = @"How are you?";
    NSString *errorMessage = @"ERROR";
    NSString *placeHolder = @"PLACEHOLDER";
    
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormatWithMaximumLength:100];
    ORKConfirmTextAnswerFormat *incorrectAnswerFormat = [[ORKConfirmTextAnswerFormat alloc] initWithOriginalItemIdentifier:identifier errorMessage:errorMessage];
    ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:identifier title:title question:question answer:answerFormat];
    [step setPlaceholder:placeHolder];
    [step setUseSurveyMode: NO];
    [step setUseCardView: NO];
    [step setOptional:NO];
    
    XCTAssertEqual([step identifier], identifier);
    XCTAssertEqual([step title], title);
    XCTAssertEqual([step question], question);
    XCTAssertEqual([step placeholder], placeHolder);
    XCTAssertEqual([step useSurveyMode], NO);
    XCTAssertEqual([step useCardView], NO);
    XCTAssertEqual([step isOptional], NO);
    XCTAssertNoThrowSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException, @"Should not throw exception");
    XCTAssertEqual([step requestedHealthKitTypesForReading], nil);
    XCTAssertEqual([step stepViewControllerClass], [ORKQuestionStepViewController class], @"Should return ORKQuestionStepViewController");
    XCTAssert([step isEqual:step]);
    XCTAssertEqual([step questionType], ORKQuestionTypeText, @"Should return ORKQuestionTypeText");
    
    ORKQuestionStep *incorrectStep = [ORKQuestionStep questionStepWithIdentifier:identifier title:title question:question answer:incorrectAnswerFormat];
    XCTAssertThrowsSpecificNamed([incorrectStep validateParameters], NSException, NSInvalidArgumentException);
}

@end

@interface ORKPDFViewerStepTests : XCTestCase

@end

@implementation ORKPDFViewerStepTests

- (void)testAttributes {
    NSString *identifier = @"STEP";
    NSURL *url = [NSURL URLWithString:@"TESTINGURL"];
    
    ORKPDFViewerStep *step = [[ORKPDFViewerStep alloc] initWithIdentifier:identifier pdfURL:url];
    step.actionBarOption = ORKPDFViewerActionBarOptionExcludeShare;
    
    XCTAssertEqual([step identifier], identifier);
    XCTAssertEqual([step pdfURL], url);
    XCTAssertEqual([step actionBarOption], ORKPDFViewerActionBarOptionExcludeShare);
}

@end

@interface ORKRegistrationStepTests : XCTestCase

@end

@implementation ORKRegistrationStepTests

- (void)testAttributes {
    NSString *identifier = @"STEP";
    NSString *title = @"TITLE";
    NSString *text = @"TEXT";
    
    NSString *pattern = @"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{4,8}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    ORKRegistrationStep *step = [[ORKRegistrationStep alloc] initWithIdentifier:identifier title:title text:text passcodeValidationRegularExpression:regex passcodeInvalidMessage:@"Invalid Password" options:ORKRegistrationStepIncludePhoneNumber];
    step.phoneNumberValidationRegularExpression = regex;
    step.phoneNumberInvalidMessage = @"Invalid Number";
    
    XCTAssertEqual([step identifier], identifier);
    XCTAssertEqual([step title], title);
    XCTAssertEqual([step text], text);
    XCTAssertEqual([step options], ORKRegistrationStepIncludePhoneNumber);
    XCTAssertEqual([step passcodeValidationRegularExpression], regex);
    XCTAssertEqual([step passcodeInvalidMessage], @"Invalid Password");
    XCTAssertEqual([step phoneNumberValidationRegularExpression], regex);
    XCTAssertEqual([step phoneNumberInvalidMessage], @"Invalid Number");
    XCTAssert([[[[step formItems] objectAtIndex:0] identifier] isEqualToString:@"ORKRegistrationFormItemEmail"]);
    XCTAssert([[[[step formItems] objectAtIndex:1] identifier] isEqualToString:@"ORKRegistrationFormItemPassword"]);
    XCTAssert([[[[step formItems] objectAtIndex:2] identifier] isEqualToString:@"ORKRegistrationFormItemConfirmPassword"]);
}

@end

@interface ORKWebViewStepTests: XCTestCase

@end

@implementation ORKWebViewStepTests

- (void)testAttributes {
    NSString *identifier = @"STEP";
    NSString *html = @"HTML";
    ORKWebViewStep *step = [ORKWebViewStep webViewStepWithIdentifier:identifier html:html];
    step.customCSS = @"body { font-size: 12px; }";
    
    XCTAssertEqual([step identifier], identifier);
    XCTAssertEqual([step html], html);
    XCTAssertEqual([step stepViewControllerClass], [ORKWebViewStepViewController class]);
    XCTAssert([step isEqual:step]);
    
    [step setHtml:nil];
    XCTAssertThrowsSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException);
}

@end

@interface ORKLearnMoreInstructionStepTests : XCTestCase

@end

@implementation ORKLearnMoreInstructionStepTests

- (void)testAttributes {
    NSString *identifier = @"STEP";
    ORKLearnMoreInstructionStep *step = [[ORKLearnMoreInstructionStep alloc] initWithIdentifier:identifier];

    XCTAssertEqual([step identifier], identifier);
}

@end

@interface ORKEnvironmentSPLMeterStepTests : XCTestCase

@end

@implementation ORKEnvironmentSPLMeterStepTests

- (void)testAttributes {
    NSString *identifier = @"STEP";
    ORKEnvironmentSPLMeterStep *step = [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:identifier];
    
    XCTAssertEqual([step identifier], identifier);
    XCTAssertNoThrow([step validateParameters]);
    XCTAssertEqual([step thresholdValue], 35.0);
    XCTAssertEqual([step samplingInterval], 1.0);
    XCTAssertEqual([step requiredContiguousSamples], 5);
    
    [step setThresholdValue:-1];
    XCTAssertThrowsSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException);
    
    [step setSamplingInterval:-1];
    [step setThresholdValue:0];
    XCTAssertThrowsSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException);
    
    [step setRequiredContiguousSamples:0];
    [step setThresholdValue:2];
    XCTAssertThrowsSpecificNamed([step validateParameters], NSException, NSInvalidArgumentException);
    
    XCTAssert([step isEqual:step]);
}

@end

@interface ORKAudioFitnessStepTests : XCTestCase

@end

@implementation ORKAudioFitnessStepTests

- (void)testAttributes {

    NSString *identifier = @"abc";
    NSString *bundleID = @"com.fake.bundle";
    NSString *name = @"song";
    NSString *extension = @".mp3";

    ORKBundleAsset *audio = [[ORKBundleAsset alloc] initWithName:name
                                                bundleIdentifier:bundleID
                                                   fileExtension:extension];

    ORKAudioFitnessStep *step = [[ORKAudioFitnessStep alloc] initWithIdentifier:identifier
                                                                     audioAsset:audio
                                                                      vocalCues:nil];
    XCTAssertEqual(step.identifier, identifier);
    XCTAssertEqual(step.audioAsset.bundleIdentifier, bundleID);
    XCTAssertEqual(step.audioAsset.name, name);
    XCTAssertEqual(step.audioAsset.fileExtension, extension);
    XCTAssertEqual(step.stepDuration, 180);
    XCTAssertEqual(step.shouldShowDefaultTimer, NO);
    XCTAssertEqual(step.vocalCues.count, 0);
    XCTAssert([step isEqual:step]);
}

@end
