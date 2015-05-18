#import <XCTest/XCTest.h>
#import "ORKConsentSectionFormatter.h"
#import "ORKConsentSection_Internal.h"

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
