//
//  RedressCell.m
//  iRfHD
//
//  Created by pro on 13-3-28.
//  Copyright (c) 2013年 rwe. All rights reserved.
//

#import "RedressCell.h"

@implementation RedressCell

@synthesize goodsqty;
@synthesize goodsname;
@synthesize downgrade;
@synthesize cellData;

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
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.inputAccessoryView == nil) {
        CGRect rect = GetScreenSize;
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, rect.size.height, 50)];
        numberToolbar.barStyle = UIBarStyleBlackTranslucent;
        numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel",@"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Apply",@"Apply") style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                               nil];
        [numberToolbar sizeToFit];
        textField.inputAccessoryView = numberToolbar;
        
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.cellData setObject:self.goodsqty.text forKey:@"goodsqty"];
}

-(void)cancelNumberPad
{
    [self.goodsqty resignFirstResponder];
    self.goodsqty.text = @"0";
}

-(void)doneWithNumberPad
{
    [self.goodsqty resignFirstResponder];
}

-(IBAction)qtydown:(UIButton *)sender
{
    if (self.goodsqty.enabled) {
        NSUInteger qty = [self.goodsqty.text intValue];
        if (qty > 1) {
            self.goodsqty.text = [NSString stringWithFormat:@"%d",qty-1];
        }
    }
}

-(IBAction)qtyup:(UIButton *)sender
{
    if (self.goodsqty.enabled) {
        self.goodsqty.text = [NSString stringWithFormat:@"%d",[self.goodsqty.text intValue]+1];
    }
}

-(IBAction)downgradechange:(UISegmentedControl*)sender
{
   [self.cellData setObject:[NSString stringWithFormat:@"%d",[sender selectedSegmentIndex]] forKey:@"downgraded"];
}
@end
