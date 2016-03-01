//
//  ORKFloatStack.m
//  ResearchKit
//
//  Created by Ricardo Sánchez-Sáez on 08/02/2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKFloatStack.h"

@implementation ORKFloatStack

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithStackedValues:(CGFloat)value, ... NS_REQUIRES_NIL_TERMINATION {
    self = [super init];
    if (self) {
        NSMutableArray *stackedValues = [NSMutableArray new];
        CGFloat totalValue = 0;
        
        va_list arguemntList;
        va_start(arguemntList, value);
        
        CGFloat argument = 0;
        while ((argument = va_arg(arguemntList, CGFloat))) {
            [stackedValues addObject:@(argument)];
            totalValue += argument;
        }
        
        va_end(arguemntList);
        _stackedValues = [stackedValues copy];
        _totalValue = totalValue;
    }
    return self;
}


@end
