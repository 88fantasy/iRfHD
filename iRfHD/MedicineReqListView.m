//
//  MedicineReqListView.m
//  iRf
//
//  Created by xian weijian on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MedicineReqListView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "MedicineReqCell.h"
#import "MBProgressHUD.h"

static NSString *kCellIdentifier = @"MedicineReqCellIdentifier";

@implementation MedicineReqListView

@synthesize dataList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
       
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
    
    self.title = @"领药列表";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleBordered target:self action:@selector(reqConfirm)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor lightGrayColor];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status")] ;
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    }


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.dataList = nil;
    
}


- (void) getReqList
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
    iRfRgService* service = [iRfRgService service];
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    [service getReqInfo:self action:@selector(getReqListHandler:) 
             username: username 
             password: password];

}

- (void) getReqListHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [CommonUtil alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [CommonUtil alert:@"soap连接失败" msg:[result faultString]];
	}				
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id json = [parser objectWithString:result];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                NSUInteger count = [rows count];
                if (count <1) {
                    [CommonUtil alert:@"提示" msg:@"无需领药"];
                }
                else{
                    
                    self.dataList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSMutableDictionary *obj = [rows objectAtIndex:i];
                        
                        [self.dataList addObject:obj];
                    }
                    
                    [self.tableView reloadData];
                    [self updateFresh];
                    
                }
                
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
}

- (void) reqConfirm
{
    if ([self.dataList count]>0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
                                                        message:@"确定以当前列表领药??"
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")  
                                              otherButtonTitles: NSLocalizedString(@"Apply", @"Apply")
                              ,nil];
        [alert show];	
    }
    
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        // Set determinate mode
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
        hud.removeFromSuperViewOnHide = YES;
        
        iRfRgService* service = [iRfRgService service];
        NSDictionary *setting = [CommonUtil getSettings];
        NSString *username = [setting objectForKey:kSettingUserKey];
        NSString *password = [setting objectForKey:kSettingPwdKey];
        
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        NSString *jsonArray =[writer stringWithObject:[self.dataList copy]];
        
        NSLog(@"%@",jsonArray);
        
        [service doReqComfirm:self 
                       action:@selector(reqConfirmHandler:) 
                     username:username 
                     password:password 
                    jsonArray:jsonArray];
    }
    
}

- (void) reqConfirmHandler:(id)value
{
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [CommonUtil alert:@"连接失败" msg:[result localizedFailureReason]];
	}
    
	// Handle faults
	else if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [CommonUtil alert:@"soap连接失败" msg:[result faultString]];
	}				
    
    
	// Do something with the NSString* result
    else{
        NSString* result = (NSString*)value;
        //	resultText.text = [@"getRg returned the value: " stringByAppendingString:result] ;
        NSLog(@"%@", result);
        
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id json = [parser objectWithString:result];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
//                [self alert:NSLocalizedString(@"Info", @"Info") msg:@"操作成功"];
                
                self.dataList = [NSArray array];
                [self.tableView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:msg];
            }
            
        }
        else{
            
        }
    }
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    [self getReqList];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    self.title = [NSString stringWithFormat:@"领药列表(共%d条)",[self.dataList count]];
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *row = [self.dataList objectAtIndex:indexPath.row];
    
    
    UINib *nib = [UINib nibWithNibName:@"MedicineReqCellHD"
                                bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:kCellIdentifier];
    
    MedicineReqCell *cell = (MedicineReqCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
	cell.goodsname.text = [row objectForKey:@"goodsname"];
    cell.goodstype.text = [row objectForKey:@"goodstype"];
    cell.locno.text = [row objectForKey:@"locno"];
    cell.lotno.text = [row objectForKey:@"lotno"];
    cell.goodsqty.text = [row objectForKey:@"goodsqty"];
    cell.houserealqty.text = [row objectForKey:@"houserealqty"];
    cell.opqty.text = [row objectForKey:@"opqty"];
    cell.data = row;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


#pragma mark -
#pragma mark - refresh handle
-(void)updateFresh
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm:ss a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"%@ on %@",NSLocalizedString(@"Last Updated", @"Last Updated"), [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated] ;
    
    
    [self.refreshControl endRefreshing];
}
-(void)refreshView:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        refresh.attributedTitle = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"Loading...", @"Loading Status")] ;
        
        [self getReqList];
        
        [self performSelector:@selector(updateFresh) withObject:nil afterDelay:2];
        
    }
}


@end
