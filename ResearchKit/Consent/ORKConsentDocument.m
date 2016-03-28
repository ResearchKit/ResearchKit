/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Alex Basson. All rights reserved.

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


#import "ORKConsentDocument_Internal.h"

#import "ORKBodyLabel.h"
#import "ORKHeadlineLabel.h"
#import "ORKSubheadlineLabel.h"

#import "ORKConsentSection_Private.h"
#import "ORKConsentSectionFormatter.h"
#import "ORKConsentSignature.h"
#import "ORKConsentSignatureFormatter.h"
#import "ORKHTMLPDFWriter.h"

#import "ORKHelpers_Internal.h"
#import "ORKErrors.h"


@implementation ORKConsentDocument {
    NSMutableArray<ORKConsentSignature *> *_signatures;
}

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithHTMLPDFWriter:[[ORKHTMLPDFWriter alloc] init]
            consentSectionFormatter:[[ORKConsentSectionFormatter alloc] init]
            consentSignatureFormatter:[[ORKConsentSignatureFormatter alloc] init]];
}

- (instancetype)initWithHTMLPDFWriter:(ORKHTMLPDFWriter *)writer
              consentSectionFormatter:(ORKConsentSectionFormatter *)sectionFormatter
            consentSignatureFormatter:(ORKConsentSignatureFormatter *)signatureFormatter{
    if (self = [super init]) {
        _writer = writer;
        _sectionFormatter = sectionFormatter;
        _signatureFormatter = signatureFormatter;
    }
    return self;
}

#pragma mark - Accessors

- (void)setSignatures:(NSArray<ORKConsentSignature *> *)signatures {
    _signatures = [signatures mutableCopy];
}

- (NSArray<ORKConsentSignature *> *)signatures {
    return [_signatures copy];
}

#pragma mark - Public

- (void)addSignature:(ORKConsentSignature *)signature {
    if (!_signatures) {
        _signatures = [NSMutableArray array];
    }
    [_signatures addObject:signature];
}

- (void)makePDFWithCompletionHandler:(void (^)(NSData *data, NSError *error))completionBlock {
    [_writer writePDFFromHTML:[self htmlForMobile:NO withTitle:nil detail:nil]
          withCompletionBlock:^(NSData *data, NSError *error) {
        if (error) {
            // Pass the webview error straight through. This is a pretty exceptional
            // condition (can only happen if they pass us really invalid content).
            completionBlock(nil, error);
        } else {
            completionBlock(data, nil);
        }
    }];
}

#pragma mark - Private

- (NSString *)mobileHTMLWithTitle:(NSString *)title detail:(NSString *)detail {
    return [self htmlForMobile:YES withTitle:title detail:detail];
}

+ (NSString *)cssStyleSheet:(BOOL)mobile {
    NSMutableString *css = [@"@media print { .pagebreak { page-break-before: always; } }\n" mutableCopy];
    if (mobile) {
        [css appendString:@".header { margin-top: 36px ; margin-bottom: 30px; text-align: center; }\n"];
        [css appendString:@"body { margin-left: 0px; margin-right: 0px; }\n"];
        
        
        CGFloat adjustment = [[ORKSubheadlineLabel defaultFont] pointSize] - 17.0;
        NSArray *hPointSizes = @[@([[ORKHeadlineLabel defaultFont] pointSize]),
                                 @(24.0 + adjustment),
                                 @(19.0 + adjustment),
                                 @(17.0 + adjustment),
                                 @(13.0 + adjustment),
                                 @(11.0 + adjustment)];
        
        [css appendString:[NSString stringWithFormat:@"h1 { font-family: -apple-system-font ; font-weight: 300; font-size: %.0lf; }\n",
                           ((NSNumber *)hPointSizes[0]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"h2 { font-family: -apple-system-font ; font-weight: 300; font-size: %.0lf; text-align: left; margin-top: 2em; }\n",
                           ((NSNumber *)hPointSizes[1]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"h3 { font-family: -apple-system-font ; font-size: %.0lf; margin-top: 2em; }\n",
                           ((NSNumber *)hPointSizes[2]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"h4 { font-family: -apple-system-font ; font-size: %.0lf; margin-top: 2em; }\n",
                           ((NSNumber *)hPointSizes[3]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"h5 { font-family: -apple-system-font ; font-size: %.0lf; margin-top: 2em; }\n",
                           ((NSNumber *)hPointSizes[4]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"h6 { font-family: -apple-system-font ; font-size: %.0lf; margin-top: 2em; }\n",
                           ((NSNumber *)hPointSizes[5]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"body { font-family: -apple-system-font; font-size: %.0lf; }\n",
                           ((NSNumber *)hPointSizes[3]).floatValue]];
        [css appendString:[NSString stringWithFormat:@"p, blockquote, ul, fieldset, form, ol, dl, dir, { font-family: -apple-system-font; font-size: %.0lf; margin-top: -.5em; }\n",
                           ((NSNumber *)hPointSizes[3]).floatValue]];
    } else {
        [css appendString:@"h1, h2 { text-align: center; }\n"];
        [css appendString:@"h2, h3 { margin-top: 3em; }\n"];
        [css appendString:@"body, p, h1, h2, h3 { font-family: Helvetica; }\n"];
    }
    
    [css appendFormat:@".col-1-3 { width: %@; float: left; padding-right: 20px; }\n", mobile ? @"66.6%" : @"33.3%"];
    [css appendString:@".sigbox { position: relative; height: 100px; max-height:100px; display: inline-block; bottom: 10px }\n"];
    [css appendString:@".inbox { position: relative; top: 100%%; transform: translateY(-100%%); -webkit-transform: translateY(-100%%);  }\n"];
    [css appendString:@".grid:after { content: \"\"; display: table; clear: both; }\n"];
    [css appendString:@".border { -webkit-box-sizing: border-box; box-sizing: border-box; }\n"];
    
    return css;
}

+ (NSString *)wrapHTMLBody:(NSString *)body mobile:(BOOL)mobile {
    NSMutableString *html = [NSMutableString string];
    
    [html appendString:@"<html><head><style>"];
    [html appendString:[[self class] cssStyleSheet:mobile]];
    [html appendString:@"</style></head><body>"];
    [html appendString:body];
    [html appendString:@"</body></html>"];
    
    return [html copy];
}

- (NSString *)htmlForMobile:(BOOL)mobile withTitle:(NSString *)title detail:(NSString *)detail {
    NSMutableString *body = [NSMutableString new];
    
    // header
    [body appendFormat:@"<div class='header'>"];
    if (title) {
        [body appendFormat:@"<h1>%@</h1>", title];
    }
    
    if (detail) {
        [body appendFormat:@"<p>%@</p>", detail];
    }
    [body appendFormat:@"</div>"];
    
    if (_htmlReviewContent) {
        [body appendString:_htmlReviewContent];
    } else {
        
        // title
        [body appendFormat:@"<h3>%@</h3>", _title ? : @""];
        
        // scenes
        for (ORKConsentSection *section in _sections) {
            if (!section.omitFromDocument) {
                [body appendFormat:@"%@", [_sectionFormatter HTMLForSection:section]];
            }
        }
        
        if (!mobile) {
            // page break
            [body appendFormat:@"<h4 class=\"pagebreak\">%@</h4>", _signaturePageTitle ? : @""];
            [body appendFormat:@"<p>%@</p>", _signaturePageContent ? : @""];
            
            for (ORKConsentSignature *signature in self.signatures) {
                [body appendFormat:@"%@", [_signatureFormatter HTMLForSignature:signature]];
            }
        }
    }
    return [[self class] wrapHTMLBody:body mobile:mobile];
}

#pragma mark - <NSSecureCoding>

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, title, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, signaturePageTitle, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, signaturePageContent, NSString);
        ORK_DECODE_OBJ_CLASS(aDecoder, htmlReviewContent, NSString);
        NSArray *signatures = (NSArray *)[aDecoder decodeObjectOfClass:[NSArray class] forKey:@"signatures"];
        _signatures = [signatures mutableCopy];
        ORK_DECODE_OBJ_ARRAY(aDecoder, sections, ORKConsentSection);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, title);
    ORK_ENCODE_OBJ(aCoder, signaturePageTitle);
    ORK_ENCODE_OBJ(aCoder, signaturePageContent);
    ORK_ENCODE_OBJ(aCoder, signatures);
    ORK_ENCODE_OBJ(aCoder, htmlReviewContent);
    ORK_ENCODE_OBJ(aCoder, sections);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - <NSCopying>

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKConsentDocument *doc = [[[self class] allocWithZone:zone] init];
    doc.title = _title;
    doc.signaturePageTitle = _signaturePageTitle;
    doc.signaturePageContent = _signaturePageContent;
    doc.htmlReviewContent = _htmlReviewContent;
    
    // Deep copy the signatures
    doc.signatures = ORKArrayCopyObjects(_signatures);
    
    // Deep copy the sections
    doc.sections = ORKArrayCopyObjects(_sections);
    
    return doc;
}

#pragma mark - <NSObject>

- (BOOL)isEqual:(id)object {
    if ([self class] != [object class]) {
        return NO;
    }

    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.title, castObject.title)
            && ORKEqualObjects(self.signaturePageTitle, castObject.signaturePageTitle)
            && ORKEqualObjects(self.signaturePageContent, castObject.signaturePageContent)
            && ORKEqualObjects(self.htmlReviewContent, castObject.htmlReviewContent)
            && ORKEqualObjects(self.signatures, castObject.signatures)
            && ORKEqualObjects(self.sections, castObject.sections));
}

- (NSUInteger)hash {
    return _title.hash ^ _sections.hash;
}

@end
