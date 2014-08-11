//
//  NearbyDetailInfoViewController.h
//  ATM Korea
//
//  Created by Young Byun on 10. 5. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NearbyDetailInfoViewController : UIViewController 
{
	UITableView* _tableView;
}

@property (nonatomic, retain) IBOutlet UITableView* _tableView;

@end
