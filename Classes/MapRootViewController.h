//
//  MapRootViewController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LocationManager.h"
#import "DatabaseManager.h"
 
@interface MapRootViewController : UIViewController <MKMapViewDelegate, LocationManagerDelegate>
{
	UINavigationBar* naviBar;
	MKMapView* atmMapView;
	
	LocationManager* locationManager;
	DatabaseManager* dataManager;
	
	NSMutableArray* annotationsArray;
	
	UIActivityIndicatorView* activityIndicatorView;
	
	CLLocation* curLocation;
}

@property (nonatomic, retain) IBOutlet 	UINavigationBar* naviBar;
@property (nonatomic, retain) IBOutlet	MKMapView* atmMapView;
@property (nonatomic, retain) LocationManager* locationManager;

@property (nonatomic, retain) NSMutableArray* annotationsArray;
@property (nonatomic, retain) DatabaseManager* dataManager;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicatorView;

- (IBAction) showCurrentLocation;

@end
