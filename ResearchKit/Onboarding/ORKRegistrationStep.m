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


@implementation ORKRegistrationStep {
    ORKRegistrationStepOption _options;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text
                           message:(NSString *)message
                           options:(ORKRegistrationStepOption)options {
    self = [super initWithIdentifier:identifier title:title text:text];
    if (self) {
        _message = message;
        _options = options;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text {
    return [self initWithIdentifier:identifier
                              title:title
                               text:text
                            message:nil
                            options:ORKRegistrationStepDefault];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier
                              title:nil
                               text:nil];
}

- (NSArray<ORKFormItem *> *)formItems {
    NSMutableArray *formItems = [NSMutableArray new];
    if (! (_options & ORKRegistrationStepExcludeFirstName)) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"first_name"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"First name";
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeLastName)) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"last_name"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"Last name";
        item.optional = NO;
        [formItems addObject:item];
    }

    if (! (_options & ORKRegistrationStepExcludeEmail)) {
        ORKEmailAnswerFormat *answerFormat = [ORKAnswerFormat emailAnswerFormat];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"email"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"Email";
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludePassword)) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.secureTextEntry = YES;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"password"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"Password";
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeGender)) {
        NSArray *textChoices = @[[ORKTextChoice choiceWithText:@"Male" value:@0],
                                 [ORKTextChoice choiceWithText:@"Female" value:@1]];
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"gender"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"Gender";
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeGender)) {
        NSArray *textChoices = @[[ORKTextChoice choiceWithText:@"Male" value:@0],
                                 [ORKTextChoice choiceWithText:@"Female" value:@1]];
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"gender"
                                                               text:nil
                                                       answerFormat:answerFormat];
        item.placeholder = @"Gender";
        item.optional = NO;
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeDOB)) {
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"dob" text:@"Date of Birth" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        item.placeholder = @"DOB";
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
        ORK_DECODE_OBJ(aDecoder, message);
        ORK_DECODE_INTEGER(aDecoder, options);
        ORK_DECODE_OBJ(aDecoder, passcodeValidationRegex);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, message);
    ORK_ENCODE_INTEGER(aCoder, options);
    ORK_ENCODE_OBJ(aCoder, passcodeValidationRegex);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRegistrationStep *step = [[[self class] allocWithZone:zone] init];
    step->_message = self.message;
    step->_options = self.options;
    step->_passcodeValidationRegex = self.passcodeValidationRegex;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.message, castObject.message) &&
            self.options == castObject.options &&
            ORKEqualObjects(self.passcodeValidationRegex, castObject.passcodeValidationRegex));
}

@end
