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


@import XCTest;
@import ResearchKit.Private;


@interface ORKAnswerFormatTests : XCTestCase

@end

@protocol ORKComfirmAnswerFormat_Private <NSObject>

@property (nonatomic, copy, readonly) NSString *originalItemIdentifier;
@property (nonatomic, copy, readonly) NSString *errorMessage;

@end


@implementation ORKAnswerFormatTests

- (void)testValidEmailAnswerFormat {
    // Test email regular expression validation with correct input.
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some.one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone@researchkit.org.uk"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some_one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"some-one@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"someone1@researchkit.org"]);
    XCTAssert([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"Someone1@ResearchKit.org"]);
}

- (void)testInvalidEmailAnswerFormat {
    // Test email regular expression validation with incorrect input.
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@researchkit"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"emailtest@.org"]);
    XCTAssertFalse([[ORKEmailAnswerFormat emailAnswerFormat] isAnswerValidWithString:@"12345"]);
}

- (void)testInvalidRegularExpressionAnswerFormat {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    answerFormat.keyboardType = UIKeyboardTypeASCIICapable;
    NSRegularExpression *validationRegularExpression =
    [NSRegularExpression regularExpressionWithPattern:@"^[A-F,0-9]+$"
                                              options:(NSRegularExpressionOptions)0
                                                error:nil];
    answerFormat.validationRegularExpression = validationRegularExpression;
    answerFormat.invalidMessage = @"Only hexidecimal values in uppercase letters are accepted.";
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    XCTAssertFalse([answerFormat isAnswerValidWithString:@"Q2"]);
    XCTAssertFalse([answerFormat isAnswerValidWithString:@"abcd"]);
    XCTAssertTrue([answerFormat isAnswerValidWithString:@"ABCD1234FFED0987654321"]);
}

- (void)testConfirmAnswerFormat {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    answerFormat.secureTextEntry = YES;
    answerFormat.keyboardType = UIKeyboardTypeASCIICapable;
    if (@available(iOS 12.0, *)) {
        answerFormat.textContentType = UITextContentTypeNewPassword;
    } else {
        answerFormat.textContentType = UITextContentTypePassword;
    }
    answerFormat.maximumLength = 12;
    NSRegularExpression *validationRegularExpression =
    [NSRegularExpression regularExpressionWithPattern:@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{10,}"
                                              options:(NSRegularExpressionOptions)0
                                                error:nil];
    answerFormat.validationRegularExpression = validationRegularExpression;
    answerFormat.invalidMessage = @"Invalid password";
    answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    
    // Note: setting these up incorrectly for a password to test that the values are *not* copied.
    // DO NOT setup a real password field with these options.
    answerFormat.autocorrectionType = UITextAutocorrectionTypeDefault;
    answerFormat.spellCheckingType = UITextSpellCheckingTypeDefault;
    
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:NO];
    
    // -- method under test
    ORKFormItem *confirmItem = [item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                                         text:@"enter again"
                                                                 errorMessage:@"doesn't match"];
    
    XCTAssertEqualObjects(confirmItem.identifier, @"bar");
    XCTAssertEqualObjects(confirmItem.text, @"enter again");
    XCTAssertFalse(confirmItem.optional);
    
    // Inspect the answer format
    ORKAnswerFormat *confirmFormat = confirmItem.answerFormat;
    
    // ORKAnswerFormat that is returned should be a subclass of ORKTextAnswerFormat.
    // The actual subclass that is returned is private to the API and should not be accessed directly.
    XCTAssertNotNil(confirmFormat);
    XCTAssertTrue([confirmFormat isKindOfClass:[ORKTextAnswerFormat class]]);
    if (![confirmFormat isKindOfClass:[ORKTextAnswerFormat class]]) { return; }
    
    ORKTextAnswerFormat *confirmAnswer = (ORKTextAnswerFormat*)confirmFormat;
    
    // These properties should match the original format
    XCTAssertFalse(confirmAnswer.multipleLines);
    XCTAssertTrue(confirmAnswer.secureTextEntry);
    XCTAssertEqual(confirmAnswer.keyboardType, UIKeyboardTypeASCIICapable);
    if (@available(iOS 12.0, *)) {
        XCTAssertEqual(confirmAnswer.textContentType, UITextContentTypeNewPassword);
    } else {
        XCTAssertEqual(confirmAnswer.textContentType, UITextContentTypePassword);
    }
    XCTAssertEqual(confirmAnswer.maximumLength, 12);
    
    // This property should match the input answer format so that cases that
    // require all-upper or all-lower (for whatever reason) can be met.
    XCTAssertEqual(confirmAnswer.autocapitalizationType, UITextAutocapitalizationTypeAllCharacters);
    
    // These properties should always be set to not autocorrect
    XCTAssertEqual(confirmAnswer.autocorrectionType, UITextAutocorrectionTypeNo);
    XCTAssertEqual(confirmAnswer.spellCheckingType, UITextSpellCheckingTypeNo);
    
    // These properties should be nil
    XCTAssertNil(confirmAnswer.validationRegularExpression);
    XCTAssertNil(confirmAnswer.invalidMessage);
    
    // Check that the confirmation answer format responds to the internal methods
    XCTAssertTrue([confirmFormat respondsToSelector:@selector(originalItemIdentifier)]);
    XCTAssertTrue([confirmFormat respondsToSelector:@selector(errorMessage)]);
    if (![confirmFormat respondsToSelector:@selector(originalItemIdentifier)] ||
        ![confirmFormat respondsToSelector:@selector(errorMessage)]) {
        return;
    }
    
    NSString *originalItemIdentifier = [(id)confirmFormat originalItemIdentifier];
    XCTAssertEqualObjects(originalItemIdentifier, @"foo");
    
    NSString *errorMessage = [(id)confirmFormat errorMessage];
    XCTAssertEqualObjects(errorMessage, @"doesn't match");
    
}

- (void)testConfirmAnswerFormat_Optional_YES {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = NO;
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:YES];
    
    // -- method under test
    ORKFormItem *confirmItem = [item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                                         text:@"enter again"
                                                                 errorMessage:@"doesn't match"];
    
    // Check that the confirm item optional value matches the input item
    XCTAssertTrue(confirmItem.optional);
    
}

- (void)testConfirmAnswerFormat_MultipleLines_YES {
    
    // Setup an answer format
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
    answerFormat.multipleLines = YES;
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo" text:@"enter value" answerFormat:answerFormat optional:YES];
    
    // -- method under test
    XCTAssertThrows([item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                              text:@"enter again"
                                                      errorMessage:@"doesn't match"]);
    
}

- (void)testContinuousScaleAnswerFormat {
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max < min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10001
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max > effectiveUpperBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:100
                                                                                 minimumValue:-10001
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since min < effectiveLowerBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since max < min");
    
    
    ORKContinuousScaleAnswerFormat *answerFormat = [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1
                                                                                                   minimumValue:0
                                                                                                   defaultValue:10
                                                                                          maximumFractionDigits:10
                                                                                                       vertical:YES
                                                                                        maximumValueDescription:NULL
                                                                                        minimumValueDescription:NULL];
    
    XCTAssertEqual([answerFormat maximum], 1);
    XCTAssertEqual([answerFormat minimum], 0);
    XCTAssertEqual([answerFormat defaultValue], 10);
    XCTAssertEqual([answerFormat maximumFractionDigits], 4, @"Should return 4 since the maximumFractionDigits needs to 0 <= maximumFractionDigits <= 4");
    XCTAssertEqual([answerFormat isVertical], YES);
    XCTAssertEqual([answerFormat maximumValueDescription], NULL);
    XCTAssertEqual([answerFormat minimumValueDescription], NULL);
    
     ORKContinuousScaleAnswerFormat *answerFormatTwo = [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1
                                                                                                       minimumValue:0
                                                                                                       defaultValue:10
                                                                                              maximumFractionDigits:-1
                                                                                                           vertical:YES
                                                                                            maximumValueDescription:NULL
                                                                                            minimumValueDescription:NULL];
    
    XCTAssertEqual([answerFormatTwo maximumFractionDigits], 0, @"Should return 0 since the maximumFractionDigits needs to 0 <= maximumFractionDigits <= 4");
    
}

- (void)testScaleAnswerFormat {
    
    ORKScaleAnswerFormat *answerFormat = [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                               minimumValue:0
                                                                               defaultValue:10
                                                                                       step:10
                                                                                   vertical:YES
                                                                    maximumValueDescription:@"MAX"
                                                                    minimumValueDescription:@"MIN"];
    
    XCTAssertEqual([answerFormat maximum], 100);
    XCTAssertEqual([answerFormat minimum], 0);
    XCTAssertEqual([answerFormat defaultValue], 10);
    XCTAssertEqual([answerFormat step], 10);
    XCTAssertEqual([answerFormat isVertical], YES);
    XCTAssertEqual([answerFormat maximumValueDescription], @"MAX");
    XCTAssertEqual([answerFormat minimumValueDescription], @"MIN");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:25
                                                                       minimumValue:50
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since max < min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:10
                                                                       defaultValue:200
                                                                               step:0
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step < 1");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:3
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step is not divisible by the difference of max and min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:25
                                                                       minimumValue:-20000
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since min < -10000");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:20000
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:10
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since max > 10000");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:0
                                                                       defaultValue:10
                                                                               step:1
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step count > 13");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat scaleAnswerFormatWithMaximumValue:100
                                                                       minimumValue:100
                                                                       defaultValue:10
                                                                               step:1
                                                                           vertical:YES
                                                            maximumValueDescription:NULL
                                                            minimumValueDescription:NULL],
                                 NSException, NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step count < 1");
    
}

- (void)testTextScaleAnswerFormat {

    ORKTextChoice *choiceOne = [ORKTextChoice choiceWithText:@"Choice One" value:[NSNumber numberWithInteger:1]];
    ORKTextChoice *choiceTwo = [ORKTextChoice choiceWithText:@"Choice Two" value:[NSNumber numberWithInteger:2]];
    NSArray *choices = [NSArray arrayWithObjects:choiceOne, choiceTwo, nil];
    ORKTextScaleAnswerFormat *answerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:choices defaultIndex:0 vertical:YES];
    
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:0] value],[NSNumber numberWithInteger:1]);
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:1] value],[NSNumber numberWithInteger:2]);
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:0] text], @"Choice One");
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:1] text], @"Choice Two");
    XCTAssertEqual([answerFormat defaultIndex], 0);
    XCTAssertEqual([answerFormat isVertical], YES);
    
}

- (void)testTimeOfDayAnswerFormat {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = 01;
    dateComponents.day = 24;
    dateComponents.year = 1984;
    
    ORKTimeOfDayAnswerFormat *answerFormat = [ORKAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:dateComponents];
    
    XCTAssertEqual([[answerFormat defaultComponents] month], 01);
    XCTAssertEqual([[answerFormat defaultComponents] day], 24);
    XCTAssertEqual([[answerFormat defaultComponents] year], 1984);
}

- (void)testNumericAnswerFormat {
    
    ORKNumericAnswerFormat *answerFormatWithIntegerStyle = [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger
                                                                                                    unit:@"Units"
                                                                                                 minimum:[NSNumber numberWithInteger:0]
                                                                                                 maximum:[NSNumber numberWithInteger:100]
                                                                                   maximumFractionDigits:@(0)];
    
    XCTAssertEqual([answerFormatWithIntegerStyle style], ORKNumericAnswerStyleInteger);
    XCTAssertEqual([answerFormatWithIntegerStyle unit], @"Units");
    XCTAssertEqual([answerFormatWithIntegerStyle minimum], [NSNumber numberWithInteger:0]);
    XCTAssertEqual([answerFormatWithIntegerStyle maximum], [NSNumber numberWithInteger:100]);
    XCTAssertEqual([answerFormatWithIntegerStyle maximumFractionDigits], @(0));
    
    
    ORKNumericAnswerFormat *answerFormatWithDecimalStyle = [[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleDecimal];
    XCTAssertEqual([answerFormatWithDecimalStyle style ], ORKNumericAnswerStyleDecimal);
    
    XCTAssertThrowsSpecificNamed([[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger
                                                                          unit:@"Integers"
                                                                       minimum:[NSNumber numberWithInteger:100]
                                                                       maximum:[NSNumber numberWithInteger:0]], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since max < min");
    
    
    XCTAssertThrowsSpecificNamed([[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleDecimal
                                                                          unit:@"Doubles"
                                                                       minimum:[NSNumber numberWithDouble:10.2]
                                                                       maximum:[NSNumber numberWithDouble:10]], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since max < min");
    
    XCTAssertNoThrowSpecificNamed([[ORKNumericAnswerFormat alloc] initWithStyle:ORKNumericAnswerStyleInteger
                                                                           unit:@"Integers"
                                                                        minimum:NULL
                                                                        maximum:NULL],
                                  NSException, NSInvalidArgumentException,
                                  @"Should not throw exception for null values");
}

- (void)testBooleanAnswerFormat {
    ORKBooleanAnswerFormat *answerFormat = [ORKAnswerFormat booleanAnswerFormatWithYesString:@"YES" noString:@"NO"];
    XCTAssertEqual([answerFormat yes], @"YES");
    XCTAssertEqual([answerFormat no], @"NO");
}

- (void)testHeightAnswerFormat {
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    XCTAssert([answerFormat measurementSystem] == ORKMeasurementSystemMetric);
}

- (void)testTimeIntervalAnswerFormat {
    NSTimeInterval defaultTimeInterval = 40;
    
    ORKTimeIntervalAnswerFormat *answerFormat = [ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:defaultTimeInterval
                                                                                                        step:1];
    
    XCTAssertEqual([answerFormat defaultInterval], defaultTimeInterval);
    XCTAssertEqual([answerFormat step], 1);
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:defaultTimeInterval step:-1],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step is lower than the recommended minimuim: 0");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:defaultTimeInterval step:31],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since step is lower than the recommended maximum: 30");
}
- (void)testImageChoiceAnswerFormat {
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"org.researchkit.ResearchKit"];
    
    UIImage *imageOne = [UIImage imageNamed:@"heart-fitness" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *imageTwo = [UIImage imageNamed:@"phoneshake" inBundle:bundle compatibleWithTraitCollection:nil];
    
    ORKImageChoice *choiceOne = [ORKImageChoice choiceWithNormalImage:imageOne selectedImage:imageOne text:@"Heart" value:@"ImageTwo"];
    ORKImageChoice *choiceTwo = [ORKImageChoice choiceWithNormalImage:imageTwo selectedImage:imageTwo text:@"Phone Shake" value:@"ImageOne"];
    
    NSArray *choices = [NSArray arrayWithObjects:choiceOne, choiceTwo, nil];
    ORKImageChoiceAnswerFormat *answerChoice = [ORKAnswerFormat choiceAnswerFormatWithImageChoices:choices];
    
    XCTAssertEqual([[answerChoice imageChoices] objectAtIndex:0], choiceOne);
    XCTAssertEqual([[answerChoice imageChoices] objectAtIndex:1], choiceTwo);
    
    NSArray *wrongChoices = [NSArray arrayWithObjects:@"Wrong Choice One", @"Wrong Choice Two", nil];
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat choiceAnswerFormatWithImageChoices:wrongChoices], NSException, NSInvalidArgumentException, "Should throw NSInvalidArgumentException since choices were not ORKImageChoice objects");
}

- (void)testTextAnswerFormat {
    ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormatWithMaximumLength:10];

    XCTAssertEqual([answerFormat questionType], ORKQuestionTypeText);
    XCTAssertEqual(answerFormat.maximumLength, 10);
    XCTAssertEqual([answerFormat isAnswerValidWithString:@"CORRECT"], YES, @"Should return YES since the string length is less than max");
    XCTAssertEqual([answerFormat isAnswerValidWithString:@"REALLY LONG STRING! I THINK?"], NO, @"Should return NO since the string length is more than max");
    XCTAssert([answerFormat isEqual:answerFormat], @"Should be equal");
    
    ORKTextAnswerFormat *noMaxAnswerFormat = [ORKAnswerFormat textAnswerFormat];
    XCTAssertEqual(noMaxAnswerFormat.maximumLength, 0);
    
    NSString *pattern = @"^[2-9]\\d{2}-\\d{3}-\\d{4}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:NULL];
    ORKTextAnswerFormat *regexAnswerFormat = [ORKAnswerFormat textAnswerFormatWithValidationRegularExpression:regex invalidMessage:@"NOT A PHONENUMBER!"];
    
    XCTAssertEqual(regexAnswerFormat.validationRegularExpression, regex);
    XCTAssertEqual(regexAnswerFormat.invalidMessage, @"NOT A PHONENUMBER!");
    
    NSString *correctPhoneNumber = @"333-444-5555";
    NSString *incorrectPhoneNumber = @"123-456-7890";
    
    XCTAssertEqual([regexAnswerFormat isAnswerValidWithString:correctPhoneNumber], YES, @"Should return YES since it is in the correct format");
    XCTAssertEqual([regexAnswerFormat isAnswerValidWithString:incorrectPhoneNumber], NO, @"Should return NO since it is not in the correct format");
}

- (void)testLocationAnswerFormat {
    ORKLocationAnswerFormat *answerFormat = [ORKAnswerFormat locationAnswerFormat];
    [answerFormat setUseCurrentLocation:YES];
    XCTAssertEqual(answerFormat.useCurrentLocation, YES);
}

- (void)testWeightAnswerFormat {
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric
                                                                                  numericPrecision:ORKNumericPrecisionHigh
                                                                                      minimumValue:0
                                                                                      maximumValue:300
                                                                                      defaultValue: 150];
    
    XCTAssertEqual(answerFormat.measurementSystem, ORKMeasurementSystemMetric);
    XCTAssertEqual(answerFormat.numericPrecision, ORKNumericPrecisionHigh);
    XCTAssertEqual(answerFormat.minimumValue, 0);
    XCTAssertEqual(answerFormat.maximumValue, 300);
    XCTAssertEqual(answerFormat.defaultValue, 150);
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric
                                                                         numericPrecision:ORKNumericPrecisionHigh
                                                                             minimumValue:100
                                                                             maximumValue:50
                                                                             defaultValue:25],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since min > max");

}

- (void)testMultipleValuePickerAnswerFormat {
    ORKTextChoice *choiceOne = [ORKTextChoice choiceWithText:@"Choice One" value: [NSNumber numberWithInteger:1]];
    ORKTextChoice *choiceTwo = [ORKTextChoice choiceWithText:@"Choice Two" value: [NSNumber numberWithInteger:2]];
    ORKTextChoice *choiceThree = [ORKTextChoice choiceWithText:@"Choice Two" value: [NSNumber numberWithInteger:3]];
    ORKTextChoice *choiceFour = [ORKTextChoice choiceWithText:@"Choice Two" value: [NSNumber numberWithInteger:4]];
    
    NSArray *firstChoices = [NSArray arrayWithObjects:choiceOne, choiceTwo, nil];
    NSArray *secondChoices = [NSArray arrayWithObjects:choiceThree, choiceFour, nil];
    
    ORKValuePickerAnswerFormat *valuePickerOne = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:firstChoices];
    ORKValuePickerAnswerFormat *valuePickerTwo = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:secondChoices];
    
    NSArray *valuePickerFormats = [NSArray arrayWithObjects:valuePickerOne, valuePickerTwo, nil];
    ORKMultipleValuePickerAnswerFormat *multiplePickerAnswerFormat = [[ORKMultipleValuePickerAnswerFormat alloc] initWithValuePickers:valuePickerFormats separator:@"S"];
    
    XCTAssertEqualObjects(multiplePickerAnswerFormat.valuePickers, valuePickerFormats);
    XCTAssert([multiplePickerAnswerFormat.separator isEqualToString:@"S"]);
}

- (void)testValuePickerAnswerFormat {
    
    ORKTextChoice *choiceOne, *choiceTwo;
    
    choiceOne = [ORKTextChoice choiceWithText:@"Choice One" value:[NSNumber numberWithInteger:1]];
    choiceTwo = [ORKTextChoice choiceWithText:@"Choice Two" value:[NSNumber numberWithInteger:2]];
    
    NSArray *choices = [NSArray arrayWithObjects:choiceOne, choiceTwo, nil];
    ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:choices];
    
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:0] value], [NSNumber numberWithInteger:1]);
    XCTAssertEqual([[[answerFormat textChoices] objectAtIndex:1] value], [NSNumber numberWithInteger:2]);
}

- (void)testHealthKitCharacteristicTypeAnswerFormat {
    
    HKCharacteristicType *biologicalSex = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    ORKHealthKitCharacteristicTypeAnswerFormat *answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:biologicalSex];
    NSArray *options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_FEMALE", nil) value: ORKBiologicalSexIdentifierFemale],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_MALE", nil) value:ORKBiologicalSexIdentifierMale],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_OTHER", nil) value:ORKBiologicalSexIdentifierOther]
                         ];
    ORKAnswerFormat *expectedFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:options];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    
    HKCharacteristicType *bloodType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:bloodType];
    options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_A+", nil) value:ORKBloodTypeIdentifierAPositive],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_A-", nil) value:ORKBloodTypeIdentifierANegative],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_B+", nil) value:ORKBloodTypeIdentifierBPositive],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_B-", nil) value:ORKBloodTypeIdentifierBNegative],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_AB+", nil) value:ORKBloodTypeIdentifierABPositive],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_AB-", nil) value:ORKBloodTypeIdentifierABNegative],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_O+", nil) value:ORKBloodTypeIdentifierOPositive],
                         [ORKTextChoice choiceWithText:ORKLocalizedString(@"BLOOD_TYPE_O-", nil) value:ORKBloodTypeIdentifierONegative]
                         ];
    expectedFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:options];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    
    HKCharacteristicType *dateOfBirth = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:dateOfBirth];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *defaultDate = [NSDate date];
    NSDate *minimumDate = [NSDate dateWithTimeIntervalSinceNow:-1000];
    NSDate *maximumDate = [NSDate dateWithTimeIntervalSinceNow:1000];
    answerFormat.defaultDate = defaultDate;
    answerFormat.minimumDate = minimumDate;
    answerFormat.maximumDate = maximumDate;
    expectedFormat = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                              minimumDate:minimumDate
                                                              maximumDate:maximumDate
                                                                 calendar:calendar];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
   
    HKCharacteristicType *fitzpatrickSkin = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType];
    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:fitzpatrickSkin];
    options = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_I", nil) value:@(HKFitzpatrickSkinTypeI)],
                [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_II", nil) value:@(HKFitzpatrickSkinTypeII)],
                [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_III", nil) value:@(HKFitzpatrickSkinTypeIII)],
                [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_IV", nil) value:@(HKFitzpatrickSkinTypeIV)],
                [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_V", nil) value:@(HKFitzpatrickSkinTypeV)],
                [ORKTextChoice choiceWithText:ORKLocalizedString(@"FITZPATRICK_SKIN_TYPE_VI", nil) value:@(HKFitzpatrickSkinTypeVI)],
                ];
    expectedFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:options];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    
    HKCharacteristicType *wheelchairUse = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierWheelchairUse];
    answerFormat = [ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:wheelchairUse];
    expectedFormat = [ORKAnswerFormat booleanAnswerFormat];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], [expectedFormat impliedAnswerFormat]);
    XCTAssertEqual([answerFormat questionType], ORKQuestionTypeSingleChoice);
    XCTAssert([answerFormat isEqual:answerFormat]);
}

- (void)testHealthKitQuantityTypeAnswerFormat {
    
    HKQuantityType *height = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    ORKHealthKitQuantityTypeAnswerFormat *answerFormat = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:height unit:NULL style:ORKNumericAnswerStyleInteger];
    ORKAnswerFormat *expectedFormat = [ORKHeightAnswerFormat heightAnswerFormat];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    XCTAssertEqual([answerFormat unit], [HKUnit meterUnitWithMetricPrefix:(HKMetricPrefixCenti)]);
    
    HKQuantityType *weight = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    answerFormat = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:weight unit:NULL style:ORKNumericAnswerStyleInteger];
    expectedFormat = [ORKWeightAnswerFormat weightAnswerFormat];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    XCTAssertEqual([answerFormat unit], [HKUnit gramUnitWithMetricPrefix:(HKMetricPrefixKilo)]);
    
    HKUnit *unit = [HKUnit unitFromEnergyFormatterUnit:(NSEnergyFormatterUnitCalorie)];
    HKQuantityType *calories = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    answerFormat = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:calories unit:unit style:ORKNumericAnswerStyleDecimal];
    expectedFormat = [ORKNumericAnswerFormat decimalAnswerFormatWithUnit:[unit localizedUnitString]];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    
    answerFormat = [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:calories unit:unit style:ORKNumericAnswerStyleInteger];
    expectedFormat = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:[unit localizedUnitString]];
    XCTAssertEqualObjects([answerFormat impliedAnswerFormat], expectedFormat);
    XCTAssertEqual([answerFormat unit], unit);
    XCTAssertEqual([answerFormat numericAnswerStyle], ORKNumericAnswerStyleInteger);
    XCTAssertEqual([answerFormat quantityType], calories);
}

- (void)testDateAnswerFormat {
    
    NSDateComponents *earlierDateComponents = [[NSDateComponents alloc] init];
    [earlierDateComponents setDay: 24];
    [earlierDateComponents setMonth: 1];
    [earlierDateComponents setYear: 1984];
    NSDate *earlierDate = [[NSCalendar currentCalendar] dateFromComponents: earlierDateComponents];
    
    NSDate *middleDate = [NSDate date];
    
    NSDateComponents *laterDateComponents = [[NSDateComponents alloc] init];
    [laterDateComponents setDay: 01];
    [laterDateComponents setMonth: 01];
    [laterDateComponents setYear: 3000];
    NSDate *laterDate = [[NSCalendar currentCalendar] dateFromComponents: laterDateComponents];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    ORKDateAnswerFormat *answerFormat = [ORKAnswerFormat dateAnswerFormatWithDefaultDate:middleDate
                                                                             minimumDate:earlierDate
                                                                             maximumDate:laterDate
                                                                                calendar:calendar];
    
    XCTAssertEqual([answerFormat minimumDate], earlierDate);
    XCTAssertEqual([answerFormat defaultDate], middleDate);
    XCTAssertEqual([answerFormat maximumDate], laterDate);
    XCTAssertEqual([answerFormat questionType], ORKQuestionTypeDate);
    XCTAssert([answerFormat isAnswerValidWithString:NULL]);
    
    answerFormat = [ORKAnswerFormat dateTimeAnswerFormat];
    XCTAssertEqual([answerFormat questionType], ORKQuestionTypeDateAndTime);
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:middleDate
                                                                      minimumDate:laterDate
                                                                      maximumDate:earlierDate
                                                                         calendar:calendar],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since maximum date is less than minimum date");
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:laterDate
                                                                      minimumDate:earlierDate
                                                                      maximumDate:middleDate
                                                                         calendar:calendar],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since default date is more than maximum date");
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:earlierDate
                                                                      minimumDate:middleDate
                                                                      maximumDate:laterDate
                                                                         calendar:calendar],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since default date is less than minimum date");
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:nil
                                                                      minimumDate:laterDate
                                                                      maximumDate:earlierDate
                                                                         calendar:calendar],
                                 NSException,
                                 NSInvalidArgumentException,
                                 @"Should throw NSInvalidArgumentException since minimum date is later than maximum date");
    XCTAssertNoThrowSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:nil
                                                                       minimumDate:earlierDate
                                                                       maximumDate:laterDate
                                                                          calendar:calendar],
                                  NSException,
                                  NSInvalidArgumentException);
    XCTAssertNoThrowSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:middleDate
                                                                       minimumDate:nil
                                                                       maximumDate:laterDate
                                                                          calendar:calendar],
                                  NSException,
                                  NSInvalidArgumentException);
    XCTAssertNoThrowSpecificNamed([ORKAnswerFormat dateAnswerFormatWithDefaultDate:middleDate
                                                                       minimumDate:earlierDate
                                                                       maximumDate:nil
                                                                          calendar:calendar],
                                  NSException,
                                  NSInvalidArgumentException);
    
}

@end
