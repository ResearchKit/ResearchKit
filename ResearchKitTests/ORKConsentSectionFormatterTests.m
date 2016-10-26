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

#import "ORKConsentSectionFormatter.h"


@interface ORKConsentSectionFormatterTests : XCTestCase

@property (nonatomic, strong) ORKConsentSectionFormatter *formatter;
@property (nonatomic, strong) ORKConsentSection *section;

@end


@implementation ORKConsentSectionFormatterTests

- (void)setUp {
    [super setUp];
    self.formatter = [[ORKConsentSectionFormatter alloc] init];
    self.section = [[ORKConsentSection alloc] init];
}

- (void)tearDown {
    self.formatter = nil;
    self.section = nil;
    [super tearDown];
}

- (void)testHTMLForSection_whenSectionHasFormalTitle_formatsFormalTitle {
    self.section.formalTitle = @"Formal Title";
    self.section.title = @"Informal Title";
    XCTAssertEqualObjects([self.formatter HTMLForSection:self.section], @"<h4>Formal Title</h4><p></p>");
}

- (void)testHTMLForSection_whenSectionHasNoFormalTitle_formatsFormalTitle {
    self.section.title = @"Informal Title";
    XCTAssertEqualObjects([self.formatter HTMLForSection:self.section], @"<h4>Informal Title</h4><p></p>");
}

- (void)testHTMLForSection_whenSectionHasHTMLContent_formatsHTMLContent {
    self.section.htmlContent = @"html content";
    self.section.content = @"other content";
    XCTAssertEqualObjects([self.formatter HTMLForSection:self.section], @"<h4></h4><p>html content</p>");
}

- (void)testHTMLForSection_whenSectionHasNoHTMLContent_formatsEscapedContent {
    self.section.content = @"unescaped content\nwith special characters such as < >";
    XCTAssertEqualObjects([self.formatter HTMLForSection:self.section], @"<h4></h4><p>unescaped content<br/>with special characters such as &lt; &gt;</p>");
}

@end
