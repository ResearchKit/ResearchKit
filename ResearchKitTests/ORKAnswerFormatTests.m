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
#import "ORKAnswerFormat_Internal.h"
#import "ORKPicker.h"
#import "ORKPickerTestDelegate.h"

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
    
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo"
                                                           text:@"enter value"
                                                   answerFormat:answerFormat
                                                       optional:NO];
    
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
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo"
                                                           text:@"enter value"
                                                   answerFormat:answerFormat
                                                       optional:YES];
    
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
    
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"foo"
                                                           text:@"enter value"
                                                   answerFormat:answerFormat
                                                       optional:YES];
    
    // -- method under test
    XCTAssertThrows([item confirmationAnswerFormItemWithIdentifier:@"bar"
                                                              text:@"enter again"
                                                      errorMessage:@"doesn't match"]);

}

#pragma mark - UIPickerTests
- (BOOL)setupNonOptionalPicker:(ORKAnswerFormat*)answerFormat
                      scrollTo:(double)inputValue
              expectedKGAnswer:(double)expectedKGAnswer
              secondInputValue:(double)secondInputValue {
    
    // add one because the first value in the array is empty, so all values need to be pushed up one
    inputValue = inputValue + 1;
    
    ORKPickerTestDelegate* testDelegate = [[ORKPickerTestDelegate alloc] initWithOptionalValue:false];
    id<ORKPicker> picker = [ORKPicker pickerWithAnswerFormat:answerFormat answer: nil delegate:testDelegate];
    [picker pickerWillAppear];
    UIPickerView* pickerView = (UIPickerView*)[picker pickerView];
    [pickerView selectRow:inputValue inComponent:0 animated:true];
    if (secondInputValue != ORKDoubleInvalidValue) {
        [pickerView selectRow:secondInputValue inComponent:1 animated:true];
    }
    [picker pickerWillAppear];
    
    return  expectedKGAnswer == ((NSNumber*) picker.answer).doubleValue;
}

- (BOOL)revisitingNonOptionalPicker:(ORKAnswerFormat*)answerFormat
                       defaultValue:(double)defaultValue
                        expectedRow:(double)expectedRow
                  expectedSecondRow:(double)expectedSecondRow {
    
    // add one because the first value in the array is empty, so all values need to be pushed up one
    expectedRow = expectedRow + 1;
    
    ORKPickerTestDelegate* testDelegate = [[ORKPickerTestDelegate alloc] initWithOptionalValue:false];
    id<ORKPicker> revisitingPickerFromAnotherScreen = [ORKPicker pickerWithAnswerFormat:answerFormat answer: [NSNumber numberWithDouble:defaultValue] delegate:testDelegate];
    UIPickerView* revisitingPickerFromAnotherScreenpickerView = (UIPickerView*)[revisitingPickerFromAnotherScreen pickerView];

    if (expectedSecondRow == ORKDoubleInvalidValue) {
        return([revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:0] == expectedRow);
    } else {
        return([revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:0] == expectedRow && [revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:1] == expectedSecondRow);

    }
}

- (BOOL)setupOptionalPicker:(ORKAnswerFormat*)answerFormat
                   scrollTo:(double)inputValue
           expectedKGAnswer:(double)expectedKGAnswer
           secondInputValue:(double)secondInputValue {
    
    ORKPickerTestDelegate* testDelegate = [[ORKPickerTestDelegate alloc] initWithOptionalValue:true];
    id<ORKPicker> picker = [ORKPicker pickerWithAnswerFormat:answerFormat answer: nil delegate:testDelegate];
    [picker pickerWillAppear];
    UIPickerView* pickerView = (UIPickerView*)[picker pickerView];
    [pickerView selectRow:inputValue inComponent:0 animated:true];
    if (secondInputValue != ORKDoubleInvalidValue) {
        [pickerView selectRow:secondInputValue inComponent:1 animated:true];
    }
    [picker pickerWillAppear];
    return  expectedKGAnswer == ((NSNumber*) picker.answer).doubleValue;
}

- (BOOL) revisitingOptionalPicker:(ORKAnswerFormat*)answerFormat
                     defaultValue:(double)defaultValue
                      expectedRow:(double)expectedRow
                expectedSecondRow:(double)expectedSecondRow {
    
    ORKPickerTestDelegate* testDelegate = [[ORKPickerTestDelegate alloc] initWithOptionalValue:true];
    id<ORKPicker> revisitingPickerFromAnotherScreen = [ORKPicker pickerWithAnswerFormat:answerFormat answer: [NSNumber numberWithDouble:defaultValue] delegate:testDelegate];
    UIPickerView* revisitingPickerFromAnotherScreenpickerView = (UIPickerView*)[revisitingPickerFromAnotherScreen pickerView];

    if (expectedSecondRow == ORKDoubleInvalidValue) {
        return([revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:0] == expectedRow);
    } else {
        return([revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:0] == expectedRow && [revisitingPickerFromAnotherScreenpickerView selectedRowInComponent:1] == expectedSecondRow);
    }
}

#pragma mark - UIWeightPickerTests
- (void)testNonOptionalWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormat];
    
    double tenPounds = 10.0;
    double kgConversion = ORKPoundsToKilograms(tenPounds);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:tenPounds
                              expectedKGAnswer:kgConversion
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:tenPounds
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalMetricWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double tenPounds = 10.0;
    double kgConversion = 5.0; //ORKPoundsToKilograms(tenPounds);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:tenPounds
                              expectedKGAnswer:kgConversion
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:tenPounds
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalMetricLowPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric numericPrecision:ORKNumericPrecisionLow minimumValue:ORKDoubleDefaultValue maximumValue:ORKDoubleDefaultValue defaultValue:ORKDoubleDefaultValue];
    
    double tenKG = 10.0;
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:tenKG
                              expectedKGAnswer:tenKG
                              secondInputValue:ORKDoubleInvalidValue]);
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat defaultValue:tenKG expectedRow:tenKG expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalMetricHighPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric numericPrecision:ORKNumericPrecisionHigh minimumValue:20.0 maximumValue:100.0 defaultValue:45.00];
    
    double scrollIndex = 10.0;
    double secondScrollIndex = 10.0;

    double expectedValue = 30.09;

    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:scrollIndex
                              expectedKGAnswer:expectedValue
                              secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:expectedValue
                                        expectedRow:scrollIndex
                                  expectedSecondRow:secondScrollIndex]);
}

- (void)testNonOptionalUSCWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double tenPounds = 10.0;
    double kgConversion = ORKPoundsToKilograms(tenPounds);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:tenPounds
                              expectedKGAnswer:kgConversion
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:tenPounds
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalUSCHighPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC numericPrecision:ORKNumericPrecisionHigh minimumValue:50.0 maximumValue:150.0 defaultValue:100.0];
    
    double scrollIndex = 1.0; //51
    double secondScrollIndex = 8.0; //blank default value, starts at 0 -> 7 ounces

    double expectedValue = 51.4375; // 51 pounds and 7 ounces = 51.4375 pounds
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:scrollIndex
                              expectedKGAnswer:kgConversion
                              secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:scrollIndex
                                  expectedSecondRow:secondScrollIndex]);
}

- (void)testNonOptionalMetricLowPrecisionDecimalWeightPickerAnswerFormat {
    // Setup an answer format

    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double scrollIndex = 3.0; // 1.5 kg
    double expectedValue = 1.5; // 1.5 kg
    
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:scrollIndex
                              expectedKGAnswer:expectedValue
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:expectedValue
                                        expectedRow:scrollIndex
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalUSCLowPercisionMinWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionLow
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 0.0; //51
    double expectedValue = 50.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue( [self setupNonOptionalPicker:answerFormat
                                       scrollTo:scrollIndex
                               expectedKGAnswer:kgConversion
                               secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:scrollIndex
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalUSCLowPercisionMaxWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionLow
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 100.0;
    double expectedValue = 150.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:scrollIndex
                              expectedKGAnswer:kgConversion
                              secondInputValue:ORKDoubleInvalidValue]);

    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:kgConversion
                                        expectedRow:scrollIndex
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormat];
    
    double tenPounds = 10.0;
    double kgConversion = ORKPoundsToKilograms(tenPounds);

    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:tenPounds
                           expectedKGAnswer:kgConversion
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:tenPounds
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalMetricWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double tenPounds = 10.0;
    double kgConversion = 5.0; //ORKPoundsToKilograms(tenPounds);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:tenPounds
                           expectedKGAnswer:kgConversion
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:tenPounds
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalMetricLowPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric
                                                                                  numericPrecision:ORKNumericPrecisionLow
                                                                                      minimumValue:ORKDoubleDefaultValue
                                                                                      maximumValue:ORKDoubleDefaultValue
                                                                                      defaultValue:ORKDoubleDefaultValue];
    
    double tenKG = 10.0;
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:tenKG
                           expectedKGAnswer:tenKG
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:tenKG
                                     expectedRow:tenKG
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalMetricHighPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric
                                                                                  numericPrecision:ORKNumericPrecisionHigh
                                                                                      minimumValue:20.0
                                                                                      maximumValue:100.0
                                                                                      defaultValue:45.00];
    
    double scrollIndex = 10.0;
    double secondScrollIndex = 10.0;

    double expectedValue = 30.10;

    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:expectedValue
                           secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:expectedValue
                                     expectedRow:scrollIndex
                               expectedSecondRow:secondScrollIndex]);
}

- (void)testOptionalUSCWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double tenPounds = 10.0;
    double kgConversion = ORKPoundsToKilograms(tenPounds);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:tenPounds
                           expectedKGAnswer:kgConversion
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:tenPounds
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalUSCHighPercisionWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionHigh
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 1.0; //51
    double secondScrollIndex = 8.0; //no default value, starts at 0 -> 7 ounces

    double expectedValue = 51.49; // 51 pounds and 8 ounces = 51.5 pounds
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:kgConversion
                           secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:scrollIndex
                               expectedSecondRow:secondScrollIndex]);
}

- (void)testOptionalUSCLowPercisionMinWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionLow
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 0.0; //51
    double expectedValue = 50.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:kgConversion
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:scrollIndex
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalUSCLowPercisionMaxWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionLow
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 100.0;
    double expectedValue = 150.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:kgConversion
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:scrollIndex
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalUSCHighPercisionMinWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionHigh
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 0.0;
    double secondScrollIndex = 0.0;
    double expectedValue = 50.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:kgConversion
                           secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:scrollIndex
                               expectedSecondRow:secondScrollIndex]);
}

- (void)testOptionalUSCHighPercisionMaxWeightPickerAnswerFormat {
    // Setup an answer format
    ORKWeightAnswerFormat *answerFormat = [ORKAnswerFormat weightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC
                                                                                  numericPrecision:ORKNumericPrecisionHigh
                                                                                      minimumValue:50.0
                                                                                      maximumValue:150.0
                                                                                      defaultValue:100.0];
    
    double scrollIndex = 100.0;
    double secondScrollIndex = 0.0;
    double expectedValue = 150.0;
    double kgConversion = ORKPoundsToKilograms(expectedValue);
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:scrollIndex
                           expectedKGAnswer:kgConversion
                           secondInputValue:secondScrollIndex]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:kgConversion
                                     expectedRow:scrollIndex
                               expectedSecondRow:secondScrollIndex]);
}


#pragma mark - UIHeightPickerTests

- (void)testNonOptionalHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormat];
    
    double fiveFeet = 5.0;
    double fiveInches = 5.0;

    double expectedFeet = 5.0;
    double expectedInches = 4.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:fiveFeet
                              expectedKGAnswer:metricConversion
                              secondInputValue:fiveInches]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:metricConversion
                                        expectedRow:fiveFeet
                                  expectedSecondRow:fiveInches]);
}

- (void)testNonOptionalMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double fiveCM = 5.0;

    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:fiveCM
                              expectedKGAnswer:fiveCM
                              secondInputValue:ORKDoubleInvalidValue]);

    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:fiveCM
                                        expectedRow:fiveCM
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double fiveFeet = 5.0;
    double fiveInches = 5.0;

    double expectedFeet = 5.0;
    double expectedInches = 4.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:fiveFeet
                              expectedKGAnswer:metricConversion
                              secondInputValue:fiveInches]);

    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:metricConversion
                                        expectedRow:fiveFeet
                                  expectedSecondRow:fiveInches]);
}

- (void)testNonOptionalMinUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double startFeet = 0.0;
    double startInches = 1.0;

    double expectedFeet = 0.0;
    double expectedInches = 0.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:startFeet
                              expectedKGAnswer:metricConversion
                              secondInputValue:startInches]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:metricConversion
                                        expectedRow:startFeet
                                  expectedSecondRow:startInches]);
}

- (void)testNonOptionalMaxUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double startFeet = 9.0;
    double startInches = 12.0;

    double expectedFeet = 9.0;
    double expectedInches = 11.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:startFeet
                              expectedKGAnswer:metricConversion
                              secondInputValue:startInches]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:metricConversion
                                        expectedRow:startFeet
                                  expectedSecondRow:startInches]);
}

- (void)testNonOptionalMinMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double cm = 0.0;
    
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:cm
                              expectedKGAnswer:cm
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:cm
                                        expectedRow:cm
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testNonOptionalMaxMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double cm = 298.0;
    
    XCTAssertTrue([self setupNonOptionalPicker:answerFormat
                                      scrollTo:cm
                              expectedKGAnswer:cm
                              secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingNonOptionalPicker:answerFormat
                                       defaultValue:cm
                                        expectedRow:cm
                                  expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormat];
    
    double fiveFeet = 5.0;
    double fiveInches = 5.0;

    double expectedFeet = 5.0;
    double expectedInches = 5.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:fiveFeet
                           expectedKGAnswer:metricConversion
                           secondInputValue:fiveInches]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:metricConversion
                                     expectedRow:fiveFeet
                               expectedSecondRow:fiveInches]);
}

- (void)testOptionalMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double fiveCM = 5.0;

    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:fiveCM
                           expectedKGAnswer:fiveCM
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:fiveCM
                                     expectedRow:fiveCM
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double fiveFeet = 5.0;
    double fiveInches = 5.0;

    double expectedFeet = 5.0;
    double expectedInches = 5.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:fiveFeet
                           expectedKGAnswer:metricConversion
                           secondInputValue:fiveInches]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:metricConversion
                                     expectedRow:fiveFeet
                               expectedSecondRow:fiveInches]);
}

- (void)testOptionalMinUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double startFeet = 0.0;
    double startInches = 1.0;

    double expectedFeet = 0.0;
    double expectedInches = 1.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:startFeet
                           expectedKGAnswer:metricConversion
                           secondInputValue:startInches]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:metricConversion
                                     expectedRow:startFeet
                               expectedSecondRow:startInches]);
}

- (void)testOptionalMaxUSCHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemUSC];
    
    double startFeet = 9.0;
    double startInches = 11.0;

    double expectedFeet = 9.0;
    double expectedInches = 11.0;
    
    double metricConversion = ORKFeetAndInchesToCentimeters(expectedFeet, expectedInches);
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:startFeet
                           expectedKGAnswer:metricConversion
                           secondInputValue:startInches]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:metricConversion
                                     expectedRow:startFeet
                               expectedSecondRow:startInches]);
}

- (void)testOptionalMinMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double cm = 0.0;
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:cm
                           expectedKGAnswer:cm
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:cm
                                     expectedRow:cm
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testOptionalMaxMetricHeightPickerAnswerFormat {
    // Setup an answer format
    ORKHeightAnswerFormat *answerFormat = [ORKAnswerFormat heightAnswerFormatWithMeasurementSystem:ORKMeasurementSystemMetric];
    
    double cm = 298.0;
    
    XCTAssertTrue([self setupOptionalPicker:answerFormat
                                   scrollTo:cm
                           expectedKGAnswer:cm
                           secondInputValue:ORKDoubleInvalidValue]);
    
    XCTAssertTrue([self revisitingOptionalPicker:answerFormat
                                    defaultValue:cm
                                     expectedRow:cm
                               expectedSecondRow:ORKDoubleInvalidValue]);
}

- (void)testContinuousScaleAnswerFormat {
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since max < min");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10001
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since max > effectiveUpperBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:100
                                                                                 minimumValue:-10001
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since min < effectiveLowerBound");
    
    XCTAssertThrowsSpecificNamed([ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                 minimumValue:100
                                                                                 defaultValue:10
                                                                        maximumFractionDigits:10
                                                                                     vertical:YES
                                                                      maximumValueDescription:NULL
                                                                      minimumValueDescription:NULL], NSException, NSInvalidArgumentException, @"Should throw NSInvalidArgumentException since max < min");
    
    
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

- (void)testMaxFractionDigitsZeroSuccess {
    NSUInteger maxFractionDigits = 0;

    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.1234],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.123],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.0000],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1],  @"1");
    }
    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.1234],  @"99");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.123],  @"99");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.0000],  @"99");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99],  @"99");
    }
    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.0000],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.000],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.0],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.99],  @"100");
    }
    
    {
        NSRange range = NSMakeRange(0, 1);
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc]
                                                       initWithMaximumValue:NSMaxRange(range)
                                                       minimumValue:range.location
                                                       defaultValue:0.0
                                                       maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@0],  @"0");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@000.0000],  @"0");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@000.000],  @"0");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@000.0],  @"0");

        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@0.01],  @"0");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@0.1],  @"0");
    }
    {
        NSRange range = NSMakeRange(0, 1);
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc]
                                                       initWithMaximumValue:NSMaxRange(range)
                                                       minimumValue:range.location
                                                       defaultValue:0.0
                                                       maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.0000],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.000],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.0],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@0.9],  @"1");
    }
}

- (void)testMaxFractionDigitsThreeSuccess {
    NSUInteger maxFractionDigits = 3;

    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.1234],  @"1.123");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.123],  @"1.123");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1.0000],  @"1");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@1],  @"1");
    }
    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.1234],  @"99.123");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.123],  @"99.123");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.0000],  @"99");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99],  @"99");
    }
    {
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.0000],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.000],  @"100");
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@100.0],  @"100");
    }
}

- (void)testMaxFractionDigitsClamping {
    {
        NSUInteger maxFractionDigits = 5;
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.12345],  @"99.1235");
    }
    {
        NSUInteger maxFractionDigits = -1;
        ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10 minimumValue:1 defaultValue:0.0 maximumFractionDigits:maxFractionDigits];
        XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@99.12345],  @"99");
    }
}

- (void)testMaxFractionDigitsFailures {

    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0.0 maximumFractionDigits:4], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 100 with 4 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1000 minimumValue:1 defaultValue:0.0 maximumFractionDigits:3], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 1000 with 3 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10000 minimumValue:1 defaultValue:0.0 maximumFractionDigits:2], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 10000 with 2 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100000 minimumValue:1 defaultValue:0.0 maximumFractionDigits:1], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 100000 with 1 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1000000 minimumValue:1 defaultValue:0.0 maximumFractionDigits:0], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 1000000 with 0 fractional digits would be over 6 digits");
    
}

- (void)testMaxFractionDigits {
    
    // testing that we can display 6 digits in all numeric scenarios, including decimal

    // Testing max values with increasing maxFractionDigits
    
    ORKContinuousScaleAnswerFormat* scaleAnswer = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:1 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer.numberFormatter stringFromNumber:@0.001],  @"0.001");
    
    ORKContinuousScaleAnswerFormat* scaleAnswer2 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:11 minimumValue:1 defaultValue:1 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer2.numberFormatter stringFromNumber:@10.999],  @"10.999");

    ORKContinuousScaleAnswerFormat* scaleAnswer3 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:9.999 minimumValue:1 defaultValue:1 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer3.numberFormatter stringFromNumber:@9.999],  @"9.999");

    ORKContinuousScaleAnswerFormat* scaleAnswer4 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:9.9999 minimumValue:1 defaultValue:1 maximumFractionDigits:4];
    XCTAssertEqualObjects([scaleAnswer4.numberFormatter stringFromNumber:@1.0008],  @"1.0008");

    // Testing min values with increasing maxFractionDigits
    
    ORKContinuousScaleAnswerFormat* scaleAnswer5 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:1 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer5.numberFormatter stringFromNumber:@0.005],  @"0.005");

    ORKContinuousScaleAnswerFormat* scaleAnswer6 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:0 maximumFractionDigits:4];
    XCTAssertEqualObjects([scaleAnswer6.numberFormatter stringFromNumber:@0.0001],  @"0.0001");

    // Testing min values with decreasing min values
    
    ORKContinuousScaleAnswerFormat* scaleAnswer7 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-99.999 defaultValue:0 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer7.numberFormatter stringFromNumber:@-0.123],  @"-0.123");

    ORKContinuousScaleAnswerFormat* scaleAnswer8 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-1 defaultValue:0 maximumFractionDigits:4];
    XCTAssertEqualObjects([scaleAnswer8.numberFormatter stringFromNumber:@-0.0001],  @"-0.0001");

    ORKContinuousScaleAnswerFormat* scaleAnswer9 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-10 defaultValue:0 maximumFractionDigits:3];
    XCTAssertEqualObjects([scaleAnswer9.numberFormatter stringFromNumber:@-9.999],  @"-9.999");

    ORKContinuousScaleAnswerFormat* scaleAnswer10 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-100 defaultValue:0 maximumFractionDigits:2];
    XCTAssertEqualObjects([scaleAnswer10.numberFormatter stringFromNumber:@-99.01],  @"-99.01");

    ORKContinuousScaleAnswerFormat* scaleAnswer11 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-1000 defaultValue:0 maximumFractionDigits:1];
    XCTAssertEqualObjects([scaleAnswer11.numberFormatter stringFromNumber:@-9999.1],  @"-9,999.1");

    ORKContinuousScaleAnswerFormat* scaleAnswer12 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:0 minimumValue:-10000 defaultValue:0 maximumFractionDigits:0];
    XCTAssertEqualObjects([scaleAnswer12.numberFormatter stringFromNumber:@-99999],  @"-99,999");
    
    // Testing larger numbers
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100 minimumValue:1 defaultValue:0 maximumFractionDigits:4], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 100 with 4 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1000 minimumValue:1 defaultValue:0 maximumFractionDigits:3], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 1000 with 3 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10000 minimumValue:1 defaultValue:0 maximumFractionDigits:2], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 10000 with 2 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100000 minimumValue:1 defaultValue:0 maximumFractionDigits:1], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 100000 with 1 fractional digits would be over 6 digits");
    
    XCTAssertThrowsSpecificNamed([[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1000000 minimumValue:1 defaultValue:0 maximumFractionDigits:0], NSException, NSInvalidArgumentException, @"Shoud throw NSInvalidArgumentException since 1000000 with 0 fractional digits would be over 6 digits");
    
    // testing commas
    ORKContinuousScaleAnswerFormat* scaleAnswerComma = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:100000 minimumValue:0 defaultValue:0 maximumFractionDigits:0];
    XCTAssertEqualObjects([scaleAnswerComma.numberFormatter stringFromNumber:@999999],  @"999,999");
    
    ORKContinuousScaleAnswerFormat* scaleAnswerComma2 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:-100000 defaultValue:0 maximumFractionDigits:0];
    XCTAssertEqualObjects([scaleAnswerComma2.numberFormatter stringFromNumber:@-999999],  @"-999,999");
    
    // Testing decimal clipping bounds should clip at 6 digits max
    ORKContinuousScaleAnswerFormat* scaleAnswer13 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:0 maximumFractionDigits:8];
    XCTAssertEqualObjects([scaleAnswer13.numberFormatter stringFromNumber:@0.12345678],  @"0.1235");
    
    ORKContinuousScaleAnswerFormat* scaleAnswer14 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:0 maximumFractionDigits:5];
    XCTAssertEqualObjects([scaleAnswer14.numberFormatter stringFromNumber:@0.12345678],  @"0.1235");
    
    ORKContinuousScaleAnswerFormat* scaleAnswer15 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:0 maximumFractionDigits:10];
    XCTAssertEqualObjects([scaleAnswer15.numberFormatter stringFromNumber:@0.12345678],  @"0.1235");
    
    ORKContinuousScaleAnswerFormat* scaleAnswer16 = [[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:1 minimumValue:0 defaultValue:0 maximumFractionDigits:-5];
    XCTAssertEqualObjects([scaleAnswer16.numberFormatter stringFromNumber:@0.12345678],  @"0");
    
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
