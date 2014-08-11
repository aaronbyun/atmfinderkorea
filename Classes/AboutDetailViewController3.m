//
//  AboutDetailViewController3.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutDetailViewController3.h"


@implementation AboutDetailViewController3

@synthesize webView;
@synthesize url, banktitle;

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
	
	webView.delegate = self;
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	[webView loadRequest:request];
	
	self.navigationItem.title = banktitle;
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(148, 200, 25, 25)];
	activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	
	[self.view addSubview:activityIndicatorView];
	[activityIndicatorView startAnimating];
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = YES;
//	[activityIndicatorView release];
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
	webView = nil;
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}


- (void)dealloc 
{
	[webView release];
	[url release];
	[banktitle release];
	[activityIndicatorView release];
    [super dealloc];
}

#pragma mark -
#pragma mark webView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[activityIndicatorView stopAnimating];
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{	

}


@end
