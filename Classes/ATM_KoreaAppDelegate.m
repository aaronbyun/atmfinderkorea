//
//  ATM_KoreaAppDelegate.m
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ATM_KoreaAppDelegate.h"

@implementation ATM_KoreaAppDelegate

@synthesize window;
@synthesize mainTabbar;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
    // Override point for customization after application launch
	//[self showSplash];
	
	[window addSubview:mainTabbar.view];
	[window makeKeyAndVisible];
	[self startAnimation];	

}


- (void)dealloc 
{
	[mainTabbar release];
    [window release];
    [super dealloc];
}

- (void) startAnimation
{
	splashView = [[UIImageView alloc] initWithFrame:CGRectMake(-1,20, 321, 460)];  
	splashView.image = [UIImage imageNamed:@"Default.png"];  
	[window addSubview:splashView];  
	[window bringSubviewToFront:splashView];  
	[UIView beginAnimations:nil context:nil];  
	[UIView setAnimationDuration:1.5];  
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];  
	[UIView setAnimationDelegate:self];   
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];  
	splashView.alpha = 0.0;  
	//splashView.frame = CGRectMake(-60, -85, 440, 635);  
	[UIView commitAnimations]; 
}

- (void) startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{  
	[splashView removeFromSuperview];  
	[splashView release];  
}  

@end
