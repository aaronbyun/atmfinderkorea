//
//  DatabaseManager.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 1..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface DatabaseManager : NSObject 
{
	sqlite3*  _sqlite;
	NSDictionary* settingsForQuery;
	CLLocationCoordinate2D coordinate;
	MKPlacemark* placemark;
	
	NSInteger numberOfSettings;
	
	NSMutableArray* resultArray;
}

@property (nonatomic, retain) NSDictionary* settingsForQuery;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) MKPlacemark* placemark;

@property (nonatomic, assign) NSInteger numberOfSettings;
@property (nonatomic, readonly) NSMutableArray* resultArray;

- (id) initWithSettingValue:(NSDictionary*)settings AndCoordinate:(CLLocationCoordinate2D)coord AndAddress:(MKPlacemark*)address;

- (BOOL) openDatabase;
- (BOOL) getDataV1;
- (NSMutableArray*) getDataV2:(MKCoordinateRegion)region;
- (BOOL) getDataV3; // English version.
- (void) closeDatabase;
- (void) makeResultArray;
- (NSInteger) bankCodeToIndex:(NSInteger)code;

@end
