//
//  TrView.m
//  iRf
//
//  Created by user on 11-8-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrView.h"
#import "iRfRgService.h"
#import "SBJson.h"

typedef NS_OPTIONS(NSUInteger, TrViewType) {
    TrViewTypeBasecode = 0,          
    TrViewTypeLocno = 1,           
};

@implementation TrView
@synthesize ugoodsid,goodsname,goodstype,tradename,factno,goodsunit,cusgdsid,multi,companyname,locbtn,locno,basebtn,basecode;
@synthesize scrollView,values;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj 
{
   
    self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    
    
    if (self) {
        // Custom initialization
        self.title = @"货品对应关系明细";
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target:self action:@selector(confirmTr:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    self.values = obj;
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
    
    NSLog(@"%@",values);
    
    self.ugoodsid.text = (NSString*) [values objectForKey:@"ugoodsid"];
    self.goodsname.text =  [values objectForKey:@"goodsname"] == nil ? @"" : [values objectForKey:@"goodsname"];
    self.goodstype.text =  [values objectForKey:@"goodstype"] == nil ? @"" : [values objectForKey:@"goodstype"];
    self.tradename.text =  [values objectForKey:@"tradename"] == nil ? @"" : [values objectForKey:@"tradename"];
    self.factno.text =  [values objectForKey:@"factno"] == nil ? @"" : [values objectForKey:@"factno"];
    self.goodsunit.text =  [values objectForKey:@"goodsunit"] == nil ? @"" : [values objectForKey:@"goodsunit"];
    self.cusgdsid.text =  [values objectForKey:@"cusgdsid"] == nil ? @"" : [values objectForKey:@"cusgdsid"];
    self.multi.text =  [values objectForKey:@"multi"];
    self.companyname.text =  [values objectForKey:@"companyname"];
    self.locno.text =  [values objectForKey:@"locno"] == nil ? @"" : [values objectForKey:@"locno"];
    self.basecode.text =  [values objectForKey:@"basecode"] == nil ? @"" : [values objectForKey:@"basecode"];
}

#pragma mark ios6+纵向旋转控制需要以下3个 覆盖viewcontroller的方法
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)confirmTr:(id)sender {
    
    if ([[self.cusgdsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message: @"客户货品码不能为空"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        return;
    }
    
    if ([[self.multi.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message: @"倍数关系不能为空"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    NSMutableDictionary *trobj = [NSMutableDictionary dictionary];
    NSString *goodsnamestr = [self.goodsname.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *goodstypestr = [self.goodstype.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tradenamestr = [self.tradename.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *factnostr = [self.factno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *goodsunitstr = [self.goodsunit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *cusgdsidstr = [self.cusgdsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *multistr = [self.multi.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *locnostr = [self.locno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *basecodestr = [self.basecode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL needSave = NO;
    NSString *goodsnamestr2 = [values objectForKey:@"goodsname"];
    if ((goodsnamestr2 != nil || (goodsnamestr2 == nil && ![@"" isEqualToString:goodsnamestr] ) ) && ![goodsnamestr isEqualToString:goodsnamestr2]) {
        [trobj setObject:goodsnamestr forKey:@"goodsname"];
        needSave = YES;
    }
    
    NSString *goodstypestr2 = [values objectForKey:@"goodstype"];
    if ((goodstypestr2 != nil || (goodstypestr2 == nil && ![@"" isEqualToString:goodstypestr] ) ) && ![goodstypestr isEqualToString:goodstypestr2]) {
        [trobj setObject:goodstypestr forKey:@"goodstype"];
        needSave = YES;
    }
    
    NSString *tradenamestr2 = [values objectForKey:@"tradename"];
    if ((tradenamestr2 != nil || (tradenamestr2 == nil && ![@"" isEqualToString:tradenamestr] ) ) && ![tradenamestr isEqualToString:tradenamestr2]) {
        [trobj setObject:tradenamestr forKey:@"tradename"];
        needSave = YES;
    }
    
    NSString *factnostr2 = [values objectForKey:@"factno"];
    if ((factnostr2 != nil || (factnostr2 == nil && ![@"" isEqualToString:factnostr] ) ) && ![factnostr isEqualToString:factnostr2]) {
        [trobj setObject:factnostr forKey:@"factno"];
        needSave = YES;
    }
    
    NSString *goodsunitstr2 = [values objectForKey:@"goodsunit"];
    if ((goodsunitstr2 != nil || (goodsunitstr2 == nil && ![@"" isEqualToString:goodsunitstr] ) ) && ![goodsunitstr isEqualToString:goodsunitstr2]) {
        [trobj setObject:goodsunitstr forKey:@"goodsunit"];
        needSave = YES;
    }
    
    NSString *locnostr2 = [values objectForKey:@"locno"];
    if ((locnostr2 != nil || (locnostr2 == nil && ![@"" isEqualToString:locnostr] ) ) && ![locnostr isEqualToString:locnostr2]) {
        [trobj setObject:locnostr forKey:@"locno"];
        needSave = YES;
    }
    
    NSString *basecodestr2 = [values objectForKey:@"basecode"];
    if ((basecodestr2 != nil || (basecodestr2 == nil && ![@"" isEqualToString:basecodestr] ) ) && ![basecodestr isEqualToString:basecodestr2]) {
        [trobj setObject:basecodestr forKey:@"basecode"];
        needSave = YES;
    }
    
    
    NSString *cusgdsidstr2 = [values objectForKey:@"cusgdsid"];
    if (![cusgdsidstr isEqualToString:cusgdsidstr2]) {
        [trobj setObject:cusgdsidstr forKey:@"cusgdsid"];
        needSave = YES;
    }
    
    NSString *multistr2 = [values objectForKey:@"multi"];
    if (![multistr isEqualToString:multistr2]) {
        [trobj setObject:multistr forKey:@"multi"];
        needSave = YES;
    }
    
    if (needSave) {
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *json = [writer stringWithObject:trobj];
        
        [service doTr:self
               action:@selector(doTrHandler:)
             username: username
             password: password
              pkvalue:[self.ugoodsid.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
           jsonConfig:json
         ];
    }
    
    
}

- (void)doTrHandler:(id)value {
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"连接失败" 
                                                        message: [result localizedFailureReason]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"soap连接失败" 
                                                        message: [result faultString]
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
	}				
    
    else {
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        NSLog(@"doRg returned the value: %@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",retObj);
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                [values setValue:self.cusgdsid.text forKey:@"cusgdsid"];
    //            if (self.scanViewDelegate!=nil) { 
    //                //调用回调函数 
    //                [self.scanViewDelegate confirmCallBack:YES values:values]; 
    //            } 
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                message: msg
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];	
            }
            
        }
        else{
            
        }
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate 

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
//- (IBAction) scrollToBottom:(id)sender{
//    [self.scrollView setContentOffset:CGPointMake(0, 250) animated:YES];
//}


#pragma mark Scan and Handle

- (IBAction) scanButtonTapped:(UIButton *)btn
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
    if (btn == self.locbtn) {
        scanType = TrViewTypeLocno;
    }
    else if (btn == self.basebtn){
        scanType = TrViewTypeBasecode;
    }
    //    CGRect rect_screen = [[UIScreen mainScreen] bounds];
    //    CGRect rect = reader.readerView.frame;
    //
    //    rect.size.height = rect_screen.size.height;
    //    rect.size.width = rect_screen.size.width;
    //    reader.readerView.frame = rect;
    
    
    
	//reader.showsZBarControls = NO;
	
	
	
    //    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // EXAMPLE: disable rarely used I2/5 to improve performance
    //    [scanner setSymbology: ZBAR_I25
    //				   config: ZBAR_CFG_ENABLE
    //					   to: 0];
	
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
	
    // EXAMPLE: do something useful with the barcode data
	
    if (scanType == TrViewTypeLocno) {
        self.locno.text = symbol.data;
    }
    else if (scanType == TrViewTypeBasecode){
        self.basecode.text = symbol.data;
    }
    
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
}

@end
