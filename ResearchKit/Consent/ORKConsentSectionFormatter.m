#import "ORKConsentSectionFormatter.h"
#import "ORKConsentSection_Internal.h"

@implementation ORKConsentSectionFormatter

- (NSString *)HTMLForSection:(ORKConsentSection *)section {
    NSString *title = [NSString stringWithFormat:@"<h4>%@</h4>", section.formalTitle?:(section.title?:@"")];
    NSString *content = [NSString stringWithFormat:@"<p>%@</p>", section.htmlContent?:(section.escapedContent?:@"")];
    return [NSString stringWithFormat:@"%@%@", title, content];
}

@end
