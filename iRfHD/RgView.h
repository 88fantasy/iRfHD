//
//  RgView.h
//  iRf
//
//  Created by pro on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDGoalBar.h"

@protocol RgViewDelegate;


@interface RgView : UIViewController
<ZBarReaderDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
    UIScrollView *scrollView;
    UITextField *invno;
    UITextField *goodsname;
    UITextField *goodstype;
    UITextField *factoryname;
    UITextField *goodsprice;
    UITextField *goodsunit;
    UITextField *lotno;
    UITextField *packsize;
    UITextField *validto;
    UITextField *orgrow;
    UITextField *goodsqty;
    UITextField *rgqty;
    UITextField *locno;
    UITextField *socompanyname;
    UITextField *vendername;
    NSString *spdid;
    NSDictionary *values;
    
    BOOL readOnlyFlag;
    __weak id<RgViewDelegate> delegate;
    
    UIAlertView *goalBarView;
    KDGoalBar *goalBar;
    
    int notDoRgCount;
    int doneDoRgCoount;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *invno;
@property (nonatomic, strong) IBOutlet UITextField *goodsname;
@property (nonatomic, strong) IBOutlet UITextField *goodstype;
@property (nonatomic, strong) IBOutlet UITextField *factoryname;
@property (nonatomic, strong) IBOutlet UITextField *goodsprice;
@property (nonatomic, strong) IBOutlet UITextField *goodsunit;
@property (nonatomic, strong) IBOutlet UITextField *lotno;
@property (nonatomic, strong) IBOutlet UITextField *packsize;
@property (nonatomic, strong) IBOutlet UITextField *validto;
@property (nonatomic, strong) IBOutlet UITextField *orgrow;
@property (nonatomic, strong) IBOutlet UITextField *goodsqty;
@property (nonatomic, strong) IBOutlet UITextField *rgqty;
@property (nonatomic, strong) IBOutlet UITextField *locno;
@property (nonatomic, strong) IBOutlet UITextField *socompanyname;
@property (nonatomic, strong) IBOutlet UITextField *vendername;
@property (nonatomic, strong) IBOutlet NSString *spdid;
@property (nonatomic, strong) IBOutlet NSDictionary *values;
@property (nonatomic,weak) id<RgViewDelegate>  delegate;

@property (nonatomic, strong) UIAlertView *goalBarView;
@property (nonatomic, strong) KDGoalBar *goalBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj ;

- (IBAction) scrollToBottom:(id)sender;

- (IBAction) scanButtonTapped;
@end


@protocol RgViewDelegate <NSObject>

@optional
-(void) rgViewDidConfirm:(RgView*)rgview ;
@end