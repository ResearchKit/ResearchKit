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

#import "ORKFormStepViewController.h"
#import "ORKBodyItem.h"
#import "ORKLearnMoreItem.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKFormItem_Internal.h"
#import "ORKStep_Private.h"

#import "ORKHelpers_Internal.h"

#if HEALTH
#import <HealthKit/HealthKit.h>
#endif

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
        self.useCardView = YES;
        self.cardViewStyle = ORKCardViewStyleDefault;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.optional = YES;
        self.useSurveyMode = YES;
        self.useCardView = YES;
        self.cardViewStyle = ORKCardViewStyleDefault;
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
    step.cardViewStyle = self.cardViewStyle;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            (ORKEqualObjects(self.formItems, castObject.formItems)) &&
            self.cardViewStyle == castObject.cardViewStyle);
}

- (NSUInteger)hash {
    return super.hash ^ self.formItems.hash;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    // We enter this code-path only for formSteps which have ONE valid answer format (the other type of formItem would likely be a section header)
    ORKFormItem *item;
    for (item in self.formItems) {
        if (item.answerFormat) {
            break;
        }
    }
    return item.answerFormat;
}

- (ORKQuestionType)questionType {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    return impliedFormat.questionType;
}

- (BOOL)isFormatImmediateNavigation {
    // Only allow immediate navigation for formSteps which contain only ONE formItem with a valid answer format
    int numberOfAnswerFormats = 0;
    for (ORKFormItem *item in self.formItems) {
        if (item.answerFormat) {
            numberOfAnswerFormats += 1;
            if (numberOfAnswerFormats > 1) {
                return false;
            }
        }
    }
    ORKQuestionType questionType = self.questionType;
    return (self.optional == NO) && ((questionType == ORKQuestionTypeBoolean) || (questionType == ORKQuestionTypeSingleChoice));
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, formItems, ORKFormItem);
        ORK_DECODE_BOOL(aDecoder, useCardView);
        ORK_DECODE_OBJ(aDecoder, footerText);
        ORK_DECODE_ENUM(aDecoder, cardViewStyle);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, formItems);
    ORK_ENCODE_BOOL(aCoder, useCardView);
    ORK_ENCODE_OBJ(aCoder, footerText);
    ORK_ENCODE_ENUM(aCoder, cardViewStyle);
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

#if HEALTH
- (NSSet<HKObjectType *> *)requestedHealthKitTypesForReading {
    NSMutableSet<HKObjectType *> *healthTypes = [NSMutableSet set];
    
    for (ORKFormItem *formItem in self.formItems) {
        ORKAnswerFormat *answerFormat = [formItem answerFormat];
        HKObjectType *objType = [answerFormat healthKitObjectTypeForAuthorization];
        if (objType) {
            [healthTypes addObject:objType];
        }
    }
    
    return healthTypes.count ? healthTypes : nil;
}
#endif

@end


@implementation ORKFormItem

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(ORKAnswerFormat *)answerFormat {
    return [self initWithIdentifier:identifier
                               text:text
                         detailText:nil
                      learnMoreItem:nil
                      showsProgress:YES
                       answerFormat:answerFormat
                            tagText: nil
                           optional:YES];
}

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(ORKAnswerFormat *)answerFormat optional:(BOOL)optional {
    return [self initWithIdentifier:identifier
                               text:text
                         detailText:nil
                      learnMoreItem:nil
                      showsProgress:YES
                       answerFormat:answerFormat
                            tagText: nil
                           optional:optional];
}

- (instancetype)initWithSectionTitle:(NSString *)sectionTitle {
    self = [super init];
    if (self) {
        _text = [sectionTitle copy];
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier text:(nullable NSString *)text detailText:(nullable NSString *)detailText learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem showsProgress:(BOOL)showsProgress answerFormat:(nullable ORKAnswerFormat *)answerFormat tagText:(nullable NSString *)tagText optional:(BOOL) optional {
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        _identifier = [identifier copy];
        _text = [text copy];
        _detailText = [detailText copy];
        _learnMoreItem = [learnMoreItem copy];
        _showsProgress = showsProgress;
        _answerFormat = [answerFormat copy];
        _tagText = [tagText copy];
        _optional = optional;
    }
    return self;
}

- (instancetype)initWithSectionTitle:(nullable NSString *)sectionTitle detailText:(nullable NSString *)text learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem showsProgress:(BOOL)showsProgress {
    self = [super init];
    if (self) {
        _text = [sectionTitle copy];
        _detailText = [text copy];
        _learnMoreItem = [learnMoreItem copy];
        _showsProgress = showsProgress;
    }
    return self;
}

- (ORKFormItem *)confirmationAnswerFormItemWithIdentifier:(NSString *)identifier
                                                     text:(nullable NSString *)text
                                             errorMessage:(NSString *)errorMessage {
    
    if (![self.answerFormat conformsToProtocol:@protocol(ORKConfirmAnswerFormatProvider)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Answer format %@ does not conform to confirmation protocol", self.answerFormat]
                                     userInfo:nil];
    }
    
    ORKAnswerFormat *answerFormat = [(id <ORKConfirmAnswerFormatProvider>)self.answerFormat
                                     confirmationAnswerFormatWithOriginalItemIdentifier:self.identifier
                                     errorMessage:errorMessage];
    ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:identifier
                                                           text:text
                                                   answerFormat:answerFormat
                                                       optional:self.optional];
    return item;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKFormItem *item = [[[self class] allocWithZone:zone] initWithIdentifier:[_identifier copy] text:[_text copy] answerFormat:[_answerFormat copy]];
    item->_optional = _optional;
    item->_placeholder = _placeholder;
    item->_detailText = [_detailText copy];
    item->_learnMoreItem = [_learnMoreItem copy];
    item->_showsProgress = _showsProgress;
    item->_tagText = [_tagText copy];
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_BOOL(aDecoder, optional);
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, detailText, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, learnMoreItem, ORKLearnMoreItem);
        ORK_DECODE_BOOL(aDecoder, showsProgress);
        ORK_DECODE_OBJ_CLASS(aDecoder, placeholder, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, answerFormat, ORKAnswerFormat);
        ORK_DECODE_OBJ_CLASS(aDecoder, step, ORKFormStep);
        ORK_DECODE_OBJ_CLASS(aDecoder, tagText, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
    ORK_ENCODE_BOOL(aCoder, optional);
    ORK_ENCODE_OBJ(aCoder, text);
    ORK_ENCODE_OBJ(aCoder, detailText);
    ORK_ENCODE_OBJ(aCoder, learnMoreItem);
    ORK_ENCODE_BOOL(aCoder, showsProgress);
    ORK_ENCODE_OBJ(aCoder, placeholder);
    ORK_ENCODE_OBJ(aCoder, answerFormat);
    ORK_ENCODE_OBJ(aCoder, step);
    ORK_ENCODE_OBJ(aCoder, tagText);

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
            && ORKEqualObjects(self.detailText, castObject.detailText)
            && ORKEqualObjects(self.learnMoreItem, castObject.learnMoreItem)
            && self.showsProgress == castObject.showsProgress
            && ORKEqualObjects(self.placeholder, castObject.placeholder)
            && ORKEqualObjects(self.tagText, castObject.tagText)
            && ORKEqualObjects(self.answerFormat, castObject.answerFormat));
}

- (NSUInteger)hash {
     // Ignore the step reference - it's not part of the content of this item
    return _identifier.hash ^ _text.hash ^ _placeholder.hash ^ _answerFormat.hash ^ (_optional ? 0xf : 0x0) ^ _detailText.hash ^ _learnMoreItem.hash ^ (_showsProgress ? 0xf : 0x0) ^ _tagText.hash;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return [self.answerFormat impliedAnswerFormat];
}

- (ORKQuestionType)questionType {
    return [[self impliedAnswerFormat] questionType];
}

@end
