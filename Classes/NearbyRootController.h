//
//  NearbyRootController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import "SettingsController.h"
#import "LocationManager.h"
#import "DatabaseManager.h"
 
@interface NearbyRootController : UIViewController <UITableViewDelegate, UITableViewDataSource, SettingViewControllerDelegate, LocationManagerDelegate>
{
	NSMutableDictionary* settings;
	LocationManager* locationManager;
	DatabaseManager* databaseManager;
	
	UITableView* _tableView;
	
	NSArray* resultArray;
	
	UIView* activityIndicatorHolder;
	UIActivityIndicatorView* activityIndicatorView;
	CLLocation* curLocation;
	
	UIBarButtonItem* refreshButton;
	UIBarButtonItem* settingButton;
}

@property (nonatomic, retain) NSMutableDictionary* settings;
@property (nonatomic, retain) LocationManager* locationManager;
@property (nonatomic, retain) DatabaseManager* databaseManager;
@property (nonatomic, retain) NSArray* resultArray;

@property (nonatomic, retain) IBOutlet UITableView* _tableView;

@property (nonatomic, retain) IBOutlet UIView* activityIndicatorHolder;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicatorView;

@property (nonatomic, retain) 	CLLocation* curLocation;

- (NSString*) getSettingContentFilePath;
- (void) refreshPressed:(id)sender;
- (void) settingPressed:(id)sender;
- (BOOL) loadSettingData;
- (BOOL) writeSettingData;

- (NSInteger) getNumberOfBankSettings;
- (NSString*) getHeaderTitleForSection:(int)index;

// for test
- (void) makePromptEmpty;

@end
