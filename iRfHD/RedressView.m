//
//  RedressView.m
//  iRfHD
//
//  Created by pro on 13-3-25.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import "RedressView.h"
#import "RedressCell.h"
#import "BAMethod.h"

static NSString *inTableCellIdentifier = @"RedressViewInTableCell";
static NSString *outTableCellIdentifier = @"RedressViewOutTableCell";
static NSString *goodsTableCellIdentifier = @"RedressViewGoodsTableCell";

#define kRedressViewSoKey @"sos"
#define kRedressViewGoodsKey @"goods"

@implementation RedressView

@synthesize inTable,inSearch,outTable,soTable;
@synthesize searchPopOver,goodsSns,conmaker,goodsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    inDataList = [NSMutableArray array];
    outDataList = [NSMutableArray array];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(redressSaveHandler)];
    
    self.conmaker = [[ConditionMakerController alloc]initWithStyle:UITableViewStylePlain];
    self.conmaker.fieldDictionaryList = @[
                                    @{kConditionMakerFieldNameKey: @"hisgdsid",
                                      kConditionMakerFieldTextKey: @"货品码"},
                                    @{kConditionMakerFieldNameKey: @"goodsname",
                                      kConditionMakerFieldTextKey: @"货品名称"},
                                    @{kConditionMakerFieldNameKey: @"goodspy",
                                      kConditionMakerFieldTextKey: @"货品拼音"},
                                    
                                    ];
    self.conmaker.delegate = self;
    
    self.goodsTable = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
    self.goodsTable.tableView.dataSource = self;
    self.goodsTable.tableView.delegate = self;
    self.goodsTable.tableView.allowsSelection = NO;
    
    
    self.goodsSns = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.goodsSns.dataSource = self;
    self.goodsSns.delegate = self;
    
    [self.goodsSns setViewControllers:@[self.conmaker] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.searchPopOver = [[UIPopoverController alloc] initWithContentViewController:self.goodsSns];
    self.searchPopOver.popoverContentSize = CGSizeMake(480., 480.);
    self.searchPopOver.delegate = self;
    
    
    goodsDataSetRequest = [[DataSetRequest alloc]initWithGridcode:@"hscm-goods-stock-sns" querytype:@"table" datasource:@"hscm_stock_group_v" querymoduleid:@"all" sumfieldnames:nil];
    goodsDataSetRequest.delegate = self;
    
    [self.inTable registerNib:[UINib nibWithNibName:@"RedressCell" bundle:nil] forCellReuseIdentifier:inTableCellIdentifier];
    [self.outTable registerNib:[UINib nibWithNibName:@"RedressCell" bundle:nil] forCellReuseIdentifier:outTableCellIdentifier];
    
    
    soDataSetRequest = [[DataSetRequest alloc]initWithGridcode:@"func-somgr-all-grid" querytype:@"table" datasource:@"hscm_so_doc_dtl_v" querymoduleid:@"all" sumfieldnames:nil];
    soDataSetRequest.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!IsLandscape) {
        [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:@"请横置屏幕使用此功能"];
    }
}

#pragma mark ios6+纵向旋转控制需要以下3个 覆盖viewcontroller的方法
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark -
#pragma mark - UITableViewDataSource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.soTable) {
        if (soDataSetRequest.userInfo) {
            NSArray *sos = [soDataSetRequest.userInfo objectForKey:kRedressViewSoKey];
            return sos.count;
        }
        else {
            return 0;
        }
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.soTable && soDataSetRequest.userInfo) {
        NSArray *sos = [soDataSetRequest.userInfo objectForKey:kRedressViewSoKey];
        return [[sos objectAtIndex:section] objectForKey:@"title"];
    }
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.goodsTable.tableView) {
        if (goodsDataSetRequest.userInfo) {
            NSArray *rows = [goodsDataSetRequest.userInfo objectForKey:kRedressViewGoodsKey];
            return rows.count;
        }
        else {
            return 0;
        }
    }
    else if (tableView == self.inTable) {
        return inDataList.count;
    }
    else if (tableView == self.outTable) {
        return outDataList.count;
    }
    else if (tableView == self.soTable) {
        if (soDataSetRequest.userInfo) {
            NSArray *sos = [soDataSetRequest.userInfo objectForKey:kRedressViewSoKey];
            NSArray *dtl =  [[sos objectAtIndex:section] objectForKey:@"dtl"];
            return dtl.count;
        }
        else {
            return 0;
        }
    }
    else {
        return 0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle celltype = UITableViewCellStyleSubtitle;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    NSString *identifier = nil;
    if (tableView == self.goodsTable.tableView) {
        identifier = goodsTableCellIdentifier;
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else if (tableView == self.inTable){
        identifier = inTableCellIdentifier;
    }
    else if (tableView == self.outTable) {
        identifier = outTableCellIdentifier;
    }
    else {
        identifier = @"";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
        
        cell = [[UITableViewCell alloc] initWithStyle:celltype reuseIdentifier:identifier] ;
        cell.accessoryType = accessoryType;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    if (tableView == self.goodsTable.tableView) {
        NSArray *goods =  [goodsDataSetRequest.userInfo objectForKey:kRedressViewGoodsKey];
        NSDictionary *good = goods[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@[%@]  %@%@",
                               [good objectForKey:@"goodsname"],
                               [good objectForKey:@"hisgdsid"],
                               [good objectForKey:@"goodsqty"],
                               [good objectForKey:@"goodsunit"]
                               ];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 货位[%@] 生产日期[%@] 失效期[%@] 有效期至[%@]",
                                     
                                     [good objectForKey:@"goodstype"],
                                     [good objectForKey:@"locno"],
                                     [good objectForKey:@"proddate"],
                                     [good objectForKey:@"invaliddate"],
                                     [good objectForKey:@"validto"]
                                    ];
    }
    else if (tableView == self.inTable || tableView == self.outTable) {
        RedressCell *cel = (RedressCell*)cell;
        NSMutableDictionary *dict = nil;
        if (tableView == self.inTable) {
            dict = [inDataList objectAtIndex:indexPath.row];
            cel.goodsqty.enabled = NO;
        }
        else {
            dict = [outDataList objectAtIndex:indexPath.row];
        }
        cel.goodsname.text = [dict objectForKey:@"goodsname"];
        cel.goodsqty.text = [dict objectForKey:@"useqty"];
        cel.goodsunit.text = [dict objectForKey:@"goodsunit"];
        cel.cellData = dict;
        
    }
    else if (tableView == self.soTable) {
        NSArray *sos = [soDataSetRequest.userInfo objectForKey:kRedressViewSoKey];
        NSArray *dtl =  [[sos objectAtIndex:indexPath.section] objectForKey:@"dtl"];
        NSDictionary *dict = [dtl objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)  %@%@",
                               [dict objectForKey:@"goodsname"],
                               [dict objectForKey:@"hisgdsid"],
                               [dict objectForKey:@"goodsqty"],
                               [dict objectForKey:@"goodsunit"]
                            ];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"批号[%@] 生产日期[%@] 失效期[%@] 有效期至[%@]",
                                     [dict objectForKey:@"lotno"],
                                     [dict objectForKey:@"proddate"],
                                     [dict objectForKey:@"invaliddate"],
                                     [dict objectForKey:@"validto"]
                                    ];
        UIImageView *uncheck = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unchecked.png"]];
        cell.accessoryView = uncheck;
        
	}
    return cell;
}

#pragma mark -
#pragma mark uitableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.soTable) {
        return  30;
    }
    else {
        return 0;
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.goodsTable.tableView) {
        NSArray *goods =  [goodsDataSetRequest.userInfo objectForKey:kRedressViewGoodsKey];
        NSDictionary *good = goods[indexPath.row];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:good];
        [dict setObject:@"1" forKey:@"useqty"];
        [outDataList addObject:dict];
        [self.outTable reloadData];
        [self.searchPopOver dismissPopoverAnimated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (tableView == self.inTable || tableView == self.outTable) {
        return YES;
    }
    else {
        return NO;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if (tableView == self.inTable) {
            [inDataList removeObjectAtIndex:indexPath.row];
        }
        else if (tableView == self.outTable) {
            [outDataList removeObjectAtIndex:indexPath.row];
        }
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.soTable) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView =  [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checked.png"]];

        
        
        NSArray *sos =  [soDataSetRequest.userInfo objectForKey:kRedressViewSoKey];
        NSArray *dtls = [sos[indexPath.section] objectForKey:@"dtl"];
        NSDictionary *dtl = dtls[indexPath.row];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dtl];
        [dict setObject:[dtl objectForKey:@"goodsqty"] forKey:@"useqty"];
        [inDataList addObject:dict];
        [self.inTable reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.soTable) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView =  [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unchecked.png"]];
    }
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource Delegate
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController == self.goodsTable) {
        return self.conmaker;
    }
    else {
        return nil;
    }
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController == self.conmaker) {
        return self.goodsTable;
    }
    else {
        return nil;
    }
}

#pragma mark - 
#pragma mark UISearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ( searchBar.text.length > 0 ) {
        NSDate *threeMonthsBefore = [NSDate dateWithTimeIntervalSinceNow: - 60 * 60 * 24 * 90 ];
        NSString *threeMonthsBeforeStr = [CommonUtil stringFromDate:threeMonthsBefore];
        
        
        NSDictionary *searchfield = nil;
        
        NSScanner* scan = [NSScanner scannerWithString:searchBar.text];
        int val;
        if([scan scanInt:&val] && [scan isAtEnd]){
            searchfield = NSMakeConditionClike(@"orgsoid", searchBar.text);
        }
        else {
            searchfield = NSMakeConditionClike(@"customname", searchBar.text);
        }
        
        [soDataSetRequest doQueryWithConditions:@[
                searchfield,
                NSMakeConditionCbigEqual(@"inputdate", threeMonthsBeforeStr),
                NSMakeConditionCeq(@"sotype", @"1"), //销售
                NSMakeConditionCeq(@"dtlconfirmflag", @"1")
                                                    ] byRetAll:YES];
    }
    [searchBar resignFirstResponder];
}


#pragma mark -
#pragma mark reset
-(void)reset
{
    inDataList = [NSMutableArray array];
    outDataList = [NSMutableArray array];
    soDataSetRequest.userInfo = nil;
    goodsDataSetRequest.userInfo = nil;
    [inTable reloadData];
    [outTable reloadData];
    [soTable reloadData];
    [goodsTable.tableView reloadData];
}

#pragma mark -
#pragma mark button handler

-(void)redressSaveHandler
{
    if (inDataList.count > 0 && outDataList.count > 0) {
        BAMethod *ba = [BAMethod baWithClassName:@"com.ebig.ba.edis.LoanBA" moduleId:@"all" methodName:@"doCreateInAndOut"];
        NSDictionary *loanin = [NSDictionary dictionaryWithObjectsAndKeys:
                                inDataList,@"dtls",
                                @"123",@"sss"
                                , nil];
        NSDictionary *loanout = [NSDictionary dictionaryWithObjectsAndKeys:
                                outDataList,@"dtls",
                                 [NSNumber numberWithBool:YES],@"test"
                                , nil];
        id ret = [ba invokeBySync:@[[NSNull null],loanin,loanout]];
        if (ret != nil) {
            [CommonUtil alert:NSLocalizedString(@"Success", @"Success") msg:@"操作成功"];
            [self reset];
        }
    }
}

-(IBAction)showSearchPopOver:(UIBarButtonItem*)sender
{
    // If the popover is already showing from the bar button item, dismiss it. Otherwise, present it.
	if (self.searchPopOver.popoverVisible == NO) {
		[self.searchPopOver presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        if (self.goodsSns.viewControllers[0] != self.conmaker) {
            [self.goodsSns setViewControllers:@[self.conmaker] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
	}
	else {
		[self.searchPopOver dismissPopoverAnimated:YES];
	}
}

-(IBAction)scanCode:(id)sender
{
    ZBarReaderViewController *_reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
    [_reader addScanLineOverlay];
    [self presentViewController:_reader animated:YES completion:nil];
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
    NSString *conditionstr = [NSString stringWithFormat:@" hisgdsid in (select edis_hisgdsid from edis_goods_translate where barcode = '%@')", symbol.data];
    [goodsDataSetRequest doQueryWithConditions:@[NSMakeConditionCstr(conditionstr)] byRetAll:YES];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil ];
    
    
}

-(void)conditionMakerController:(ConditionMakerController*)conditionMakerController didMaked:(NSDictionary*)makedconditions
{
    NSMutableArray *array = [NSMutableArray array];
    for( NSString *key in makedconditions.keyEnumerator ) {
        NSString *value = [makedconditions objectForKey:key];
        if ([key isEqualToString:@"goodspy" ] ) {
            value = [value uppercaseString];
        }
        [array addObject: NSMakeConditionClike(key, value)];
    }
    [goodsDataSetRequest doQueryWithConditions:array byRetAll:YES];
}
-(void)dataSetRequest:(DataSetRequest *)dataSetRequest dataDidRead:(NSArray *)rows
{
    if (rows == nil) {
        [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:@"查找过程中出错"];
        return;
    }
    if (dataSetRequest == goodsDataSetRequest) {
        dataSetRequest.userInfo = [NSDictionary dictionaryWithObject:rows forKey:kRedressViewGoodsKey];
        
        if ( rows.count > 1 ) {
            [self.goodsSns setViewControllers:@[self.goodsTable] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self.goodsTable.tableView reloadData];
        }
        else if (rows.count == 1) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:rows[0]];
//            [dict setObject:@"1" forKey:@"useqty"];
            [outDataList addObject:dict];
            [self.outTable reloadData];
        }
        else {
            [CommonUtil alert:NSLocalizedString(@"Info", @"Info") msg:@"没找到货品"];
        }
    }
    else if (dataSetRequest == soDataSetRequest) {
        
        if (rows.count > 0) {
            NSMutableArray *sos = [NSMutableArray array];
            
            for (NSUInteger i=0,j=rows.count; i<j; i++) {
                NSDictionary *row = rows[i];
                NSString *soid = [row objectForKey:@"hscm_soid"];
                
                NSUInteger m=0,n=sos.count;
                for (; m<n; m++) {
                    if ([soid isEqualToString:[sos[m] objectForKey:@"soid"]]) {
                        NSMutableArray *dtls = [sos[m] objectForKey:@"dtl"];
                        [dtls addObject:row];
                        break;
                    }
                }
                if (m==n) {
                    NSString *customname = [row objectForKey:@"customname"];
                    NSString *orgsoid = [row objectForKey:@"orgsoid"];
                    NSString *sex = [@"1" isEqualToString:[row objectForKey:@"sex"]]?@"男":@"女";
                    NSDictionary *section = @{@"soid": soid,
                                              @"title": [NSString stringWithFormat:@"%@  %@  处方号:%@",customname,sex,orgsoid],
                                              @"dtl": [NSMutableArray arrayWithObject:row]
                                              };
                    [sos addObject:section];
                }
            }
            soDataSetRequest.userInfo = [NSDictionary dictionaryWithObject:sos forKey:kRedressViewSoKey];
            [self.soTable reloadData];
        }
        else {
            [CommonUtil alert:NSLocalizedString(@"Info", @"Info") msg:@"没有找到处方"];
        }
    }
    
}

@end
