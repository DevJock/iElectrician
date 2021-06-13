//
//  CapacitorViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 7/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CapacitorViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField1;

@property (strong, nonatomic) IBOutlet UISlider *slider1;

@property (strong, nonatomic) IBOutlet UIButton *button1;
- (IBAction)buttonPress:(id)sender;

@end
