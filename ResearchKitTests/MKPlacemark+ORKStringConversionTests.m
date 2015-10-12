//
//  MKPlacemark+ORKStringConversionTests.m
//  ResearchKit
//
//  Created by Brandon McQuilkin on 10/12/15.
//  Copyright © 2015 researchkit.org. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ResearchKit/ResearchKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MKPlacemark+ORKStringConversion.h"
#import "ORKHelpers.h"


static BOOL ork_doubleEqual(double x, double y) {
    static double K = 1;
    return (fabs(x-y) < K * DBL_EPSILON * fabs(x+y) || fabs(x-y) < DBL_MIN);
}

#pragma mark - MKPlacemark+ORKStringConversionTests
#pragma mark -

@interface MKPlacemarkORKStringConversionTests : XCTestCase

@end


@implementation MKPlacemarkORKStringConversionTests {
    
}

- (void)testPlacemarkDictionarySerialization {
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(10.235, -3.294)
                                                   addressDictionary:@{
                                                                       @"City": @"Cincinnati",
                                                                       @"Country": @"United States",
                                                                       @"CountryCode": @"US",
                                                                       @"FormattedAddressLines": @[
                                                                               @"7753 Montgomery Rd",
                                                                               @"Cincinnati, OH  45236",
                                                                               @"United States"
                                                                               ],
                                                                       @"Name": @"7753 Montgomery Rd",
                                                                       @"PostCodeExtension": @(4201),
                                                                       @"State": @"OH",
                                                                       @"Street": @"7753 Montgomery Rd",
                                                                       @"SubAdministrativeArea": @"Hamilton",
                                                                       @"SubThoroughfare": @(7753),
                                                                       @"Thoroughfare": @"Montgomery Rd",
                                                                       @"ZIP": @(45236)
                                                                       }];
    
    
    NSDictionary *placemarkDictionary = [placemark ork_JSONDictionary];
    XCTAssertNotNil(placemarkDictionary, @"");
    XCTAssertEqualObjects(placemark.addressDictionary, placemarkDictionary[@"addressDictionary"], @"");
    NSDictionary *locationDictionary = placemarkDictionary[@"location"];
    XCTAssertNotNil(locationDictionary, @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.latitude, ((NSNumber *)locationDictionary[@"latitude"]).doubleValue), @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.longitude, ((NSNumber *)locationDictionary[@"longitude"]).doubleValue), @"");
    
    MKPlacemark *reserializedPlacemark = [MKPlacemark ork_placemarkWithJSONDictionary:placemarkDictionary];
    XCTAssertNotNil(reserializedPlacemark, @"");
    XCTAssertEqualObjects(placemark.addressDictionary, reserializedPlacemark.addressDictionary, @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.latitude, reserializedPlacemark.location.coordinate.latitude), @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.longitude, reserializedPlacemark.location.coordinate.longitude), @"");
}

- (void)testPlacemarkStringSerialization {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(10.235, -3.294)
                                                   addressDictionary:@{
                                                                       @"City": @"Cincinnati",
                                                                       @"Country": @"United States",
                                                                       @"CountryCode": @"US",
                                                                       @"FormattedAddressLines": @[
                                                                               @"7753 Montgomery Rd",
                                                                               @"Cincinnati, OH  45236",
                                                                               @"United States"
                                                                               ],
                                                                       @"Name": @"7753 Montgomery Rd",
                                                                       @"PostCodeExtension": @(4201),
                                                                       @"State": @"OH",
                                                                       @"Street": @"7753 Montgomery Rd",
                                                                       @"SubAdministrativeArea": @"Hamilton",
                                                                       @"SubThoroughfare": @(7753),
                                                                       @"Thoroughfare": @"Montgomery Rd",
                                                                       @"ZIP": @(45236)
                                                                       }];
    
    NSString *placemarkString = [placemark ork_JSONStringValue];
    XCTAssertNotNil(placemarkString, @"");
    
    MKPlacemark *reserializedPlacemark = [MKPlacemark ork_placemarkWithJSONString:placemarkString];
    XCTAssertNotNil(reserializedPlacemark, @"");
    XCTAssertEqualObjects(placemark.addressDictionary, reserializedPlacemark.addressDictionary, @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.latitude, reserializedPlacemark.location.coordinate.latitude), @"");
    XCTAssertTrue(ork_doubleEqual(placemark.location.coordinate.longitude, reserializedPlacemark.location.coordinate.longitude), @"");
}

@end
