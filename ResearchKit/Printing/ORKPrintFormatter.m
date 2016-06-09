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
#import <AVFoundation/AVFoundation.h>


static const CGFloat POINTS_PER_INCH = 72;

#pragma mark - ORKHTMLPrintFormatter

@implementation ORKHTMLPrintFormatter

- (instancetype)init {
    self = [super initWithMarkupText:@""];
    if (self) {
        _styleSheetContent = @"";
        _styleSheetURL = [ORKBundle() URLForResource:@"Stylesheet" withExtension:@"css"];
        self.perPageContentInsets = UIEdgeInsetsMake(POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f, POINTS_PER_INCH * 0.5f);
    }
    return self;
}

- (void)prepareWithSteps:(NSArray<ORKStep *> *)steps andResult:(id<ORKTaskResultSource>)result {
    NSMutableArray *formatableSteps = [[NSMutableArray alloc] initWithArray:steps];
    for (ORKStep *step in steps) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(printFormatter:shouldFormatStep:withResult:)]) {
            if (![self.delegate printFormatter:self shouldFormatStep:step withResult:[result stepResultForStepIdentifier:step.identifier]]) {
                [formatableSteps removeObject:step];
            }
        }
    }
    NSString *body = @"";
    for (ORKStep *step in formatableSteps) {
        body = [@[body, [self HTMLFromStep:step withResult:[result stepResultForStepIdentifier:step.identifier] addSurroundingHTMLTags:NO]] componentsJoinedByString:@""];
    }
    if ([_styleSheetContent isEqualToString:@""] && _styleSheetURL) {
        _styleSheetContent = [NSString stringWithContentsOfURL:_styleSheetURL encoding:NSUTF8StringEncoding error:nil];
    }
    [self setMarkupText:[_ORK_HTMLfromTemplate(@"HTML"), _styleSheetContent, body]];
}

- (void)prepareWithStep:(ORKStep *)step andResult:(ORKStepResult *)result {
    NSMutableArray *formatableSteps = [[NSMutableArray alloc] initWithArray:@[step]];
    if (self.delegate && [self.delegate respondsToSelector:@selector(printFormatter:shouldFormatStep:withResult:)]) {
        if (![self.delegate printFormatter:self shouldFormatStep:step withResult:result]) {
            [formatableSteps removeObject:step];
        }
    }
    if ([_styleSheetContent isEqualToString:@""] && _styleSheetURL) {
        _styleSheetContent = [NSString stringWithContentsOfURL:_styleSheetURL encoding:NSUTF8StringEncoding error:nil];
    }
    [self setMarkupText:[_ORK_HTMLfromTemplate(@"HTML"), _styleSheetContent, [self HTMLFromStep:step withResult:result addSurroundingHTMLTags:YES]]];
}

#pragma mark - internal

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
    if (![stepBody isEqualToString:@""] && (self.options & ORKPrintFormatterOptionIncludeTimestamp)) {
        //TODO: use ORKLocalizedString
        NSString *footerString = [NSString stringWithFormat:@"%@ - %@", [self stringFromDate:result.startDate], [self stringFromDate:result.endDate]];
        stepFooter = [_ORK_HTMLfromTemplate(@"STEP_FOOTER"), footerString];
    }
    NSString *stepHTML = [_ORK_HTMLfromTemplate(@"STEP"), stepHeader, stepBody, stepFooter];
    if ([_styleSheetContent isEqualToString:@""] && _styleSheetURL) {
        _styleSheetContent = [NSString stringWithContentsOfURL:_styleSheetURL encoding:NSUTF8StringEncoding error:nil];
    }
    return addSurroundingHTMLTags ? [_ORK_HTMLfromTemplate(@"HTML"), _styleSheetContent, stepHTML] : stepHTML;
}

- (NSString *)HTMLfromQuestionStep:(ORKQuestionStep *)questionStep andResult:(ORKStepResult *)result {
    ORKQuestionResult *questionResult = (ORKQuestionResult *)result.results.firstObject;
    NSString *answerHTML = [self HTMLfromAnswerFormat:questionStep.impliedAnswerFormat andResult:questionResult];
    return [answerHTML isEqualToString:@""] ? @"" : [_ORK_HTMLfromTemplate(@"QUESTION_STEP_ANSWER"), answerHTML];
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
        if (image) {
            answerHTML = [_ORK_HTMLfromTemplate(@"STEP_ANSWER"), [self HTMLFromImage:image withTitle:[[answerFormat stringForAnswer:result.answer] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"]], @""];
        }
    } else {
        if (result && !result.isAnswerEmpty) {
            answerHTML = [_ORK_HTMLfromTemplate(@"STEP_ANSWER"), [[answerFormat stringForAnswer:result.answer] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"], @""];
        }
    }
    return answerHTML;
}

- (NSString *)HTMLfromChoiceAnswerFormat:(ORKAnswerFormat *)answerFormat andResult:(ORKQuestionResult *)result {
    NSString *answerHTML = @"";
    ORKChoiceAnswerFormatHelper *helper = [[ORKChoiceAnswerFormatHelper alloc] initWithAnswerFormat:answerFormat];
    if (self.options & ORKPrintFormatterOptionIncludeChoices) {
        for (NSUInteger choiceIndex = 0; choiceIndex < [helper choiceCount]; choiceIndex++) {
            BOOL isSelected = [[helper selectedIndexesForAnswer:result.answer] containsObject:[NSNumber numberWithUnsignedInteger:choiceIndex]];
            answerHTML = [@[answerHTML, [self HTMLfromAnswerOption:[helper answerOptionAtIndex:choiceIndex] isSelected:isSelected]] componentsJoinedByString:@""];
        }
    } else {
        for (NSNumber *choiceIndex in [helper selectedIndexesForAnswer:result.answer]) {
            answerHTML = [@[answerHTML, [self HTMLfromAnswerOption:[helper answerOptionAtIndex:choiceIndex.unsignedIntegerValue] isSelected:YES]] componentsJoinedByString:@""];
        }
    }
    return answerHTML;
}

- (NSString *)HTMLfromAnswerOption:(id<ORKAnswerOption>)answerOption isSelected:(BOOL)isSelected {
    NSString *answerHTML = @"";
    if ([answerOption isKindOfClass:[ORKTextChoice class]]) {
        ORKTextChoice *textChoice = (ORKTextChoice *)answerOption;
        if (textChoice.value != ORKNullAnswerValue()) {
            NSString *textChoiceText = textChoice.text;
            if (textChoice.detailText) {
                textChoiceText = [@[textChoiceText, textChoice.detailText] componentsJoinedByString:@"<br/>"];
            }
            textChoiceText = [textChoiceText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
            if (self.options & ORKPrintFormatterOptionIncludeChoices) {
                answerHTML = [_ORK_HTMLfromTemplate(isSelected ? @"STEP_SELECTED_ANSWER" : @"STEP_UNSELECTED_ANSWER"), textChoiceText, @""];
            } else {
                answerHTML = [_ORK_HTMLfromTemplate(@"STEP_ANSWER"), textChoiceText, @""];
            }
        }
    } else if ([answerOption isKindOfClass:[ORKImageChoice class]]) {
        ORKImageChoice *imageChoice = (ORKImageChoice *)answerOption;
        NSString *imageChoiceText = imageChoice.text ? imageChoice.text : @"";
        imageChoiceText = [imageChoiceText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
        if (self.options & ORKPrintFormatterOptionIncludeChoices) {
            answerHTML = isSelected ? [_ORK_HTMLfromTemplate(@"STEP_SELECTED_ANSWER"), [self HTMLFromImage:imageChoice.selectedStateImage withTitle:imageChoiceText], @""] : [_ORK_HTMLfromTemplate(@"STEP_UNSELECTED_ANSWER"), [self HTMLFromImage:imageChoice.normalStateImage withTitle:imageChoiceText], @""];
        } else {
            answerHTML = [_ORK_HTMLfromTemplate(@"STEP_ANSWER"), [self HTMLFromImage:imageChoice.selectedStateImage withTitle:imageChoiceText], @""];
        }
    }
    return answerHTML;
}

- (NSString *)HTMLFromImage:(UIImage *)image withTitle:(NSString *)title {
    CGSize maxSize = CGSizeMake(200, 200);
    NSData *imageData = UIImagePNGRepresentation(image);
    if (maxSize.width < image.size.width || maxSize.height < image.size.height) {
        imageData = UIImagePNGRepresentation([self scaledImageFromImage:image withTargetSize: maxSize]);
    }
    return imageData ? [_ORK_HTMLfromTemplate(@"IMAGE"), @(maxSize.height), @(maxSize.width), [imageData base64EncodedStringWithOptions:0], title] : @"";
}

- (UIImage *)scaledImageFromImage:(UIImage *)image withTargetSize:(CGSize)size {
    CGRect targetRect = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, size.width, size.height));
    UIGraphicsBeginImageContextWithOptions(targetRect.size, YES, 0.0);
    [image drawInRect:targetRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSString *)HTMLfromFormStep:(ORKFormStep *)formStep andResult:(ORKStepResult *)result {
    NSString *formStepHTML = @"";
    for (ORKFormItem *item in formStep.formItems) {
        if (item.identifier != nil) {
            NSUInteger index = [result.results indexOfObjectPassingTest:^BOOL(ORKResult *result, NSUInteger index, BOOL *stop) {
                return [result.identifier isEqualToString:item.identifier];
            }];
            ORKQuestionResult *questionResult = index != NSNotFound ? (ORKQuestionResult *)result.results[index] : nil;
            formStepHTML = [@[formStepHTML, [_ORK_HTMLfromTemplate(@"FORM_STEP_ANSWER"), item.text, [self HTMLfromAnswerFormat:item.impliedAnswerFormat andResult:questionResult]]] componentsJoinedByString:@""];
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
