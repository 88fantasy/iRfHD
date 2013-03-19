//
//  BaseCodeTableView.m
//  iRf
//
//  Created by xian weijian on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseCodeTableView.h"

@implementation BaseCodeTableView

@synthesize codeinput,codeList,codenum;
@synthesize baseCodeTableViewDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.codenum = -1;
        self.title = @"扫描基药码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputDone:)];
    self.navigationItem.rightBarButtonItem = addButton;
//    [addButton release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 31);
    [button setImage:[UIImage imageNamed:@"barcode.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    self.codeinput.leftView = button;
    self.codeinput.leftViewMode = UITextFieldViewModeAlways;
//    [button release];
    
    self.codeList = [NSMutableArray array];
}

-(IBAction)inputDone:(id)sender
{
//    if ([self.codeList count]==codenum||codenum==-1) {
        if(self.baseCodeTableViewDelegate != nil){
            [self.baseCodeTableViewDelegate DidCodeInput: [NSArray arrayWithArray:[self.codeList copy]]];
            [self.navigationController popViewControllerAnimated:YES];
        }
//    }
//    else {
//        NSString *msg = @"基药码的数量不符,总数为";
//        msg = [msg stringByAppendingFormat:@"%d",codenum];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"Error") message: msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];	
//        [alert release];
//    }
}

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
	[self addTextToList:symbol.data];
	
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    
    if ([textField.text length]>0) {
        [self addTextToList:textField.text];
        textField.text = @"";
    }
    
	return YES;
}

- (void) addTextToList:(NSString *)code
{
    if (![self.codeList containsObject:code]) {
        [self.codeList addObject:code];
        [self.tableView reloadData];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.codeinput = nil;
    self.codeList = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { 
    // Return the number of sections. 
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.codeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self.codeList objectAtIndex:indexPath.row]];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[self.codeList objectAtIndex:indexPath.row] ] ;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [self.codeList objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



//// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.codeList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     [detailViewController release];
//     */
//}

@end
