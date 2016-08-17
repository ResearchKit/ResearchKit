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


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKResult.h>
#import <ResearchKit/ORKHTMLPrintingTemplate.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ORKPrintFormatterOptions) {
    ORKPrintFormatterOptionIncludeChoices = 1 << 0,
    ORKPrintFormatterOptionIncludeTimestamp = 1 << 1
};

@class ORKHTMLPrintFormatter;

ORK_AVAILABLE_DECL
@protocol ORKHTMLPrintFormatterDelegate <NSObject>

@optional
- (ORKPrintFormatterOptions)printFormatter:(ORKHTMLPrintFormatter *)printFormatter optionsForStep:(ORKStep *)step withResult:(ORKStepResult *)result;

- (BOOL)printFormatter:(ORKHTMLPrintFormatter *)printFormatter shouldFormatStep:(ORKStep *)step withResult:(ORKStepResult *)result;

- (NSString *)printFormatter:(ORKHTMLPrintFormatter *)printFormatter htmlContentForStep:(ORKStep *)step withResult:(ORKStepResult *)result;
@end

ORK_CLASS_AVAILABLE
@interface ORKHTMLPrintFormatter : UIMarkupTextPrintFormatter

@property ORKPrintFormatterOptions options;

@property (nonatomic, weak, nullable) id<ORKHTMLPrintFormatterDelegate> delegate;

@property (nonatomic, nullable) NSString *styleSheetContent;

@property (nonatomic, nullable) ORKHTMLPrintingTemplate *template;

- (instancetype)init;

- (void)setSteps:(NSArray<ORKStep *> *)steps withResult:(nullable id<ORKTaskResultSource>)result;

@end

NS_ASSUME_NONNULL_END