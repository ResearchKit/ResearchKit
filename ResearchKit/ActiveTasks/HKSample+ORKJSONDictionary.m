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


#import "HKSample+ORKJSONDictionary.h"
#import "ORKHelpers.h"

static NSString *const kHKSampleIdentifierKey = @"type"; // For compatibility with Health XML export
static NSString *const kHKUUIDKey = @"uuid";
static NSString *const kHKSampleStartDateKey = @"startDate";
static NSString *const kHKSampleEndDateKey = @"endDate";
static NSString *const kHKSampleValue = @"value";
static NSString *const kHKMetadataKey = @"metadata";
static NSString *const kHKSourceKey = @"source";
static NSString *const kHKUnitKey = @"unit";
static NSString *const kHKCorrelatedObjectsKey = @"objects";
// static NSString *const kHKSourceIdentifierKey = @"sourceBundleIdentifier";

@interface HKCategorySample (ORKJSONDictionary)

@end

@interface HKQuantitySample (ORKJSONDictionary)

@end


@implementation HKSample (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithCapacity:12];
    
    // Type identification
    HKSampleType *sampleType = [self sampleType];
    mdict[kHKSampleIdentifierKey] = [sampleType identifier];
    
    // consider adding @"class" : NSStringFromClass(sampleType) ?
    
    // Start and end dates
    NSDate *startDate = [self startDate];
    if (startDate) {
        mdict[kHKSampleStartDateKey] = ORKStringFromDateISO8601(startDate);
    }
    
    NSDate *endDate = [self endDate];
    if (endDate) {
        mdict[kHKSampleEndDateKey] = ORKStringFromDateISO8601(endDate);
    }
    if (unit) {
        mdict[kHKUnitKey] = [unit unitString];
    }
    if ((options & ORKSampleIncludeUUID)) {
        NSUUID *uuid = [self UUID];
        if (uuid) {
            mdict[kHKUUIDKey] = [uuid UUIDString];
        }
    }
    
    if ( (options & ORKSampleIncludeMetadata) && [self.metadata count] > 0) {
        NSMutableDictionary *metadata = [self.metadata mutableCopy];
        for (NSString *k in metadata) {
            id obj = metadata[k];
            if ([obj isKindOfClass:[NSDate class]]) {
                metadata[k] = ORKStringFromDateISO8601(obj);
            }
        }
        
        mdict[kHKMetadataKey] = metadata;
    }
    
    if (options & ORKSampleIncludeSource) {
        HKSource *source = [self source];
        if (source.name) {
            mdict[kHKSourceKey] = source.name;
        }
    }
        
    return mdict;
}

@end


@implementation HKCategorySample (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *dict = [[super ork_JSONDictionaryWithOptions:options unit:unit] mutableCopy];
    
    NSInteger value = [self value];
    dict[kHKSampleValue] = @(value);
    
    return dict;
}

@end

@implementation HKQuantitySample (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *dict = [[super ork_JSONDictionaryWithOptions:options unit:unit] mutableCopy];
    
    HKQuantity *quantity = [self quantity];
    double value = [quantity doubleValueForUnit:unit];
    dict[kHKSampleValue] = @(value);
    
    
    return dict;
}

@end


@implementation HKCorrelation (ORKJSONDictionary)


- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options sampleTypes:(NSArray *)sampleTypes units:(NSArray *)units {
    NSMutableDictionary *mdict = (NSMutableDictionary *)[self ork_JSONDictionaryWithOptions:options unit:nil];
    
    // The correlated objects
    NSMutableArray *correlatedObjects = [NSMutableArray arrayWithCapacity:[sampleTypes count]];
    for (HKSample *sample in self.objects) {
        NSUInteger idx = [sampleTypes indexOfObject:sample.sampleType];
        if (idx == NSNotFound) {
            continue;
        }
        
        [correlatedObjects addObject:[sample ork_JSONDictionaryWithOptions:options unit:units[idx]]];
    }
    mdict[kHKCorrelatedObjectsKey] = correlatedObjects;
    
    
    return mdict;
}

@end
