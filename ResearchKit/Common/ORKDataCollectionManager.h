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
#import <ResearchKit/ResearchKit.h>
#import <CoreMotion/CoreMotion.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKCollector;
@class ORKHealthCollector;
@class ORKHealthCorrelationCollector;
@class ORKMotionActivityCollector;
@class ORKDataCollectionManager;


/**
 The data collection manager delegate is responsible for delivering collected data objects, 
 and reporting errors during the operation.
 */
@protocol ORKDataCollectionManagerDelegate <NSObject>

@optional
/**
 Method for delivering the collected health data samples.
 
 @param collector   The data collector.
 @param samples     Collected health data samples.
 
 @return Boolean indicating whether the samples has be accepted.
 If NO is returned or this method is not implemented, the manager will stop the collection for the collector and repeat this same collection next time,
 until the data is accepted.
 */
- (BOOL)healthCollector:(ORKHealthCollector *)collector didCollectSamples:(NSArray<HKSample *> *)samples;

/**
 Method for delivering the collected health correlations.
 
 @param collector       The data collector.
 @param correlations    Collected health correlation samples.
 
 @return Boolean indicating whether the samples has be accepted.
 If NO is returned or this method is not implemented, the manager will stop the collection for the collector and repeat this same collection next time,
 until the data is accepted.
 */
- (BOOL)healthCorrelationCollector:(ORKHealthCorrelationCollector *)collector didCollectCorrelations:(NSArray<HKCorrelation *> *)correlations;

/**
 Method for delivering the collected motion activities.
 
 @param collector           The data collector.
 @param motionActivities    Collected motion activities.
 
 @return Boolean indicating whether the samples has be accepted.
 If NO is returned or this method is not implemented, the manager will stop the collection for the collector and repeat this same collection next time,
 until the data is accepted.
 */
- (BOOL)motionActivityCollector:(ORKMotionActivityCollector *)collector didCollectMotionActivities:(NSArray<CMMotionActivity *> *)motionActivities;

/**
 Indicating the collection is completed for all the collectors.
 
 @param manager   The data collection manager.
 */
- (void)dataCollectionManagerDidCompleteCollection:(ORKDataCollectionManager *)manager;

/**
 Method for reporting the deteted error during collection.
 
 @param collector   The data collector.
 @param error       The error object.
 */
- (void)collector:(ORKCollector *)collector didDetectError:(NSError *)error;

@end

/**
 The data collection manager is used to collect HealthKit data and CoreMotion data.
 
 It uses collectors to track data types to be collected.
 Anchors are used to track progress of each types of data to avoid duplications.
 Collected data samples are returned in the delegation methods, return YES to confirm the samples has been accepted.
 */
ORK_CLASS_AVAILABLE
@interface ORKDataCollectionManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initiate the manager with a persistence directory.
 The directory is used to store the configurations and progress of the collectors.
 
 @param directoryURL    URL path for the directory.
 
 @return Initiated ORKDataCollectionManager instance.
 */
- (instancetype)initWithPersistenceDirectoryURL:(NSURL *)directoryURL NS_DESIGNATED_INITIALIZER;

/**
 An array of collectors.
 */
@property (copy, readonly) NSArray<ORKCollector *> *collectors;

/**
 Implement the delegate to receive collected data objects.
 */
@property (nonatomic, weak, nullable) id<ORKDataCollectionManagerDelegate> delegate;

/**
 Add a collector for HealthKit quantity and category samples.
 
 @param sampleType  HealthKit sample type.
 @param unit        HealthKit unit into which data should be collected.
 @param startDate   Samples should be collected starting at this date.
 @param error       Any error detected during this operation.
 
 @return Initiated health collector.
 */
- (ORKHealthCollector *)addHealthCollectorWithSampleType:(HKSampleType *)sampleType
                                                    unit:(HKUnit *)unit
                                               startDate:(NSDate *)startDate
                                                   error:(NSError * _Nullable *)error;

/**
 Add a collector for HealthKit correlations.
 
 @param correlationType     HealthKit correlation type.
 @param sampleTypes         Array of HKSampleType expected in the correlation.
 @param units               Array of HKUnit to use when serializing the samples collected (should be same size as sampleTypes).
 @param startDate           Samples should be collected starting at this date.
 @param error               Any error detected during this operation.
 
 @return Initiated health correlation collector.
 */
- (ORKHealthCorrelationCollector *)addHealthCorrelationCollectorWithCorrelationType:(HKCorrelationType *)correlationType
                                                                        sampleTypes:(NSArray<HKSampleType *> *)sampleTypes
                                                                              units:(NSArray<HKUnit *> *)units
                                                                          startDate:(NSDate *)startDate
                                                                              error:(NSError * _Nullable *)error;

/**
 Add a collector for motion activity.
 
 @param startDate     When data collection should start.
 @param error         Error during this operation.

 @return Initiated motion activity collector.
 */
- (ORKMotionActivityCollector *)addMotionActivityCollectorWithStartDate:(NSDate *)startDate
                                                                  error:(NSError * _Nullable *)error;

/**
 Remove a collector.
 
 @param collector     The collector to be removed.
 @param error         Error during this operation.
 
 @return If this operation is successful.
 */
- (BOOL)removeCollector:(ORKCollector *)collector error:(NSError* _Nullable *)error;

/**
 Start data collection.
 This method triggers running all the RKCollector collections associated with the present manager.
 When the collection is completed, delegate recieves a method call `dataCollectionManagerDidCompleteCollection:`.
 */
- (void)startCollection;

@end

NS_ASSUME_NONNULL_END
