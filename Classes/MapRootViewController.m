//
//  MapRootViewController.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 17..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapRootViewController.h"
#import "ImageAnnotation.h"
#import "ImageAnnotationView.h"
#import "ATM_Info.h"

@implementation MapRootViewController

@synthesize naviBar;
@synthesize atmMapView;
@synthesize locationManager;
@synthesize annotationsArray;
@synthesize dataManager;
@synthesize activityIndicatorView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.atmMapView.delegate = self;
	//self.atmMapView.showsUserLocation = YES;
	
	naviBar.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];
	
	CLLocationCoordinate2D coord;
	coord.latitude = 37.52345;
	coord.longitude = 126.9245;

	MKCoordinateSpan span;
	span.latitudeDelta = 0.01;
	span.latitudeDelta = 0.01;
//	MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);
//	[self.atmMapView setRegion:region animated:YES];
	
	locationManager = [[LocationManager alloc] init];
	locationManager.delegate = self;
	
	annotationsArray = [[NSMutableArray alloc] init];
	dataManager = [[DatabaseManager alloc] init];
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142, 222, 35, 35)];
	activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	
	[self.view addSubview:activityIndicatorView];
	[activityIndicatorView startAnimating];
	
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
}


- (void)dealloc 
{
	[naviBar release];
	[atmMapView release];
	[locationManager release];
	[annotationsArray release];
	[dataManager release];
	[activityIndicatorView release];
	[curLocation release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom Method

- (IBAction) showCurrentLocation
{
	//[annotationsArray removeAllObjects];
	[atmMapView removeAnnotations:annotationsArray];
	[activityIndicatorView startAnimating];
	locationManager.delegate = self;
	[locationManager start];
}

#pragma mark -
#pragma mark LocationManagerDelegate Method

- (void) locationManager:(LocationManager*) locManager didFailToGetGeoData:(LOCATIONERROR)error
{
	
	if(error == kCLErrorDenied)
	{
		self.navigationItem.prompt = nil;
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"LOCATION_TITLE") message:NSLocalizedString(@"Location service was denied.", @"ROOT_NEAR_PROMPT_DENIED") 
													   delegate:self cancelButtonTitle:NSLocalizedString(@"Confirm", @"LOCATION_CANCEL") otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[activityIndicatorView stopAnimating];
}

- (void) locationManager:(LocationManager*) locManager didSuccessfullyGetGeoData:(CLLocation*)location
{	

}

- (void) locationManager:(LocationManager*) locManager didSuccessfullyFinishWithCLLocation:(CLLocation*)location AndAddress:(MKPlacemark*)address
{	
	[locationManager stop];
	locationManager.delegate = nil;
	
	CLLocationCoordinate2D coordinate = location.coordinate;
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0008;
	span.longitudeDelta = 0.0008;
	
	NSLog(@"location information : %f, %f", coordinate.latitude, coordinate.longitude);
	
	MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
	[self.atmMapView setRegion:region animated:YES];	
	
	[activityIndicatorView stopAnimating];
	
	curLocation = location;
	//37.566535
	//126.9779692
}

#pragma mark -
#pragma mark MapViewDelegate Method

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	//[activityIndicatorView startAnimating];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	//[activityIndicatorView stopAnimating];
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// 바뀔때마다 annotation 들을 새로 추가 한다. 
	// Database Manager 가 data를 긁어 옴.
	//[mapView removeAnnotations:annotationsArray];
	
	MKCoordinateRegion region = mapView.region;
	
	NSLog(@"map view region changed : %f  %f  %f  %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
		
	[annotationsArray removeAllObjects];
	
	NSMutableArray* atmInfoArray = [dataManager getDataV2:region];
	if(atmInfoArray == nil) return ;
	
	int i, count = [atmInfoArray count]; 
	for(i = 0; i < count; i++)
	{
		
		ATM_Info* info = (ATM_Info*)[atmInfoArray objectAtIndex:i];
		
		ImageAnnotation* imageAnnotation;
		
		imageAnnotation = [[ImageAnnotation alloc] init];
		imageAnnotation.latitude = info.latitude;
		imageAnnotation.longitude = info.longitude;
		imageAnnotation.bankCode = info._bankCode;
		imageAnnotation.type = info._type;
		imageAnnotation.detailAddress = [NSString stringWithFormat:@"%@ %@", info.addressCity, info.addressDetail]; 		
		imageAnnotation.availableTime = info.availableTime;
		
		[annotationsArray addObject:imageAnnotation];
		
		[imageAnnotation release];
	}
	
	[atmInfoArray release];
	
	ImageAnnotation* curAnnotation = [[ImageAnnotation alloc] init];
	curAnnotation.latitude = curLocation.coordinate.latitude;
	curAnnotation.longitude = curLocation.coordinate.longitude;
	curAnnotation.type = -1;
	curAnnotation.detailAddress = [NSString stringWithFormat:@"GPS 정확도 : %0.0f m", curLocation.horizontalAccuracy];
	
	[annotationsArray addObject:curAnnotation];
	[curAnnotation release];
	
	[atmMapView addAnnotations:annotationsArray];
	
	[activityIndicatorView stopAnimating];
	
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	ImageAnnotation* anno = (ImageAnnotation*)annotation;
	if(anno.type != -2)
	{
		static NSString* identifier = @"imageAnnotationView2";
		
		ImageAnnotationView* annotationView = (ImageAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(annotationView == nil)
		{
			annotationView = [[[ImageAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		
		annotationView.annotation = annotation;
		
		return annotationView;
	}	
	
	static NSString* identifier = @"imageAnnotationView2";
	
	MKPinAnnotationView* annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if(annotationView == nil)
	{
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		//annotationView.animatesDrop = YES;
	}
	
	annotationView.pinColor = MKPinAnnotationColorGreen;
	annotationView.canShowCallout = YES;
	//annotationView.animatesDrop = YES;
	annotationView.annotation = annotation;
	
	return annotationView;
}


@end
