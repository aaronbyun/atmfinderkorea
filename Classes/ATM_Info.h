//
//  ATM_Info.h
//  ATM Finder
//
//  Created by Young Byun on 10. 2. 13..
//  Copyright 2010 Likus. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ATM_Info : NSObject 
{
	NSInteger _id;
	NSInteger _bankCode;
	NSInteger _type;
	
	NSString* addressState;
	NSString* addressCity;
	NSString* addressDetail;
	NSString* availableTime;
	
	double latitude;
	double longitude;
	double distance;
}

@property (assign) NSInteger _id;
@property (assign) NSInteger _bankCode;
@property (assign) NSInteger _type;

@property (nonatomic, retain) NSString* addressState;
@property (nonatomic, retain) NSString* addressCity;
@property (nonatomic, retain) NSString* addressDetail;
@property (nonatomic, retain) NSString* availableTime;

@property (assign) double latitude;
@property (assign) double longitude;
@property (assign) double distance;

@end
