/*
 Copyright (c) 2017, Chris Ortman, University of Iowa, All rights reserved.

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
