//
//  ImageAnnotation.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation : NSObject <MKAnnotation>
{
	double latitude;
	double longitude;
	CLLocationCoordinate2D coordinate;
	
	NSInteger bankCode;
	NSInteger type;
	NSString* detailAddress;
	NSString* availableTime;
}


@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) NSInteger bankCode;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, retain) NSString* detailAddress;
@property (nonatomic, retain) NSString* availableTime;

@end
