#import <ResearchKit/ResearchKit.h>
#import <ResearchKit/ORKConsentSignature.h>

@interface ORKConsentSignatureFormatter : NSObject

- (NSString *)HTMLForSignature:(ORKConsentSignature *)signature;

@end
