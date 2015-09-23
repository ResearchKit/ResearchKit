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


#import "CMMotionActivity+ORKJSONDictionary.h"
#import "ORKHelpers.h"


static NSString *const ActivityUnknown = @"unknown";
static NSString *const ActivityStationary = @"stationary";
static NSString *const ActivityWalking = @"walking";
static NSString *const ActivityRunning = @"running";
static NSString *const ActivityAutomotive = @"automotive";
static NSString *const StartDateKey = @"startDate";
static NSString *const EndDateKey = @"endDate";

static NSString *stringFromActivityConfidence(CMMotionActivityConfidence confidence) {
    NSDictionary *confidences = @{@(CMMotionActivityConfidenceHigh) : @"high",
                                  @(CMMotionActivityConfidenceMedium) : @"medium",
                                  @(CMMotionActivityConfidenceLow) : @"low"};
    return confidences[@(confidence)];
}

static NSArray *activityArray(CMMotionActivity *activity) {
    NSMutableArray *array = [NSMutableArray array];
    if (activity.unknown) {
        [array addObject:ActivityUnknown];
    }
    if (activity.stationary) {
        [array addObject:ActivityStationary];
    }
    if (activity.walking) {
        [array addObject:ActivityWalking];
    }
    if (activity.running) {
        [array addObject:ActivityRunning];
    }
    if (activity.automotive) {
        [array addObject:ActivityAutomotive];
    }
    return array;
}

static NSString *const ActivityKey = @"activity";
static NSString *const ConfidenceKey = @"confidence";

@implementation CMMotionActivity (ORKJSONDictionary)

- (NSDictionary *)ork_JSONDictionary {
    return @{ConfidenceKey : stringFromActivityConfidence(self.confidence),
             ActivityKey : activityArray(self),
             StartDateKey : ORKStringFromDateISO8601(self.startDate)};
}

@end
