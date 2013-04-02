//
//  ConditionMakerController.m
//  iRfHD
//
//  Created by pro on 13-3-20.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import "ConditionMakerController.h"

#define kTextFieldWidth 250
#define kTextFieldHeight 40

@interface ConditionMakerController ()

@end

static NSString *cmcCellIdentifier = @"ConditionMakerControllerCell";

@implementation ConditionMakerController

@synthesize fieldDictionaryList;
@synthesize delegate;
@synthesize controllermode;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.allowsSelection = NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.fieldDictionaryList = [NSArray array];
        self.tableView.allowsSelection = NO;
        controllermode = ConditionMakerModeSingle;
        
        _fieldValues = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (id)controllerWithMode:(ConditionMakerMode)mode style:(UITableViewStyle)style fields:(NSArray*)fieldlist
{
    ConditionMakerController *cmc = [[ConditionMakerController alloc] initWithStyle:style];
    cmc.fieldDictionaryList = fieldlist;
    cmc.controllermode = mode;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    if (self.fieldDictionaryList){
        return self.fieldDictionaryList.count;
    }
    else {
        return 0;
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kTextFieldHeight;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cmcCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cmcCellIdentifier];
    }
    
    NSDictionary *row = [self.fieldDictionaryList objectAtIndex:indexPath.row];
    NSString *fieldname = [row objectForKey:kConditionMakerFieldNameKey];
    NSString *title = [row objectForKey:kConditionMakerFieldTextKey];
    NSNumber *type = [row objectForKey:kConditionMakerInputTypeKey];
    if (type == nil) {
        type = [NSNumber numberWithInteger:ConditionMakerInputTypeText];
    }
    cell.textLabel.text = title;
    CGRect rect = cell.frame;
    rect.size.width = rect.size.width * 0.6;
    rect.origin.y = 9;
    switch ([type integerValue]) {
        case ConditionMakerInputTypeText:
            rect.size.height = 31;
            cell.accessoryView = [self createTextFieldWithFrame:rect fieldname:fieldname];
            break;
            
        default:
            break;
    }
    
    UIView *view = cell.accessoryView;
    if (view != nil) {
        view.tag = indexPath.row;
    }
    
    return cell;
}

#pragma mark -
#pragma mark create textfield
-(UITextField*)createTextFieldWithFrame:(CGRect)frame fieldname:(NSString*)fieldname
{
//    CGRect frame = CGRectMake(0, 0, kTextFieldWidth, kTextFieldHeight);
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    textfield.accessibilityIdentifier = fieldname;
    textfield.borderStyle = UITextBorderStyleRoundedRect;
//    textfield.textColor = [UIColor blackColor];
//    textfield.font = [UIFont systemFontOfSize:kFontSize];
//    textfield.backgroundColor = [UIColor whiteColor];
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    textfield.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleWidth;
    
    if (controllermode == ConditionMakerModeSingle) {
        textfield.returnKeyType = UIReturnKeySearch;
    }
    else {
        textfield.returnKeyType = UIReturnKeyDone;
    }
    
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    
    textfield.delegate = self;
    
    return textfield;
}

#pragma mark -
#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
    if (controllermode == ConditionMakerModeSingle) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(conditionMakerController:didMaked:)]) {
            NSDictionary *condition = @{textField.accessibilityIdentifier:textField.text};
            [self.delegate performSelector:@selector(conditionMakerController:didMaked:) withObject:self withObject:condition];
        }
    }
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:CGPointMake(0, textField.frame.origin.y) animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (controllermode == ConditionMakerModeMulti) {
        if ([@"" isEqualToString:textField.text]) {
            [_fieldValues removeObjectForKey:textField.accessibilityIdentifier];
        }
        else {
            [_fieldValues setObject:textField.text forKey:textField.accessibilityIdentifier];
        }
    }
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(conditionDidMaked:)]) {
//        [self.delegate performSelector:@selector(conditionDidMaked) withObject:[self getConditions]];
//    }
//}

#pragma mark -
#pragma mark getcondition or delegate
-(NSDictionary*)getConditions
{
    return _fieldValues;
}

@end
