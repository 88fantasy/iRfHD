//
//  MedicineReqCell.h
//  iRf
//
//  Created by xian weijian on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicineReqCell : UITableViewCell
<UITextFieldDelegate>
{
    UILabel *goodsname;
    UILabel *goodstype;
    UILabel *locno;
    UILabel *lotno;
    UILabel *goodsqty;
    UILabel *houserealqty;
    UITextField *opqty;
    NSMutableDictionary *data;
}

@property (nonatomic,strong) IBOutlet UILabel *goodsname;
@property (nonatomic,strong) IBOutlet UILabel *goodstype;
@property (nonatomic,strong) IBOutlet UILabel *locno;
@property (nonatomic,strong) IBOutlet UILabel *lotno;
@property (nonatomic,strong) IBOutlet UILabel *goodsqty;
@property (nonatomic,strong) IBOutlet UILabel *houserealqty;
@property (nonatomic,strong) IBOutlet UITextField *opqty;
@property (nonatomic,strong) NSMutableDictionary *data;

@end
