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


#import "ORKRegistrationStep.h"

#import "ORKAnswerFormat_Private.h"

#import "ORKHelpers_Internal.h"


NSString *const ORKRegistrationFormItemIdentifierEmail = @"ORKRegistrationFormItemEmail";
NSString *const ORKRegistrationFormItemIdentifierPassword = @"ORKRegistrationFormItemPassword";
NSString *const ORKRegistrationFormItemIdentifierConfirmPassword = @"ORKRegistrationFormItemConfirmPassword";
NSString *const ORKRegistrationFormItemIdentifierGivenName = @"ORKRegistrationFormItemGivenName";
NSString *const ORKRegistrationFormItemIdentifierFamilyName = @"ORKRegistrationFormItemFamilyName";
NSString *const ORKRegistrationFormItemIdentifierGender = @"ORKRegistrationFormItemGender";
NSString *const ORKRegistrationFormItemIdentifierDOB = @"ORKRegistrationFormItemDOB";

static id ORKFindInArrayByFormItemId(NSArray *array, NSString *formItemIdentifier) {
    return findInArrayByKey(array, @"identifier", formItemIdentifier);
}

static NSArray <ORKFormItem*> *ORKRegistrationFormItems(ORKRegistrationStepOption options) {
    NSMutableArray *formItems = [NSMutableArray new];
    
    {
        ORKEmailAnswerFormat *answerFormat = [ORKAnswerFormat emailAnswerFormat];
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierEmail
                                                               text:ORKLocalizedString(@"EMAIL_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"EMAIL_FORM_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    ORKFormItem *passwordFormItem;
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.secureTextEntry = YES;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierPassword
                                                               text:ORKLocalizedString(@"PASSWORD_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"PASSWORD_FORM_ITEM_PLACEHOLDER", nil);
        passwordFormItem = item;
        
        [formItems addObject:item];
    }
    
    {
        ORKFormItem *item = [passwordFormItem confirmationAnswerFormItemWithIdentifier:ORKRegistrationFormItemIdentifierConfirmPassword
                                                text:ORKLocalizedString(@"CONFIRM_PASSWORD_FORM_ITEM_TITLE", nil)
                                                errorMessage:ORKLocalizedString(@"CONFIRM_PASSWORD_ERROR_MESSAGE", nil)];
        item.placeholder = ORKLocalizedString(@"CONFIRM_PASSWORD_FORM_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    if (options & (ORKRegistrationStepIncludeFamilyName | ORKRegistrationStepIncludeGivenName | ORKRegistrationStepIncludeDOB | ORKRegistrationStepIncludeGender)) {
        ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:ORKLocalizedString(@"ADDITIONAL_INFO_SECTION_TITLE", nil)];
        
        [formItems addObject:item];
    }
    
    if (options & ORKRegistrationStepIncludeGivenName) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierGivenName
                                                               text:ORKLocalizedString(@"CONSENT_NAME_GIVEN", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"GIVEN_NAME_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    if (options & ORKRegistrationStepIncludeFamilyName) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierFamilyName
                                                               text:ORKLocalizedString(@"CONSENT_NAME_FAMILY", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"FAMILY_NAME_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    // Adjust order of given name and family name form item cells based on current locale.
    if ((options & ORKRegistrationStepIncludeGivenName) && (options & ORKRegistrationStepIncludeFamilyName)) {
        if (ORKCurrentLocalePresentsFamilyNameFirst()) {
            ORKFormItem *givenNameFormItem = ORKFindInArrayByFormItemId(formItems, ORKRegistrationFormItemIdentifierGivenName);
            ORKFormItem *familyNameFormItem = ORKFindInArrayByFormItemId(formItems, ORKRegistrationFormItemIdentifierFamilyName);
            [formItems exchangeObjectAtIndex:[formItems indexOfObject:givenNameFormItem]
                           withObjectAtIndex:[formItems indexOfObject:familyNameFormItem]];
        }
    }
    
    if (options & ORKRegistrationStepIncludeGender) {
        NSArray *textChoices = @[[ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_FEMALE", nil) value:@"female"],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_MALE", nil) value:@"male"],
                                 [ORKTextChoice choiceWithText:ORKLocalizedString(@"GENDER_OTHER", nil) value:@"other"]];
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierGender
                                                               text:ORKLocalizedString(@"GENDER_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"GENDER_FORM_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    if (options & ORKRegistrationStepIncludeDOB) {
        // Calculate default date (20 years from now).
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear
                                                                       value:-20
                                                                      toDate:[NSDate date]
                                                                     options:(NSCalendarOptions)0];
        
        ORKDateAnswerFormat *answerFormat = [ORKAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                 minimumDate:nil
                                                                                 maximumDate:[NSDate date]
                                                                                    calendar:[NSCalendar currentCalendar]];
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierDOB
                                                               text:ORKLocalizedString(@"DOB_FORM_ITEM_TITLE", nil)
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = ORKLocalizedString(@"DOB_FORM_ITEM_PLACEHOLDER", nil);
        
        [formItems addObject:item];
    }
    
    return formItems;
}

@implementation ORKRegistrationStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text
passcodeValidationRegularExpression:(NSRegularExpression *)passcodeValidationRegularExpression
            passcodeInvalidMessage:(NSString *)passcodeInvalidMessage
                           options:(ORKRegistrationStepOption)options {
    self = [super initWithIdentifier:identifier title:title text:text];
    if (self) {
        _options = options;
        self.passcodeValidationRegularExpression = passcodeValidationRegularExpression;
        self.passcodeInvalidMessage = passcodeInvalidMessage;
        self.optional = NO;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text
                           options:(ORKRegistrationStepOption)options {
    return [self initWithIdentifier:identifier
                              title:title
                               text:text
passcodeValidationRegularExpression:nil
             passcodeInvalidMessage:nil
                            options:options];
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

- (ORKTextAnswerFormat *)passwordAnswerFormat {
    ORKFormItem *passwordFormItem = ORKFindInArrayByFormItemId(self.formItems, ORKRegistrationFormItemIdentifierPassword);
    ORKTextAnswerFormat *passwordAnswerFormat = (ORKTextAnswerFormat *)passwordFormItem.answerFormat;
    return passwordAnswerFormat;
}

- (NSArray <ORKFormItem *> *)formItems {
    if (![super formItems]) {
        self.formItems = ORKRegistrationFormItems(_options);
    }
    
    ORKFormItem *dobFormItem = ORKFindInArrayByFormItemId([super formItems], ORKRegistrationFormItemIdentifierDOB);
    ORKDateAnswerFormat *originalAnswerFormat = (ORKDateAnswerFormat *)dobFormItem.answerFormat;
    ORKDateAnswerFormat *modifiedAnswerFormat = [ORKAnswerFormat dateAnswerFormatWithDefaultDate:originalAnswerFormat.defaultDate
                                                                                     minimumDate:originalAnswerFormat.minimumDate
                                                                                     maximumDate:[NSDate date]
                                                                                        calendar:originalAnswerFormat.calendar];

    dobFormItem = [[ORKFormItem alloc] initWithIdentifier:ORKRegistrationFormItemIdentifierDOB
                                                     text:ORKLocalizedString(@"DOB_FORM_ITEM_TITLE", nil)
                                             answerFormat:modifiedAnswerFormat
                                                 optional:NO];
    dobFormItem.placeholder = ORKLocalizedString(@"DOB_FORM_ITEM_PLACEHOLDER", nil);
    
    return [super formItems];
}

- (NSRegularExpression *)passcodeValidationRegularExpression {
    return [self passwordAnswerFormat].validationRegularExpression;
}

- (void)setPasscodeValidationRegularExpression:(NSRegularExpression *)passcodeValidationRegularExpression {
    [self passwordAnswerFormat].validationRegularExpression = passcodeValidationRegularExpression;
}

- (NSString *)passcodeInvalidMessage {
    return [self passwordAnswerFormat].invalidMessage;
}

- (void)setPasscodeInvalidMessage:(NSString *)passcodeInvalidMessage {
    [self passwordAnswerFormat].invalidMessage = passcodeInvalidMessage;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // `passcodeValidationRegularExpression` and `passcodeInvalidMessage` are transparent
        // properties. The corresponding decoding for these properties takes place in the answer
        // format's `-initWithCode:` method, invoked from super's (ORKFormStep) implementation.
        ORK_DECODE_INTEGER(aDecoder, options);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    // `passcodeValidationRegularExpression` and `passcodeInvalidMessage` are transparent
    // properties. The corresponding encoding for these properties takes place in the answer format's
    // `-encodeWithCoder:` method, invoked from super's (ORKFormStep) implementation.
    ORK_ENCODE_INTEGER(aCoder, options);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRegistrationStep *step = [super copyWithZone:zone];
    
    // `passcodeValidationRegularExpression` and `passcodeInvalidMessage` are transparent
    // properties. The corresponding copying of these properties happens in the answer format
    // `-copyWithZone:` method, invoked from the super's (ORKFormStep) implementation.
    step->_options = self.options;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    // `passcodeValidationRegularExpression` and `passcodeInvalidMessage` are transparent
    // properties. The corresponding equality test for these properties takes place in the answer
    // format's `-isEqual:` method, invoked from super's (ORKFormStep) implementation.
    __typeof(self) castObject = object;
    return (isParentSame &&
            self.options == castObject.options);
}

@end
