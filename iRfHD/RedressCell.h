//
//  RedressCell.h
//  iRfHD
//
//  Created by pro on 13-3-28.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedressCell : UITableViewCell
<UITextFieldDelegate>
{
    UILabel *goodsname;
    UITextField *goodsqty;
    UILabel *goodsunit;
    NSMutableDictionary *cellData;
}

@property (nonatomic,strong) IBOutlet UILabel *goodsname;
@property (nonatomic,strong) IBOutlet UITextField *goodsqty;
@property (nonatomic,strong) IBOutlet UILabel *goodsunit;
@property (strong) NSMutableDictionary *cellData;

-(IBAction)qtyup:(UIButton*)sender;
-(IBAction)qtydown:(UIButton*)sender;
@end
