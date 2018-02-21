//
//  SettingsViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *opencvSwitch;
- (IBAction)clearData:(id)sender;
- (IBAction)toggledSwitch:(id)sender;
@end
