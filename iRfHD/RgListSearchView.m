//
//  RgListSearchView.m
//  iRf
//
//  Created by user on 11-9-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RgListSearchView.h"


@implementation RgListSearchView

@synthesize scrollView,goodsname,prodarea,lotno,invno,startdate,enddate,goodspy,vender,rgflag;
@synthesize finButton,tmp;
@synthesize rgListSearchViewDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"查询条件";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = self.finButton;
   
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.startdate || textField == self.enddate) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        
        self.tmp = textField;
        
        NSDate *date = [NSDate date];
        
        if (!([textField.text isEqualToString:@""] || textField.text == nil )) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            date = [formatter dateFromString:textField.text];
        }
        
        [datePicker setDate:date animated:YES];
        
        datePicker.datePickerMode = UIDatePickerModeDate;
        
        [datePicker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
        //UITextField的inputView属性代替标准的系统键盘
        
        textField.inputView = datePicker;//inputView相当于给弹出datePicker控件的动画的功能;定制键盘来使用datePicker,弹出datePicker与弹出键盘方式一样
        // Configure the view for the selected state
        if (textField.inputAccessoryView == nil) {
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.barStyle = UIBarStyleBlackTranslucent;
            numberToolbar.items = [NSArray arrayWithObjects:
                                   [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(canceldate)],
                                   [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                   [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(applydate )],
                                   nil];
            [numberToolbar sizeToFit];
            textField.inputAccessoryView = numberToolbar;
        }
        
    }
    
	return YES;
}

- (void) canceldate
{
    self.tmp.text = @"";
    [self applydate];
}

- (void) applydate
{
    [self.tmp resignFirstResponder];
}



- (IBAction) finSearch:(id)sender{
    NSMutableDictionary *searchFields = [NSMutableDictionary dictionary];
    if (![self.goodspy.text isEqualToString:@""] && self.goodspy.text != nil) {
        [searchFields setObject:[self.goodspy.text stringByAppendingString:@"%"] forKey:@"goodspy"];
    }
    if (![self.goodsname.text isEqualToString:@""] && self.goodsname.text != nil) {
        [searchFields setObject:[self.goodsname.text stringByAppendingString:@"%"] forKey:@"goodsname"];
    }
    
    if (![self.prodarea.text isEqualToString:@""] && self.prodarea.text != nil) {
       [searchFields setObject:[self.prodarea.text stringByAppendingString:@"%"] forKey:@"prodarea"];
    }
    
    if (![self.vender.text isEqualToString:@""] && self.vender.text != nil) {
        [searchFields setObject:[self.vender.text stringByAppendingString:@"%"] forKey:@"uvender"];
    }
    
    if (![self.lotno.text isEqualToString:@""] && self.lotno.text != nil) {
        [searchFields setObject:self.lotno.text forKey:@"lotno"];
    }
    
    if (![self.invno.text isEqualToString:@""] && self.invno.text != nil) {
        [searchFields setObject:self.invno.text forKey:@"invno"];
    }
    
    if (![self.startdate.text isEqualToString:@""] && self.startdate.text != nil) {
        [searchFields setObject:self.startdate.text forKey:@"startdate"];
    }
    
    if (![self.enddate.text isEqualToString:@""] && self.enddate.text != nil) {
        [searchFields setObject:self.enddate.text forKey:@"enddate"];
    }
    
    if (self.rgflag.selectedSegmentIndex != 0) {
        if (self.rgflag.selectedSegmentIndex == 1) {
            [searchFields setObject:@"0" forKey:@"rgflag"];
        }
        else if (self.rgflag.selectedSegmentIndex == 2) {
            [searchFields setObject:@"1" forKey:@"rgflag"];
        }
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    if (self.rgListSearchViewDelegate && [self.rgListSearchViewDelegate respondsToSelector:@selector(searchCallBack:)]) {
        //调用回调函数 
        [self.rgListSearchViewDelegate searchCallBack:searchFields]; 
    } 
}

- (void)dateAction:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.tmp.text = [formatter stringFromDate:sender.date];
}
@end
