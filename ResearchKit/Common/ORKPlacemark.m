//
//  ORKPlacemark.m
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/12/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import "ORKPlacemark.h"

@implementation ORKPlacemark

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate addressDictionary:(NSDictionary<NSString *,id> *)addressDictionary {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        return nil;
    }
    self = [super initWithCoordinate:coordinate addressDictionary:addressDictionary];
    return self;
}

- (instancetype)initWithPlacemark:(CLPlacemark *)placemark {
    if (!CLLocationCoordinate2DIsValid(placemark.location.coordinate)) {
        return nil;
    }
    self = [super initWithPlacemark:placemark];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!CLLocationCoordinate2DIsValid(self.location.coordinate)) {
        return nil;
    }
    return self;
}

@end
