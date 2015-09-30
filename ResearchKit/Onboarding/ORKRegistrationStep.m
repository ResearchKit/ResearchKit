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

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title text:(NSString *)text {
    ORKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier message:(NSString *)message options:(ORKRegistrationStepOption)options {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _message = message;
        _options = options;
    }
    return self;
}

- (NSArray<ORKFormItem *> *)formItems {
    NSMutableArray *formItems = [NSMutableArray new];
    if (! (_options & ORKRegistrationStepExcludeFirstName)) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"first_name"
                                                               text:@"First name"
                                                       answerFormat:answerFormat];
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeLastName)) {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"last_name"
                                                               text:@"Last name"
                                                       answerFormat:answerFormat];
        [formItems addObject:item];
    }

    if (! (_options & ORKRegistrationStepExcludeEmail)) {
        ORKEmailAnswerFormat *answerFormat = [ORKAnswerFormat emailAnswerFormat];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"email"
                                                               text:@"Email"
                                                       answerFormat:answerFormat];
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
                                                               text:@"Password"
                                                       answerFormat:answerFormat];
        [formItems addObject:item];
    }
    
    if (! (_options & ORKRegistrationStepExcludeGender)) {
        NSArray *textChoices = @[[ORKTextChoice choiceWithText:@"Male" value:@0],
                                 [ORKTextChoice choiceWithText:@"Female" value:@1]];
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:textChoices];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"gender"
                                                               text:@"Gender"
                                                       answerFormat:answerFormat];
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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, message);
    ORK_ENCODE_INTEGER(aCoder, options);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKRegistrationStep *step = [[[self class] allocWithZone:zone] init];
    step->_message = self.message;
    step->_options = self.options;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.message, castObject.message) &&
            self.options == castObject.options);
}

@end
