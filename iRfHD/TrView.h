//
//  TrView.h
//  iRf
//
//  Created by user on 11-8-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrView : UIViewController
<UITextFieldDelegate,ZBarReaderDelegate>
{
    UIScrollView *scrollView;
    UITextField *ugoodsid;
    UITextField *goodsname;
    UITextField *goodstype;
    UITextField *tradename;
    UITextField *factno;
    UITextField *goodsunit;
    UITextField *cusgdsid;
    UITextField *multi;
    UITextField *companyname;
    UIButton *locbtn;
    UITextField *locno;
    UIButton *basebtn;
    UITextField *basecode;
    NSDictionary *values;
    
    NSUInteger scanType;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *ugoodsid;
@property (nonatomic, strong) IBOutlet UITextField *goodsname;
@property (nonatomic, strong) IBOutlet UITextField *goodstype;
@property (nonatomic, strong) IBOutlet UITextField *tradename;
@property (nonatomic, strong) IBOutlet UITextField *factno;
@property (nonatomic, strong) IBOutlet UITextField *goodsunit;
@property (nonatomic, strong) IBOutlet UITextField *cusgdsid;
@property (nonatomic, strong) IBOutlet UITextField *multi;
@property (nonatomic, strong) IBOutlet UITextField *companyname;
@property (nonatomic, strong) IBOutlet UIButton *locbtn;
@property (nonatomic, strong) IBOutlet UITextField *locno;
@property (nonatomic, strong) IBOutlet UIButton *basebtn;
@property (nonatomic, strong) IBOutlet UITextField *basecode;

@property (nonatomic, strong) IBOutlet NSDictionary *values;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj ;

- (IBAction) scanButtonTapped:(UIButton *)btn;

@end
