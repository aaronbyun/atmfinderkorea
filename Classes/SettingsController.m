//
//  SettingsController.m
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
#import "AppConstant.h"

const NSString* BANK_LISTS [MAX_BANK_CNT] = {@"국민은행", @"기업은행", @"농협", @"신한은행", @"외환은행", @"우리은행", @"제일은행", @"하나은행"};
const NSString* DISTANCE_LISTS [MAX_DISTANCE_CNT] = {@"100m", @"200m", @"300m", @"500m", @"1km"};

@implementation SettingsController

@synthesize delegate;
@synthesize settingTableView;
@synthesize navigationBar;
@synthesize doneButton;
@synthesize settings;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self != nil)
	{
	}
	
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	navigationBar.backItem.title = NSLocalizedString(@"Setting", @"ROOT_NEAR_SETTING");
	doneButton.target = self;
	doneButton.action = @selector(doneButtonSelected:);
	doneButton.title = NSLocalizedString(@"Done", @"ROOT_NEAR_DONE");
	
	navigationBar.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];
}

- (void) doneButtonSelected:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	if( [delegate respondsToSelector:@selector(settingViewController:didFinishWithInfo:)] )
	{
		[delegate settingViewController:self didFinishWithInfo:settings];
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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
	navigationBar = nil;
	settingTableView = nil;
	settings = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return TABLE_SECTION_CNT;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if(section == TABLE_SECTION_BANK)
	{
		return MAX_BANK_CNT;
	}
	else if(section == TABLE_SECTION_DISTANCE)
	{
		return MAX_DISTANCE_CNT;
	}

	return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == TABLE_SECTION_BANK)
	{
		return NSLocalizedString(@"Bank list", @"SETTING_NEAR_BANK");
	}
	else if(section == TABLE_SECTION_DISTANCE)
	{
		return NSLocalizedString(@"Search distance", @"SETTING_NEAR_DISTANCE");
	}
	
	return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Set up the cell...
	int section = indexPath.section;
	int row = indexPath.row;
	
	if(section == TABLE_SECTION_BANK)
	{
		cell.textLabel.text = (NSString*)BANK_LISTS[row];
		
		NSMutableArray* bankArr = [settings valueForKey:BANK_KEY];
		NSNumber* value = [bankArr objectAtIndex:row];
		
		if([value intValue] == 1) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else if(section == TABLE_SECTION_DISTANCE)
	{
		NSNumber* value = (NSNumber*)[settings valueForKey:DISTANCE_KEY];
		NSInteger index = [value integerValue];
		
		cell.textLabel.text = (NSString*)DISTANCE_LISTS[row];
		if(index == row) cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else 
	{
		// nothing to do
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	int section = indexPath.section;
	int row = indexPath.row;
	
	if(section == TABLE_SECTION_BANK)
	{
		NSMutableArray* bankArr = [settings valueForKey:BANK_KEY];
		NSNumber* value = [bankArr objectAtIndex:row];
		if([value intValue] == 0)
		{
			[bankArr replaceObjectAtIndex:row withObject:[NSNumber numberWithInt:1]];
		}
		else 
		{
			[bankArr replaceObjectAtIndex:row withObject:[NSNumber numberWithInt:0]];
		}
	}
	else if(section == TABLE_SECTION_DISTANCE)
	{
		[settings setObject:[NSNumber numberWithInt:row] forKey:DISTANCE_KEY];
	}
	
	[settingTableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc 
{
	[navigationBar release];
	[settingTableView release];
	[settings release];
    [super dealloc];
}


@end

