//
//  AboutRootViewController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView* tableView;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

@end
