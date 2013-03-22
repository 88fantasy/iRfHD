//
//  StockAdjustView.m
//  iRf
//
//  Created by xian weijian on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StockAdjustView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "MBProgressHUD.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kObjKey = @"obj";


typedef NS_ENUM(NSInteger, StockAdjustViewAlertStyle) {
    HouseLocnoStyle =  40000,  //药房默认货位提示
    NoHouseStyle = 400001, //不从药房发药提示
};

@implementation StockAdjustView

@synthesize orglocno,tolocno,goodsqty,orgswitch,toswitch,stocktableview;
@synthesize scrollView,stockList,baseCodeList;
@synthesize venders,venderPickerView,vender;
@synthesize defaultflag,nohouseflag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:[nibNameOrNil stringByAppendingString:@"HD"] bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"库存调整";
        txtindex = 0;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleBordered target:self action:@selector(confirmAdjust)];
        self.navigationItem.rightBarButtonItem = addButton;
        
        
        venderPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 100, 320, 250)];
        venderPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        

        [venderPickerView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];

        
        venderPickerView.delegate = self;
        
        venderPickerView.showsSelectionIndicator = YES;
        
        // add this picker to our view controller, initially hidden
        venderPickerView.hidden = YES;
        [self.view addSubview:venderPickerView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!IsPad) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                               nil];
        [numberToolbar sizeToFit];
        self.goodsqty.inputAccessoryView = numberToolbar;
    }
    
    self.baseCodeList = [NSArray array];
    self.venders = [NSArray array];
    

    CGRect frame =  self.orglocno.frame;
    frame.size.height = 60;
    self.orglocno.frame = frame;
    
    frame = self.tolocno.frame;
    frame.size.height = 60;
    self.tolocno.frame = frame;

    frame = self.goodsqty.frame;
    frame.size.height = 60;
    self.goodsqty.frame = frame;

}

- (IBAction) orgButtonTapped
{
    txtindex = 1;
    if (!self.orgswitch.isOn) {
        [self showScanScreen];
    }
    
}

- (IBAction) toButtonTapped
{
    txtindex = 2;
    if (!self.toswitch.isOn) {
        [self showScanScreen];
    }
    
}

- (void) showScanScreen
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
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
	
    switch (txtindex) {
        case 1:
            orglocno.text = symbol.data;
            [self getStockList];
            break;
            
        default:
            tolocno.text = symbol.data;
            break;
    }    
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    
}



- (IBAction) getStockList
{
    NSString *orgtext = [self.orglocno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    orgtext = [orgtext uppercaseString];
    if ( [orgtext length]>0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Set determinate mode
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        hud.removeFromSuperViewOnHide = YES;
        
        
        iRfRgService* service = [iRfRgService service];
        NSDictionary *setting = [CommonUtil getSettings];
        NSString *username = [setting objectForKey:kSettingUserKey];
        NSString *password = [setting objectForKey:kSettingPwdKey];
        
        [service getStockByLoc:self action:@selector(getStockListHandler:) 
                      username: username 
                      password: password
                         locno:orgtext];
    }
    
        
}

// Handle the response from getStockList.

- (void) getStockListHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [self alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [self alert:@"soap连接失败" msg:[result faultString]];
	}				
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        NSLog(@"%@", result);
        
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                NSUInteger count = [rows count];
                if (count <1) {
                    [self alert:@"提示" msg:@"没有库存"];
                }
                else{
                    
                    self.stockList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSDictionary *obj = [rows objectAtIndex:i];
                        NSString *text = [obj objectForKey:@"goodsname"];
                        
                        text = [text stringByAppendingString:@"  "];
                        text = [text stringByAppendingString:[obj objectForKey:@"goodsqty"]];
                        text = [text stringByAppendingString:[obj objectForKey:@"goodsunit"]];
                        
                        NSString *detailText = [obj objectForKey:@"goodstype"];
                        NSString *lotno = [obj objectForKey:@"lotno"];
                        NSString *goodsstatus = [obj objectForKey:@"goodsstatus"];
                        NSString *proddate = [obj objectForKey:@"proddate"];
                        if (lotno != nil) {
                            if ([lotno length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:lotno];
                            }
                        }
                        if (proddate != nil) {
                            if ([proddate length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:proddate];
                            }
                        }
                        if (goodsstatus != nil) {
                            if ([goodsstatus length]>0) {
                                detailText = [detailText stringByAppendingString:@"     "];
                                detailText = [detailText stringByAppendingString:goodsstatus];
                            }
                        }
                        
                        
                        [self.stockList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  text, kTitleKey,
                                                  detailText, kExplainKey,
                                                  obj,kObjKey,
                                                  nil]];
                    }
                    
                    
                    [self.stocktableview reloadData];
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                    [self.stocktableview selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionTop];
                    [self tableView:self.stocktableview didSelectRowAtIndexPath:indexPath];
                }
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
}

- (void) confirmAdjust
{
    if (!self.venderPickerView.hidden) {
        [self.venderPickerView setHidden:YES];
    }
    [self.orglocno resignFirstResponder];
    [self.tolocno resignFirstResponder];
    [self.goodsqty resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    NSString *orgtext = [self.orglocno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *totext = [self.tolocno.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSIndexPath *indexPath = [self.stocktableview indexPathForSelectedRow];
    if (indexPath!=nil
        &&orgtext.length>0
        &&totext.length>0
        &&self.goodsqty.text.length>0)
    {
        orgtext = [orgtext uppercaseString];
        totext = [totext uppercaseString];
        NSDictionary *obj = [[self.stockList objectAtIndex:indexPath.row] objectForKey:kObjKey];
        NSString *goodsname = [obj objectForKey:@"goodsname"];
        NSString *houselocno = [obj objectForKey:@"houselocno"];
        NSString *basecode = [obj objectForKey:@"basecode"];
        NSString *nohouse = [obj objectForKey:@"nohouse"];
        if (![@"" isEqualToString:basecode]
            &&[[totext substringToIndex:1] isEqualToString:@"C"]
            &&[self.baseCodeList count]!=[self.goodsqty.text intValue]) {
            BaseCodeTableView *basetable = [[BaseCodeTableView alloc]initWithNibName:@"BaseCodeTableView" bundle:nil];
            basetable.codenum = [self.goodsqty.text intValue];
            basetable.baseCodeTableViewDelegate = self;
            [[self navigationController] pushViewController:basetable animated:YES];      
        }
        else if ([@"C01" isEqualToString:orgtext]&&[[totext substringToIndex:1] isEqualToString:@"B"]&&[houselocno isEqualToString:@""]&&self.defaultflag==nil) {
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle:@"药房默认货位提示"
                                  message:[NSString stringWithFormat:@"是否将 %@ 的药房默认货位设置成 %@ ??",goodsname,totext] 
                                  delegate:self 
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
                                  otherButtonTitles:NSLocalizedString(@"Apply", @"Apply"),
                                  nil];
            alert.tag = HouseLocnoStyle;
            [alert show];	
        }
        else if ([totext isEqualToString:@"TH"]&&vender == nil) {
            
            iRfRgService* service = [iRfRgService service];
            
            [service queryJSON:self action:@selector(showVenderPicker:) 
                           sql:@"select * from edis_company x where nvl(companytype,0) = 0" 
                        dbname:nil];
            
        }
        else if ([totext isEqualToString:@"KSLY"]&&vender == nil) {
            
            if ([nohouse isEqualToString:@""]&&nohouseflag == nil) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"不从药房发药提示"
                                      message:[NSString stringWithFormat:@"是否将 %@ 设未不从药房发药 ??",goodsname]
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                      otherButtonTitles:NSLocalizedString(@"Apply", @"Apply"),
                                      nil];
                alert.tag = NoHouseStyle;
                [alert show];
            }
            
            iRfRgService* service = [iRfRgService service];
            
            [service queryJSON:self action:@selector(showVenderPicker:) 
                           sql:@"select * from edis_company x where nvl(companytype,0) = 1" 
                        dbname:nil];
            
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            // Set determinate mode
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Loading";
            hud.removeFromSuperViewOnHide = YES;
            
            
            NSDictionary *stock = [obj copy];
            basecode = @"";
            for (int i=0; i<[self.baseCodeList count]; i++) {
                if (i==0) {
                    basecode = [basecode stringByAppendingString:[self.baseCodeList objectAtIndex:i]];
                }
                else {
                    basecode = [basecode stringByAppendingString:[@"," stringByAppendingString: [self.baseCodeList objectAtIndex:i]]];
                }
            }
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (vender!=nil) {
                [params setObject:vender forKey:@"venderobj"];
            }
            if (self.defaultflag!=nil) {
                [params setObject:self.defaultflag forKey:@"defaultflag"];
            }
            if (self.nohouseflag!=nil) {
                [params setObject:self.nohouseflag forKey:@"nohouseflag"];
            }
            
            NSDictionary *jsonobj =[NSDictionary dictionaryWithObjectsAndKeys:
                                    orgtext,@"orglocno",
                                    totext,@"tolocno",
                                    self.goodsqty.text,@"goodsqty",
                                    basecode,@"basecode",
                                    stock,@"stockobj",
                                    params,@"params",
                                    nil];
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];
            NSString *json =[writer stringWithObject:jsonobj];
            
            NSLog(@"%@",json);
            
            iRfRgService* service = [iRfRgService service];
            NSDictionary *setting = [CommonUtil getSettings];
            NSString *username = [setting objectForKey:kSettingUserKey];
            NSString *password = [setting objectForKey:kSettingPwdKey];
            
            [service mvConfirm:self action:@selector(confirmHandler:) 
                      username: username 
                      password: password
                    jsonObject:json];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==HouseLocnoStyle) {
        if (buttonIndex==1) {
            self.defaultflag = @"1";
        }
        else {
            self.defaultflag = @"0";
        }
        [self confirmAdjust];
    }
    else if (alertView.tag == NoHouseStyle){
        if (buttonIndex==1) {
            self.nohouseflag = @"1";
        }
        else {
            self.nohouseflag = @"0";
        }
        [self confirmAdjust];
    }
    
}

-(void)DidCodeInput:(NSArray *)codes
{
    self.baseCodeList = codes;
    [self confirmAdjust];
}

- (void) confirmHandler:(id)value
{
    if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [self alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [self alert:@"soap连接失败" msg:[result faultString]];
	}
    
    else {
        // Do something with the NSString* result
        
        NSString* result = (NSString*)value;
        NSLog(@"%@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                if (self.orgswitch.isOn) {
                    [self getStockList];
                }
                else {
                    self.stockList = [NSMutableArray array];
                    self.orglocno.text = @"";
                    [self.stocktableview reloadData];
                    
                }
                if (!self.toswitch.isOn) {
                    self.tolocno.text = @"";
                }
                self.goodsqty.text = @"";
                self.baseCodeList = [NSArray array];
                
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            self.vender = nil;
            self.defaultflag = nil;
            self.nohouseflag = nil;
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stockList count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    row = [self.stockList objectAtIndex:indexPath.row];
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[row objectForKey:kCellIdentifier]];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[row objectForKey:kCellIdentifier]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [row objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:18]];
    cell.detailTextLabel.text = [row objectForKey:kExplainKey];
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    row = [self.stockList objectAtIndex:indexPath.row];
    // Navigation logic may go here. Create and push another view controller.
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    self.goodsqty.text =  [obj objectForKey:@"goodsqty"];
    
}




- (IBAction) scrollToBottom:(id)sender{
    UITextField *field = (UITextField *)sender;
    [self.scrollView setContentOffset:CGPointMake(0, field.frame.origin.y) animated:YES];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    textField.text = [textField.text uppercaseString];
//    return YES;
//}

-(void)cancelNumberPad{
    [self.goodsqty resignFirstResponder];
    self.goodsqty.text = @"";
}

-(void)doneWithNumberPad{
    [self.goodsqty resignFirstResponder];
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


- (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    textField.text = [textField.text uppercaseString];
	return YES;
}


#pragma mark -
#pragma mark UIPickerViewDataSource

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//	return [CustomView viewWidth];
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//	return [CustomView viewHeight];
//}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.venders count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.venders objectAtIndex:row] objectForKey:@"edis_companyname"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    vender = [self.venders objectAtIndex:row ];
}

- (void) showVenderPicker:(id)value
{
    if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [self alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [self alert:@"soap连接失败" msg:[result faultString]];
	}
    
    else {
        // Do something with the NSString* result
        
        NSString* result = (NSString*)value;
        NSLog(@"%@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                
                
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                NSUInteger count = [rows count];
                if (count <1) {
                    [self alert:@"提示" msg:@"没有设置供应商"];
                }
                else{
                    
                    self.venders = [rows copy];
                    
                    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                    
                    [self.venderPickerView reloadAllComponents];
                    [self.venderPickerView setHidden:NO];
                    [self.venderPickerView selectRow:0 inComponent:0 animated:YES];
                    [self pickerView:self.venderPickerView didSelectRow:0 inComponent:0];
                }
                
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [self alert:NSLocalizedString(@"Error",@"Error") msg:msg];
            }
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

@end