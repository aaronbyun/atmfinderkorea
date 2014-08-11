//
//  NearbyDetailViewController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ImageAnnotation.h"
#import "ImageAnnotationView.h"

@interface NearbyDetailViewController : UIViewController <MKMapViewDelegate> 
{
	MKMapView* mapView;
	CLLocationCoordinate2D coordinate;
	
	UIToolbar* toolBar;
	UISegmentedControl* seg;
	
	ImageAnnotation* imageAnnotation;
	ImageAnnotation* curAnnotation;
	CLLocation* curLoc;
	
	double distance;
}

@property (nonatomic, retain) IBOutlet MKMapView* mapView;
@property (nonatomic, retain) IBOutlet UIToolbar* toolBar;

@property (nonatomic, retain) IBOutlet UISegmentedControl* seg;
@property (nonatomic, retain) CLLocation* curLoc;

@property (assign) double distance;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord AndCode:(int)code AndType:(int)type AndDetailAddress:(NSString*)address AndTime:(NSString*)time;

- (IBAction) segControlSelectedChange:(id)sender;

@end
