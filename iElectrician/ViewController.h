//
//  ViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

@interface ViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,CvVideoCameraDelegate,UIActionSheetDelegate>
{
    CvVideoCamera* videoCamera;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *tapZone;

@property (strong, nonatomic) IBOutlet UIView *resistor;


@property (strong, nonatomic) IBOutlet UILabel *resistanceLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *resistancePicker;
@property (strong, nonatomic) IBOutlet UIView *bandOne;
@property (strong, nonatomic) IBOutlet UIView *bandTwo;
@property (strong, nonatomic) IBOutlet UIView *bandThree;
@property (strong, nonatomic) IBOutlet UIView *bandFour;

@end

