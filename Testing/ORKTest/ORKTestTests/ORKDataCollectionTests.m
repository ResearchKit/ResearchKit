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


#import <XCTest/XCTest.h>
#import <ResearchKit/ResearchKit.h>


@interface ORKDataCollectionTests : XCTestCase <ORKDataCollectionManagerDelegate>

@end


@implementation ORKDataCollectionTests {
    XCTestExpectation *_completionExpectation;
    XCTestExpectation *_healthCollectionExpectation;
    XCTestExpectation *_correlationCollectionExpectation;
    HKHealthStore *_healthStore;
    BOOL _acceptDelivery;
    NSInteger _errorCount;
}

- (BOOL)fileExistAt:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (NSString *)documentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

- (NSString *)sourcePath {
    NSString *sourcePath = [[self documentPath] stringByAppendingPathComponent:@"source"];
    [[NSFileManager defaultManager] createDirectoryAtPath:sourcePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return sourcePath;
}

- (NSString *)basePath {
    NSString *testPath = [[self documentPath] stringByAppendingPathComponent:@"test"];
    [[NSFileManager defaultManager] createDirectoryAtPath:testPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return testPath;
}

- (NSString *)storePath {
    NSString *basePath = [self basePath];
    NSString *storePath = [basePath stringByAppendingPathComponent:@"managedDataCollectionStore"];
    return storePath;
}

- (NSString *)cleanStorePath {
    NSString *storePath = [self storePath];
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
    return storePath;
}

static ORKDataCollectionManager *createManagerWithCollectors(NSURL *url,
                                                             NSDate *startDate,
                                                             ORKMotionActivityCollector **motionCollector,
                                                             ORKHealthCollector **healthCollector,
                                                             ORKHealthCorrelationCollector **healthCorrelationCollector,
                                                             NSError **error) {
    
    ORKDataCollectionManager *manager = [[ORKDataCollectionManager alloc] initWithPersistenceDirectoryURL:url];
    
    ORKMotionActivityCollector *mac = [manager addMotionActivityCollectorWithStartDate:startDate error:error];
    if (motionCollector) {
        *motionCollector = mac;
    }
    
    if (error && *error) {
        return  nil;
    }
    
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKUnit *unit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    ORKHealthCollector *hc = [manager addHealthCollectorWithSampleType:type
                                                                  unit:unit
                                                             startDate:startDate
                                                                 error:error];

    if (healthCollector) {
        *healthCollector = hc;
    }
    
    if (error && *error) {
        return  nil;
    }
    
    HKCorrelationType *correlationType = [HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
    NSArray<HKSampleType *> *sampleTypes = @[[HKObjectType quantityTypeForIdentifier: HKQuantityTypeIdentifierBloodPressureDiastolic],
                                             [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]];
    NSArray<HKUnit *> *units = @[[HKUnit unitFromString:@"mmHg"], [HKUnit unitFromString:@"mmHg"]];
    
    ORKHealthCorrelationCollector *hcc = [manager addHealthCorrelationCollectorWithCorrelationType:correlationType
                                                                                       sampleTypes:sampleTypes
                                                                                             units:units
                                                                                         startDate:startDate
                                                                                             error:error];
    
    if (healthCorrelationCollector) {
        *healthCorrelationCollector = hcc;
    }
    
    if (error && *error) {
        return  nil;
    }
    
    return manager;
}

- (void)setUp {
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *diastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *systolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    NSSet *types = [NSSet setWithObjects:heartRateType, diastolicType, systolicType, nil];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for grant permissions"];
    [[HKHealthStore new] requestAuthorizationToShareTypes:types readTypes:types
                                               completion:^(BOOL success, NSError * _Nullable error) {
                                                   [expectation fulfill];
                                               }];
    
    _acceptDelivery = YES;
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testBasicOperations {
    
    ORKMotionActivityCollector *motionCollector;
    ORKHealthCollector *healthCollector;
    ORKHealthCorrelationCollector *healthCorrelationCollector;
    NSError *error;
    // Create
    ORKDataCollectionManager *manager = createManagerWithCollectors([NSURL fileURLWithPath:[self cleanStorePath]],
                                                                    [NSDate date],
                                                                    &motionCollector,
                                                                    &healthCollector,
                                                                    &healthCorrelationCollector,
                                                                    &error);
    
    XCTAssertNil(error);
    XCTAssertEqual(manager.collectors.count, 3);
    
    // Re-init
    manager = [[ORKDataCollectionManager alloc] initWithPersistenceDirectoryURL:[NSURL fileURLWithPath:[self storePath]]];
    XCTAssertEqual(manager.collectors.count, 3);
    
    // Remove Collector
    [manager removeCollector:motionCollector error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(manager.collectors.count, 2);
    
    [manager removeCollector:healthCollector error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(manager.collectors.count, 1);
    
    [manager removeCollector:healthCorrelationCollector error:&error];
    XCTAssertNil(error);
    XCTAssertEqual(manager.collectors.count, 0);

}


typedef NS_OPTIONS (NSInteger, SampleDataType) {
    SampleDataTypeHR = 1 << 0,
    SampleDataTypeBP = 1 << 1,
    SampleDataTypeALL= SampleDataTypeHR|SampleDataTypeBP
};


- (BOOL)insertSampleDataWithType:(SampleDataType)sampleDataType
                       startDate:(NSDate *)startDate
                         endDate:(NSDate *)endDate {
    _healthStore = [[HKHealthStore alloc] init];
    
    HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *diastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *systolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    HKAuthorizationStatus heartRateTypeStatus = [_healthStore authorizationStatusForType:heartRateType];
    HKAuthorizationStatus diastolicTypeStatus = [_healthStore authorizationStatusForType:diastolicType];
    HKAuthorizationStatus systolicTypeStatus = [_healthStore authorizationStatusForType:systolicType];
    
    BOOL authorized = (heartRateTypeStatus == HKAuthorizationStatusSharingAuthorized
                       && diastolicTypeStatus == HKAuthorizationStatusSharingAuthorized
                       && systolicTypeStatus == HKAuthorizationStatusSharingAuthorized);
    
    if (authorized) {
        
#if TARGET_OS_SIMULATOR
        
        // Heart Rate
        HKUnit *hrUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
        HKQuantity* quantity = [HKQuantity quantityWithUnit:hrUnit doubleValue:(NSInteger)([NSDate date].timeIntervalSinceReferenceDate)%100];
        HKQuantitySample *heartRateSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:quantity startDate:startDate endDate:endDate];
        
        NSString *identifier = HKCorrelationTypeIdentifierBloodPressure;
        HKUnit *bpUnit = [HKUnit unitFromString:@"mmHg"];
        
        // Blood Presure
        HKQuantitySample *diastolicPressure = [HKQuantitySample quantitySampleWithType:diastolicType quantity:[HKQuantity quantityWithUnit:bpUnit doubleValue:70] startDate:startDate endDate:endDate];
        HKQuantitySample *systolicPressure = [HKQuantitySample quantitySampleWithType:systolicType quantity:[HKQuantity quantityWithUnit:bpUnit doubleValue:110] startDate:startDate endDate:endDate];
        
        HKCorrelation *bloodPressureCorrelation = [HKCorrelation correlationWithType:[HKCorrelationType correlationTypeForIdentifier:identifier] startDate:startDate endDate:endDate objects:[NSSet setWithObjects:diastolicPressure, systolicPressure, nil]];
        
        NSMutableArray *objects = [NSMutableArray new];
        if (sampleDataType & SampleDataTypeHR) {
            [objects addObject:heartRateSample];
        }
        if (sampleDataType & SampleDataTypeBP) {
            [objects addObject:bloodPressureCorrelation];
        }
        
        [_healthStore saveObjects:objects withCompletion:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"HK sample saving = %@, error = %@", success ? @"success" : @"failed", error);
        }];

#endif
    } else {
        NSLog(@"HKHealthStore access has not been authorized.");
    }

    return authorized;
}

- (void)testDataCollection {
    
    ORKMotionActivityCollector *motionCollector;
    ORKHealthCollector *healthCollector;
    ORKHealthCorrelationCollector *healthCorrelationCollector;
    __block NSError *error;
    ORKDataCollectionManager *manager = createManagerWithCollectors([NSURL fileURLWithPath:[self cleanStorePath]],
                                                                    [NSDate dateWithTimeIntervalSinceNow:-10],
                                                                    &motionCollector,
                                                                    &healthCollector,
                                                                    &healthCorrelationCollector,
                                                                    &error);
    
    manager.delegate = self;
    
    // First round collection
    _completionExpectation = [self expectationWithDescription:@"Expectation for collection completion"];
    
#if TARGET_OS_SIMULATOR
    if ([self insertSampleDataWithType:SampleDataTypeALL
                             startDate:[NSDate dateWithTimeIntervalSinceNow:-9]
                               endDate:[NSDate dateWithTimeIntervalSinceNow:-8]]) {
        _healthCollectionExpectation = [self expectationWithDescription:@"Expectation for health sample collection completion"];
        _correlationCollectionExpectation = [self expectationWithDescription:@"Expectation for correlation collection completion"];
    }
#endif
    
    [manager startCollection];
    
    // Test removing collector during collection
    BOOL result = [manager removeCollector:healthCollector error:&error];
    XCTAssertFalse(result);
    XCTAssertNotNil(error);
    XCTAssertEqual(manager.collectors.count, 3);

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    
    // Test removing collector after collection
    result = [manager removeCollector:healthCollector error:&error];
    XCTAssertTrue(result);
    XCTAssertNil(error);
    XCTAssertEqual(manager.collectors.count, 2);
    
    // Second round collection
    _completionExpectation = [self expectationWithDescription:@"Expectation for collection completion"];
    
#if TARGET_OS_SIMULATOR
    if ([self insertSampleDataWithType:SampleDataTypeBP
                             startDate:[NSDate dateWithTimeIntervalSinceNow:-9]
                               endDate:[NSDate dateWithTimeIntervalSinceNow:-8]]) {
        // Health Collector was removed
        _healthCollectionExpectation = nil;
        _correlationCollectionExpectation = [self expectationWithDescription:@"Expectation for correlation collection completion"];
    }
#endif
    
    [manager startCollection];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
       XCTAssertNil(error);
    }];

}

- (void)testDataCollectionWithoutCollectors {
    
    ORKMotionActivityCollector *motionCollector;
    ORKHealthCollector *healthCollector;
    ORKHealthCorrelationCollector *healthCorrelationCollector;
    __block NSError *error;
    ORKDataCollectionManager *manager = createManagerWithCollectors([NSURL fileURLWithPath:[self cleanStorePath]],
                                                                    [NSDate date],
                                                                    &motionCollector,
                                                                    &healthCollector,
                                                                    &healthCorrelationCollector,
                                                                    &error);
    
    manager.delegate = self;
    
    [manager removeCollector:motionCollector error:&error];
    [manager removeCollector:healthCollector error:&error];
    [manager removeCollector:healthCorrelationCollector error:&error];
    
    _completionExpectation = [self expectationWithDescription:@"Expectation for collection completion"];
    
    [manager startCollection];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testDataCollectionDelegateDeliveryRejection {
    _acceptDelivery = NO;
    _errorCount = 0;
    
    ORKMotionActivityCollector *motionCollector;
    ORKHealthCollector *healthCollector;
    ORKHealthCorrelationCollector *healthCorrelationCollector;
    __block NSError *error;
    
    // Make sure the startDate isn't earlier that the dates
    // of the samples added on '-testDataCollection'.
    // Othersie, you'll get the samples from that test too.
    ORKDataCollectionManager *manager = createManagerWithCollectors([NSURL fileURLWithPath:[self cleanStorePath]],
                                                                    [NSDate dateWithTimeIntervalSinceNow:-5],
                                                                    &motionCollector,
                                                                    &healthCollector,
                                                                    &healthCorrelationCollector,
                                                                    &error);
    
    manager.delegate = self;
    
    _completionExpectation = [self expectationWithDescription:@"Expectation for collection completion"];
    
#if TARGET_OS_SIMULATOR
    if ([self insertSampleDataWithType:SampleDataTypeALL
                             startDate:[NSDate dateWithTimeIntervalSinceNow:-4]
                               endDate:[NSDate dateWithTimeIntervalSinceNow:-3]]) {
        _healthCollectionExpectation = [self expectationWithDescription:@"Expectation for health sample collection completion"];
        _correlationCollectionExpectation = [self expectationWithDescription:@"Expectation for correlation collection completion"];
    }
#endif

    [manager startCollection];
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    XCTAssertEqual(_errorCount, 2);
}

#pragma mark - delegate

- (BOOL)healthCollector:(ORKHealthCollector *)collector
      didCollectSamples:(NSArray<HKSample *> *)samples {
    XCTAssertEqual(samples.count, 1);
    [_healthCollectionExpectation fulfill];
    NSLog(@"Did collect health samples");
    return _acceptDelivery;
}

- (BOOL)healthCorrelationCollector:(ORKHealthCorrelationCollector *)collector
            didCollectCorrelations:(NSArray<HKCorrelation *> *)correlations {
    XCTAssertEqual(correlations.count, 1);
    [_correlationCollectionExpectation fulfill];
    NSLog(@"Did collect correlation samples");
    return _acceptDelivery;
}

- (BOOL)motionActivityCollector:(ORKMotionActivityCollector *)collector
     didCollectMotionActivities:(NSArray<CMMotionActivity *> *)motionActivities {
    XCTAssertGreaterThan(motionActivities.count, 0);
    NSLog(@"Did collect CMMotionActivity samples");
    return _acceptDelivery;
}

- (void)dataCollectionManagerDidCompleteCollection:(ORKDataCollectionManager *)manager {
    NSLog(@"dataCollectionManagerDidCompleteCollection %@", @(_acceptDelivery));
    [_completionExpectation fulfill];
}

- (void)collector:(ORKCollector *)collector didDetectError:(NSError *)error {
    NSLog(@"didDetectError %@", error);
    if (_acceptDelivery) {
        XCTAssertNil(error);
    }
    _errorCount++;
}

@end
