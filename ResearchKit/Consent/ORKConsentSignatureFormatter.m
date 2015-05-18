#import "ORKConsentSignatureFormatter.h"
#import "ORKDefines_Private.h"

@implementation ORKConsentSignatureFormatter

- (NSString *)HTMLForSignature:(ORKConsentSignature *)signature {
    NSMutableString *body = [NSMutableString new];

    NSString *hr = @"<hr align='left' width='100%' style='height:1px; border:none; color:#000; background-color:#000; margin-top: -10px; margin-bottom: 0px;' />";

    NSString *signatureElementWrapper = @"<p><br/><div class='sigbox'><div class='inbox'>%@</div></div>%@%@</p>";

    BOOL addedSig = NO;

    NSMutableArray *signatureElements = [NSMutableArray array];

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
        [signatureElements addObject:[NSString stringWithFormat:signatureElementWrapper, imageTag?:@"&nbsp;", hr, [NSString stringWithFormat:titleFormat, signature.title]]];
    }

    if (addedSig) {
        [signatureElements addObject:[NSString stringWithFormat:signatureElementWrapper, signature.signatureDate?:@"&nbsp;", hr, ORKLocalizedString(@"CONSENT_DOC_LINE_DATE", nil)]];
    }

    NSInteger numElements = [signatureElements count];
    if (numElements > 1) {
        [body appendString:[NSString stringWithFormat:@"<div class='grid border'>"]];
        for (NSString *element in signatureElements) {
            [body appendString:[NSString stringWithFormat:@"<div class='col-1-3 border'>%@</div>",element]];
        }

        [body appendString:@"</div>"];
    } else if (numElements == 1) {
        [body appendString:[NSString stringWithFormat:@"<div width='200'>%@</div>",[signatureElements lastObject]]];
    }
    return body;
}

@end
