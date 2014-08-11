//
//  NearbyRootController.m
//  ATM Korea
//
//  Created by Young Byun on 10. 2. 28..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NearbyRootController.h"
#import "NearbyDetailViewController.h"
#import "SettingsController.h"
#import "ATM_Info.h"
#import "AppConstant.h"

#define TEST
#undef TEST

extern const NSString* BANK_LISTS [MAX_BANK_CNT] ;

@implementation NearbyRootController

@synthesize settings;
@synthesize locationManager;
@synthesize databaseManager;
@synthesize resultArray;
@synthesize activityIndicatorHolder;
@synthesize activityIndicatorView;
@synthesize _tableView;
@synthesize curLocation;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void) viewWillAppear:(BOOL)animated
{
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPressed:)];
	settingButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Setting", @"ROOT_NEAR_SETTING") style:UIBarButtonItemStyleBordered target:self action:@selector(settingPressed:)];
	
	UINavigationBar* naviBar = self.navigationController.navigationBar;
	naviBar.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];
	
	self.navigationItem.leftBarButtonItem = refreshButton;
	[refreshButton release];
	
	self.navigationItem.title = NSLocalizedString(@"Nearby", @"ROOT_NEAR_TITLE");
	self.navigationItem.rightBarButtonItem = settingButton;
	[settingButton release];
	
	self._tableView.delegate = self;
	self._tableView.dataSource = self;
	
	UIApplication* app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:app];
	
	if(![self loadSettingData])
	{
		settings = [[NSMutableDictionary alloc] initWithCapacity:2];
		NSMutableArray* emptyArr = [[NSMutableArray alloc] initWithCapacity:MAX_BANK_CNT];
		for(int i = 0; i < MAX_BANK_CNT; i++)
		{
			[emptyArr addObject:[NSNumber numberWithInt:0]];
		}
		
		[settings setObject:emptyArr forKey:BANK_KEY];
		[emptyArr release];
		[settings setObject:[NSNumber numberWithInt:4] forKey:DISTANCE_KEY];
	}
	
	locationManager = [[LocationManager alloc] init];
	if(locationManager == nil) return;
	
	locationManager.delegate = self;
	self.navigationItem.prompt = NSLocalizedString(@"Geo coding service started...", @"ROOT_NEAR_PROMPT_GEOSTARTED");
	
	refreshButton.enabled = NO;
	settingButton.enabled = NO;
	
	self._tableView.hidden = YES;
	
	activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142, 160, 35, 35)];
	activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	
	[self.view addSubview:activityIndicatorView];
	[activityIndicatorView startAnimating];
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
	settings = nil;
	locationManager = nil;
	databaseManager = nil;
	resultArray = nil;
}


- (void)dealloc 
{
	[settings release];
	[locationManager release];
	[databaseManager release];
	[resultArray release];
	[activityIndicatorHolder release];
	[activityIndicatorView release];
	[_tableView release];
	[curLocation release];
	[refreshButton release];
	[settingButton release];
	
    [super dealloc];
}

- (void) applicationWillTerminate:(NSNotification*)notification
{
	[self writeSettingData];
}

- (NSString*) getSettingContentFilePath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectoryPath = [paths objectAtIndex:0];
	
	return [documentDirectoryPath stringByAppendingPathComponent:SETTING_FILE_NAME];
}

- (BOOL) loadSettingData
{
	settings = [[NSDictionary alloc] initWithContentsOfFile:[self getSettingContentFilePath]];
	if(settings) return YES;
	
	return NO;
}

- (BOOL) writeSettingData
{
	return [settings writeToFile:[self getSettingContentFilePath] atomically:YES];
}

- (NSInteger) getNumberOfBankSettings
{
	NSArray* bankArr = [settings valueForKey:BANK_KEY];
	int total = [bankArr count];
	int count = 0;
	
	for(int i = 0; i < total; i++)
	{
		NSNumber* value = [bankArr objectAtIndex:i];
		if( [value intValue] == 1) count++;
	}
	
	return count;
}

- (NSString*) getHeaderTitleForSection:(int)index
{
	NSArray* bankArr = [settings valueForKey:BANK_KEY];
	int total = [bankArr count];
	int count = 0;
	
	for(int i = 0; i < total; i++)
	{
		NSNumber* value = [bankArr objectAtIndex:i];
		if( [value intValue] == 1) 
		{
			if(index == count) return (NSString*)BANK_LISTS[i];
			count++;
		}
	}
	
	return @"";
}

#pragma mark -
#pragma mark Tableviiw delegates

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sections = 0;
	
#ifdef TEST
	sections = 1;
#else 
	
	sections = [self getNumberOfBankSettings];
#endif 
	
	return sections;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* title = nil;
#ifdef	TEST
	title = [NSString stringWithFormat:@"section - %d", section];
#else
	title = [self getHeaderTitleForSection:section];
#endif	
	return title;
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	NSInteger rows = 0;
#ifdef TEST
	rows = 3;
#else 
	NSArray* infoArray = (NSArray*)[resultArray objectAtIndex:section];
	rows = [infoArray count];
#endif
	return rows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

/*
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30.0;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIImage* image = [UIImage imageNamed:@"icon.png"]; 
	UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
	return imageView;
}
*/
 
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* identifier = @"Nearbycell";
	
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		//cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		// custom cell 을 사용 한다. 
		NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:@"NearbyTableViewCell" owner:self options:nil];
		cell  = [nibContents objectAtIndex:0];
	}
	
	// configure table view
#ifdef TEST
	UIImageView* imageView = (UIImageView*)[cell viewWithTag:1000];
	imageView.image = [UIImage imageNamed:@"ATM_Cell.png"];
	
	UILabel* label = (UILabel*)[cell viewWithTag:1001];
	label.text = [NSString stringWithFormat:@"%@ %@", @"서울시", @"강남구"]; 
		
	label = (UILabel*)[cell viewWithTag:1003];
	label.text = @"양재동 AT center"; 
	
#else
	int section = indexPath.section;
	int row = indexPath.row;
 	
	NSArray* infoArray = (NSArray*)[resultArray objectAtIndex:section];
	ATM_Info* info = (ATM_Info*)[infoArray objectAtIndex:row];
	
//	UIImageView* imageView = (UIImageView*)[cell viewWithTag:1000];
//	imageView.image = [UIImage imageNamed:@"ATM_Cell3.png"];
	
	UILabel* label = (UILabel*)[cell viewWithTag:1001];
	label.text = [NSString stringWithFormat:@"%@ %@", info.addressState, info.addressCity]; 
	
	label = (UILabel*)[cell viewWithTag:1003];
	label.text = info.addressDetail; 	
	
	label = (UILabel*)[cell viewWithTag:1002];
	label.text = [NSString stringWithFormat:@"%0.0fm", info.distance];
	label.textColor = [UIColor colorWithRed:0.3 green:0.7 blue:0.9 alpha:1.0];
#endif	
	
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = indexPath.section;
	int row = indexPath.row;
 	
	NSArray* infoArray = (NSArray*)[resultArray objectAtIndex:section];
	ATM_Info* info = (ATM_Info*)[infoArray objectAtIndex:row];
	
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = info.latitude;
	coordinate.longitude = info.longitude;

	NearbyDetailViewController* detailController = [[NearbyDetailViewController alloc] initWithCoordinate:coordinate AndCode:info._bankCode AndType:info._type AndDetailAddress:info.addressDetail AndTime:info.availableTime];
	detailController.curLoc = curLocation;
	detailController.distance = info.distance;
	//NSLog(@"detail address is %@", info.addressDetail);
	
	[self.navigationController pushViewController:detailController animated:YES];
	
	[detailController release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark SettingsControllerDelegate

- (BOOL) settingViewController:(SettingsController*)settingController didFinishWithInfo:(NSDictionary*)setting
{
	NSInteger count = [self getNumberOfBankSettings];
	
	if(count == 0) return NO;
	
	if(locationManager == nil) return NO;
	
	UILabel* label = (UILabel*)[self.view viewWithTag:2000];
	label.hidden = YES;
	self.navigationItem.prompt = NSLocalizedString(@"Geo coding service started...", @"ROOT_NEAR_PROMPT_GEOSTARTED");
	//[self.tableView reloadData];E
	//설정 하고 낭면 다시 검색 하도록 함
	self._tableView.hidden = YES;
	[locationManager start];
	
	refreshButton.enabled = NO;
	settingButton.enabled = NO;
	
	UITabBarItem* item = self.tabBarController.tabBar.selectedItem;
	item.badgeValue = nil;
	[activityIndicatorView startAnimating];
	return YES;
}

#pragma mark -
#pragma mark Custom Action Method

- (void) refreshPressed:(id)sender
{
	if(locationManager == nil) return;
		
	self.navigationItem.prompt = NSLocalizedString(@"Geo coding service started...", @"ROOT_NEAR_PROMPT_GEOSTARTED");
	
	self._tableView.hidden = YES;

	[locationManager start];
	
	refreshButton.enabled = NO;
	settingButton.enabled = NO;
	
	UITabBarItem* item = self.tabBarController.tabBar.selectedItem;
	item.badgeValue = nil;
	[activityIndicatorView startAnimating];
}

- (void) settingPressed:(id)sender
{	
	SettingsController* settingController = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:nil];
	settingController.delegate = self;
	settingController.settings = self.settings;
	[self.navigationController presentModalViewController:settingController animated:YES];
	//[self.navigationController pushViewController:settingController animated:YES];
	
	[settingController release];
}

#pragma mark - 
#pragma mark LocationManager delegate

// 위치를 제대로 찾았을 경우 callback으로 전달됨. 즉 이때 db query를 수행 하면 됨.
- (void) locationManager:(LocationManager*) locManager didSuccessfullyFinishWithCLLocation:(CLLocation*)location AndAddress:(MKPlacemark*)address
{
	//[activityIndicatorView startAnimating];
	//self.navigationItem.prompt = NSLocalizedString(@"Detected...", @"ROOT_NEAR_PROMPT_SUCCESS");
		
	//self.navigationItem.prompt = NSLocalizedString(@"Geo coding service started...", @"ROOT_NEAR_PROMPT_GEOSTARTED");
//	NSString* promptString = [locManager convertMKPlacemarkToString:address];	
//	self.navigationItem.prompt = promptString;
//	[promptString release];
	
	//[activityIndicatorView startAnimating];
	
	curLocation = location;
	
	self.navigationItem.prompt = nil;
	
//	NSTimer* timer = [NSTimer timerWithTimeInterval:15.0 target:self selector:@selector(makePromptEmpty) userInfo:nil repeats:NO];
//	[timer fire];
	
	NSInteger count = [self getNumberOfBankSettings];
	
	if(count  == 0 ) 
	{
		settingButton.enabled = YES;
		
		UILabel* errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 135, 250, 80)];
		errorLabel.textAlignment = UITextAlignmentCenter;
		errorLabel.backgroundColor =  [UIColor grayColor];//[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		errorLabel.textColor = [UIColor whiteColor];
		errorLabel.text = NSLocalizedString(@"Please select banks in setting.", @"ROOT_NEAR_SETTING_SELECT_BANK");
		errorLabel.tag = 2000;
		errorLabel.numberOfLines = 1;
		[self.view addSubview:errorLabel];
		[errorLabel release];
		
		[activityIndicatorView stopAnimating];
		
		[self._tableView reloadData];
		return;
	}
	
	UILabel* label = (UILabel*)[self.view viewWithTag:2000];
	label.hidden = YES;
	
	if(databaseManager != nil) 
	{
		[databaseManager release];
		databaseManager = nil;	
	}
	
	databaseManager = [[DatabaseManager alloc] initWithSettingValue:settings AndCoordinate:location.coordinate AndAddress:address];
	
	databaseManager.numberOfSettings = count;
	[databaseManager makeResultArray];
	
	//  한글 version과 영어 version처리가 다름.
	
#if 0
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
#endif	
	
#if 0	
	if([currentLanguage compare:@"ko"] ==  NSOrderedSame)
	{
		[databaseManager getDataV1];
	}
	else
	{
		[databaseManager getDataV3];
	}
#else 
	[databaseManager getDataV3];
#endif
	
	resultArray = databaseManager.resultArray;
	
	[activityIndicatorView stopAnimating];
	self._tableView.hidden = NO;
	
	[self._tableView reloadData];
	int total = 0;
	for(int i = 0; i < [resultArray count]; i++)
	{
		NSMutableArray* temp = (NSMutableArray*)[resultArray objectAtIndex:i];
		total += [temp count];
	}

	UITabBarItem* item = (UITabBarItem*)[self.tabBarController.tabBar.items objectAtIndex:0];
	item.badgeValue = [NSString stringWithFormat:@"%d", total];
	
	//[databaseManager release];
	refreshButton.enabled = YES;
	settingButton.enabled = YES;
}

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
	else 
	{
		//self.navigationItem.prompt = NSLocalizedString(@"Can't find your location.", @"ROOT_NEAR_PROMPT_UNSUCCESS");
	}
	
	//db에 접근하지 않고 끝낸다.
	[activityIndicatorView stopAnimating];
	self._tableView.hidden = NO;
	
	[self._tableView reloadData];
	
	refreshButton.enabled = YES;
	settingButton.enabled = YES;
}

- (void) locationManager:(LocationManager*) locManager didSuccessfullyGetGeoData:(CLLocation*)location
{
	self.navigationItem.prompt = NSLocalizedString(@"Geo coding service started...", @"ROOT_NEAR_PROMPT_GEOSTARTED");
	
	//   double accuracy = location.horizontalAccuracy;
	//	NSString* message = [NSString stringWithFormat:@"GPS 로 얻어온 현재 위치의 정확도 반경은 %0.0f m 입니다.", accuracy];	
	//	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"알림" message:message delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
	//	[alert show];
	//	[alert release];
	curLocation = location;
}

#pragma mark -
#pragma mark TEST

- (void) makePromptEmpty
{
	self.navigationItem.prompt = nil;
}

@end
