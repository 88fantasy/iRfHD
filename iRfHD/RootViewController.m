//
//  RootViewController.m
//  iRf
//
//  Created by pro on 11-7-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "iRfRgService.h"
#import "RootViewController.h"
#import "ScanView.h"
#import "RgListView.h"
#import "TrListView.h"
#import "StockAdjustView.h"
#import "MedicineReqListView.h"
#import "RgGroupListView.h"
#import "SettingListView.h"
#import "BasecodeStockList.h"
#import "QRCodeRgReader.h"
//#import "LoanTableView.h"
#import "MBProgressHUD.h"
#import "RedressView.h"

static NSString * const kCellIdentifier = @"RootViewControllerIdentifier";
static NSString * const kTitleKey = @"title";
static NSString * const kExplainKey = @"explanation";
static NSString * const kViewControllerKey = @"viewController";
static NSString * const iconKey = @"iconfile";

enum {
    SyncAlert = 100001,
    VersionAlert = 100002
};

//@interface RootViewController ()
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//@end

@implementation RootViewController

@synthesize menuList,userfield,pwdfield,goalBarView,goalBar;


+ (bool) isSync {
    return syncflag && IsInternet;
}

- (void)confirmUser{
    NSDictionary *settingData = [CommonUtil getSettings];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username_preference"];
    NSString *password = [defaults stringForKey:@"password_preference"];
    
//    兼容以前已设置的信息 保存至新方式
	if ((username != nil || password != nil ) && [settingData objectForKey:kSettingUserKey] == nil) {
        NSMutableDictionary *newSetting = [NSMutableDictionary dictionaryWithDictionary:settingData];
        [newSetting setObject:username forKey:kSettingUserKey];
        [newSetting setObject:password forKey:kSettingPwdKey];
        if (([defaults boolForKey:@"enabled_preference"]||[defaults stringForKey:@"enabled_preference"]==nil)) {
            [newSetting setObject:@"true" forKey:kSettingInternetKey];
        }
        else {
            [newSetting setObject:@"false" forKey:kSettingInternetKey];
        }
        NSString *server = [defaults stringForKey:@"serviceurl_preference"];
        if (server!=nil) {
            [newSetting setObject:server forKey:kSettingServerKey];
        }
        [newSetting writeToFile:[CommonUtil getSettingPath] atomically:YES];
        settingData = [NSDictionary dictionaryWithDictionary:newSetting];
    }
    username = [settingData objectForKey:kSettingUserKey];
    password = [settingData objectForKey:kSettingPwdKey];
	if (username == nil || [@"" isEqualToString:username] || password == nil || [@"" isEqualToString:password]) {
        [self setAction];

//    旧输入方式
//		UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"尚未设置用户名密码"
//														 message:@"\n\n\n" // IMPORTANT
//														delegate:self 
//											   cancelButtonTitle:@"取消" 
//											   otherButtonTitles:@"确定", nil];
//		
//		if (username == nil || [@"" isEqualToString:username]) {
//			userfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 25.0)]; 
//			[userfield setBackgroundColor:[UIColor whiteColor]];
//			[userfield setPlaceholder:@"用户名"];
//			[prompt addSubview:userfield];
//			
//		}
//		
//		if(password == nil|| [@"" isEqualToString:password]){
//			pwdfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 90.0, 260.0, 25.0)]; 
//			[pwdfield setBackgroundColor:[UIColor whiteColor]];
//			[pwdfield setPlaceholder:@"密码"];
//			[pwdfield setSecureTextEntry:YES];
//			[prompt addSubview:pwdfield];
//			
//		}
//        [prompt setTag:UserAlert];
//		// set place
//		[prompt setCenter:self.view.center];
//		[prompt show];
//		[prompt release];
		
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"医药库存管理系统";
    
    // 增加设置按钮
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setAction)];
    self.navigationItem.leftBarButtonItem = settingButton;
    
    
//    [self reloadMain];
    
	[self confirmUser];
    
}

- (void) reloadMain
{
    
    if (IsInternet) {
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(syncAction:)];
        self.navigationItem.rightBarButtonItem = syncButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.menuList = [NSMutableArray array];
    
    ScanView* scanview = [[ScanView alloc] initWithNibName:@"ScanView" bundle:nil];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"条码收货", kTitleKey,
                              @"扫描或手输条码进行收货", kExplainKey,
                              scanview, kViewControllerKey,
                              @"barcode.png",iconKey,
							  nil]];
    
    RgListView *rglistView = [[RgListView alloc] initWithStyle:UITableViewStylePlain];
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"收货明细列表", kTitleKey,
                              @"查询一个月内所有收货的信息", kExplainKey,
                              rglistView, kViewControllerKey,
                              @"kccx.png",iconKey,
							  nil]];
    TrListView *trListView = [[TrListView alloc]initWithNibName:@"TrListView" bundle:nil];
    
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"货品对应关系", kTitleKey,
                              @"查询货品的对应关系情况", kExplainKey,
                              trListView, kViewControllerKey,
                              @"jcsj.png",iconKey,
							  nil]];
    
    RgGroupListView *rgGroupListView = [[RgGroupListView alloc]initWithNibName:@"RgGroupListView" bundle:nil];
    
    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                              @"品种收货汇总查询", kTitleKey,
                              @"查询一个月内收货信息的汇总情况", kExplainKey,
                              rgGroupListView, kViewControllerKey,
                              @"kccx.png",iconKey,
							  nil]];
    
    
//    [trListView release];  //清除prompt时会调用release
//    NSLog(@"trListView retain count : %d",[trListView retainCount]);
    if (!IsInternet) {
        
        StockAdjustView *stockAdjustView = [[StockAdjustView alloc]initWithNibName:@"StockAdjustView" bundle:nil];
        
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"库存调整", kTitleKey,
                                  @"可进行移库或退货等操作", kExplainKey,
                                  stockAdjustView, kViewControllerKey,
                                  @"kctz.png",iconKey,
                                  nil]];
        
        MedicineReqListView *medicineReqListView = [[MedicineReqListView alloc] initWithNibName:@"MedicineReqListView" bundle:nil];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"药房领药", kTitleKey,
                                  @"对低于库存下限的货品进行批量移库", kExplainKey,
                                  medicineReqListView, kViewControllerKey,
                                  @"yfly.png",iconKey,
                                  nil]];
        
        BasecodeStockList *basecodeStockList = [[BasecodeStockList alloc]initWithStyle:UITableViewStylePlain];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"库存查询", kTitleKey,
                                  @"通过扫描货品零售条码来查询当前库存", kExplainKey,
                                  basecodeStockList, kViewControllerKey,
                                  @"kccx.png",iconKey,
                                  nil]];
        
        QRCodeRgReader *qrCodeRgReader = [[QRCodeRgReader alloc]initWithStyle:UITableViewStylePlain];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"二维码收货", kTitleKey,
                                  @"通过扫描二维码识别收货数据", kExplainKey,
                                  qrCodeRgReader, kViewControllerKey,
                                  @"qrcode.png",iconKey,
                                  nil]];
        
        RedressView *redressView = [[RedressView alloc]initWithNibName:@"RedressView" bundle:nil];
        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"药房换药", kTitleKey,
                                  @"借货或勾对处方还药", kExplainKey,
                                  redressView, kViewControllerKey,
                                  @"kccx.png",iconKey,
                                  nil]];
        
    }
    
//    LoanTableView *loanTableView = [[LoanTableView alloc]initWithStyle:UITableViewStylePlain];
//    [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
//                              @"换货管理", kTitleKey,
//                              @"允许操作借出还入单", kExplainKey,
//                              loanTableView, kViewControllerKey,
//                              @"kccx.png",iconKey,
//                              nil]];
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadMain];
}

#pragma mark -
#pragma mark UITableViewDelegate

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController *targetViewController = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kViewControllerKey];
	[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource

// tell our table how many rows it will have, in our case the size of our menuList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.menuList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier] ;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	cell.textLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:20]];
    cell.detailTextLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kExplainKey];
    
    UIImage *cellIcon = [UIImage imageNamed:[[self.menuList objectAtIndex:indexPath.row] objectForKey:iconKey]];
	[[cell imageView] setImage:cellIcon];
    
	return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [super viewDidUnload];
	
	self.menuList = nil;
	self.userfield = nil;
	self.pwdfield = nil;
    self.goalBar = nil;
    self.goalBarView = nil;
}


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     
//    if ([alertView tag] == SyncAlert) {
        switch (buttonIndex) {
            case 1:
                [self getAllRg];
                break;
            case 2:
                syncflag = NO;
                [self.navigationItem.rightBarButtonItem setTitle:@"0"];
                break;
            case 3:
                [self confirmRg];
                break;
            default:
                ;
        }
//    }
}
#pragma mark -
#pragma mark 同步信息
- (IBAction)syncAction:(id)sender {
    NSString *msg;
    
    if ([RootViewController isSync]) {
        msg = [NSString stringWithFormat:@"当前已同步 %@ 条收货数据",
              [self.navigationItem.rightBarButtonItem title] ];
    }
    else {
        msg = @"尚未进行同步";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"请选择操作"
                          message:msg
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                          otherButtonTitles:@"同步",@"撤销同步",@"回传收货信息",
                          nil];
    [alert setTag:SyncAlert];
    [alert show];
}

- (void) getAllRg{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
    iRfRgService* service = [iRfRgService service];
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    [service getAllRg:self action:@selector(getAllRgHandler:)
             username: username
             password: password
            queryjson:nil
     ];
    
}

// Handle the response from getRg.

- (void) getAllRgHandler: (id) value {
    
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
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                
                if (rows != nil) {
                    
                    FMDatabase *db = [DbUtil rebuildForResource:@"iRf" ofType:@"rdb"];
                    if (db != nil) {
                        
                        [db beginTransaction];
                        
                        [db executeUpdate:@"delete from SCM_RG"];
                        
                        for (int i=0; i<[rows count]; i++) {
                            NSDictionary *row = [rows objectAtIndex:i];
                            [db executeUpdate:@"insert into SCM_RG (spdid, labelno, labeltype, said, orgsoid, socompanyid, socompanyname, lotno, ugoodsid, cusgdsid, goodsname, goodspy, goodstype, factno, goodsunit, goodsqty,  invno, invprice, proddate, prodarea, validto,  locno, tcsoid, packsize, uvenderid, uvender, orgrow, stageid, rgmanid, rgdate, rgqty, rgflag, credate) values ( :spdid, :labelno, :labeltype, :said, :orgsoid, :socompanyid, :socompanyname, :lotno, :ugoodsid, :cusgdsid, :goodsname, :goodspy, :goodstype, :factno, :goodsunit, :goodsqty,  :invno, :invprice, date(:proddate), :prodarea, :validto,  :locno, :tcsoid, :packsize, :uvenderid, :uvender, :orgrow,   :stageid, :rgmanid, :rgdate, :rgqty, :rgflag, datetime(:credate) )" withParameterDictionary:row];
                        
                        }
                        FMResultSet *rs = [db executeQuery:@"select count(*) from SCM_RG"];
                        if ([rs next]) {
                            int count = [rs intForColumnIndex:0];
//                            NSLog(@"%d",count);
                            [self.navigationItem.rightBarButtonItem
                                            setTitle:[rs stringForColumnIndex:0]];
                            [CommonUtil alert:@"提示"
                                          msg:[NSString stringWithFormat:@"已成功接受%d条收货信息",count]];
                        }
                        
                        [db commit];
                        
                        [db close];
                    }
                }
                
                syncflag = YES;
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
    }

    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -
#pragma mark 进度条
//显示等待进度条
- (void) displayGoalBarView:(int) percent {
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
    [goalBar setPercent:percent animated:YES];
    [goalBarView show];
}

//取消等待进度条
- (void) dismissGoalBarView
{
    if (goalBarView)
    {
        [goalBarView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

#pragma mark -
#pragma mark  批量收货
- (void)confirmRg {
    if ([RootViewController isSync]) {
        FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
        if(db!=Nil){
            notDoRgCount = 0;
            doneDoRgCoount = 0;
            FMResultSet *rs = [db executeQuery:@"select count(*) from SCM_RG where rgflag = 1 and rgdate in ('')"];
            if ([rs next]) {
                notDoRgCount = [rs intForColumnIndex:0];
            }
            if (notDoRgCount>0) {
                [self displayGoalBarView:0];
            }
            iRfRgService* service = [iRfRgService service];
            //    service.logging = YES;
            
            NSDictionary *setting = [CommonUtil getSettings];
            NSString *username = [setting objectForKey:kSettingUserKey];
            NSString *password = [setting objectForKey:kSettingPwdKey];
                
            rs = [db executeQuery:@"select spdid,rgqty,locno from SCM_RG where rgflag = 1 and rgdate in ('')"];
            while ([rs next]) {
                NSString *spdid = [rs stringForColumnIndex:0];
                NSString *rgqty = [rs stringForColumnIndex:1];
                NSString *locno = [rs stringForColumnIndex:2];
                
                [service doRg:self
                       action:@selector(doRgHandler:)
                     username: username
                     password: password
                        splid: spdid
                        rgqty: rgqty
                        locno: locno];
//                [self doRgHandler:nil];
            }
            
            [db close];
        }
        
    }
    
    
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
        
        doneDoRgCoount ++;
        if (doneDoRgCoount >= notDoRgCount) {
            [self dismissGoalBarView];
        }
        else {
            [self displayGoalBarView: doneDoRgCoount * 100 / notDoRgCount ];
        }
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                NSDictionary *msg = (NSDictionary*) [ret objectForKey:kMsgKey];
                NSString *spdid = (NSString*) [msg objectForKey:@"spdid"];
                if ([RootViewController isSync]) {
                    FMDatabase *db = [DbUtil retConnectionForResource:@"iRf" ofType:@"rdb"];
                    if(db != nil) {
                        [db executeUpdate:@"update scm_rg set rgdate = datetime('now') where spdid = ?",spdid];
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
    }
}




#pragma mark -
#pragma mark 进入设置界面
- (void) setAction
{
    SettingListView *settingView = [[SettingListView alloc] initWithStyle:UITableViewStyleGrouped];
    [[self navigationController] pushViewController:settingView animated:YES];
}

@end

