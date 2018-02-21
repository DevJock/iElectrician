//
//  WebViewController.m
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "WebViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppLib.h"

@implementation WebViewController
{
    AppLib *appLib;
    NSString *mime;
    NSString *fileName;
}
@synthesize URL,webView,mode;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appLib = [[AppLib alloc] init];
    webView.delegate = self;
    NSURLRequest *urlReq =  [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [NSURLConnection connectionWithRequest:urlReq delegate:self];
    [webView loadRequest: urlReq];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(mode == 0 &&  [self isDisplayingPDF])
    {
        NSArray *cms = [self.webView.request.URL.absoluteString componentsSeparatedByString:@"/"];
        fileName = [cms objectAtIndex:[cms count] -1 ];
        UIAlertView *fname = [[UIAlertView alloc] initWithTitle:@"Enter File Name" message:@"Enter a Filename to Save PDF for offline use" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        fname.alertViewStyle = UIAlertViewStylePlainTextInput;
        [fname textFieldAtIndex:0].placeholder = fileName;
        [fname textFieldAtIndex:0].textAlignment = NSTextAlignmentCenter;
        [fname show];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Canceled File Save");
    }
    else if(buttonIndex == 1)
    {
        if(![[alertView textFieldAtIndex:0].text isEqualToString:fileName] && [[alertView textFieldAtIndex:0].text length] >1)
        {
            fileName = [alertView textFieldAtIndex:0].text ;
        }
        NSData *pdf = [NSData dataWithContentsOfURL: self.webView.request.URL.absoluteURL];
        NSString  *documentsDirectory = [[appLib documentsPath] stringByAppendingPathComponent:@"datasheets"];
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
        [pdf writeToFile:filePath atomically:YES];
        NSLog(@"PDF Saved as %@",fileName);
    }
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    mime = [response MIMEType];
}

- (BOOL)isDisplayingPDF
{
    NSString *extension = [[mime substringFromIndex:([mime length] - 3)] lowercaseString];
    return ([[[self.webView.request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"] || [extension isEqualToString:@"pdf"]);
}



@end
