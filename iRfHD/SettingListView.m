//
//  SettingListView.m
//  iRf
//
//  Created by pro on 13-1-11.
//
//

#import "iRfAppDelegate.h"
#import "SettingListView.h"
#import "iRfServices.h"

#define kLeftMargin		110.0
#define kTopMargin   8.0
#define kTextFieldWidth	  360.0
#define kTextFieldHeight		30.0
#define kFontSize   20.0
#define kSwitchLeftMargin 233.0

typedef NS_OPTIONS(NSUInteger, SettingListSectionType) {
    SettingListSectionTypeAccount = 0,          // 账号设置
    SettingListSectionTypeServer = 1,           // 服务器设置
    SettingListSectionTypeExtra = 2             // 其他设置
};


typedef NS_OPTIONS(NSUInteger, SettingListSectionTypeAccountRow) {
    SettingListSectionTypeAccountRowUser = 0,          // 用户名
    SettingListSectionTypeAccountRowPwd = 1,           // 密码
    SettingListSectionTypeAccountRowTest = 2             // 测试按钮
};

typedef NS_OPTIONS(NSUInteger, SettingListSectionTypeServerRow) {
    SettingListSectionTypeServerRowInternet = 0,          // 互联网模式
    SettingListSectionTypeServerRowServerUrl = 1,         // 服务器地址
    SettingListSectionTypeServerRowApns = 2               // 是否接受推送
};

typedef NS_OPTIONS(NSUInteger, SettingListTestBtnType) {
    SettingListTestBtnTypeLogin = 1000001,          // 登陆
    SettingListTestBtnTypeLogout = 1000002          // 注销
};


typedef NS_OPTIONS(NSUInteger, SettingListSectionTypeExtraRow) {
    SettingListSectionTypeExtraRowVersion = 0,          // 当前版本
};

@implementation SettingListView

@synthesize settingData;
@synthesize username,password,testBtn,internet,server;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"设  置";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self resetView];
    
}

- (void) resetView
{
    self.settingData = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil getSettings]];
    
    self.username = [self genTextField];
    self.username.text = [self.settingData objectForKey:kSettingUserKey];
    
    self.password = [self genTextField];
    self.password.text = [self.settingData objectForKey:kSettingPwdKey];
    self.password.secureTextEntry = YES;
    
    self.testBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if (self.username.text != nil && ![@"" isEqualToString:self.username.text]) {
        [self setLoginStatus:YES];
    }
    else {
        [self setLoginStatus:NO];
    }
    [self.testBtn.titleLabel setFont:[UIFont systemFontOfSize:kFontSize]];
    self.testBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.testBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    [self.testBtn sizeToFit];
    [self.testBtn setFrame:CGRectMake(10, 10, testBtn.frame.size.width+20, testBtn.frame.size.height-10)];
    
    [self.testBtn addTarget:self action:@selector(doAccountTest) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = CGRectMake(0, kTopMargin, 27.0, kTextFieldHeight);
    self.internet = [[UISwitch alloc] initWithFrame:frame];
    self.internet.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin;
    
    NSString *internetstr  = [self.settingData objectForKey:kSettingInternetKey];
    
    if (internetstr == nil || [internetstr boolValue]) {
        [self.internet setOn:YES];
    }
    else{
        [self.internet setOn:NO];
    }
    
    [self.internet addTarget:self action:@selector(doSaveSetting:) forControlEvents:UIControlEventValueChanged];
    
    self.server = [self genTextField];
    self.server.text = [self.settingData objectForKey:kSettingServerKey];
}

- (void) setLoginStatus:(BOOL)login
{
    if (login) {
        [self.username setEnabled:NO];
        [self.password setEnabled:NO];
        [self.testBtn setTitle:@"注 销 账 号" forState:UIControlStateNormal];
        self.testBtn.tag = SettingListTestBtnTypeLogout;
    }
    else {
        [self.username setEnabled:YES];
        [self.password setEnabled:YES];
        self.username.text = @"";
        self.password.text = @"";
        [self.testBtn setTitle:@"测 试 账 号" forState:UIControlStateNormal];
        self.testBtn.tag = SettingListTestBtnTypeLogin;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case SettingListSectionTypeAccount:
            return 3;
        case SettingListSectionTypeServer:
            return 3;
        case SettingListSectionTypeExtra:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"SettingDataCell_%2d%2d",indexPath.section,indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:kFontSize];
        
        
        if(indexPath.section==SettingListSectionTypeAccount) {
            if (indexPath.row == SettingListSectionTypeAccountRowUser) {
                cell.textLabel.text = @"账号";
                
                cell.accessoryView = self.username;
            }
            else if(indexPath.row == SettingListSectionTypeAccountRowPwd){
                cell.textLabel.text = @"密码";
                
                cell.accessoryView =  self.password;
            }
            else if(indexPath.row == SettingListSectionTypeAccountRowTest){
                [self.testBtn setCenter:cell.center];
                
                [cell.contentView addSubview:self.testBtn];
            }
        }
        else if (indexPath.section == SettingListSectionTypeServer){
            if (indexPath.row == SettingListSectionTypeServerRowInternet) {
                cell.textLabel.text = @"互联网";
                
                cell.accessoryView = self.internet;
                
            }
            else if (indexPath.row == SettingListSectionTypeServerRowServerUrl){
                cell.textLabel.text = @"服务地址";
                
                cell.accessoryView = self.server;
                
            }
            else if (indexPath.row == SettingListSectionTypeServerRowApns){
                cell.textLabel.text = @"推送服务";
                cell.detailTextLabel.text = @"暂不支持推送";
//                UIRemoteNotificationType rntype = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//                
//                CGRect frame = CGRectMake(0, kTopMargin, 27.0, kTextFieldHeight);
//                UISwitch *pns = [[UISwitch alloc] initWithFrame:frame];
//                pns.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
//                UIViewAutoresizingFlexibleTopMargin |
//                UIViewAutoresizingFlexibleRightMargin;
//                
//                if (rntype!=UIRemoteNotificationTypeNone) {
//                    [pns setOn:YES];
//                }
//                else{
//                    [pns setOn:NO];
//                }
//                
//                [pns addTarget:self action:@selector(doApnsChange:) forControlEvents:UIControlEventValueChanged];
//                
//                cell.accessoryView = pns;
                
            }
        }
        else if (indexPath.section == SettingListSectionTypeExtra){
            if (indexPath.row == SettingListSectionTypeExtraRowVersion) {
                cell.textLabel.text = @"当前版本";
                
                cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                
            }
        }
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark -
#pragma mark - doApnsChange Handle

- (void) doApnsChange:(UISwitch*)apns
{
    [self apnsService:apns.on];
}

- (void) apnsService:(BOOL)reg
{
    if (reg) {
        //      Register for push notifications 注册推送服务
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeSound];
        NSLog(@"注册推送");
    }
    else {
        //      注销推送服务
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        NSLog(@"注销推送");
    }
}

#pragma mark -
#pragma mark - doSaveSetting Handle

- (void) doSaveSetting:(id)sender
{
    if (sender == self.internet) {
        [self setLoginStatus:NO];
    }
    
    NSMutableDictionary *newSetting = [NSMutableDictionary dictionary];
    if (self.testBtn.tag == SettingListTestBtnTypeLogout) {
        [newSetting setObject:self.username.text forKey:kSettingUserKey];
        [newSetting setObject:self.password.text forKey:kSettingPwdKey];
    }
//    else {
//        [self.settingData removeObjectForKey:kSettingUserKey];
//        [self.settingData removeObjectForKey:kSettingPwdKey];
//    }
    if (self.internet.on) {
        [newSetting setObject:@"true" forKey:kSettingInternetKey];
    }
    else {
        [newSetting setObject:@"false" forKey:kSettingInternetKey];
    }
    if (self.server.text!=nil) {
        NSString *serverurl = self.server.text;
        [newSetting setObject:serverurl forKey:kSettingServerKey];
    }
    
    [newSetting writeToFile:[CommonUtil getSettingPath] atomically:YES];
    self.settingData = [NSMutableDictionary dictionaryWithDictionary:[CommonUtil rebuildSetting]];
}


#pragma mark -
#pragma mark - testBtn handle

- (void) doAccountTest
{
    if(self.testBtn.tag == SettingListTestBtnTypeLogin) {
        NSString *user = self.username.text;
        NSString *pass = self.password.text;
        if (user != nil && ![@"" isEqualToString:user] && pass != nil && ![@"" isEqualToString:pass]) {
            
            if (self.internet.on) {
                iRfRgService *service = [iRfRgService service];
                [service test:self action:@selector(testHandle:) username:user password:pass];
            }
            else {
                NSHTTPCookie *cookies = [CommonUtil getSessionByUsername:user password:pass];
                if (cookies != nil) {
                    [self loginSuccess];
                }
            }
            
        }
    }
    else {
        [self setLoginStatus:NO];
        [self doSaveSetting:self.testBtn];
    }
    
}

- (void)testHandle:(id)value {
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError * result = (NSError*)value;
        [CommonUtil alert:@"连接失败" msg:[result localizedFailureReason]];
    }
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [CommonUtil alert:@"soap连接失败" msg:[result faultString]];
	}
    
    else {
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        NSLog(@"test returned the value: %@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",retObj);
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            if ([retflag boolValue]==YES) {
                [self loginSuccess];
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
}

-(void)loginSuccess
{
    [CommonUtil alert:NSLocalizedString(@"Info", @"Info")  msg:@"登陆成功"];
    [self setLoginStatus:YES];
    [self doSaveSetting:nil];
}

#pragma mark -
#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    if (textField == self.username) {
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [self doAccountTest];
    }
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self doSaveSetting:textField];
}

#pragma mark -
#pragma mark - textfield gen

- (UITextField*) genTextField
{
    CGRect frame = CGRectMake(0, kTopMargin, kTextFieldWidth, kTextFieldHeight);
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    
    textfield.borderStyle = UITextBorderStyleRoundedRect;
    textfield.textColor = [UIColor blackColor];
    textfield.font = [UIFont systemFontOfSize:kFontSize];
    textfield.backgroundColor = [UIColor whiteColor];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    textfield.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth;
    
    textfield.keyboardType = UIKeyboardTypeDefault;
    textfield.returnKeyType = UIReturnKeyDone;
    
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    
    textfield.delegate = self;
    
    return textfield;
}

@end
