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


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKTask.h>
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKResult.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ORKPrintFormatterOptions) {
    ORKPrintFormatterOptionIncludeChoices = 1 << 0,
    ORKPrintFormatterOptionIncludeTimestamp = 1 << 1
};

@protocol ORKPrintFormatter;

ORK_AVAILABLE_DECL
@protocol ORKPrintFormatterDelegate <NSObject>

- (ORKPrintFormatterOptions)printFormatter:(id<ORKPrintFormatter>)printFormatter optionsForStep:(ORKStep *)step withResult:(ORKStepResult *)result;

- (BOOL)printFormatter:(id<ORKPrintFormatter>)printFormatter shouldFormatStep:(ORKStep *)step withResult:(ORKStepResult *)result;

@end

ORK_AVAILABLE_DECL
@protocol ORKPrintFormatter <NSObject>

@property ORKPrintFormatterOptions options;

@property (nonatomic, weak, nullable) id<ORKPrintFormatterDelegate> delegate;

- (instancetype)initWithTask:(id<ORKTask>)task steps:(NSArray<ORKStep *> *)steps andResult:(nullable ORKTaskResult *)result;

- (instancetype)initWithStep:(ORKStep *)step andResult:(nullable ORKStepResult *)result;

- (void)prepare;

@end

ORK_CLASS_AVAILABLE
@interface ORKHTMLPrintFormatter: UIMarkupTextPrintFormatter <ORKPrintFormatter>

@property ORKPrintFormatterOptions options;

@property (nonatomic, weak, nullable) id<ORKPrintFormatterDelegate> delegate;

@property (nonatomic, copy, nullable) NSString *styleSheetContent;

- (instancetype)initWithTask:(id<ORKTask>)task steps:(NSArray<ORKStep *> *)steps andResult:(nullable ORKTaskResult *)result;

- (instancetype)initWithStep:(ORKStep *)step andResult:(nullable ORKStepResult *)result;

- (void)prepare;

@end

ORK_CLASS_AVAILABLE
@interface ORKPrintPageRenderer : UIPrintPageRenderer

@property (nonatomic, copy, nullable) NSString* headerContent;

@property (nonatomic, copy, nullable) NSString* footerContent;

@end

NS_ASSUME_NONNULL_END
