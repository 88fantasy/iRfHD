//
//  StockAdjustView.h
//  iRf
//
//  Created by xian weijian on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCodeTableView.h"

@interface StockAdjustView : UIViewController
// ADD: delegate protocol
< ZBarReaderDelegate,UITextFieldDelegate,NSXMLParserDelegate,UITableViewDelegate,UITableViewDataSource,BaseCodeTableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate >
{
    UITextField *orglocno;
    UITextField *tolocno;
    UITextField *goodsqty;
	UISwitch *orgswitch;
    UISwitch *toswitch;
    UITableView *stocktableview;
    uint txtindex;
    UIScrollView *scrollView;
    NSMutableArray *stockList;
    NSArray *baseCodeList;
    NSArray *venders;
    UIPickerView *venderPickerView;
    NSDictionary *vender;
    NSString *defaultflag;
    NSString *nohouseflag;
}

@property (nonatomic, strong) IBOutlet UITextField *orglocno;
@property (nonatomic, strong) IBOutlet UITextField *tolocno;
@property (nonatomic, strong) IBOutlet UITextField *goodsqty;
@property (nonatomic, strong) IBOutlet UISwitch *orgswitch;
@property (nonatomic, strong) IBOutlet UISwitch *toswitch;
@property (nonatomic, strong) IBOutlet UITableView *stocktableview;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *stockList;
@property (nonatomic, strong) NSArray *baseCodeList;
@property (nonatomic, strong) NSArray *venders;
@property (nonatomic, strong) UIPickerView *venderPickerView;
@property (nonatomic, strong) NSDictionary *vender;
@property (nonatomic, strong) NSString *defaultflag;
@property (nonatomic, strong) NSString *nohouseflag;

- (IBAction) orgButtonTapped;
- (IBAction) toButtonTapped;
- (IBAction) scrollToBottom:(id)sender;
- (IBAction) getStockList;
-(void)DidCodeInput:(NSDictionary *)codes;
@end
