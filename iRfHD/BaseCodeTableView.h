//
//  BaseCodeTableView.h
//  iRf
//
//  Created by xian weijian on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseCodeTableViewDelegate 
//回调函数 
-(void)DidCodeInput:(NSArray *)codes; 
@end

@interface BaseCodeTableView : UITableViewController
<UITextFieldDelegate,ZBarReaderDelegate>
{
    UITextField *codeinput;
    NSMutableArray *codeList;
    NSInteger codenum;
    id<BaseCodeTableViewDelegate> baseCodeTableViewDelegate;
}

@property (nonatomic,strong) IBOutlet UITextField *codeinput;
@property (nonatomic,strong) NSMutableArray *codeList;
@property (nonatomic) NSInteger codenum;
@property (nonatomic,strong) id<BaseCodeTableViewDelegate>  baseCodeTableViewDelegate;

@end
