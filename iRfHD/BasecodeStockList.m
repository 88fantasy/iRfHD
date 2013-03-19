//
//  BasecodeStockList.m
//  iRf
//
//  Created by pro on 13-1-24.
//
//

#import "BasecodeStockList.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "PCPieChart.h"
#import "PCLineChartView.h"
#import "MBProgressHUD.h"

#define CELLHEIGHT 440.0

@implementation BasecodeStockList

@synthesize dataList;
@synthesize colors;
@synthesize conditions;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"库存查询";
        
        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        refresh.tintColor = [UIColor lightGrayColor];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status")] ;
        [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
       
        
        colors = [NSArray arrayWithObjects:
                  UIColorFromRGB(0x4096EE),
                  UIColorFromRGB(0x36A667),
                  UIColorFromRGB(0xE37164),
                  UIColorFromRGB(0xE3D9C1),
                  UIColorFromRGB(0xB48A6B),
                  UIColorFromRGB(0x0070C3),
                  UIColorFromRGB(0xF4D2CD),
                  UIColorFromRGB(0x007D43),
                  UIColorFromRGB(0xC7E0CE),
                  UIColorFromRGB(0xB5493F),
                  UIColorFromRGB(0x786B40)
                  , nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(scanAction:)];
    
    
    self.navigationItem.rightBarButtonItem = button;
    
    
    self.dataList = [NSArray array];
    
   
}

-(void)viewDidAppear:(BOOL)animated
{
//    if (self.currentCode == nil) {
//        [self scanAction:nil];
//    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0,j = self.dataList.count; i<j; i++) {
        NSString *hisgdsid = [[self.dataList objectAtIndex:i] objectForKey:@"hisgdsid"];
        NSString *title = [hisgdsid substringToIndex:3];
        if (![array containsObject:title]) {
            [array addObject:title];
        }
    }
    return array;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    for (int i=0,j = self.dataList.count; i<j; i++) {
        NSString *hisgdsid = [[self.dataList objectAtIndex:i] objectForKey:@"hisgdsid"];
        NSString *datatitle = [hisgdsid substringToIndex:3];
        if ([title isEqualToString: datatitle]) {
            return i;
        }
    }
    return 0;
}

#pragma mark -
#pragma mark  getStock handle

- (void) getStock
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	hud.labelText = @"Loading";
    
    NSString *sql = [NSString stringWithFormat: @"select *   from (select 1 gp,b.hisgdsid,b.goodsname,(select dd_value   from sys_datadictionary x  where x.dd_key = 'STORAGENAME'    and dd_id = a.storagename) storagename,decode(a.downgraded, 0, b.goodsunit, b.downgradeunit) goodsunit,round(decode(a.downgraded,       0,       a.goodsqty,       a.goodsqty /       decode(nvl(b.downgradeqty, 1),     0,     1,     nvl(b.downgradeqty, 1))),2) baseqty,a.goodsqty  from hscm_stock_sum a, hscm_goods b where a.hisgdsid = b.hisgdsid union all select decode(a1.iotypedtl, '11', 2, '21', 3),b1.hisgdsid,max(c1.goodsname),to_char(a1.credate,'yyyy-mm'),max(c1.goodsunit),round(sum((case    when nvl(b1.downgraded, 0) = 0 then     b1.goodsqty    else  b1.goodsqty / c1.downgradeqty end))),0  from hscm_inout_doc a1, hscm_inout_dtl b1, hscm_goods c1 where a1.inoutid = b1.inoutid   and b1.completed = 1   and a1.iotypedtl in (11, 21)   and b1.hisgdsid = c1.hisgdsid   and getusemm(a1.credate) >= getusemm(sysdate) - 4 group by b1.hisgdsid, a1.iotypedtl,to_char(a1.credate,'yyyy-mm'))  where 1 = 1 "];
    
    if ([conditions objectForKey:@"basecode"]) {
        sql = [sql stringByAppendingFormat:@" hisgdsid in (select edis_hisgdsid from edis_goods_translate where barcode = '%@')", [conditions objectForKey:@"basecode"]];
    }
    
    sql = [sql stringByAppendingString:@" order by hisgdsid , gp asc"];
    
//    NSString *sql = @"select *   from (select 1 gp,b.hisgdsid,b.goodsname,(select dd_value   from sys_datadictionary x  where x.dd_key = 'STORAGENAME'    and dd_id = a.storagename) storagename,decode(a.downgraded, 0, b.goodsunit, b.downgradeunit) goodsunit,round(decode(a.downgraded,       0,       a.goodsqty,       a.goodsqty /       decode(nvl(b.downgradeqty, 1),     0,     1,     nvl(b.downgradeqty, 1))),2) baseqty,a.goodsqty  from hscm_stock_sum a, hscm_goods b where a.hisgdsid = b.hisgdsid union all select decode(a1.iotypedtl, '11', 2, '21', 3),b1.hisgdsid,max(c1.goodsname),to_char(a1.credate,'yyyy-mm'),max(c1.goodsunit),round(sum((case    when nvl(b1.downgraded, 0) = 0 then     b1.goodsqty    else  b1.goodsqty / c1.downgradeqty end))),0  from hscm_inout_doc a1, hscm_inout_dtl b1, hscm_goods c1 where a1.inoutid = b1.inoutid   and b1.completed = 1   and a1.iotypedtl in (11, 21)   and b1.hisgdsid = c1.hisgdsid   and getusemm(a1.credate) >= getusemm(sysdate) - 4 group by b1.hisgdsid, a1.iotypedtl,to_char(a1.credate,'yyyy-mm'))  where hisgdsid in ('100500T0010','130924')";
    
    iRfRgService *service = [iRfRgService service];
    [service queryJSON:self action:@selector(getStockHandle:) sql:sql
                dbname:nil];
    
}

- (void) getStockHandle:(id) value
{
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        NSError* result = (NSError*)value;
        [CommonUtil alert:@"连接失败" msg:[result localizedFailureReason]];
        return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        SoapFault * result = (SoapFault*)value;
        [CommonUtil alert:@"soap连接失败" msg:[result faultString]];
        return;
	}
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"getStockHandle returned the value: %@", result);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id retObj = [parser objectWithString:result];
    NSLog(@"%@",retObj);    
    if (retObj != nil) {
        NSDictionary *ret = (NSDictionary*)retObj;
        NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
        
        if ([retflag boolValue]==YES) {
            NSArray *result = [ret objectForKey:kMsgKey];
            NSMutableArray *section = [NSMutableArray array];
            
            if ([result count]==0) {
                [CommonUtil alert:NSLocalizedString(@"Info", @"Info")
                                                msg:@"没有找到库存信息"];
            }
            
            
            for (int i=0,j=[result count]; i<j; i++) {
                
                NSDictionary *resultrow = [result objectAtIndex:i];
                NSString *hisgdsid = [resultrow objectForKey:@"hisgdsid"];
                NSString *goodsname = [resultrow objectForKey:@"goodsname"];
//                NSString *gp = [resultrow objectForKey:@"gp"];
                int m=0,n=[section count];
                for (; m<n; m++) {
                    if ([hisgdsid isEqualToString:[[section objectAtIndex:m] objectForKey:@"hisgdsid"]]) {
                        break;
                    }
                }
                if (m==n) {
                    
                    [section addObject:[NSDictionary dictionaryWithObjectsAndKeys:hisgdsid,@"hisgdsid",
                                                goodsname,@"goodsname",
                                                [NSMutableArray arrayWithObject:resultrow],@"array",
                                                nil]];
                }
                else {
                    NSMutableArray *row = [[section objectAtIndex:m] objectForKey:@"array"];
                    [row addObject:resultrow];
                }
            }
            self.dataList = section;
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
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark -
#pragma mark  scanAction handle
-(IBAction)scanAction:(id)sender
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    
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
    self.conditions = @{@"basecode": symbol.data};
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil ];
    
    [self getStock];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) reader
{
    [reader dismissViewControllerAnimated:YES completion:nil];
    if (self.dataList.count < 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark  refresh handle
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
        
        [self getStock];
        
        [self performSelector:@selector(updateFresh) withObject:nil afterDelay:2];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionobj = [self.dataList objectAtIndex:section];
    return [NSString stringWithFormat:@"%@  %@",[sectionobj objectForKey:@"hisgdsid"],[sectionobj objectForKey:@"goodsname"]];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"BasecodeStockCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] ;
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    NSArray *subviews = cell.contentView.subviews;
    for ( UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [cell.contentView setContentMode:UIViewContentModeCenter];
    
    NSArray *rows = [[self.dataList objectAtIndex:indexPath.section] objectForKey:@"array"];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    float width = rect.size.width;
    
    if (indexPath.row == 0) {
        NSMutableArray *array = [NSMutableArray array];
        for (unsigned i = 0,j = [rows count]; i<j; i++) {
            NSDictionary *row = [rows objectAtIndex:i];
            if ([@"1" isEqualToString:[row objectForKey:@"gp"] ]) {
                [array addObject:row];
            }
        }
        
        PCPieChart *pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(0, 0 ,width,CELLHEIGHT)];
        [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        [pieChart setDiameter:width/2];
        [pieChart setSameColorLabel:YES];
        
        
        pieChart.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
        pieChart.percentageFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:45];
        
        
        NSMutableArray *components = [NSMutableArray array];
        for (int i=0; i<[array count]; i++)
        {
            NSDictionary *item = [array objectAtIndex:i];
            NSString *title = [NSString stringWithFormat:@"%@\n%@%@",
                               [item objectForKey:@"storagename"],
                               [item objectForKey:@"goodsqty"],
                               [item objectForKey:@"goodsunit"]
                               ];
            
            PCPieComponent *component = [PCPieComponent pieComponentWithTitle:title value:[[item objectForKey:@"baseqty"] floatValue]];
            [components addObject:component];
            
            if (i<colors.count) {
                UIColor *color = [colors objectAtIndex:i];
                [component setColour:color];
            }
            
//            if (i==0)
//            {
//                [component setColour:PCColorYellow];
//            }
//            else if (i==1)
//            {
//                [component setColour:PCColorGreen];
//            }
//            else if (i==2)
//            {
//                [component setColour:PCColorOrange];
//            }
//            else if (i==3)
//            {
//                [component setColour:PCColorRed];
//            }
//            else if (i==4)
//            {
//                [component setColour:PCColorBlue];
//            }
        }
        [pieChart setComponents:components];
        //        [pieChart setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview: pieChart];
    }
    else if (indexPath.row == 1){
        
        PCLineChartView *_lineChartView = [[PCLineChartView alloc] initWithFrame:CGRectMake(0,10,width,CELLHEIGHT-20)];
        [_lineChartView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
        
        _lineChartView.autoscaleYAxis = YES;
        _lineChartView.legendFont = [UIFont boldSystemFontOfSize:16];
        
        NSDateComponents *datecomponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
        NSInteger year = [datecomponents year];
        NSInteger month = [datecomponents month];
        
        NSMutableArray *x_labels =  [NSMutableArray array];
        
        for (int i = 3; i >= 0 ; i--) {
            NSInteger x = month - i;
            if (x > 0) {
                [x_labels addObject:[NSString stringWithFormat:@"%d-%02d",year,x]];
            }
            else {
                [x_labels addObject:[NSString stringWithFormat:@"%d-%02d",year-1,x+12]];
            }
        }
        
        
        NSMutableArray *components = [NSMutableArray array];
        
        NSMutableArray *inpoint = [NSMutableArray array];
        float insum = 0;
        for (int i = 0,j = [x_labels count]; i < j ; i++) {
            NSString *xLabel = [x_labels objectAtIndex:i];
            float rowsum = 0;
            for (unsigned m=0,n=[rows count]; m<n; m++) {
                NSDictionary *row = [rows objectAtIndex:m];
                if ([xLabel isEqualToString:[row objectForKey:@"storagename"]]
                    && [@"2" isEqualToString:[row objectForKey:@"gp"]]
                    ) {
                    rowsum += [[row objectForKey:@"baseqty"] floatValue];
                }
            }
            [inpoint addObject:[NSString stringWithFormat:@"%f",rowsum]];
            insum += rowsum;
        }
        
        PCLineChartViewComponent *incomponent = [[PCLineChartViewComponent alloc] init];
        [incomponent setTitle:[NSString stringWithFormat:@"%.0f",insum]];
        
        [incomponent setPoints:inpoint];
//            [incomponent setShouldLabelValues:YES];
        [incomponent setColour:PCColorGreen];
        [components addObject:incomponent];
        
        
        NSMutableArray *outpoint = [NSMutableArray array];
        float outsum = 0;
        for (int i = 0,j = [x_labels count]; i < j ; i++) {
            NSString *xLabel = [x_labels objectAtIndex:i];
            float rowsum = 0;
            for (unsigned m=0,n=[rows count]; m<n; m++) {
                NSDictionary *row = [rows objectAtIndex:m];
                if ([xLabel isEqualToString:[row objectForKey:@"storagename"]]
                    && [@"3" isEqualToString:[row objectForKey:@"gp"]]
                    ) {
                    rowsum += [[row objectForKey:@"baseqty"] floatValue];
                }
            }
            [outpoint addObject:[NSString stringWithFormat:@"%f",rowsum]];
            outsum += rowsum;
        }
        PCLineChartViewComponent *outcomponent = [[PCLineChartViewComponent alloc] init];
        [outcomponent setTitle:[NSString stringWithFormat:@"%.0f",outsum]];
        [outcomponent setPoints:outpoint];
//            [outcomponent setShouldLabelValues:YES];
        [outcomponent setColour:PCColorBlue];
        [components addObject:outcomponent];
        
        float max = insum > outsum ? insum : outsum;
        unsigned interval = max / 100  + 1 ;
        _lineChartView.maxValue = interval * 100;
        
        [_lineChartView setComponents:components];
        [_lineChartView setXLabels:x_labels];
        [cell.contentView addSubview: _lineChartView];
    }
	
	
    return cell;
}

@end
