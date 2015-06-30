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
#import "ORKDefines_Private.h"

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
    BOOL itemsHaveNonUniqueIdentifiers = ( [nonUniqueIdentifiers count] != [uniqueIdentifiers count] );
    
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
    self = [super init];
    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(identifier);
        
        _identifier = [identifier copy];
        _text = [text copy];
        _answerFormat = [answerFormat copy];
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
    item.placeholder = self.placeholder;
    return item;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, identifier, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, text, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, placeholder, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, answerFormat, ORKAnswerFormat);
        ORK_DECODE_OBJ_CLASS(aDecoder, step, ORKFormStep);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, identifier);
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
            && ORKEqualObjects(self.text, castObject.text)
            && ORKEqualObjects(self.placeholder, castObject.placeholder)
            && ORKEqualObjects(self.answerFormat, castObject.answerFormat));
}

- (NSUInteger)hash {
     // Ignore the step reference - it's not part of the content of this item
    return [_identifier hash] ^ [_text hash] ^ [_placeholder hash] ^ [_answerFormat hash];
}

- (ORKAnswerFormat *)impliedAnswerFormat {
    return [self.answerFormat impliedAnswerFormat];
}

- (ORKQuestionType)questionType {
    return [[self impliedAnswerFormat] questionType];
}

@end

@implementation ORKReviewStep: ORKFormStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(nullable NSString *)title
                              text:(nullable NSString *)text {
    self = [super initWithIdentifier:identifier title:title text:text];
    if (self) {
        _skippedItemText = ORKLocalizedString(@"SKIPPED_REVIEWITEM_TITLE", nil);
    }
    return self;
}

- (void)setTaskResult:(ORKTaskResult * __nullable)taskResult {
    [self setFormItems:nil];
    if (taskResult && [self task]) {
        NSArray<ORKStepResult*>* stepResults = (NSArray<ORKStepResult*>*) taskResult.results;
        NSMutableArray<ORKFormItem*>* formItems = [NSMutableArray<ORKFormItem*> new];
        for (ORKStepResult* stepResult in stepResults) {
            ORKStep* step = [[self task] stepWithIdentifier:stepResult.identifier];
            if (step && step.identifier != self.identifier) {
                [formItems addObjectsFromArray:[self reviewItemsForStep:step result:stepResult]];
            }
        }
        [self setFormItems:formItems];
    }
}

- (NSArray<ORKFormItem*>*)reviewItemsForStep:(ORKStep*)step result:(ORKStepResult*)result {
    NSMutableArray<ORKFormItem*>* reviewItems = [NSMutableArray<ORKFormItem *> new];
    if ([step isKindOfClass:[ORKQuestionStep class]]) {
        [reviewItems addObject: [[ORKFormItem alloc] initWithSectionTitle:step.title]];
        ORKQuestionStep* questionStep = (ORKQuestionStep*) step;
        if ([[result resultForIdentifier:questionStep.identifier] isKindOfClass:[ORKQuestionResult class]]) {
            ORKQuestionResult* questionResult = (ORKQuestionResult*) [result resultForIdentifier:questionStep.identifier];
            [reviewItems addObjectsFromArray:[self reviewItemsForAnswerWithFormat:questionStep.answerFormat result:questionResult targetStepIdentifier:questionStep.identifier]];
        }
        
    } else if ([step isKindOfClass:[ORKFormStep class]]) {
        ORKFormStep* formStep = (ORKFormStep*) step;
        for (ORKFormItem* formItem in formStep.formItems) {
            [reviewItems addObject: [[ORKFormItem alloc] initWithSectionTitle:[[step.title stringByAppendingString:@" - "] stringByAppendingString:formItem.text]]];
            if ([[result resultForIdentifier:formItem.identifier] isKindOfClass:[ORKQuestionResult class]]){
                ORKQuestionResult* questionResult = (ORKQuestionResult*) [result resultForIdentifier:formItem.identifier];
                [reviewItems addObjectsFromArray: [self reviewItemsForAnswerWithFormat:formItem.answerFormat result:questionResult targetStepIdentifier:formStep.identifier]];
            }
        }
    }
    return reviewItems;
}

- (NSArray<ORKFormItem*>*)reviewItemsForAnswerWithFormat:(ORKAnswerFormat*)answerFormat result:(ORKQuestionResult*)result targetStepIdentifier:(NSString*)targetStepIdentifier {
    NSMutableArray<ORKFormItem *>* reviewItems = [NSMutableArray<ORKFormItem *> new];
    if ([answerFormat questionResultClass] != [result class]) {
        return reviewItems;
    }
    BOOL skipped = NO;
    NSString* reviewItemIdentifier = [[NSUUID alloc] init].UUIDString;
    if ([answerFormat isKindOfClass:[ORKTextChoiceAnswerFormat class]]) {
        ORKTextChoiceAnswerFormat* textChoiceAnswerFormat = (ORKTextChoiceAnswerFormat*) answerFormat;
        ORKChoiceQuestionResult* choiceQuestionResult = (ORKChoiceQuestionResult*) result;
        skipped = choiceQuestionResult.choiceAnswers == nil;
        if (!skipped) {
            NSString* reviewItemText = nil;
            NSString* reviewItemDetailText = nil;
            for (id<NSCopying,NSCoding,NSObject> choiceAnswer in choiceQuestionResult.choiceAnswers) {
                for (ORKTextChoice* textChoice in textChoiceAnswerFormat.textChoices) {
                    if (textChoice.value == choiceAnswer) {
                        reviewItemText = reviewItemText == nil ? textChoice.text : [[reviewItemText stringByAppendingString:@"\n"] stringByAppendingString:textChoice.text];
                        reviewItemDetailText = reviewItemDetailText == nil ? textChoice.detailText : [[reviewItemDetailText stringByAppendingString:@"\n"] stringByAppendingString:textChoice.detailText];
                    }
                }
            }
            if (reviewItemText != nil) {
                ORKReviewAnswerFormat* reviewItemAnswerFormat = [[ORKReviewAnswerFormat alloc] initWithTargetStepIdentifier:targetStepIdentifier text:reviewItemText detailText:reviewItemDetailText];
                ORKFormItem* reviewItem = [[ORKFormItem alloc] initWithIdentifier:reviewItemIdentifier text:nil answerFormat: reviewItemAnswerFormat];
                [reviewItems addObject:reviewItem];
            }
        }
    } else if ([answerFormat isKindOfClass:[ORKBooleanAnswerFormat class]])  {
        ORKBooleanQuestionResult* booleanQuestionResult = (ORKBooleanQuestionResult*) result;
        skipped = booleanQuestionResult.booleanAnswer == nil;
        if (!skipped) {
            NSString* reviewItemText = booleanQuestionResult.booleanAnswer.boolValue == NO ? ORKLocalizedString(@"BOOL_NO", nil) : ORKLocalizedString(@"BOOL_YES", nil);;
            ORKReviewAnswerFormat* reviewItemAnswerFormat = [[ORKReviewAnswerFormat alloc] initWithTargetStepIdentifier:targetStepIdentifier text:reviewItemText detailText: nil];
            ORKFormItem* reviewItem = [[ORKFormItem alloc] initWithIdentifier:reviewItemIdentifier text:nil answerFormat: reviewItemAnswerFormat];
            [reviewItems addObject:reviewItem];
        }
    } else if ([answerFormat isKindOfClass: [ORKTimeIntervalAnswerFormat class]]) {
        ORKTimeIntervalQuestionResult* timeIntervalQuestionResult = (ORKTimeIntervalQuestionResult*) result;
        skipped = timeIntervalQuestionResult.intervalAnswer == nil;
        if (!skipped) {
            NSString* reviewItemText = [ORKTimeIntervalLabelFormatter() stringFromTimeInterval: [timeIntervalQuestionResult.intervalAnswer floatValue]];
            ORKReviewAnswerFormat* reviewItemAnswerFormat = [[ORKReviewAnswerFormat alloc] initWithTargetStepIdentifier:targetStepIdentifier text:reviewItemText detailText: nil];
            ORKFormItem* reviewItem = [[ORKFormItem alloc] initWithIdentifier:reviewItemIdentifier text:nil answerFormat: reviewItemAnswerFormat];
            [reviewItems addObject:reviewItem];
        }
    }
    if (skipped) {
        ORKReviewAnswerFormat* reviewItemAnswerFormat = [[ORKReviewAnswerFormat alloc] initWithTargetStepIdentifier:targetStepIdentifier text:_skippedItemText detailText:nil];
        ORKFormItem* reviewItem = [[ORKFormItem alloc] initWithIdentifier:reviewItemIdentifier text:nil answerFormat: reviewItemAnswerFormat];
        [reviewItems addObject:reviewItem];
    }
    return reviewItems;
}

@end