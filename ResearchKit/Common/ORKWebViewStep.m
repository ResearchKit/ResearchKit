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

#import "ORKWebViewStep.h"
#import "ORKWebViewStepViewController.h"
#import "ORKHelpers_Internal.h"

@implementation ORKWebViewStep

+ (Class)stepViewControllerClass {
    return [ORKWebViewStepViewController class];
}

+ (instancetype)webViewStepWithIdentifier:(NSString *)identifier
                                     html:(NSString *)html {
    ORKWebViewStep *step = [[ORKWebViewStep alloc] initWithIdentifier:identifier];
    step.html = html;
    return step;
}

- (void)validateParameters {
    [super validateParameters];
    
    if (self.html == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"WebViewStep requires html property."
                                     userInfo:nil];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, html, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, customCSS, NSString);
        ORK_DECODE_BOOL(aDecoder, showSignatureAfterContent);
        ORK_DECODE_OBJ_CLASS(aDecoder, customViewProvider, NSObject<ORKCustomSignatureAccessoryViewProvider>);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, html);
    ORK_ENCODE_OBJ(aCoder, customCSS);
    ORK_ENCODE_BOOL(aCoder, showSignatureAfterContent);
    ORK_ENCODE_OBJ(aCoder, customViewProvider);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKWebViewStep *step = [super copyWithZone:zone];
    step.html = self.html;
    step.customCSS = self.customCSS;
    step.customViewProvider = self.customViewProvider;
    step.showSignatureAfterContent = self.showSignatureAfterContent;
    return step;
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            [self.html isEqual:castObject.html] &&
            [self.customCSS isEqual:castObject.customCSS] &&
            self.showSignatureAfterContent == castObject.showSignatureAfterContent);
}

@end
