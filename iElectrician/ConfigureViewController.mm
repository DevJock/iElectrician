//
//  ConfigureViewController.m
//  iElectrician
//
//  Created by Chiraag Bangera on 5/28/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "ConfigureViewController.h"
#import "AppLib.h"

@interface ConfigureViewController ()

@end

@implementation ConfigureViewController
{
    AppLib *appLib;
    float hmin,smin,vmin,hmax,smax,vmax;
    int colorCode;
    NSArray *codes;
    NSMutableArray *minHSVValues;
    NSMutableArray *maxHSVValues;
    NSMutableDictionary *rData;
}
using namespace cv;

@synthesize cvLabel,videoCamera,imagePreview,hMin,hMax,sMin,sMax,vMin,vMax,saveButton,colorButton;



- (void)viewDidLoad
{
    [super viewDidLoad];
    appLib = [[AppLib alloc] init];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imagePreview];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    [hMin addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
    [sMin addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
    [vMin addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
    [hMax addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
    [sMax addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
    [vMax addTarget:self action:@selector(act) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [appLib checkAndCopy:@"Resistor.plist"];
    if([[appLib retriveSettings:@"OPEN_CV_ENABLED"] isEqualToString:@"YES"])
    {
        NSLog(@"Starting Camera");
        [videoCamera start];
    }
    rData = [[NSMutableDictionary alloc] init];
    minHSVValues = [[NSMutableArray alloc] init];
    maxHSVValues = [[NSMutableArray alloc] init];
    rData = [appLib loadJSONDataFromFile:@"Resistor.plist"];
    for(int i=0;i<[[rData objectForKey:@"BandOneTwo"] count];i++)
    {
        [minHSVValues addObject:[[[rData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"colorMin"]];
        [maxHSVValues addObject:[[[rData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"colorMax"]];
    }
    [colorButton setTitle:@"Black" forState:UIControlStateNormal];
    codes = [[NSArray alloc] initWithObjects:@"Black",@"Brown",@"Red",@"Orange",@"Yellow",@"Green",@"Blue",@"Violet",@"Gray",@"White",nil];
    NSLog(@"Settings Loaded");
    hmin = [[[minHSVValues objectAtIndex:0] objectAtIndex:0] doubleValue];
    smin = [[[minHSVValues objectAtIndex:0] objectAtIndex:1] doubleValue];
    vmin = [[[minHSVValues objectAtIndex:0] objectAtIndex:2] doubleValue];
    hmax = [[[maxHSVValues objectAtIndex:0] objectAtIndex:0] doubleValue];
    smax = [[[maxHSVValues objectAtIndex:0] objectAtIndex:1] doubleValue];
    vmax = [[[maxHSVValues objectAtIndex:0] objectAtIndex:2] doubleValue];
    hMin.value = hmin;
    sMin.value = smin;
    vMin.value = vmin;
    hMax.value = hmax;
    sMax.value = smax;
    vMax.value = vmax;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if([[appLib retriveSettings:@"OPEN_CV_ENABLED"] isEqualToString:@"YES"])
    {
        NSLog(@"Stopping Camera");
        [videoCamera stop];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)act
{
    hmin = hMin.value;
    smin = sMin.value;
    vmin = vMin.value;
    hmax = hMax.value;
    smax = sMax.value;
    vmax = vMax.value;
}


#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus

-(void)processImage:(Mat &)image
{
    Mat hsvImg,imgThresholdr;
    GaussianBlur( image, image, cv::Size( 7, 7), 0, 0 );
    cvtColor(image, hsvImg, COLOR_BGR2HSV);
    inRange(hsvImg,Vec3b(hmin,smin,vmin),Vec3b(hmax,vmax,smax), imgThresholdr);
    imgThresholdr = imgprocess(imgThresholdr);
    image = imgThresholdr;
}

Mat imgprocess(Mat image)
{
    Mat temp;
    temp = image;
    Mat structuringElement = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3));
    erode(temp, temp, structuringElement);
    dilate( temp, temp, structuringElement );
    cv::morphologyEx( temp, temp, MORPH_CLOSE, structuringElement );
    return temp;
}

#endif


-(void)saveData
{
    [[minHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.1lf",hmin] atIndexedSubscript:0];
    [[minHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.1lf",smin] atIndexedSubscript:1];
    [[minHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.1lf",vmin] atIndexedSubscript:2];
    [[maxHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.11lf",hmax] atIndexedSubscript:0];
    [[maxHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.1lf",smax] atIndexedSubscript:1];
    [[maxHSVValues objectAtIndex:colorCode] setObject:[NSString stringWithFormat:@"%.1lf",vmax] atIndexedSubscript:2];
    NSMutableDictionary *dictForColor = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrayForColor = [[NSMutableArray alloc] init];
    arrayForColor = [rData objectForKey:@"BandOneTwo"];
    dictForColor = [arrayForColor objectAtIndex:colorCode ];
    [dictForColor setObject:[minHSVValues objectAtIndex:colorCode] forKeyedSubscript:@"colorMin"];
    [dictForColor setObject:[maxHSVValues objectAtIndex:colorCode] forKeyedSubscript:@"colorMax"];
    [arrayForColor setObject:dictForColor atIndexedSubscript:colorCode];
    [rData setObject:arrayForColor forKey:@"BandOneTwo"];
    [appLib saveJSONDataToFile:rData with:@"Resistor.plist"];
    NSLog(@"Settings Saved");
}


- (IBAction)buttonPressed:(id)sender
{
    [self saveData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeColor:(id)sender
{
    [self saveData];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change Settings For" message:@"Select Color to Tweak" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Black",@"Brown",@"Red",@"Orange",@"Yellow",@"Green",@"Blue",@"Violet",@"Gray",@"White", nil];
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        
    }
    else
    {
        colorCode = buttonIndex - 1;
        [colorButton setTitle:[codes objectAtIndex:colorCode] forState:UIControlStateNormal];
        hmin = [[[minHSVValues objectAtIndex:colorCode] objectAtIndex:0] doubleValue];
        smin = [[[minHSVValues objectAtIndex:colorCode] objectAtIndex:1] doubleValue];
        vmin = [[[minHSVValues objectAtIndex:colorCode] objectAtIndex:2] doubleValue];
        hmax = [[[maxHSVValues objectAtIndex:colorCode] objectAtIndex:0] doubleValue];
        smax = [[[maxHSVValues objectAtIndex:colorCode] objectAtIndex:1] doubleValue];
        vmax = [[[maxHSVValues objectAtIndex:colorCode] objectAtIndex:2] doubleValue];
        hMin.value = hmin;
        sMin.value = smin;
        vMin.value = vmin;
        hMax.value = hmax;
        sMax.value = smax;
        vMax.value = vmax;
    }
}




@end
