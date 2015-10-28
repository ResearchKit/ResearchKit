/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.

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


#import <UIKit/UIKit.h>
#import "ORKDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKRangedPoint` class represents a ranged point used in a graph plot.
 */
ORK_CLASS_AVAILABLE
@interface ORKRangedPoint : NSObject

/**
 Returns a range point initialized using the specified `minimumValue` and `maximumValue`.

 @param minimumValue     The `minimumValue` to set.
 @param maximumValue     The `maximumValue` to set.

 @return A range point.
*/
- (instancetype)initWithMinimumValue:(CGFloat)minimumValue maximumValue:(CGFloat)maximumValue NS_DESIGNATED_INITIALIZER;

/**
 Returns a range point initialized using the specified `value` for both `minimumValue` and
 `maximumValue`. This is useful for creating points that model a single data value without a range.

 This method is a convenience initializer.

 @param value    The `minimumValue` and `maximumValue` to set.

 @return A range point.
*/
- (instancetype)initWithValue:(CGFloat)value;

/**
 The upper limit of the range represented by this point.
 The default value of this property is zero.
 */
@property (nonatomic) CGFloat maximumValue;

/**
 The lower limit of the range represented by this point.
 The default value of this property is zero.
 */
@property (nonatomic) CGFloat minimumValue;

/**
 A Boolean value indicating that `minimumValue` is equal to `maximumValue`. (read-only)
*/
@property (nonatomic, readonly) BOOL hasEmptyRange;

/**
 A Boolean value indicating that both `minimum value` and `maximum value` have not been set.  (read-only)
*/
@property (nonatomic, readonly) BOOL isUnset;

@end

NS_ASSUME_NONNULL_END
