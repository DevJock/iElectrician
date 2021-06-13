//
//  SettingsViewController.m
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppLib.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    AppLib *appLib;
}
@synthesize opencvSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    appLib = [[AppLib alloc] init];
    if([[appLib retriveSettings:@"OPEN_CV_ENABLED"] isEqualToString:@"YES"])
        opencvSwitch.on = true;
    else
        opencvSwitch.on = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




- (IBAction)clearData:(id)sender
{
    NSLog(@"Cleared Cache");
    [appLib deleteFilesOfType:@"pdf"];
    [appLib deleteFile:@"Resistor.plist"];
}

- (IBAction)toggledSwitch:(id)sender
{
    NSString *str;
    if(opencvSwitch.on)
    {
        NSLog(@"Camera Enabled");
        str = @"YES";
    }
    else
    {
        NSLog(@"Camera Disabled");
        str = @"NO";
    }
    [appLib saveSettings:str forKey:@"OPEN_CV_ENABLED"];
    
}
@end
