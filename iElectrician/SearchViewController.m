//
//  SearchViewController.m
//  iElectrician
//
//  Created by Chiraag Bangera on 5/24/15.
//  Copyright (c) 2015 Chiraag Bangera. All rights reserved.
//

#import "SearchViewController.h"
#import "WebViewController.h"
#import "AppLib.h"

@interface SearchViewController ()

@end

@implementation SearchViewController
{
    AppLib *appLib;
    NSArray *files;
    UITextField *searchField;
    NSString *searchFieldValue;
    NSString *URL;
    int m;
}
@synthesize FilesView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    appLib = [[AppLib alloc] init];
    URL = @"http://search.datasheetcatalog.net/key/";
    FilesView.delegate = self;
    FilesView.dataSource = self;
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchField.delegate = self;
    searchField.backgroundColor = [UIColor grayColor];
    searchField.textAlignment = NSTextAlignmentCenter;
    searchField.font = [UIFont fontWithName:@"Arial" size:20];
    searchField.placeholder = @"Search by Part# / Description";
    searchField.returnKeyType = UIReturnKeySearch;
    self.FilesView.tableHeaderView = searchField;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UILabel *lab;
    self.FilesView.contentOffset = CGPointMake(0, searchField.frame.size.height);
    files = [[NSArray alloc] init];
    files = [appLib listFileAtPath:[NSString stringWithFormat:@"%@/datasheets/",[appLib documentsPath]]];
    [lab removeFromSuperview];
    if([files count] <= 0 )
    {
        lab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.width/1.5 , self.view.frame.size.width, 200)];
        lab.text = @"No Cached Data";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont fontWithName:@"Arial" size:40];
        lab.numberOfLines = 3;
        [self.view addSubview:lab];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *folderPath = [NSString stringWithFormat:@"%@/datasheets",[appLib documentsPath]];
    files = [appLib listFileAtPath:folderPath];
    return [files count] ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    UILabel *file = (UILabel *)[cell viewWithTag:10];
    file.text = [files objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    URL = [NSString stringWithFormat:@"%@/datasheets/%@",[appLib documentsPath],[files objectAtIndex:indexPath.row]];
    m = 1;
    [self performSegueWithIdentifier:@"search" sender:nil];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    searchFieldValue = textField.text;
    URL = [NSString stringWithFormat:@"%@%@",URL,searchFieldValue];
    [self performSegueWithIdentifier:@"search" sender:nil];
    m = 0;
    return NO;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WebViewController *wvc = (WebViewController *)[segue destinationViewController];
    wvc.mode = m;
    wvc.URL = URL;
}



@end
