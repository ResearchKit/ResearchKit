//
//  ORKLanguageHelper.m
//  ResearchKit
//
//  Created by Mike Leveton on 4/4/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKLanguageHelper.h"
#import "ORKSingleton.h"
#import "ORKStep.h"

@implementation ORKLanguageHelper

+ (NSString *)languageSelectedForKey:(NSString *)key value:(NSString *)value table:(id)table{
    
    NSString *path;
    NSString *selectedLanguage = [ORKSingleton sharedSingleton].currentLanguage;
    NSBundle *bundle = [NSBundle bundleForClass:[ORKStep class]];
    
    if([selectedLanguage isEqualToString:@"English"]){
        NSLog(@"REACHED SET AS ENGLISH");
        path = [bundle pathForResource:@"en" ofType:@"lproj"];
    } else if ([selectedLanguage isEqualToString:@"Español"]){
        NSLog(@"REACHED SET AS SPANISH");
        path = [bundle pathForResource:@"es" ofType:@"lproj"];
    } else {
        /* default to english */
        NSLog(@"REACHED FELL THROUGH TO ENGLISH");
        path = [bundle pathForResource:@"en" ofType:@"lproj"];
    }
    
    NSBundle *languageBundle = [NSBundle bundleWithPath:path];
    NSString *str = [languageBundle localizedStringForKey:key value:@"" table:@"ResearchKit"];
    return str;
}

@end
