/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKInstructionStepHTMLFormatter.h"
#import "ORKInstructionStep.h"
#import "ORKBodyItem.h"

@implementation ORKInstructionStepHTMLFormatter

NSString * const OpeningHTMLTag = @"<!DOCTYPE html> <html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">";
NSString * const HeaderTagContent = @"<head>"
                                    "<meta name=\"viewport\" content=\"width=400, user-scalable=no\">"
                                    "<meta charset=\"utf-8\" />"
                                    "<style type=\"text/css\">"
                                        "body { background: #FFF; font-family: Helvetica, sans-serif; text-align: center; }"
                                        ".container { width: 100%; padding: 10px; box-sizing: border-box;}"
                                        ".iconImageContainer { text-align:left; }"
                                    "</style>"
                                    "</head>";

NSString * const OpeningBodyTag = @"<body>";
NSString * const OpeningContainerDivTag = @"<div class=\"container\">";

NSString * const IconImageTagWrappingDiv = @"<p><br/><div class='iconImageContainer'>%@</div></p>";
NSString * const IconImageTag = @"<img width='80px' src='data:image/png;base64,%@' />";

NSString * const ImageTagWrappingDiv = @"<p><br/><div>%@</div></p>";
NSString * const ImageTag = @"<img width='100%%' src='data:image/png;base64,%@' />";

NSString * const HeaderForTitleTag = @"<h3 style=\"text-align: left\">%@</h3>";
NSString * const ParagraphForDetailTextTag = @"<p align=\"left\">%@</p>";

NSString * const OpeningUnorderedListTag = @"<ul style=\"margin:15px; padding:0\">";
NSString * const ListItemElement = @"<li style=\"text-align: left; padding-bottom:20px\">%@</li>";
NSString * const ClosingUnorderedListTag = @"</ul>";

NSString * const ClosingContainerDivTag = @"</div>";
NSString * const ClosingBodyTag = @"</body>";
NSString * const ClosingHTMLTag = @"</html>";

- (NSString *)HTMLForInstructionSteps:(NSArray<ORKInstructionStep *> *)instructionSteps {
    NSMutableString *htmlContent = [NSMutableString new];
    
    [htmlContent appendString:[self _getOpeningHTMLTags]];
    
    for (ORKInstructionStep *instructionStep in instructionSteps) {
        [htmlContent appendString:[self _getHTMLImageContentFromInstructionStep:instructionStep] ?: @""];
        [htmlContent appendString:[self _getHTMLTitleContentFromInstructionStep:instructionStep] ?: @""];
        [htmlContent appendString:[self _getHTMLDetailTextContentFromInstructionStep:instructionStep] ?: @""];
        [htmlContent appendString:[self _getHTMLBodyItemContentFromInstructionStep:instructionStep] ?: @""];
    }
    
    [htmlContent appendString:[self _getClosingHTMLTags]];
    
    return htmlContent;
}

- (NSString *)_getOpeningHTMLTags {
    return [NSString stringWithFormat:@"%@%@%@%@", OpeningHTMLTag, HeaderTagContent, OpeningBodyTag, OpeningContainerDivTag];
}

- (nullable NSString *)_getHTMLImageContentFromInstructionStep:(ORKInstructionStep *)instructionStep {
    if (instructionStep.iconImage) {
        NSString *encodedImg = [self _getEncodedStringFromImage:instructionStep.iconImage];
        NSString *imageTag = [NSString stringWithFormat:IconImageTag, encodedImg];
        return [NSString stringWithFormat:IconImageTagWrappingDiv, imageTag];
    } else if (instructionStep.image) {
        NSString *encodedImg = [self _getEncodedStringFromImage:instructionStep.image];
        NSString *imageTag = [NSString stringWithFormat:ImageTag, encodedImg];
        return [NSString stringWithFormat:ImageTagWrappingDiv, imageTag];
    }
    
    return nil;
}

- (NSString *)_getEncodedStringFromImage:(UIImage *)image {
    NSString *base64 = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64;
}

- (nullable NSString *)_getHTMLTitleContentFromInstructionStep:(ORKInstructionStep *)instructionStep {
    if (instructionStep.title) {
        return [NSString stringWithFormat:HeaderForTitleTag, instructionStep.title];
    }
    
    return nil;
}

- (nullable NSString *)_getHTMLDetailTextContentFromInstructionStep:(ORKInstructionStep *)instructionStep {
    if (instructionStep.detailText) {
        return [NSString stringWithFormat:ParagraphForDetailTextTag, instructionStep.detailText];
    }
    
    return nil;
}

- (nullable NSString *)_getHTMLBodyItemContentFromInstructionStep:(ORKInstructionStep *)instructionStep {
    if (instructionStep.bodyItems.count > 0) {
        NSMutableString *content = [NSMutableString new];
        [content appendString:OpeningUnorderedListTag];
        
        for (ORKBodyItem *bodyItem in instructionStep.bodyItems) {
            NSString *listItemContent = [NSString stringWithFormat:ListItemElement, bodyItem.text];
            [content appendString: listItemContent];
        }
        
        [content appendString:ClosingUnorderedListTag];
        return content;
    }
    
    return nil;
}

- (NSString *)_getClosingHTMLTags {
    return [NSString stringWithFormat:@"%@%@%@", ClosingContainerDivTag, ClosingBodyTag, ClosingHTMLTag];
}

@end
