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


#import "ORKLoginStep.h"
#import "ORKDefines_Private.h"
#import "ORKHelpers.h"


@implementation ORKLoginStep

- (Class)stepViewControllerClass {
    return [_loginViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    ORKThrowMethodUnavailableException();
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text
               loginViewController:(ORKLoginStepViewController *)loginViewController {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.title = title;
        self.text = text;
        _loginViewController = loginViewController;
    }
    return self;
}

- (BOOL)isOptional {
    return YES;
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
    }
    
    return formItems;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, loginViewController);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, loginViewController);
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKLoginStep *step = [super copyWithZone:zone];
    step->_loginViewController = self.loginViewController;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.loginViewController, castObject.loginViewController));
}

@end
