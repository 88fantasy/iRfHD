//
//  RedressView.h
//  iRfHD
//
//  Created by pro on 13-3-25.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConditionMakerController.h"
#import "DataSetRequest.h"

@interface RedressView : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UIPopoverControllerDelegate,
UIPageViewControllerDataSource,
UIPageViewControllerDelegate,
ConditionMakerControllerDelegate,
ZBarReaderDelegate,
DataSetRequestDelegate
>
{
    UITableView *inTable;
    NSMutableArray *inDataList;
    
    UITableView *outTable;
    NSMutableArray *outDataList;
    
    UITableView *soTable;
    UISearchBar *inSearch;
    DataSetRequest *soDataSetRequest;
    
    UIPopoverController *searchPopOver;
    UIPageViewController *goodsSns;
    ConditionMakerController *conmaker;
    UITableViewController *goodsTable;
    DataSetRequest *goodsDataSetRequest;
}

@property (nonatomic,strong) IBOutlet UITableView *inTable;
@property (nonatomic,strong) IBOutlet UITableView *outTable;
@property (nonatomic,strong) IBOutlet UITableView *soTable;
@property (nonatomic,strong) IBOutlet UISearchBar *inSearch;

@property (strong) UIPopoverController *searchPopOver;
@property (strong) UIPageViewController *goodsSns;
@property (strong) ConditionMakerController *conmaker;
@property (strong) UITableViewController *goodsTable;

-(IBAction)showSearchPopOver:(UIBarButtonItem*)sender;
-(IBAction)scanCode:(id)sender;

@end
