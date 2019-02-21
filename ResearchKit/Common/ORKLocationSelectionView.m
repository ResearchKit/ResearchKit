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


#import "ORKLocationSelectionView.h"

#import "ORKAnswerTextField.h"

#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionResult_Private.h"
#import "ORKResult_Private.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"

@import MapKit;


static const NSString *FormattedAddressLines = @"FormattedAddressLines";

@interface ORKLocationSelectionView () <UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSLayoutConstraint *mapViewHeightConstraint;
@property (nonatomic, strong, readwrite) ORKAnswerTextField *textField;
@property (nonatomic, strong) MKMapView *mapView;

@end


@interface CLPlacemark (ork_addressLine)

@property (nonatomic, copy, readonly) NSString* ork_addressLine;

@end


@implementation CLPlacemark (ork_addressLine)

- (NSString *)ork_addressLine {
     return [self.addressDictionary[FormattedAddressLines] componentsJoinedByString:@" "];
}

@end


@implementation ORKLocationSelectionView {
    CLLocationManager *_locationManager;
    BOOL _userLocationNeedsUpdate;
    MKCoordinateRegion _initalCoordinateRegion;
    BOOL _setInitialCoordinateRegion;
    CGFloat _mapHorizontalMargin;
    CGFloat _textFieldHorizontalMargin;
    
    UIView *_seperator1;
    UIView *_seperator2;
    UIView *_seperator3;
}

+ (CGFloat)textFieldHeight {
    return ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, nil);
}

+ (CGFloat)textFieldBottomMargin {
    static CGFloat textFieldBottomMargin = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        textFieldBottomMargin = 1.0 / [UIScreen mainScreen].scale;
    });
    return textFieldBottomMargin;
}

- (instancetype)initWithFormMode:(BOOL)formMode
              useCurrentLocation:(BOOL)useCurrentLocation
                   leadingMargin:(CGFloat)leadingMargin {
    if (NO == formMode) {
        self = [super initWithFrame:CGRectMake(0.0, 0.0, 200.0, [self.class textFieldHeight] + [ORKLocationSelectionView.class textFieldBottomMargin]*2 + ORKGetMetricForWindow(ORKScreenMetricLocationQuestionMapHeight, self.window))];
    } else {
        self = [super initWithFrame:CGRectMake(0.0, 0.0, 200.0, [self.class textFieldHeight])];
    }
    
    if (self) {
        _textField = [[ORKAnswerTextField alloc] init];
        _textField.delegate = self;
        _textField.placeholder = ORKLocalizedString(@"LOCATION_QUESTION_PLACEHOLDER",nil);
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeySearch;
        _textField.adjustsFontSizeToFitWidth = YES;
        
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;

        _useCurrentLocation = useCurrentLocation;
        _textFieldHorizontalMargin = leadingMargin;
        _mapHorizontalMargin = formMode ? leadingMargin : 0;
        
        [self addSubview:_textField];
        
        if (NO == formMode) {
            // For Question step
            _seperator1 = [[UIView alloc] init];
            _seperator1.backgroundColor = [UIColor ork_midGrayTintColor];
            _seperator2 = [[UIView alloc] init];
            _seperator2.backgroundColor = [UIColor ork_midGrayTintColor];
            _seperator3 = [[UIView alloc] init];
            _seperator3.backgroundColor = [UIColor ork_midGrayTintColor];
            [self addSubview:_seperator1];
            [self addSubview:_seperator2];
            [self addSubview:_seperator3];
        }
        
        [self setUpGestureRecognizer];
        [self setUpConstraints];

        if (NO == formMode) {
            [self showMapViewIfNecessary];
        }
        
        
    }
    
    return self;
}

- (void)setUpGestureRecognizer {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPlacemarkToMap:)];
    lpgr.minimumPressDuration = 1.0; // press for 1 second
    [_mapView addGestureRecognizer:lpgr];
}

- (void)addPlacemarkToMap:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:_mapView];
    CLLocationCoordinate2D touchMapCoordinate = [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = touchMapCoordinate;
    [_mapView addAnnotation:annotation];
    
    ORKLocation *pinLocation = [[ORKLocation alloc] initWithCoordinate:touchMapCoordinate region:nil userInput:nil addressDictionary:nil];
    [self setAnswer:pinLocation];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_textField);
    ORKEnableAutoLayoutForViews([views allValues]);
    
    NSDictionary *metrics = @{@"horizontalMargin": @(_textFieldHorizontalMargin)};
    if (_seperator1) {
        _seperator1.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *seperators = NSDictionaryOfVariableBindings(_seperator1);
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_seperator1 attribute:NSLayoutAttributeTop multiplier:1.0 constant:-1.0/[UIScreen mainScreen].scale]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_seperator1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0 / [UIScreen mainScreen].scale]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_seperator1]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:seperators]];
    }
    
    if (_seperator2) {
        _seperator2.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *seperators = NSDictionaryOfVariableBindings(_seperator2);
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_seperator2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_seperator2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0 / [UIScreen mainScreen].scale]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_seperator2]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:seperators]];
    }
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[self.class textFieldHeight]]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[_textField]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views]];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)setPlaceholderText:(NSString *)text {
    _textField.placeholder = text;
}

- (void)setTextColor:(UIColor *)color {
    _textField.textColor = color;
}

- (NSString *)enteredLocation {
    return [_textField.text copy];
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_textField isFirstResponder];
}

- (BOOL)resignFirstResponder {
    BOOL didResign = [super resignFirstResponder];
    didResign = [_textField resignFirstResponder] || didResign;
    return didResign;
}

- (CGSize)intrinsicContentSize {
    CGFloat height = [self.class textFieldHeight] + (_mapView.superview == nil ? 0.0 : [ORKLocationSelectionView.class textFieldBottomMargin]*2 + ORKGetMetricForWindow(ORKScreenMetricLocationQuestionMapHeight, self.window));
    return CGSizeMake(40, height);
}

- (void)showMapViewIfNecessary {
    if (_mapView.superview) {
        return;
    }
    
    _mapView.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, 0.0);
    ORKEnableAutoLayoutForViews(@[_mapView]);
    [self addSubview:_mapView];
    
    NSMutableArray *constraints = [NSMutableArray new];
    
    NSDictionary *metrics = @{@"horizontalMargin": @(_mapHorizontalMargin)};
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(horizontalMargin)-[_mapView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:NSDictionaryOfVariableBindings(_mapView)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeBottom multiplier:1.0 constant:[ORKLocationSelectionView.class textFieldBottomMargin]]];
    
    _mapViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ORKGetMetricForWindow(ORKScreenMetricLocationQuestionMapHeight, self.window)];
    [constraints addObject:_mapViewHeightConstraint];
    
    if (_seperator3) {
        [self bringSubviewToFront:_seperator3];
        _seperator3.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *seperators = NSDictionaryOfVariableBindings(_seperator3);
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_mapView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_seperator3 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:_seperator3 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1.0 / [UIScreen mainScreen].scale]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_seperator3]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:seperators]];
    }
    
    [NSLayoutConstraint activateConstraints:constraints];
    [self layoutIfNeeded];
    if ([_delegate respondsToSelector:@selector(locationSelectionViewNeedsResize:)]) {
        [_delegate locationSelectionViewNeedsResize:self];
    }
}

- (void)loadCurrentLocationIfNecessary {
    if (_useCurrentLocation) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            _userLocationNeedsUpdate = YES;
            _mapView.showsUserLocation = YES;
        } else {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)geocodeAndDisplay:(NSString *)string {
    
    if (string == nil || string.length == 0) {
        [self setAnswer:ORKNullAnswerValue()];
        return;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    ORKWeakTypeOf(self) weakSelf = self;
    [geocoder geocodeAddressString:string completionHandler:^(NSArray *placemarks, NSError *error) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (error) {
            [self notifyDelegateOfError:error];
            [strongSelf setAnswer:ORKNullAnswerValue()];
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            [strongSelf setAnswer:[[ORKLocation alloc] initWithPlacemark:placemark userInput:string]];
        }
    }];
}

- (void)reverseGeocodeAndDisplay:(ORKLocation *)location {
    
    if (location == nil) {
        [self setAnswer:ORKNullAnswerValue()];
        return;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    ORKWeakTypeOf(self) weakSelf = self;
    CLLocation *cllocation = [[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [geocoder reverseGeocodeLocation:cllocation completionHandler:^(NSArray *placemarks, NSError *error) {
        ORKStrongTypeOf(weakSelf) strongSelf = weakSelf;
        if (error) {
            [self notifyDelegateOfError:error];
            [strongSelf setAnswer:ORKNullAnswerValue()];
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            [strongSelf setAnswer:[[ORKLocation alloc] initWithPlacemark:placemark
                                                               userInput:location.userInput ? : placemark.ork_addressLine]
                        updateMap:YES];
        }
    }];
}

- (void)setAnswer:(ORKLocation *)answer {
    [self setAnswer:answer updateMap:YES];
}

- (void)setAnswer:(ORKLocation *)answer updateMap:(BOOL)updateMap {
    
    BOOL isAnswerClassORKLocation = [[answer class] isSubclassOfClass:[ORKLocation class]];
    _answer = (isAnswerClassORKLocation || answer == ORKNullAnswerValue()) ? answer : nil;
    
    if (_answer) {
        _userLocationNeedsUpdate = NO;
    } else {
         [self loadCurrentLocationIfNecessary];
    }
    
    ORKLocation *location = isAnswerClassORKLocation ? (ORKLocation *)_answer : nil;
    
    if (location) {
        
        if (!location.userInput || !location.region |!location.addressDictionary) {
            // redo geo decoding if any of them is missing
            [self reverseGeocodeAndDisplay:location];
            return;
        }
        
        if (location.userInput) {
            _textField.text = location.userInput;
        }
    }
    
    if (updateMap) {
        [self updateMapWithLocation:location];
    }
    
    if ([_delegate respondsToSelector:@selector(locationSelectionViewDidChange:)]) {
        [_delegate locationSelectionViewDidChange:self];
    }
}

- (void)updateMapWithLocation:(ORKLocation *)location {
    
    MKPlacemark *placemark = location ? [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:location.addressDictionary] : nil;
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    if (placemark) {
        [_mapView addAnnotation:placemark];
        CLLocationDistance span = MAX(200, location.region.radius);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.region.center, span, span);
        [self setMapRegion:region];
    } else {
        if (_setInitialCoordinateRegion) {
            [self setMapRegion:_initalCoordinateRegion];
        }
    }
}

- (void)setMapRegion:(MKCoordinateRegion)region {
    if (!_setInitialCoordinateRegion) {
        _setInitialCoordinateRegion = YES;
        _initalCoordinateRegion = _mapView.region;
    }
    [_mapView setRegion:region animated:YES];
}

- (void)notifyDelegateOfError:(NSError *)error {
    NSString *title = ORKLocalizedString(@"LOCATION_ERROR_TITLE", @"");
    NSString *message = nil;
    
    switch (error.code) {
        case kCLErrorLocationUnknown:
        case kCLErrorHeadingFailure:
            message = ORKLocalizedString(@"LOCATION_ERROR_MESSAGE_LOCATION_UNKNOWN", @"");
            break;
        case kCLErrorDenied:
        case kCLErrorRegionMonitoringDenied:
            message = ORKLocalizedString(@"LOCATION_ERROR_MESSAGE_DENIED", @"");
            break;
        case kCLErrorNetwork:
            message = ORKLocalizedString(@"LOCATION_ERROR_GEOCODE_NETWORK", @"");
            break;
        case kCLErrorGeocodeFoundNoResult:
        case kCLErrorGeocodeFoundPartialResult:
        case kCLErrorGeocodeCanceled:
            message = ORKLocalizedString(@"LOCATION_ERROR_GEOCODE", @"");
            break;
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(locationSelectionView:didFailWithErrorTitle:message:)] && message != nil) {
        [_delegate locationSelectionView:self didFailWithErrorTitle:title message:message];
    }
}

# pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self loadCurrentLocationIfNecessary];
    }
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_userLocationNeedsUpdate) {
        [self reverseGeocodeAndDisplay:[[ORKLocation alloc] initWithCoordinate:userLocation.location.coordinate
                                                                        region:nil
                                                                     userInput:nil
                                                             addressDictionary:@{}]];
        _userLocationNeedsUpdate = NO;
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    // Be quiet if map cannot find user current location
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(locationSelectionViewDidBeginEditing:)]) {
        [_delegate locationSelectionViewDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self geocodeAndDisplay:textField.text];
    if ([_delegate respondsToSelector:@selector(locationSelectionViewDidEndEditing:)]) {
        [_delegate locationSelectionViewDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Clear answer to prevent user continue with invalid answer.
    if ( NO == ORKIsAnswerEmpty(_answer) ) {
        [self setAnswer:ORKNullAnswerValue() updateMap:NO];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self geocodeAndDisplay:textField.text];
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [_mapView setRegion:_initalCoordinateRegion animated:YES];
    [self setAnswer:ORKNullAnswerValue()];
    return YES;
}

@end
