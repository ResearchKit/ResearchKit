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
#import <ResearchKit/ORKStep.h>
#import <ResearchKit/ORKResult.h>
#import <ResearchKit/ORKResult.h>
#import <ResearchKit/ORKHTMLPrintingTemplate.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ORKHTMLWriterOptions) {
    ORKHTMLWriterOptionIncludeChoices = 1 << 0,
    ORKHTMLWriterOptionIncludeTimestamp = 1 << 1
};

@class ORKHTMLWriter;

ORK_AVAILABLE_DECL
@protocol ORKHTMLWriterDelegate <NSObject>

@optional
- (ORKHTMLWriterOptions)htmlWriter:(ORKHTMLWriter *)htmlWriter optionsForStep:(ORKStep *)step withResult:(ORKStepResult *)result;

- (BOOL)htmlWriter:(ORKHTMLWriter *)htmlWriter shouldFormatStep:(ORKStep *)step withResult:(ORKStepResult *)result;

- (NSString *)htmlWriter:(ORKHTMLWriter *)htmlWriter htmlContentForStep:(ORKStep *)step withResult:(ORKStepResult *)result;
@end

ORK_CLASS_AVAILABLE
@interface ORKHTMLWriter : NSObject

@property (nonatomic, weak, nullable) id<ORKHTMLWriterDelegate> delegate;

@property (nonatomic, nullable) NSString *styleSheetContent;

@property (nonatomic, nullable) ORKHTMLPrintingTemplate *template;

@property ORKHTMLWriterOptions options;

- (NSString *)writeHTMLFromSteps:(NSArray<ORKStep *> *)steps andResult:(nullable id<ORKTaskResultSource>)result;

@end

NS_ASSUME_NONNULL_END