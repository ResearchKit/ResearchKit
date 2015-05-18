#import <XCTest/XCTest.h>
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
            @"(null)'s Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withNameRequired_formatsNames {
    self.signature.requiresName = YES;
    self.signature.title = @"Title";
    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);

    self.signature.familyName = @"Family";
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);

    self.signature.givenName = @"Given";
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Given&nbsp;Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Name (printed)</p></div><div class='col-1-3 border'>"
            @"<p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Signature</p></div>"
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
            @"(null)'s Name (printed)</p></div>"
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
            @"(null)'s Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"(null)'s Signature</p></div>"
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
            @"(null)'s Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"(null)'s Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

- (void)testHTMLForSignature_withNameAndImage_formatsSignature {
    self.signature.requiresName = YES;
    self.signature.familyName = @"Family";
    self.signature.givenName = @"Given";
    self.signature.title = @"Title";
    self.signature.requiresSignatureImage = YES;
    self.signature.signatureImage = [UIImage imageNamed:@"arrowLeft"];

    NSString *html;
    html =  @"<br/><div class='grid border'><div class='col-1-3 border'><p><br/><div class='sigbox'>"
            @"<div class='inbox'>Given&nbsp;Family</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Name (printed)</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Title's Signature</p></div>"
            @"<div class='col-1-3 border'><p><br/><div class='sigbox'><div class='inbox'>&nbsp;</div></div>"
            @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />"
            @"Date</p></div></div>";
    XCTAssertEqualObjects([self.formatter HTMLForSignature:self.signature], html);
}

@end
