//
//  RgListView.h
//  iRf
//
//  Created by pro on 11-7-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RgListSearchView.h"
#import "KDGoalBar.h"
#import "RgView.h"
#import "LeveyPopListView.h"

@interface RgListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,RgListSearchViewDelegate,
RgViewDelegate,
UIActionSheetDelegate,LeveyPopListViewDelegate>
{
    NSMutableArray *menuList;
    NSArray *objs;
    
    BOOL canReload;
    
    UIBarButtonItem *refreshButtonItem;
    
    NSDictionary *searchObj;
    
    UIAlertView *goalBarView;
    KDGoalBar *goalBar;
    
    int notDoRgCount;
    int doneDoRgCoount;
    
    int titleFontSize;
    int detailFontSize;
    
    UIButton *titleBtn;
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) NSArray *objs;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;

@property (nonatomic, strong) NSDictionary *searchObj;

@property (nonatomic, strong) UIAlertView *goalBarView;
@property (nonatomic, strong) KDGoalBar *goalBar;

@property (nonatomic, strong) UIButton *titleBtn;

- (id)initWithStyle:(UITableViewStyle)style objs:(NSArray*)_arrays;
- (IBAction) setSearchJson:(id)sender;
- (void)searchCallBack:(NSDictionary *)_fields;
@end
