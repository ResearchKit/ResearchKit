//
//  MKPlacemark+ORKStringConversion.h
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/6/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPlacemark (ORKStringConversion)

- (NSString *)ork_stringValue;

+ (instancetype)ork_placemarkWithString:(NSString *)string;

@end
