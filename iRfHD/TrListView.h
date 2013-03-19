//
//  NtrListView.h
//  iRf
//
//  Created by user on 11-8-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeveyPopListView.h"

typedef NS_ENUM (NSInteger,TrListTitleSeg){
	TrListTitleSegAll = 0,  //全部
	TrListTitleSegNoCusid = 1, //无客户码
	TrListTitleSegNoLocno = 2,  //无默认货位
    TrListTitleSegNoBasecode = 3,  //无基本码

};

@interface TrListView : UITableViewController
<UISearchDisplayDelegate, UISearchBarDelegate,LeveyPopListViewDelegate>
{
    NSMutableArray *menuList;
    
    UIBarButtonItem *refreshButtonItem;
    
    
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    UISearchDisplayController *seachDispalyController;
    UITableView *tablelistView;
    
    NSInteger   titleSegmentIndex;
    NSArray *titleArray;
    UIButton *titleBtn;
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) UIBarButtonItem *refreshButtonItem;

@property (nonatomic, strong) NSMutableArray *filteredListContent;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic) NSInteger titleSegmentIndex;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIButton *titleBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


@end
