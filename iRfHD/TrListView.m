//
//  NtrListView.m
//  iRf
//
//  Created by user on 11-8-30.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrListView.h"
#import "iRfRgService.h"
#import "SBJson.h"
#import "TrView.h"
#import "POAPinyin.h"
#import "MBProgressHUD.h"

static NSString *kCellIdentifier = @"TrListViewIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kExplainKey = @"explanation";
static NSString *kObjKey = @"obj";
static NSString *kTitlePrefix = @"货品对应关系";

@implementation TrListView

@synthesize menuList,refreshButtonItem;
@synthesize filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize titleSegmentIndex,titleArray,titleBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        refresh.tintColor = [UIColor lightGrayColor];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status")] ;
        [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
        
        
        if (self.refreshButtonItem == nil) {
            self.refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh                                                                          target:self action:@selector(getTrGds)];
            
        }
        
        self.navigationItem.rightBarButtonItem = self.refreshButtonItem;

    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) alert:(NSString*)title msg:(NSString*)msg {
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];	
}



#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    //增加未维护客户码和货位的过滤项
    
    self.titleArray = [NSArray arrayWithObjects:@"全部",@"无客户码", @"无货位", @"无基本码",nil];
    titleSegmentIndex = 0;
    
    self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@[全部▾]",kTitlePrefix] forState:UIControlStateNormal];
    [self.titleBtn addTarget:self action:@selector(showConditionList) forControlEvents:UIControlEventTouchUpInside];
    self.titleBtn.frame = CGRectMake(0, 0, 200, 31);
    [self.titleBtn setCenter:self.navigationItem.titleView.center];
    self.navigationItem.titleView = self.titleBtn;
//    [testbtn release];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
	[self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSDictionary *) tableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = nil;
    NSMutableArray *list = nil;
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        list =  self.filteredListContent;
    }
	else
	{
        list = self.menuList;
    }
    if (titleSegmentIndex == TrListTitleSegAll) {
        row = [list objectAtIndex:indexPath.row];
    }
    else {
        NSString *key = nil;
        if (titleSegmentIndex == TrListTitleSegNoCusid){
            key = @"cusgdsid";
        }
        else if (titleSegmentIndex == TrListTitleSegNoLocno){
            key = @"locno";        }
        else if (titleSegmentIndex == TrListTitleSegNoBasecode){
            key = @"basecode";
        }
        for (int i=0,j=list.count; i<j; i++) {
            NSDictionary *tmprow = [list objectAtIndex:i];
            NSDictionary *obj = [tmprow objectForKey:kObjKey];
            NSString *value = [obj objectForKey:key];
            if (value == nil || [@"" isEqualToString:value]) {
                if (indexPath.row == count) {
                    row = tmprow;
                    break;
                }
                count++;
            }
        }
    }
    return row;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSMutableArray *list = nil;
    NSInteger count = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        list =  self.filteredListContent;
    }
	else
	{
        list = self.menuList;
    }
    if (titleSegmentIndex == TrListTitleSegAll) {
        count =  [list count];
    }
    else{
        NSString *key = nil;
        if (titleSegmentIndex == TrListTitleSegNoCusid){
            key = @"cusgdsid";
        }
        else if (titleSegmentIndex == TrListTitleSegNoLocno){
            key = @"locno";        }
        else if (titleSegmentIndex == TrListTitleSegNoBasecode){
            key = @"basecode";
        }
        for (int i=0,j=list.count; i<j; i++) {
            NSDictionary *obj = [[list objectAtIndex:i] objectForKey:kObjKey];
            NSString *value = [obj objectForKey:key];
            if (value == nil || [@"" isEqualToString:value]) {
                count++;
            }
        }
    }
    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@(%d)[%@▾]",kTitlePrefix,count,[self.titleArray objectAtIndex:titleSegmentIndex]] forState:UIControlStateNormal];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [self tableView:tableView rowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[row objectForKey:kCellIdentifier]];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[row objectForKey:kCellIdentifier]] ;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [row objectForKey:kTitleKey];
    [cell.textLabel setFont: [UIFont fontWithName:@"Heiti SC" size:20]];
    cell.detailTextLabel.text = [row objectForKey:kExplainKey];
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    
    NSString *cusgdsid = (NSString*) [obj objectForKey:@"cusgdsid"];
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIView *backgrdView = [[UIView alloc] initWithFrame:cell.frame];
    if ([cusgdsid isEqualToString:@""]|| (!IsInternet&&[cusgdsid rangeOfString:@"tmp" options:NSCaseInsensitiveSearch].location != NSNotFound)) {    
        backgrdView.backgroundColor = [UIColor greenColor];
    }
    else{
        backgrdView.backgroundColor = [UIColor whiteColor];
    }
    cell.backgroundView = backgrdView;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [self tableView:tableView rowAtIndexPath:indexPath];
    // Navigation logic may go here. Create and push another view controller.
    
    NSDictionary *obj = [row objectForKey:kObjKey];
    TrView* targetViewController = [[TrView alloc] initWithNibName:@"TrView" bundle:nil values:obj];
    //    targetViewController.scanViewDelegate = self;
	[[self navigationController] pushViewController:targetViewController animated:YES];
    
}

#pragma mark -
#pragma mark UIViewController delegate

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self getTrGds];
    
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    [self.tableView reloadData];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
}

#pragma mark -
#pragma mark - TrGds

- (void) getTrGds{
    
    if (self.refreshButtonItem) {
        self.refreshButtonItem.enabled = NO;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // Set determinate mode
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = @"Loading";
    hud.removeFromSuperViewOnHide = YES;
    
    
    
    iRfRgService* service = [iRfRgService service];
    NSDictionary *setting = [CommonUtil getSettings];
    NSString *username = [setting objectForKey:kSettingUserKey];
    NSString *password = [setting objectForKey:kSettingPwdKey];
    
    [service getTrGds:self action:@selector(getTrGdsHandler:)
             username: username
             password: password
                 page:0];
    
}

// Handle the response from getRg.

- (void) getTrGdsHandler: (id) value {
    
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
        
        
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id json = [parser objectWithString:result];
        
        
        if (json != nil) {
            NSDictionary *ret = (NSDictionary*)json;
            NSString *retflag = (NSString*) [ret objectForKey:kRetFlagKey];
            
            if ([retflag boolValue]) {
                NSArray *rows = (NSArray*) [ret objectForKey:kMsgKey];
                NSUInteger count = [rows count];
                if (count <1) {
                    [self alert:@"提示" msg:@"没有找到货品关系"];
                }
                else{
                    
                    self.menuList = [NSMutableArray array];
                    
                    for (int i=0; i<[rows count]; i++) {
                        NSDictionary *obj = [rows objectAtIndex:i];
                        NSString *text = [obj objectForKey:@"goodsname"];
                    
                        NSString *detailText = [obj objectForKey:@"goodstype"];
                        detailText = [detailText stringByAppendingString:@"     "];
                        detailText = [detailText stringByAppendingString:[obj objectForKey:@"factno"]];
                        
                        NSString *idv = [obj objectForKey:@"ugoodsid"];
                        
                        [self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  text, kTitleKey,
                                                  detailText, kExplainKey,
                                                  obj,kObjKey,
                                                  idv,kCellIdentifier,
                                                  nil]];
                    }
                    
                    
                    self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.menuList count]];
                    
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
    if (self.refreshButtonItem) {
        self.refreshButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
    [self updateFresh];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
    
    NSString *searchKey = nil;
    if ([scope isEqualToString:@"规格"] )
    {
        searchKey = @"goodstype";
    }
    else if([scope isEqualToString:@"厂家"] )
    {
        searchKey = @"factno";
    }
    else if ([scope isEqualToString:@"货品码"]) {
        searchKey = @"cusgdsid";
    }
    else if ([scope isEqualToString:@"拼音"]) {
        searchKey = @"goodsname";
    }
    else{
        searchKey = @"goodsname";
    }
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *row in menuList)
	{
       
        NSString *field = [[row objectForKey:kObjKey] objectForKey:searchKey];
        NSUInteger result = NSNotFound;
        if ([scope isEqualToString:@"拼音"]) {
            NSString *pinyin = [POAPinyin quickConvert:field byConvertMode:POAPinyinConvertModeFirstWord];
            result = [pinyin  rangeOfString:[searchText uppercaseString]].location;
        }
        else{
            result = [field  rangeOfString:searchText].location;
        }
        if ( result != NSNotFound )
        {
            [self.filteredListContent addObject:row];
        }
        
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark -
#pragma mark - LeveyPopListViewDelegate

- (void) showConditionList
{
    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"请选择筛选条件..." options:self.titleArray];
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    [self.titleBtn setEnabled:NO];
}

- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    titleSegmentIndex =  anIndex;
    [self.titleBtn setTitle:[NSString stringWithFormat:@"%@[%@▾]",kTitlePrefix,[self.titleArray objectAtIndex:anIndex]] forState:UIControlStateNormal];
    [self.tableView reloadData];
    [self.titleBtn setEnabled:YES];
}

- (void)leveyPopListViewDidCancel
{
    [self.titleBtn setEnabled:YES];
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
        
        [self getTrGds];
        
        [self performSelector:@selector(updateFresh) withObject:nil afterDelay:2];
        
    }
}

@end
