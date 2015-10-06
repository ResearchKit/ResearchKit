//
//  MKPlacemark+ORKStringConversion.m
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/6/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "MKPlacemark+ORKStringConversion.h"
#import "CLLocation+ORKJSONDictionary.h"

@implementation MKPlacemark (ORKStringConversion)

- (NSDictionary *)ork_JSONDictionary {
    return @{
             @"location": @{
                     @"latitude": [NSDecimalNumber numberWithDouble:self.location.coordinate.latitude],
                     @"longitude": [NSDecimalNumber numberWithDouble:self.location.coordinate.longitude]
                     },
             @"addressDictionary": self.addressDictionary
             };
}

- (NSString *)ork_stringValue {
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
    if (dictionary[@"location"] && [[dictionary[@"location"] class] isSubclassOfClass:[NSDictionary class]]) {
        NSDictionary *locationDictionary = dictionary[@"location"];
        if (locationDictionary[@"latitude"] && locationDictionary[@"longitude"] && [[locationDictionary[@"latitude"] class] isSubclassOfClass:[NSNumber class]] && [[locationDictionary[@"longitude"] class] isSubclassOfClass:[NSNumber class]]) {
            location = CLLocationCoordinate2DMake(((NSNumber *)locationDictionary[@"latitude"]).doubleValue, ((NSNumber *)locationDictionary[@"longitude"]).doubleValue);
        }
    }
    if (dictionary[@"addressDictionary"] && [[dictionary[@"addressDictionary"] class] isSubclassOfClass:[NSDictionary class]]) {
        addressDictionary = dictionary[@"addressDictionary"];
    }

    return [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:addressDictionary];
}

+ (instancetype)ork_placemarkWithString:(NSString *)string {
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
