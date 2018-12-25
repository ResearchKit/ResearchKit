/*
 Copyright (c) 2018, Muh-Tarng Lin. All rights reserved.
 
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


#import "ORKTouchAbilityTrial.h"
#import "ORKTouchAbilityTrial_Internal.h"
#import "ORKTouchAbilityTrack.h"
#import "ORKTouchAbilityGestureRecoginzerEvent.h"

#import "ORKHelpers_Internal.h"


@implementation ORKTouchAbilityTrial

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, startDate);
    ORK_ENCODE_OBJ(aCoder, endDate);
    ORK_ENCODE_OBJ(aCoder, tracks);
    ORK_ENCODE_OBJ(aCoder, gestureRecognizerEvents);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ(aDecoder, startDate);
        ORK_DECODE_OBJ(aDecoder, endDate);
        ORK_DECODE_OBJ(aDecoder, tracks);
        ORK_DECODE_OBJ(aDecoder, gestureRecognizerEvents);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ORKTouchAbilityTrial *trial = [[[self class] allocWithZone:zone] init];
    trial.startDate = [self.startDate copy];
    trial.endDate = [self.endDate copy];
    trial.tracks = [self.tracks copy];
    trial.gestureRecognizerEvents = [self.gestureRecognizerEvents copy];
    return trial;
}

- (BOOL)isEqual:(id)object {
    
    if ([self class] != [object class]) {
        return NO;
    }
    
    __typeof(self) castObject = object;
    
    return (ORKEqualObjects(self.startDate, castObject.startDate) &&
            ORKEqualObjects(self.endDate, castObject.endDate) &&
            ORKEqualObjects(self.tracks, castObject.tracks) &&
            ORKEqualObjects(self.gestureRecognizerEvents, castObject.gestureRecognizerEvents));
}

- (NSDate *)startDate {
    if (!_startDate) {
        _startDate = [NSDate distantPast];
    }
    return _startDate;
}

- (NSDate *)endDate {
    if (!_endDate) {
        _endDate = [NSDate distantFuture];
    }
    return _endDate;
}

- (NSArray<ORKTouchAbilityTrack *> *)tracks {
    if (!_tracks) {
        _tracks = [NSArray new];
    }
    return _tracks;
}

- (NSArray<ORKTouchAbilityGestureRecoginzerEvent *> *)gestureRecoginzerEvents {
    if (!_gestureRecognizerEvents) {
        _gestureRecognizerEvents = [NSArray new];
    }
    return _gestureRecognizerEvents;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; start: %@; end: %@; tracks count: %@; gesture recognizer events count: %@>",
            self.class.description,
            self,
            self.startDate,
            self.endDate,
            @(self.tracks.count),
            @(self.gestureRecognizerEvents.count)];
}

@end
