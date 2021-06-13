//
//  SearchViewController.h
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *FilesView;

@end
