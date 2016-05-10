/*
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


#import "ORKHTMLPDFWriter.h"
#import "ORKHelpers.h"
#import "ORKDefines_Private.h"
#import "ORKPrintFormatter.h"


#define PPI 72
#define ORKSizeMakeWithPPI(width, height) CGSizeMake(width * PPI, height * PPI)

static const CGFloat A4Width = 8.27;
static const CGFloat A4Height = 11.69;
static const CGFloat LetterWidth = 8.5f;
static const CGFloat LetterHeight = 11.0f;

#pragma mark - ORKHTMLPDFWriter Interface

@interface ORKHTMLPDFPageRenderer : ORKHTMLPrintPageRenderer

@property (nonatomic) UIEdgeInsets pageMargins;

@end


#pragma mark - ORKHTMLPDFWriter Implementation

@implementation ORKHTMLPDFPageRenderer

- (CGRect)paperRect {
    NSLocale *locale = [NSLocale currentLocale];
    BOOL useMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    CGSize pageSize = (useMetric ? ORKSizeMakeWithPPI(A4Width, A4Height) : ORKSizeMakeWithPPI(LetterWidth, LetterHeight));
    return CGRectMake(0, 0, pageSize.width, pageSize.height);
}

- (CGRect)printableRect {
    return UIEdgeInsetsInsetRect([self paperRect], _pageMargins);
}

@end


@interface ORKHTMLPDFWriter () <UIWebViewDelegate, ORKHTMLHeaderFooterRendererDelegate> {
    id _selfRetain;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) NSError *error;
@property (nonatomic, copy) void (^completionBlock)(NSData *data, NSError *error);

@end


@implementation ORKHTMLPDFWriter

static const CGFloat HeaderHeight = 25.0;
static const CGFloat FooterHeight = 30.0;
static const CGFloat PageEdge = 72.0 / 4;

- (void)writePDFFromHTML:(NSString *)html withCompletionBlock:(void (^)(NSData *data, NSError *error))completionBlock {
    _data = nil;
    _error = nil;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    [self.webView loadHTMLString:html baseURL:ORKCreateRandomBaseURL()];
    
    _selfRetain = self;
    self.completionBlock = completionBlock;
}

#pragma mark - private

- (void)timeout {
    [self savePDF];
}

- (void)savePDF {
    if (!self.webView) {
        return;
    }
    
    UIPrintFormatter *formatter = self.webView.viewPrintFormatter;
    
    ORKHTMLPDFPageRenderer *renderer = [[ORKHTMLPDFPageRenderer alloc] init];
    renderer.pageMargins = UIEdgeInsetsMake(PageEdge, PageEdge, PageEdge, PageEdge);
    renderer.footerHeight = FooterHeight;
    renderer.headerHeight = HeaderHeight;
    renderer.headerFooterDelegate = self;
    
    [renderer addPrintFormatter:formatter startingAtPageAtIndex:0];
    
    NSMutableData *currentReportData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(currentReportData, renderer.paperRect, @{});
    
    [renderer prepareForDrawingPages:NSMakeRange(0, 1)];
    
    NSInteger pages = [renderer numberOfPages];
    
    for (NSInteger i = 0; i < pages; i++) {
        UIGraphicsBeginPDFPage();
        [renderer drawPageAtIndex:i inRect:renderer.printableRect];
    }
    
    UIGraphicsEndPDFContext();
    
    _data = currentReportData;
    
    self.webView = nil;
    
    self.completionBlock(_data, nil);
    _selfRetain = nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    BOOL complete = [readyState isEqualToString:@"complete"];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    
    if (complete) {
        [self savePDF];
    } else {
        [self performSelector:@selector(timeout) withObject:nil afterDelay:1.0f];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
    
    _error = error;
    self.webView = nil;
    
    self.completionBlock(nil, error);
    _selfRetain = nil;
}

#pragma mark - ORKHTMLHeaderFooterRendererDelegate

- (NSString *)printPageRenderer:(ORKHTMLPrintPageRenderer *)printPageRenderer
    footerContentForPageInRange:(NSRange)range {
    NSString *footerContent = [NSString stringWithFormat:ORKLocalizedString(@"CONSENT_PAGE_NUMBER_FORMAT", nil), range.location, range.length];
    NSString *footerHTML = [NSString stringWithFormat:@"<!doctype html><html><head><meta charset=\"utf-8\"></head><body><p style=\"text-align: center;font-family: Helvetica\">%@</p></body></html>", footerContent];
    return footerHTML;
}

@end
