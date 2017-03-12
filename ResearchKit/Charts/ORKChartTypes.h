/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, James Cox.
 Copyright (c) 2015, Ramsundar Shandilya.
 Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.
 
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


@import UIKit;
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN
/**
 Defines the common attributes of chart values.
 */
@protocol ORKValueCollectionType

/**
 A Boolean value indicating that the value is unset. (read-only)
 */
@property (nonatomic, readonly) BOOL isUnset;

@end


/**
 The `ORKValueRange` class represents a range between two values of the double type. It can be used
 in graph chart plots to draw value ranges.
 */
ORK_CLASS_AVAILABLE
@interface ORKValueRange : NSObject <ORKValueCollectionType>

/**
 Returns a value range initialized using the specified `minimumValue` and `maximumValue`.
 
 @param minimumValue     The `minimumValue` to set.
 @param maximumValue     The `maximumValue` to set.
 
 @return A value range object.
 */
- (instancetype)initWithMinimumValue:(double)minimumValue maximumValue:(double)maximumValue NS_DESIGNATED_INITIALIZER;

/**
 Returns a value range initialized using the specified `value` for both `minimumValue` and
 `maximumValue`. This is useful for plotting data points that model a single value with no range.
 
 This method is a convenience initializer.
 
 @param value    The `minimumValue` and `maximumValue` to set.
 
 @return A value range object.
 */
- (instancetype)initWithValue:(double)value;

/**
 Returns a value range initialized using the `ORKDoubleInvalidValue` value for both `minimumValue`
 and `maximumValue`. This denotes an unset or invalid value range. It is useful, for example, for
 representing unavailable data in discontinous graph chart plots.
 
 This method is a convenience initializer.
 
 @return A value range object initialized with the `ORKDoubleInvalidValue` value.
 */
- (instancetype)init;

/**
 The upper limit of the value range.
 */
@property (nonatomic) double maximumValue;

/**
 The lower limit of the value range.
 */
@property (nonatomic) double minimumValue;

/**
 A Boolean value indicating that `minimumValue` is equal to `maximumValue`. (read-only)
 */
@property (nonatomic, readonly) BOOL isEmptyRange;

/**
 A Boolean value indicating that both `minimum value` and `maximum value` are equal to the
 `ORKDoubleInvalidValue` value. (read-only)
 */
@property (nonatomic, readonly) BOOL isUnset;

@end


/**
 The `ORKValueStack` class represents an arbitrary list of values of the double type. It can be used
 in graph chart plots to draw stacked values.
 */
ORK_CLASS_AVAILABLE
@interface ORKValueStack : NSObject <ORKValueCollectionType>

/**
 Returns an empty value stack.
 
 @return An empty value stack object.
 */
- (instancetype)init;

/**
 Returns a value stack initialized with the passed `NSNumber` array.
 
 @param stackedValues   An array containing `NSNumber` objects.
 
 @return A value stack object initialized with the passed `NSNumber` values.
 */
- (instancetype)initWithStackedValues:(NSArray<NSNumber *> *)stackedValues NS_DESIGNATED_INITIALIZER;

/**
 An array of `NSNumber` objects, each one representing a stacked double value.
 */
@property (nonatomic, copy, readonly) NSArray<NSNumber *> *stackedValues;

/**
 The total sum of the stacked double values
 */
@property (nonatomic) double totalValue;

@end

NS_ASSUME_NONNULL_END
