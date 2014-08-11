//
//  ATM_KoreaAppDelegate.h
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATM_KoreaAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController* mainTabbar; 	
	UIImageView *splashView;  
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController* mainTabbar; 

- (void) startAnimation;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context; 

@end

