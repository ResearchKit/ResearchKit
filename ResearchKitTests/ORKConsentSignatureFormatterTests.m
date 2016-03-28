/*
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


@import XCTest;
@import ResearchKit.Private;

#import "ORKConsentSignatureFormatter.h"


@interface ORKConsentSignatureFormatterTests : XCTestCase

@property (nonatomic, strong) ORKConsentSignatureFormatter *formatter;
@property (nonatomic, strong) ORKConsentSignature *signature;

@end


@implementation ORKConsentSignatureFormatterTests

- (void)setUp {
    [super setUp];

    self.formatter = [[ORKConsentSignatureFormatter alloc] init];
    self.signature = [[ORKConsentSignature alloc] init];
    self.signature.title = @"User";
}

- (void)tearDown {
    self.formatter = nil;
    self.signature = nil;

    [super tearDown];
}

- (void)testHTMLForSignature_withNameNotRequired_formatsNames {
    self.signature.requiresName = NO;
    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/>"
            @"<div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withNameRequired_formatsNames {
    self.signature.requiresName = YES;
    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);

    self.signature.familyName = @"Family";
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);

    self.signature.givenName = @"Given";
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Given&nbsp;Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div><div class='col-1-3 border'>"
            @"<p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withSignatureImageNotRequired_formatsImage {
    self.signature.requiresSignatureImage = NO;
    NSString *html;
    html =  @"<div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withSignatureImageRequired_formatsImage {
    self.signature.requiresSignatureImage = YES;
    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);

}

- (void)testHTMLForSignature_withSignatureImage_formatsImage {
    self.signature.signatureImage = [UIImage imageNamed:@"arrowLeft"];
    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withNameAndImage_formatsSignature {
    self.signature.requiresName = YES;
    self.signature.familyName = @"Family";
    self.signature.givenName = @"Given";

    self.signature.requiresSignatureImage = YES;
    self.signature.signatureImage = [UIImage imageNamed:@"arrowLeft"];

    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Given&nbsp;Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"User's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

@end
