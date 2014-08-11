//
//  AboutRootViewController.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutRootViewController.h"
#import "AboutDetailViewController.h"
#import "AboutDetailViewController2.h"
#import "AboutDetailViewController3.h"

#define SECTION_CNT 3

#define HELP_CNT 1
#define DEVEL_CNT 3
#define INFOR_CNT 8

NSString* sectionString[SECTION_CNT] = {@"ATM Finder", @"만든 사람들", @"정보 제공"};
NSString* sectionString2[SECTION_CNT] = {@"ATM Finder", @"Created by", @"Information"};
NSInteger sectionNumberArray[SECTION_CNT] = {1, 3, 8};

//NSString* helpString[HELP_CNT] = {@"어플리케이션 정보", @"어플리케이션 사용법", @"알림"};
NSString* helpString[HELP_CNT] = {@"본 어플은 사용자의 현재 위치로부터 가장 가까운 ATM으로 안내합니다. 현재 버젼에서는 8개 은행을 지원하며 서울, 경기 지역 뿐만 아니라 전국에 있는 ATM을 찾을 수 있습니다. 어플에 관한 데이터는 1-2개월 주기로 업데이트 될 예정입니다."};
NSString* helpString2[HELP_CNT] = {@"ATM Finder finds the nearest ATMs from your current location. In this initial version. it supports 8 banks and provies not only Seoul, Gyung-gi ATMs but also ATMs in the whole country. The data about ATMs are updated every or every other months."};

NSString* developerImageString[DEVEL_CNT] = {@"macmath22.png", @"kingkong.png", @"saljjinnom.png"};
NSString* developerString[DEVEL_CNT] = {@"대박", @"킹콩", @"살찐놈"};
NSString* developerEmailString[DEVEL_CNT] = {@"macmath22@hanmail.net", @"bypbyp@nate.com", @"saljjinnom@naver.com"};
NSString* informationString[INFOR_CNT] = {@"국민은행", @"기업은행", @"농협", @"신한은행", @"외환은행", @"우리은행", @"제일은행", @"하나은행"};

NSString* urlString[INFOR_CNT] = {@"http://money.kbstar.com/quics?asfilecode=5023&_nextPage=page=B002066", 
											@"http://kiupbank.chzero.com/popup/search_step01.jsp/", 
											@"http://nonghyup.chzero.com/",
											@"http://www.shinhan.com/branch/domestic/domestic.jsp",
											@"http://www.keb.co.kr/etc/index_branch.html",
											@"http://pot.wooribank.com/pot/branch/wcgud100_01p.jsp?IN=TOP2&redraw=no", 
											@"http://asp.congnamul.com/firstbank/map/index.jsp?id=null&type=null/",
											@"http://hanabank.chzero.com/top.jsp"};

@implementation AboutRootViewController

@synthesize tableView;

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
	self.navigationItem.title = NSLocalizedString(@"About", @"About");
	
	UINavigationBar* naviBar = self.navigationController.navigationBar;
	naviBar.tintColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.0];
}

- (void) viewWillAppear:(BOOL)animated
{
	UIApplication* myApp = [UIApplication sharedApplication];
	myApp.networkActivityIndicatorVisible = NO;
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
	tableView = nil;
}


- (void)dealloc 
{
	[tableView release];
    [super dealloc];
}

#pragma mark -
#pragma mark TableView Delegate Method
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return SECTION_CNT;
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return sectionNumberArray[section];
}

- (NSString*) tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	if([currentLanguage compare:@"ko"] == NSOrderedSame)
	{
		return sectionString[section];
	}
	else 
	{
		return sectionString2[section];
	}
}

- (CGFloat) tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = indexPath.section;
	
	if(section == 0) return 200.0;
	else if(section == 1) return 56.0;
	else return 44.0;
}

- (UITableViewCell*) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* identifier = @"About Cell";
	static NSString* identifier2 = @"About Cell2";
	
	int section = indexPath.section;
	int row = indexPath.row;
	
	UITableViewCell* cell = nil;
	if(section == 1)
	{
		cell = [table dequeueReusableCellWithIdentifier:identifier];
	}
	else 
	{
		cell = [table dequeueReusableCellWithIdentifier:identifier2];
	}
	
	if(cell == nil)
	{
		if(section == 1)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
		}
		else 
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2] autorelease];
		}
	}
		
	if(section == 0)
	{		
		cell.textLabel.lineBreakMode = UILineBreakModeClip;
		cell.textLabel.numberOfLines = 17;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
		NSString *currentLanguage = [languages objectAtIndex:0];
		
		if([currentLanguage compare:@"ko"] == NSOrderedSame)
		{
			cell.textLabel.text = helpString[row];
		}
		else 
		{
			cell.textLabel.text = helpString2[row];
		}
	}
	else if(section == 1)
	{
		cell.imageView.image = [UIImage imageNamed:developerImageString[row]];
		cell.textLabel.text = developerString[row];
		cell.detailTextLabel.text = developerEmailString[row];
	}
	else 
	{
		cell.textLabel.text = informationString[row];
	}

		
	return cell;
}

- (NSIndexPath*) tableView:(UITableView *)table willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = indexPath.section;
	
	if(section == 0 || section == 1) return nil ;
	
	return indexPath;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int section = indexPath.section;
	int row = indexPath.row;
	
	if(section == 0)
	{
		AboutDetailViewController* detailViewController = [[AboutDetailViewController alloc] init];
		[self.navigationController pushViewController:detailViewController animated:YES];
		[detailViewController release];
	}
	else if(section == 1)
	{/*
		AboutDetailViewController2* detailViewController2 = [[AboutDetailViewController2 alloc] init];
		detailViewController2.develTitle = developerString[row];
		[self.navigationController pushViewController:detailViewController2 animated:YES];
		[detailViewController2 release];*/
	}
	else // safari 연결
	{
		AboutDetailViewController3* detailViewController3 = [[AboutDetailViewController3 alloc] init];
		detailViewController3.url = urlString[row];
		detailViewController3.banktitle = [NSString stringWithFormat:@"%@ 지점", informationString[row]];
		[self.navigationController pushViewController:detailViewController3 animated:YES];
		[detailViewController3 release];
		
		[table deselectRowAtIndexPath:indexPath animated:YES];
	}
	
	[table deselectRowAtIndexPath:indexPath animated:YES];
}

@end
