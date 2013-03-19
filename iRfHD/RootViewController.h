//
//  RootViewController.h
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "KDGoalBar.h"

static bool syncflag = NO;
#pragma unused ( syncflag )

@interface RootViewController : UITableViewController
<UIAlertViewDelegate,NSURLConnectionDataDelegate>
{
    NSMutableArray *menuList;
	UITextField *userfield;
	UITextField *pwdfield;
    
    UIAlertView *goalBarView;
    KDGoalBar *goalBar;
    
    int notDoRgCount;
    int doneDoRgCoount;
}

@property (nonatomic, retain) NSMutableArray *menuList;
@property (nonatomic, retain) UITextField *userfield;
@property (nonatomic, retain) UITextField *pwdfield;

@property (nonatomic, retain) UIAlertView *goalBarView;
@property (nonatomic, retain) KDGoalBar *goalBar;

+ (bool) isSync ;
@end
