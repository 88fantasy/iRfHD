//
//  RgListSearchView.h
//  iRf
//
//  Created by user on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RgListSearchViewDelegate <NSObject>
//回调函数 
-(void)searchCallBack:(NSDictionary *)_fields; 
@end

@interface RgListSearchView : UIViewController
<UITextFieldDelegate>
{
    UIScrollView *scrollView;
    UITextField *goodsname;
    UITextField *prodarea;
    UITextField *lotno;
    UITextField *invno;
    UITextField *startdate;
    UITextField *enddate;
    UITextField *goodspy;
    UITextField *vender;
    
    UISegmentedControl *rgflag;
    UISwitch *fuzzy;
    
    UIBarButtonItem *finButton;
    UITextField *tmp;
    
    __weak id<RgListSearchViewDelegate> rgListSearchViewDelegate;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *goodsname;
@property (nonatomic, strong) IBOutlet UITextField *prodarea;
@property (nonatomic, strong) IBOutlet UITextField *lotno;
@property (nonatomic, strong) IBOutlet UITextField *invno;
@property (nonatomic, strong) IBOutlet UITextField *startdate;
@property (nonatomic, strong) IBOutlet UITextField *enddate;
@property (nonatomic, strong) IBOutlet UITextField *goodspy;
@property (nonatomic, strong) IBOutlet UITextField *vender;
@property (nonatomic, strong) IBOutlet UISegmentedControl *rgflag;
@property (nonatomic, strong) IBOutlet UISwitch *fuzzy;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *finButton;
@property (nonatomic, strong) IBOutlet UITextField *tmp;
@property (nonatomic, weak) id<RgListSearchViewDelegate>  rgListSearchViewDelegate;


- (IBAction) finSearch:(id)sender;
@end
