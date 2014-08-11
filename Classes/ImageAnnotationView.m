//
//  ImageAnnotationView.m
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 6..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageAnnotationView.h"
#import "ImageAnnotation.h"

// [UIImage imageNamed:@"kb.png"];
/*const UIImage* bankAnnotationImage[8] = {[UIImage imageNamed:@"kb.png"], 
										   [UIImage imageNamed:@"ibk.png"],
[UIImage imageNamed:@"nh.png"], [UIImage imageNamed:@"shinhan.png"], 
[UIImage imageNamed:@"keb.png"], [UIImage imageNamed:@"woori.png"],
[UIImage imageNamed:@"sc.png"], [UIImage imageNamed:@"hana.png"]};
 /Developer/Platforms/iPhoneOS.platform/Developer/Library/PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources
*/

@implementation ImageAnnotationView
 
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(26.0, 32.0);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
	   self.canShowCallout = YES;
		//  self.centerOffset = CGPointMake(30.0, 42.0);
    }
    return self;	
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
	[super setAnnotation:annotation];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	ImageAnnotation* atmItem = (ImageAnnotation*)self.annotation;
	if(atmItem.type == -1)
	{
		[[UIImage imageNamed:@"mypos.png"] drawInRect:CGRectMake(0.0, 0.0, 26.0, 32.0)];
	}
	else 
	{
		NSString* imageFile = [NSString stringWithFormat:@"%d_2.png", atmItem.bankCode];
		//NSLog(@"imageFileName : %@", imageFile);
		[[UIImage imageNamed:imageFile] drawInRect:CGRectMake(0.0, 0.0, 26.0, 32.0)];

	}
}

@end
