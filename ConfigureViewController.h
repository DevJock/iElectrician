//
//  ConfigureViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 5/28/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

@interface ConfigureViewController : UIViewController<UIAlertViewDelegate,CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
}
- (IBAction)buttonPressed:(id)sender;
- (IBAction)changeColor:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *colorButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UILabel *cvLabel;

@property (strong, nonatomic) IBOutlet UISlider *hMin;
@property (strong, nonatomic) IBOutlet UISlider *sMin;
@property (strong, nonatomic) IBOutlet UISlider *vMin;

@property (strong, nonatomic) IBOutlet UISlider *hMax;
@property (strong, nonatomic) IBOutlet UISlider *sMax;
@property (strong, nonatomic) IBOutlet UISlider *vMax;

@end
