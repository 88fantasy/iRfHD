//
//  RgView.m
//  iRf
//
//  Created by pro on 11-7-19.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "RgView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "RootViewController.h"
#import "POAPinyin.h"

@implementation RgView

@synthesize scrollView,invno,goodsname,goodstype,factoryname,goodsprice,goodsunit,lotno
,packsize,validto,orgrow,goodsqty,rgqty,locno,socompanyname,vendername;

@synthesize spdid,values;
@synthesize goalBarView,goalBar;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil values:(NSDictionary*)obj
//         readOnlyFlag:(BOOL) _readOnlyFlag
{
    self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        
        NSString *rfflag = (NSString*) [obj objectForKey:@"rgflag"];
        if ([rfflag intValue]==1) {
            self.title = @"收货明细(已收货)";
            readOnlyFlag = YES;
        }
        else{
            self.title = @"收货明细";
            readOnlyFlag = NO;
        }
        
        self.values = obj;
        //        readOnlyFlag = _readOnlyFlag;
        
        if (readOnlyFlag != YES) {
            if ([ RootViewController isSync]) {
                UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSeet)];
                self.navigationItem.rightBarButtonItem = addButton;

            }
            else {
                UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"确认收货" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmRg)];
                self.navigationItem.rightBarButtonItem = addButton;

            }
            
        }
        
        
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
    
    NSLog(@"%@",values);
    
    self.invno.text = (NSString*) [values objectForKey:@"invno"];
    self.goodsname.text = (NSString*) [values objectForKey:@"goodsname"];
    self.goodstype.text = (NSString*) [values objectForKey:@"goodstype"];
    self.factoryname.text = (NSString*) [values objectForKey:@"factno"];
    self.goodsprice.text = (NSString*) [values objectForKey:@"invprice"];
    self.goodsunit.text = (NSString*) [values objectForKey:@"goodsunit"];
    self.lotno.text = (NSString*) [values objectForKey:@"lotno"];
    self.packsize.text = (NSString*) [values objectForKey:@"packsize"];
    self.validto.text = (NSString*) [values objectForKey:@"validto"];
    self.orgrow.text = (NSString*) [values objectForKey:@"orgrow"];
    self.goodsqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    
    
    self.rgqty.text = (NSString*) [values objectForKey:@"goodsqty"];
    self.locno.text = (NSString*) [values objectForKey:@"locno"];
    self.socompanyname.text = (NSString*) [values objectForKey:@"socompanyname"];
    self.vendername.text = (NSString*) [values objectForKey:@"uvender"];
    
    self.spdid = (NSString*) [values objectForKey:@"spdid"];
    
    if (!readOnlyFlag) {
        [self.rgqty setEnabled:YES];
        [self.locno setEnabled:YES];
    }

    NSString *pinyin = [POAPinyin quickConvert:self.goodsname.text byConvertMode:POAPinyinConvertModeFirstWord] ;

    NSLog(@"%@",pinyin);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.invno = nil ;
    self.goodsname = nil ;
    self.goodstype = nil ;
    self.factoryname = nil ;
    self.goodsprice = nil ;
    self.goodsunit = nil ;
    self.lotno = nil ;
    self.packsize = nil ;
    self.validto = nil ;
    self.orgrow = nil ;
    self.goodsqty = nil ;
    self.rgqty = nil ;
    self.locno = nil ;
    self.spdid = nil;
    self.socompanyname = nil;
    self.vendername = nil;
    self.values = nil;
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

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self reDrawTextField];
//}
//
//- (void) reDrawTextField
//{
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
//        NSLog(@"%f",[[UIScreen mainScreen] bounds].size.width);
//        CGRect frame = self.invno.frame;
//        frame.size = CGSizeMake(300, frame.size.height);
//        self.invno.frame = frame;
//        
//    }
//}

- (void)confirmRg {
    iRfRgService* service = [iRfRgService service];
    //    service.logging = YES;
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    NSLog(@"dorg开始");
    [service doRg:self
           action:@selector(doRgHandler:)
         username: username
         password: password
            splid: self.spdid
            rgqty: self.rgqty.text
            locno: self.locno.text];
    
    if ([RootViewController isSync]) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if(db != nil) {
            [db executeUpdate:@"update scm_rg set rgqty = ?,locno = ?,rgflag = 1 where spdid = ?",
             self.rgqty.text, self.locno.text, self.spdid];
            [db close];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doRgHandler:(id)value {
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
                if (delegate && [delegate respondsToSelector:@selector(rgViewDidConfirm:)]) {
                    [delegate performSelector:@selector(rgViewDidConfirm:) withObject:self  withObject:error];
                }
                //            NSDictionary *msg = (NSDictionary*) [ret objectForKey:kMsgKey];
                //            NSString *sid = (NSString*) [msg objectForKey:@"spdid"];
                
                if ([RootViewController isSync]) {
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",self.spdid];
                        [db close];
                    }
                }
                
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

- (IBAction) scrollToBottom:(id)sender{
    [self.scrollView setContentOffset:CGPointMake(0, 320) animated:YES];
}

- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
	//reader.showsZBarControls = NO;
	
	
	
    //    ZBarImageScanner *scanner = reader.scanner;	
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
    locno.text = symbol.data;
    
	
    // EXAMPLE: do something useful with the barcode image
    //    resultImage.image =
    //	[info objectForKey: UIImagePickerControllerOriginalImage];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
}


-(void) showActionSeet
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"请选择操作"
                                                    delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                      destructiveButtonTitle:@"确认收货"
                                           otherButtonTitles:@"全部收货", nil];
    [as showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) { //单条收货
            [self confirmRg];
        }
        else if (buttonIndex == 1 && [ RootViewController isSync] ){ //全部收货
            //只有缓存模式才能通过数据库查询同批号,同销售单的货品
            FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
            if (db != nil) {
                
                notDoRgCount = 0;
                doneDoRgCoount = 0;
                
                NSString *ugoodsid = [values objectForKey:@"ugoodsid"];
                NSString *orgsoid = [values objectForKey:@"orgsoid"];
                
                FMResultSet *rs = [db executeQuery:@"select count(*) from scm_rg where ugoodsid = ? and lotno = ? and orgsoid = ? and rgflag <> 1 ",ugoodsid,self.lotno.text,orgsoid];
                if ([rs next]) {
                    notDoRgCount = [rs intForColumnIndex:0];
                }
                [db close];
                if (notDoRgCount == 1) {
                    
                    [self confirmRg];
                    return;
                }
                else if (notDoRgCount > 1) {
                    [self displayGoalBarView:0];
                    iRfRgService* service = [iRfRgService service];
                    //    service.logging = YES;
                    
                    NSDictionary *setting = [CommonUtil getSettings];
                    NSString *username = [setting objectForKey:kSettingUserKey];
                    NSString *password = [setting objectForKey:kSettingPwdKey];
                    
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    
                    if (db != nil) {
                        FMResultSet *rs = [db executeQuery:@"select spdid,goodsqty,locno from scm_rg where ugoodsid = ? and lotno = ? and orgsoid = ? and rgflag <> 1 ",ugoodsid,self.lotno.text,orgsoid];
                        while  ([rs next]) {
                            
                            NSString *idv = [rs stringForColumn:@"spdid"];
                            NSString *qty = [rs stringForColumn:@"goodsqty"];
                            NSString *lno = [rs stringForColumn:@"locno"];
                            
                            [service doRg:self
                                   action:@selector(doRgBatchHandler:)
                                 username: username
                                 password: password
                                    splid: idv
                                    rgqty: qty
                                    locno: lno];
                            
                            [db executeUpdate:@"update scm_rg set rgqty = ?,rgflag = 1 where spdid = ?", qty,  idv];
                            
                            
                            [goalBar setPercent:doneDoRgCoount/notDoRgCount * 100 animated:YES];
                        }
                        [db close];
                    }
                }
                
            }
        }
    }
    
}


- (void)doRgBatchHandler:(id)value {
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
        
        doneDoRgCoount ++;
        if (doneDoRgCoount >= notDoRgCount) {
            [self dismissGoalBarView];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            int percent = doneDoRgCoount * 100 / notDoRgCount ;
            [self displayGoalBarView:percent];
        }
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                
                if ([RootViewController isSync]) {
                    NSDictionary *msg = (NSDictionary*) [ret objectForKey:kMsgKey];
                    NSString *idv = (NSString*) [msg objectForKey:@"spdid"];
                
                
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",idv];
                        [db close];
                    }
                }
                
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

//显示等待进度条
- (void) displayGoalBarView:(int)percent {
    if (goalBarView==nil){
        goalBarView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Loading...",@"Loading...")
                                                 message: @"\n\n\n\n\n\n\n"  //放大进度条显示区域
                                                delegate: self
                                       cancelButtonTitle: nil
                                       otherButtonTitles: nil];
        
        goalBar = [[KDGoalBar alloc] initWithFrame:CGRectMake(60.f, 55.0f, 177.0f, 177.0f)];
        [goalBar setAllowDragging:NO];
        [goalBar setAllowSwitching:NO];
        [goalBar setPercent:0 animated:NO];
        [goalBar setAllowTap:NO];
        [goalBarView addSubview:goalBar];
    }
    if (!goalBarView.isVisible) {
        [goalBarView show];
    }
    [goalBar setPercent:percent animated:YES];
    
}

//取消等待进度条
- (void) dismissGoalBarView
{
    if (goalBarView)
    {
        [goalBarView dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
