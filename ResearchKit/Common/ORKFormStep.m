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


#import "ORKFormStep.h"
#import "ORKFormItem_Internal.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKStep_Private.h"
#import "ORKFormStepViewController.h"


@implementation ORKFormStep

+ (Class)stepViewControllerClass {
    return [ORKFormStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.title = title;
        self.text = text;
        self.optional = YES;
        self.useSurveyMode = YES;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.optional = YES;
        self.useSurveyMode = YES;
    }
    return self;
}


- (void)validateParameters {
    [super validateParameters];
    
    for (ORKFormItem *item in _formItems) {
        [item.answerFormat validateParameters];
    }
    
    [self validateIdentifiersUnique];
}

- (void)validateIdentifiersUnique {
    NSArray *uniqueIdentifiers = [_formItems valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
    NSArray *nonUniqueIdentifiers = [_formItems valueForKeyPath:@"@unionOfObjects.identifier"];
    BOOL itemsHaveNonUniqueIdentifiers = ( nonUniqueIdentifiers.count != uniqueIdentifiers.count );
    
    if (itemsHaveNonUniqueIdentifiers) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Each form item should have a unique identifier" userInfo:nil];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKFormStep *step = [super copyWithZone:zone];
    step.formItems = ORKArrayCopyObjects(_formItems);
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame && ORKEqualObjects(self.formItems, castObject.formItems);
}

- (NSUInteger)hash {
    return [super hash] ^ [self.formItems hash];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, formItems, ORKFormItem);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, formItems);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)setFormItems:(NSArray<ORKFormItem *> *)formItems {
    // unset removed formItems
    for (ORKFormItem *item in _formItems) {
         item.step = nil;
    }
    
    _formItems = formItems;
    
    for (ORKFormItem *item in _formItems) {
        item.step = self;
    }
}

@end


@implementation ORKFormItem

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(ORKAnswerFormat *)answerFormat {
    return [self initWithIdentifier:identifier text:text answerFormat:answerFormat optional:YES];
}

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(ORKAnswerFormat *)answerFormat optional:(BOOL) optional {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        _identifier = [identifier copy];
        _text = [text copy];
        _answerFormat = [answerFormat copy];
        _optional = optional;
    }
    return self;
}

- (instancetype)initWithSectionTitle:(NSString *)sectionTitle {
    self = [super init];
    if (self) {
        _text = [sectionTitle copy];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKFormItem *item = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy] text:[_text copy] answerFormat:[_answerFormat copy]];
    item.optional = _optional;
    item.placeholder = _placeholder;
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_BOOL(aDecoder, optional);
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, placeholder, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, answerFormat, ORKAnswerFormat);
        ORK_DECODE_OBJ_CLASS(aDecoder, step, ORKFormStep);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_BOOL(aCoder, optional);
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, placeholder);
    ORK_ENCODE_OBJ(aCoder, answerFormat);
    ORK_ENCODE_OBJ(aCoder, step);

}

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }
    
    // Ignore the step reference - it's not part of the content of this item
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.identifier, castObject.identifier)
            && self.optional == castObject.optional
            && ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.placeholder, castObject.placeholder)
            && ORKEqualObjects(self.answerFormat, castObject.answerFormat));
}

- (NSUInteger)hash {
     // Ignore the step reference - it's not part of the content of this item
    return [_identifier hash] ^ [_text hash] ^ [_placeholder hash] ^ [_answerFormat hash] ^ (_optional ? 0xf : 0x0);
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return [self.answerFormat impliedAnswerFormat];
}

- (ORKQuestionType)questionType {
    return [[self impliedAnswerFormat] questionType];
}

@end
