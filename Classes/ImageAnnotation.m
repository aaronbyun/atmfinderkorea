//
//  ImageAnnotation.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageAnnotation.h"
#import "AppConstant.h"

#define TYPE_BANK  1
#define TYPE_ATM 2

extern const NSString* BANK_LISTS [MAX_BANK_CNT];

@implementation ImageAnnotation

@synthesize latitude, longitude;
@synthesize type;
@synthesize detailAddress;
@synthesize bankCode;
@synthesize availableTime;

- (CLLocationCoordinate2D)coordinate
{
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
	
    return coordinate;	
}

- (NSString*) title
{
	NSString* retTitle = nil;
	if(type == TYPE_BANK)
	{
		//return @"Bank";
		retTitle = [NSString stringWithFormat:@"%@ %@", BANK_LISTS[bankCode-1], @"BANK"];
		return retTitle;
	}
	else if(type == TYPE_ATM)
	{
		//return @"ATM";
		if(self.availableTime == nil || [self.availableTime compare:@"" options:1] == NSOrderedSame)
		{
			retTitle = [NSString stringWithFormat:@"%@ %@", BANK_LISTS[bankCode-1], @"ATM"];
		}
		else 
		{
			retTitle = [NSString stringWithFormat:@"%@ %@      [%@]", BANK_LISTS[bankCode-1], @"ATM", self.availableTime];
		}
		
		return retTitle;
	}
	else 
	{
		//NSLog(@"Not supported type...");
		return @"현재 위치";
	}
}

- (NSString*) subtitle
{
	NSLog(@"address is %@", detailAddress);
	
	return detailAddress;
}

- (void) dealloc
{
	[detailAddress release];
	[availableTime release];
	[super dealloc];
}

@end
