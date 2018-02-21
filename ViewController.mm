//
//  ViewController.m
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "ViewController.h"
#import "ConfigureViewController.h"
#import "AppLib.h"

@interface ViewController ()

@end

using namespace cv;
using namespace std;

@implementation ViewController
{
    AppLib *appLib;
    NSMutableDictionary *resistorData;
    NSString *resistance;
    UITapGestureRecognizer *newTap;
    UIPickerView *resPicker;
    UIView *rpickerView;
    UIAlertController * searchActionSheet;
    NSMutableArray *minHSVValues;
    NSMutableArray *maxHSVValues;
    NSMutableArray *colorNames;
    NSMutableArray *colorValues;
    bool pickerVisible;
    int colorCode;
}


@synthesize resistanceLabel,bandOne,bandTwo,bandThree,bandFour,imageView;
@synthesize videoCamera,tapZone,resistor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    appLib = [[AppLib alloc] init];
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettings)];
    newTap.numberOfTapsRequired = 2;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPicker:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.tapZone addGestureRecognizer:tapGesture];
    [imageView setUserInteractionEnabled:YES];
    [imageView addGestureRecognizer:newTap];
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [appLib checkAndCopy:@"Resistor.plist"];
    resistorData = [appLib loadJSONDataFromFile:@"Resistor.plist"];
    minHSVValues = [[NSMutableArray alloc] init];
    maxHSVValues = [[NSMutableArray alloc] init];
    colorNames = [[NSMutableArray alloc] init];
    colorValues = [[NSMutableArray alloc] init];
    for(int i=0;i<[[resistorData objectForKey:@"BandOneTwo"] count];i++)
    {
        [minHSVValues addObject:[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"colorMin"]];
        [maxHSVValues addObject:[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"colorMax"]];
        [colorNames addObject:[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"name"]];
        [colorValues addObject:[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:i] objectForKey:@"colorValue"]];
    }
    [resPicker selectRow:1 inComponent:0 animated:YES];
    if([[appLib retriveSettings:@"OPEN_CV_ENABLED"] isEqualToString:@"YES"] && !pickerVisible)
    {
        NSLog(@"Starting Camera");
        [videoCamera start];
    }
    else
    {
        NSLog(@"Camera Disabled");
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if(videoCamera)
    [videoCamera stop];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showPicker:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [videoCamera stop];
        pickerVisible = true;
        resPicker=[[UIPickerView alloc]  initWithFrame:CGRectMake(0,0, self.view.frame.size.width, 100)];
        resPicker.showsSelectionIndicator=YES;
        resPicker.backgroundColor = [UIColor whiteColor];
        resPicker.delegate=self;
        resPicker.dataSource=self;
        resPicker.userInteractionEnabled = YES;
        resPicker.showsSelectionIndicator = YES;
        resPicker.multipleTouchEnabled = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:resPicker];
        UIToolbar *controlToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, rpickerView.bounds.size.width, 55)];
        controlToolbar.barStyle = UIBarStyleBlackTranslucent;
        [controlToolbar sizeToFit];
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(DoneClicked)];
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:@selector(cancelClicked)];

        [controlToolbar setItems:[NSArray arrayWithObjects:spacer, cancelButton, setButton, nil] animated:NO];
        [resPicker setFrame:CGRectMake(0, controlToolbar.frame.size.height - 15, resPicker.frame.size.width, resPicker.frame.size.height)];
        
        if (!rpickerView)
        {
            rpickerView = [[UIView alloc] initWithFrame:resPicker.frame];
        } else
        {
            [rpickerView setHidden:NO];
        }
        
        
        CGFloat pickerViewYpositionHidden = self.view.frame.size.height + rpickerView.frame.size.height;
        
        CGFloat pickerViewYposition = self.view.frame.size.height - rpickerView.frame.size.height;
        
        [rpickerView setFrame:CGRectMake(rpickerView.frame.origin.x,
                                        pickerViewYpositionHidden,
                                        rpickerView.frame.size.width,
                                        rpickerView.frame.size.height)];
        [rpickerView setBackgroundColor:[UIColor whiteColor]];
        [rpickerView addSubview:controlToolbar];
        [rpickerView addSubview:resPicker];
        [resPicker setHidden:NO];
        [self.view addSubview:rpickerView];

        
        [UIView animateWithDuration:0.5f
                         animations:^{
                            [resistor setFrame:CGRectMake(resistor.frame.origin.x,0, resistor.frame.size.width, resistor.frame.size.height)];
                             [rpickerView setFrame:CGRectMake(rpickerView.frame.origin.x,pickerViewYposition,rpickerView.frame.size.width,rpickerView.frame.size.height)];
                         }
                         completion:nil];
        
    }
}



-(void)DoneClicked
{
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + rpickerView.frame.size.height;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [rpickerView setFrame:CGRectMake(rpickerView.frame.origin.x,
                                                         pickerViewYpositionHidden,
                                                         rpickerView.frame.size.width,
                                                         rpickerView.frame.size.height)];
                     }
                     completion:nil];
    [videoCamera start];
}

-(void)cancelClicked
{
    CGFloat pickerViewYpositionHidden = self.view.frame.size.height + rpickerView.frame.size.height;
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [rpickerView setFrame:CGRectMake(rpickerView.frame.origin.x,
                                                          pickerViewYpositionHidden,
                                                          rpickerView.frame.size.width,
                                                          rpickerView.frame.size.height)];
                     }
                     completion:nil];
    [videoCamera start];
}





- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int t = 0;
    switch (component)
    {
        case 0:
        {
            t = [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:row] objectForKey:@"value"] intValue];
            t = t*10 + [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"value"] intValue];
            t = t*pow(10,[[[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"value"] intValue]);
             resistance = [NSString stringWithFormat:@"%@\u03A9  %@",[appLib abbreviateNumber:t],[[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"value"]];
            NSString *cCode1 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:row] objectForKey:@"colorValue"];
            NSString *cCode2 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"colorValue"];
            NSString *cCode3 = [[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"colorValue"];
            NSString *cCode4 = [[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"colorValue"];
            bandOne.backgroundColor = [appLib colorDecoder:cCode1];
            bandTwo.backgroundColor = [appLib colorDecoder:cCode2];
            bandThree.backgroundColor = [appLib colorDecoder:cCode3];
            bandFour.backgroundColor = [appLib colorDecoder:cCode4];
        }break;
        case  1:
        {
            t = [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"value"] intValue];
            t = t*10 + [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:row] objectForKey:@"value"] intValue];
            t = t*pow(10,[[[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"value"] intValue]);
            resistance = [NSString stringWithFormat:@"%@\u03A9 %@",[appLib abbreviateNumber:t],[[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"value"]];
            NSString *cCode1 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"colorValue"];
            NSString *cCode2 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:row] objectForKey:@"colorValue"];
            NSString *cCode3 = [[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"colorValue"];
            NSString *cCode4 = [[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"colorValue"];
            bandOne.backgroundColor = [appLib colorDecoder:cCode1];
            bandTwo.backgroundColor = [appLib colorDecoder:cCode2];
            bandThree.backgroundColor = [appLib colorDecoder:cCode3];
            bandFour.backgroundColor = [appLib colorDecoder:cCode4];
        }break;
        case 2:
        {
            t = [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"value"] intValue];
             t = t*10 + [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"value"] intValue];
            t = t*pow(10,[[[[resistorData objectForKey:@"BandThree"] objectAtIndex:row] objectForKey:@"value"] intValue]);
            resistance = [NSString stringWithFormat:@"%@\u03A9 %@",[appLib abbreviateNumber:t],[[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"value"]];
            NSString *cCode1 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"colorValue"];
            NSString *cCode2 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"colorValue"];
            NSString *cCode3 = [[[resistorData objectForKey:@"BandThree"] objectAtIndex:row] objectForKey:@"colorValue"];
            NSString *cCode4 = [[[resistorData objectForKey:@"BandFour"] objectAtIndex:[pickerView selectedRowInComponent:3]] objectForKey:@"colorValue"];
            bandOne.backgroundColor = [appLib colorDecoder:cCode1];
            bandTwo.backgroundColor = [appLib colorDecoder:cCode2];
            bandThree.backgroundColor = [appLib colorDecoder:cCode3];
            bandFour.backgroundColor = [appLib colorDecoder:cCode4];
        }break;
        case 3:
        {
            t = [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"value"] intValue];
            t = t*10 + [[[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"value"] intValue];
            t = t*pow(10,[[[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"value"] intValue]);
            resistance = [NSString stringWithFormat:@"%@\u03A9 %@",[appLib abbreviateNumber:t],[[[resistorData objectForKey:@"BandFour"] objectAtIndex:row] objectForKey:@"value"]];
            NSString *cCode1 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:0]] objectForKey:@"colorValue"];
            NSString *cCode2 = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:[pickerView selectedRowInComponent:1]] objectForKey:@"colorValue"];
            NSString *cCode3 = [[[resistorData objectForKey:@"BandThree"] objectAtIndex:[pickerView selectedRowInComponent:2]] objectForKey:@"colorValue"];
            NSString *cCode4 = [[[resistorData objectForKey:@"BandFour"] objectAtIndex:row] objectForKey:@"colorValue"];
            bandOne.backgroundColor = [appLib colorDecoder:cCode1];
            bandTwo.backgroundColor = [appLib colorDecoder:cCode2];
            bandThree.backgroundColor = [appLib colorDecoder:cCode3];
            bandFour.backgroundColor = [appLib colorDecoder:cCode4];
        }break;
    }
    resistanceLabel.text = resistance;
}

-(UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"Arial" size:20];
    label.textAlignment = NSTextAlignmentCenter;
    switch (component)
    {
        case 0:
        case  1:
        {
            label.text = [[[resistorData objectForKey:@"BandOneTwo"] objectAtIndex:row] objectForKey:@"name"];
        }break;
        case 2:
        {
            label.text = [[[resistorData objectForKey:@"BandThree"] objectAtIndex:row] objectForKey:@"name"];
        }break;
        case 3:
        {
            label.text = [[[resistorData objectForKey:@"BandFour"] objectAtIndex:row] objectForKey:@"name"];
        }break;
            
        default:
            break;
    }
    return label;
}





// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [resistorData count] + 1 ;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0 || component == 1)
    {
        return [[resistorData objectForKey:@"BandOneTwo"]  count];
    }
    else if( component == 2)
    {
        return [[resistorData objectForKey:@"BandThree"]  count];
    }
    else if(component == 3)
        return [[resistorData objectForKey:@"BandFour"]  count];
    else
        return 0;
}



// OpenCV Stuff




-(void)showSettings
{
    [self performSegueWithIdentifier:@"cvsettings" sender:nil];
}


#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus

-(Scalar) convert:(NSArray *)array andIndex:(int)index
{
    NSArray *row = [[NSArray alloc] initWithArray:[array objectAtIndex:index]];
    return Scalar([row[0] doubleValue],[row[1] doubleValue],[row[2] doubleValue]);
}

-(Scalar)splitColors:(NSString *)colorString
{
    NSArray *array = [colorString componentsSeparatedByString:@","];
    return Scalar([array[2] doubleValue],[array[1] doubleValue],[array[0] doubleValue]);
}


void set_label(cv::Mat& im, cv::Rect r, const std::string label,Scalar color)
{
    int fontface = cv::FONT_HERSHEY_COMPLEX_SMALL;
    double scale = 0.5;
    int thickness = 1;
    int baseline = 0;
    cv::Size text = cv::getTextSize(label, fontface, scale, thickness, &baseline);
    cv::Point pt(r.x + (r.width-text.width)/2, r.y + (r.height+text.height)/2);
    cv::putText(im, label, pt, fontface, scale, color, thickness, 8);
}

-(void)processImage:(Mat &)image
{
    Mat imgCopy;
    Mat imgHSV;
    Mat imgThresholded[10];
    /*int imWidth = image.cols;
    int imHeight = image.rows;
    int reductionFactor = 1;
    resize(image, image, cv::Size(imWidth/reductionFactor,imHeight/reductionFactor));*/
    imgCopy = image;
    GaussianBlur( imgCopy, imgCopy, cv::Size( 3, 3), 0, 0 );
    cvtColor(imgCopy, imgHSV, COLOR_BGR2HSV);
    for(int k=0;k<10;k++)
    {
        inRange(imgHSV, [self convert:minHSVValues andIndex:k], [self convert:maxHSVValues andIndex:k],imgThresholded[k]);
        imgThresholded[k] = imgProcess(imgThresholded[k]);
        image = drawName(image, imgThresholded[k],[[colorNames objectAtIndex:k] UTF8String],[self splitColors:[colorValues objectAtIndex:k]]);
        //image.setTo([self splitColors:[colorValues objectAtIndex:k]],imgThresholded[k]);
    }
}

Mat imgProcess(Mat image)
{
    Mat temp;
    temp = image;
    Mat structuringElement = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    erode(temp, temp, structuringElement);
    dilate( temp, temp, structuringElement );
    cv::morphologyEx( temp, temp, MORPH_CLOSE, structuringElement );
    return temp;
}


Mat drawName(Mat Originalimage,Mat imageToFind ,String name,Scalar color)
{
    Canny(imageToFind, imageToFind, 10, 20);
    std::vector< std::vector<cv::Point> > Countour;
    findContours(imageToFind, Countour, RETR_EXTERNAL, CHAIN_APPROX_NONE);
    cv::Rect rect;
    for (size_t i=0; i<Countour.size(); i++)
    {
        for (size_t j = 0; j < Countour[i].size(); j++)
        {
            double a = contourArea(Countour[i]);
            if(a > 300)
            {
                rect=boundingRect(Countour[i]);
                set_label(Originalimage, rect, name,color);
                rectangle(Originalimage, rect,  color,1, 8,0);
            }
        }
    }
    return Originalimage;
}




#endif




@end
