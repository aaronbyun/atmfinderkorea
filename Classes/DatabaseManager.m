//
//  DatabaseManager.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DatabaseManager.h"
#import "ATM_Info.h"
#import "AppConstant.h"

#define COL_ID  0
#define COL_BANKCODE  1
#define COL_TYPE 2
#define COL_ADDRESSSTATE  3
#define COL_ADDRESSCITY  4
#define COL_ADDRESSDETAIL  5
#define COL_AVAILABLETIME  6
#define COL_LATITUDE    7
#define COL_LONGITUDE  8

#define _DEBUG

const static int distance_range[MAX_DISTANCE_CNT] = {100, 200, 300, 500, 1000};

@implementation DatabaseManager

@synthesize settingsForQuery;
@synthesize coordinate;
@synthesize placemark;
@synthesize numberOfSettings;
@synthesize resultArray;

- (id) initWithSettingValue:(NSDictionary*)settings AndCoordinate:(CLLocationCoordinate2D)coord AndAddress:(MKPlacemark*)address
{
	self = [super init];
	if(self != nil)
	{
		self.settingsForQuery = settings;
		self.coordinate = coord;
		self.placemark = address;
		
#ifdef _DEBUG	
		NSLog(@"retain count of settings %d", [self.settingsForQuery retainCount]);
#endif
		
		[self openDatabase];
	}
	
	return self;
}

- (void) dealloc
{
	[settingsForQuery release];
	[placemark release];
	[resultArray release];
	
#ifdef _DEBUG	
	NSLog(@"retain count of settings %d", [self.settingsForQuery retainCount]);
#endif	
	
	[self closeDatabase];
	[super dealloc];
}

#pragma mark -
#pragma mark Database Management functions

- (BOOL) openDatabase
{
	// ATM database 의 특성 상, 한번 deploy 되면 단순히, select 되는 것이므로, document directory에 복사 할 필요가 없다. 
	// 따라서 단순히 main bundle에서 사용하도록 한다 
	NSString* databasePath = [[NSBundle mainBundle] pathForResource:@"ATMDB" ofType:@"sqlite"];
	
#ifdef _DEBUG	
	NSLog(@"Path of the database file %@", databasePath);
#endif
	
	int open = sqlite3_open([databasePath UTF8String], &_sqlite);
	
	if(open == SQLITE_OK) return YES;
	
	[self closeDatabase];
	
	return NO;
}

// not use callback mechanism
- (BOOL) getDataV1
{
	// query 생성 조건
	// 1. 은행 종류
	// 2. 지역 범위
	
	NSArray* array = [self.settingsForQuery valueForKey:BANK_KEY];
	int i, j = 0, count = [array count];
	
	//NSString* query = [NSString stringWithFormat:@"SELECT * from %@ WHERE %@ LIKE ;", @"bank_db", @"addressCity"];
	NSMutableString* query = [[NSMutableString alloc] initWithString:@"SELECT * from bank_db"];
	
	for(i = 0; i < count; i++)
	{
		int value = [(NSNumber*)[array objectAtIndex:i] intValue];
		
		if(value == 1)
		{
			if(j == 0) // 첫번째 일 경우
			{
				[query appendString:@" WHERE ( bankCode = ?"];
			}
			else 
			{
				[query appendString:@" OR bankCode = ?"];
			}
			j++;
		}
	}
	
	[query appendString:@") AND addressCity = ?"];
	[query appendString:@";"];
	
	j = 0;
	
	sqlite3_stmt* statement;
	
	int prepare = sqlite3_prepare_v2(_sqlite, [query UTF8String], -1, &statement, nil);

	if(prepare != SQLITE_OK) return NO;
	
	
	for(i = 0; i < count; i++)
	{
		int value = [(NSNumber*)[array objectAtIndex:i] intValue];
		if(value == 1)
		{
			sqlite3_bind_int(statement, j + 1, i + 1);
			j++;
		}
	}
	
	char* bindingText = NULL;
	if(placemark.administrativeArea == nil) // 광역시 
	{
		bindingText= (char*)[placemark.subLocality UTF8String];
	}
	else  // 8도 전부
	{
		bindingText= (char*)[placemark.locality UTF8String];
	}

	sqlite3_bind_text(statement, j + 1, bindingText, -1, nil);
	
	while(sqlite3_step(statement) == SQLITE_ROW) // 이 부분 Thread 로 동작 하도록 설계 
	{	
		double latitude = sqlite3_column_double(statement, COL_LATITUDE);
		double longitude = sqlite3_column_double(statement, COL_LONGITUDE);
				
		CLLocation* compare = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		CLLocation* currentLoc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		
		double distance =  [currentLoc getDistanceFrom:compare];
		int settingDistance = (int)[(NSNumber*)[settingsForQuery valueForKey:DISTANCE_KEY] integerValue];
		
		//NSLog(@"distance  : %f   and settings distance  : %d  ", distance, distance_range[settingDistance]);
		
		if(distance <= distance_range[settingDistance]) 
		//if(distance <= 15000) 
		{
			int bankCode = sqlite3_column_int(statement, COL_BANKCODE);
			int type = sqlite3_column_int(statement, COL_TYPE);
		
			NSString* addressState = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, COL_ADDRESSSTATE)];
			NSString* addressCity = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, COL_ADDRESSCITY)];
			NSString* addressDetail = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, COL_ADDRESSDETAIL)];
			char* time = (char*)sqlite3_column_text(statement, COL_AVAILABLETIME);
			NSString* availableTime = @"";
			if(time != nil)
			{
				availableTime = [NSString stringWithUTF8String:time];
			}
			
			NSLog(@"Thr address : %@ %@ %@", addressState, addressCity, addressDetail);
				
			ATM_Info* info = [[ATM_Info alloc] init];
			
			info._bankCode = bankCode;
			info._type = type;
			
			info.addressState = addressState;
			info.addressCity = addressCity;
			info.addressDetail = addressDetail;
			info.availableTime = availableTime;
		
			info.latitude = latitude;
			info.longitude = longitude;
		
			info.distance = distance;
		
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			
			int k = [self bankCodeToIndex:bankCode];					
	  		NSMutableArray* temp = (NSMutableArray*)[resultArray objectAtIndex:k];
			[temp addObject:info];
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			[currentLoc release];
			[compare release];
			[info release];
		}
	}
	
	sqlite3_finalize(statement);
	
	[query release];
		
	return YES;
}

- (BOOL) getDataV3
{
	// query 생성 조건
	// 1. 은행 종류
	// 2. 지역 범위
	
	NSArray* array = [self.settingsForQuery valueForKey:BANK_KEY];
	int i, j = 0, count = [array count];
	
	//NSString* query = [NSString stringWithFormat:@"SELECT * from %@ WHERE %@ LIKE ;", @"bank_db", @"addressCity"];
	NSMutableString* query = [[NSMutableString alloc] initWithString:@"SELECT * from bank_db"];
	
	for(i = 0; i < count; i++)
	{
		int value = [(NSNumber*)[array objectAtIndex:i] intValue];
		
		if(value == 1)
		{
			if(j == 0) // 첫번째 일 경우
			{
				[query appendString:@" WHERE ( bankCode = ?"];
			}
			else 
			{
				[query appendString:@" OR bankCode = ?"];
			}
			j++;
		}
	}
	
	[query appendString:@") AND (latitude <= ? AND latitude >= ? AND longitude <= ? AND longitude >= ?)"];
	[query appendString:@";"];
	
	j = 0;
	
	sqlite3_stmt* statement;
	
	int prepare = sqlite3_prepare_v2(_sqlite, [query UTF8String], -1, &statement, nil);
	
	if(prepare != SQLITE_OK) return NO;
	
	
	for(i = 0; i < count; i++)
	{
		int value = [(NSNumber*)[array objectAtIndex:i] intValue];
		if(value == 1)
		{
			sqlite3_bind_int(statement, j + 1, i + 1);
			j++;
		}
	}
	
	sqlite3_bind_double(statement, j + 1, coordinate.latitude + 0.05);
	sqlite3_bind_double(statement, j + 2, coordinate.latitude - 0.05);
	sqlite3_bind_double(statement, j + 3, coordinate.longitude + 0.05);
	sqlite3_bind_double(statement, j + 4, coordinate.longitude - 0.05);
	
	while(sqlite3_step(statement) == SQLITE_ROW) // 이 부분 Thread 로 동작 하도록 설계 
	{	
		double latitude = sqlite3_column_double(statement, COL_LATITUDE);
		double longitude = sqlite3_column_double(statement, COL_LONGITUDE);
		
		CLLocation* compare = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		CLLocation* currentLoc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		
		double distance =  [currentLoc getDistanceFrom:compare];
		int settingDistance = (int)[(NSNumber*)[settingsForQuery valueForKey:DISTANCE_KEY] integerValue];
		
		//NSLog(@"distance  : %f   and settings distance  : %d  ", distance, distance_range[settingDistance]);
		
		if(distance <= distance_range[settingDistance]) 
			//if(distance <= 15000) 
		{
			int bankCode = sqlite3_column_int(statement, COL_BANKCODE);
			int type = sqlite3_column_int(statement, COL_TYPE);
			
			char* state = (char*)sqlite3_column_text(statement, COL_ADDRESSSTATE);
			char* city = (char*)sqlite3_column_text(statement, COL_ADDRESSCITY);
			char* detail = (char*)sqlite3_column_text(statement, COL_ADDRESSDETAIL);
			NSString* addressState = @"";
			NSString* addressCity = @"";
			NSString* addressDetail = @"";
			
			if(state != nil)
			{
				addressState = [NSString stringWithUTF8String:state];
			}
			if(city != nil)
			{
				addressCity = [NSString stringWithUTF8String:city];
			}
			if(detail != nil)
			{
				addressDetail = [NSString stringWithUTF8String:detail];
			}
			
			char* time = (char*)sqlite3_column_text(statement, COL_AVAILABLETIME);
			NSString* availableTime = @"";
			if(time != nil)
			{
				availableTime = [NSString stringWithUTF8String:time];
			}
			
			NSLog(@"Thr address : %@ %@ %@", addressState, addressCity, addressDetail);
			
			ATM_Info* info = [[ATM_Info alloc] init];
			
			info._bankCode = bankCode;
			info._type = type;
			
			info.addressState = addressState;
			info.addressCity = addressCity;
			info.addressDetail = addressDetail;
			info.availableTime = availableTime;
			
			info.latitude = latitude;
			info.longitude = longitude;
			
			info.distance = distance;
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			
			
			int k = [self bankCodeToIndex:bankCode];					
	  		NSMutableArray* temp = (NSMutableArray*)[resultArray objectAtIndex:k];
			[temp addObject:info];
			
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			[currentLoc release];
			[compare release];
			[info release];
		}
	}
	
	sqlite3_finalize(statement);
	
	[query release];
	
	return YES;
}

// use callback mechanism
- (NSMutableArray*) getDataV2:(MKCoordinateRegion)region
{
	[self openDatabase];
	NSMutableArray* retArray = [[NSMutableArray alloc] init];
	
	double latitude = region.center.latitude;
	double longitude = region.center.longitude;
	
	double minLat = latitude - region.span.latitudeDelta;
	double maxLat = latitude + region.span.latitudeDelta;
	
	double minLong = longitude - region.span.longitudeDelta;
	double maxLong = longitude + region.span.longitudeDelta;

	// 여기서 query 를 생성 한다. query 생성시에 은행의 종류 여부와 상관 없이 좌표 범위로만 query 를제한 한다. 
	
	NSString* query = [NSString stringWithFormat:@"SELECT * from bank_db WHERE ( latitude BETWEEN ? AND ?) AND (longitude BETWEEN ? AND ?)"];
	sqlite3_stmt* statement;
	
	int prepare = sqlite3_prepare_v2(_sqlite, [query UTF8String], -1, &statement, nil);
	
	if(prepare != SQLITE_OK) return nil;
	
	sqlite3_bind_double(statement, 1, minLat);
	sqlite3_bind_double(statement, 2, maxLat);
	sqlite3_bind_double(statement, 3, minLong);
	sqlite3_bind_double(statement, 4, maxLong);
	
	int code;
	
	while((code =  sqlite3_step(statement)) == SQLITE_ROW)
	{
		int bankCode = sqlite3_column_int(statement, COL_BANKCODE);
		int type = sqlite3_column_int(statement, COL_TYPE);
		
		char* state = (char*)sqlite3_column_text(statement, COL_ADDRESSSTATE);
		char* city = (char*)sqlite3_column_text(statement, COL_ADDRESSCITY);
		char* detail = (char*)sqlite3_column_text(statement, COL_ADDRESSDETAIL);
		NSString* addressState = @"";
		NSString* addressCity = @"";
		NSString* addressDetail = @"";
		
		if(state != nil)
		{
			addressState = [NSString stringWithUTF8String:state];
		}
		if(city != nil)
		{
			addressCity = [NSString stringWithUTF8String:city];
		}
		if(detail != nil)
		{
			addressDetail = [NSString stringWithUTF8String:detail];
		}
		
		char* time = (char*)sqlite3_column_text(statement, COL_AVAILABLETIME);
		NSString* availableTime = @"";
		if(time != nil)
		{
			availableTime = [NSString stringWithUTF8String:time];
		}
		
		double latitude = sqlite3_column_double(statement, COL_LATITUDE);
		double longitude = sqlite3_column_double(statement, COL_LONGITUDE);
		
		ATM_Info* info = [[ATM_Info alloc] init];
		
		info._bankCode = bankCode;
		info._type = type;
		
		info.addressState = addressState;
		info.addressCity = addressCity;
		info.addressDetail = addressDetail;
		info.availableTime = availableTime;
		
		info.latitude = latitude;
		info.longitude = longitude;
		
		info.distance = 0;
		
		[retArray addObject:info];
	}
	
	return retArray;
}

- (void) makeResultArray
{
	[resultArray removeAllObjects];
	if(resultArray == nil)
	{
		resultArray = [[NSMutableArray alloc] init];
	}
	
	int i, count = self.numberOfSettings;
	
	for(i = 0; i < count; i++)
	{
		NSMutableArray* tempArr = [[NSMutableArray alloc] init];
		[resultArray addObject:tempArr];
		[tempArr release];
	}
}

- (NSInteger) bankCodeToIndex:(NSInteger)code
{
	int retVal = 0;
	
	NSArray* array = [self.settingsForQuery valueForKey:BANK_KEY];
	
	for(int i = 0; i < [array count]; i++)
	{
		NSNumber* num = [array objectAtIndex:i];
		int val = [num intValue];
		
		if(val == 1)
		{			
			if(code == i+1) break;
			retVal++;
		}
	}
	
	return retVal;
}

- (void) closeDatabase
{
	if(_sqlite)
	{
		sqlite3_close(_sqlite);
		_sqlite = nil;
	}
}


@end
