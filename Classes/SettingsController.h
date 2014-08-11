//
//  SettingsController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define  TABLE_SECTION_CNT                  2
#define  TABLE_SECTION_BANK                0
#define  TABLE_SECTION_DISTANCE        1

@class SettingsController;

@protocol SettingViewControllerDelegate <NSObject>

- (BOOL) settingViewController:(SettingsController*)settingController didFinishWithInfo:(NSDictionary*)settings;

@end

@interface SettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	id<SettingViewControllerDelegate> delegate;
	UITableView* settingTableView;
	UINavigationBar* navigationBar;
	UIBarButtonItem* doneButton;
	
	NSMutableDictionary* settings;
}

@property (nonatomic, assign) id<SettingViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView* settingTableView;
@property (nonatomic, retain) IBOutlet UINavigationBar* navigationBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* doneButton;
@property (nonatomic, retain) NSMutableDictionary* settings;

- (void) doneButtonSelected:(id)sender;

@end
