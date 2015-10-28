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


static NSString *const HKSampleIdentifierKey = @"type"; // For compatibility with Health XML export
static NSString *const HKUUIDKey = @"uuid";
static NSString *const HKSampleStartDateKey = @"startDate";
static NSString *const HKSampleEndDateKey = @"endDate";
static NSString *const HKSampleValue = @"value";
static NSString *const HKMetadataKey = @"metadata";
static NSString *const HKSourceKey = @"source";
static NSString *const HKUnitKey = @"unit";
static NSString *const HKCorrelatedObjectsKey = @"objects";
// static NSString *const HKSourceIdentifierKey = @"sourceBundleIdentifier";


@implementation HKSample (ORKJSONDictionary)

- (NSMutableDictionary *)ork_JSONMutableDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:12];
    
    // Type identification
    HKSampleType *sampleType = [self sampleType];
    mutableDictionary[HKSampleIdentifierKey] = [sampleType identifier];
    
    // consider adding @"class" : NSStringFromClass(sampleType) ?
    
    // Start and end dates
    NSDate *startDate = [self startDate];
    if (startDate) {
        mutableDictionary[HKSampleStartDateKey] = ORKStringFromDateISO8601(startDate);
    }
    
    NSDate *endDate = [self endDate];
    if (endDate) {
        mutableDictionary[HKSampleEndDateKey] = ORKStringFromDateISO8601(endDate);
    }
    if (unit) {
        mutableDictionary[HKUnitKey] = [unit unitString];
    }
    if ((options & ORKSampleIncludeUUID)) {
        NSUUID *uuid = [self UUID];
        if (uuid) {
            mutableDictionary[HKUUIDKey] = uuid.UUIDString;
        }
    }
    
    if ( (options & ORKSampleIncludeMetadata) && self.metadata.count > 0) {
        NSMutableDictionary *metadata = [self.metadata mutableCopy];
        for (NSString *k in metadata) {
            id obj = metadata[k];
            if ([obj isKindOfClass:[NSDate class]]) {
                metadata[k] = ORKStringFromDateISO8601(obj);
            }
        }
        
        mutableDictionary[HKMetadataKey] = metadata;
    }
    
    if (options & ORKSampleIncludeSource) {
        HKSource *source = [self source];
        if (source.name) {
            mutableDictionary[HKSourceKey] = source.name;
        }
    }
        
    return mutableDictionary;
}

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    return [self ork_JSONMutableDictionaryWithOptions:options unit:unit];
}

@end


@interface HKCategorySample (ORKJSONDictionary)

@end


@implementation HKCategorySample (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *dictionary = [self ork_JSONMutableDictionaryWithOptions:options unit:unit];
    
    NSInteger value = self.value;
    dictionary[HKSampleValue] = @(value);
    
    return dictionary;
}

@end


@interface HKQuantitySample (ORKJSONDictionary)

@end


@implementation HKQuantitySample (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options unit:(HKUnit *)unit {
    NSMutableDictionary *dictionary = [self ork_JSONMutableDictionaryWithOptions:options unit:unit];
    
    HKQuantity *quantity = [self quantity];
    double value = [quantity doubleValueForUnit:unit];
    dictionary[HKSampleValue] = @(value);
    
    
    return dictionary;
}

@end


@implementation HKCorrelation (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionaryWithOptions:(ORKSampleJSONOptions)options sampleTypes:(NSArray *)sampleTypes units:(NSArray *)units {
    NSMutableDictionary *mutableDictionary = [self ork_JSONMutableDictionaryWithOptions:options unit:nil];
    
    // The correlated objects
    NSMutableArray *correlatedObjects = [NSMutableArray arrayWithCapacity:sampleTypes.count];
    for (HKSample *sample in self.objects) {
        NSUInteger idx = [sampleTypes indexOfObject:sample.sampleType];
        if (idx == NSNotFound) {
            continue;
        }
        
        [correlatedObjects addObject:[sample ork_JSONDictionaryWithOptions:options unit:units[idx]]];
    }
    mutableDictionary[HKCorrelatedObjectsKey] = correlatedObjects;
    
    return mutableDictionary;
}

@end
