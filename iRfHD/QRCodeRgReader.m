//
//  QRCodeRgReader.m
//  iRf
//
//  Created by pro on 13-3-5.
//
//

#import "QRCodeRgReader.h"
#import "ScanOverlayView.h"
#import "iRfRgService.h"

NSString* const QRCodeRgReaderCellIdentifier = @"QRCodeRgReaderCell";

@implementation QRCodeRgReader

@synthesize dataList,uploadJSON;
@synthesize fieldDictionary;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"二维码收货";
        
        self.fieldDictionary = @[
                                 @{@"sid": @"明细ID"},
                                 @{@"lbt": @"原散件"},
                                 @{@"gid": @"货品ID"},
                                 @{@"gnm": @"货品名称"},
                                 @{@"gtp": @"货品规格"},
                                 @{@"gun": @"货品单位"},
                                 @{@"siz": @"包装大小"},
                                 @{@"lot": @"批号"},
                                 @{@"qty": @"实际数量"},
                                 @{@"prc": @"单价"},
                                 @{@"scq": @"生产日期"},
                                 @{@"sxq": @"失效期"},
                                 @{@"inv": @"发票号"},
                                 @{@"pgh": @"发票代码"},
                                 @{@"prq": @"发票日期"},
                                 @{@"ttl": @"发票金额"},
                                 @{@"fdc": @"厂家"},
                                 @{@"pwh": @"批准文号"},
                                 @{@"zch": @"注册证号"},
                                 @{@"sdt": @"订单日期"},
                                 @{@"vid": @"供应商ID"},
                                 @{@"tid": @"天池ID"},
                                 @{@"pod": @"打印号"},
                                 @{@"xsd": @"原销售单"}
                                 ];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanAction:)];
    
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave                                                                          target:self action:@selector(sendJson:)];
    
    [self.navigationItem setRightBarButtonItems:@[sendBtn,camera] animated:YES];
    
    
    
    self.dataList = [NSArray array];
    
//    [self reloadByJson:@"{\"scq\":123}"];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QRCodeRgReaderCellIdentifier];
    
    if (cell == nil)
	{
        // Configure the cell...
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:QRCodeRgReaderCellIdentifier] ;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    NSDictionary *row = self.dataList[indexPath.row];
    
    NSString *fieldname = [row objectForKey:@"key"];
    NSString *fieldvalue = [row objectForKey:@"value"];
    
    cell.textLabel.text = fieldname;
    
    cell.detailTextLabel.text = fieldvalue;
    
    return cell;
}


#pragma mark -
#pragma mark  scanAction handle
-(IBAction)scanAction:(id)sender
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    //高分辨率模式可以扫描600个字符的qrcode
    reader.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [reader addScanLineOverlay];
	//reader.showsZBarControls = NO;
	
	
	
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_NONE
				   config: ZBAR_CFG_ENABLE
					   to: 0];
    [scanner setSymbology: ZBAR_QRCODE
				   config: ZBAR_CFG_ENABLE
					   to: 1];
	
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
    for(symbol in results) {
        // EXAMPLE: just grab the first barcode
        break;
    }
	
    // EXAMPLE: do something useful with the barcode data
	
    NSString *json = symbol.data;
//    [CommonUtil alert:[NSString stringWithFormat:@"%d",json.length] msg:json];
    
    [self reloadByJson:json];

    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark -
#pragma mark json to cell
-(void) reloadByJson:(NSString*)json
{
    
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (obj != nil) {
        NSDictionary *dict = (NSDictionary*)obj;
        NSMutableArray *array = [NSMutableArray array];
        
        for ( NSDictionary *o in self.fieldDictionary) {
            NSString *key = o.allKeys[0];
            NSString *fieldname = o.allValues[0];
            id obj = [dict objectForKey:key];
            if (obj != nil &&  obj != [NSNull null]) {
                NSString *value = [NSString stringWithFormat:@"%@",obj];
                NSDictionary *row = @{
                                      @"key":fieldname,
                                      @"value":value
                                      };
                NSLog(@"%@",row);
                [array addObject:row];
            }
            
        }
        self.dataList = array;
        self.uploadJSON = json;
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark send json to server
-(IBAction)sendJson:(id)sender
{
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    iRfRgService *service = [iRfRgService service];
    [service doRgBy2DBarcode:self action:@selector(sendJsonHandler:) username:username password:password json:self.uploadJSON];
}

-(void)sendJsonHandler:(id)value
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
    
    else {
        // Do something with the NSString* result
        NSString* result = (NSString*)value;
        NSLog(@"sendJsonHandler returned the value: %@", result);
        
        NSError *error = nil;
        id retObj = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        NSLog(@"%@",retObj);
        
        
        
        if (retObj != nil) {
            NSDictionary *ret = (NSDictionary*)retObj;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]==YES) {
                
                self.dataList = @[];
                self.uploadJSON = nil;
                [self.tableView reloadData];
            }
            else{
                NSString *msg = (NSString*) [ret objectForKey:kMsgKey];
                if ([msg isKindOfClass:[NSNull class]]) {
                    msg = @"空指针";
                }
                [CommonUtil alert:NSLocalizedString(@"Error", @"Error")
                              msg:msg];
            }
        }
        else {
            [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:[error localizedDescription]];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
