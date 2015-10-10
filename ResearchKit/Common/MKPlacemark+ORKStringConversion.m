/*
 Copyright (c) 2015, Alejandro Martinez, Quintiles Inc.
 Copyright (c) 2015, Brian Kelly, Quintiles Inc.
 Copyright (c) 2015, Bryan Strothmann, Quintiles Inc.
 Copyright (c) 2015, Greg Yip, Quintiles Inc.
 Copyright (c) 2015, John Reites, Quintiles Inc.
 Copyright (c) 2015, Pavel Kanzelsberger, Quintiles Inc.
 Copyright (c) 2015, Richard Thomas, Quintiles Inc.
 Copyright (c) 2015, Shelby Brooks, Quintiles Inc.
 Copyright (c) 2015, Steve Cadwallader, Quintiles Inc.
 
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


#import "MKPlacemark+ORKStringConversion.h"
#import "CLLocation+ORKJSONDictionary.h"


static NSString *const LocationKey = @"location";
static NSString *const LatitudeKey = @"latitude";
static NSString *const LongitudeKey = @"longitude";
static NSString *const AddressDictionaryKey = @"addressDictionary";

@implementation MKPlacemark (ORKStringConversion)

- (NSDictionary *)ork_JSONDictionary {
    return @{
             LocationKey: @{
                     LatitudeKey: [NSDecimalNumber numberWithDouble:self.location.coordinate.latitude],
                     LongitudeKey: [NSDecimalNumber numberWithDouble:self.location.coordinate.longitude]
                     },
             AddressDictionaryKey: self.addressDictionary ? : [NSNull null]
             };
}

- (NSString *)ork_JSONStringValue {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self ork_JSONDictionary] options:0 error:&error];
    
    if (!jsonData) {
        NSLog(@"Unable to convert MKPlacemark to JSON string: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (instancetype)ork_placemarkWithJSONDictionary:(NSDictionary *)dictionary {
    CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
    NSDictionary *addressDictionary = nil;
    if (dictionary[LocationKey] && [[dictionary[LocationKey] class] isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *locationDictionary = dictionary[LocationKey];
        if (locationDictionary[LatitudeKey] && locationDictionary[LongitudeKey] && [[locationDictionary[LatitudeKey] class] isSubclassOfClass:[NSNumber class]] && [[locationDictionary[LongitudeKey] class] isSubclassOfClass:[NSNumber class]]) {
            location = CLLocationCoordinate2DMake(((NSNumber *)locationDictionary[LatitudeKey]).doubleValue, ((NSNumber *)locationDictionary[LongitudeKey]).doubleValue);
        }
    }
    if (dictionary[AddressDictionaryKey] && [[dictionary[AddressDictionaryKey] class] isSubclassOfClass:[NSDictionary class]]) {
        addressDictionary = dictionary[AddressDictionaryKey];
    }

    return [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:addressDictionary];
}

+ (instancetype)ork_placemarkWithJSONString:(NSString *)string {
    NSError *error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (!jsonDictionary) {
        NSLog(@"Unable to convert JSON string to MKPlacemark: %@", error.localizedDescription);
        return nil;
    } else {
        return [MKPlacemark ork_placemarkWithJSONDictionary:jsonDictionary];
    }
}

@end
