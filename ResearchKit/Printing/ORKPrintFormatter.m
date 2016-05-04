/*
 Copyright (c) 2015, Oliver Schaefer
 
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


#import "ORKPrintFormatter.h"
#import "ORKQuestionStep.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKFormStep.h"
#import "ORKFormItem_Internal.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKResult_Private.h"
#import "ORKChoiceAnswerFormatHelper.h"



@implementation ORKHTMLPrintFormatter {
    id<ORKTask> _task;
    ORKTaskResult *_taskResult;
    NSMutableArray<ORKStep *> *_steps;
    NSMutableDictionary<NSString *, ORKStepResult *> *_stepResults;
}

- (instancetype)initWithMarkupText:(NSString *)markupText {
    self = [super initWithMarkupText:markupText];
    if (self) {
        _task = nil;
        _taskResult = nil;
        _steps = [[NSMutableArray alloc] initWithArray:@[]];
        _stepResults = [[NSMutableDictionary alloc] init];
    }
    return self;

}

- (instancetype)initWithTask:(id<ORKTask>)task steps:(NSArray<ORKStep *> *)steps andResult:(nullable ORKTaskResult *)result {
    self = [self initWithMarkupText:@""];
    if (self) {
        _task = task;
        _taskResult = result;
        [_steps addObjectsFromArray:steps];
        for (ORKStep *step in _steps) {
            _stepResults[step.identifier] = [result stepResultForStepIdentifier:step.identifier];
        }
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step andResult:(ORKStepResult *)result {
    self = [self initWithMarkupText:@""];
    if (self) {
        [_steps addObject:step];
        _stepResults[step.identifier] = result;
    }
    return self;
}

- (void)prepare {
    NSMutableArray *discardedSteps = [[NSMutableArray alloc] init];
    for (ORKStep *step in _steps) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(printFormatter:shouldFormatStep:withResult:)]) {
            if (![self.delegate printFormatter:self shouldFormatStep:step withResult:_stepResults[step.identifier]]) {
                [discardedSteps addObject:step];
            }
        }
    }
    for (ORKStep *step in discardedSteps) {
        [_stepResults removeObjectForKey:step.identifier];
        [_steps removeObject:step];
    }
    if (_task) {
        //TODO: add implementation
    } else {
        ORKStep *step = _steps.firstObject;
        [self setMarkupText:[self HTMLFromStep:step withResult:_stepResults[step.identifier] addSurroundingHTMLTags:YES]];
    }
}

#pragma mark - internal

- (NSString *)HTMLFromStep:(ORKStep *)step withResult:(ORKStepResult *)result addSurroundingHTMLTags:(BOOL)addSurroundingHTMLTags {
    NSString *stepHeader = [self HTMLfromTemplate:@"STEP_HEADER", step.title, step.text];
    NSString *stepBody = @"";
    if ([step isKindOfClass:[ORKQuestionStep class]]) {
        stepBody = [self HTMLfromQuestionStep:(ORKQuestionStep *)step andResult:result];
    } else if ([step isKindOfClass:[ORKFormStep class]]) {
        stepBody = [self HTMLfromFormStep:(ORKFormStep *)step andResult:result];
    }
    NSString *stepFooter = @"";
    if (self.options & ORKPrintFormatterOptionIncludeTimestamp) {
        //TODO: use ORKLocalizedString
        stepFooter = [self HTMLfromTemplate:@"STEP_FOOTER", @"Start Date", [self stringFromDate:result.startDate], @"End Date", [self stringFromDate:result.endDate]];
    }
    NSString *stepHTML = [self HTMLfromTemplate:@"STEP", stepHeader, stepBody, stepFooter];
    return addSurroundingHTMLTags ? [self HTMLfromTemplate:@"HTML", _styleSheetContent, stepHTML] : stepHTML;
}

- (NSString *)HTMLfromTemplate:(NSString *)name, ... {
    NSString *format = [ORKBundle() localizedStringForKey:name value:@"" table:@"HTMLTemplates"];
    NSMutableArray<NSString *> *arguments = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, name);
    for (NSUInteger count = 0; count < [format componentsSeparatedByString:@"%@"].count-1; count++) {
        NSString *stringArgument = va_arg(args, NSString *);
        [arguments addObject:stringArgument != nil ? stringArgument : @""];
    }
    va_end(args);
    for (NSString * stringArgument in arguments) {
        NSRange location = [format rangeOfString:@"%@"];
        format = [format stringByReplacingCharactersInRange:location withString:stringArgument];
    }
    return format;
}

- (NSString *)HTMLfromQuestionStep:(ORKQuestionStep *)questionStep andResult:(ORKStepResult *)result {
    ORKQuestionResult *questionResult = (ORKQuestionResult *)result.results.firstObject;
    return [self HTMLfromTemplate:@"QUESTION_STEP_ANSWER", [self HTMLfromAnswerFormat:questionStep.impliedAnswerFormat andResult:questionResult]];
}

- (NSString *)HTMLfromAnswerFormat:(ORKAnswerFormat *)answerFormat andResult:(ORKQuestionResult *)result {
    NSString *answerHTML = @"";
    NSArray *validHelperClasses = @[[ORKTextChoiceAnswerFormat class], [ORKTextScaleAnswerFormat class], [ORKValuePickerAnswerFormat class]];
    if ([validHelperClasses containsObject:[answerFormat class]]) {
        answerHTML = [self HTMLfromChoiceAnswerFormat:answerFormat andResult:result];
    } else if ([answerFormat isKindOfClass:[ORKImageChoiceAnswerFormat class]]) {
        //TODO: add implementation
    } else if ([answerFormat isKindOfClass:[ORKLocationAnswerFormat class]]) {
        //TODO: add implementation
    } else if (!result.isAnswerEmpty) {
        answerHTML = [self HTMLfromTemplate:@"STEP_SELECTED_ANSWER", nil, [answerFormat stringForAnswer:result.answer]];
    }
    return answerHTML;
}

- (NSString *)HTMLfromChoiceAnswerFormat:(ORKAnswerFormat *)answerFormat andResult:(ORKQuestionResult *)result {
    NSString *answerHTML = @"";
    ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
    if (self.options & ORKPrintFormatterOptionIncludeChoices) {
        for (NSUInteger choiceIndex = 0; choiceIndex < [helper choiceCount]; choiceIndex++) {
            id answer = [helper answerForSelectedIndex:choiceIndex];
            if (!ORKIsAnswerEmpty(answer)) {
                answerHTML = [@[answerHTML, [self HTMLfromTemplate:([result.answer isEqual:answer] ? @"STEP_SELECTED_ANSWER" : @"STEP_UNSELECTED_ANSWER") , nil, [helper stringForChoiceAnswer:answer]]] componentsJoinedByString:@"\n"];
            }
        }
    } else if (!result.isAnswerEmpty) {
        for (NSString *answerString in [helper stringsForChoiceAnswer:result.answer]) {
            answerHTML = [@[answerHTML, [self HTMLfromTemplate:@"STEP_SELECTED_ANSWER", nil, answerString]] componentsJoinedByString:@"\n"];
        }
    }
    return answerHTML;
}

- (NSString *)HTMLfromFormStep:(ORKFormStep *)formStep andResult:(ORKStepResult *)result {
    NSString *formStepHTML = @"";
    for (ORKFormItem *item in formStep.formItems) {
        if (item.identifier != nil) {
            NSUInteger index = [result.results indexOfObjectPassingTest:^BOOL(ORKResult *result, NSUInteger index, BOOL *stop) {
                return [result.identifier isEqualToString:item.identifier];
            }];
            ORKQuestionResult *questionResult = index != NSNotFound ? (ORKQuestionResult *)result.results[index] : nil;
            formStepHTML = [@[formStepHTML, [self HTMLfromTemplate:@"FORM_STEP_ANSWER", item.text, [self HTMLfromAnswerFormat:item.impliedAnswerFormat andResult:questionResult]]] componentsJoinedByString:@"\n<br/>\n"];
        } else {
            formStepHTML = [@[formStepHTML, [self HTMLfromTemplate:@"FORM_STEP", item.text]] componentsJoinedByString:@"\n"];
        }
    }
    return formStepHTML;
}

//TODO: revise date to string conversion
- (NSString *)stringFromDate:(NSDate *)date {
    if (!date) {
        return @"";
    }
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterMediumStyle;
    });
    return [formatter stringFromDate:date];
}

@end
