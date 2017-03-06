//
//  NSAttributedString+NSAttributedString_FontSize.m
//  ResearchKit
//
//  Created by Tomas Srna on 07/01/2017.
//  Copyright © 2017 researchkit.org. All rights reserved.
//

#import "NSAttributedString+FontSize.h"

@implementation NSAttributedString (FontSize)

- (NSAttributedString*) attributedStringWithFontSize:(CGFloat) fontSize
    {
        NSMutableAttributedString* attributedString = [self mutableCopy];
        
        {
            [attributedString beginEditing];
            
            [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                
                if (value && [value isKindOfClass:[UIFont class]]) {
                    UIFont* font = value;
                    font = [font fontWithSize:fontSize];
                    
                    [attributedString removeAttribute:NSFontAttributeName range:range];
                    [attributedString addAttribute:NSFontAttributeName value:font range:range];
                }
            }];
            
            [attributedString endEditing];
        }
        
        return [attributedString copy];
    }

@end
