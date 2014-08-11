//
//  AboutDetailViewController3.h
//  ATM Korea
//
//  Created by Young Byun on 10. 3. 11..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutDetailViewController3 : UIViewController <UIWebViewDelegate>
{
	UIWebView* webView;
	NSString* url;
	NSString* banktitle;
	
	UIActivityIndicatorView* activityIndicatorView;
}

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (retain) NSString* url;
@property (retain) NSString* banktitle;

@end
