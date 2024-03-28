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

#import "ORKSignatureFormatter.h"
#import "ORKSignatureResult.h"
#import "ORKHelpers_Internal.h"

NSString * const ClosingBodyTagText = @"</body>";
NSString * const ClosingHTMLTagText = @"</html>";
NSString * const HorizontalRowHTMLText = @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />";
NSString * const ImageTagHTMLText = @"<img width='100%%' alt='star' src='data:image/png;base64,%@' />";
NSString * const SignatureEnclosingDiveHTMLText = @"<div width='200'>%@</div>";
NSString * const SignatureImageWrapperHTMLText = @"<p><br/><div class='sigbox'><div class='inboxImage'>%@</div></div>%@%@</p>";


@implementation ORKSignatureFormatter

- (NSString *)HTMLForSignatureResult:(ORKSignatureResult *)signatureResult {
    NSString *hr = HorizontalRowHTMLText;
    NSString *signatureImageWrapper = SignatureImageWrapperHTMLText;
    NSString *imageTag = [self getImgTagFromImage:signatureResult.signatureImage];
    
    NSMutableArray *signatureElements = [NSMutableArray array];
    [signatureElements addObject:[NSString stringWithFormat:signatureImageWrapper, imageTag, hr, ORKLocalizedString(@"CONSENT_DOC_LINE_SIGNATURE", nil)]];
    
    NSString *html = [NSString stringWithFormat:SignatureEnclosingDiveHTMLText, signatureElements.lastObject];
    return html;
}

- (NSString *)appendSignatureToHTML:(NSString *)html signatureResult:(ORKSignatureResult *)signatureResult {
    if (![html containsString:ClosingBodyTagText] || ![html containsString:ClosingHTMLTagText]) {
        return nil;
    }
    
    NSString *htmlForSignature = [self HTMLForSignatureResult:signatureResult];
    
    NSString *htmlWithoutClosingTags = [self removeClosingTagsFromHTML:html];
    NSMutableString *body = [NSMutableString new];
    [body appendString:htmlForSignature];
    
    NSString *groupedBodyAndHTMLClosingTags = [NSString stringWithFormat:@"%@%@", ClosingBodyTagText, ClosingHTMLTagText];
    NSString *finalHTMLString = [htmlWithoutClosingTags stringByAppendingString:body];
    finalHTMLString = [finalHTMLString stringByAppendingString:groupedBodyAndHTMLClosingTags];
    
    return finalHTMLString;
}

#pragma mark - private

- (NSString *)removeClosingTagsFromHTML:(NSString *)html {
    NSRange bodyReplaceRangeRange = [html rangeOfString:ClosingBodyTagText];
    NSString *tempString = [html stringByReplacingCharactersInRange:bodyReplaceRangeRange withString:@""];
    
    NSRange htmlReplaceRangeRange = [tempString rangeOfString:ClosingHTMLTagText];
    tempString = [tempString stringByReplacingCharactersInRange:htmlReplaceRangeRange withString:@""];
    
    return [tempString copy];
}

- (NSString *)getImgTagFromImage:(UIImage *)image {
    NSString *base64 = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *imageTag = [NSString stringWithFormat:ImageTagHTMLText, base64];
    return imageTag;
}

@end
