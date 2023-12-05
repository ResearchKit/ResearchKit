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

#import "ORKQuestionStep.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAnswerFormat_Private.h"
#import "ORKStep_Private.h"
#import "ORKHelpers_Internal.h"
#if TARGET_OS_IOS
#import "ORKQuestionStep_Private.h"
#import "ORKQuestionStepViewController.h"
#import "ORKLearnMoreItem.h"
#endif

#if TARGET_OS_IOS
ORKQuestionStepPresentationStyle const ORKQuestionStepPresentationStyleDefault = @"default";
ORKQuestionStepPresentationStyle const ORKQuestionStepPresentationStylePlatter = @"platter";
#endif

@implementation ORKQuestionStep
#if TARGET_OS_IOS
@synthesize presentationStyle = _presentationStyle;
#endif

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                      question:(nullable NSString *)question
                                    answer:(nullable ORKAnswerFormat *)answerFormat {
    
    ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:identifier];
    step.title = title;
    step.question = question;
    step.answerFormat = answerFormat;
    step.tagText = nil;
    return step;
}

#if TARGET_OS_IOS

+ (instancetype)platterQuestionWithIdentifier:(NSString *)identifier
                                     question:(NSString *)question
                                         text:(NSString *)text
                                 answerFormat:(ORKAnswerFormat<ORKAnswerFormatPlatterPresentable> *)answerFormat {
    
    ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:identifier];
    step.title = question;
    step.text = text;
    step.presentationStyle = ORKQuestionStepPresentationStylePlatter;
    step.answerFormat = answerFormat;
    step.tagText = nil;
    return step;
}

+ (Class)stepViewControllerClass {
    return [ORKQuestionStepViewController class];
}

+ (instancetype)questionStepWithIdentifier:(NSString *)identifier
                                     title:(nullable NSString *)title
                                  question:(nullable NSString *)question
                                    answer:(nullable ORKAnswerFormat *)answerFormat
                             learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem {
    
    ORKQuestionStep *step = [[ORKQuestionStep alloc] initWithIdentifier:identifier];
    step.title = title;
    step.question = question;
    step.answerFormat = answerFormat;
    step.learnMoreItem = learnMoreItem;
    step.tagText = nil;
    return step;
}

- (BOOL)isFormatChoiceWithImageOptions {
    return [[self impliedAnswerFormat] isKindOfClass:[ORKImageChoiceAnswerFormat class]];
}

- (BOOL)isFormatChoiceValuePicker {
    return [[self impliedAnswerFormat] isKindOfClass:[ORKValuePickerAnswerFormat class]];
}

- (BOOL)isFormatTextfield {
    ORKAnswerFormat *impliedAnswerFormat = [self impliedAnswerFormat];
    return [impliedAnswerFormat isKindOfClass:[ORKTextAnswerFormat class]] && ![(ORKTextAnswerFormat *)impliedAnswerFormat multipleLines];
}

- (NSSet<HKObjectType *> *)requestedHealthKitTypesForReading {
    HKObjectType *objType = [[self answerFormat] healthKitObjectTypeForAuthorization];
    return (objType != nil) ? [NSSet setWithObject:objType] : nil;
}

#endif

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.optional = YES;
        self.useSurveyMode = YES;
        self.useCardView = YES;
        self.showsProgress = YES;
        self.tagText = nil;

#if TARGET_OS_IOS
        self.presentationStyle = ORKQuestionStepPresentationStyleDefault;
#endif
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];

#if TARGET_OS_IOS
    if([self.answerFormat isKindOfClass:[ORKConfirmTextAnswerFormat class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"ORKConfirmTextAnswerFormat can only be used with an ORKFormStep."
                                     userInfo:nil];
    }

    if ([self.presentationStyle isEqualToString:ORKQuestionStepPresentationStylePlatter]) {
          
        if (![self.answerFormat conformsToProtocol:@protocol(ORKAnswerFormatPlatterPresentable)]) {
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"ORKQuestionStepPresentationStylePlatter must be paired with an ORKAnswerFormat which conforms to ORKAnswerFormatPlatterPresentable (aka: ORKTextChoiceAnswerFormat)"
                                         userInfo:nil];
        }
        if (self.useCardView != YES) {
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"ORKQuestionStepPresentationStylePlatter is only supported when `useCardView == YES`"
                                         userInfo:nil];
        }
        if (self.title == nil) {
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"ORKQuestionStepPresentationStylePlatter is only supported when `title != nil`"
                                         userInfo:nil];
        }
        if (self.question != nil) {
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:@"ORKQuestionStepPresentationStylePlatter is only supported when `question == nil`"
                                         userInfo:nil];
        }
    }
#endif
    
    [[self impliedAnswerFormat] validateParameters];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKQuestionStep *questionStep = [super copyWithZone:zone];
    questionStep.answerFormat = [self.answerFormat copy];
    questionStep.placeholder = [self.placeholder copy];

#if TARGET_OS_IOS
    questionStep.learnMoreItem = [self.learnMoreItem copy];
    questionStep.presentationStyle = self.presentationStyle;
#endif
    questionStep.question = [self.question copy];
    questionStep.tagText = [self.tagText copy];
    
    return questionStep;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame &&
    ORKEqualObjects(self.answerFormat, castObject.answerFormat) &&
    ORKEqualObjects(self.placeholder, castObject.placeholder) &&
#if TARGET_OS_IOS
    ORKEqualObjects(self.presentationStyle, castObject.presentationStyle) &&
    ORKEqualObjects(self.learnMoreItem, castObject.learnMoreItem) &&
#endif
    ORKEqualObjects(self.tagText, castObject.tagText);
}

- (NSUInteger)hash {
    
    return super.hash ^
    self.answerFormat.hash ^
    self.question.hash ^
    self.questionType ^
    self.placeholder.hash ^
    (_useCardView ? 0xf : 0x0) ^
    self.tagText.hash
#if TARGET_OS_IOS
    ^ self.learnMoreItem.hash
    ^ _presentationStyle.hash
#endif
    ;
}

- (void)setQuestion:(NSString *)question {
    _question = question;
}

- (ORKQuestionType)questionType {
    ORKAnswerFormat *impliedFormat = [self impliedAnswerFormat];
    return impliedFormat.questionType;
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return [self.answerFormat impliedAnswerFormat];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, answerFormat, ORKAnswerFormat);
        ORK_DECODE_OBJ_CLASS(aDecoder, placeholder, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, question, NSString);
#if TARGET_OS_IOS
        ORK_DECODE_OBJ_CLASS(aDecoder, learnMoreItem, ORKLearnMoreItem);
        ORK_DECODE_OBJ_CLASS(aDecoder, presentationStyle, NSString);
#endif
        ORK_DECODE_BOOL(aDecoder, useCardView);
        ORK_DECODE_OBJ_CLASS(aDecoder, tagText, NSString);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    ORK_ENCODE_OBJ(aCoder, answerFormat);
    ORK_ENCODE_OBJ(aCoder, placeholder);
    ORK_ENCODE_OBJ(aCoder, question);
#if TARGET_OS_IOS
    ORK_ENCODE_OBJ(aCoder, learnMoreItem);
    ORK_ENCODE_OBJ(aCoder, presentationStyle);
#endif
    ORK_ENCODE_BOOL(aCoder, useCardView);
    ORK_ENCODE_OBJ(aCoder, tagText);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isFormatImmediateNavigation {
    ORKQuestionType questionType = self.questionType;
    return (self.optional == NO) && ((questionType == ORKQuestionTypeBoolean) || (questionType == ORKQuestionTypeSingleChoice));
}

- (BOOL)isFormatFitsChoiceCells {
    
    if ([self formatRequiresSwiftUI]) {
        return NO;
    }
    
#if TARGET_OS_IOS
    return ((self.questionType == ORKQuestionTypeSingleChoice && ![self isFormatChoiceWithImageOptions] && ![self isFormatChoiceValuePicker]) ||
            (self.questionType == ORKQuestionTypeMultipleChoice && ![self isFormatChoiceWithImageOptions]) ||
            self.questionType == ORKQuestionTypeBoolean);
#else
    return ((self.questionType == ORKQuestionTypeSingleChoice) ||
    (self.questionType == ORKQuestionTypeMultipleChoice) ||
    self.questionType == ORKQuestionTypeBoolean);
#endif

}

- (BOOL)formatRequiresTableView {
    return [self isFormatFitsChoiceCells];
}

- (BOOL)formatRequiresSwiftUI {
    
    if ([_answerFormat isKindOfClass:ORKTextChoiceAnswerFormat.class] && self.questionType != ORKQuestionTypeBoolean) {
        ORKTextChoiceAnswerFormat *textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat *)_answerFormat;
        
        for (ORKTextChoice* textChoice in textChoiceAnswerFormat.textChoices) {
            if (textChoice.image != nil) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
