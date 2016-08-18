/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


@import XCTest;
@import ResearchKit.Private;

#import "HKSample+ORKJSONDictionary.h"


@interface ORKHKSampleTests : XCTestCase

@end


@implementation ORKHKSampleTests

- (void)testHKSampleSerialization {
    NSDate *d1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate *d2 = [NSDate dateWithTimeInterval:10 sinceDate:d1];
    
    NSString *identifier = HKQuantityTypeIdentifierStepCount;
    HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:identifier] quantity:[HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:5] startDate:d1 endDate:d2];
    
    NSDictionary *dict = [quantitySample ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeMetadata|ORKSampleIncludeSource|ORKSampleIncludeUUID) unit:[HKUnit countUnit]];
    
    XCTAssertEqualObjects(dict[@"uuid"], [quantitySample UUID].UUIDString, @"");
    XCTAssertEqualObjects(dict[@"type"], identifier, @"");
    XCTAssertEqualObjects(dict[@"startDate"], ORKStringFromDateISO8601(d1), @"");
    XCTAssertEqualObjects(dict[@"endDate"], ORKStringFromDateISO8601(d2), @"");
    XCTAssertEqualObjects(dict[@"value"], @(5), @"");
    XCTAssertNil(dict[@"sourceBundleIdentifier"], @"");
    XCTAssertNil(dict[@"sourceName"], @"");
    XCTAssertNil(dict[@"metadata"], @"");
}

- (void)testHKMetadataSerialization {
    NSDate *d1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate *d2 = [NSDate dateWithTimeInterval:10 sinceDate:d1];
    
    NSDictionary *testMeta = @{@"k1": @"v1"};
    
    NSString *identifier = HKQuantityTypeIdentifierStepCount;
    HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:[HKQuantityType quantityTypeForIdentifier:identifier] quantity:[HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:5] startDate:d1 endDate:d2 metadata:testMeta ];
    
    // No metadata if not requested
    NSDictionary *dict = [quantitySample ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeSource) unit:[HKUnit countUnit]];
    XCTAssertNil(dict[@"metadata"], @"");
    
    // Verify metadata appears when requested
    dict = [quantitySample ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeMetadata|ORKSampleIncludeSource|ORKSampleIncludeUUID) unit:[HKUnit countUnit]];
    XCTAssertEqualObjects(testMeta, dict[@"metadata"], @"");
}

- (void)testHKCorrelationSerialization {
    NSDate *d1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate *d2 = [NSDate dateWithTimeInterval:10 sinceDate:d1];
    
    NSString *identifier = HKCorrelationTypeIdentifierBloodPressure;
    HKUnit *unit = [HKUnit unitFromString:@"mmHg"];
    HKQuantityType *diastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *systolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantitySample *dPressure = [HKQuantitySample quantitySampleWithType:diastolicType quantity:[HKQuantity quantityWithUnit:unit doubleValue:70] startDate:d1 endDate:d2];
    HKQuantitySample *sPressure = [HKQuantitySample quantitySampleWithType:systolicType quantity:[HKQuantity quantityWithUnit:unit doubleValue:110] startDate:d1 endDate:d2];
    
    HKCorrelation *correlation = [HKCorrelation correlationWithType:[HKCorrelationType correlationTypeForIdentifier:identifier] startDate:d1 endDate:d2 objects:[NSSet setWithObjects:dPressure, sPressure, nil]];
    
    NSDictionary *dict = [correlation ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeMetadata|ORKSampleIncludeSource|ORKSampleIncludeUUID) sampleTypes:@[diastolicType,systolicType] units:@[unit, unit]];
    
    NSDictionary *dd = [dPressure ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeMetadata|ORKSampleIncludeSource|ORKSampleIncludeUUID) unit:unit];
    NSDictionary *ds = [sPressure ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)(ORKSampleIncludeMetadata|ORKSampleIncludeSource|ORKSampleIncludeUUID) unit:unit];
    
    XCTAssertEqualObjects(dict[@"uuid"], [correlation UUID].UUIDString, @"");
    XCTAssertEqualObjects(dict[@"type"], identifier, @"");
    XCTAssertEqualObjects(dict[@"startDate"], ORKStringFromDateISO8601(d1), @"");
    XCTAssertEqualObjects(dict[@"endDate"], ORKStringFromDateISO8601(d2), @"");
    XCTAssertNil(dict[@"sourceBundleIdentifier"], @"");
    XCTAssertNil(dict[@"sourceName"], @"");
    XCTAssertNil(dict[@"metadata"], @"");
    XCTAssertTrue([dict[@"objects"] containsObject:dd], @"");
    XCTAssertTrue([dict[@"objects"] containsObject:ds], @"");
}

@end
