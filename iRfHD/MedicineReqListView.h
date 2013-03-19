//
//  MedicineReqListView.h
//  iRf
//
//  Created by xian weijian on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicineReqListView : UITableViewController
<UIAlertViewDelegate>
{
    NSMutableArray *dataList;
    
}

@property (nonatomic, strong) NSMutableArray *dataList;

@end
