/*
 Copyright (c) 2015, Bruce Duncan. All rights reserved.
 
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


#import "ORKRegistrationStep.h"
#import "ORKHelpers.h"
#import "ORKDefines_Private.h"


@implementation ORKRegistrationStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text
                           options:(ORKRegistrationStepOption)options {
    self = [super initWithIdentifier:identifier title:title text:text];
    if (self) {
        _options = options;
        self.optional = NO;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text {
    return [self initWithIdentifier:identifier
                              title:title
                               text:text
                            options:ORKRegistrationStepDefault];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier
                              title:nil
                               text:nil];
}

- (NSArray<ORKFormItem *> *)formItems {
    NSMutableArray *formItems = [NSMutableArray new];
    
    {
        ORKEmailAnswerFormat *answerFormat = [ORKAnswerFormat emailAnswerFormat];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"email"
                                                               text:ORKLocalizedString(@"EMAIL_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"EMAIL_FORM_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }
    
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.secureTextEntry = YES;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;

        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"password"
                                                               text:ORKLocalizedString(@"PASSWORD_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"PASSWORD_FORM_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
        
        item = [[ORKFormItem alloc] initWithIdentifier:@"confirm_password"
                                                  text:ORKLocalizedString(@"CONFIRM_PASSWORD_FORM_ITEM_TITLE", nil)
                                          answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"CONFIRM_PASSWORD_FORM_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }

    if (!(_options & ORKRegistrationStepDefault)) {
        ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:ORKLocalizedString(@"ADDITIONAL_INFO_SECTION_TITLE", nil)];
        [formItems addObject:item];
    }
    
    if (_options & ORKRegistrationStepIncludeFirstName) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"given_name"
                                                               text:ORKLocalizedString(@"CONSENT_NAME_GIVEN", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"FIRST_NAME_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (_options & ORKRegistrationStepIncludeLastName) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"family_name"
                                                               text:ORKLocalizedString(@"CONSENT_NAME_FAMILY", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"LAST_NAME_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (_options & ORKRegistrationStepIncludeGender) {
        NSArray *textChoices = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_MALE", nil) value:@0],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_FEMALE", nil) value:@1],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_OTHER", nil) value:@2]];
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"gender"
                                                               text:ORKLocalizedString(@"GENDER_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"GENDER_FORM_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (_options & ORKRegistrationStepIncludeDOB) {
        // Calculate default date (20 years from now).
        NSDateComponents *minusTwentyYears = [NSDateComponents new];
        minusTwentyYears.year = -20;
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingComponents:minusTwentyYears
                                                                                toDate:[NSDate date]
                                                                               options:0];
        
        ORKDateAnswerFormat *answerFormat = [ORKAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                 minimumDate:nil
                                                                                 maximumDate:nil
                                                                                    calendar:nil];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"dob"
                                                               text:ORKLocalizedString(@"DOB_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat];
        item.placeholder = ORKLocalizedString(@"DOB_FORM_ITEM_PLACEHOLDER", nil);
        item.optional = NO;
        [formItems addObject:item];
    }
    
    return formItems;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_INTEGER(aDecoder, options);
        ORK_DECODE_OBJ(aDecoder, passcodeValidationRegex);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_INTEGER(aCoder, options);
    ORK_ENCODE_OBJ(aCoder, passcodeValidationRegex);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRegistrationStep *step = [super copyWithZone:zone];
    step->_options = self.options;
    step->_passcodeValidationRegex = self.passcodeValidationRegex;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            self.options == castObject.options &&
            ORKEqualObjects(self.passcodeValidationRegex, castObject.passcodeValidationRegex));
}

@end
