//
//  ORKLanguageHelper.h
//  ResearchKit
//
//  Created by Mike Leveton on 4/4/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ORKLocalizedString(key, comment) [ORKLanguageHelper languageSelectedForKey:(key) value:@"" table:nil]
@interface ORKLanguageHelper : NSObject

+ (NSString *)languageSelectedForKey:(NSString *)key value:(NSString *)value table:(id)table;

@end
