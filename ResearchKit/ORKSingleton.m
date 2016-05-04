//
//  ORKSingleton.m
//  ResearchKit
//
//  Created by Mike Leveton on 4/4/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKSingleton.h"

@implementation ORKSingleton

static ORKSingleton *_sharedSingleton = nil;

+ (ORKSingleton *)sharedSingleton
{
    static dispatch_once_t pred;
    static ORKSingleton *instance = nil;
    dispatch_once(&pred, ^{instance = [[self alloc]init];});
    return instance;
}

+(id)alloc
{
    @synchronized([ORKSingleton class])
    {
        NSAssert(_sharedSingleton == nil, @"Attempted to allocate a second instance of a ORKSingleton.");
        _sharedSingleton = [super alloc];
        return _sharedSingleton;
    }
    
    return nil;
}

-(id)init {
    self = [super init];
    
    if (self != nil) {
        
    }
    
    return self;
}

@end
