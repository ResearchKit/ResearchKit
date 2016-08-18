/*
 Copyright (c) 2015, Alex Basson. All rights reserved.
 Copyright (c) 2015, Apple Inc. All rights reserved.

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


#import "ORKConsentSignatureFormatter.h"

#import "ORKConsentSignature.h"

#import "ORKHelpers_Internal.h"


@implementation ORKConsentSignatureFormatter

- (NSString *)HTMLForSignature:(ORKConsentSignature *)signature {
    NSMutableString *body = [NSMutableString new];

    NSString *hr = @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />";

    NSString *signatureElementWrapper = @"<p><br/><div class='sigbox'><div class='inbox'>%@</div></div>%@%@</p>";

    BOOL addedSig = NO;

    NSMutableArray *signatureElements = [NSMutableArray array];
    
    if (signature.title == nil) {
        @throw [NSException exceptionWithName:NSObjectNotAvailableException reason:@"Signature title is missing" userInfo:nil];
    }

    // Signature
    if (signature.requiresName || signature.familyName || signature.givenName) {
        addedSig = YES;
        NSString *nameStr = @"&nbsp;";
        if (signature.familyName || signature.givenName) {
            NSMutableArray *names = [NSMutableArray array];
            if (signature.givenName) {
                [names addObject:signature.givenName];
            }
            if (signature.familyName) {
                [names addObject:signature.familyName];
            }
            if (ORKCurrentLocalePresentsFamilyNameFirst()) {
                names = [[[names reverseObjectEnumerator] allObjects] mutableCopy];
            }
            nameStr = [names componentsJoinedByString:@"&nbsp;"];
        }

        NSString *titleFormat = ORKLocalizedString(@"CONSENT_DOC_LINE_PRINTED_NAME", nil);
        [signatureElements addObject:[NSString stringWithFormat:signatureElementWrapper, nameStr, hr, [NSString stringWithFormat:titleFormat,signature.title]]];
    }

    if (signature.requiresSignatureImage || signature.signatureImage) {
        addedSig = YES;
        NSString *imageTag = nil;

        if (signature.signatureImage) {
            NSString *base64 = [UIImagePNGRepresentation(signature.signatureImage) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            imageTag = [NSString stringWithFormat:@"<img width='100%%' alt='star' src='data:image/png;base64,%@' />", base64];
        } else {
            [body appendString:@"<br/>"];
        }
        NSString *titleFormat = ORKLocalizedString(@"CONSENT_DOC_LINE_SIGNATURE", nil);
        [signatureElements addObject:[NSString stringWithFormat:signatureElementWrapper, imageTag ? : @"&nbsp;", hr, [NSString stringWithFormat:titleFormat, signature.title]]];
    }

    if (addedSig) {
        [signatureElements addObject:[NSString stringWithFormat:signatureElementWrapper, signature.signatureDate ? : @"&nbsp;", hr, ORKLocalizedString(@"CONSENT_DOC_LINE_DATE", nil)]];
    }

    NSInteger numElements = signatureElements.count;
    if (numElements > 1) {
        [body appendString:[NSString stringWithFormat:@"<div class='grid border'>"]];
        for (NSString *element in signatureElements) {
            [body appendString:[NSString stringWithFormat:@"<div class='col-1-3 border'>%@</div>",element]];
        }

        [body appendString:@"</div>"];
    } else if (numElements == 1) {
        [body appendString:[NSString stringWithFormat:@"<div width='200'>%@</div>",signatureElements.lastObject]];
    }
    return body;
}

@end
