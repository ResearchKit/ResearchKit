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


#import "ORKHTMLPrintingTemplate.h"


@implementation ORKHTMLPrintingTemplate

- (NSString *)html {
    return @"<!doctype html><html><head><title>html</title><meta charset=\"utf-8\"></head><style>%@</style><body>%@</body></html>";
}

- (NSString *)step {
    return @"<div class=\"stepSeparator\">%@%@%@</div>";
}

- (NSString *)stepHeader {
    return @"<p class=\"stepTitle\">%@</p><p id=\"stepText\">%@</p>";
}

- (NSString *)formStep {
    return @"<p class=\"formStepTitle\">%@</p>";
}

- (NSString *)formStepAnswer {
    return @"<p class=\"sectionTitle\">%@</p><table id=\"answerTable\">%@</table>";
}

- (NSString *)questionStepAnswer {
    return @"<table class=\"answerTable\">%@</table>";
}

- (NSString *)stepAnswer {
    return @"<tr class=\"answerRow\"><td><div class=\"answerColumn\"/>%@<td/></tr>";
}

- (NSString *)stepSelectedAnswer {
    return @"<tr class=\"selectedAnswerRow\"><td><div class=\"selectedAnswerPrimaryColumn\"/>%@<td/><td><div class=\"selectedAnswerSecondaryColumn\">%@</div></td></tr>";
}

- (NSString *)stepUnselectedAnswer {
    return @"<tr class=\"unselectedAnswerRow\"><td><div class=\"unselectedAnswerPrimaryColumn\"/>%@<td/><td><div class=\"unselectedAnswerSecondaryColumn\">%@</div></td></tr>";
}

- (NSString *)stepFooter {
    return @"<p class=\"stepFooter\">%@</p>";
}

- (NSString *)image {
    return @"<figure class=\"figure\"><img class=\"image\" height=\"%@\" width=\"%@\" src=\"data:image/png;base64,%@\"/><figcaption>%@</figcaption></figure>";
}

@end
