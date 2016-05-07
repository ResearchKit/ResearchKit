/*
 Copyright (c) 2016, Oliver Schaefer
 
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
#import "ORKReviewStep.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKResult_Private.h"
#import "ORKChoiceAnswerFormatHelper.h"
#import "ORKDefines_Private.h"



static const CGFloat POINTS_PER_INCH = 72;

#pragma mark - ORKHTMLPrintFormatter

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
        _styleSheetContent = @"";
        self.perPageContentInsets = UIEdgeInsetsMake(POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f);
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
    NSMutableArray *formatableSteps = [[NSMutableArray alloc] init];
    for (ORKStep *step in _steps) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(printFormatter:shouldFormatStep:withResult:)]) {
            if ([self.delegate printFormatter:self shouldFormatStep:step withResult:_stepResults[step.identifier]]) {
                [formatableSteps addObject:step];
            }
        }
    }
    if (_task) {
        [self setMarkupText:[self HTMLFromTask:_task containingSteps:[formatableSteps copy] withResult:_taskResult]];
    } else {
        ORKStep *step = formatableSteps.firstObject;
        if (step) {
            [self setMarkupText:[self HTMLFromStep:step withResult:_stepResults[step.identifier] addSurroundingHTMLTags:YES]];
        }
    }
}

#pragma mark - internal

- (NSString *)HTMLFromTask:(id<ORKTask>)task containingSteps:(NSArray<ORKStep *> *)steps withResult:(ORKTaskResult *)result {
    NSString *taskTitle = @"";
    if (_delegate && [_delegate respondsToSelector:@selector(printFormatter:titleForTask:)]) {
        taskTitle = [_delegate printFormatter:self titleForTask:task];
    }
    NSString *taskBody = @"";
    for (ORKStep *step in steps) {
        taskBody = [@[taskBody, [self HTMLFromStep:step withResult:_stepResults[step.identifier] addSurroundingHTMLTags:NO]] componentsJoinedByString:@""];
    }
    NSString *taskHTML = [_ORK_HTMLfromTemplate(@"TASK"), taskTitle, taskBody];
    return [_ORK_HTMLfromTemplate(@"HTML"), _styleSheetContent, taskHTML];
}

- (NSString *)HTMLFromStep:(ORKStep *)step withResult:(ORKStepResult *)result addSurroundingHTMLTags:(BOOL)addSurroundingHTMLTags {
    NSString *stepHeader = [_ORK_HTMLfromTemplate(@"STEP_HEADER"), step.title ? step.title : @"", step.text ? step.text : @""];
    NSString *stepBody = @"";
    if ([step isKindOfClass:[ORKQuestionStep class]]) {
        stepBody = [self HTMLfromQuestionStep:(ORKQuestionStep *)step andResult:result];
    } else if ([step isKindOfClass:[ORKFormStep class]]) {
        stepBody = [self HTMLfromFormStep:(ORKFormStep *)step andResult:result];
    } else if ([step isKindOfClass:[ORKReviewStep class]]) {
        stepBody = [self HTMLfromReviewStep:(ORKReviewStep *)step andResult:result];
    }
    NSString *stepFooter = @"";
    if (self.options & ORKPrintFormatterOptionIncludeTimestamp) {
        //TODO: use ORKLocalizedString
        stepFooter = [_ORK_HTMLfromTemplate(@"STEP_FOOTER"), @"Start Date", [self stringFromDate:result.startDate], @"End Date", [self stringFromDate:result.endDate]];
    }
    NSString *stepHTML = [_ORK_HTMLfromTemplate(@"STEP"), stepHeader, stepBody, stepFooter];
    return addSurroundingHTMLTags ? [_ORK_HTMLfromTemplate(@"HTML"), _styleSheetContent, stepHTML] : stepHTML;
}

- (NSString *)HTMLfromQuestionStep:(ORKQuestionStep *)questionStep andResult:(ORKStepResult *)result {
    ORKQuestionResult *questionResult = (ORKQuestionResult *)result.results.firstObject;
    return [_ORK_HTMLfromTemplate(@"QUESTION_STEP_ANSWER"), [self HTMLfromAnswerFormat:questionStep.impliedAnswerFormat andResult:questionResult]];
}

- (NSString *)HTMLfromAnswerFormat:(ORKAnswerFormat *)answerFormat andResult:(ORKQuestionResult *)result {
    NSString *answerHTML = @"";
    NSArray *validHelperClasses = @[[ORKTextChoiceAnswerFormat class], [ORKTextScaleAnswerFormat class], [ORKValuePickerAnswerFormat class], [ORKImageChoiceAnswerFormat class]];
    if ([validHelperClasses containsObject:[answerFormat class]]) {
        answerHTML = [self HTMLfromChoiceAnswerFormat:answerFormat andResult:result];
    } else if ([answerFormat isKindOfClass:[ORKLocationAnswerFormat class]]) {
        ORKLocation *location = ((ORKLocationQuestionResult*)result).locationAnswer;
        __block UIImage *image;
        if (location) {
            MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
            options.size = CGSizeMake(200, 200);
            CLLocationDistance span = MAX(200, location.region.radius);
            options.region = MKCoordinateRegionMakeWithDistance(location.region.center, span, span);
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
            [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                image = snapshot.image;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2));
        }
        NSString *answerString = image ? [self HTMLFromImage:image withTitle:[answerFormat stringForAnswer:result.answer]] : @"&nbsp;";
        answerHTML = [_ORK_HTMLfromTemplate(@"STEP_SELECTED_ANSWER"), @"", answerString];
    } else {
        NSString *answerString = !result.isAnswerEmpty ? [answerFormat stringForAnswer:result.answer] : @"&nbsp;";
        answerHTML = [_ORK_HTMLfromTemplate(@"STEP_SELECTED_ANSWER"), @"", answerString];
    }
    return answerHTML;
}

- (NSString *)HTMLfromChoiceAnswerFormat:(ORKAnswerFormat *)answerFormat andResult:(ORKQuestionResult *)result {
    NSString *answerHTML = @"";
    ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
    if (self.options & ORKPrintFormatterOptionIncludeChoices) {
        for (NSUInteger choiceIndex = 0; choiceIndex < [helper choiceCount]; choiceIndex++) {
            BOOL isSelected = [result.answer isEqual:[helper answerForSelectedIndex:choiceIndex]];
            answerHTML = [@[answerHTML, [self HTMLfromAnswerOption:[helper answerOptionAtIndex:choiceIndex] isSelected:isSelected]] componentsJoinedByString:@""];
        }
    } else {
        for (NSNumber *choiceIndex in [helper selectedIndexesForAnswer:result.answer]) {
             answerHTML = [@[answerHTML, [self HTMLfromAnswerOption:[helper answerOptionAtIndex:choiceIndex.unsignedIntegerValue] isSelected:YES]] componentsJoinedByString:@""];
        }
    }
    return [answerHTML isEqualToString:@""] ? [_ORK_HTMLfromTemplate(@"STEP_SELECTED_ANSWER"), @"", @"&nbsp;"] : answerHTML;
}

- (NSString *)HTMLfromAnswerOption:(id<ORKAnswerOption>)answerOption isSelected:(BOOL)isSelected {
    NSString *answerHTML = @"";
    if ([answerOption isKindOfClass:[ORKTextChoice class]]) {
        ORKTextChoice *textChoice = (ORKTextChoice *)answerOption;
        NSString *textChoiceText = textChoice.text;
        if (textChoice.detailText) {
            textChoiceText = [@[textChoiceText, textChoice.detailText] componentsJoinedByString:@"<br/>"];
        }
        answerHTML = [_ORK_HTMLfromTemplate(isSelected ? @"STEP_SELECTED_ANSWER" : @"STEP_UNSELECTED_ANSWER"), @"", textChoiceText];
    } else if ([answerOption isKindOfClass:[ORKImageChoice class]]) {
        ORKImageChoice *imageChoice = (ORKImageChoice *)answerOption;
        answerHTML = isSelected ? [_ORK_HTMLfromTemplate(@"STEP_SELECTED_ANSWER"), @"", [self HTMLFromImage:imageChoice.selectedStateImage withTitle:imageChoice.text]] : [_ORK_HTMLfromTemplate(@"STEP_UNSELECTED_ANSWER"), @"", [self HTMLFromImage:imageChoice.normalStateImage withTitle:imageChoice.text]];
    }
    return answerHTML;
}

- (NSString *)HTMLFromImage:(UIImage *)image withTitle:(NSString *)title {
    //TODO: scale images
    NSData *imageData = UIImagePNGRepresentation(image);
    return imageData ? [_ORK_HTMLfromTemplate(@"IMAGE"), @(image.size.height), @(image.size.width), [imageData base64EncodedStringWithOptions:0], title] : @"";
}

- (NSString *)HTMLfromFormStep:(ORKFormStep *)formStep andResult:(ORKStepResult *)result {
    NSString *formStepHTML = @"";
    for (ORKFormItem *item in formStep.formItems) {
        if (item.identifier != nil) {
            NSUInteger index = [result.results indexOfObjectPassingTest:^BOOL(ORKResult *result, NSUInteger index, BOOL *stop) {
                return [result.identifier isEqualToString:item.identifier];
            }];
            ORKQuestionResult *questionResult = index != NSNotFound ? (ORKQuestionResult *)result.results[index] : @"";
            formStepHTML = [@[formStepHTML, [_ORK_HTMLfromTemplate(@"FORM_STEP_ANSWER"), item.text, [self HTMLfromAnswerFormat:item.impliedAnswerFormat andResult:questionResult]]] componentsJoinedByString:@"<br/>"];
        } else {
            formStepHTML = [@[formStepHTML, [_ORK_HTMLfromTemplate(@"FORM_STEP"), item.text]] componentsJoinedByString:@""];
        }
    }
    return formStepHTML;
}

- (NSString *)HTMLfromReviewStep:(ORKReviewStep *)reviewStep andResult:(ORKStepResult *)result {
    NSString *reviewStepHTML = @"";
    for (ORKStep *step in reviewStep.steps) {
        ORKStepResult *stepResult = [reviewStep.resultSource stepResultForStepIdentifier:step.identifier];
        reviewStepHTML = [@[reviewStepHTML, [self HTMLFromStep:step withResult:stepResult addSurroundingHTMLTags:NO]] componentsJoinedByString:@""];
    }
    return reviewStepHTML;
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

#pragma mark - ORKHTMLPrintPageRenderer

@implementation ORKHTMLPrintPageRenderer

- (void)drawHeaderForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)headerRect {
    if (_delegate && [_delegate respondsToSelector:@selector(printPageRenderer:headerContentForPageInRange:)]) {
        NSString *headerContent = [_delegate printPageRenderer:self headerContentForPageInRange:NSMakeRange(pageIndex+1, [self numberOfPages])];
        [self drawHTML:headerContent inRect:headerRect];
    }
}

- (void)drawFooterForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)footerRect {
    if (_delegate && [_delegate respondsToSelector:@selector(printPageRenderer:footerContentForPageInRange:)]) {
        NSString *footerContent = [_delegate printPageRenderer:self footerContentForPageInRange:NSMakeRange(pageIndex+1, [self numberOfPages])];
        [self drawHTML:footerContent inRect:footerRect];
    }
}

- (void)drawHTML:(NSString*)html inRect:(CGRect)rect {
    NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    [htmlString drawInRect:rect];
}
 
@end
