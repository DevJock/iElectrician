//
//  WebViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate,NSURLConnectionDataDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSString *URL;
@property(nonatomic) int mode;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
