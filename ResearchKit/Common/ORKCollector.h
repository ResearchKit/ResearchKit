/*
 Copyright (c) 2016, Apple Inc. All rights reserved.
 
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


#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/ORKErrors.h>
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKCollector;
@class ORKHealthCollector;
@class ORKMotionActivityCollector;


/**
 Abstract class of data collector.
 */
ORK_CLASS_AVAILABLE
@interface ORKCollector : NSObject <NSCopying, NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;

/**
 Identifier of this collector.
 */
@property (copy, readonly) NSString *identifier;

/**
 Serialization helper that produces serialized output.
 Subclasses should implement to provide a default serialization for upload.
 
 @params objects    The objects to be serialized.
 
 @return Serialized data object.
 */
- (NSData *)serializedDataForObjects:(NSArray *)objects;

/**
 Serialization helper that produces objects suitable for serialization to JSON.
 
 Subclasses should implement to provide a default JSON serialization for upload.
 Called by `serializedDataForObjects:`.
 
 @params objects    The objects to be serialized.
 
 @return Serializable dictionary objects.
 */
- (NSArray<NSDictionary *> *)serializableObjectsForObjects:(NSArray *)objects;

@end


/**
 ORKHealthCollector collects HKSample.
 
 It cannot be initiated directly. 
 Use `addHealthCollectorWithSampleType:`to add one to a `ORKDataCollectionManager`.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthCollector : ORKCollector

/**
 HealthKit sample type.
 */
@property (copy, readonly) HKSampleType *sampleType;

/**
 HealthKit unit into which data should be collected.
 */
@property (copy, readonly) HKUnit *unit;

/**
 Samples should be collected starting at this date.
 */
@property (copy, readonly) NSDate *startDate;

/**
 Last anchor already seen.
 */
@property (copy, readonly) HKQueryAnchor *lastAnchor;

@end


/**
 ORKHealthCollector collects HKCorrelation.
 
 It cannot be initiated directly.
 Use `addHealthCorrelationCollectorWithCorrelationType:`to add one to a `ORKDataCollectionManager`.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthCorrelationCollector : ORKCollector

/**
 HealthKit correlation type.
 */
@property (copy, readonly) HKCorrelationType *correlationType;

/**
 Array of HKSampleType expected in the correlation.
 */
@property (copy, readonly) NSArray<HKSampleType *> *sampleTypes;

/**
 Array of HKUnit to use when serializing the samples collected (should be same size as sampleTypes).
 */
@property (copy, readonly) NSArray<HKUnit *> *units;

/**
 Samples should be collected starting at this date.
 */
@property (copy, readonly) NSDate *startDate;

/**
 Last anchor already seen.
 */
@property (copy, readonly) HKQueryAnchor *lastAnchor;

@end


/**
 ORKHealthCollector collects CMMotionActivity.
 
 It cannot be initiated directly.
 Use `addMotionActivityCollectorWithStartDate:`to add one to a `ORKDataCollectionManager`.
 */
ORK_CLASS_AVAILABLE
@interface ORKMotionActivityCollector : ORKCollector

/**
 Samples should be collected starting at this date.
 */
@property (copy, readonly) NSDate *startDate;

/**
 Last anchor already seen.
 */
@property (copy, readonly) NSDate *lastDate;

@end

NS_ASSUME_NONNULL_END
