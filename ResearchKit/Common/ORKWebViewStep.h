/*
 Copyright (c) 2017, CareEvolution, Inc.
 
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


#import <ResearchKit/ORKStep.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKWebViewStep` class represents a step that displays an embedded webview.
 
 This may be useful in cases where extreme custom styling is necessary, or an instrument
 with specific requirements does not yet have a native implementation.
 
 In order to proceed to the next step from inside the webviewstep, you must execute this
 line of javascript when the user should proceed:
 
 window.webkit.messageHandlers.ResearchKit.postMessage(answer);
 
 Where "answer" is the string answer that will be captured in the WebViewStepResult.
 A string answer is required or the user will be unable to proceed.
 */
ORK_CLASS_AVAILABLE
@interface ORKWebViewStep : ORKStep

/**
 Returns a new web view step that includes the specified identifier and will display the specified html.
 
 @param identifier    The identifier of the step (a step identifier should be unique within the task).
 @param html          The html to be displayed in the webview.
 */
+ (instancetype)webViewStepWithIdentifier:(NSString *)identifier
                                     html:(NSString *)html;

/**
 Embedded html used for displaying the webview.
 */
@property (nonatomic, copy, nullable) NSString *html;

@end

NS_ASSUME_NONNULL_END
