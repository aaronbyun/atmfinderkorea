//
//  NearbyDetailViewController.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 5..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyDetailViewController.h"
#import "NearbyDetailInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAP_VIEW 0
#define SATELLITE_VIEW 1
#define HYBRID_VIEW  2

#define PIN

@implementation NearbyDetailViewController

@synthesize mapView;
@synthesize toolBar;
@synthesize curLoc;
@synthesize distance;
@synthesize seg;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord AndCode:(int)code AndType:(int)type AndDetailAddress:(NSString*)address AndTime:(NSString*)time
{
	self = [super init];
	
	if(self != nil)
	{
		coordinate = coord;
		imageAnnotation = [[ImageAnnotation alloc] init];
		imageAnnotation.latitude = coordinate.latitude;
		imageAnnotation.longitude = coordinate.longitude;
		imageAnnotation.bankCode = code;
		imageAnnotation.type = type;
		imageAnnotation.detailAddress = address;
		imageAnnotation.availableTime = time;
		//imageAnnotation.detailAddress = [NSString stringWithFormat:@"Test\\n 1234"];
	}
	
	return self;
}

- (void) viewWillAppear:(BOOL)animated
{
	CLLocationCoordinate2D center;
	center.latitude = (curLoc.coordinate.latitude + coordinate.latitude) / 2.0;
	center.longitude = (curLoc.coordinate.longitude + coordinate.longitude) / 2.0;
	
	self.toolBar.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];
	seg.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];

	
	curAnnotation = [[ImageAnnotation alloc] init];
	curAnnotation.latitude = curLoc.coordinate.latitude;
	curAnnotation.longitude = curLoc.coordinate.longitude;
	curAnnotation.type = -1;
	curAnnotation.detailAddress = [NSString stringWithFormat:@"GPS 정확도 : %0.0fm", curLoc.horizontalAccuracy];

	mapView.layer.cornerRadius = 20;
	mapView.delegate = self;
	mapView.centerCoordinate = center;
	//mapView.showsUserLocation = YES;
	
	MKCoordinateSpan span;
	
	double spanVal = distance / 111000.0;
	
	//NSLog(@"span value is %f", spanVal);
	
	span.latitudeDelta = spanVal;
	span.longitudeDelta = spanVal;
	MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
	
	[mapView setRegion:region animated:YES];
	
	self.navigationItem.title = NSLocalizedString(@"Map Info.", @"DETAIL_NEAR_TITLE");
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = YES;
}

- (void) viewDidLoad // make annotation views here.
{
}
 
- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	mapView = nil;
	toolBar = nil;
}

- (void)dealloc 
{
	[imageAnnotation release];
	[curAnnotation release];
	[toolBar release];
	[mapView release];
	[curLoc release];
	[seg release];
    [super dealloc];
}

#pragma mark -
#pragma mark MapViewDelegate Method

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	//NSString* errorDescription = [error localizedDescription];
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
#if 0	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"DETAIL_NEAR_MAP_ERROR") message:NSLocalizedString(errorDescription , @"DETAIL_NEAR_MAP_MESSAGE") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"DETAIL_NEAR_MAP_CANCEL") otherButtonTitles:nil];
	
	[alert show];
	[alert release];
#endif
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = YES;
}

- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated
{
#ifdef 	REFERENCE
    NSArray *oldAnnotations = mapView.annotations;
    [mapView removeAnnotations:oldAnnotations];
	
    NSArray *weatherItems = [weatherServer weatherItemsForMapRegion:mapView.region maximumCount:4];
    [mapView addAnnotations:weatherItems];
#else 
#endif

	
//	[mapView addAnnotation:imageAnnotation];
	//[mapView addAnnotation:curAnnotation];
	NSArray* array = [NSArray arrayWithObjects:imageAnnotation, curAnnotation, nil];
	[mapView addAnnotations:array];

	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
	
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
#ifdef PIN	
	
	ImageAnnotation* anno = (ImageAnnotation*)annotation;
	if(anno.type != -2)
	{
		static NSString* identifier = @"imageAnnotationView";
		
		ImageAnnotationView* annotationView = (ImageAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(annotationView == nil)
		{
			annotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		
		annotationView.annotation = annotation;
		//annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		//if(anno.type == -1) annotationView.rightCalloutAccessoryView = nil;
		
		return annotationView;
	}
	
	static NSString* identifier = @"pinAnnotationView";
	
	MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if(annotationView == nil)
	{
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
	}
	
	annotationView.pinColor = MKPinAnnotationColorGreen;
	annotationView.canShowCallout = YES;
	annotationView.animatesDrop = YES;
	annotationView.annotation = annotation;
	
	return annotationView;
	
#else

	
#endif
}

- (void) mapView:(MKMapView*) mapView annotationView:(MKAnnotationView*)view calloutAccessoryControlTapped:(UIControl*)control
{
	NearbyDetailInfoViewController* detailInfoController = [[NearbyDetailInfoViewController alloc] init];
	[self.navigationController pushViewController:detailInfoController animated:YES];
	
	[detailInfoController release];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark Action Method

- (IBAction) segControlSelectedChange:(id)sender
{
	UISegmentedControl* control = (UISegmentedControl*)sender;
	
	int index = control.selectedSegmentIndex;
	
	if(index == MAP_VIEW)
	{
		mapView.mapType = MKMapTypeStandard;
	}
	else if(index == SATELLITE_VIEW)
	{
		mapView.mapType = MKMapTypeSatellite;
	}
	else if(index == HYBRID_VIEW)
	{
		mapView.mapType = MKMapTypeHybrid;
	}
	else 
	{
		NSLog(@"Not supported view type");
	}
}

@end
