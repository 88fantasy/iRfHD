//
//  RgGroupListView.h
//  iRf
//
//  Created by pro on 12-11-30.
//
//

#import <UIKit/UIKit.h>
#import "RgListSearchView.h"

@interface RgGroupListView : UITableViewController
<UITableViewDelegate,UITableViewDataSource,RgListSearchViewDelegate>
{
    NSMutableArray *menuList;
    NSArray *objs;
    
    NSDictionary *searchObj;
    
    int titleFontSize;
    int detailFontSize;
}

@property (nonatomic, strong) NSMutableArray *menuList;
@property (nonatomic, strong) NSArray *objs;
@property (nonatomic, strong) NSDictionary *searchObj;


- (void)searchCallBack:(NSDictionary *)_fields;
@end
