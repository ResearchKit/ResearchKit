#import <XCTest/XCTest.h>
#import "ORKConsentDocument.h"
#import "ORKHTMLPDFWriter.h"
#import "ORKConsentSectionFormatter.h"
#import "ORKConsentSignatureFormatter.h"

@interface ORKMockHTMLPDFWriter : ORKHTMLPDFWriter
@property (nonatomic, copy) NSString *html;
@property (nonatomic, copy) void (^completionBlock)(NSData *, NSError *);
@end

@implementation ORKMockHTMLPDFWriter

- (void)writePDFFromHTML:(NSString *)html withCompletionBlock:(void (^)(NSData *, NSError *))completionBlock {
    self.html = html;
    self.completionBlock = completionBlock;
}

@end

@interface ORKMockConsentSectionFormatter : ORKConsentSectionFormatter
@end

@implementation ORKMockConsentSectionFormatter

- (NSString *)HTMLForSection:(ORKConsentSection *)section {
    return @"html for section";
}

@end

@interface ORKMockConsentSignatureFormatter : ORKConsentSignatureFormatter

@end

@implementation ORKMockConsentSignatureFormatter

- (NSString *)HTMLForSignature:(ORKConsentSignature *)signature {
    return @"html for signature";
}

@end


@interface ORKConsentDocumentTests : XCTestCase
@property (nonatomic, strong) ORKConsentDocument *document;
@property (nonatomic, strong) ORKMockHTMLPDFWriter *mockWriter;
@end

@implementation ORKConsentDocumentTests

- (void)setUp {
    [super setUp];

    self.mockWriter = [[ORKMockHTMLPDFWriter alloc] init];

    self.document = [[ORKConsentDocument alloc] initWithHTMLPDFWriter:self.mockWriter
                                              consentSectionFormatter:[[ORKMockConsentSectionFormatter alloc] init]
                                            consentSignatureFormatter:[[ORKMockConsentSignatureFormatter alloc] init]];
}

- (void)tearDown {
    self.document = nil;
    [super tearDown];
}

- (NSString *)htmlWithContent:(NSString *)content {
    NSString *boilerplateHeader = @"<html><head><style>@media print { .pagebreak { page-break-before: always; } }\nh1, h2 { text-align: center; }\nh2, h3 { margin-top: 3em; }\nbody, p, h1, h2, h3 { font-family: Helvetica; }\n.col-1-3 { width: 33.3%; float: left; padding-right: 20px; }\n.sigbox { position: relative; height: 100px; max-height:100px; display: inline-block; bottom: 10px }\n.inbox { position: relative; top: 100%%; transform: translateY(-100%%); -webkit-transform: translateY(-100%%);  }\n.grid:after { content: \"\"; display: table; clear: both; }\n.border { -webkit-box-sizing: border-box; box-sizing: border-box; }\n</style></head><body><div class='header'></div>";
    NSString *boilerplateFooter = @"</body></html>";

    return [NSString stringWithFormat:@"%@%@%@", boilerplateHeader, content, boilerplateFooter];
}

- (void)testMakePDFWithCompletionHandler_withHTMLReviewContent_callsWriterWithCorrectHTML {
    self.document.htmlReviewContent = @"some content";
    [self.document makePDFWithCompletionHandler:^(NSData *data, NSError *error) {}];
    XCTAssertEqualObjects(self.mockWriter.html, [self htmlWithContent:@"some content"]);
}

- (void)testMakePDFWithCompletionHandler_withoutHTMLReviewContent_callsWriterWithCorrectHTML {
    self.document.title = @"A Title";
    self.document.sections = @[
                               [[ORKConsentSection alloc] init],
                               [[ORKConsentSection alloc] init]
                               ];
    self.document.signaturePageTitle = @"Signature Page Title";
    self.document.signaturePageContent = @"signature page content";
    self.document.signatures = @[
                                 [[ORKConsentSignature alloc] init],
                                 [[ORKConsentSignature alloc] init]
                                 ];

    NSString *content = @"<h3>A Title</h3>"
                        @"html for section"
                        @"html for section"
                        @"<h4 class=\"pagebreak\" >Signature Page Title</h4>"
                        @"<p>signature page content</p>"
                        @"html for signature"
                        @"html for signature";

    [self.document makePDFWithCompletionHandler:^(NSData *data, NSError *error) {}];
    XCTAssertEqualObjects(self.mockWriter.html, [self htmlWithContent:content]);
}

- (void)testMakePDFWithCompletionHandler_whenWriterReturnsData_callsCompletionBlockWithData {
    __block NSData *passedData;
    __block NSError *passedError;
    [self.document makePDFWithCompletionHandler:^(NSData *data, NSError *error) {
        passedData = data;
        passedError = error;
    }];

    NSData *data = [NSData data];
    self.mockWriter.completionBlock(data, nil);

    XCTAssertEqualObjects(passedData, data);
    XCTAssertEqualObjects(passedError, nil);
}

- (void)testMakePDFWithCompletionHandler_whenWriterReturnsError_callsCompletionBlockWithError {
    __block NSData *passedData;
    __block NSError *passedError;
    [self.document makePDFWithCompletionHandler:^(NSData *data, NSError *error) {
        passedData = data;
        passedError = error;
    }];

    NSError *error = [NSError errorWithDomain:@"some error domain" code:123 userInfo:@{}];
    self.mockWriter.completionBlock(nil, error);

    XCTAssertEqualObjects(passedData, nil);
    XCTAssertEqualObjects(passedError, error);
}

@end
