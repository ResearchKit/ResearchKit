//
//  ORKFloatStack.h
//  ResearchKit
//
//  Created by Ricardo Sánchez-Sáez on 08/02/2016.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ORKFloatStack : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStackedValues:(CGFloat)value, ... NS_REQUIRES_NIL_TERMINATION NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSArray *stackedValues;

@property (nonatomic) CGFloat totalValue;

@end

NS_ASSUME_NONNULL_END
