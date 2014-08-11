//
//  LocationManager.m
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

#define TEST
#undef TEST

#define ACCURACY_VALUE  1000

static int count = 0;
static NSDate* countoneDate;

@implementation LocationManager

@synthesize delegate;
@synthesize manager;
@synthesize bestLocation;
@synthesize reverseGeocoder;
@synthesize locationMeasurements;

- (id) init
{
	self = [super init];
	if(self != nil)
	{
		manager = [[CLLocationManager alloc] init];
		if(manager.locationServicesEnabled == NO)
		{
			//UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"LOCATION_TITLE") message:NSLocalizedString(@"Please check your LBS service state.", @"LOCATION_MESSAGE") 
														   //delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", @"LOCATION_CANCEL") otherButtonTitles:nil];
			//[alert show];
			//[alert release];
			manager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyBest;// kCLLocationAccuracyNearestTenMeters;//kCLLocationAccuracyHundredMeters; // kCLLocationAccuracyKilometer;//kCLLocationAccuracyHundredMeters;//kCLLocationAccuracyBest;
			manager.distanceFilter = kCLDistanceFilterNone;
			manager.delegate = self;
		
			[self start];
			
			return nil;
		}
		
		self.locationMeasurements = [NSMutableArray array];
		
		manager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyBest;// kCLLocationAccuracyNearestTenMeters;//kCLLocationAccuracyHundredMeters; // kCLLocationAccuracyKilometer;//kCLLocationAccuracyHundredMeters;//kCLLocationAccuracyBest;
		manager.distanceFilter = kCLDistanceFilterNone;
		manager.delegate = self;
		[self start];
	}
	
	return self;
}

- (void) start
{
	manager.delegate = self;
	[manager startUpdatingLocation];
}

- (void) stop
{
	[manager stopUpdatingLocation];
	manager.delegate = nil;
}

- (void)dealloc
{
	[manager release];
	[bestLocation release];
	[reverseGeocoder release];
	[locationMeasurements release];
	[super dealloc];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Method

- (void) locationManager:(CLLocationManager *)locManager didFailWithError:(NSError *)error
{
/*	kCLErrorLocationUnknown  = 0,   // location is currently unknown, but CL will keep trying
	kCLErrorDenied,                 // CL access has been denied (eg, user declined location use)
	kCLErrorNetwork,                // general, network-related error
	kCLErrorHeadingFailure
 */
	NSInteger code = [error code];
	
	if(code == kCLErrorLocationUnknown) 
	{
		NSLog(@"Unkown Error");
	}
	else if(code == kCLErrorDenied)
	{
		NSLog(@"Denied Error");
		[self stop];
		//- (void) locationManager:(LocationManager*) locManager didFailToGetGeoData:(LOCATIONERROR)error;
		if( [delegate respondsToSelector:@selector(locationManager:didFailToGetGeoData:)] )
		{
			[delegate locationManager:self didFailToGetGeoData:kCLErrorDenied];
		}
		
	}
	else if(code == kCLErrorNetwork)
	{
		NSLog(@"Network Error");
		[self stop];
	}
	else 
	{
		[self stop];
	}
}

- (void) locationManager:(CLLocationManager *)locManager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation
{
	[locationMeasurements addObject:newLocation];
	
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	count++;
	
	if(count == 1) countoneDate = [newLocation.timestamp retain];
	
	bool locationChanged;
	
	if((newLocation.coordinate.latitude != oldLocation.coordinate.latitude) && (newLocation.coordinate.longitude != oldLocation.coordinate.longitude))
		locationChanged = YES;
	else
		locationChanged = NO;
		
	if(locationAge > 5.0) 
	{
		manager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	
	//NSString* debugStr = [NSString stringWithFormat:@"%f  %f  %f   %d  %d", locationAge, newLocation.horizontalAccuracy, oldLocation.horizontalAccuracy, count, locationChanged];
	//NSLog(@"locationAge : %f   newLocation Horizontal : %f   oldLocation Horizontal : %f   count : %d   locationChanged : %d", locationAge, newLocation.horizontalAccuracy, oldLocation.horizontalAccuracy, count, locationChanged);
	if( (locationAge < 5.6) && ( (newLocation.horizontalAccuracy < (oldLocation.horizontalAccuracy - 10) ) || (newLocation.horizontalAccuracy <= 166.0) 
								|| ((count >= 3) && (count <= 5)  &&  (newLocation.horizontalAccuracy <= 166.0) && locationChanged )))
	{
		[self stop];
		count = 0;
		[countoneDate release];
		countoneDate = nil;
		[bestLocation release];
		bestLocation = [newLocation retain];

		if( [delegate respondsToSelector:@selector(locationManager:didSuccessfullyFinishWithCLLocation:AndAddress:)] )
		{
			[delegate locationManager:self didSuccessfullyFinishWithCLLocation:bestLocation AndAddress:nil];
		}
	}
	else 
	{
		manager.desiredAccuracy = kCLLocationAccuracyBest;
		NSDate* current = [NSDate date];
		NSTimeInterval value =  [current timeIntervalSinceDate:countoneDate];
		//NSLog(@"time interval value : %f", value);
		if(value >= 6.0)
		{
			[self stop];
			count = 0;
			[countoneDate release];
			countoneDate = nil;
			[bestLocation release];
			bestLocation = [newLocation retain];
			
			if( [delegate respondsToSelector:@selector(locationManager:didSuccessfullyFinishWithCLLocation:AndAddress:)] )
			{
				[delegate locationManager:self didSuccessfullyFinishWithCLLocation:bestLocation AndAddress:nil];
			}			
		}
	}
}

#pragma mark -
#pragma mark reverseGeocoder delegate

- (void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if( [delegate respondsToSelector:@selector(locationManager:didFailWithError:)] )
	{
		[delegate locationManager:self didFailToGetGeoData:ERRORCANTTRANSLATETOADDRESS];
	}
}

- (void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	// location 정보를 주소 정보로 변환에 성공 하였다. 
	NSLog(@"Country %@", placemark.country);
	NSLog(@"Country  Code %@", placemark.countryCode);
	NSLog(@"State %@", placemark.administrativeArea);
	NSLog(@"Sub State %@", placemark.subAdministrativeArea);
	NSLog(@"City  %@", placemark.locality);
	NSLog(@"Sub City %@", placemark.subLocality);
	NSLog(@"Street %@", placemark.thoroughfare);
	NSLog(@"Sub Street %@", placemark.subThoroughfare);
	NSLog(@"Zip code %@", placemark.postalCode);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if( [delegate respondsToSelector:@selector(locationManager:didSuccessfullyFinishWithCLLocation:AndAddress:)] )
	{
		[delegate locationManager:self didSuccessfullyFinishWithCLLocation:bestLocation AndAddress:placemark];
	}
}

- (NSString*) convertMKPlacemarkToString:(MKPlacemark*)placemark
{
	NSMutableString* address = [[NSMutableString alloc] init];
	NSString* state = placemark.administrativeArea;
	NSString* city = placemark.locality;
	NSString* subCity = placemark.subLocality;
	NSString* street = placemark.thoroughfare;
	
	if(address == nil) return @"";
	
	[address appendString:NSLocalizedString(@"Current position : ", @"LOCATIONMANAGER_CURRENT_POSITION")];
	
	if(state != nil)
	{
		[address appendString:state];
		[address appendString:@" "];
	}
	if(city != nil)
	{
		[address appendString:city];
		[address appendString:@" "];
	}
	if(subCity != nil)
	{
		[address appendString:subCity];
		[address appendString:@" "];
	}
	if(street != nil)
	{
		[address appendString:street];
	}
	
	return address;
}

@end
