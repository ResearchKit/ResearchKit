//
//  ORKTouchAbilitySwipeResult.m
//  ResearchKit
//
//  Created by Tommy Lin on 2018/12/5.
//  Copyright © 2018 researchkit.org. All rights reserved.
//

#import "ORKTouchAbilitySwipeResult.h"
#import "ORKHelpers_Internal.h"

@implementation ORKTouchAbilitySwipeResult

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, trials);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        ORK_ENCODE_OBJ(aDecoder, trials);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame && ORKEqualObjects(self.trials, castObject.trials);
}

- (NSUInteger)hash {
    return super.hash ^ self.trials.hash;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilitySwipeResult *result = [super copyWithZone:zone];
    result.trials = [self.trials mutableCopy];
    return result;
}

- (NSArray<ORKTouchAbilitySwipeTrial *> *)trials {
    if (!_trials) {
        _trials = [NSArray new];
    }
    return _trials;
}

@end
