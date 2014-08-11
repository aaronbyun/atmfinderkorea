//
//  LocationManager.h
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppConstant.h"

@class LocationManager;

@protocol LocationManagerDelegate <NSObject>

- (void) locationManager:(LocationManager*) locManager didSuccessfullyFinishWithCLLocation:(CLLocation*)location AndAddress:(MKPlacemark*)address;
- (void) locationManager:(LocationManager*) locManager didFailToGetGeoData:(LOCATIONERROR)error;
- (void) locationManager:(LocationManager*) locManager didSuccessfullyGetGeoData:(CLLocation*)location;

@end


@interface LocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate>
{
	id <LocationManagerDelegate> delegate;
	CLLocationManager* manager;
	CLLocation* bestLocation;
	MKReverseGeocoder* reverseGeocoder;
	
	NSMutableArray* locationMeasurements;
	
}

@property (nonatomic, assign) id <LocationManagerDelegate> delegate;
@property (nonatomic, retain) CLLocationManager* manager;
@property (nonatomic, retain) CLLocation* bestLocation;
@property (nonatomic, retain) MKReverseGeocoder* reverseGeocoder;
@property (nonatomic, retain) NSMutableArray* locationMeasurements;

- (void) start;
- (void) stop;

- (NSString*) convertMKPlacemarkToString:(MKPlacemark*)placemark;

@end
