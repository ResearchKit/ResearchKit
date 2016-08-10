//
//  ORKHTMLPDFPageRenderer.m
//  ResearchKit
//
//  Created by Ortman, Chris E on 8/10/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKErrors.h"
#import "ORKHelpers_Internal.h"
#import "ORKDefines.h"
#import "ORKHTMLPDFPageRenderer.h"

@implementation ORKHTMLPDFPageRenderer

- (CGRect)paperRect {
    return UIGraphicsGetPDFContextBounds();
}

- (CGRect)printableRect {
    return UIEdgeInsetsInsetRect([self paperRect], _pageMargins);
}

- (void)drawFooterForPageAtIndex:(NSInteger)pageIndex
                          inRect:(CGRect)footerRect {
    NSString *footer  = [NSString stringWithFormat:ORKLocalizedString(@"CONSENT_PAGE_NUMBER_FORMAT", nil), (long)(pageIndex + 1), (long)[self numberOfPages]];
    
    if (footer) {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];
        CGSize size = [footer sizeWithAttributes:@{ NSFontAttributeName: font}];
        
        // Center Text
        CGFloat drawX = (CGRectGetWidth(footerRect) / 2) + footerRect.origin.x - (size.width / 2);
        CGFloat drawY = footerRect.origin.y + (footerRect.size.height / 2) - (size.height / 2);
        CGPoint drawPoint = CGPointMake(drawX, drawY);
        
        [footer drawAtPoint:drawPoint withAttributes:@{ NSFontAttributeName: font}];
    }
}

@end
