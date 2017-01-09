//
//  NSAttributedString+FontSize.h
//  ResearchKit
//
//  Created by Tomas Srna on 07/01/2017.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

@import Foundation;
@import UIKit;

#ifndef NSAttributedString_FontSize_h
#define NSAttributedString_FontSize_h

@interface NSAttributedString (FontSize)
    
- (NSAttributedString*) attributedStringWithFontSize:(CGFloat) fontSize;
    
@end

#endif /* NSAttributedString_FontSize_h */
