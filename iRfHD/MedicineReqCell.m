//
//  MedicineReqCell.m
//  iRf
//
//  Created by xian weijian on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MedicineReqCell.h"

@implementation MedicineReqCell

@synthesize goodsname,goodsqty,goodstype,locno,lotno,opqty,houserealqty,data;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (self.opqty.inputAccessoryView == nil) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                               nil];
        [numberToolbar sizeToFit];
        self.opqty.inputAccessoryView = numberToolbar;
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableView *tableView =  (UITableView *)[self superview];
//    CGFloat offsety = [tableView contentOffset].y;
    CGFloat y =   [tableView indexPathForCell: self].row * self.frame.size.height;
    [tableView setContentOffset:CGPointMake(0, y) animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.opqty.text intValue]>[self.goodsqty.text intValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:@"输入数量不可以大于该货位总库存" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];	
        return NO;
    }
    else {
        [data setObject:self.opqty.text forKey:@"opqty"];
        return YES;
    }
}
-(void)cancelNumberPad
{
    [self.opqty resignFirstResponder];
    self.opqty.text = @"0";
}

-(void)doneWithNumberPad
{
    [self.opqty resignFirstResponder];
}

@end
